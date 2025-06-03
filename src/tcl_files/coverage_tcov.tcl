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

## @brief Returns a unique host local directory for code coverage
#
# @return A directory name, e.g. /tmp/tcov/10000
proc tcov_get_local_basedir {} {
   get_current_cluster_config_array ts_config
   return "/tmp/tcov/$ts_config(commd_port)"
}

## @brief Initializes the tcov coverage profiling environment
#
# This function creates the local profile directories on all hosts.
# It also sets up the environment for processes started directly from expect.
#
# @param clean If set to 1, the local profile directories are removed before
#              creating them. Default is 0.
proc tcov_initialize {{clean 0}} {
   global CHECK_COVERAGE_DIR CHECK_USER
   global env
   get_current_cluster_config_array ts_config

   set local_host [gethostname]

   if { [have_root_passwd] == -1 } {
      ts_log_fine "need root access ..."
      set_root_passwd
   }

   # create a local log directory on all hosts
   set basedir [tcov_get_local_basedir]
   ts_log_fine "creating local log directories on host"
   set hosts [host_conf_get_cluster_hosts]
   set users [user_conf_get_cluster_users]
   foreach host $hosts {
      ts_log_progress FINE " $host"
      start_remote_prog $host "root" "$ts_config(testsuite_root_dir)/scripts/tcov_create_log_dirs.sh" "$clean $basedir $users"
   }
   ts_log_fine " done"

   # setup the environment to use the profile directory
   # for processes started directly by expect
   tcov_per_process_setup $local_host $CHECK_USER env
}

## @brief Sets up the environment for tcov coverage profiling
#
# This function sets the environment variable SUN_PROFDATA_DIR to point to
# the host local, user specific profile directory.
# This is required for processes started directly from expect.
#
# @param host    The host where the process will be started.
# @param user    The user who will run the process.
# @param env_var The name of a TCL array holding environment variables that will
#                be set in the process's environment.
#
proc tcov_per_process_setup {host user env_var} {
   upvar $env_var env

   set basedir [tcov_get_local_basedir]
   set env(SUN_PROFDATA_DIR) "${basedir}/${user}"
}

##
# @brief Joins the local coverage profile directories from all hosts
#
# This function copies the local coverage profile directories from all hosts
# to a shared directory (CHECK_COVERAGE_DIR).
# It then joins all coverage profiles (files named "tcovd") into a single
# coverage profile (file named "total.profile").
# The resulting profile can be used to generate a coverage report.
#
proc tcov_join_dirs {} {
   global CHECK_COVERAGE_DIR
   get_current_cluster_config_array ts_config

   if {[have_root_passwd] == -1} {
      ts_log_fine "need root access ..."
      set_root_passwd
   }

   # copy from local logdir (basedir) to CHECK_COVERAGE_DIR/$host
   set basedir [tcov_get_local_basedir]
   ts_log_fine "copying local log directories from host"
   set hosts [host_conf_get_cluster_hosts]
   foreach host $hosts {
      ts_log_progress FINE " $host"
      start_remote_prog $host "root" "$ts_config(testsuite_root_dir)/scripts/tcov_join_log_dirs.sh" "$basedir ${CHECK_COVERAGE_DIR}/${host}" prg_exit_state 600
   }
   ts_log_fine " done"

   # join coverage files into one
   ts_log_fine "joining all coverage profiles into a single one"
   cd $CHECK_COVERAGE_DIR
   set profiles {}
   foreach host $hosts {
      set host_profiles [glob -nocomplain "${host}/*/*/tcovd"]
      foreach profile $host_profiles {
         lappend profiles $profile
      }
   }
   ts_log_fine "parsing [llength $profiles] profiles "
   foreach profile $profiles {
      tcov_parse_coverage_file $profile
   }
   ts_log_fine " done"
   ts_log_fine "dumping joined profile"
   tcov_dump_coverage "total.profile"
   ts_log_fine "done"
}

## @brief Returns a unique name for a TCL array
#
# This function is used to create unique names for the tcov_objects array,
# which holds information about all source code files that have been
# instrumented for code coverage.
# The names are of the form "tcov_object_<unique number>".
#
# @return A unique name for a TCL array, e.g. "tcov_object_1".
proc tcov_get_object_array_name {} {
   global tcov_object_count

   if {![info exists tcov_object_count]} {
      set tcov_object_count 0
   }

   incr tcov_object_count
   return "tcov_object_${tcov_object_count}"
}

## @brief Parses a tcov coverage profile file
#
# This function reads a tcov coverage profile file and extracts the coverage
# information for each source code file. It stores the information in a global
# array `tcov_objects`, where each entry corresponds to a source code file.
# The function handles the parsing of the profile file, extracting the object
# file name, timestamp, source file name, and coverage data for each block.
# The coverage data is stored in a TCL array for each object file, which includes
# the number of times each block was executed.
#
# @param filename The name of the tcov coverage profile file to parse.
#
proc tcov_parse_coverage_file {filename} {
   global tcov_objects

   # open the coverage file
   ts_log_progress
   #puts $filename
   set f [open $filename "r"]

   # parse the coverage file
   while {[gets $f line] >= 0} {
      switch -glob $line {
         "OBJFILE:*" {
            set object_name [lindex $line 1]
            if {![info exists tcov_objects($object_name)]} {
               set tcov_objects($object_name) [tcov_get_object_array_name]
            }
            #puts "$object_name $tcov_objects($object_name)"
            upvar $tcov_objects($object_name) obj
         }
         "TIMESTAMP:*" {
            set obj(timestamp) [lrange $line 1 end]
         }

         "SRCFILE:*" {
            set obj(srcfile) [lindex $line 1]
         }

         default {
            if {[string is space [string range $line 0 1]]} {
               set line [string trim $line]
               set block [lindex $line 0]
               set count [lindex $line 1]
               if {[info exists obj($block)]} {
                  incr obj($block) $count
               } else {
                  set obj($block) $count
                  lappend obj(index) $block
               }
            }
         }
      }
   }

   # cleanup
   close $f
}

## @brief Dumps the coverage information to a file
#
# This function writes the coverage information stored in the global `tcov_objects`
# array to a file in the specified directory. The file is named "tcovd" and contains
# the version of the coverage data file, object file names, timestamps, source file
# names, and coverage data for each block in the source files.
# If the directory does not exist, it is created.
# The function iterates over all entries in the `tcov_objects` array, writing the
# relevant information for each object file to the output file.
# If the source file name is available, it writes the coverage data for each block
# in the source file, including the block number and the number of times it was executed.
#
# @param dirname The name of the directory where the coverage data file will be created.
#
proc tcov_dump_coverage {dirname} {
   global tcov_objects

   if {![file isdirectory $dirname]} {
      file mkdir $dirname
   }

   set filename "$dirname/tcovd"
   set f [open $filename w]
   puts $f "TCOV-DATA-FILE-VERSION: 2.0"

   foreach object_name [array names tcov_objects] {
      puts $f "OBJFILE: $object_name"
      upvar $tcov_objects($object_name) obj
      puts $f "TIMESTAMP: $obj(timestamp)"

      if {[info exists obj(srcfile)]} {
         puts $f "SRCFILE: $obj(srcfile)"

         foreach block [lsort -integer $obj(index)] {
            puts $f "\t\t$block\t$obj($block)"
         }
      }

      unset obj
   }

   close $f
   unset tcov_objects
}

## @brief Computes code coverage and generates a report
#
# This function computes code coverage by recursively traversing the source
# code tree, calling the `tcov` utility for each source code file to generate
# coverage reports. It collects the number of blocks and executed blocks for
# each file and directory, calculates the coverage percentage, and generates
# an HTML report summarizing the coverage metrics.
# It also creates a table in the HTML report showing the file names, number of
# blocks, executed blocks, and coverage percentage for each source code file.
#
proc tcov_compute_coverage {} {
   global CHECK_PROTOCOL_DIR
   get_current_cluster_config_array ts_config

   if {$ts_config(source_dir) == "none"} {
      ts_log_severe "source directory is set to \"none\" - cannot go to source dir"
      return
   }

   cd $ts_config(source_dir)

   set target_dirs "./clients ./common ./daemons ./libs ./utilbin"
   set target_files "./3rdparty/qmake/remote-sge.c"

   set result(index) {}
   tcov_recursive_coverage "." target_dirs target_files result

   ts_log_newline
   ts_log_fine "total blocks:    $result(.,blocks)"
   ts_log_fine "blocks executed: $result(.,blocks_executed)"

   if {$result(.,blocks) > 0} {
      set coverage [expr $result(.,blocks_executed) * 100.0 / $result(.,blocks)]
      set coverage_text [format "%3.0f" $coverage]
      ts_log_fine "coverage:        $coverage_text %"
   }

   set html_body [create_html_text "Code coverage"]
   append html_body [create_html_text [clock format [clock seconds]]]

   set html_table(1,BGCOLOR) "#3366FF"
   set html_table(1,FNCOLOR) "#66FFFF"
   set html_table(COLS) 4
   set html_table(1,1) "File"
   set html_table(1,2) "Blocks"
   set html_table(1,3) "Executed"
   set html_table(1,4) "Coverage \[%\]"

   set row 1
   foreach file [lsort $result(index)] {
      incr row 1
      if {$result($file,is_node)} {
         set html_table($row,1) $file
      } else {
         set html_table($row,1) [create_html_link $file "${file}.txt"]
      }
      set html_table($row,2) $result($file,blocks)
      set html_table($row,3) $result($file,blocks_executed)
      set coverage 0
      if {$result($file,blocks) > 0} {
         set coverage [expr $result($file,blocks_executed) * 100.0 / $result($file,blocks)]
      }
      set html_table($row,4) [format "%3.0f" $coverage]
      set html_table($row,FNCOLOR) "#000000"
      if {$coverage < 30} {
         set html_table($row,BGCOLOR) "#FF0000"
      } else {
         if {$coverage < 70} {
            set html_table($row,BGCOLOR) "#FFFF00"
         } else {
            set html_table($row,BGCOLOR) "#33FF33"
         }
      }
   }

   set html_table(ROWS) $row
   append html_body [create_html_table html_table]
   generate_html_file "$CHECK_PROTOCOL_DIR/coverage/index.html" "Code Coverage Analysis" $html_body
}

## @brief Recursively traverses the source code tree and collects coverage data
#
# This function recursively traverses the source code tree starting from the
# specified node. It collects coverage data for all source code files (leafs)
# and directories (nodes) in the tree. For each leaf, it calls the `tcov` utility
# to generate a coverage report and stores the results in the specified result
# variable. The function initializes the coverage data for each node and aggregates
# the coverage data from its child directories and files.
# It maintains a hierarchical structure where each node contains the total number
# of blocks and executed blocks, allowing for a comprehensive overview of the
# code coverage across the entire source code tree.
#
proc tcov_recursive_coverage {node subdirs_var files_var result_var} {
   upvar $subdirs_var subdirs
   upvar $files_var files
   upvar $result_var result

   # initialize node data
   lappend result(index) $node
   set result($node,is_node) 1
   set result($node,blocks) 0
   set result($node,blocks_executed) 0

   # recursively descend tree
   foreach dir $subdirs {
      if {[file tail $dir] != "CVS"} {
         set directories [glob -directory $dir -nocomplain -types d *]
         set sourcefiles [glob -directory $dir -nocomplain -types f *.c *.cc]
         tcov_recursive_coverage $dir directories sourcefiles result

         incr result($node,blocks) $result($dir,blocks)
         incr result($node,blocks_executed) $result($dir,blocks_executed)
      }
   }

   # do coverage analysis for the leaf nodes
   foreach file $files {
      lappend result(index) $file
      set result($file,is_node) 0
      tcov_call_tcov $file result

      incr result($node,blocks) $result($file,blocks)
      incr result($node,blocks_executed) $result($file,blocks_executed)
   }
}

## @brief Calls the tcov utility for a single source code file
#
# This function runs the `tcov` utility on a specified source code file to
# generate coverage data. It initializes the result array with the file name,
# error status, and the number of blocks and executed blocks. It constructs the
# command to run `tcov` with the total profile file and the output file name.
# If the command executes successfully, it reads the output file to extract
# the number of blocks and executed blocks from the coverage report.
# If there is an error during execution, it logs the error output to the
# output file and sets the error status in the result array.
# The function uses the `start_remote_prog` utility to execute the `tcov`
# command on the local host, ensuring that the coverage data is generated
# in the correct directory structure.
# The results are stored in the specified result variable, which is a TCL
# array containing the file name, error status, number of blocks, and
# executed blocks.
#
# @param file       The name of the source code file to analyze.
# @param result_var The name of a TCL array to store the coverage information.
#
proc tcov_call_tcov {file result_var} {
   global CHECK_USER
   global CHECK_COVERAGE CHECK_COVERAGE_DIR CHECK_PROTOCOL_DIR

   upvar $result_var result

   set local_host [gethostname]
   set result($file,error) 0
   set result($file,blocks) 0
   set result($file,blocks_executed) 0

   set profile "$CHECK_COVERAGE_DIR/total.profile"
   set tcovfile "$CHECK_PROTOCOL_DIR/coverage/${file}.txt"
   set tcovdir [file dirname $tcovfile]
   if {![file isdirectory $tcovdir]} {
      file mkdir $tcovdir
   }
   if {[file exists $tcovfile]} {
      file delete $tcovfile
   }
   set CHECK_COVERAGE "none"
   set output [start_remote_prog $local_host $CHECK_USER [get_binary_path $local_host "tcov"] "-x $profile -o $tcovfile $file"]
   set CHECK_COVERAGE "tcov"
   if {$prg_exit_state == 0} {
      ts_log_progress FINE "+"
      set f [open $tcovfile "r"]
      while {[gets $f line] >= 0} {
         switch -glob -- $line {
            "*Basic blocks in this file*" {
               set result($file,blocks) [lindex [string trim $line] 0]
            }
            "*Basic blocks executed*" {
               set result($file,blocks_executed) [lindex [string trim $line] 0]
            }
         }
      }
      close $f
   } else {
      ts_log_progress FINE "-"
      set result($file,error) 1
      set f [open $tcovfile "a+"]
      puts $f "================================================================================"
      puts $f "------------------------- tcov error output ------------------------------------"
      puts $f $output
      puts $f "================================================================================"
      close $f
   }
}

