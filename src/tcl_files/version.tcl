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
#  Portions of this software are Copyright (c) 2023-2024,2026 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

#                                                             max. column:     |
#
#****** version/ts_source() ******
#  NAME
#     ts_source() -- get testsuite internal version number for product
#
#  SYNOPSIS
#     ts_source {filebase {extension tcl}}
#
#  FUNCTION
#     This function sources a tclfile named by filebase and extension.
#     It will first source a version independent file (if it exists) and
#     then a version dependent file.
#
#     It will check if the following files exist, and source them:
#        $filebase.$extension
#        $filebase.$ts_config(gridengine_version).$extension
#
#  INPUTS
#     filebase  - filename without extension, e.g. tcl_files/version
#     extension - extension, e.g. "tcl" or "ext", default "tcl"
#
#  RESULT
#     1 on success, else 0
#
#  SEE ALSO
#*******************************
#
proc ts_source {filebase {extension tcl}} {
   global ts_config

   set sourced 0
   # suppress warnings when testsuite tries to resource some files
   if {[string first "not in testmode" $filebase] != -1} {
      return $sourced
   }

   # we need a testsuite config before sourcing files
   if {![info exists ts_config] || ![info exists ts_config(gridengine_version)]} {
      ts_log_severe "can't source version specific files before knowing the version"
   } else {
      # read a version independent file first, then the version dependent
      set version $ts_config(gridengine_version)
      set filename "${filebase}.${extension}"
      if {[file exists $filename]} {
         ts_log_finest "reading file $filename"
         set time_now [timestamp]
         uplevel source $filename
         set time_after [timestamp]
         set source_time [expr $time_after - $time_now]
         if { $source_time > 5 } {
            ts_log_info "sourcing $filename took $source_time!"
         }
         incr sourced
      }

      if { $version != "" } {
         set major [string index $version 0]
         set minor [string index $version 1]

         for {set i 0} {$i <= $minor} {incr i} {
            set filename "${filebase}.${major}${i}.${extension}"
            if {[file exists $filename]} {
               ts_log_finest "reading version specific file $filename"
               set time_now [timestamp]
               uplevel source $filename
               set time_after [timestamp]
               set source_time [expr $time_after - $time_now]
               if { $source_time > 5 } {
                  ts_log_info "sourcing $filename took $source_time!"
               }
               incr sourced
            }
         }
      }
   }

   if {$sourced == 0} {
      ts_log_finest "no files sourced for filename \"$filebase.*\""
   }

   return $sourced
}

#****** version/get_version_info() *********************************************
#  NAME
#     get_version_info() -- get version number of the cluster software
#
#  SYNOPSIS
#     get_version_info { {version_information_array_name} }
#
#  FUNCTION
#     This procedure will return the version string. The optional parameter
#     version_information_array_name is used to upvar a variable name and set additional
#     release informations.
#     Following array names are set:
#       - version_information_array_name(major_release)    e.g. "6"
#       - version_information_array_name(minor_release)    e.g. "2"
#       - version_information_array_name(update_release)   e.g. "3"
#       - version_information_array_name(full)             e.g. "GE 6.2u3beta"
#       - version_information_array_name(detected_version) e.g. "6.2u3"
#
#       - version_information_array_name(major_release)    e.g. "8"
#       - version_information_array_name(minor_release)    e.g. "0"
#       - version_information_array_name(update_release)   e.g. "0"
#       - version_information_array_name(full)             e.g. "GE 8.0.0 beta"
#       - version_information_array_name(detected_version) e.g. "8.0.0"
#
#
#  INPUTS
#     {version_information_array_name} - optional: upvar variable for setting release info
#
#  RESULT
#     Version string e.g. "GE 8.0.0 beta" or "0.0" if it is not possible to
#     get the version string.
#*******************************************************************************

# cache release info
# g_rel_info(major_release)      - 8
# g_rel_info(minor_release)      - 1
# g_rel_info(update_release)     - 2
# g_rel_info(full)               - GE 8.1.2 (this is what qconf reports)
# g_rel_info(detected_version)   - 8.1.2
global g_rel_info
unset -nocomplain g_rel_info
proc clear_version_info {{wait_for_nfs 0}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   # Clear the cache.
   global g_rel_info
   unset -nocomplain g_rel_info

   # When retrieving the version info to fill the cache again,
   # we call qconf -help or inst_sge -v.
   # Make sure at least one of them is available.
   # We call qconf/inst_sge on the master host, wait for qconf for the master arch.
   if {$wait_for_nfs} {
      set qconf_host $ts_config(master_host)
      set qconf_host_arch [resolve_arch $qconf_host]
      set qconf_bin $ts_config(product_root)/bin/$qconf_host_arch/qconf

      if {[wait_for_remote_file $qconf_host $CHECK_USER $qconf_bin 60 0] != 0} {
         set install_master_file "$ts_config(product_root)/inst_sge"
         if {[wait_for_remote_file $qconf_host $CHECK_USER $install_master_file 60 0] != 0} {
            ts_log_severe "neither $qconf_bin nor $install_master_file is available on host $qconf_host"
         }
      }
   }
}

proc parse_version_info {version_string {version_information_array_name ""}} {
   upvar $version_information_array_name rel_info

   # e.g. "GE 6.2u3beta"
   set help [split $version_string "."]
   set major_help [lindex $help 0]
   set rel_info(major_release) "0"

   # strip GE from major version
   foreach str [split $major_help " "] {
      if {[string is integer $str]} {
         set rel_info(major_release) [string trim $str]
      }
   }

   # distinguish old version scheme 6.2u5
   # from new one 8.0.0
   if {[llength $help] > 2} {
      # new Univa versioning scheme
      set rel_info(minor_release) [lindex $help 1]
      set update_help [lindex $help 2]
      set up_rel ""
      for {set i 0} {$i < [string length $update_help]} {incr i 1} {
         set char [string index $update_help $i]
         if {[string is integer $char]} {
            append up_rel $char
         } else {
            break
         }
         if {$up_rel == ""} {
            set up_rel 0
         }
      }
      set rel_info(update_release) $up_rel
      set rel_info(full) $version_string
      set rel_info(detected_version) "$rel_info(major_release).$rel_info(minor_release).$rel_info(update_release)"
   } else {
      # old Sun versioning scheme
      # split minor version from patch number: "2u5"
      set minor_help [lindex $help 1]
      set help [split $minor_help "u"]
      set rel_info(minor_release) [string trim [lindex $help 0]]
      if {[llength $help] > 1} {
         set update_help [lindex $help 1]  ;# "3beta"
         set up_rel ""
         for {set i 0} {$i < [string length $update_help]} {incr i 1} {
            set char [string index $update_help $i]
            if {[string is integer $char]} {
               append up_rel $char
            } else {
               break
            }
         }
         if {$up_rel == ""} {
            set up_rel 0
         }
      } else {
         set up_rel 0
      }
      set rel_info(update_release) $up_rel
      set rel_info(full) $version_string
      if { $up_rel == 0 } {
         set rel_info(detected_version) "$rel_info(major_release).$rel_info(minor_release)"
      } else {
         set rel_info(detected_version) "$rel_info(major_release).$rel_info(minor_release)u$rel_info(update_release)"
      }
   }
}

## @brief get the Cluster Scheduler (Grid Engine) version
#
# This procedure tries to get the Cluster Scheduler (Grid Engine) version
# in different ways:
# 1) from global variable g_rel_info if already parsed
# 2) by starting "qconf -help" on the qmaster host and parsing the first line of output
# 3) by starting the install script with "-v" option
#
# If the caller requests detailed release info, it is copied from the
# global cache g_rel_info into the array given by version_information_array_name.
#
# @param[in] optional version_information_array_name - name of array to copy detailed
#            release info into
# @param[in] optional do_cleanup - if 1 then cleanup version string
#            (replace spaces by underscores and cut off build number in parentheses)
# @return version string
#
proc get_version_info {{version_information_array_name ""} {do_cleanup 0}} {
   get_current_cluster_config_array ts_config
   global g_rel_info
   global CHECK_PRODUCT_VERSION_NUMBER
   global CHECK_PRODUCT_TYPE CHECK_USER

   if {[info exists g_rel_info] && $g_rel_info(major_release) > 0} {
      set CHECK_PRODUCT_VERSION_NUMBER $g_rel_info(full)
   } else {
      set CHECK_PRODUCT_VERSION_NUMBER "n.a."
   }

   if {[info exists ts_config(product_root)] != 1} {
      set CHECK_PRODUCT_VERSION_NUMBER "testsuite configuration not initialized"
      return $CHECK_PRODUCT_VERSION_NUMBER
   }

   # if we do not yet know the version, try to get it via qconf -help
   if {$CHECK_PRODUCT_VERSION_NUMBER == "n.a."} {
      set qconf_host $ts_config(master_host)
      set qconf_host_arch [resolve_arch $qconf_host]
      set qconf_bin $ts_config(product_root)/bin/$qconf_host_arch/qconf

      if {[is_remote_file $qconf_host $CHECK_USER $qconf_bin]} {
         set result [start_remote_prog $qconf_host $CHECK_USER $qconf_bin "-help" prg_exit_state 15 0 "" "" 1 1 0 1]
         set help [split $result "\n"]
         if {([string first "fopen" [ lindex $help 0]]        >= 0) ||
             ([string first "error" [ lindex $help 0]]        >= 0) ||
             ([string first "product_mode" [ lindex $help 0]] >= 0)} {
             ts_log_finer "cannot get version starting qconf -help!"
         } else {
            set CHECK_PRODUCT_VERSION_NUMBER [string trim [lindex $help 0]]
            if {[string first "exit" $CHECK_PRODUCT_VERSION_NUMBER ] >= 0} {
               ts_log_finer "output of qconf -help contains \"exit\"! Output: \"$CHECK_PRODUCT_VERSION_NUMBER\""
               set CHECK_PRODUCT_VERSION_NUMBER "n.a."
            }
         }
      }

      #  try to get version from install script
      if {$CHECK_PRODUCT_VERSION_NUMBER == "n.a."} {
         set install_master_file "$ts_config(product_root)/inst_sge"
         if {[is_remote_file $qconf_host $CHECK_USER $install_master_file]} {
            set result [start_remote_prog $qconf_host $CHECK_USER $install_master_file "-v" prg_exit_state 15 0 $ts_config(product_root)]
            if {$prg_exit_state == 0} {
               set CHECK_PRODUCT_VERSION_NUMBER [string trim [lindex [split $result ":"] 1]]
            } else {
               set CHECK_PRODUCT_VERSION_NUMBER "0.0"
            }
         } else {
            set CHECK_PRODUCT_VERSION_NUMBER "0.0"
         }
      }

      parse_version_info $CHECK_PRODUCT_VERSION_NUMBER g_rel_info
   }

   # caller requested detailed release info - copy from global cache
   if {$version_information_array_name != ""} {
      upvar $version_information_array_name rel_info
      foreach name [array names g_rel_info] {
         set rel_info($name) $g_rel_info($name)
      }
   }

   set version $CHECK_PRODUCT_VERSION_NUMBER

   # cleanup version string
   if {$do_cleanup == 1} {

      # optionally replace spaces in version string by underscore
      regsub -all { } $version "_" version

      # cut off build number enclosed in parentheses
      set bracket_pos [string first "(" $version]
      if {$bracket_pos != -1} {
         set version [string range $version 0 [expr $bracket_pos - 2]]
      }
   }

   return $version
}

###
# @brief check if the current Cluster Scheduler (Grid Engine) version is in a given range
#
# The Cluster Scheduler (Grid Engine) version must be higher or equal the from_version
# and (optionally) lower than the to_version.
# @example if the current version is 9.0.0 then
#          "is_version_in_range 8.0.0" will return 1
#
# Both versions may name one version per release branch, which is what a change that
# was merged into several branches needs:
# @example "is_version_in_range "9.0.14 9.1.6"" is true for 9.0.14 and later on
#          V90_BRANCH, for 9.1.6 and later on V91_BRANCH, and for everything from
#          9.2.0 on, but not for 9.0.13 and not for 9.1.5
# @see also version_select_for_branch(), test_version_in_range()
#
# @param[in] from_version one version, or one version per release branch
# @param[in] optional to_version, if not given (value "") then
#            the range is open to the right.
# @return 1 if the version is in the given range, else 0
##
proc is_version_in_range {from_version {to_version ""}} {
   # get the current product version
   set current_version [get_version_info]

   # we put the following into a separate function for ease of testing
   return [check_version_in_range $current_version $from_version $to_version]
}

###
# @brief check if the current Cluster Scheduler (Grid Engine) version is in a range given as list
#
# Calls is_version_in_range with the one or two arguments given as list.
# @example if the current version is 9.0.0 then
#          is_version_in_range_list {"8.0.0"} or
#          is_version_in_range_list {"8.0.0" ""} or
#          is_version_in_range_list {"8.0.0" "10.0.0"}
#          will all return 1
#
# Each of the two elements may name one version per release branch, e.g.
#          is_version_in_range_list {"9.0.14 9.1.6" ""}
# for a change which went into 9.0.14 and into 9.1.6, see version_select_for_branch().
#
# @param[in] the version range as list
# @return 1 if the version is in the given range, else 0
##
proc is_version_in_range_list {range_list} {
   set from [lindex $range_list 0]
   if {[llength $range_list] > 1} {
      set to [lindex $range_list 1]
   } else {
      set to ""
   }

   return [is_version_in_range $from $to]
}


###
# @brief pick the entry of a per branch version list which applies to a version
#
# A version list may name one version per release branch, e.g. "9.0.14 9.1.6" for a
# change which went into 9.0.14 on V90_BRANCH and into 9.1.6 on V91_BRANCH. This
# function returns the entry which has to be compared against the given version:
#   - the entry of the same release branch (same major and minor release), if there
#     is one,
#   - else the newest entry of an older branch - a later branch inherits what an
#     earlier one got, so "9.0.14 9.1.6" also covers 9.2.0,
#   - else, when every entry belongs to a later branch, the oldest entry, so that
#     the comparison puts the version outside of the range.
#
# A single version, an empty string, and anything which does not look like a list of
# versions (e.g. the old "GE 6.2u5") are returned unchanged.
#
# @param[in] version_list one or more versions, e.g. "9.0.14 9.1.6"
# @param[in] version_info_array_name name of an array as filled by parse_version_info
# @return the version to compare against
# @see also test_version_in_range()
##
proc version_select_for_branch {version_list version_info_array_name} {
   upvar $version_info_array_name current

   # nothing to select from
   if {[llength $version_list] < 2} {
      return $version_list
   }

   # only a list of plain versions is treated as a per branch list - a single version
   # string may well contain a blank, e.g. "GE 6.2u5"
   foreach version $version_list {
      if {![regexp {^[0-9]+\.[0-9]} $version]} {
         return $version_list
      }
   }

   set current_branch [expr {$current(major_release) * 1000 + $current(minor_release)}]

   set selected ""
   set selected_branch -1
   set oldest ""
   set oldest_branch -1

   foreach version $version_list {
      parse_version_info $version entry
      set branch [expr {$entry(major_release) * 1000 + $entry(minor_release)}]

      if {$oldest_branch < 0 || $branch < $oldest_branch} {
         set oldest_branch $branch
         set oldest $version
      }

      # the newest entry which is not newer than the branch we are asked about
      if {$branch <= $current_branch && $branch > $selected_branch} {
         set selected_branch $branch
         set selected $version
      }
   }

   if {$selected ne ""} {
      return $selected
   }
   return $oldest
}

###
# @brief check if a given version is between a start version (inclusive)
#        and an end version (exclusive)
#
# from_version and to_version may each name one version per release branch,
# see version_select_for_branch().
##
proc check_version_in_range {current_version from_version to_version} {
   set ret 1

   parse_version_info $current_version current

   # a per branch version list is reduced to the entry which applies here
   set from_version [version_select_for_branch $from_version current]
   set to_version [version_select_for_branch $to_version current]

   if {$from_version != ""} {
      parse_version_info $from_version from
      if {$current(major_release) < $from(major_release)} {
         set ret 0
      } elseif {$current(major_release) == $from(major_release)} {
          if {$current(minor_release) < $from(minor_release)} {
            set ret 0
         } elseif {$current(minor_release) == $from(minor_release)} {
            if {$current(update_release) < $from(update_release)} {
               set ret 0
            }
         }
      }
   }

   if {$ret && $to_version != ""} {
      parse_version_info $to_version to
      if {$current(major_release) > $to(major_release)} {
         set ret 0
      } elseif {$current(major_release) == $to(major_release)} {
         if {$current(minor_release) > $to(minor_release)} {
            set ret 0
         } elseif {$current(minor_release) == $to(minor_release)} {
            if {$current(update_release) >= $to(update_release)} {
               set ret 0
            }
         }
      }
   }

   return $ret
}

###
# @brief test function for is_version_in_range()
##
proc test_version_in_range {} {
   set scenarios {}
   lappend scenarios {"GE 9.0.0prealpha" "9.0.1" "" 0}
   lappend scenarios {"9.0.1" "8.0.0" "" 1}
   lappend scenarios {"9.0.1" "9.0.1" "" 1}
   lappend scenarios {"9.0.1" "9.1.0" "" 0}
   lappend scenarios {"9.0.1" "" "8.7.0" 0}
   lappend scenarios {"9.0.1" "9.0.0" "9.5.0" 1}
   lappend scenarios {"9.0.0" "" "9.0.0" 0}

   # a version list names one version per release branch, for a change which was
   # merged into more than one branch - here into 9.0.14 and into 9.1.6
   lappend scenarios {"9.0.13" "9.0.14 9.1.6" "" 0}
   lappend scenarios {"9.0.14" "9.0.14 9.1.6" "" 1}
   lappend scenarios {"9.0.20" "9.0.14 9.1.6" "" 1}
   lappend scenarios {"9.1.5" "9.0.14 9.1.6" "" 0}
   lappend scenarios {"9.1.6" "9.0.14 9.1.6" "" 1}
   # a branch which is newer than every entry of the list inherits the change
   lappend scenarios {"9.2.0" "9.0.14 9.1.6" "" 1}
   # a branch which is older than every entry of the list does not have it
   lappend scenarios {"8.9.9" "9.0.14 9.1.6" "" 0}
   # the order of the entries does not matter
   lappend scenarios {"9.1.5" "9.1.6 9.0.14" "" 0}
   lappend scenarios {"9.0.14" "9.1.6 9.0.14" "" 1}

   # the same for the end of the range, which is exclusive
   lappend scenarios {"9.0.19" "" "9.0.20 9.1.10" 1}
   lappend scenarios {"9.0.20" "" "9.0.20 9.1.10" 0}
   lappend scenarios {"9.1.9" "" "9.0.20 9.1.10" 1}
   lappend scenarios {"9.1.10" "" "9.0.20 9.1.10" 0}
   lappend scenarios {"9.2.0" "" "9.0.20 9.1.10" 0}
   lappend scenarios {"8.9.9" "" "9.0.20 9.1.10" 1}

   # a version list on both sides
   lappend scenarios {"9.0.13" "9.0.14 9.1.6" "9.0.20 9.1.10" 0}
   lappend scenarios {"9.0.14" "9.0.14 9.1.6" "9.0.20 9.1.10" 1}
   lappend scenarios {"9.0.20" "9.0.14 9.1.6" "9.0.20 9.1.10" 0}
   lappend scenarios {"9.1.5" "9.0.14 9.1.6" "9.0.20 9.1.10" 0}
   lappend scenarios {"9.1.6" "9.0.14 9.1.6" "9.0.20 9.1.10" 1}
   lappend scenarios {"9.1.10" "9.0.14 9.1.6" "9.0.20 9.1.10" 0}

   # a version list with a prealpha version of the branch it names
   lappend scenarios {"GE 9.1.6prealpha" "9.0.14 9.1.6" "" 1}

   # the shepherd/wrapper check: fixed in 9.0.12 and in 9.1.1
   lappend scenarios {"9.0.11" "9.0.12 9.1.1" "" 0}
   lappend scenarios {"9.0.12" "9.0.12 9.1.1" "" 1}
   lappend scenarios {"9.1.0" "9.0.12 9.1.1" "" 0}
   lappend scenarios {"9.1.1" "9.0.12 9.1.1" "" 1}

   # a list may name as many branches as needed
   lappend scenarios {"9.0.11" "9.0.12 9.1.1 9.2.3" "" 0}
   lappend scenarios {"9.1.0" "9.0.12 9.1.1 9.2.3" "" 0}
   lappend scenarios {"9.2.2" "9.0.12 9.1.1 9.2.3" "" 0}
   lappend scenarios {"9.2.3" "9.0.12 9.1.1 9.2.3" "" 1}
   lappend scenarios {"9.3.0" "9.0.12 9.1.1 9.2.3" "" 1}

   foreach scenario $scenarios {
      set current [lindex $scenario 0]
      set from [lindex $scenario 1]
      set to [lindex $scenario 2]
      set expected [lindex $scenario 3]

      if {[check_version_in_range $current $from $to] != $expected} {
         puts "ERROR: check_version_in_range $current $from $to should have reported $expected"
      } else {
         puts "OK:    check_version_in_range $current $from $to reported $expected"
      }
   }
}
