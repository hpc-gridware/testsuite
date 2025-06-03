#___INFO__MARK_BEGIN__
##########################################################################
#
#  The Contents of this file are made available subject to the terms of
#  the Sun Industry Standards Source License Version 1.2
#
#  Sun Microsystems Inc., March, 2001
#
#
#  Sun Industry Standards Source License Version 1.2
#  =================================================
#  The contents of this file are subject to the Sun Industry Standards
#  Source License Version 1.2 (the "License"); You may not use this file
#  except in compliance with the License. You may obtain a copy of the
#  License at http://gridengine.sunsource.net/Gridengine_SISSL_license.html
#
#  Software provided under this License is provided on an "AS IS" basis,
#  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
#  WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
#  MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
#  See the License for the specific provisions governing your rights and
#  obligations concerning the Software.
#
#  The Initial Developer of the Original Code is: Sun Microsystems, Inc.
#
#  Copyright: 2001 by Sun Microsystems, Inc.
#
#  All Rights Reserved.
#
#  Portions of this software are Copyright (c) 2023-2024 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

## @brief check if code coverage is enabled
#
# Returns if code coverage is enabled for the current testsuite run.
#
# One or multiple code coverage methods can be enabled at a time,
# "lcov", "tcov", or "insure" for C/C++ code coverage analysis,
# or "emma" for Java code coverage analyis.
#
# The procedure can check if any coverage method is enabled (parameter
# method == ""), or a specific one.
#
# @param method coverage method to look for, or "" (default) to check if
#               any coverage analyis is done
# @return 1 if coverage is enabled, 0 if not
#
proc coverage_enabled {{method ""}} {
   global CHECK_COVERAGE

   set ret 0

   if {$method == ""} {
      if {$CHECK_COVERAGE != {}} {
         set ret 1
      }
   } else {
      if {[lsearch -exact $CHECK_COVERAGE $method] >= 0} {
         set ret 1
      }
   }

   return $ret
}

## @brief initialize code coverage analysis
#
# This function is called during testsuite setup. It sets up the required
# environment (e.g. directories) # for code coverage analysis.
#
# This step can be triggered manually
#    menu item 26 "cluster checks" => 1 "initialize code coverage"
#
# @param clean 0 - shall the coverage directories be deleted and reinitialized?
#              1 - clean up the coverage directories
proc coverage_initialize {{clean 0}} {
   global CHECK_COVERAGE

   foreach cov $CHECK_COVERAGE {
      set procname "${cov}_initialize"
      if {[info procs $procname] != {}} {
         $procname $clean
      }
   }
   return 0
}

## @brief setup process environment for code coverage
#
# This function is called atomatically to set up code coverage environment
# after the build process has finished.
#
# It can be used to create a basiline before the TS itself has a chance to
# influence the coverage data.
#
proc coverage_build_epilog {} {
   global CHECK_COVERAGE

   ts_log_fine "coverage_build_epilog: $CHECK_COVERAGE"

   foreach cov $CHECK_COVERAGE {
      set procname "${cov}_build_epilog"
      if {[info procs $procname] != {}} {
         set ret [$procname]
         if {$ret != 0} {
            ts_log_severe "Error in ${cov}_epilog_build: $ret"
            return $ret
         }
      }
   }
   return 0
}

proc coverage_test_epilog {test_name} {
   global CHECK_COVERAGE

   ts_log_fine "coverage_test_epilog: $test_name"

   foreach cov $CHECK_COVERAGE {
      set procname "${cov}_test_epilog"
      if {[info procs $procname] != {}} {
         set ret [$procname $test_name]
         if {$ret != 0} {
            ts_log_severe "Error in $procname: $ret"
            return $ret
         }
      }
   }
   return 0
}

proc coverage_check_epilog {test_name check_name} {
   global CHECK_COVERAGE

   ts_log_fine "coverage_check_epilog: $test_name"

   foreach cov $CHECK_COVERAGE {
      set procname "${cov}_check_epilog"
      if {[info procs $procname] != {}} {
         set ret [$procname $test_name $check_name]
         if {$ret != 0} {
            ts_log_severe "Error in $procname: $ret"
            return $ret
         }
      }
   }
   return 0
}

## @brief setup process environment for code coverage
#
# This function is called to set up the environment for a process that
# will be started with code coverage enabled.
# It is called by the testsuite framework before starting a process.
#
# @param host host where the process will be started
# @param user user who will run the process
# @param env_var name of a TCL array holding environment variables that will
#                be set in the processes environment
#
proc coverage_per_process_setup {host user env_var} {
   global CHECK_COVERAGE
  
   foreach cov $CHECK_COVERAGE {
      set procname "${cov}_per_process_setup"
      if {[info procs $procname] != {}} {
         $procname $host $user env
      }
   }
}

## @brief join host local coverage profile directories
#
# This function is called to copy the host local files to a shared directory.
# If necessary (depending on profiling method) multiple profiles are
# joined into a single one.
# It is called by the testsuite framework before computing the coverage.
#
proc coverage_join_dirs {} {
   global CHECK_COVERAGE

   foreach cov $CHECK_COVERAGE {
      set procname "${cov}_join_dirs"
      if {[info procs $procname] != {}} {
         $procname
      }
   }
}

## @brief join host local coverage profile directories
#
# This function is called to copy the host local files to a shared directory.
# If necessary (depending on profiling method) multiple profiles are
# joined into a single one.
# It is called by the testsuite framework before computing the coverage.
#
proc coverage_compute_coverage {} {
   global CHECK_COVERAGE

   foreach cov $CHECK_COVERAGE {
      set procname "${cov}_compute_coverage"
      if {[info procs $procname] != {}} {
         $procname
      }
   }
}

## @brief do coverage analysis
#
# This function is called (e.g. from testsuite menu) to generate the
# code coverage analysis.
#
# Host local coverage profiles are joined in a shared location and the analysis and reporting is done.
#
proc coverage_analyis {} {
   global CHECK_COVERAGE

   if {$CHECK_COVERAGE == "none"} {
      ts_log_fine "No coverage information available."
      ts_log_fine "To gather coverage information, please do"
      ts_log_fine "  o compile with -cov"
      ts_log_fine "  o install the binaries"
      ts_log_fine "  o call testsuite with the coverage and coverage_dir options"
      ts_log_fine "  o run testsuite installation and checks"
      ts_log_fine "  o call this menu item"
      return
   }

   # gather and join coverage files
   coverage_join_dirs

   # compute coverage information 
   coverage_compute_coverage
}
