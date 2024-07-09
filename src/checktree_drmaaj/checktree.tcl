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


global ts_checktree drmaaj_config
global CHECK_DEFAULTS_FILE
global drmaaj_checktree_nr
global ACT_CHECKTREE

ts_source $ACT_CHECKTREE/config

set drmaaj_config(initialized) 0
set drmaaj_checktree_nr $ts_checktree($ACT_CHECKTREE)

set ts_checktree($drmaaj_checktree_nr,setup_hooks_0_name)         "DRMAA-Java configuration"
set ts_checktree($drmaaj_checktree_nr,setup_hooks_0_config_array) drmaaj_config
set ts_checktree($drmaaj_checktree_nr,setup_hooks_0_init_func)    drmaaj_init_config
set ts_checktree($drmaaj_checktree_nr,setup_hooks_0_verify_func)  drmaaj_verify_config
set ts_checktree($drmaaj_checktree_nr,setup_hooks_0_save_func)    drmaaj_save_configuration
set ts_checktree($drmaaj_checktree_nr,setup_hooks_0_filename)     [get_additional_config_file_path "drmaaj"]
set ts_checktree($drmaaj_checktree_nr,setup_hooks_0_version)      "1.0"

#set ts_checktree($drmaaj_checktree_nr,checktree_clean_hooks_0)  ""

set ts_checktree($drmaaj_checktree_nr,compile_hooks_0)        "drmaaj_compile"
set ts_checktree($drmaaj_checktree_nr,compile_clean_hooks_0)  "drmaaj_compile_clean"
set ts_checktree($drmaaj_checktree_nr,install_binary_hooks_0) "drmaaj_install_binaries"
set ts_checktree($drmaaj_checktree_nr,mk_dist_options)        "-drmaaj"

#set ts_checktree($drmaaj_checktree_nr,shutdown_hooks_0)       ""
#set ts_checktree($drmaaj_checktree_nr,startup_hooks_0)       ""

set ts_checktree($drmaaj_checktree_nr,start_runlevel_hooks_0)   "drmaaj_test_run_level_check"

#set ts_checktree($drmaaj_checktree_nr,required_hosts_hook)    ""

###
# @brief 
##
proc drmaaj_compile {compile_hosts a_report} {
   upvar $a_report report
   return [drmaaj_build [host_conf_get_java_compile_host] "package" report "-Dmaven.test.skip"]
}

proc drmaaj_compile_clean { compile_hosts a_report } {
   upvar $a_report report
   return [drmaaj_build [host_conf_get_java_compile_host] "clean" report]
}

proc drmaaj_build {build_host target a_report {options ""} {drmaaj_build_timeout 120} } {
   global CHECK_USER
   
   upvar $a_report report
 
   set task_nr [report_create_task report "drmaaj_build_$target" $build_host]
   ts_log_fine "creating target \"$target\" on compile host \"$build_host\""
   
   report_task_add_message report $task_nr "------------------------------------------"
   report_task_add_message report $task_nr "-> starting mvn $options $target on host $build_host ..."
  
   # setup environment
   set myenv(JAVA_HOME) [host_conf_get_java $build_host 8 0 1]
   if {$myenv(JAVA_HOME) == ""} {
      ts_log_config "Java  not found on $build_host!"
      return -1
   }

   set source_dir [config_get_drmaaj_source_dir]
   
   set open_spawn [open_remote_spawn_process $build_host $CHECK_USER "mvn" "$options $target" 0 $source_dir env]

   set spawn_list [lindex $open_spawn 1]
   set timeout $drmaaj_build_timeout
   set error -1
   set use_output 0
   expect {
      -i $spawn_list full_buffer {
         report_task_add_message report $task_nr "full_buffer error \"$build_host\""
      }
      -i $spawn_list timeout {
         report_task_add_message report $task_nr "got timeout for host \"$build_host\""
      }
      -i $spawn_list eof {
         report_task_add_message report $task_nr "got eof \"$build_host\""
      }
      -i $spawn_list "_exit_status_:(*)" {            
         set error [get_string_value_between "_exit_status_:(" ")" $expect_out(0,string)]
         report_task_add_message report $task_nr "mvn exited with status $error"
      }
      -i $spawn_list "_start_mark_:(0)" {
         set use_output 1
         report_task_add_message report $task_nr "cd $source_dir ; mvn $options $target"
         exp_continue
      }
      -i $spawn_list -re {^.*?\n} {
         if {$use_output == 1} {
            set line [string trimright $expect_out(buffer) "\n\r"]
            report_task_add_message report $task_nr "$line"
         }
         exp_continue
      }
   }
 
   close_spawn_process $open_spawn
   report_finish_task report $task_nr $error

   if {$error != 0} {
      ts_log_severe "DRMAA-Java build failed with exit_state $error"
      return -1
   }

   return 0
}

proc drmaaj_install_binaries { arch_list a_report } {
   global CHECK_USER
   global ts_config ts_host_config drmaaj_config
   
   upvar $a_report report
   set task_nr [report_create_task report "drmaaj_install_binaries" $ts_config(master_host)]
   
   set source_dir [config_get_drmaaj_source_dir]
   set jar "$source_dir/target/jdrmaa-1.0.jar"
   set dest "$ts_config(product_root)/lib"
   set cmd "cp"
   set args "$jar $dest"
   
   report_task_add_message report $task_nr "------------------------------------------"
   report_task_add_message report $task_nr "-> $cmd $args"
   set output [start_remote_prog $ts_config(master_host) $CHECK_USER $cmd $args]
   if {$prg_exit_state != 0} {
      report_task_add_message report $task_nr "------------------------------------------"
      report_task_add_message report $task_nr "return state: $prg_exit_state"
      report_task_add_message report $task_nr "------------------------------------------"
      report_task_add_message report $task_nr "output:\n$output"
      report_task_add_message report $task_nr "------------------------------------------"
      report_finish_task report $task_nr -1
      return -1
   }

   if {![is_remote_file $ts_config(master_host) $CHECK_USER "$ts_config(product_root)/lib/drmaa.jar"]} {
      set cmd "ln"
      set args "-s jdrmaa-1.0.jar drmaa.jar"
      report_task_add_message report $task_nr "------------------------------------------"
      report_task_add_message report $task_nr "-> $cmd $args"
      set output [start_remote_prog $ts_config(master_host) $CHECK_USER $cmd $args prg_exit_state 60 0 "$ts_config(product_root)/lib"]
      if {$prg_exit_state != 0} {
         report_task_add_message report $task_nr "------------------------------------------"
         report_task_add_message report $task_nr "return state: $prg_exit_state"
         report_task_add_message report $task_nr "------------------------------------------"
         report_task_add_message report $task_nr "output:\n$output"
         report_task_add_message report $task_nr "------------------------------------------"
         report_finish_task report $task_nr -1
         return -1
      }
   }


   report_finish_task report $task_nr 0

   return 0
}


proc drmaaj_test_run_level_check {is_starting was_error} {
   # anything to do?
   return 0
}
