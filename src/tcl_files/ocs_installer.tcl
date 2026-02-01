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

## @brief perform an interactive upgrade from a backup
#
# @param bckp_dir directory where the backup is stored
# @return exit code of the upgrade script
#
proc installer_do_upgrade_from_backup {bckp_dir} {
   get_current_cluster_config_array ts_config

   global CHECK_DEBUG_LEVEL CHECK_ADMIN_USER_SYSTEM CHECK_USER

   set new_ijs 1

   ts_log_fine "performing upgrade ..."
   ts_log_fine "Backup config directory is set to: $bckp_dir"

   set do_log_output 0 ;# _LOG
   if { $CHECK_DEBUG_LEVEL == 2 } {
     set do_log_output  1 ;# 1
   }

   if {$CHECK_ADMIN_USER_SYSTEM == 0} {
      set install_user "root"
   } else {
      set install_user $CHECK_USER
      ts_log_fine "--> install as user $CHECK_USER <--"
   }


   set LICENSE_AGREEMENT            [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_LICENSE_AGREEMENT] ]
   set HIT_RETURN_TO_CONTINUE       [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_HIT_RETURN_TO_CONTINUE] ]
   set ANSWER_YES                   [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ANSWER_YES] ]
   set ANSWER_NO                    [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ANSWER_NO] ]

   set INSTALL_AS_ADMIN_USER        [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_INSTALL_AS_ADMIN_USER] "$CHECK_USER" ]
   set UNIQUE_CLUSTER_NAME          [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_UNIQUE_CLUSTER_NAME] ]
   set CURRENT_GRID_ROOT_DIRECTORY  [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CURRENT_GRID_ROOT_DIRECTORY] "*" "*" ]
   set CELL_NAME_FOR_QMASTER        [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CELL_NAME_FOR_QMASTER] "*"]
   set ENTER_SCHEDULER_SETUP        [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_SCHEDLUER_SETUP] ]
   set ENTER_A_RANGE                [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_A_RANGE] ]
   set USING_GID_RANGE_HIT_RETURN   [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_USING_GID_RANGE_HIT_RETURN] "*"]
   set CHANGE_PORT_QUESTION         [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CHANGE_PORT_QUESTION] ]
   set COMMD_PORT                   [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_UNUSED_PORT] "sge_qmaster"]
   set EXECD_PORT                   [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_UNUSED_PORT] "sge_execd"]
   set ENTER_ADMIN_MAIL             [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_ADMIN_MAIL] "*"]
   set ENTER_ADMIN_MAIL_SINCE_U3    [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_ADMIN_MAIL_SINCE_U3] "*"]
   set SMF_IMPORT_SERVICE           [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_SMF_IMPORT_SERVICE] ]
   set DNS_DOMAIN_QUESTION          [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DNS_DOMAIN_QUESTION] ]
   set ACCEPT_CONFIGURATION         [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ACCEPT_CONFIGURATION] ]
   set ENTER_OVERRIDE_PROTECTION    [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_ENTER_OVERRIDE_PROTECTION] ]
   set INSTALL_SCRIPT               [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_INSTALL_SCRIPT] "*" ]

   # spooling
   set CHOOSE_SPOOLING_METHOD       [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CHOOSE_SPOOLING_METHOD] "*"]
   set OTHER_SPOOL_DIR              [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_OTHER_SPOOL_DIR] ]
   set ENTER_SPOOL_DIR              [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_SPOOL_DIR] "*"]
   set ENTER_QMASTER_SPOOL_DIR      [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_QMASTER_SPOOL_DIR] "*"]
   set DATABASE_LOCAL_SPOOLING      [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DATABASE_LOCAL_SPOOLING]]
   set DELETE_DB_SPOOL_DIR          [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DELETE_DB_SPOOL_DIR] ]
   set ENTER_DATABASE_SERVER        [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_DATABASE_SERVER] "*"]
   set ENTER_DATABASE_DIRECTORY_LOCAL_SPOOLING [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_DATABASE_DIRECTORY_LOCAL_SPOOLING] "*"]
   set ENTER_DATABASE_SERVER_DIRECTORY [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ENTER_SERVER_DATABASE_DIRECTORY] "*"]
   set DATABASE_DIR_NOT_ON_LOCAL_FS [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DATABASE_DIR_NOT_ON_LOCAL_FS] "*"]
   set STARTUP_RPC_SERVER           [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_STARTUP_RPC_SERVER]]
   set EXECD_SPOOLING_DIR_NOROOT_NOADMINUSER [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_EXECD_SPOOLING_DIR_NOROOT_NOADMINUSER]]
   set EXECD_SPOOLING_DIR_NOROOT    [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_EXECD_SPOOLING_DIR_NOROOT] "*"]
   set EXECD_SPOOLING_DIR_DEFAULT   [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_EXECD_SPOOLING_DIR_DEFAULT] "*"]

   set INSTALL_BDB_AND_CONTINUE     [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_INSTALL_BDB_AND_CONTINUE]]

   # verify permissions
   set VERIFY_FILE_PERMISSIONS1     [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_VERIFY_FILE_PERMISSIONS1] ]
   set VERIFY_FILE_PERMISSIONS2     [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_VERIFY_FILE_PERMISSIONS2] ]
   set WILL_NOT_VERIFY_FILE_PERMISSIONS [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_WILL_NOT_VERIFY_FILE_PERMISSIONS] ]
   set DO_NOT_VERIFY_FILE_PERMISSIONS [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DO_NOT_VERIFY_FILE_PERMISSIONS] ]
   set DONT_KNOW_HOW_TO_TEST_FOR_LOCAL_FS [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DONT_KNOW_HOW_TO_TEST_FOR_LOCAL_FS]]

   # Certificate Authority
   set ENTER_CA_COUNTRY_CODE        [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_ENTER_CA_COUNTRY_CODE]]
   set ENTER_CA_STATE               [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_ENTER_CA_STATE]]
   set ENTER_CA_LOCATION            [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_ENTER_CA_LOCATION]]
   set ENTER_CA_ORGANIZATION        [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_ENTER_CA_ORGANIZATION]]
   set ENTER_CA_ORGANIZATION_UNIT   [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_ENTER_CA_ORGANIZATION_UNIT]]
   set ENTER_CA_ADMIN_EMAIL         [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_ENTER_CA_ADMIN_EMAIL]]
   set CA_RECREATE                  [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_CA_RECREATE]]

   # csp
   set CSP_COPY_CERTS [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CSP_COPY_CERTS]]
   set CSP_COPY_CMD [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CSP_COPY_CMD]]
   set CSP_COPY_FAILED [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CSP_COPY_FAILED]]
   set CSP_COPY_RSH_FAILED [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CSP_COPY_RSH_FAILED]]

   # upgrade
   set BCKP_DIR                     [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_UPGRADE_BCKP_DIR] ]
   set USE_BCKP_DIR                 [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_UPGRADE_USE_BCKP_DIR] ]
   set NEW_BCKP_DIR                 [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_UPGRADE_NEW_BCKP_DIR] ]
   set COMMD_PORT_SETUP             [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_UPGRADE_COMMD_PORT_SETUP] ]
   set IJS_SELECTION                [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINT_UPGRADE_IJS_SELECTION]]
   set NEXT_RANK_NUMBER             [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINCT_UPGRADE_NEXT_RANK_NUMBER]]
   set USE_EXISTING_SPOOLING        [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINCT_UPGRADE_USE_EXISTING_SPOOLING] "*"]
   set PKGADD_QUESTION              [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_PKGADD_QUESTION] ]
   set PKGADD_QUESTION_SINCE_U3     [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_PKGADD_QUESTION_SINCE_U3] ]


   set id [open_remote_spawn_process "$ts_config(master_host)" $install_user "./inst_sge" "-upd" 0 "$ts_config(product_root)"]
   set sp_id [ lindex $id 1 ]
   set return_value 0
   set timeout 60
   set old_log_user [log_user]
   log_user 1
   set script_exit_0_found 0
   set install_output ""
   expect {
      -i $sp_id full_buffer {
         ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
         set return_value 1
      }

      -i $sp_id eof {
         ts_log_severe "unexpected eof"
         set return_value 1
      }

      -i $sp_id -- "coredump" {
         ts_log_severe "coredump"
         set return_value 1
      }

      -i $sp_id timeout {
         if {[info exists expect_out(buffer)]} {
            set buffer_output [format_array expect_out]
         } else {
            set buffer_output "n.a."
         }
         ts_log_severe "timeout while waiting for output\n$buffer_output"
         set return_value 1
      }

      -i $sp_id -- "orry" {
         ts_log_severe "wrong root password"
         set return_value 1
      }

      -i $sp_id -- "issing" {
         ts_log_severe "missing binary error"
         set return_value 1
      }
      -i $sp_id -- "CRITICAL*\n" {
         append install_output $expect_out(buffer)
         ts_log_severe "found critical error: \"$expect_out(buffer)\""
         log_user 1
         exp_continue
      }
      -i $sp_id -- "xit." {
         ts_log_severe "installation failed"
         set return_value 1
      }

      -i $sp_id -- "More" {
         ts_log_fine "\n -->testsuite: sending >space<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            gets stdin anykey
         }

         ts_send $sp_id " "
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      #  This is for More license output on darwin
      -i $sp_id -- "LICENSE ??%" {
         set found_darwin_more 1
         ts_log_fine "\n -->testsuite: sending >space< (darwin)"
         if {$do_log_output == 1} {
            puts "press RETURN"
            gets stdin anykey
         }

         ts_send $sp_id " "
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $LICENSE_AGREEMENT {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_YES\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $PKGADD_QUESTION {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_NO\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $PKGADD_QUESTION_SINCE_U3 {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_NO\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $HIT_RETURN_TO_CONTINUE {
         ts_log_fine "\n -->testsuite: sending >RETURN<"
         if {$do_log_output == 1} {
            puts "-->testsuite: press RETURN (HIT_RETURN_TO_CONTINUE)"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $BCKP_DIR {
         ts_log_fine "\n -->testsuite: sending >${bckp_dir}<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "${bckp_dir}\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $USE_BCKP_DIR {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_YES\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $NEW_BCKP_DIR {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_NO\n"
         ts_log_severe "Not a valid backup directory!"
         set return_value 1
      }

      -i $sp_id -- $CURRENT_GRID_ROOT_DIRECTORY {
         ts_log_fine "\n -->testsuite: sending >RETURN<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $CELL_NAME_FOR_QMASTER {
         ts_log_fine "\n -->testsuite: sending  $ts_config(cell)"
         if {$do_log_output == 1} {
              puts "-->testsuite: press RETURN (CELL_NAME_FOR_QMASTER)"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ts_config(cell)\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $COMMD_PORT_SETUP {
         ts_log_fine "\n -->testsuite: sending >RETURN<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $CHANGE_PORT_QUESTION {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_YES\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $COMMD_PORT {
         ts_log_fine "\n -->testsuite: sending  $ts_config(commd_port)"
         if {$do_log_output == 1} {
              puts "-->testsuite: press RETURN (QMASTER_PORT)"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ts_config(commd_port)\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $EXECD_PORT {
         set execd_port [expr $ts_config(commd_port) + 1]
         ts_log_fine "\n -->testsuite: sending  $execd_port"
         if {$do_log_output == 1} {
              puts "-->testsuite: press RETURN (EXECD_PORT)"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$execd_port\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $INSTALL_AS_ADMIN_USER {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_YES\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $OTHER_SPOOL_DIR {
         # TODO: Calling gobal functions are dangerous here: The cloned cluster might have different startup parameters!
         set spooldir [get_local_spool_dir $ts_config(master_host) qmaster]
         if { $spooldir != "" } {
           set answer $ANSWER_YES
         } else {
           set answer $ANSWER_NO
         }
         ts_log_fine "\n -->testsuite: sending >$answer<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$answer\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $DELETE_DB_SPOOL_DIR {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_YES\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_OVERRIDE_PROTECTION {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_YES\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $UNIQUE_CLUSTER_NAME {

         # INFO cluster name has to be transfered
         ts_log_fine "\n -->testsuite: sending cluster_name >$ts_config(cluster_name)<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ts_config(cluster_name)\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $VERIFY_FILE_PERMISSIONS1 {
        if { $ts_config(package_type) == "tar" || $ts_config(package_type) == "create_tar" } {
         set input "$ANSWER_YES"
        } else {
           set input "$ANSWER_NO"
        }
         ts_log_fine "\n -->testsuite: sending >$input<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$input\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $VERIFY_FILE_PERMISSIONS2 {
         set input "$ANSWER_YES"
         ts_log_fine "\n -->testsuite: sending >$input<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$input\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $WILL_NOT_VERIFY_FILE_PERMISSIONS {
          ts_log_fine "\n -->testsuite: sending >RETURN<"
          if {$do_log_output == 1} {
               puts "press RETURN"
               set anykey [wait_for_enter 1]
          }
          ts_send $sp_id "\n"
          append install_output $expect_out(buffer)
          log_user 1
          exp_continue
      }

      -i $sp_id -- $DO_NOT_VERIFY_FILE_PERMISSIONS {
          ts_log_fine "\n -->testsuite: sending >RETURN<"
          if {$do_log_output == 1} {
               puts "press RETURN"
               set anykey [wait_for_enter 1]
          }
          ts_send $sp_id "\n"
          append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $CHOOSE_SPOOLING_METHOD {
         set spooling_method $ts_config(spooling_method)
         ts_log_fine "\n -->testsuite: sending $spooling_method (choose spooling method)"

         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$spooling_method\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $DATABASE_LOCAL_SPOOLING {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
         set input "$ANSWER_NO\n"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id $input
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $DELETE_DB_SPOOL_DIR {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_YES\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_SCHEDULER_SETUP {
         ts_log_fine "\n -->testsuite: sending >RETURN<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }

         ts_send $sp_id "\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_DATABASE_DIRECTORY_LOCAL_SPOOLING {
         set spooldir $ts_config(bdb_dir)
         if { $spooldir == "" } {
            ts_log_fine "\n -->testsuite: sending >RETURN<"
            if {$do_log_output == 1} {
               puts "press RETURN"
               set anykey [wait_for_enter 1]
            }
            ts_send $sp_id "\n"
         } else {
            ts_log_fine "\n -->testsuite: sending >$spooldir<"
            if {$do_log_output == 1} {
               puts "press RETURN"
               set anykey [wait_for_enter 1]
            }
            ts_send $sp_id "$spooldir\n"
         }
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $DATABASE_DIR_NOT_ON_LOCAL_FS {
          ts_log_config "configured database directory not on local disk\nPlease run testsuite setup and configure Berkeley DB server and/or directory"
          set return_value 1
      }

      -i $sp_id -- $IJS_SELECTION {
         if {$new_ijs == 1} {
            set my_answer $ANSWER_NO
         } else {
            set my_answer $ANSWER_YES
         }
         ts_log_fine "\n -->testsuite: sending >$my_answer< (use existing IJS)"

         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$my_answer\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_A_RANGE {
         set myrange [ get_gid_range $CHECK_USER $ts_config(commd_port)]
         ts_log_fine "\n -->testsuite: sending >${myrange}<"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }

         ts_send $sp_id "${myrange}\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $USING_GID_RANGE_HIT_RETURN {
         ts_log_fine "\n -->testsuite: sending >RETURN<(17)"
         if {$do_log_output == 1} {
              puts "-->testsuite: press RETURN (USING_GID_RANGE_HIT_RETURN)"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_QMASTER_SPOOL_DIR {
         ts_log_fine "\n"
         # TODO: Calling gobal functions are dangerous here: The cloned cluster might have different startup parameters!
         set spooldir [get_local_spool_dir $ts_config(master_host) qmaster]
         if { $spooldir != "" } {
           # use local spool dir
           ts_log_fine "\n -->testsuite: sending >$spooldir<"
           if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
           }
           ts_send $sp_id "$spooldir\n"
         } else {
           # use default spool dir
           ts_log_fine "\n -->testsuite: sending >RETURN<"
           if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
           }
           ts_send $sp_id "\n"
         }
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_SPOOL_DIR {
         ts_log_fine "\n"
         # TODO: Calling gobal functions are dangerous here: The cloned cluster might have different startup parameters!
         set spooldir [get_local_spool_dir $ts_config(master_host) qmaster]
         if { $spooldir != "" } {
           # use local spool dir
           ts_log_fine "\n -->testsuite: sending >$spooldir<"
           if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
           }
           ts_send $sp_id "$spooldir\n"
         } else {
           # use default spool dir
           ts_log_fine "\n -->testsuite: sending >RETURN<"
           if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
           }
           ts_send $sp_id "\n"
         }
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $EXECD_SPOOLING_DIR_NOROOT_NOADMINUSER {
         ts_log_fine "\n"
         # TODO: Calling gobal functions are dangerous here: The cloned cluster might have different startup parameters!
         set spooldir [get_local_spool_dir $ts_config(master_host) execd 0]
         if { $spooldir != "" } {
           # use local spool dir
           ts_log_fine "\n -->testsuite: sending >$spooldir<"
           if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
           }
           ts_send $sp_id "$spooldir\n"
           set local_execd_spool_set 1
         } else {
           # use default spool dir
           ts_log_fine "\n -->testsuite: sending >RETURN<"
           if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
           }
           ts_send $sp_id "\n"
         }
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
       }

      -i $sp_id -- $EXECD_SPOOLING_DIR_NOROOT {
         ts_log_fine "\n"
         # TODO: Calling gobal functions are dangerous here: The cloned cluster might have different startup parameters!
         set spooldir [get_local_spool_dir $ts_config(master_host) execd 0]
         if { $spooldir != "" } {
           # use local spool dir
           ts_log_fine "\n -->testsuite: sending >$spooldir<"
           if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
           }
           ts_send $sp_id "$spooldir\n"
           set local_execd_spool_set 1
         } else {
           # use default spool dir
           ts_log_fine "\n -->testsuite: sending >RETURN<"
           if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
           }
           ts_send $sp_id "\n"
         }
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_ADMIN_MAIL {
         if { $ts_config(report_mail_to) == "none" } {
            set admin_mail "${CHECK_USER}@${CHECK_DNS_DOMAINNAME}"
         } else {
            set admin_mail $ts_config(report_mail_to)
         }
         ts_log_fine "\n -->testsuite: sending >$admin_mail<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$admin_mail\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_ADMIN_MAIL_SINCE_U3 {
         if { $ts_config(report_mail_to) == "none" } {
            set admin_mail "${CHECK_USER}@${CHECK_DNS_DOMAINNAME}"
         } else {
            set admin_mail $ts_config(report_mail_to)
         }
         ts_log_fine "\n -->testsuite: sending >$admin_mail<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$admin_mail\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ACCEPT_CONFIGURATION {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }

         ts_send $sp_id "$ANSWER_NO\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $NEXT_RANK_NUMBER {
         ts_log_fine "\n -->testsuite: sending >RETURN<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $SMF_IMPORT_SERVICE  {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }

         ts_send $sp_id "$ANSWER_NO\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $INSTALL_SCRIPT  {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }

         ts_send $sp_id "$ANSWER_NO\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $DNS_DOMAIN_QUESTION {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_YES\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $CSP_COPY_CERTS {
         set answer $ANSWER_YES
         ts_log_fine "\n -->testsuite: sending >$answer<"
         if {$do_log_output == 1} {
           puts "press RETURN"
           set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$answer\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $CSP_COPY_CMD {
         if {$ts_config(connection_type) == ssh} {
            ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
            if {$do_log_output == 1} {
                 puts "press RETURN"
                 set anykey [wait_for_enter 1]
            }
            ts_send $sp_id "$ANSWER_NO\n"
         } else {
            ts_log_fine "\n -->testsuite: sending >$ANSWER_YES<"
            if {$do_log_output == 1} {
                 puts "press RETURN"
                 set anykey [wait_for_enter 1]
            }
            ts_send $sp_id "$ANSWER_YES\n"
         }
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $CSP_COPY_FAILED {
         ts_log_fine "\n -->testsuite: received copy failure"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }
         ts_log_config "We received a failure during copy of certificates. This appears, when the\nrcp/scp command fails!"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $CSP_COPY_RSH_FAILED {
         ts_log_fine "\n -->testsuite: received rsh/ssh failure"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }
         ts_log_config "We received a rsh/ssh failure. This error happends, if the rsh/ssh connection\nto any execution host was not possible, due to the missing permissions for user\nroot to connect via rsh/ssh without entering a password. This warning shows,\nthat the tested error handling code is working. To prevent this warning make\nsure the you qmaster host allows rsh/ssh connction for root without asking for\na password."
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $USE_EXISTING_SPOOLING {
         ts_log_fine "matched correct spooling question!"
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO< (use spooling method - OK)"
         if {$do_log_output == 1} {
              puts "press RETURN"
              set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_NO\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $CA_RECREATE {
         ts_log_fine "\n -->testsuite: sending >$ANSWER_NO<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$ANSWER_NO\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_CA_COUNTRY_CODE {
         ts_log_fine "\n -->testsuite: sending >DE<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "DE\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_CA_STATE {
         ts_log_fine "\n -->testsuite: sending >Bavaria<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "Bavaria\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_CA_LOCATION {
         ts_log_fine "\n -->testsuite: sending >Regensburg<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "Regensburg\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_CA_ORGANIZATION {
         ts_log_fine "\n -->testsuite: sending >Sun Microsystems<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "Sun Microsystems\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_CA_ORGANIZATION_UNIT {
         ts_log_fine "\n -->testsuite: sending >Testsystem at qmaster port $ts_config(commd_port)<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "Testsystem at qmaster port $ts_config(commd_port)\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- $ENTER_CA_ADMIN_EMAIL {
         if { $ts_config(report_mail_to) == "none" } {
            set CA_admin_mail "${CHECK_USER}@${CHECK_DNS_DOMAINNAME}"
         } else {
            set CA_admin_mail $ts_config(report_mail_to)
         }
         ts_log_fine "\n -->testsuite: sending >$CA_admin_mail<"
         if {$do_log_output == 1} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }
         ts_send $sp_id "$CA_admin_mail\n"
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- "_exit_status_:(0)" {
         set script_exit_0_found 1
         append install_output $expect_out(buffer)
         log_user 1
         exp_continue
      }

      -i $sp_id -- "*(_END_OF_FILE_)" {
         append install_output $expect_out(buffer)
         ts_log_fine "upgrade done"
      }
      -i $sp_id default {
         ts_log_severe "undefined behaviour: $expect_out(buffer)"
         set return_value 1
      }
   }


   if {$script_exit_0_found != 1} {
      ts_log_severe "script exit status is not 0:\noutput:\n$install_output\n"
      set return_value 1
   }
   log_user $old_log_user
   ts_log_fine "return value of upgrade: $return_value"
   close_spawn_process $id
   return $return_value
}

## @brief  do 'inst_sge -upd-execd -noremote' on one execd host
#
#  @param host execd host where to do the upgrade
#  @return     0 on success, 1 on failure
#
proc installer_do_upgrade_execd_for_host {host} {
   get_current_cluster_config_array ts_config
   global CHECK_DEBUG_LEVEL CHECK_ADMIN_USER_SYSTEM CHECK_USER

   ts_log_fine "performing execd upgrade ..."

   set do_log_output 0 ;# _LOG
   if { $CHECK_DEBUG_LEVEL == 2 } {
     set do_log_output  1 ;# 1
   }

   if {$CHECK_ADMIN_USER_SYSTEM == 0} {
      set install_user "root"
   } else {
      set install_user $CHECK_USER
      ts_log_fine "--> install as user $CHECK_USER <--"
   }

   set id [open_remote_spawn_process $host $install_user "./inst_sge" "-upd-execd -noremote" 0 "$ts_config(product_root)"]
   set sp_id [ lindex $id 1 ]
   set return_value 0
   set timeout 60
   set old_log_user [log_user]
   if {$do_log_output} {
      log_user 1
   }
   set script_exit_0_found 0
   set install_output ""
   expect {
      -i $sp_id full_buffer {
         ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
         set return_value 1
      }

      -i $sp_id eof {
         ts_log_severe "unexpected eof"
         set return_value 1
      }

      -i $sp_id timeout {
         if {[info exists expect_out(buffer)]} {
            set buffer_output [format_array expect_out]
         } else {
            set buffer_output "n.a."
         }
         ts_log_severe "timeout while waiting for output\n$buffer_output"
         set return_value 1
      }

      -i $sp_id -- "_exit_status_:(0)" {
         set script_exit_0_found 1
         append install_output $expect_out(buffer)
         exp_continue
      }

      -i $sp_id -- "*(_END_OF_FILE_)" {
         append install_output $expect_out(buffer)
         ts_log_fine "upgrade done"
      }
      -i $sp_id default {
         ts_log_severe "undefined behaviour: $expect_out(buffer)"
         set return_value 1
      }
   }
   if {$script_exit_0_found != 1} {
      ts_log_severe "The script exit status is not 0!\noutput:\n$install_output"
      set return_value 1
   }
   log_user $old_log_user
   close_spawn_process $id

   # restart execd on host
   if {$return_value == 0} {
      startup_execd $host
   }

   return $return_value
}

## @brief  do 'inst_sge -upd-execd -noremote' on all execd hosts
#
# @return     0 on success, 1 on failure
#
proc installer_do_upgrade_execd {} {
   get_current_cluster_config_array ts_config

   # do '$SGE_ROOT/inst_sge -upd-execd -noremote' on all execds
   set ret 0
   foreach host $ts_config(execd_nodes) {
      set ret [installer_do_upgrade_execd_for_host $host]
      if {$ret != 0} {
         ts_log_severe "upgrade seems not to work correct for execd host $host"
         return $ret
      }
   }

   return 0
}

## @brief  test cluster after upgrade
#
# @return     0 on success, 1 on failure
#
proc installer_test_cluster_after_upgrade {} {
   get_current_cluster_config_array ts_config

   ts_log_fine "testing cluster after upgrade ..."

   # submit a job and check if jobid is divisible by 2000 for the first job after upgrade
   set job_args "-b y sleep 120"
   set jid [submit_job $job_args]
   delete_all_jobs
   wait_for_end_of_all_jobs

   if {$jid == 1 || ($jid % 2000) != 0} {
      ts_log_severe "Job submission after upgrade failed, expected jid that is divisible by 2000, got $jid"
      return 1
   }

   # @todo: here version specific tests could be added

   return 0
}
