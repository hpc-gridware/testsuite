#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2025 HPC-Gridware GmbH
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

global lcov_tests
array set lcov_tests {}

global lcov_read_file
set lcov_read_file 0

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

## @brief returns the base directory for the lcov coverage data
proc lcov_get_base_dir {} {
   global ts_config
   global CHECK_COVERAGE_DIR

   return [file join $CHECK_COVERAGE_DIR $ts_config(commd_port)]
}

## @brief returns the directory where the lcov coverage data is stored
#
# The directory is based on the configured test suite commd_port and the host name.
#
# @param host the host name for which the coverage data directory is returned
# @return the directory where the lcov coverage data is stored
#
proc lcov_get_coverage_build_dir {host} {
   return [file join [lcov_get_base_dir] $host]
}

## @brief adapts the permissions of *.gcda files in the coverage build directory
#
# *.gcda files are created during execution of the OCS/GCS commands that are build with gcov.
# The files are executed as the user that triggered the command and the created *.gcda files
# have permissions 644 (read and write for the owner, read for group and others - with a typical umask).
#
# File permissions need to get changed to 666 (read and write for all users) so that the lcov tool can
# read the coverage data files. and also that OCS/GCS commands can update the coverage data files.
#
# @param host the host name for which the permissions are adapted
# @return 0 on success, -1 on failure
#
proc lcov_adapt_permissions {host} {
   set build_dir [lcov_get_coverage_build_dir $host]
   set find_binary [get_binary_path $host "find"]
   set find_output [start_remote_prog $host "root" $find_binary "$build_dir -name \"*.gcda\" -perm 644 -exec chmod 666 {} \\;"]
   if {$prg_exit_state != 0} {
      ts_log_fine $find_output
      ts_log_fine "lcov_adapt_permissions: failed to set permissions for *.gcda files in $build_dir"
      return -1
   }
   return 0
}

## @brief returns the lcov command line with all exclude directives
#
# The exclude/include  directives are used to select what should be part of the coverage report.
#
# @param host the host name for which the lcov command line is returned
# @return the lcov command line with all exclude directives
#
proc lcov_exclude_directives {host} {
   global CHECK_USER
   global ts_config

   set source_token [file split $ts_config(source_dir)]
   set source_dir_minus1 [file join {*}[lrange $source_token 0 end-1]]
   set source_dir_minus2 [file join {*}[lrange $source_token 0 end-2]]

   set build_dir [lcov_get_coverage_build_dir $host]
   set lcov_base_cmd_line "--exclude \"$build_dir/_deps/*\""
   append lcov_base_cmd_line " --exclude \"/home/$CHECK_USER/3rd_party/*\""
   append lcov_base_cmd_line " --exclude \"$build_dir/*\""
   append lcov_base_cmd_line " --exclude \"$ts_config(source_dir)/3rdparty/qmake*\""
   append lcov_base_cmd_line " --include \"$ts_config(source_dir)/3rdparty/qmake/remote-sge*\""
   append lcov_base_cmd_line " --exclude \"$ts_config(source_dir)/tools*\""
   append lcov_base_cmd_line " --exclude \"$source_dir_minus1/test*\""
   append lcov_base_cmd_line " --exclude \"$source_dir_minus2/gcs-extensions/test*\""
   append lcov_base_cmd_line " --exclude \"/opt/rh/*\""
   append lcov_base_cmd_line " --exclude \"/usr/include/*\""
   return $lcov_base_cmd_line
}

## @brief initializes the lcov baseline with zero counters
#
# This function is called to initialize the lcov baseline with zero counters.
# It is called during the build process to ensure that zero counters are available for all
# architectures that are compiled and for all branches of the code.
# The baseline-zero can later be combined with a test specific coverage snapshot
# to create a final coverage report that includes all counters. This insures that
# the final coverage report does not only the counters but also the correct percentages in
# the reports.
#
# @param host the host name for which the lcov baseline is initialized
# @return 0 on success, -1 on failure
#
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

   return 0
}

## @brief initializes the lcov coverage data.
#
# This function is called to initialize the lcov coverage data or to reset the coverage data.
# Can be triggered manually via TS menu
#
# @param clean if 1 then the coverage data is cleaned before initialization, otherwise the existing data is kept
# @return 0 on success, -1 on failure
proc lcov_initialize {{clean 0}} {
   global CHECK_COVERAGE_DIR
   global CHECK_RESULT_DIR
   global CHECK_USER
   global lcov_tests

   foreach host [lcov_get_compile_hosts] {
      set build_dir [lcov_get_coverage_build_dir $host]
      set arch [host_conf_get_arch $host]

      if {$clean} {
         array set lcov_tests {}

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
   return 0
}

## @brief callback in the testsuite framework triggered directly after the cmake build
#
# This function is called to initialize the lcov coverage data after the cmake build.
# It is called during the build process to ensure that zero counters are available for all
# architectures that are compiled and for all branches of the code.
#
# @return 0 on success, -1 on failure
#
proc lcov_build_epilog {} {
   global CHECK_USER

   foreach host [lcov_get_compile_hosts] {
      lcov_init_baseline_zero $host
      lcov_adapt_permissions $host
   }
   return 0
}

## @brief callback in the testsuite framework triggered directly after one check of a test finished
#
# @param test_name the name of the test that finished
# @param check_name the name of the check that finished
# @returns 0 on success, -1 on failure
proc lcov_check_epilog {test_name check_name} {
   ts_log_fine "lcov_check_epilog: $test_name $check_name"
   foreach host [lcov_get_compile_hosts] {
      set build_dir [lcov_get_coverage_build_dir $host]
      lcov_adapt_permissions $host
   }
   return 0
}

## @brief callback in the testsuite framework triggered directly after one test finished
#
# @param test_name the name of the test that finished
# @returns 0 on success, -1 on failure
#
proc lcov_test_epilog {test_name test_description} {
   global lcov_tests
   global lcov_read_file

   ts_log_fine "lcov_test_epilog: $test_name"

   # read file if there is one from a previous TS run
   if {$lcov_read_file == 0} {
      set in_filename [file join [lcov_get_base_dir] "lcov-description.txt"]
      lcov_read_description_file $in_filename
      set lcov_read_file 1
   }

   # set the test name and description in the lcov_tests array
   set lcov_tests($test_name) $test_description

   # adapt permissions of *.gcda files
   foreach host [lcov_get_compile_hosts] {
      set build_dir [lcov_get_coverage_build_dir $host]
      lcov_adapt_permissions $host
   }

   # compute the coverage data for the test
   lcov_compute_coverage $test_name $test_description
   return 0
}

# callback in the testsuite framework that would allow per process setup
proc lcov_per_process_setup {host user env_var} {
   #upvar $env_var env
   # nothing to do for lcov
}

# callback in the testsuite framework that would allow to join the coverage data of multiple coverage runs
# this is not required for lcov as it is done in the lcov_compute_coverage function automatically
proc lcov_join_dirs {} {
   # @todo CS-1307: all architecture specific coverage is automatically collected in the cmake-build directory
   # this means that there is no need to join data for one architecture ...but
   # is there a possibility to combine the data of multiple architectures?
}

## @brief computes the coverage data for the given test name
#
# This function is called to compute the coverage data for the given test name.
# It is called during the test execution to compute the coverage data for the test.
# In regular intervals the method also updates a final coverage report.
#
# Can be triggered manually via TS menu, too, e.g. to generate a final coverage report.
#
# @param test_name the name of the test for which the coverage data is computed
# @note if test_name is "final" then the final coverage report is generated
#
proc lcov_compute_coverage {{test_name "final"} {test_description ""}} {
   global CHECK_USER
   global ts_config
   global lcov_counter

   # do for each architecture that we have compiled
   foreach host [lcov_get_compile_hosts] {
      set build_dir [lcov_get_coverage_build_dir $host]
      set arch [host_conf_get_arch $host]
      set lcov_binary [get_binary_path $host "lcov"]
      set genhtml_binary [get_binary_path $host "genhtml"]

      ts_log_fine "lcov_compute_coverage: $test_name - $test_description"

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
      if {$test_name == "final" || $lcov_counter >= 0} {
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
         set ocs_version [get_version_info version_array]
         set genhtml_title "$ocs_version LCOV-Report"
         set genhtml_prefix [file join {*}[lrange [file split $ts_config(source_dir)] 0 end-2]]
         set genhtml_descr_file [lcov_gen_description_file $host]
         set genhtml_cmd_line "--ignore-errors source --demangle-cpp --legend --title \"$genhtml_title\" --prefix \"$genhtml_prefix\" --show-details"
         if {$genhtml_descr_file != ""} {
            append genhtml_cmd_line " --description-file $genhtml_descr_file --keep-descriptions"
         }
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

## @brief writes the test names and descriptions into a file
#
# This function is called to write the test names and descriptions into a file.
# The file is used to generate a description file for the lcov tool.
#
# @param out_filename the name of the file where the test names and descriptions are written
# @note the file is written in a format that can be read by the lcov tool
#
proc lcov_write_description_file {out_filename} {
   global lcov_tests

   set fh [open $out_filename "w"]
   foreach test_name [array names lcov_tests] {
      set test_description $lcov_tests($test_name)
      puts $fh "$test_name"
      puts $fh "    $test_description"
   }
   close $fh
}

## @brief reads the test names and descriptions from a file
#
# This function is called to read the test names and descriptions from a file.
# The file is used to generate a description file for the lcov tool.
#
# @param in_filename the name of the file where the test names and descriptions are read from
#
proc lcov_read_description_file {in_filename} {
    global lcov_tests

    if {![file exists $in_filename]} {
       # no error if the file does not exist
       return 0
    }

    set fh [open $in_filename "r"]
    set test_name ""
    set is_name 1
    while {[gets $fh line] >= 0} {
       if {$is_name} {
          set name $line
          set is_name 0
       } else {
          set description [string trim $line]
          set lcov_tests($name) $description
          set is_name 1
       }
    }
    close $fh

    return 0
 }

## @brief generates the lcov description file
#
proc lcov_gen_description_file {host} {
   global ts_config
   global CHECK_USER
   global lcov_tests
   set gendesc_binary [get_binary_path $host "gendesc"]

   # early exit if there is nothing to do
   set names [array names lcov_tests]
   if {[llength $names] == 0} {
      return ""
   }

   # write test names and description into a file
   set base_dir [lcov_get_base_dir]
   set in_filename [file join $base_dir "lcov-description.txt"]
   lcov_write_description_file $in_filename

   # generate the lcov description file that will be accepted by lcov
   set out_filename [file join $base_dir "lcov-description.lcov"]
   set gendesc_args "--output-filename $out_filename $in_filename"
   set cp_output [start_remote_prog $host $CHECK_USER $gendesc_binary $gendesc_args]
   ts_log_fine $cp_output

   return $out_filename
}
