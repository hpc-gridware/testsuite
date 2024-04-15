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
proc clear_version_info {} {
   global g_rel_info
   unset -nocomplain g_rel_info
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

proc get_version_info {{version_information_array_name ""}} {
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
      set qconf_host [host_conf_get_suited_hosts]
      set qconf_host_arch [resolve_arch $qconf_host]
      set qconf_bin $ts_config(product_root)/bin/$qconf_host_arch/qconf

      if {[file isfile $qconf_bin]} {
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
         if {[file isfile $install_master_file]} {
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

   return $CHECK_PRODUCT_VERSION_NUMBER
}

###
# @brief check if the current OGE version is in a given range
#
# The OGE version must be higher or equal the from_version
# and (optionally) lower than the to_version.
# @example if the current version is 9.0.0 then
#          "is_version_in_range 8.0.0" will return 1
# @see also test_version_in_range()
#
# @param[in] from_version
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
# @brief check if a given version is between a start version (inclusive)
#        and an end version (exclusive)
##
proc check_version_in_range {current_version from_version to_version} {
   set ret 1

   parse_version_info $current_version current

   if {$from_version != ""} {
      parse_version_info $from_version from
      if {$current(major_release) < $from(major_release)} {
         set ret 0
      } elseif {$current(major_release) == $from(major_release)} {
          if {$current(minor_release) < $from(minor_release)} {
            set ret 0
         } elseif {$current(minor_release) == $from(minor_release)} {
            if {$current(update_release) < $from(minor_release)} {
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
            if {$current(update_release) > $to(update_release)} {
               set ret 0
            }
         }
      }
   }

   # ts_log_fine "check_version_in_range $current_version $from_version $to_version returning $ret"

   return $ret
}

###
# @brief test function for is_version_in_range()
##
proc test_version_in_range {} {
   set scenarios {}
   lappend scenarios {"9.0.1" "8.0.0" "" 1}
   lappend scenarios {"9.0.1" "9.0.1" "" 1}
   lappend scenarios {"9.0.1" "9.1.0" "" 0}
   lappend scenarios {"9.0.1" "" "8.7.0" 0}
   lappend scenarios {"9.0.1" "9.0.0" "9.5.0" 1}

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
