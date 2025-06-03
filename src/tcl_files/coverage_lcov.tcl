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

global lcov_counter
set lcov_counter 0

## @brief returns a list of compile hosts for the configured test suite
#
# GCOV profiling is enabled during compilations on the compile hosts.
# LCOV is used to collect the profiling data and needs to be called also on the compile hosts.
#
# @return list of compile hosts
#
proc lcov_get_compile_hosts {} {
   global ts_config

   # all compile hosts for the configured test hosts (master, exec, shadow, submit_only, pure_admin)
   set compile_hosts [compile_host_list 1]

   # add compile hosts for additional compile archs
   if {$ts_config(add_compile_archs) != "none"} {
      foreach arch $ts_config(add_compile_archs) {
         lappend compile_hosts [compile_search_compile_host $arch]
      }
   }

   # eliminate duplicate and return unique list
   return [compile_unify_host_list $compile_hosts]
}

proc lcov_get_coverage_build_dir {host} {
   global ts_config
   global CHECK_COVERAGE_DIR

   return [file join $CHECK_COVERAGE_DIR $ts_config(commd_port) $host]
}

# adapt permissions of *.gcda files
proc lcov_adapt_permissions {host} {
   set build_dir [lcov_get_coverage_build_dir $host]
   set find_binary [get_binary_path $host "find"]
   set find_output [start_remote_prog $host "root" $find_binary "$build_dir -name \"*.gcda\" -perm 644 -exec chmod 666 {} \\;"]
   if {$prg_exit_state != 0} {
      ts_log_fine $find_output
      ts_log_error "lcov_adapt_permissions: failed to set permissions for *.gcda files in $build_dir"
      return -1
   }
   return 0
}

# - the _deps directory (cmake dependent projects)
# - the /opt/rh directory (where C++ compilers are installed and we would see inlined code of C++ headers)
# - the test directory (where module tests of cluster scheduler are located)
# - the test directory (where module tests of GCS are located)
# - the 3rd_party directory (where 3rd party libraries are located)
proc lcov_exclude_directives {host} {
   global CHECK_USER
   global ts_config

   set build_dir [lcov_get_coverage_build_dir $host]
   set lcov_base_cmd_line "--exclude \"$build_dir/_deps/*\""
   append lcov_base_cmd_line " --exclude \"/home/$CHECK_USER/3rd_party/*\""
   append lcov_base_cmd_line " --exclude \"$build_dir/*\""
   append lcov_base_cmd_line " --exclude \"$ts_config(source_dir)/3rdparty/qmake/*\""
   append lcov_base_cmd_line " --exclude \"$ts_config(source_dir)/../test/*\""
   append lcov_base_cmd_line " --exclude \"$ts_config(source_dir)/../../$ts_config(ext_source_dir)/test/*\""
   append lcov_base_cmd_line " --exclude \"/opt/rh/*\""
   append lcov_base_cmd_line " --exclude \"/usr/include/*\""
   return $lcov_base_cmd_line
}

proc lcov_init_baseline_zero {host} {
   global CHECK_USER

   set build_dir [lcov_get_coverage_build_dir $host]
   set arch [host_conf_get_arch $host]
   set lcov_binary [get_binary_path $host "lcov"]
   set lcov_data_dir [file join $build_dir]

   # set permissions of *.gcda files
   lcov_adapt_permissions $host

   # initialize lcov counters
   set lcov_args "-zerocounters -d $lcov_data_dir"
   ts_log_fine "lcov_initialize: $lcov_binary $lcov_args"
   set lcov_output [start_remote_prog $host $CHECK_USER $lcov_binary $lcov_args]
   ts_log_fine $lcov_output

   # create a baseline file with zero counters
   set lcov_args "[lcov_exclude_directives $host] -capture -initial -directory $lcov_data_dir -output-file $build_dir/baseline-zero-$arch.info"
   ts_log_fine "lcov_initialize: $lcov_binary $lcov_args"
   set lcov_output [start_remote_prog $host $CHECK_USER $lcov_binary $lcov_args prg_exit_state 300]
}

# callback
proc lcov_initialize {{clean 0}} {
   global CHECK_COVERAGE_DIR
   global CHECK_RESULT_DIR
   global CHECK_USER

   foreach host [lcov_get_compile_hosts] {
      set build_dir [lcov_get_coverage_build_dir $host]
      set arch [host_conf_get_arch $host]

      if {$clean} {
         set rm_output [start_remote_prog $host $CHECK_USER "rm" "$build_dir/*.info"]
         ts_log_fine $rm_output

         set rm_output [start_remote_prog $host $CHECK_USER "rm" "-rf $build_dir/report"]
         ts_log_fine $rm_output
      }

      # create the baseline zero if it does not exist
      if {![file exists "$build_dir/baseline-zero-$arch.info"]} {
         lcov_init_baseline_zero $host
      }
   }
}

# automatic callback in the testsuite framework triggered directly after the cmake build
proc lcov_build_epilog {} {
   global CHECK_USER

   foreach host [lcov_get_compile_hosts] {
      lcov_init_baseline_zero $host
   }
   return 0
}

# automatic callback in the testsuite framework triggered directly after a test finished
proc lcov_check_epilog {test_name check_name} {
   ts_log_fine "lcov_check_epilog: $test_name $check_name"
   foreach host [lcov_get_compile_hosts] {
      set build_dir [lcov_get_coverage_build_dir $host]
      lcov_adapt_permissions $host
   }
   return 0
}

# automatic callback in the testsuite framework triggered directly after a test finished
proc lcov_test_epilog {test_name} {
   ts_log_fine "lcov_test_epilog: $test_name"
   foreach host [lcov_get_compile_hosts] {
      set build_dir [lcov_get_coverage_build_dir $host]
      lcov_adapt_permissions $host
   }
   lcov_compute_coverage $test_name
   return 0
}

# callback in the testsuite framework
proc lcov_per_process_setup {host user env_var} {
   #upvar $env_var env
   # nothing to do for lcov
}

# callback in the testsuite framework
proc lcov_join_dirs {} {
   # @todo CS-1307: all architecture specific coverage is automatically collected in the cmake-build directory
   # this means that there is no need to join data for one architecture ...but
   # is there a possibility to combine the data of multiple architectures?
}

# callback in the testsuite framework
# will also be triggered after each test
proc lcov_compute_coverage {{test_name "final"}} {
   global CHECK_USER
   global ts_config
   global lcov_counter

   # do for each architecture that we have compiled
   foreach host [lcov_get_compile_hosts] {
      set build_dir [lcov_get_coverage_build_dir $host]
      set arch [host_conf_get_arch $host]
      set lcov_binary [get_binary_path $host "lcov"]
      set genhtml_binary [get_binary_path $host "genhtml"]

      # set permissions of *.gcda files
      lcov_adapt_permissions $host

      # set the lcov command line
      set lcov_base_cmd_line "[lcov_exclude_directives $host] --directory $build_dir"

      # if test_name is not "final" then we want a test specific coverage snapshot
      # otherwise be might create a final coverage report where we combine the data of multiple architectures
      set lcov_snapshot_cmd_line "$lcov_base_cmd_line --test-name $test_name"

      # create test coverage snapshot
      append lcov_snapshot_cmd_line " --capture --output-file $build_dir/$test_name-snapshot-$arch.info"
      ts_log_fine "lcov_compute_coverage: lcov $lcov_snapshot_cmd_line"
      set lcov_output [start_remote_prog $host $CHECK_USER $lcov_binary $lcov_snapshot_cmd_line prg_exit_state 300]
      ts_log_fine $lcov_output

      # combine the snapshot with the zero baseline
      set lcov_combine_cmd_line "$lcov_base_cmd_line --add-tracefile $build_dir/$test_name-snapshot-$arch.info --output-file $build_dir/$test_name-$arch.info"
      if {[file exists "$build_dir/baseline-zero-$arch.info"]} {
         append lcov_combine_cmd_line " --add-tracefile $build_dir/baseline-zero-$arch.info"
      }
      ts_log_fine "lcov_compute_coverage: lcov $lcov_combine_cmd_line"
      set lcov_output [start_remote_prog $host $CHECK_USER $lcov_binary $lcov_combine_cmd_line prg_exit_state 300]
      ts_log_fine $lcov_output

      # generate the report if triggered manually or after a certain number of tests
      set generate_final_report 0
      if {$test_name == "final" || $lcov_counter >= 2} {
         set generate_final_report 1
         set lcov_counter 0
      }
      incr lcov_counter

      # save the baseline
      set have_baseline_before_start [file exists "$build_dir/baseline-before-start-$arch.info"]
      if {$have_baseline_before_start} {
         ts_log_fine "lcov_compute_coverage: cp $build_dir/baseline-before-start-$arch.info $build_dir/$test_name-baseline-$arch.info"
         set cp_output [start_remote_prog $host $CHECK_USER "cp" "$build_dir/baseline-before-start-$arch.info $build_dir/$test_name-baseline-$arch.info"]
         ts_log_fine $cp_output
      }

      # generate report for one test submit_only
      # @todo CS-1307: might be implemented when required (take the test subtract the baseline and generate a report)
      #   --baseline $build_dir/baseline-before-start-$arch.info

      # generate the final report if requested
      if {$generate_final_report} {
         # create a test specific coverage report
         set genhtml_cmd_line "--ignore-errors source --demangle-cpp --legend --title \"GCS 9.1.0alpha Code Coverage Report\" --prefix \"/home/ebablick/CS/cs3-0/\" --show-details"
         append genhtml_cmd_line " $build_dir/$test_name-$arch.info --output-directory $build_dir/report/final-$arch"

         ts_log_fine "lcov_compute_coverage: genhtml $genhtml_cmd_line"
         set genhtml_output [start_remote_prog $host $CHECK_USER $genhtml_binary $genhtml_cmd_line prg_exit_state 300]
         ts_log_fine $genhtml_output
      }

      # create a new baseline if it is not the final coverage computation
      ts_log_fine "lcov_compute_coverage: cp $build_dir/$test_name-$arch.info $build_dir/baseline-before-start-$arch.info"
      set cp_output [start_remote_prog $host $CHECK_USER "cp" "$build_dir/$test_name-$arch.info $build_dir/baseline-before-start-$arch.info"]
      ts_log_fine $cp_output

      # @todo CS-1306: Combine the coverage data of multiple architectures
   }
}
