#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2026 HPC-Gridware GmbH
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#___INFO__MARK_END_NEW__

proc is_host_resolvable {hostname} {
   if {[catch {exec ping -c 1 $hostname} result]} {
      return 0
   } else {
      return 1
   }
}

proc installer_get_diff_script {} {
   get_current_cluster_config_array ts_config
   return "$ts_config(testsuite_root_dir)/scripts/diff_backups.sh"
}

proc installer_get_hostname {} {
   get_current_cluster_config_array ts_config
   return $ts_config(master_host)
}

proc installer_get_backup_dir {{cs_version ""}} {
   get_current_cluster_config_array ts_config
   if {$cs_version == ""} {
      get_version_info version_array 1
      set cs_version $version_array(detected_version)

      puts "DEBUG installer_get_backup_dir: Using current version for backup dir: $cs_version"
   }

   if {[is_executed_in_hpc_gridware_lab_environment]} {
      set subpath "backups"
   } else {
      set subpath "backups_local"
   }
   return "$ts_config(testsuite_root_dir)/resources/$subpath/$cs_version"
}

## @brief set environment variables needed for the upgrade scripts
#
# @param array_name name of the array to store the environment variables
#
proc installer_set_env_for_upgrade {array_name} {
   get_current_cluster_config_array ts_config
   upvar env_array $array_name

   set env_array(SGE_ROOT) $ts_config(product_root)
   set env_array(SGE_CELL) $ts_config(cell)
   set env_array(SGE_QMASTER_PORT) $ts_config(commd_port)
   set env_array(SGE_EXECD_PORT) [expr $ts_config(commd_port) + 1]
   set env_array(SGE_CLUSTER_NAME) "p${ts_config(commd_port)}"
}

## @brief backup current cluster configuration
#
# @param backup_dir directory where to store the backup, default is the path returned by installer_get_backup_dir.
# @return exit code of the backup script
#
proc installer_save_config {{backup_dir ""}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   # backup script
   if {[is_version_in_range "9.0.0" "9.0.99"]} {
      set backup_script "$ts_config(product_root)/util/upgrade_modules/save_sge_config.sh"
   } else {
      set backup_script "$ts_config(product_root)/util/upgrade_modules/save_config.sh"
   }

   # backup location and backup user
   set hostname [installer_get_hostname]
   set admin_user $CHECK_USER
   set working_dir $ts_config(product_root)

   # environment for the backup script
   installer_set_env_for_upgrade env_array

   # default backup destination
   if {$backup_dir == ""} {
      set backup_dir [installer_get_backup_dir]
   }
   set arguments $backup_dir

   # if backup dir does exist remove it first to have a clean state. save_config also expects it to be empty
   if {[is_remote_path $hostname $admin_user $backup_dir]} {
      delete_directory $backup_dir
   }

   # start the backup
   set result [start_remote_prog $hostname $admin_user $backup_script $arguments prg_exit_state 60 0 $working_dir env_array]
   if {$prg_exit_state != 0} {
      ts_log_severe "Save config script failed:\n$result"
   }
   return $prg_exit_state
}

## @brief load cluster configuration from backup
#
# @param backup_dir directory where the backup is stored, default is the path returned by installer_get_backup_dir.
# @param on_error behavior in case of errors:
#        "cont_if_exist" (default) - continue only for errors that indicate
#                                    that an object to be created already exists
#                                    abort for all other errors
#        "abort"                   - exit on any error
#        "continue"                - continue on any error
# @return exit code of the load script
#
proc installer_load_config {{backup_dir ""} {on_error "cont_if_exist"}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   # backup script
   if {[is_version_in_range "9.0.0" "9.0.99"]} {
      set backup_script "$ts_config(product_root)/util/upgrade_modules/load_sge_config.sh"
   } else {
      set backup_script "$ts_config(product_root)/util/upgrade_modules/load_config.sh"
   }

   # backup location and backup user
   set hostname [installer_get_hostname]
   set admin_user $CHECK_USER
   set working_dir $ts_config(product_root)

   # environment for the backup script
   installer_set_env_for_upgrade env_array

   # backup destination
   if {$backup_dir == ""} {
      get_version_info version_array 1
      set cs_version $version_array(detected_version)

      puts "DEBUG: Using default backup dir for version $cs_version"

      set backup_dir $ts_config(testsuite_root_dir)/resources/backups/$cs_version
   }
   set log_file [get_tmp_file_name]
   set arguments "$backup_dir $log_file -mode upgrade -log I"

   # continue only if an object already exists (default also for the upgrade)
   # all other errors will lead to a failure and an exit code != 0
   append arguments " -on_error $on_error"

   # start the backup
   set result [start_remote_prog $hostname $admin_user $backup_script $arguments prg_exit_state 60 0 $working_dir env_array]
   if {$prg_exit_state != 0} {
      ts_log_severe "Load config script failed, see log file $log_file for details:\n$result"
   }
}

## @brief create a new backup and compares it with the original one
#
# The only file expected to be different is "backup_date" which contains a timestamp.
#
# @return exit code of the diff command (0 if no differences, != 0 otherwise
#
proc installer_create_and_compare_backup {{orig_backup_dir ""}} {
   global CHECK_USER

   set hostname [installer_get_hostname]
   if {$orig_backup_dir == ""} {
      set orig_backup_dir [installer_get_backup_dir]
   }
   set new_backup_dir [get_tmp_directory_name $hostname]

   puts "Original backup dir: $orig_backup_dir"
   puts "New backup dir: $new_backup_dir"
   puts "Command: ./src/scripts/diff_backups.sh $orig_backup_dir $new_backup_dir"

   # create backup of current configuration
   installer_save_config $new_backup_dir

   # compare backup after load_config with that one before load_config
   set command [installer_get_diff_script]
   set arguments "$orig_backup_dir $new_backup_dir"
   set output [start_remote_prog $hostname $CHECK_USER $command $arguments prg_exit_state]

   # The diff script returns 0 if no differences were found
   # The script automatically ignores the backup_date file
   # or attributes containing timestamps which are expected to be different
   # Extend the script if other files/attributes need to be ignored

   # check diff result
   if {$prg_exit_state != 0} {
      ts_log_severe "Backups differ:\nBefore: $orig_backup_dir\nAfter: $new_backup_dir\nDiff output: $output"
   } else {
      ts_log_info "Backups are identical: $output"
   }
   return $prg_exit_state
}
