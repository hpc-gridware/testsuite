#!/vol2/TCL_TK/glinux/bin/tclsh
# expect script
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
##########################################################################
#___INFO__MARK_END__

global macro_messages_list

#                                                             max. column:     |
#****** gettext_procedures/test_file() ******
#
#  NAME
#     test_file -- test procedure
#
#  SYNOPSIS
#     test_file { me two }
#
#  FUNCTION
#     this function is just for test the correct function call
#
#  INPUTS
#     me  - first output parameter
#     two - second output parameter
#
#  RESULT
#     output to stdout:
#
#  EXAMPLE
#     ???
#
#  NOTES
#     ???
#
#  BUGS
#     ???
#
#  SEE ALSO
#     ???/???
#*******************************
proc test_file { me two} {
  ts_log_fine "printing \"$me\" \"$two\". host is [exec hostname]"
  return "test ok"
}

#****** gettext_procedures/diff_macro_files() **********************************
#  NAME
#     diff_macro_files() -- diff 2 testsuite message macro dump files
#
#  SYNOPSIS
#     diff_macro_files { file_a file_b { ignore_backslash_at_end 1 } }
#
#  FUNCTION
#     This function will check if all message macros from file_a are contained
#     in file_b and compare the message text. The testsuite is creating the
#     dump files in the results/protocols directory when the compile option
#     is used.
#
#  INPUTS
#     file_a                        - testsuite message dump file A
#     file_b                        - testsuite message dump file B
#     { ignore_backslash_at_end 1 } - if 1 (default) backslashes at end of a
#                                     macro are ignored
#
#  RESULT
#     0 - success without errors or warnings
#     1 - there where compare errors
#     2 - there where no compare errors, but some macros wasn't found in
#         file_b (new macros).
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc diff_macro_files { file_a file_b { ignore_backslash_at_end 1 } } {
   ts_log_fine "reading $file_a ..."
   read_array_from_file $file_a "macro_messages_list" macros_1 1
   ts_log_fine "ok                               "
   ts_log_fine "messages are from $macros_1(source_code_directory)"


   ts_log_fine "reading $file_b ..."
   read_array_from_file $file_b "macro_messages_list" macros_2 1
   ts_log_fine "ok                               "
   ts_log_fine "messages are from $macros_2(source_code_directory)"

   set macros_1_macro_names {}
   for {set i 1} {$i <= $macros_1(0) } {incr i 1} {
# ,id
# ,macro
# ,string
# ,file
# ,message_id
# source_code_directory
#      ts_log_fine "id:         $macros_1($i,id)"
#      ts_log_fine "macro:      $macros_1($i,macro)"
#      ts_log_fine "string:     $macros_1($i,string)"
#      ts_log_fine "-"
      lappend macros_1_macro_names $macros_1($i,macro)
   }
   set macros_2_macro_names {}
   for {set i 1} {$i <= $macros_2(0) } {incr i 1} {
      lappend macros_2_macro_names $macros_2($i,macro)
   }



   ts_log_fine "$file_a has [llength $macros_1_macro_names] macro entries!"
   ts_log_fine "$file_b has [llength $macros_2_macro_names] macro entries!"
   set not_found {}
   set compare_error {}
   set runs [llength $macros_1_macro_names]
   foreach macro $macros_1_macro_names {
      set found 0
      foreach help $macros_2_macro_names {
         if { $help == $macro} {
            set found 1
            # ok macro exists, check content
            for {set i 1} {$i <= $macros_1(0) } {incr i 1} {
               if { $macros_1($i,macro) == $macro } {
                  set macro_1_string $macros_1($i,string)
               }
            }
            for {set i 1} {$i <= $macros_2(0) } {incr i 1} {
               if { $macros_2($i,macro) == $macro } {
                  set macro_2_string $macros_2($i,string)
               }
            }

            if { $ignore_backslash_at_end != 0 } {
               set len [string length $macro_2_string]
               if {[string range $macro_2_string [expr $len -2] [expr $len -1]] == "\\n" } {
                  set str_length [string length $macro_2_string]
                  incr str_length -3
                  set new_string [string range $macro_2_string 0 $str_length]

               } else {
                  set new_string [string range $macro_2_string 0 end]
               }
            } else {
               set new_string [string range $macro_2_string 0 end]
            }

            if { $new_string != $macro_1_string } {
               lappend compare_error $macro
               ts_log_newline
               ts_log_fine "error for macro $macro:"
               ts_log_fine "$file_a:"
               ts_log_fine "\"$macro_1_string\""
               ts_log_fine "$file_b:"
               ts_log_fine "\"$new_string\""
            } else {

            }
         }
      }
      if { $found == 0 } {
         # macro not found in file 2
         lappend not_found $macro
      }
      ts_log_progress FINER "\rtodo: $runs                     "
      incr runs -1
   }

   set had_errors 0
   set new_macros 0

   ts_log_fine "\n\nfollowing macros from \n\"$file_a\"\n are not in \n\"$file_b\""
   foreach not_found_macro $not_found {
      incr new_macros 1
      ts_log_fine $not_found_macro
   }

   ts_log_fine "\nfollowing macros from \n\"$file_a\"\n had compare errors \n\"$file_b\""
   foreach error $compare_error {
      incr had_errors 1
      ts_log_fine $error
   }
   ts_log_fine "Comparison reported $had_errors errors!"
   ts_log_fine "Comparison reported $new_macros not found (new) message macros!"

   if { $had_errors != 0 } {
      return 1
   }

   if { $new_macros != 0 } {
      return 2
   }

   return 0
}

#****** gettext_procedures/is_macro_available() ********************************
#  NAME
#     is_macro_available() -- check if macro is existing
#
#  SYNOPSIS
#     is_macro_available { macro_name } 
#
#  FUNCTION
#     Figure out if the specified macro is available.
#
#  INPUTS
#     macro_name - name of the source code macro
#
#  RESULT
#     true or false
#*******************************************************************************
proc is_macro_available { macro_name } {
   set result [sge_macro $macro_name 0]
   if {$result == -1 || $result == ""} {
      return false
   }
   return true
}


proc get_macro_messages_file_name { } {
  global CHECK_PROTOCOL_DIR ts_config

  ts_log_fine "checking messages file ..."
  if { [ file isdirectory $CHECK_PROTOCOL_DIR] != 1 } {
     file mkdir $CHECK_PROTOCOL_DIR
     ts_log_fine "creating directory: $CHECK_PROTOCOL_DIR"
  }
  set release $ts_config(source_cvs_release)
  set filename $CHECK_PROTOCOL_DIR/source_code_macros_${release}.dump
  return $filename
}

proc search_for_macros_in_c_source_code_files { file_list search_macro_list} {
   global macro_messages_list

   if {[info exists macro_messages_list] == 0} {
     update_macro_messages_list
   }

   set search_list $search_macro_list

   ts_log_fine "macro count: $macro_messages_list(0)"
   foreach file $file_list {
      ts_log_finer "file: $file"
      ts_log_finer "macros in list: [llength $search_list]"
      set file_p [ open $file r ]

      set file_content ""
      while { [gets $file_p line] >= 0 } {
         append file_content $line
      }
      close $file_p
      set found ""
      foreach macro $search_list {
         if { [string first $macro $file_content] >= 0 } {
            lappend found $macro
         }
      }
      foreach macro $found {
         set index [lsearch -exact $search_list $macro]
         if { $index >= 0 } {
            set search_list [lreplace $search_list $index $index]
         }
      }
   }
   return $search_list
}

#****** gettext_procedures/check_c_source_code_files_for_macros() **************
#  NAME
#     check_c_source_code_files_for_macros() -- check if macros are used in code
#
#  SYNOPSIS
#     check_c_source_code_files_for_macros { }
#
#  FUNCTION
#     This procedure tries to find all sge macros in the source code *.c files.
#     If not all macros are found, an error message is generated.
#
#  NOTES
#     This procedure is called from update_macro_messages_list() after re-
#     parsing the source code for macros.
#
#  SEE ALSO
#     gettext_procedures/update_macro_messages_list()
#*******************************************************************************
proc check_c_source_code_files_for_macros {} {
   global macro_messages_list check_name ts_config

   ts_log_fine "check_name: $check_name"

   if { [info exists macro_messages_list] == 0 } {
     update_macro_messages_list
   }

   if {$ts_config(source_dir) == "none"} {
      ts_log_severe "source directory is set to \"none\" - cannot parse c code"
      return
   }

   set c_files ""
   set second_run_files ""

   set dirs [get_all_subdirectories $ts_config(source_dir) ]
   foreach dir $dirs {
      set files [get_file_names $ts_config(source_dir)/$dir "*.c"]
      foreach file $files {
         if { [string first "qmon" $file] >= 0 } {
            lappend second_run_files $ts_config(source_dir)/$dir/$file
            continue
         }
         if { [string first "3rdparty" $dir] >= 0 } {
            lappend second_run_files $ts_config(source_dir)/$dir/$file
            continue
         }
         lappend c_files $ts_config(source_dir)/$dir/$file
      }
      set files [get_file_names $ts_config(source_dir)/$dir "*.h"]
      foreach file $files {
         if { [string match -nocase msg_*.h $file] } {
            continue
         }
         lappend second_run_files $ts_config(source_dir)/$dir/$file
      }
   }

   set search_list ""
   for {set i 1} {$i <= $macro_messages_list(0) } {incr i 1} {
      lappend search_list $macro_messages_list($i,macro)
   }

   set search_list [search_for_macros_in_c_source_code_files $c_files $search_list ]
   set search_list [search_for_macros_in_c_source_code_files $second_run_files $search_list ]


   # remove SGE_INFOTEXT_TESTSTRING_S_L10N from searchlist
   set index [lsearch -exact $search_list "SGE_INFOTEXT_TESTSTRING_S_L10N"]
   if { $index >= 0 } {
      set search_list [lreplace $search_list $index $index]
   }

   set answer ""
   foreach macro $search_list {
      append answer "   $macro\n"
   }

   if { [llength $search_list ] > 0 } {
      set full_answer ""
      append full_answer "following macros seems not to be used in source code:\n"
      append full_answer "$ts_config(source_dir)\n\n"
      append full_answer "---------------------------------------------------------------\n"
      append full_answer $answer
      append full_answer "---------------------------------------------------------------\n"

      ts_log_info $full_answer
   }
#
# uncomment the following lines, if the unused macros should be removed from source code
# ======================================================================================
#
# --   foreach macro $search_list {
# --      set id [get_macro_id_from_name $macro]
# --      set index [get_internal_message_number_from_id $id]
# --
# --      set file $macro_messages_list($index,file)
# --      set file_ext 1
# --      ts_log_fine $macro_messages_list($index,macro)
# --      ts_log_fine $file
# --      read_file $file file_dat
# --      set lines $file_dat(0)
# --      set changed 0
# --      for { set i 1 } { $i <= $lines } { incr i 1 } {
# --         if { [ string first $macro $file_dat($i) ] >= 1 &&
# --              [ string first "_MESSAGE" $file_dat($i) ] >= 1 } {
# --            ts_log_fine $file_dat($i)
# --            set message_pos [ string first "_MESSAGE" $file_dat($i) ]
# --            set new_line "/* "
# --            incr message_pos -1
# --            append new_line [ string range $file_dat($i) 0 $message_pos]
# --            append new_line "_message"
# --            incr message_pos 9
# --            append new_line [ string range $file_dat($i) $message_pos end ]
# --            append new_line " __TS Removed automatically from testsuite!! TS__*/"
# --            ts_log_fine $new_line
# --            set file_dat($i) $new_line
# --            set changed 1
# --         }
# --      }
# --      if { $changed == 1 } {
# --         while { 1 } {
# --         set catch_return [ catch {
# --               file rename $file "$file.tmp${file_ext}"
# --         } ]
# --            incr file_ext 1
# --            ts_log_fine "catch: $catch_return"
# --            if { $catch_return == 0 } {
# --               break
# --            }
# --         }
# --         save_file $file file_dat
# --      }
# --   }
# --   ts_log_fine "macros removed"
}

proc get_source_msg_files {} {
   global ts_config

   if {$ts_config(source_dir) == "none"} {
      ts_log_severe "source directory is set to \"none\" - cannot parse c code"
      return {}
   }

   set msg_files {}
   set dirs [get_all_subdirectories $ts_config(source_dir)]
   foreach dir $dirs {
      set files [get_file_names $ts_config(source_dir)/$dir "msg_*.h"]
      foreach file $files {
         lappend msg_files $ts_config(source_dir)/$dir/$file
      }
   }

   return $msg_files
}

#****** gettext_procedures/update_macro_messages_list() ************************
#  NAME
#     update_macro_messages_list() -- parse sge source code for sge macros
#
#  SYNOPSIS
#     update_macro_messages_list { }
#
#  FUNCTION
#     This procedure reads all sge source code messages files (msg_*.h) in order
#     to get all macro strings and store it to the global variable
#     macro_messages_list.
#
#  NOTES
#     This procedure is called when the source code is updated ( procedure
#     compile_source() ) and when sge_macro() is called.
#
#  SEE ALSO
#     gettext_procedures/sge_macro()
#     check/compile_source()
#*******************************************************************************
proc update_macro_messages_list {} {
   global macro_messages_list
   global CHECK_PROTOCOL_DIR CHECK_USER
   global fast_setup ts_config

   if {[info exists macro_messages_list]} {
      unset macro_messages_list
   }

   set filename [get_macro_messages_file_name]
   ts_log_finer "checking file \"$filename\""
   if {[file isfile $filename]} {
      set update_required 0
      
      # If source code messages files (msg_*.h) have changed since we last parsed
      # them, we'll have to do an update.
      if {!$fast_setup && $ts_config(source_dir) != "none"} {
         set macro_file_tstamp [file mtime $filename]

         set msg_files [get_source_msg_files]
         foreach msg_file $msg_files {
            set tstamp [file mtime $msg_file]
            if {$tstamp > $macro_file_tstamp} {
               ts_log_fine "$msg_file has been modified"
               set update_required 1
               break
            }
            ts_log_progress
         }
      }

      if {$update_required} {
         ts_log_fine "The macro messages spool file is not up to date."
         ts_log_fine "Recreating it ..."
      } else {
         ts_log_fine "reading macro messages spool file:\n\"$filename\" ..."
         ts_log_fine "delete this file if you want to parse the macros again!"
         read_array_from_file $filename "macro_messages_list" macro_messages_list 1

         if {$ts_config(source_dir) == "none"} {
            ts_log_fine "Skip macro messages file update test. We do not have a source dir!"
            ts_log_fine "Testsuite is using macro file \"$filename\"!"
            return
         } else {
            # Verify that the messages file comes from the correct source directory.
            if {[string compare $macro_messages_list(source_code_directory) $ts_config(source_dir)] != 0} {
               ts_log_fine "source code directory from macro spool file:"
               ts_log_fine $macro_messages_list(source_code_directory)
               ts_log_fine "actual source code directory:"
               ts_log_fine $ts_config(source_dir)
               ts_log_fine "the macro spool dir doesn't match to actual source code directory."
               ts_log_fine "start parsing new source code directory ..."
               if {[info exists macro_messages_list]} {
                  unset macro_messages_list
               }
            } else {
               # File exists,
               # corresponds to the correct source directory,
               # and is up to date.
               # Fine, nothing to do.
               return
            }
         }
      }
   }

   if {$ts_config(source_dir) == "none"} {
      ts_log_fine "Testsuite config is has no source directory configured!"
      ts_log_fine "Try to get macros for cvs version \"$ts_config(source_cvs_release)\" ..."
      if {![parse_testsuite_info_file $CHECK_USER $ts_config(ge_packages_uri) rel_info]} {
         ts_log_severe "Cannot get released packages information!"
         testsuite_shutdown 1
      }
      get_version_info cur_version
      ts_log_fine "Installed version is \"$cur_version(detected_version)\""
      set messages_file ""
      for {set i 1} {$i <= $rel_info(count)} {incr i 1} {
         if { $rel_info($i,enabled) == true } {
            if {$rel_info($i,version) == $cur_version(detected_version)} {
               ts_log_fine "Found matching version: \"$rel_info($i,description)\""
               if {$rel_info($i,tag) == $ts_config(source_cvs_release)} {
                  ts_log_fine "Found matching cvs tag: \"$rel_info($i,tag)\""
                  set messages_file $rel_info($i,macro_file_uri)
                  break
               }
            }
         }
      }
      if {$messages_file == ""} {
         ts_log_severe "No macro messages file available!"
         testsuite_shutdown 1
      }
      set copy_host [get_uri_hostname $messages_file]
      set copy_path [get_uri_path $messages_file]

      ts_log_fine "${copy_host}($CHECK_USER): Copy messages file \"$copy_path\" to \"$filename\" ..."
      delete_remote_file $copy_host $CHECK_USER $filename

      set output [start_remote_prog $copy_host $CHECK_USER "cp" "$copy_path $filename"]
      ts_log_fine $output
      if {$prg_exit_state != 0} {
         ts_log_severe "${copy_host}($CHECK_USER): Cannot copy messages file \"$copy_path\" to \"$filename\"!" 
         testsuite_shutdown 1
      }
      wait_for_remote_file [gethostname] $CHECK_USER $filename
      read_array_from_file $filename "macro_messages_list" macro_messages_list 1
      return
   }

   set error_text ""
   set msg_files [get_source_msg_files]

   ts_log_fine "parsing the following messages files:"
   foreach file $msg_files {
      ts_log_fine $file
   }

  set count 1
  ts_log_fine "\nparsing source code for message macros ..."
  foreach file $msg_files {
     ts_log_finer "file: $file"
     set file_p [ open $file r ]
     while { [gets $file_p line] >= 0 } {
        if { [string first "_MESSAGE(" $line] >= 0 } {
           set org_line $line
           set line [replace_string $line "SFQ" "\"\\\"%-.100s\\\"\""]
           set line [replace_string $line "SFN2" "\"%-.200s\""]
           set line [replace_string $line "SFN" "\"%-.100s\""]
           set line [replace_string $line "sge_U32CFormat" "\"%ld\""]
           set line [replace_string $line "sge_X32CFormat" "\"%lx\""]
           set line [replace_string $line "U32CFormat" "\"%ld\""]
           set line [replace_string $line "X32CFormat" "\"%lx\""]
           set line [replace_string $line "SN_UNLIMITED" "\"%s\""]
           set line [replace_string $line "_(SGE_INFOTEXT_TESTSTRING_S)" "_(\"Welcome, %s\\nhave a nice day!\\n\")"]
           set line [replace_string $line "_(SGE_INFOTEXT_UNDERLINE)" "_(\"-\""]

           set line [replace_string $line "\\\"" "___01815DUMMY___"]
           set got_error 0
           while { [ set old [replace_string $line "\"" "" 1]] != 2 } {
              set index [string first "\"" $line ]
              set new_line [ string range $line 0 $index ]
              incr index 1
              set help [ string range $line $index end ]
              set index [ string first "\"" $help ]
              incr index -1
              append new_line [string range $help 0 $index]
              incr index 2
              set help [ string range $help $index end ]
              set index [ string first "\"" $help ]
              set cut [ string range $help 0 [ expr ( $index - 1) ] ]
              set cut [ string trim $cut ]
              incr index 1
              append new_line [string range $help $index end]
              set line $new_line
              set new [replace_string $line "\"" "" 1]
              if { $old == $new } {
                 ts_log_severe "error in update_macro_messages_list"
              }
              if { [string length $cut] > 0 } {
                 set unexpected_specifier $cut
                 set got_error 1
              }

           }
           set line [replace_string $line "___01815DUMMY___" "\\\"" ]

           set message_id_start [string first "_MESSAGE(" $line]
           set message_macro [ string range $line 0 [ expr ( $message_id_start - 1 ) ]]
           set help [ string range $line $message_id_start end]
           set message_id_start [string first "(" $help]
           set message_id_end   [string first "," $help]
           incr message_id_end -1
           incr message_id_start 1
           set message_id [ string range $help $message_id_start $message_id_end ]

           set message_string_start [string first "_(" $help]
           incr message_string_start 3
           set message_string [ string range $help $message_string_start end ]
           set message_string [replace_string $message_string "\\\"" "___01815DUMMY___" ]
           set message_string [replace_string $message_string "\"" "___01816DUMMY___" ]
           set message_string_end [ string first "___01816DUMMY___" $message_string ]
           incr message_string_end -1
           set message_string [ string range $message_string 0 $message_string_end]
           set message_string [ replace_string $message_string "___01815DUMMY___" "\\\""]

           set index [ string first "#define" $message_macro]
           set message_macro [ string range $message_macro [ expr ( $index + 7 ) ] end]
           set message_macro [ string trim $message_macro]

           set macro_messages_list($count)        $line
           set macro_messages_list($count,id)     $message_id
           set macro_messages_list($count,macro)  $message_macro
           set macro_messages_list($count,string) $message_string
           set macro_messages_list($count,file)   $file
           if { [ info exists macro_messages_list(0,$message_id)] != 0 } {
              append error_text "\n\n-----------MESSAGE-ID-NOT-UNIQUE----------\n"
              append error_text "message id $message_id is not unique\n"
              append error_text "$macro_messages_list(0,$message_id)\nand\n$line"
              ts_log_fine "---\nmessage id $message_id is not unique"
              ts_log_fine $macro_messages_list(0,$message_id)
              ts_log_fine "and"
              ts_log_fine $line
           }
           set macro_messages_list(0,$message_id) $line

           if { $got_error == 1 } {
               append error_text "\n\n-------UNEXPECTED-FORMAT-SPECIFIER-------\n"
               append error_text "error for message id $message_id in file \n$file:\n"
               append error_text "$org_line\nunexpected specifier: $unexpected_specifier"
               ts_log_fine "---\nerror for message id $message_id in file \n$file:\n$org_line\nunexpected specifier: -->$unexpected_specifier<--"
           }

           # check for "\n" at message end
           set len [string length $message_string]
           if {[string range $message_string [expr $len -2] [expr $len -1]] == "\\n" } {
              append error_text "\n\n-------MESSAGE-ENDS-WITH-LINEFEED-------\n"
              append error_text "message $message_id ends with a linefeed:\n$line"
              ts_log_fine "---\nmessage $message_id ends with a linefeed:\n$line"
           }

           # check for "\t" in messages
           if {[string first "\\t" $message_string] >= 0} {
              append error_text "\n\n-------MESSAGE-CONTAINS-TABS-------\n"
              append error_text "message $message_id contains tabs:\n$line"
              ts_log_fine "---\nmessage $message_id contains tabs:\n$line"
           }

           incr count 1
        }
     }
     close $file_p
  }
  if { [string compare $error_text ""] != 0 } {
     ts_log_info $error_text
  }
  incr count -1
  set macro_messages_list(0) $count
  ts_log_fine "parsed $count messages."

  ts_log_fine "saving macro file ..."

  set macro_messages_list(source_code_directory) $ts_config(source_dir)

  spool_array_to_file $filename "macro_messages_list" macro_messages_list
  check_c_source_code_files_for_macros
}

#****** gettext_procedures/get_macro_string_from_name() ************************
#  NAME
#     get_macro_string_from_name() -- get sge source code macro string from name
#
#  SYNOPSIS
#     get_macro_string_from_name { macro_name }
#
#  FUNCTION
#     This procedure returns the string defined by the given macro
#
#  INPUTS
#     macro_name - sge macro name (etc.: MSG_XXXX_S )
#
#  RESULT
#     string
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc get_macro_string_from_name { macro_name } {
  global  macro_messages_list

  if { [info exists macro_messages_list] == 0 } {
     update_macro_messages_list
  }
  for {set i 1} {$i <= $macro_messages_list(0)} {incr i 1} {
     if { [string compare $macro_name $macro_messages_list($i,macro) ] == 0 } {
#        ts_log_fine "found macro for message id $macro_messages_list($i,id)"
#        ts_log_fine "macro number is $i"
        return $macro_messages_list($i,string);
     }
  }
  return -1
}

proc get_macro_id_from_name { macro_name } {
  global  macro_messages_list

  if { [info exists macro_messages_list] == 0 } {
     update_macro_messages_list
  }
  for {set i 1} {$i <= $macro_messages_list(0)} {incr i 1} {
     if { [string compare $macro_name $macro_messages_list($i,macro) ] == 0 } {
#        ts_log_fine "found macro for message id $macro_messages_list($i,id)"
        return $macro_messages_list($i,id);
     }
  }
  return -1
}


proc get_macro_string_from_id { id } {
  global  macro_messages_list

  if { [info exists macro_messages_list] == 0 } {
     update_macro_messages_list
  }
  for {set i 1} {$i <= $macro_messages_list(0)} {incr i 1} {
     if { $id == $macro_messages_list($i,id) } {
#        ts_log_fine "found macro for message macro $macro_messages_list($i,macro)"
        return $macro_messages_list($i,string);
     }
  }
  return -1
}

proc get_internal_message_number_from_id { id } {
  global  macro_messages_list

  if { [info exists macro_messages_list] == 0 } {
     update_macro_messages_list
  }
  for {set i 1} {$i <= $macro_messages_list(0)} {incr i 1} {
     if { $id == $macro_messages_list($i,id) } {
#        ts_log_fine "found macro for message macro $macro_messages_list($i,macro)"
        return $i
     }
  }
  return -1
}



#****** gettext_procedures/translate_all_macros() ******************************
#  NAME
#     translate_all_macros() -- helper function to find out if macro is L10Ned
#
#  SYNOPSIS
#     translate_all_macros { } 
#
#  FUNCTION
#     This procedure can be used to generate a file in /tmp/unused_macros.txt
#     which contains all NOT localized message macros from GE. This is helpful
#     when checking localized po files.
#
#  INPUTS
#
#  RESULT
#     n.a.
#
#  EXAMPLE
#     expect check.exp execute_func translate_all_macros
#*******************************************************************************
proc translate_all_macros {} {
  global macro_messages_list
  global CHECK_USER ts_config
  if { [info exists macro_messages_list] == 0 } {
     update_macro_messages_list
  }
  set not_localized ""
  set max_mess $macro_messages_list(0)

  if {$ts_config(source_dir) == "none"} {
     ts_log_severe "source directory is set to \"none\" - cannot parse for macros"
     return
  }

  set parse_host [fs_config_get_server_for_path $ts_config(source_dir) 0]
  if {$parse_host == ""} {
     set parse_host [gethostname]
     ts_log_fine "using host $parse_host for parsing messages files!"
  } else {
     ts_log_fine "using NFS server host $parse_host for parsing messages files!"
  }

  file delete /tmp/unused_macros.txt
  for {set i 1} {$i <= $max_mess} {incr i 1} {
     ts_log_fine "-------$i---------------"
     set format_string $macro_messages_list($i,string)

     set localized [translate $ts_config(master_host) 0 0 1 $format_string]
     set localized [ replace_string $localized "\r" "__REP_1_DUMMY_"]
     set localized [ replace_string $localized "\t" "__REP_2_DUMMY_"]
     set localized [ replace_string $localized "\n" "__REP_3_DUMMY_"]
     set localized [ replace_string $localized "\0" "__REP_4_DUMMY_"]
     set localized [ replace_string $localized "\"" "__REP_5_DUMMY_"]
     set localized [ replace_string $localized "\\\'" "__REP_6_DUMMY_"]
     set localized [ replace_string $localized "\\" "__REP_7_DUMMY_"]



     set localized [ replace_string $localized "__REP_1_DUMMY_" ""]
     set localized [ replace_string $localized "__REP_2_DUMMY_" "\\t"]
     set localized [ replace_string $localized "__REP_3_DUMMY_" "\\n"]
     set localized [ replace_string $localized "__REP_4_DUMMY_" "\\0"]
     set localized [ replace_string $localized "__REP_5_DUMMY_" "\\\""]
     set localized [ replace_string $localized "__REP_6_DUMMY_" "\\\'"]
     set localized [ replace_string $localized "__REP_7_DUMMY_" "\\\\"]

     set localized [ string trim $localized]
     set format_string [ string trim $format_string ]
     ts_log_fine ">$format_string<"
     ts_log_fine ">$localized<"

     if { [string compare $format_string $localized] == 0 } {
        ts_log_fine "not localized"
        ts_log_fine "macro: >$macro_messages_list($i,macro)<"
        ts_log_fine "file : >$macro_messages_list($i,file)<"
        lappend not_localized $i
        set back [start_remote_prog $parse_host $CHECK_USER "grep" "$macro_messages_list($i,macro) \`find . -name \"*.\[ch\]\"\`" prg_exit_state 60 0 $ts_config(source_dir)]
        puts $back
        if { [ string first "\.c:" $back ] >= 0 } {
           ts_log_fine "used in C file !!!"
        } else {
           set f_d [open "/tmp/unused_macros.txt" "a"]
           puts $f_d "\nnot used in C-File !!!"
           puts $f_d "macro: $macro_messages_list($i,macro)"
           puts $f_d "file : $macro_messages_list($i,file)"
           close $f_d
        }
     }
  }

  set f_d [open "/tmp/unused_macros.txt" "a"]

  puts $f_d "not localized messages:"
  puts $f_d "======================="
  foreach mes $not_localized {
     puts $f_d "\nmacro  : $macro_messages_list($mes,macro)"
     puts $f_d "file   : $macro_messages_list($mes,file)"
     puts $f_d "id     : $macro_messages_list($mes,id)"
     puts $f_d "string : $macro_messages_list($mes,string)"
     puts $f_d "line   : $macro_messages_list($mes)"

  }
  close $f_d
}


proc replace_string { input_str what with {only_count 0}} {
   set msg_text $input_str
   set counter 0

   while { 1 } {
      set first [string first $what $msg_text]
      if { $first >= 0 } {
         set last $first
         incr last [string length $what]
         incr last -1
         set msg_text [ string replace $msg_text $first $last "!!__MY_PLACE_HOLDER__!!" ]
         incr counter 1
      } else {
         if { $only_count != 0 } {
            return $counter
         }
         break;
      }
   }
   while { 1 } {
      set first [string first "!!__MY_PLACE_HOLDER__!!" $msg_text]
      if { $first >= 0 } {
         set last $first
         incr last [string length "!!__MY_PLACE_HOLDER__!!"]
         incr last -1
         set msg_text [ string replace $msg_text $first $last $with ]
      } else {
         return $msg_text
      }
   }
}

#****** gettext_procedures/translate_macro() ***********************************
#  NAME
#     translate_macro() -- translate content of a certain sge messages macro
#
#  SYNOPSIS
#     translate_macro { macro {par1 ""} {par2 ""} {par3 ""} {par4 ""} {par5 ""}
#     {par6 ""} }
#
#  FUNCTION
#     Looks up the contents of a certain sge messages macro (call to sge_macro),
#     translate the message and fill in any parameters.
#
#  INPUTS
#     macro     - messages macro name
#     {par1 ""} - parameter 1
#     {par2 ""} - parameter 2
#     {par3 ""} - parameter 3
#     {par4 ""} - parameter 4
#     {par5 ""} - parameter 5
#     {par6 ""} - parameter 6
#
#  RESULT
#     Translated and formatted message.
#
#  EXAMPLE
#     translate_macro MSG_SGETEXT_CANTRESOLVEHOST_S "myhostname"
#     will return
#     can't resolve hostname "myhostname"
#
#  SEE ALSO
#     gettext_procedures/translate()
#     gettext_procedures/sge_macro()
#*******************************************************************************
proc translate_macro {macro {par1 ""} {par2 ""} {par3 ""} {par4 ""} {par5 ""} {par6 ""}} {
   get_current_cluster_config_array ts_config
   set msg [sge_macro $macro]
   set ret [translate $ts_config(master_host) 0 0 0 $msg $par1 $par2 $par3 $par4 $par5 $par6]

   return $ret
}

#****** gettext_procedures/translate_macro_if_possible() ***********************************
#  NAME
#     translate_macro_if_possible() -- translate content of a certain sge messages macro
#
#  SYNOPSIS
#     translate_macro_if_possible { macro {par1 ""} {par2 ""} {par3 ""} {par4 ""} {par5 ""}
#     {par6 ""} }
#
#  FUNCTION
#     Looks up the contents of a certain sge messages macro (call to sge_macro),
#     translate the message and fill in any parameters.
#
#  INPUTS
#     macro     - messages macro name
#     {par1 ""} - parameter 1
#     {par2 ""} - parameter 2
#     {par3 ""} - parameter 3
#     {par4 ""} - parameter 4
#     {par5 ""} - parameter 5
#     {par6 ""} - parameter 6
#
#  RESULT
#     Translated and formatted message.
#
#  EXAMPLE
#     translate_macro_if_possible MSG_SGETEXT_CANTRESOLVEHOST_S "myhostname"
#     will return
#     can't resolve hostname "myhostname"
#
#  SEE ALSO
#     gettext_procedures/translate()
#     gettext_procedures/sge_macro()
#*******************************************************************************
proc translate_macro_if_possible {macro {par1 ""} {par2 ""} {par3 ""} {par4 ""} {par5 ""} {par6 ""}} {
   get_current_cluster_config_array ts_config

   set msg [sge_macro $macro 0]
   if {$msg == -1} {
      ts_log_fine "$macro does not exist in Grid Engine $ts_config(gridengine_version)"
      set ret "$macro does not exist in Grid Engine $ts_config(gridengine_version)"
   } else {
      set ret [translate $ts_config(master_host) 1 0 0 $msg $par1 $par2 $par3 $par4 $par5 $par6]
   }

   return $ret
}

#****** gettext_procedures/translate() *****************************************
#  NAME
#     translate() -- get l10ned string
#
#  SYNOPSIS
#     translate { host remove_control_signs is_script no_input_parsing msg_txt
#     { par1 "" } { par2 ""} { par3 "" } { par4 ""} { par5 ""} { par6 ""} }
#
#  FUNCTION
#     This procedure returns the given string localized to the used language
#
#  INPUTS
#     host                 - host used for infotext call
#     remove_control_signs - if 1: remove control signs ( \n \r ...)
#     is_script            - if 1: text is from install script ( not in c source )
#     no_input_parsing     - if 1: don't try to parse input string
#     msg_txt              - text to translate
#     { par1 "" }          - paramter 1 in msg_txt
#     { par2 ""}           - paramter 2 in msg_txt
#     { par3 "" }          - paramter 3 in msg_txt
#     { par4 ""}           - paramter 4 in msg_txt
#     { par5 ""}           - paramter 5 in msg_txt
#     { par6 ""}           - paramter 6 in msg_txt
#
#  RESULT
#     localized string with optional parameters
#
#  EXAMPLE
#     set SHARETREE [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_OBJ_SHARETREE] ]
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc translate { host remove_control_signs is_script no_input_parsing msg_txt { par1 "" } { par2 ""} { par3 "" } { par4 ""} { par5 ""} { par6 ""} } {

   global CHECK_USER l10n_raw_cache l10n_install_cache
   get_current_cluster_config_array ts_config

   set msg_text $msg_txt
   if { $no_input_parsing != 1 } {
      set msg_text [replace_string $msg_text "\n" "\\n"]
      set msg_text [replace_string $msg_text "\\\"" "__QUOTE_DUMMY_"]
      set msg_text [replace_string $msg_text "\"" "\\\""]
      set msg_text [replace_string $msg_text "__QUOTE_DUMMY_" "\\\""]
   }

   set arch_string [resolve_arch $host]

   if { $is_script == 0 } {
      set msg_text [replace_string $msg_text "\\\$" "__DOLLAR_DUMMY_"]
      set msg_text [replace_string $msg_text "\$" "\\\$"]
      set msg_text [replace_string $msg_text "\\'" "'"]

      set msg_text [replace_string $msg_text "__DOLLAR_DUMMY_" "\\\$"]
      if { [ info exists l10n_raw_cache($msg_text) ] } {
          set back $l10n_raw_cache($msg_text)
          set prg_exit_state 0
      } else {
          set back [start_remote_prog $host $CHECK_USER $ts_config(product_root)/utilbin/$arch_string/infotext "-raw -__eoc__ \"$msg_text\""]
          set l10n_raw_cache($msg_text) $back
      }
      ts_log_finest "message\n\"$msg_text\" translated to\n\"$back\""
   } else {
      set num_params [ replace_string $msg_text "%s" "" 1]
      set para_num 1
      set parameter_list ""
      while { $num_params > 0 } {
         set parameter "PAR_$para_num"
         append parameter_list "$parameter "
         incr num_params -1
         incr para_num 1
      }
      if { [ info exists l10n_install_cache($msg_text) ] } {
         set back $l10n_install_cache($msg_text)
         set prg_exit_state 0
      } else {
         set back [start_remote_prog $host $CHECK_USER $ts_config(product_root)/utilbin/$arch_string/infotext "-n -__eoc__ \"$msg_text\" $parameter_list"]
         # we have line wrap and variable parameter length
         # PROBLEM: (TODO) we cannot say on which position the infotext will do a line break wrap-around
         set l10n_install_cache($msg_text) $back
      }
      ts_log_finest "message\n\"$msg_text\" translated to\n\"$back\""
   }
   if { $prg_exit_state == 0} {
      set trans_mes "$back"
      if { $remove_control_signs != 0 } {
         set trans_mes [replace_string $trans_mes "\r" ""]
         set trans_mes [replace_string $trans_mes "\n" ""]
      }
      if { $no_input_parsing != 1 } {
         set trans_mes [replace_string $trans_mes "\[" "\\\["]
         set trans_mes [replace_string $trans_mes "\]" "\\\]"]
      }

      set msg_text $trans_mes
   } else {
      ts_log_severe "gettext returned error:\n--$back\n--"
   }
   # search for %....s specifiers and replace them with parameters (%n$s)
   if { $par1 != "" } {
      set p_numb 1
      while { [set s_specifier [ string first "%" $msg_text]] >= 0 } {
         set spec_start_string [string range $msg_text $s_specifier end]
         set spec_end__string  [string first "s" $spec_start_string]
         set spec_end__decimal [string first "d" $spec_start_string]
         set spec_end__character [string first "c" $spec_start_string]
         if { $spec_end__character >= 0 } {
            if { $spec_end__character < $spec_end__decimal  } {
               set spec_end__decimal $spec_end__character
            }
         }

         if { $spec_end__string >= 0 && $spec_end__decimal >= 0 } {
            if { $spec_end__string < $spec_end__decimal } {
               set spec_end $spec_end__string
            } else {
               set spec_end $spec_end__decimal
            }
         } else {
            if { $spec_end__string >= 0 } {
               set spec_end $spec_end__string
            }
            if { $spec_end__decimal >= 0 } {
               set spec_end $spec_end__decimal
            }
         }
         set spec_string [ string range $spec_start_string 0 $spec_end]
         incr spec_end 1

         if { [string first "\$" $spec_string] >= 0 } {
            set p_numb [string range $spec_string 1 1]
         }
         incr s_specifier -1
         set new_msg_text [string range $msg_text 0 $s_specifier ]
         incr s_specifier 1
         append new_msg_text "PAR_$p_numb"
         incr spec_end $s_specifier
         append new_msg_text [string range $msg_text $spec_end end ]
         set msg_text $new_msg_text
         incr p_numb 1
      }
   }
   set msg_text [replace_string $msg_text "PAR_1" $par1]
   set msg_text [replace_string $msg_text "PAR_2" $par2]
   set msg_text [replace_string $msg_text "PAR_3" $par3]
   set msg_text [replace_string $msg_text "PAR_4" $par4]
   set msg_text [replace_string $msg_text "PAR_5" $par5]
   set msg_text [replace_string $msg_text "PAR_6" $par6]

   if { [string first "-" $msg_txt] < 0  } {
      if {[string first "-" $msg_text] >= 0} {
         ts_log_finest "---WARNING from translate macro procedure ------------------------------------"
         ts_log_finest "   translated text of string \"$msg_txt\" contains dashes(-)!"
         ts_log_finest "   Use the \"--\" option on expect pattern line when using \"$msg_text\""
         ts_log_finest "------------------------------------------------------------------------------"
      }
   }

   return $msg_text
}

#****** check/perform_simple_l10n_test() ***************************************
#  NAME
#     perform_simple_l10n_test() -- check minimal l10n settings
#
#  SYNOPSIS
#     perform_simple_l10n_test { }
#
#  FUNCTION
#     This will try to get the translated version of an message string
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc perform_simple_l10n_test { } {

   global CHECK_USER CHECK_L10N ts_host_config
   global l10n_raw_cache
   get_current_cluster_config_array ts_config

   set mem_it $CHECK_L10N


   set CHECK_L10N 0
   if { [ info exists l10n_raw_cache] } {
      unset l10n_raw_cache
   }
   set no_l10n  [translate $ts_config(master_host) 1 0 0 [sge_macro SGE_INFOTEXT_TESTSTRING_S_L10N ] " $CHECK_USER " ]
   set CHECK_L10N 1
   unset l10n_raw_cache
   set with_l10n  [translate $ts_config(master_host) 1 0 0 [sge_macro SGE_INFOTEXT_TESTSTRING_S_L10N ] " $CHECK_USER " ]

   ts_log_fine "\n------------------------------------------------------------------------\n"
   ts_log_fine $with_l10n
   ts_log_fine "------------------------------------------------------------------------"
   set CHECK_L10N $mem_it

   if { [ string compare $no_l10n $with_l10n ] == 0 } {
      ts_log_severe "localization (l10n) error:\nIs the locale directory available?"
      return -1
   }
   return 0
}

#******* qet_text_procedures/qrsh_output_contains ******************************
#
#  NAME
#     qrsh_output_contains -- checks if the qrsh output contains expected output
#
#  SYNOPSIS
#     qrsh_output_contains { output expected_output }
#
#  FUNCTION
#     Sometimes qrsh returns some additional error messages in addition to the
#     expected output. This procedure checks if the expected output line can be
#     found in the qrsh output. All lines are "trimmed" before comparison.
#
#  INPUTS
#     output          - qrsh output
#     expected_output - the expected output line
#
#  RESULT
#     1 if output contains expected_output
#     0 otherwise
#
#*******************************************************************************
proc qrsh_output_contains { output expected_output } {
   set expected_output [string trim $expected_output]
   set output [string trim $output]

   foreach line [split $output "\n"] {
      set line [string trim $line]

      if {[string compare $line $expected_output] == 0} {
         return 1
      }
   }

   return 0
}

#****** gettext_procedures/sge_macro() *****************************************
#  NAME
#     sge_macro() -- return sge macro string
#
#  SYNOPSIS
#     sge_macro { macro_name {raise_error 1} }
#
#  FUNCTION
#     This procedure returns the string defined by the macro.
#
#  INPUTS
#     macro_name  - sge source code macro
#     raise_error - if macro is not found, shall an error be raised and
#                   reparsing of messages file be triggered?
#
#  RESULT
#     string
#
#  EXAMPLE
#     set string [sge_macro MSG_OBJ_SHARETREE]
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
global warnings_already_logged
proc sge_macro { macro_name {raise_error 1} } {
   global warnings_already_logged ts_config

   set value ""

   # TODO: Remove all the "*" from the macro definitions. They should be exaclty the same like used in the
   # install scripts. First we have to solve the problem about line wrap at column 80 when the parameters (%s)
   # are responsible that the CR/LF characters might be on a different position when the parameters have variable length
   # Perhaps we should use a no automatic line wrap switch when installing in testsuite mode (set by environment variable)

   # special handling for install macros
   switch -exact $macro_name {
      "DISTINST_LICENSE_AGREEMENT" { set value "Do you agree with that license? (y/n) \[n\] >> " }
      "DISTINST_HIT_RETURN_TO_CONTINUE" { set value "\nHit <RETURN> to continue >>" }
      "DISTINST_HIT_RETURN_TO_CONTINUE_BDB_RPC" { set value "Hit <RETURN> to continue!" }
      "DISTINST_HOSTNAME_KNOWN_AT_MASTER" { set value "\nThis hostname is known at qmaster as an administrative host.\n\nHit <RETURN> to continue >>" }
      "DISTINST_CHECK_AGAIN" { set value "Check again (y/n) ('n' will abort) \[y\] >> " }
      "DISTINST_AUTO_BOOT_AT_STARTUP" { set value "Do you want to start execd automatically at machine boot?\nNOTE: If you select \"n\" SMF will be not used at all! (y/n) \[y\]" }
      "DISTINST_NOT_COMPILED_IN_SECURE_MODE" { set value "\n>sge_qmaster< binary is not compiled with >-secure< option!\n" }
      "DISTINST_ENTER_HOSTS" { set value "Host(s): " }
      "DISTINST_VERIFY_FILE_PERMISSIONS1" { set value "\nWe may now verify and set the file permissions of your Grid Engine\ndistribution.\n\nThis may be useful since due to unpacking and copying of your distribution\nyour files may be unaccessible to other users.\n\nWe will set the permissions of directories and binaries to\n\n   755 - that means executable are accessible for the world\n\nand for ordinary files to\n\n   644 - that means readable for the world\n\nDo you want to verify and set your file permissions (y/n) \[y\] >> " }
      "DISTINST_VERIFY_FILE_PERMISSIONS2" { set value "\nDid you install this version with >pkgadd< or did you already\nverify and set the file permissions of your distribution *" }
      "DISTINST_WILL_NOT_VERIFY_FILE_PERMISSIONS" { set value "We will not verify your file permissions. Hit <RETURN> to continue >>" }
      "DISTINST_DO_NOT_VERIFY_FILE_PERMISSIONS" { set value "We do not verify file permissions. Hit <RETURN> to continue >> " }
      "DISTINST_MASTER_INSTALLATION_COMPLETE" { set value "\nYour Grid Engine qmaster installation is now completed" }
      "DISTINST_ENTER_A_RANGE" { set value "Please enter a range *>> " }
      "DISTINST_PREVIOUS_SCREEN" { set value "Do you want to see previous screen about using Grid Engine again (y/n) \[n\] >> " }
      "DISTINST_FILE_FOR_HOSTLIST" { set value "Do you want to use a file which contains the list of hosts (y/n) \[n\] >> " }
      "DISTINST_FINISHED_ADDING_HOSTS" { set value "Finished adding hosts. Hit <RETURN> to continue >> " }
      "DISTINST_FILENAME_FOR_HOSTLIST" { set value "\nPlease enter the file name which contains the host list: " }
      "DISTINST_CREATE_NEW_CONFIGURATION" { set value "Do you want to create a new configuration (y/n) \[y\] >> " }
      "DISTINST_INSTALL_SCRIPT" { set value "\nWe can install the startup script that will\nstart %s at machine boot (y/n) \[y\] >> " }
      "DISTINST_ANSWER_YES" { set value "y" }
      "DISTINST_ANSWER_NO" { set value "n" }
      "DISTINST_ENTER_DEFAULT_DOMAIN" { set value "\nPlease enter your default domain >> " }
      "DISTINST_CONFIGURE_DEFAULT_DOMAIN" { set value "Do you want to configure a default domain (y/n) \[y\] >> " }
      "DISTINST_PKGADD_QUESTION" { set value "Did you install this version with >pkgadd< or did you already\nverify and set the file permissions of your distribution (y/n) \[y\] >> " }
      "DISTINST_PKGADD_QUESTION_SINCE_U3" { set value "Did you install this version with >pkgadd< or did you already verify\nand set the file permissions of your distribution (enter: y) (y/n) \[y\] >> " }
      "DISTINST_MESSAGES_LOGGING" { set value "Hit <RETURN> to see where Grid Engine logs messages >> " }
      "DISTINST_OTHER_SPOOL_DIR" { set value "Do you want to select another qmaster spool directory (y/n) \[n\] >> " }
      "DISTINST_OTHER_USER_ID_THAN_ROOT" { set value "Do you want to install Grid Engine\nunder an user id other than >root< (y/n) \[y\] >> " }
      "DISTINST_INSTALL_AS_ADMIN_USER" { set value "Do you want to install Grid Engine as admin user >%s< (y/n) \[y\] >> " }
      "DISTINST_ADMIN_USER_ACCOUNT" { set value "      admin user account = %s" }
      "DISTINST_USE_CONFIGURATION_PARAMS" { set value "\nDo you want to use these configuration parameters (y/n) \[y\] >> " }
      "DISTINST_INSTALL_GE_NOT_AS_ROOT" { set value "Do you want to install Grid Engine\nunder an user id other than >root< (y/n) \[y\] >> " }
      "DISTINST_IF_NOT_OK_STOP_INSTALLATION" { set value "Hit <RETURN> if this is ok or stop the installation with Ctrl-C >> " }
      "DISTINST_DNS_DOMAIN_QUESTION" { set value "Are all hosts of your cluster in a single DNS domain (y/n) \[y\] >> " }
      "DISTINST_SERVICE_TAGS_SUPPORT" { set value "Are you going to enable Service Tags support? (y/n) \[y\] >> " }
      "DISTINST_CHOOSE_SPOOLING_METHOD" { set value "Your SGE binaries are compiled to link the spooling libraries\nduring runtime (dynamically). So you can choose between Berkeley DB \nspooling and Classic spooling method.\nPlease choose a spooling method (berkeleydb|classic) \[%s\] >> " }
      "DISTINST_ENTER_SPOOL_DIR" { set value "Please enter a qmaster spool directory now! >>" }
      "DISTINST_ENTER_QMASTER_SPOOL_DIR" { set value "Enter a qmaster spool directory * >>" }
      "DISTINST_USING_GID_RANGE_HIT_RETURN" { set value "\nUsing >%s< as gid range. Hit <RETURN> to continue >> " }
      "DISTINST_WINDOWS_SUPPORT" { set value "\nAre you going to install Windows Execution Hosts? (y/n) \[n\] >> " }
      "DISTINST_EXECD_INSTALL_COMPLETE" { set value "Your execution daemon installation is now completed." }
      "DISTINST_LOCAL_CONFIG_FOR_HOST" { set value "Local configuration for host >%s< created." }
      "DISTINST_CELL_NAME_FOR_QMASTER" { set value "\nGrid Engine supports multiple cells.\n\nIf you are not planning to run multiple Grid Engine clusters or if you don't\nknow yet what is a Grid Engine cell it is safe to keep the default cell name\n\n   default\n\nIf you want to install multiple cells you can enter a cell name now.\n\nThe environment variable\n\n   \\\$SGE_CELL=<your_cell_name>\n\nwill be set for all further Grid Engine commands.\n\nEnter cell name \[%s\] >> " }
      "DISTINST_CELL_NAME_FOR_EXECD" { set value "\nPlease enter cell name which you used for the qmaster\ninstallation or press <RETURN> to use \[%s\] >> " }
      "DISTINST_CELL_NAME_FOR_EXECD_2" { set value "\nPlease enter cell name which you used for the qmaster\ninstallation or press <RETURN> to use default cell >default< >> " }
      "DISTINST_CELL_NAME_EXISTS" { set value "Do you want to select another cell name? (y/n) \[y\] >> " }
      "DISTINST_CELL_NAME_OVERWRITE" { set value "Do you want to overwrite \[y\] or delete \[n\] the directory? (y/n) \[y\] >> " }
      "DISTINST_GET_COMM_SETTINGS" { set value "Using a network service like >/etc/service<, >NIS/NIS+<: \[2\]\n\n(default: %s) >> " }
      "DISTINST_CHANGE_PORT_QUESTION" { set value "Do you want to change the port number? (y/n) \[n\] >> " }
      "DISTINST_ADD_DEFAULT_QUEUE" { set value "Do you want to add a default queue for this host (y/n) \[y\] >> " }
      "DISTINST_ALL_QUEUE_HOSTGROUP" { set value "Creating the default <all.q> queue and <allhosts> hostgroup" }
      "DISTINST_ADD_DEFAULT_QUEUE_INSTANCE" { set value "Do you want to add a default queue instance for this host (y/n) \[y\] >> " }
      "DISTINST_ENTER_DATABASE_SERVER" { set value "*nter the name of your Berkeley DB Spooling Server* >> " }
      "DISTINST_ENTER_SERVER_DATABASE_DIRECTORY" { set value "*nter the ?atabase ?irectory * >> " }
      "DISTINST_ENTER_DATABASE_DIRECTORY_LOCAL_SPOOLING" { set value "Please enter the ?atabase ?irectory now, even if you want to spool locally,\nit is necessary to enter this ?atabase ?irectory. \n\nDefault: \[%s\] >> " }
      "DISTINST_DATABASE_DIR_NOT_ON_LOCAL_FS" { set value "The database directory >%s<\nis not on a local filesystem.\nPlease choose a local filesystem or configure the RPC Client/Server mechanism" }
      "DISTINST_STARTUP_RPC_SERVER" { set value "*is completed, continue with <RETURN>" }
      "DISTINST_DONT_KNOW_HOW_TO_TEST_FOR_LOCAL_FS" { set value "Don't know how to test for local filesystem. Exit." }
      "DISTINST_CURRENT_GRID_ROOT_DIRECTORY" { set value "The Grid Engine root directory is:\n\n   \\\$SGE_ROOT = %s\n\nIf this directory is not correct (e.g. it may contain an automounter\nprefix) enter the correct path to this directory or hit <RETURN>\nto use default \[%s\] >> " }
      "DISTINST_INSTALL_FAIL" { set value "Uninstallation  failed after %s retries" }
      "DISTINST_DATABASE_LOCAL_SPOOLING" { set value "Do you want to use a Berkeley DB Spooling Server? (y/n) \[n\] >> " }
      "DISTINST_EXECD_SPOOLING_DIR_NOROOT_NOADMINUSER" { set value "\nPlease give the basic configuration parameters of your Grid Engine\ninstallation:\n\n   <execd_spool_dir>\n\nThe pathname of the spool directory of the execution hosts. You\nmust have the right to create this directory and to write into it.\n" }
      "DISTINST_EXECD_SPOOLING_DIR_NOROOT" { set value "\nPlease give the basic configuration parameters of your Grid Engine\ninstallation:\n\n   <execd_spool_dir>\n\nThe pathname of the spool directory of the execution hosts. User >%s<\nmust have the right to create this directory and to write into it.\n" }
      "DISTINST_EXECD_SPOOLING_DIR_DEFAULT" { set value "Default: \[%s\] >> " }
      "DISTINST_ENTER_ADMIN_MAIL" { set value "\n<administrator_mail>\n\nThe email address of the administrator to whom problem reports are sent.\n\nIt's is recommended to configure this parameter. You may use >none<\nif you do not wish to receive administrator mail.\n\nPlease enter an email address in the form >user@foo.com<.\n\nDefault: \[*\] >> " }
      "DISTINST_ENTER_ADMIN_MAIL_SINCE_U3" { set value "\n<administrator_mail>\n\nThe email address of the administrator to whom problem reports are sent.\n\nIt is recommended to configure this parameter. You may use >none<\nif you do not wish to receive administrator mail.\n\nPlease enter an email address in the form >user@foo.com<.\n\nDefault: \[*\] >> " }
      "DISTINST_SHOW_CONFIGURATION" { set value "\nThe following parameters for the cluster configuration were configured:\n\n   execd_spool_dir        %s\n   administrator_mail     %s\n" }
      "DISTINST_ACCEPT_CONFIGURATION" { set value "Do you want to change the configuration parameters (y/n) \[n\] >> " }
      "DISTINST_INSTALL_STARTUP_SCRIPT" { set value "\nWe can install the startup script that\nGrid Engine is started at machine boot (y/n) \[n\] >> " }
      "DISTINST_CHECK_ADMINUSER_ACCOUNT" { set value "\nThe current directory\n\n   %s\n\nis owned by user\n\n   %s\n\nIf user >root< does not have write permissions in this directory on *all*\nof the machines where Grid Engine will be installed (NFS partitions not\nexported for user >root< with read/write permissions) it is recommended to\ninstall Grid Engine that all spool files will be created under the user id\nof user >%s<.\n\nIMPORTANT NOTE: The daemons still have to be started by user >root<. \n" }
      "DISTINST_CHECK_ADMINUSER_ACCOUNT_ANSWER" { set value "Do you want to install Grid Engine as admin user" }
      "DISTINST_ENTER_LOCAL_EXECD_SPOOL_DIR" { set value "During the qmaster installation you've already entered a global\nexecd spool directory. This is used, if no local spool directory is configured.\n\n Now you can enter a local spool directory for this host.\n" }
      "DISTINST_ENTER_LOCAL_EXECD_SPOOL_DIR_ASK" { set value "Do you want to configure a*spool directory\n for this host (y/n) \[n\] >> " }
      "DISTINST_ENTER_LOCAL_EXECD_SPOOL_DIR_ENTER" { set value "*nter the*spool directory now! >> " }
      "DISTINST_ENTER_SCHEDLUER_SETUP" { set value "Enter the number of your prefer* configuration and hit <RETURN>! \nDefault configuration is \[1\] >> " }
      "DISTINST_DELETE_DB_SPOOL_DIR" { set value "The spooling directory already exists! Do you want to delete it? \[n\] >> " }
      "DISTINST_ADD_SHADOWHOST_HEADLINE" { set value "\nAdding Grid Engine shadow hosts" }
      "DISTINST_ADD_SHADOWHOST_INFO" { set value "\nIf you want to use a shadow host, it is recommended to add this host\n to the list of administrative hosts.\n\nIf you are not sure, it is also possible to add or remove hosts after the\ninstallation with <qconf -ah hostname> for adding and <qconf -dh hostname>\nfor removing this host\n\nAttention: This is not the shadow host installation* procedure.\n You still have to install the shadow host separately\n\n" }
      "DISTINST_ADD_SHADOWHOST_INFO2" { set value "\nPlease now add the list of hosts, where you will later install your shadow\ndaemon.\n\nPlease enter a blank separated list of your execution hosts. You may\npress <RETURN> if the line is getting too long. Once you are finished\nsimply press <RETURN> without entering a name.\n\nYou also may prepare a file with the hostnames of the machines where you plan\nto install Grid Engine. This may be convenient if you are installing Grid\nEngine on many hosts.\n\n" }
      "DISTINST_ADD_SHADOWHOST_ASK" { set value "Do you want to add your shadow host(s) now? (y/n) \[y\] >> " }
      "DISTINST_ADD_SHADOWHOST_FROM_FILE_ASK" { set value "Do you want to use a file which contains the list of hosts (y/n) \[n\] >> " }
      "DISTINST_SHADOW_HEADLINE" { set value "\nShadow Master Host Setup" }
      "DISTINST_SHADOW_INFO" { set value "\nMake sure, that the host, you wish to configure as a shadow host,\n has read/write permissions to the qmaster spool and SGE_ROOT/<cell>/common \ndirectory! For using a shadow master it is recommended to set up a \nBerkeley DB Spooling Server\n\n Hit <RETURN> to continue >> " }
      "DISTINST_SHADOW_ROOT" { set value "Please enter your SGE_ROOT directory or use the default\n\[%s\] >> " }
      "DISTINST_SHADOW_CELL" { set value "Please enter your SGE_CELL directory or use the default \[default\] >> " }
      "DISTINST_SHADOWD_INSTALL_COMPLETE" { set value "Shadowhost installation completed!" }
      "DISTINST_WE_CONFIGURE_WITH_X_SETTINGS" { set value "\nWe're configuring the scheduler with >%s< settings!\n Do you agree? (y/n) \[y\] >> " }
      "DISTINST_RPC_WELCOME" { set value "Hit <RETURN> if this is ok or stop the installation with Ctrl-C >> " }
      "DISTINST_RPC_INSTALL_AS_ADMIN" { set value "Do you want to install Grid Engine as admin user >%s< (y/n) \[y\] >> " }
      "DISTINST_RPC_SGE_ROOT" { set value "If this directory is not correct (e.g. it may contain an automounter\nprefix) enter the correct path to this directory or hit <RETURN>\nto use default \[%s\] >> " }
      "DISTINST_RPC_HIT_RETURN_TO_CONTINUE" { set value "Hit <RETURN> to continue >> " }
      "DISTINST_RPC_SGE_CELL" { set value "Enter cell name \[%s\] >> " }
      "DISTINST_RPC_SERVER" { set value "\nEnter database server name or \nhit <RETURN> to use default \[%s\] >> " }
      "DISTINST_RPC_DIRECTORY" { set value "\nEnter the database directory\nor hit <RETURN> to use default \[%s\] >> " }
      "DISTINST_RPC_DIRECTORY_EXISTS" { set value "The spooling directory already exists! Do you want to delete it? (y/n) \[n\] >> " }
      "DISTINST_RPC_START_SERVER" { set value "Shall the installation script try to start the RPC server? (y/n) \[y\] >>" }
      "DISTINST_RPC_SERVER_STARTED" { set value "Please remember these values, during Qmaster installation\n you will be asked for! Hit <RETURN> to continue!" }
      "DISTINST_RPC_INSTALL_RC_SCRIPT" { set value "We can install the startup script that\nGrid Engine is started at machine boot (y/n) \[y\] >> " }
      "DISTINST_RPC_SERVER_COMPLETE" { set value "e.g. * * * * * <full path to scripts> <sge-root dir> <sge-cell> <bdb-dir>\n" }
      "DISTINST_CSP_COPY_CMD" { set value "Do you want to use rsh/rcp instead of ssh/scp? (y/n) \[n\] >>" }
      "DISTINST_CSP_COPY_CERTS" { set value "host? (y/n) \[y\] >>" }
      #"DISTINST_CSP_COPY_CERTS" { set value "Should the script try to copy the cert files, for you, to each\n<%s> host? (y/n) \[y\] >>" }
      "DISTINST_CSP_COPY_FAILED" { set value "The certificate copy failed!" }
      "DISTINST_CSP_COPY_RSH_FAILED" { set value "Certificates couldn't be copied!"}
      "DISTINST_EXECD_UNINST_NO_ADMIN" { set value "This host is not an admin host. Uninstallation is not allowed\nfrom this host!" }
      "DISTINST_EXECD_UNINST_ERROR_CASE" { set value "Disabling queues now!" }
      "DISTINST_QMASTER_WINDOWS_DOMAIN_USER" { set value "or are you going to use local Windows Users (answer: n) (y/n) \[y\] >> " }
      "DISTINST_QMASTER_WINDOWS_MANAGER" { set value "Please, enter the Windows Administrator name \[Default: Administrator\] >> " }
      "DISTINST_EXECD_WINDOWS_HELPER_SERVICE" { set value "Do you want to install the Windows Helper Service? (y/n) \[n\] >> " }
      "DISTINST_JAVA_HOME"  { set value "Please enter JAVA_HOME or press enter \[%s\] >> " }
      "DISTINST_JAVA_HOME_OR_NONE"  { set value "Enter JAVA_HOME (use \"none\" when none available) \[%s\] >> " }
      "DISTINST_ADD_JVM_ARGS"  { set value "Please enter additional JVM arguments (optional, default is \[%s\]) >> " }
      "DISTINST_ENABLE_JMX" { set value "Do you want to enable the JMX MBean server (y/n) *" }
      "DISTINST_JMX_PORT"   { set value "Please enter an unused port number for the JMX MBean server *" }
      "DISTINST_JMX_SSL"   { set value "Enable JMX SSL server authentication (y/n) \[y\] >> " }
      "DISTINST_JMX_SSL_CLIENT"   { set value "Enable JMX SSL client authentication (y/n) \[y\] >> " }
      "DISTINST_JMX_SSL_KEYSTORE"   { set value "Enter JMX SSL server keystore path \[%s\] >> " }
      "DISTINST_JMX_SSL_KEYSTORE_PW"   { set value "Enter JMX SSL server keystore *" }
      "DISTINST_JMX_USER_KEYSTORE_PW" { set value "Enter * for * keystore (at least 6 characters) >> " }
      "DISTINST_JMX_PW_RETYPE" { set value "Retype the password >> " }
      "DISTINST_JMX_USE_DATA"   { set value "Do you want to use these data (y/n) \[y\] >> " }
      "DISTINST_UNIQUE_CLUSTER_NAME" {set value "Unique cluster name" }
      "DISTINST_DETECT_CHOOSE_NEW_NAME" {set value "NOTE: Choose 'n' to select new SGE_CLUSTER_NAME  (y/n) *" }
      "DISTINST_DETECT_REMOVE_OLD_CLUSTER" {set value "*Stop the installation (WARNING: selecting 'n' *" }
      "DISTINST_SMF_IMPORT_SERVICE" {set value "NOTE: If you select \"n\" SMF will be not used at all" }
      "DISTINST_DETECT_BDB_KEEP_CELL" {set value "Do you want to keep * or delete * the directory? (y/n) *" }
      "DISTINST_DO_YOU_WANT_TO_CONTINUE" {set value "Do you want to continue (y/n) ('n' will abort) \[y\] >> " }
      "DISTINST_REMOVE_OLD_RC_SCRIPT" {set value "Do you want to remove the startup script \nfor * at this machine? (y/n) \[y\] >> " }
      "DISTINST_UNUSED_PORT"   { set value "*%s*Please enter an unused port number >> " }
      "DISTINT_UPGRADE_BCKP_DIR" { set value "Backup directory  >> " }
      "DISTINT_UPGRADE_USE_BCKP_DIR" { set value "Continue with this backup directory (y/n) \[y\] >> " }
      "DISTINT_UPGRADE_NEW_BCKP_DIR" { set value "Enter a new backup directory or exit ('n') (y/n) \[y\] >> " }
      "DISTINT_UPGRADE_COMMD_PORT_SETUP" { set value "*How do you want to configure the Grid Engine communication ports?\n\nUsing the >shell environment<:                           \[1\]\n\nUsing a network service like >/etc/service<, >NIS/NIS+<: \[2\]\n\n(default: 1) >> " }
      "DISTINT_UPGRADE_IJS_SELECTION" { set value "\nThe backup configuration includes information for running \ninteractive jobs. Do you want to use the IJS information from \nthe backup ('y') or use new default values ('n') (y/n) \[y\] >> " }
      "DISTINCT_UPGRADE_NEXT_RANK_NUMBER" { set value "\nBackup contains last * ID *. As a suggested value, we added 1000 \nto that number and rounded it up to the nearest 1000.\nIncrease the value, if appropriate.\nChoose the new next * ID \[*\] >> " }
      "DISTINCT_UPGRADE_USE_EXISTING_JMX" { set value "Found JMX settings in the backup\nUse the JMX settings from the backup ('y') or reconfigure ('n') (y/n) \[y\] >> " }
      "DISTINCT_UPGRADE_USE_EXISTING_SPOOLING" { set value "\nUse previous %s spooling method ('y') or use new spooling method *" }
      "DISTINT_ENTER_CA_COUNTRY_CODE" { set value "Please enter your two letter country code, e.g. 'US' >> " }
      "DISTINT_ENTER_CA_STATE" { set value "Please enter your state >> " }
      "DISTINT_ENTER_CA_LOCATION" { set value "Please enter your location, e.g city or buildingcode >> " }
      "DISTINT_ENTER_CA_ORGANIZATION" { set value "Please enter the name of your organization >> " }
      "DISTINT_ENTER_CA_ORGANIZATION_UNIT" { set value "Please enter your organizational unit, e.g. your department >> " }
      "DISTINT_ENTER_CA_ADMIN_EMAIL" { set value "Please enter the email address of the CA administrator >> " }
      "DISTINT_CA_RECREATE" { set value "Do you want to recreate your SGE CA infrastructure (y/n) \[y\] >> " }
      "DISTINT_ENTER_OVERRIDE_PROTECTION" { set value "*override protection 600 (yes/no)? " }
      "DISTINT_INSTALL_BDB_AND_CONTINUE" { set value "Please, log in to your Berkeley DB spooling host and execute \"inst_sge -db\"\nPlease do not continue, before the Berkeley DB installation with\n\"inst_sge -db\" is completed, continue with <RETURN>" }
   }

   # if it was no install macro, try to find it from messages files
   if { $value == "" } {
      set value [get_macro_string_from_name $macro_name]
#      ts_log_fine "value for $macro_name is \n\"$value\""
   }

   # macro nowhere found
   if {$raise_error} {
      if { $value == -1 } {
         set macro_messages_file [get_macro_messages_file_name]
         ts_log_severe "could not find macro \"$macro_name\" in source code!"
         if {$ts_config(source_dir) != "none"} {
            ts_log_config "deleting macro messages file:\n$macro_messages_file"
            if { [ file isfile $macro_messages_file] } {
               file delete $macro_messages_file
            }
            update_macro_messages_list
         }
      }
   }
   if {[string first "-" $value] >= 0 && [info exists warnings_already_logged($macro_name)] == 0} {
      # enable this to write all used macros in a file
      #catch {
      #   set script [ open "./.testsuite_macros_with_dashes" "a" "0755" ]
      #   puts $script $macro_name
      #   close $script
      #}
      ts_log_finer "---WARNING from translate macro procedure ------------------------------------"
      ts_log_finer "   translated macro \"$macro_name\" contains dashes(-)!"
      ts_log_finer "   Use the \"--\" option on expect pattern line when using it!"
      ts_log_finer "------------------------------------------------------------------------------"
      set warnings_already_logged($macro_name) 1
   }
   return $value
}


