#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2024 HPC-Gridware GmbH
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

proc valgrind_check_settings {} {
   get_current_cluster_config_array ts_config
   global CHECK_VALGRIND CHECK_VALGRIND_HOST

   set ret 1

   if {$CHECK_VALGRIND == "master" && $CHECK_VALGRIND_HOST != $ts_config(master_host)} {
      puts "valgrind master is only supported on master host"
      set ret 0
   }
   if {$ret && $CHECK_VALGRIND == "execution" && [lsearch -exact $ts_config(execd_nodes) $CHECK_VALGRIND_HOST] < 0} {
      puts "valgrind execution is only supported on execution host"
      set ret 0
   }
   if {$ret && [lsearch -exact $ts_config(all_nodes) $CHECK_VALGRIND_HOST] < 0} {
      puts "valgrind host $CHECK_VALGRIND_HOST is not a known cluster host"
      set ret 0
   }
   if {$ret && [get_binary_path $CHECK_VALGRIND_HOST "valgrind" 0] == "valgrind"} {
      puts "valgrind is not installed on host $CHECK_VALGRIND_HOST"
      set ret 0
   }

   return $ret
}

proc valgrind_get_tmp_path {} {
   get_current_cluster_config_array ts_config

   set tmp_path "/tmp/testsuite_valgrind/$ts_config(commd_port)"
   return $tmp_path
}

proc valgrind_get_protocol_path {} {
   get_current_cluster_config_array ts_config
   global CHECK_PROTOCOL_DIR

   set protocol_path "$CHECK_PROTOCOL_DIR/valgrind"
   return $protocol_path
}

proc valgrind_init {} {
   global CHECK_VALGRIND CHECK_VALGRIND_HOST
   global CHECK_USER

   if {$CHECK_VALGRIND != ""} {
      # we make valgrind write its output files to a local directory first
      # and later on copy the ones with errors to the shared protocol directory
      set valgrind_output_dir [valgrind_get_tmp_path]
      # delete the directory if it exists
      delete_remote_file $CHECK_VALGRIND_HOST "root" $valgrind_output_dir
      # re-create it
      remote_file_mkdir $CHECK_VALGRIND_HOST $valgrind_output_dir 0 $CHECK_USER "777"
   }
}

proc valgrind_analyse_copy_files {} {
   global CHECK_VALGRIND
   if {$CHECK_VALGRIND == ""} {
      # allows us to call the function e.g. from testsuite menu without having to check for valgrind mode
      return 1
   }

   global CHECK_VALGRIND_HOST
   global CHECK_USER

   set tmp_dir [valgrind_get_tmp_path]
   set prot_dir [valgrind_get_protocol_path]

   # loop over the list of files in the tmp directory
   set error_files {}
   set output [start_remote_prog $CHECK_VALGRIND_HOST $CHECK_USER "ls" "-1 $tmp_dir"]
   foreach filename [split [string trim $output] "\n"] {
      set filename [string trim $filename]
      ts_log_fine "analysing valgrind output file: $filename"

      # if the file contains errors then copy it to the protocol directory
      set output [start_remote_prog $CHECK_VALGRIND_HOST $CHECK_USER "cat" "$tmp_dir/$filename"]
      if {[string first "<error>" $output] >= 0} {
         ts_log_fine "valgrind reported errors in file: $filename"
         start_remote_prog $CHECK_VALGRIND_HOST $CHECK_USER "cp" "$tmp_dir/$filename $prot_dir/$filename"
         lappend error_files $filename
      }

      # delete the tmp file
      ts_log_fine "deleting valgrind output file: $tmp_dir/$filename"
      delete_remote_file $CHECK_VALGRIND_HOST "root" "$tmp_dir/$filename"
   }

   set num_error_files [llength $error_files]
   if {$num_error_files > 0} {
      set msg "valgrind reported $num_error_files report(s) with errors for $CHECK_VALGRIND\n"
      append msg "see protocol directory $prot_dir:\n"
      append msg [join $error_files "\n"]
      ts_log_severe $msg
      set ret 0
   } else {
      ts_log_fine "valgrind did not report any errors for $CHECK_VALGRIND"
      set ret 1
   }

   return $ret
}

proc valgrind_sort_hosts {hosts} {
   global CHECK_VALGRIND CHECK_VALGRIND_HOST

   switch $CHECK_VALGRIND {
      "master" {
         # when we are running the master in valgrind then avoid putting additional load on the master
         set pos [lsearch -exact $hosts $CHECK_VALGRIND_HOST]
         if {$pos >= 0} {
            set hosts [lreplace $hosts $pos $pos]
            lappend hosts $CHECK_VALGRIND_HOST
         }
      }
      default {
         # when we are running the execution side in valgrind then we want to make most use of this exec host,
         # e.g. add it to test queues, run test jobs on it, etc.
         # when running clients/tests in valgrind then we want to run as many as possible on the test host
         if {$CHECK_VALGRIND_HOST != ""} {
            set pos [lsearch -exact $hosts $CHECK_VALGRIND_HOST]
            if {$pos >= 1} {
               set hosts [lreplace $hosts $pos $pos]
               set hosts [linsert $hosts 0 $CHECK_VALGRIND_HOST]
            }
         }
      }
   }

   return $hosts
}

global valgrind_binary_cache
unset -nocomplain valgrind_binary_cache

proc valgrind_init_binary_cache {} {
   get_current_cluster_config_array ts_config
   global valgrind_binary_cache
   global CHECK_VALGRIND CHECK_VALGRIND_HOST

   set arch [resolve_arch $CHECK_VALGRIND_HOST]

   switch $CHECK_VALGRIND {
      "master" {
         set valgrind_binary_cache($CHECK_VALGRIND) "sge_qmaster"
         # @todo what abut sge_shadowd?
      }
      "execution" {
         set valgrind_binary_cache($CHECK_VALGRIND) "sge_execd"
         # @todo what about sge_shepherd?
      }
      "clients" {
         # we want to run all binaries from bin except the sge_* binaries (daemons)
         set all_bin_list [glob -tails -type {f l x} -directory "$ts_config(product_root)/bin/$arch" *]
         set bin_list [lsearch -not -all -inline -glob $all_bin_list "sge_*"]
         # and all uilbin binaries except the db_* binaries (Berkeley DB)
         set all_utilbin_list [glob -tails -type {f l x} -directory "$ts_config(product_root)/utilbin/$arch" *]
         set utilbin_list [lsearch -not -all -inline -glob $all_utilbin_list "db_*"]
         set utilbin_list [lsearch -not -all -inline -glob $utilbin_list "infotext"]

         set valgrind_binary_cache($CHECK_VALGRIND) [concat $bin_list $utilbin_list]
      }
      "tests" {
         set test_list [glob -tails -type {f l x} -directory "$ts_config(product_root)/testbin/$arch" *]
         set valgrind_binary_cache($CHECK_VALGRIND) $test_list
      }
      default {
         ts_log_severe "unknown valgrind mode: $CHECK_VALGRIND"
         set valgrind_binary_cache($CHECK_VALGRIND) ""
      }
   }

   ts_log_frame
   ts_log_fine "valgrind binary cache for $CHECK_VALGRIND: $valgrind_binary_cache($CHECK_VALGRIND)"
   ts_log_frame
}

proc valgrind_run_this_binary_in_valgrind {exec_command} {
   global CHECK_VALGRIND
   global valgrind_binary_cache

   if {![info exists valgrind_binary_cache($CHECK_VALGRIND)]} {
      valgrind_init_binary_cache
   }
   set command [file tail $exec_command]
   if {[lsearch -exact $valgrind_binary_cache($CHECK_VALGRIND) $command] >= 0} {
      return 1
   }

   return 0
}

global CHECK_VALGRIND_RECURSIVE
set CHECK_VALGRIND_RECURSIVE 0
proc valgrind_set_command_and_arguments {hostname exec_command_var exec_arguments_var} {
   get_current_cluster_config_array ts_config
   global CHECK_VALGRIND CHECK_VALGRIND_HOST

   # nothing to be done if we are not valgrind testing or if this is not the valgrind host
   if {$CHECK_VALGRIND == "" || $CHECK_VALGRIND_HOST != $hostname} {
      return
   }

   # we don't do valgrind testing during testsuite startup
   global CHECK_CUR_PROC_NAME
   if {$CHECK_CUR_PROC_NAME == "initializing" || $CHECK_CUR_PROC_NAME == "main"} {
      return
   }

   global CHECK_VALGRIND_RECURSIVE
   if {$CHECK_VALGRIND_RECURSIVE} {
      return
   }
   set CHECK_VALGRIND_RECURSIVE 1

   # check if this binary shall be run in valgrind
   upvar $exec_command_var exec_command
   if {![valgrind_run_this_binary_in_valgrind $exec_command]} {
      set CHECK_VALGRIND_RECURSIVE 0
      return
   }

   # ok, we are running this binary in valgrind
   upvar $exec_arguments_var exec_arguments
   set valgrind_script "$ts_config(testsuite_root_dir)/scripts/valgrind.sh"
   set tmp_dir [valgrind_get_tmp_path]
   set valgrind_options "[file dirname $ts_config(source_dir)] $tmp_dir $exec_command "
   append valgrind_options $exec_arguments

   set exec_command $valgrind_script
   set exec_arguments $valgrind_options
   ts_log_frame
   ts_log_fine "running binary in valgrind: $exec_command $exec_arguments"
   ts_log_frame

   set CHECK_VALGRIND_RECURSIVE 0
}

proc valgrind_shutdown_daemon {} {
   get_current_cluster_config_array ts_config
   global CHECK_VALGRIND CHECK_VALGRIND_HOST
   switch $CHECK_VALGRIND {
      "master" {
         # shutdown the shadowds first - qmaster shutdown can take some time and we don't want a shadowd to take over
         foreach host $ts_config(shadowd_hosts) {
            shutdown_system_daemon $host "shadowd"
         }
         # shutdown qmaster, allow 10 minutes for the shutdown, dumping valgrind data can take some time
         shutdown_qmaster $ts_config(master_host) [get_qmaster_spool_dir] 900
      }
      "execution" {
         shutdown_system_daemon $CHECK_VALGRIND_HOST "execd"
      }
   }
}

proc valgrind_startup_daemon {} {
   get_current_cluster_config_array ts_config
   global CHECK_VALGRIND CHECK_VALGRIND_HOST
   switch $CHECK_VALGRIND {
      "master" {
         startup_qmaster
         # re-start the shadowds
         foreach host $ts_config(shadowd_hosts) {
            startup_shadowd $host
         }
         wait_for_load_from_all_queues 60
      }
      "execution" {
         # @todo startup_execd uses the rc-script, in case of valgrind we should use the binary directly
         startup_execd $CHECK_VALGRIND_HOST
      }
   }
}

global CHECK_VALGRIND_LAST_DAEMON_RESTART
set CHECK_VALGRIND_LAST_DAEMON_RESTART 0

proc valgrind_restart_daemon_after_idle {} {
   global CHECK_VALGRIND CHECK_VALGRIND_HOST
   global CHECK_VALGRIND_LAST_DAEMON_RESTART
   global check_name

   # restart the daemon if no tests have been run for more than 15 minutes
   # unless we are starting a cluster installation which will restart the daemon anyway
   if {($CHECK_VALGRIND == "master" || $CHECK_VALGRIND == "execution") && $check_name != "init_core_system"} {
      set now [clock seconds]
      set idle_time [expr $now - $CHECK_VALGRIND_LAST_DAEMON_RESTART]
      if {$idle_time > 900} {
         ts_log_fine "no tests have been run for more than 15 minutes, restarting $CHECK_VALGRIND daemon"
         valgrind_shutdown_daemon
         valgrind_analyse_copy_files
         valgrind_startup_daemon
         set CHECK_VALGRIND_LAST_DAEMON_RESTART $now
      }
   }
}

proc valgrind_check_after_runlevel {} {
   global CHECK_VALGRIND CHECK_VALGRIND_HOST

   set ret 1

   if {$CHECK_VALGRIND != ""} {
      if {$CHECK_VALGRIND == "master" || $CHECK_VALGRIND == "execution"} {
         valgrind_shutdown_daemon
      }
      set ret [valgrind_analyse_copy_files]
      if {$CHECK_VALGRIND == "master" || $CHECK_VALGRIND == "execution"} {
         valgrind_startup_daemon
      }
   }

   return $ret;
}

proc valgrind_setup_execd_conf {conf_name host} {
   get_current_cluster_config_array ts_config
   global CHECK_VALGRIND CHECK_VALGRIND_HOST

   # currently disabled due to CS-xxx
   if {0 && $CHECK_VALGRIND == "execution" && $CHECK_VALGRIND_HOST == $host} {
      upvar $conf_name conf
      set conf(shepherd_cmd) "$ts_config(testsuite_root_dir)/scripts/valgrind_shepherd.sh"
   }
}
