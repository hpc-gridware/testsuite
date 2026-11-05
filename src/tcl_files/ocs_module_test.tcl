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

## @file
# @brief Running module test binaries, one binary per level (module_test_generic, module_test_cull,
#        module_test_uti, module_test_sgeobj)

# A library file may be sourced from inside a proc, so the list is declared
# global before it is set.
global module_tests_with_report
# The binaries built on the shared module test frame (clusterscheduler
# test/common/ocs_module_test.h). When the testsuite records a run, they get
# the report options and their records become a stream of their own, so each
# scenario and CHECK shows up in the test report. Any other binary gets no
# extra arguments: some read their own.
set module_tests_with_report {test_comm_xml_parse test_sgeobj_rsmap test_sgeobj_ulong test_sgeobj_var
                              test_uti_peopen test_cull_select_pack test_uti_lock_held
                              test_uti_cpus test_uti_format_text test_cull_owner test_cull_pack_format
                              test_cull_lazy test_cull_descr}

## @brief Run the one module test binary the current level selects from a list
#
# The level is the index into the list; the binary always runs on the suited
# host. A binary whose version or feature requirement the cluster does not meet
# is skipped via ts_log_info (a configuration issue, not a failure). Used by the
# module test checks whose levels are one binary each (module_test_generic,
# module_test_cull, module_test_uti, module_test_sgeobj).
#
# @param module_tests list of {binary min_version needs_gcs max_version}, indexed by level
# @return none; reports failures through ts_log_severe
proc ocs_module_test_run_level {module_tests} {
   global ts_config CHECK_USER CHECK_ACT_LEVEL
   global module_tests_with_report

   set index $CHECK_ACT_LEVEL

   if {$index >= [llength $module_tests]} {
      ts_log_info "level $CHECK_ACT_LEVEL has no module test assigned"
      return
   }

   lassign [lindex $module_tests $index] module_test min_version needs_gcs max_version

   # ------------------------------------------------------------------------
   # ts_log_info, NEVER ts_log_config, in a check function.
   #
   # ts_log_config records -3 in check_errno($CHECK_CUR_PROC_NAME), and the
   # framework turns any -3 into "level unsupported"
   # (private_check_error_run_test_level, check.exp). check_errno is keyed by
   # FUNCTION NAME and is not cleared between levels, and every level of this
   # check runs the same function -- so a single ts_log_config here marks every
   # FOLLOWING level unsupported too, including the ones that ran and passed.
   #
   # Observed 2026-08-04: level 23 skips test_RequestLimits on 9.2 (replaced by
   # test_sgeobj_RequestLimits). With ts_log_config, levels 24..149 all reported
   # UNSUPPORTED although their binaries ran and passed.
   #
   # The framework only sanctions ts_log_config in a setup function that then
   # returns 99 (check.exp: "setup_ret == 99 ... this means there was no
   # ts_log_config"). If a level should report "unsupported" rather than simply
   # be logged as skipped, add a check_setup_level_function that does both --
   # do not call ts_log_config from here.
   # ------------------------------------------------------------------------
   if {$min_version ne "" && ![is_version_in_range $min_version]} {
      ts_log_info "$module_test needs version $min_version or newer - skipped"
      return
   }
   if {$max_version ne "" && [is_version_in_range $max_version]} {
      ts_log_info "$module_test was replaced in $max_version - skipped"
      return
   }
   if {$needs_gcs && ![ge_has_feature "gcs"]} {
      ts_log_info "$module_test needs the gcs feature set - skipped"
      return
   }

   set hosts [host_conf_get_suited_hosts]
   ts_log_fine "$module_test on: $hosts"

   set error_text ""
   foreach host $hosts {
      ts_log_frame
      ts_log_fine "host $host, arch [resolve_arch $host]"

      # some tests (especially thread related ones) can take very long
      set time_in_sec 600

      # test_uti_peopen (CS-2333) exercises the root-only user-switch path of
      # sge_peopen*; it must run as root and is told which non-root user to
      # switch to (argv[1]), otherwise it only skips.
      set test_user $CHECK_USER
      set test_args ""
      if {$module_test eq "test_uti_peopen"} {
         global CHECK_FIRST_FOREIGN_SYSTEM_USER
         set test_user "root"
         set test_args $CHECK_FIRST_FOREIGN_SYSTEM_USER
      }

      # appended, not prepended: a binary of a line not yet on the frame reads
      # its own arguments by position (test_uti_peopen: argv[1] is the user)
      if {[lsearch -exact $module_tests_with_report $module_test] >= 0} {
         set test_args [concat $test_args [tsrec_module_test_args]]
      }

      set output [start_test_bin $module_test $test_args $host $test_user ret $time_in_sec]
      set output [tsrec_module_test_output $output]
      if {$ret == 0} {
         ts_log_fine "   => $module_test ok"
         ts_log_fine $output
      } else {
         ts_log_fine "   => $module_test failed"
         append error_text "module test $module_test failed on $host:\n$output\n\n"
      }
   }

   if {$error_text ne ""} {
      ts_log_severe $error_text
   }
}
