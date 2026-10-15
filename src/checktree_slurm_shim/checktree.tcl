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


global ts_checktree
global CHECK_DEFAULTS_FILE
global slurm_shim_checktree_nr
global ACT_CHECKTREE

# we have no config yet
ts_source $ACT_CHECKTREE/config

set slurm_shim_checktree_nr $ts_checktree($ACT_CHECKTREE)

# slurm-shim is built and released in its own repository, we only install the
# release files and make them part of the product packages
set ts_checktree($slurm_shim_checktree_nr,install_binary_hooks_0) "slurm_shim_install_binaries"

set ts_checktree($slurm_shim_checktree_nr,get_dist_files_hook) "slurm_shim_get_distribution_files"
set ts_checktree($slurm_shim_checktree_nr,get_package_files_hook) "slurm_shim_get_package_files"
set ts_checktree($slurm_shim_checktree_nr,mk_dist_options) "-slurm-shim"

###
# @brief install the slurm-shim release files
#
# Copies the contents of the slurm-shim repository's releases directory to
# $SGE_ROOT/slurm-shim. That is the architecture dependent tar.gz files, their
# checksums, the README with the installation instructions and the 3rdparty
# license information.
#
# @param[in] arch_list list of architectures; not used, the release files of all
#            architectures are installed
# @param[in] a_report report object, call by reference
# @return 0 on success, -1 on error
##
proc slurm_shim_install_binaries {arch_list a_report} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   upvar $a_report report

   set ret 0
   set errors {}

   set task_nr [report_create_task report "slurm_shim_install_binaries" $ts_config(master_host)]

   set source_dir [slurm_shim_get_source_dir]
   if {$source_dir == ""} {
      report_task_add_message report $task_nr "slurm-shim code is not available"
      set ret -1
   } else {
      set release_src "$source_dir/releases"
      set release_dst "$ts_config(product_root)/slurm-shim"

      report_task_add_message report $task_nr "creating slurm-shim directory $release_dst"
      set output [remote_file_mkdir $ts_config(master_host) $release_dst "" "" prg_exit_state]
      report_task_add_message report $task_nr $output
      if {$prg_exit_state != 0} {
         report_task_add_message report $task_nr "FAILED"
         lappend errors "creating directory $release_dst failed:\n$output"
         set ret -1
      } else {
         # into the directory, not next to it - a second run would otherwise put a
         # releases directory inside the one from the first
         report_task_add_message report $task_nr "copying release files from\
                                                  $release_src to $release_dst"
         set output [start_remote_prog $ts_config(master_host) $CHECK_USER "cp" \
                                       "-r $release_src/* $release_dst"]
         report_task_add_message report $task_nr $output
         if {$prg_exit_state != 0} {
            report_task_add_message report $task_nr "FAILED"
            lappend errors "copying release files from $release_src to $release_dst\
                            failed:\n$output"
            set ret -1
         }
      }
   }

   report_finish_task report $task_nr $ret

   if {[llength $errors] > 0} {
      ts_log_severe "installing slurm-shim failed\n[join $errors "\n"]"
      set ret -1
   }

   return $ret
}

###
# @brief get the slurm-shim files installed into $SGE_ROOT
#
# mk_dist packs the files from $SGE_ROOT, so they have to be visible on the host
# the packages are created on before mk_dist is called.
#
# @return list of file names relative to $SGE_ROOT
##
proc slurm_shim_get_distribution_files {} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set dist_files {}
   analyze_directory_structure $ts_config(master_host) $CHECK_USER \
                               "$ts_config(product_root)/slurm-shim" "" files ""
   foreach f $files {
      lappend dist_files "slurm-shim/$f"
   }

   return $dist_files
}

###
# @brief get the slurm-shim product packages
#
# @param[in] path directory containing the product packages
# @param[in] type package type, either "tar" or "zip"
# @return list of package file names
##
proc slurm_shim_get_package_files {path type} {
   return [checktree_find_package_files $path $type "slurm-shim"]
}
