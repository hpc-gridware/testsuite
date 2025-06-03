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

#****** coverage/insure_get_local_basedir() ************************************
#  NAME
#     insure_get_local_basedir() -- get host local directory
#
#  SYNOPSIS
#     insure_get_local_basedir { } 
#
#  FUNCTION
#     Returns a unique host local directory for the storage of 
#     code coverage profiles.
#
#  RESULT
#     A directory name.
#     The current implementation returns a directory 
#     /tmp/insure/<qmaster commd port number>.
#*******************************************************************************
proc insure_get_local_basedir {} {
   get_current_cluster_config_array ts_config
   return "/tmp/insure/$ts_config(commd_port)"
}

#****** coverage/insure_initialize() *******************************************
#  NAME
#     insure_initialize() -- initialize for insure coverage profiling
#
#  SYNOPSIS
#     insure_initialize { } 
#
#  FUNCTION
#     Prepares the environment required for running code coverage tests 
#     with insure:
#        o create local profile directories on all hosts
#        o create insure settings file (.psrc) for all cluster users
#
#  SEE ALSO
#     coverage/coverage_initialize()
#*******************************************************************************
proc insure_initialize {{clean 0}} {
   global CHECK_COVERAGE_DIR

   get_current_cluster_config_array ts_config

   if { [have_root_passwd] == -1 } {
      ts_log_fine "need root access ..."
      set_root_passwd
   }

   # create a local log directory on all hosts
   set basedir [insure_get_local_basedir]
   ts_log_fine "creating local log directories on host"
   set hosts [host_conf_get_cluster_hosts]
   set users [user_conf_get_cluster_users]
   foreach host $hosts {
      ts_log_progress FINE " $host"
      start_remote_prog $host "root" "$ts_config(testsuite_root_dir)/scripts/insure_create_log_dirs.sh" "$clean $basedir $users"
   }
   ts_log_fine " done"

   # create .psrc file as temporary file
   # and copy .psrc file into users home directories
   ts_log_fine "installing .psrc files for all users"
   foreach user $users {
      set tmp_psrc [get_tmp_file_name]
      set f [open $tmp_psrc "w"]
      puts $f "# .psrc file created by Cluster Scheduler (Grid Engine) testsuite"
      puts $f "insure++.ReportFile insra"
      puts $f "insure++.suppress PARM_NULL"
      puts $f "insure++.suppress BAD_INTERFACE"
      puts $f "insure++.compiler_default cpp"
      puts $f "insure++.demangle off"
      puts $f "insure++.leak_search off"
      puts $f "insure++.leak_sweep off"
      puts $f "insure++.checking_uninit off"
      puts $f "insure++.ignore_wild off"
      puts $f "insure++.temp_directory /tmp"
      puts $f "insure++.coverage_boolean on"
      puts $f "#insure++.coverage_only on"
      puts $f "insure++.coverage_map_data on"
      # we might add %a (architecture) to the following option
      puts $f "insure++.coverage_map_file ${CHECK_COVERAGE_DIR}/tca.map"
      puts $f "insure++.coverage_log_data on"
      puts $f "insure++.coverage_overwrite off"
      # we might want to add the hostname as directory to the following option.
      # We should also consider if storing the log files on a local filesystem
      # could significantly speed up testsuite execution
      puts $f "insure++.coverage_log_file ${basedir}/${user}/tca.%v.log"
      puts $f "insure++.coverage_banner off"
      puts $f "insure++.report_banner off"
      puts $f "insure++.threaded_runtime on"
      puts $f "insure++.avoidExternDecls *"
      close $f

      # the user might have local home directory,
      # so copy his .psrc to every host
      # and we have to create the local log directory on every host
      ts_log_fine "-> user $user on host"
      foreach host [host_conf_get_cluster_hosts] {
         ts_log_progress FINE " $host"
         start_remote_prog $host $user "cp" "$tmp_psrc \$HOME/.psrc"
      }
      ts_log_fine " done"
   }
}

proc insure_join_dirs {} {
   global CHECK_COVERAGE_DIR

   get_current_cluster_config_array ts_config

   if { [have_root_passwd] == -1 } {
      ts_log_fine "need root access ..."
      set_root_passwd
   }

   # copy from local logdir (basedir) to CHECK_COVERAGE_DIR/$host
   set basedir [insure_get_local_basedir]
   ts_log_fine "copying local log directories from host"
   set hosts [host_conf_get_cluster_hosts]
   foreach host $hosts {
      ts_log_progress FINE " $host"
      start_remote_prog $host "root" "$ts_config(testsuite_root_dir)/scripts/insure_join_log_dirs.sh" "$basedir ${CHECK_COVERAGE_DIR}/${host}" prg_exit_state 600
   }
   ts_log_fine " done"
}

proc insure_compute_coverage {} {
# source code with coverage for a certain file:
# tca -ds -ct -fF sge_dstring.c /cod_home/joga/sys/tca/*/*/tca*.log
#
# coverage summary per file
# tca -dS -fF sge_dstring.c /cod_home/joga/sys/tca/*/*/tca*.log
}
