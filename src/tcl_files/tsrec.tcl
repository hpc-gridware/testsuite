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

# Report record stream (CS-2936).
#
# Writes one JSON Lines file per testsuite invocation to
# <results_dir>/reports/<run_id>/<invocation_id>.jsonl. The format is
# described in testsuite/doc/reports/format.md. Recording is off unless
# TS_REPORT=1 or TS_REPORT_RUN_ID is set in the environment; while it is off,
# every tsrec_* procedure returns at once.

global tsrec
if {![info exists tsrec(enabled)]} {
   set tsrec(enabled) 0
}

## @brief Format a time stamp as ISO 8601 with milliseconds and offset
# @param ms milliseconds since the epoch, "" for now
# @return the time stamp, e.g. 2026-10-22T14:03:11.204+02:00
proc tsrec_time {{ms ""}} {
   if {$ms == ""} {
      set ms [clock milliseconds]
   }
   set sec [expr {$ms / 1000}]
   set frac [format "%03d" [expr {$ms % 1000}]]
   set base [clock format $sec -format "%Y-%m-%dT%H:%M:%S"]
   set zone [clock format $sec -format "%z"]
   return "$base.$frac[string range $zone 0 2]:[string range $zone 3 4]"
}

## @brief Encode a Tcl string as a JSON string literal
# @param value the string
# @return the quoted and escaped JSON string
proc tsrec_str {value} {
   set map [list "\\" "\\\\" "\"" "\\\"" "\n" "\\n" "\r" "\\r" "\t" "\\t" "\b" "\\b" "\f" "\\f"]
   set escaped [string map $map $value]
   # remaining control characters - rare, so only then character by character
   if {![regexp {[\x00-\x1f]} $escaped]} {
      return "\"$escaped\""
   }
   set out ""
   foreach char [split $escaped ""] {
      scan $char %c code
      if {$code < 0x20} {
         append out [format "\\u%04x" $code]
      } else {
         append out $char
      }
   }
   return "\"$out\""
}

## @brief Encode a Tcl list of strings as a JSON array of strings
# @param values the list
# @return the JSON array
proc tsrec_str_list {values} {
   set items {}
   foreach value $values {
      lappend items [tsrec_str $value]
   }
   return "\[[join $items ","]\]"
}

## @brief Encode a Tcl list of integers as a JSON array of numbers
# @param values the list
# @return the JSON array
proc tsrec_num_list {values} {
   return "\[[join $values ","]\]"
}

## @brief Encode an integer as a JSON number, anything else as a JSON string
# @param value the value
# @return the JSON number or string
proc tsrec_num_or_str {value} {
   if {[string is integer -strict $value]} {
      return $value
   }
   return [tsrec_str $value]
}

## @brief Encode a run level as a JSON number, an unset one as null
#
# The level of the current unit is empty outside a unit. Written raw, an empty
# level makes the record invalid JSON, and the merger skips the line.
# @param value the level
# @return the JSON number or null
proc tsrec_level {value} {
   if {[string is integer -strict $value]} {
      return $value
   }
   return "null"
}

## @brief Encode a Tcl boolean as a JSON boolean
# @param value a Tcl boolean
# @return true or false
proc tsrec_bool {value} {
   if {[string is true -strict $value]} {
      return "true"
   }
   return "false"
}

## @brief Build a JSON object from key/value pairs whose values are already JSON
# @param pairs flat list: key json-value key json-value ...
# @return the JSON object
proc tsrec_obj {pairs} {
   set items {}
   foreach {key value} $pairs {
      lappend items "[tsrec_str $key]:$value"
   }
   return "\{[join $items ","]\}"
}

## @brief Append one line of the given type to the record stream
#
# Adds "type" and "t" in front of the given pairs, writes the line and
# flushes it, so a killed invocation keeps every line written so far.
# @param type the line type, e.g. unit_start
# @param pairs flat list of key json-value pairs
# @return nothing
proc tsrec_line {type pairs} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   set line [tsrec_obj [concat [list type [tsrec_str $type] t [tsrec_str [tsrec_time]]] $pairs]]
   if {[catch {
      puts $tsrec(fd) $line
      flush $tsrec(fd)
   } msg]} {
      puts "tsrec: cannot write record stream, recording stopped: $msg"
      set tsrec(enabled) 0
   }
}

## @brief Return the commit and dirty state of the git repository containing a directory
# @param dir a directory inside the repository
# @return a JSON object with repo, commit and dirty, or "" if dir is no git tree
proc tsrec_git_source {dir} {
   if {$dir == "" || $dir == "none" || ![file isdirectory $dir]} {
      return ""
   }
   if {[catch {exec git -C $dir rev-parse --show-toplevel} top]} {
      return ""
   }
   if {[catch {exec git -C $top rev-parse --short=10 HEAD} commit]} {
      return ""
   }
   set dirty 0
   if {![catch {exec git -C $top status --porcelain --untracked-files=no} status] && $status != ""} {
      set dirty 1
   }
   return [tsrec_obj [list repo [tsrec_str [file tail $top]] \
                               commit [tsrec_str $commit] \
                               dirty [tsrec_bool $dirty]]]
}

## @brief Start recording if the environment asks for it
#
# Reads TS_REPORT, TS_REPORT_RUN_ID, TS_REPORT_ATTEMPT and
# TS_REPORT_ATTEMPT_LABEL, opens the stream file, writes the invocation line
# and prints the run id and report directory. Must be called once the
# configuration (ts_config) is loaded.
# @return nothing
proc tsrec_init {} {
   global tsrec ts_config env CHECK_USER

   set tsrec(enabled) 0
   set on 0
   if {[info exists env(TS_REPORT)] && $env(TS_REPORT) == "1"} {
      set on 1
   }
   if {[info exists env(TS_REPORT_RUN_ID)] && $env(TS_REPORT_RUN_ID) != ""} {
      set on 1
   }
   if {!$on} {
      return
   }

   set start_ms [clock milliseconds]
   if {[info exists env(TS_REPORT_RUN_ID)] && $env(TS_REPORT_RUN_ID) != ""} {
      set run_id $env(TS_REPORT_RUN_ID)
   } else {
      set run_id [clock format [expr {$start_ms / 1000}] -format "%Y%m%d-%H%M%S"]
   }
   set attempt 0
   if {[info exists env(TS_REPORT_ATTEMPT)] && [string is integer -strict $env(TS_REPORT_ATTEMPT)]} {
      set attempt $env(TS_REPORT_ATTEMPT)
   }
   set label "interactive"
   if {[info exists env(TS_REPORT_ATTEMPT_LABEL)] && $env(TS_REPORT_ATTEMPT_LABEL) != ""} {
      set label $env(TS_REPORT_ATTEMPT_LABEL)
   }

   set host [lindex [split [info hostname] "."] 0]
   set invocation_id "$host-[pid]-$start_ms"
   set dir "$ts_config(results_dir)/reports/$run_id"
   if {[catch {
      file mkdir $dir
      set fd [open "$dir/$invocation_id.jsonl" a]
      fconfigure $fd -encoding utf-8 -translation lf
   } msg]} {
      puts "tsrec: cannot open record stream in $dir, recording off: $msg"
      return
   }

   set tsrec(fd) $fd
   set tsrec(run_id) $run_id
   set tsrec(invocation_id) $invocation_id
   set tsrec(dir) $dir
   set tsrec(attempt) $attempt
   set tsrec(attempt_label) $label
   set tsrec(check) ""
   set tsrec(level) ""
   set tsrec(function) ""
   set tsrec(context) ""
   set tsrec(cleanup_messages) {}
   set tsrec(next_origin) ""
   set tsrec(in_start_remote_prog) 0
   set tsrec(last_real_user) ""
   set tsrec(context_stack) {}
   set tsrec(context_next) 0
   set tsrec(diagnostic) 0
   set tsrec(stub) ""
   set tsrec(level_functions) 0
   set tsrec(level_stubs) 0
   set tsrec(enabled) 1

   # provenance
   set sources {}
   foreach dir_key {source_dir ext_source_dir testsuite_root_dir} {
      if {[info exists ts_config($dir_key)]} {
         set src_dir $ts_config($dir_key)
         # ext_source_dir is given relative to the clusterscheduler directory,
         # the cmake source root it is handed to as PROJECT_EXTENSIONS
         if {$dir_key == "ext_source_dir" && $src_dir != "none" && [file pathtype $src_dir] != "absolute"} {
            set src_dir [file normalize [file join [file dirname $ts_config(source_dir)] $src_dir]]
         }
         set src [tsrec_git_source $src_dir]
         if {$src != ""} {
            lappend sources $src
         }
      }
   }
   if {[info exists ts_config(additional_checktree_dirs)]} {
      foreach checktree_dir $ts_config(additional_checktree_dirs) {
         set src [tsrec_git_source $checktree_dir]
         if {$src != "" && [lsearch -exact $sources $src] < 0} {
            lappend sources $src
         }
      }
   }
   # get_version_info returns e.g. "GCS 9.1.8prealpha (221026-1628)"
   set version ""
   catch {set version [get_version_info]}
   set product [lindex $version 0]
   set version [lrange $version 1 end]
   set user ""
   if {[info exists CHECK_USER]} {
      set user $CHECK_USER
   }
   set cluster [tsrec_obj [list \
      name [tsrec_str $ts_config(cluster_name)] \
      qmaster_host [tsrec_str $ts_config(master_host)] \
      qmaster_port $ts_config(commd_port) \
      execd_hosts [tsrec_str_list $ts_config(execd_nodes)] \
      submit_hosts [tsrec_str_list $ts_config(submit_only_hosts)]]]
   set provenance [tsrec_obj [list \
      ts_host [tsrec_str $host] \
      ts_user [tsrec_str $user] \
      product [tsrec_str $product] \
      product_version [tsrec_str $version] \
      product_root [tsrec_str $ts_config(product_root)] \
      sources "\[[join $sources ","]\]" \
      cluster $cluster \
      results_dir [tsrec_str $ts_config(results_dir)]]]

   puts $fd [tsrec_obj [list \
      format [tsrec_str "ts-report/record/1"] \
      type [tsrec_str "invocation"] \
      t [tsrec_str [tsrec_time $start_ms]] \
      run_id [tsrec_str $run_id] \
      invocation_id [tsrec_str $invocation_id] \
      attempt $attempt \
      attempt_label [tsrec_str $label] \
      producer [tsrec_str "testsuite"] \
      provenance $provenance]]
   flush $fd

   exit -onexit tsrec_invocation_end
   puts "tsrec: recording run \"$run_id\" to $dir/$invocation_id.jsonl"
}

## @brief Write the closing line of the stream; installed as exit handler
# @return nothing
proc tsrec_invocation_end {} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   tsrec_line "invocation_end" {}
   catch {close $tsrec(fd)}
   set tsrec(enabled) 0
}

## @brief Turn a check path into the absolute spelling the units are keyed by
# @param path a check path as given on the command line or by the checktree
# @return the absolute path
proc tsrec_check_path {path} {
   global ts_config
   if {[file pathtype $path] != "absolute"} {
      set path "$ts_config(testsuite_root_dir)/checktree/$path"
   }
   return [file normalize $path]
}

## @brief Record the units an invocation intends to run
# @param source command_line or run_test
# @param units list of {path level} pairs
# @return nothing
proc tsrec_selection {source units} {
   global tsrec
   if {!$tsrec(enabled) || [llength $units] == 0} {
      return
   }
   set items {}
   foreach unit $units {
      lassign $unit path level
      lappend items [tsrec_obj [list check [tsrec_str [tsrec_check_path $path]] level $level]]
   }
   tsrec_line "selection" [list source [tsrec_str $source] units "\[[join $items ","]\]"]
}

## @brief Record a check-wide phase (setup or cleanup) of the current check
# @param path the check path
# @param levels the levels the check runs in this invocation
# @param phase setup or cleanup
# @param ret the return value of the phase procedure
# @return nothing
proc tsrec_check_phase {path levels phase ret} {
   tsrec_line "phase" [list check [tsrec_str [tsrec_check_path $path]] \
                                levels [tsrec_num_list $levels] \
                                phase [tsrec_str $phase] \
                                result [tsrec_str [tsrec_phase_result $ret]] \
                                return [tsrec_num_or_str $ret]]
}

## @brief Map the return value of execute_test_preparation_procedure to a phase result
# @param ret 0 failure, 1 ok, 2 no procedure, 99 skip
# @return ok, skip or error
proc tsrec_phase_result {ret} {
   switch -- $ret {
      0 {return "error"}
      99 {return "skip"}
      default {return "ok"}
   }
}

## @brief Record the start of a unit (one check at one level)
# @param path the check path
# @param level the run level
# @return nothing
proc tsrec_unit_start {path level} {
   global tsrec check_name check_description check_category check_functions check_test_cases
   if {!$tsrec(enabled)} {
      return
   }
   set tsrec(check) [tsrec_check_path $path]
   set tsrec(level) $level
   set tsrec(level_functions) 0
   set tsrec(level_stubs) 0
   set description ""
   if {[info exists check_description($level)]} {
      set description $check_description($level)
   }
   set functions {}
   if {[info exists check_functions]} {
      set functions $check_functions
   }
   set pairs [list check [tsrec_str $tsrec(check)] \
                   name [tsrec_str $check_name] \
                   level $level \
                   description [tsrec_str $description] \
                   categories [tsrec_str_list $check_category] \
                   functions [tsrec_str_list $functions]]
   if {[array exists check_test_cases]} {
      set per_function {}
      foreach function [lsort [array names check_test_cases]] {
         set cases {}
         foreach entry $check_test_cases($function) {
            lassign $entry id relation
            if {$relation == ""} {
               set relation "covers"
            }
            lappend cases [tsrec_obj [list id [tsrec_str $id] relation [tsrec_str $relation]]]
         }
         lappend per_function $function "\[[join $cases ","]\]"
      }
      lappend pairs test_cases [tsrec_obj $per_function]
   }
   tsrec_line "unit_start" $pairs
}

## @brief Record a level phase (setup_level or cleanup_level) of the current unit
# @param phase setup_level or cleanup_level
# @param ret the return value of the phase procedure
# @return nothing
proc tsrec_level_phase {phase ret} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   tsrec_line "phase" [list check [tsrec_str $tsrec(check)] \
                                level [tsrec_level $tsrec(level)] \
                                phase [tsrec_str $phase] \
                                result [tsrec_str [tsrec_phase_result $ret]] \
                                return [tsrec_num_or_str $ret]]
}

## @brief Record the start of a check function
# @param function the function name
# @param index its position in check_functions, counted from 1
# @return nothing
proc tsrec_function_start {function index} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   set tsrec(function) $function
   set tsrec(stub) ""
   tsrec_line "function_start" [list function [tsrec_str $function] index $index]
}

## @brief Record the end of a check function and derive its verdict
#
# A function that raised no error but called ts_not_implemented ends
# not_implemented, with the reason it gave.
# @param function the function name
# @param duration_ms the function's run time in milliseconds
# @param tcl_failed 1 if the function raised a Tcl error
# @return nothing
proc tsrec_function_end {function duration_ms tcl_failed} {
   global tsrec check_errno
   if {!$tsrec(enabled)} {
      return
   }
   set errors 0
   set config 0
   if {[info exists check_errno($function)]} {
      foreach code $check_errno($function) {
         switch -- $code {
            -1 - -2 {incr errors}
            -3 {incr config}
         }
      }
   }
   if {$tcl_failed} {
      set verdict "tcl_error"
   } elseif {$errors > 0} {
      set verdict "failed"
   } elseif {$config > 0} {
      set verdict "unsupported"
   } elseif {$tsrec(stub) != ""} {
      set verdict "not_implemented"
   } else {
      set verdict "passed"
   }
   set pairs [list function [tsrec_str $function] \
                   verdict [tsrec_str $verdict] \
                   duration [format "%.3f" [expr {$duration_ms / 1000.0}]]]
   if {$verdict == "not_implemented"} {
      lappend pairs reason [tsrec_str $tsrec(stub)]
      incr tsrec(level_stubs)
   }
   incr tsrec(level_functions)
   tsrec_line "function_end" $pairs
   set tsrec(function) ""
   set tsrec(stub) ""
}

## @brief Mark the running check function as a stub of a test not written yet
#
# For a test case of a specification whose test does not exist yet: the check
# function names the case in check_test_cases, calls this and returns. The
# report shows the function, and the unit when all its functions are stubs,
# as not_implemented, so the progress against the specification is visible.
# For the testsuite itself the function passed: no error is raised, so a
# fleet run does not repeat it and the ledger records it as passed.
# @param reason what is missing, e.g. "needs the role enforcement in qmaster"
# @return nothing
proc ts_not_implemented {reason} {
   global tsrec CHECK_CUR_PROC_NAME
   set function ""
   if {[info exists CHECK_CUR_PROC_NAME]} {
      set function $CHECK_CUR_PROC_NAME
   }
   ts_log_fine "NOT IMPLEMENTED: $function: $reason"
   if {!$tsrec(enabled) || $tsrec(function) == ""} {
      return
   }
   set tsrec(stub) $reason
}

## @brief Record an error raised through the testsuite logging
#
# Called from the logging code for SEVERE, WARNING and CONFIG messages.
# During the post-check cleanup checks the messages are collected for the
# cleanup_check line instead.
# @param level_name SEVERE, WARNING or CONFIG
# @param message the error text
# @param origin assertion, tcl_error, poll_timeout, command_timeout or connection
# @return nothing
proc tsrec_error {level_name message {origin "assertion"}} {
   global tsrec CHECK_CUR_PROC_NAME
   if {!$tsrec(enabled)} {
      return
   }
   if {$tsrec(next_origin) != ""} {
      set origin $tsrec(next_origin)
      set tsrec(next_origin) ""
   } elseif {$origin == "assertion" && [tsrec_in_proc "open_remote_spawn_process"]} {
      # raised while a connection to a host was being set up
      set origin "connection"
   }
   set poll [tsrec_innermost poll]
   set step [tsrec_innermost step]
   if {$step != ""} {
      dict set tsrec(step,$step) error 1
   }
   if {$poll != ""} {
      # raised inside a wait helper: a timeout there points at load
      if {$origin == "assertion" && ([string match -nocase "*timeout*" $message] || [tsrec_poll_due $poll [clock milliseconds]])} {
         set origin "poll_timeout"
      }
      if {$origin == "poll_timeout"} {
         dict set tsrec(poll,$poll) timeout_error 1
      } else {
         dict set tsrec(poll,$poll) error 1
      }
   }
   if {$tsrec(context) == "cleanup_check"} {
      lappend tsrec(cleanup_messages) $message
      set origin "cleanup"
   }
   set function $tsrec(function)
   if {$tsrec(context) == "cleanup_check"} {
      set function "cleanup_check"
   } elseif {$function == "" && [info exists CHECK_CUR_PROC_NAME]} {
      set function $CHECK_CUR_PROC_NAME
   }
   set pairs [list function [tsrec_str $function] \
                   level [tsrec_str $level_name] \
                   origin [tsrec_str $origin] \
                   message [tsrec_str $message]]
   if {$poll != ""} {
      lappend pairs poll $poll
   }
   if {$step != ""} {
      lappend pairs step $step
   }
   if {$tsrec(check) != ""} {
      set pairs [concat [list check [tsrec_str $tsrec(check)]] $pairs]
   }
   tsrec_line "error" $pairs
}

## @brief Set the origin of the next recorded error
#
# For errors whose cause the caller knows better than the logging code, e.g.
# a Tcl error caught around a check function.
# @param origin one of the origins listed for tsrec_error
# @return nothing
proc tsrec_set_origin {origin} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   set tsrec(next_origin) $origin
}

## @brief Record the end of the current unit
#
# A passed level whose functions all ended not_implemented is recorded as
# not_implemented.
# @param verdict passed, failed, unsupported or skipped
# @param duration_s the unit's run time in seconds
# @return nothing
proc tsrec_unit_end {verdict duration_s} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   if {$verdict == "passed" && $tsrec(level_functions) > 0 && \
       $tsrec(level_stubs) == $tsrec(level_functions)} {
      set verdict "not_implemented"
   }
   tsrec_line "unit_end" [list check [tsrec_str $tsrec(check)] \
                                   level [tsrec_level $tsrec(level)] \
                                   verdict [tsrec_str $verdict] \
                                   duration [format "%.3f" $duration_s]]
   set tsrec(level) ""
}

## @brief Mark the start of the post-check cleanup checks
# @param path the check path
# @return nothing
proc tsrec_cleanup_check_start {path} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   set tsrec(check) [tsrec_check_path $path]
   set tsrec(context) "cleanup_check"
   set tsrec(cleanup_messages) {}
}

## @brief Record the result of the post-check cleanup checks
#
# The result is "error" when any error was raised since
# tsrec_cleanup_check_start - by check_if_test_cleaned_up or by the other
# checks run after the cleanup function (daemon crashes, session leaks,
# valgrind).
# @param levels the levels the check ran in this invocation
# @return nothing
proc tsrec_cleanup_check_end {levels} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   set result "ok"
   if {[llength $tsrec(cleanup_messages)] > 0} {
      set result "error"
   }
   tsrec_line "cleanup_check" [list check [tsrec_str $tsrec(check)] \
                                        levels [tsrec_num_list $levels] \
                                        result [tsrec_str $result] \
                                        messages [tsrec_str_list $tsrec(cleanup_messages)]]
   set tsrec(context) ""
   set tsrec(cleanup_messages) {}
   set tsrec(check) ""
}

## @brief Tell whether a procedure is on the current call stack
# @param name the procedure name
# @return 1 if a frame of that procedure is active, 0 otherwise
proc tsrec_in_proc {name} {
   for {set level [expr {[info level] - 1}]} {$level > 0} {incr level -1} {
      if {[lindex [info level $level] 0] == $name} {
         return 1
      }
   }
   return 0
}

## @brief Tell whether the testsuite framework itself is running, not a check
#
# True around a check (the cleanup baseline before the setup, the post-check
# cleanup checks) and inside the framework procedures a check function calls
# indirectly: the error mail of the logging, the result marker, and the
# lookups of message texts (translate) and host names (resolve_host).
# @param function the function the record is attributed to
# @return 1 for framework activity, 0 otherwise
proc tsrec_in_framework {function} {
   if {$function == "main" || $function == "cleanup_check"} {
      return 1
   }
   foreach name {ts_private_log_send_mail mail_report send_mail save_result translate resolve_host} {
      if {[tsrec_in_proc $name]} {
         return 1
      }
   }
   return 0
}

## @brief Mark the start of a check, so its setup commands are recorded too
# @param path the check path
# @return nothing
proc tsrec_check_start {path} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   set tsrec(check) [tsrec_check_path $path]
}

## @brief Save the recording state of the current unit before a nested run
#
# A check that reinstalls the cluster runs the INSTALL checks as units of
# their own, through the same global state. Their ends clear the check, the
# level and the context, so the records the outer unit writes afterwards
# would name no check and no level. The caller saves the state here and
# hands it back to tsrec_restore_unit once the nested run is over.
# @return the saved state, "" if recording is off
proc tsrec_save_unit {} {
   global tsrec
   if {!$tsrec(enabled)} {
      return ""
   }
   set state {}
   foreach key {check level function context cleanup_messages next_origin \
                stub level_functions level_stubs} {
      lappend state $key $tsrec($key)
   }
   return $state
}

## @brief Restore the recording state saved by tsrec_save_unit
# @param state the value tsrec_save_unit returned
# @return nothing
proc tsrec_restore_unit {state} {
   global tsrec
   if {!$tsrec(enabled) || $state == ""} {
      return
   }
   foreach {key value} $state {
      set tsrec($key) $value
   }
}

## @brief Encode command output as a JSON object with size and excerpt
#
# Keeps the first and the last 2 KiB of longer output. The record lines a
# module test writes to its output are left out: they become a stream of
# their own (tsrec_module_test_output).
# @param output the command output
# @return the JSON object with bytes, excerpt and truncated
proc tsrec_output {output} {
   regsub -all -line {^##tsrec .*(\n|$)} $output "" output
   set length [string length $output]
   set truncated 0
   if {$length > 4096} {
      set output "[string range $output 0 2047]\n...\n[string range $output end-2047 end]"
      set truncated 1
   }
   return [tsrec_obj [list bytes $length \
                               excerpt [tsrec_str $output] \
                               truncated [tsrec_bool $truncated]]]
}

## @brief Record one finished command
# @param host the host the command ran on
# @param user the user it ran as
# @param command the command
# @param arguments its arguments
# @param cwd its working directory, "" for the default
# @param start_ms start time in milliseconds
# @param end_ms end time in milliseconds
# @param exit_status the exit status, "" if unknown
# @param timed_out 1 if the command did not finish in time
# @param background 1 if it was started in the background
# @param interactive 1 for a session driven by the check (no exit status)
# @param output the command output
# @return nothing
proc tsrec_command {host user command arguments cwd start_ms end_ms exit_status timed_out background interactive output} {
   global tsrec CHECK_CUR_PROC_NAME
   if {!$tsrec(enabled) || $tsrec(check) == ""} {
      return
   }
   set function $tsrec(function)
   if {$tsrec(context) == "cleanup_check"} {
      set function "cleanup_check"
   } elseif {$function == "" && [info exists CHECK_CUR_PROC_NAME]} {
      set function $CHECK_CUR_PROC_NAME
   }
   set framework [tsrec_in_framework $function]
   set exit_json "null"
   if {[string is integer -strict $exit_status]} {
      set exit_json $exit_status
   }
   set pairs [list function [tsrec_str $function] \
                   host [tsrec_str $host] \
                   user [tsrec_str $user] \
                   root [tsrec_bool [expr {$user == "root"}]] \
                   command [tsrec_str $command] \
                   args [tsrec_str $arguments] \
                   cwd [tsrec_str $cwd] \
                   start [tsrec_str [tsrec_time $start_ms]] \
                   end [tsrec_str [tsrec_time $end_ms]] \
                   exit $exit_json \
                   timed_out [tsrec_bool $timed_out] \
                   background [tsrec_bool $background] \
                   interactive [tsrec_bool $interactive] \
                   framework [tsrec_bool $framework]]
   # the innermost context of either kind counts the command as its own
   set inner [lindex $tsrec(context_stack) end]
   foreach kind {poll step} {
      if {$inner != "" && [info exists tsrec($kind,$inner)]} {
         dict incr tsrec($kind,$inner) commands
      }
      set id [tsrec_innermost $kind]
      if {$id != ""} {
         lappend pairs $kind $id
      }
   }
   lappend pairs diagnostic [tsrec_bool [expr {$tsrec(diagnostic) > 0}]] \
                 output [tsrec_output $output]
   tsrec_line "command" $pairs
}

## @brief Note a spawned session; called by open_remote_spawn_process before it returns
#
# Remembers the user the session really runs as, for start_remote_prog. A
# session opened directly by a check (not through start_remote_prog) is kept
# until close_spawn_process, which records it as an interactive command.
# @param host the host
# @param user the user the session runs as
# @param command the command
# @param arguments its arguments
# @param cwd the working directory
# @param background the background flag
# @param spawn_id the expect spawn id of the session
# @param start_ms when the session was requested, in milliseconds
# @return nothing
proc tsrec_spawn_opened {host user command arguments cwd background spawn_id start_ms} {
   global tsrec
   if {!$tsrec(enabled)} {
      return
   }
   set tsrec(last_real_user) $user
   if {$tsrec(in_start_remote_prog) == 0 && $tsrec(check) != ""} {
      set tsrec(open,$spawn_id) [list $host $user $command $arguments $cwd $background $start_ms]
   }
}

## @brief Record a session opened directly by a check when it is closed
# @param spawn_id the expect spawn id of the session
# @return nothing
proc tsrec_spawn_closed {spawn_id} {
   global tsrec
   if {!$tsrec(enabled) || ![info exists tsrec(open,$spawn_id)]} {
      return
   }
   lassign $tsrec(open,$spawn_id) host user command arguments cwd background start_ms
   unset tsrec(open,$spawn_id)
   tsrec_command $host $user $command $arguments $cwd $start_ms [clock milliseconds] "" 0 $background 1 ""
}

## @brief The innermost open context of a kind
# @param kind poll or step
# @return its id, or "" if no context of that kind is open
proc tsrec_innermost {kind} {
   global tsrec
   for {set i [expr {[llength $tsrec(context_stack)] - 1}]} {$i >= 0} {incr i -1} {
      set id [lindex $tsrec(context_stack) $i]
      if {[info exists tsrec($kind,$id)]} {
         return $id
      }
   }
   return ""
}

## @brief The function a context opened now is attributed to
# @return the check function, the phase, or cleanup_check
proc tsrec_context_function {} {
   global tsrec CHECK_CUR_PROC_NAME
   if {$tsrec(context) == "cleanup_check"} {
      return "cleanup_check"
   }
   if {$tsrec(function) == "" && [info exists CHECK_CUR_PROC_NAME]} {
      return $CHECK_CUR_PROC_NAME
   }
   return $tsrec(function)
}

## @brief Remove a context and every context opened inside it from the stack
# @param id the context id
# @return nothing
proc tsrec_context_pop {id} {
   global tsrec
   set index [lsearch -exact $tsrec(context_stack) $id]
   if {$index >= 0} {
      set tsrec(context_stack) [lrange $tsrec(context_stack) 0 [expr {$index - 1}]]
   }
}

## @brief Open a step context for the calling cluster-control helper
#
# A step is one action of a check carried out by a helper, e.g. stopping the
# qmaster, that spawns several commands of its own (pid files, process
# lists, the stop command). It closes by itself when the helper returns, like
# a poll context, and nests with poll contexts on one stack; commands and
# errors inside carry its id as step.
# @param description what the step does, e.g. "stop qmaster on host-0012"
# @return nothing
proc tsrec_step_begin {description} {
   global tsrec
   if {!$tsrec(enabled) || $tsrec(check) == ""} {
      return
   }
   set id [incr tsrec(context_next)]
   set function [tsrec_context_function]
   set tsrec(step,$id) [dict create parent [lindex $tsrec(context_stack) end] \
                                    function $function \
                                    helper [lindex [info level -1] 0] \
                                    framework [tsrec_in_framework $function] \
                                    description $description \
                                    start [clock milliseconds] \
                                    commands 0 \
                                    error 0]
   lappend tsrec(context_stack) $id
   uplevel 1 [list set tsrec_step_guard $id]
   uplevel 1 [list trace add variable tsrec_step_guard unset [list tsrec_step_end $id]]
}

## @brief Close a step context and record it; variable trace installed by tsrec_step_begin
#
# The outcome is error if an error was raised inside the step, ok otherwise.
# @param id the step context id
# @param args the arguments of the variable trace (name1 name2 op), unused
# @return nothing
proc tsrec_step_end {id args} {
   global tsrec
   if {![info exists tsrec(step,$id)]} {
      return
   }
   set end_ms [clock milliseconds]
   tsrec_context_pop $id
   set step $tsrec(step,$id)
   unset tsrec(step,$id)
   if {!$tsrec(enabled)} {
      return
   }
   set parent [dict get $step parent]
   if {$parent == ""} {
      set parent "null"
   }
   tsrec_line "step" [list id $id \
                           parent $parent \
                           function [tsrec_str [dict get $step function]] \
                           helper [tsrec_str [dict get $step helper]] \
                           framework [tsrec_bool [dict get $step framework]] \
                           description [tsrec_str [dict get $step description]] \
                           start [tsrec_str [tsrec_time [dict get $step start]]] \
                           end [tsrec_str [tsrec_time $end_ms]] \
                           outcome [tsrec_str [expr {[dict get $step error] ? "error" : "ok"}]] \
                           commands [dict get $step commands]]
}

## @brief Open a poll context for the calling wait helper
#
# Called by a wait helper once it knows its effective timeout. The context
# closes by itself when the helper returns, whichever way it leaves: a trace
# on a variable in the helper's frame fires when the frame goes away.
# Commands spawned while the context is open carry its id.
# @param condition what the helper waits for, e.g. "job 1234 running"
# @param timeout the effective timeout in seconds, after ts_scale_timeout
# @return nothing
proc tsrec_poll_begin {condition timeout} {
   global tsrec
   if {!$tsrec(enabled) || $tsrec(check) == ""} {
      return
   }
   set id [incr tsrec(context_next)]
   set function [tsrec_context_function]
   set tsrec(poll,$id) [dict create parent [lindex $tsrec(context_stack) end] \
                                    function $function \
                                    helper [lindex [info level -1] 0] \
                                    framework [tsrec_in_framework $function] \
                                    condition $condition \
                                    timeout $timeout \
                                    start [clock milliseconds] \
                                    commands 0 \
                                    error 0 \
                                    timeout_error 0]
   lappend tsrec(context_stack) $id
   uplevel 1 [list set tsrec_poll_guard $id]
   uplevel 1 [list trace add variable tsrec_poll_guard unset [list tsrec_poll_end $id]]
}

## @brief Tell whether the effective timeout of a poll context has run out
#
# The helpers count whole seconds, so a deadline counts as reached up to one
# second early. A timeout below 1 means the helper waits without a deadline.
# @param id the poll context id
# @param now_ms the time to check, in milliseconds
# @return 1 if the deadline is reached, 0 otherwise
proc tsrec_poll_due {id now_ms} {
   global tsrec
   set timeout_ms [expr {[dict get $tsrec(poll,$id) timeout] * 1000}]
   if {$timeout_ms < 1000} {
      return 0
   }
   set slack [expr {min(1000, $timeout_ms / 2)}]
   return [expr {$now_ms - [dict get $tsrec(poll,$id) start] >= $timeout_ms - $slack}]
}

## @brief Close a poll context and record it; variable trace installed by tsrec_poll_begin
#
# The outcome is timeout if a timeout error was raised inside the context or
# the deadline was reached silently (a helper called without error check),
# error if any other error was raised, met otherwise.
# @param id the poll context id
# @param args the arguments of the variable trace (name1 name2 op), unused
# @return nothing
proc tsrec_poll_end {id args} {
   global tsrec
   if {![info exists tsrec(poll,$id)]} {
      return
   }
   set end_ms [clock milliseconds]
   tsrec_context_pop $id
   set poll $tsrec(poll,$id)
   if {[dict get $poll timeout_error]} {
      set outcome "timeout"
   } elseif {[dict get $poll error]} {
      set outcome "error"
   } elseif {[tsrec_poll_due $id $end_ms]} {
      set outcome "timeout"
   } else {
      set outcome "met"
   }
   unset tsrec(poll,$id)
   if {!$tsrec(enabled)} {
      return
   }
   set parent [dict get $poll parent]
   if {$parent == ""} {
      set parent "null"
   }
   tsrec_line "poll" [list id $id \
                           parent $parent \
                           function [tsrec_str [dict get $poll function]] \
                           helper [tsrec_str [dict get $poll helper]] \
                           framework [tsrec_bool [dict get $poll framework]] \
                           condition [tsrec_str [dict get $poll condition]] \
                           timeout [tsrec_num_or_str [dict get $poll timeout]] \
                           start [tsrec_str [tsrec_time [dict get $poll start]]] \
                           end [tsrec_str [tsrec_time $end_ms]] \
                           outcome [tsrec_str $outcome] \
                           commands [dict get $poll commands]]
}

## @brief Run a script whose commands only explain a failure
#
# Wait helpers wrap the commands they run after a timeout to show the state
# of the cluster; those commands are recorded with diagnostic set, so a
# report does not list them as steps of the scenario.
# @param script the script, evaluated in the caller's frame
# @return the result of the script, with its return code
proc tsrec_diagnostic {script} {
   global tsrec
   set counted [expr {[info exists tsrec(diagnostic)] && $tsrec(enabled)}]
   if {$counted} {
      incr tsrec(diagnostic)
   }
   set code [catch {uplevel 1 $script} result options]
   if {$counted} {
      incr tsrec(diagnostic) -1
   }
   return -options $options $result
}

## @brief The options that make a module test binary record into this run
#
# The binary writes its record lines to stdout with the prefix "##tsrec "
# (clusterscheduler test/common/ocs_module_test.h); tsrec_module_test_output
# takes them out of its output again. The label must not contain blanks, as
# the options pass through a remote shell.
# @return the option list, empty when recording is off
proc tsrec_module_test_args {} {
   global tsrec
   if {!$tsrec(enabled)} {
      return {}
   }
   set label [string map {" " "_"} $tsrec(attempt_label)]
   return [list "--report=-" "--report-run=$tsrec(run_id)" "--report-attempt=$tsrec(attempt)" \
                "--report-label=$label"]
}

## @brief Store the record lines in a module test's output as a stream of its own
#
# The stream is named after the invocation id the binary wrote, so it sits
# next to the testsuite's own streams of the run and merge reads it like any
# other.
# @param output the output of the module test binary
# @return the output without the record lines
proc tsrec_module_test_output {output} {
   global tsrec
   set kept {}
   set records {}
   foreach line [split $output "\n"] {
      set line [string trimright $line "\r"]
      if {[string match "##tsrec *" $line]} {
         lappend records [string range $line 8 end]
      } else {
         lappend kept $line
      }
   }
   if {$tsrec(enabled) && [llength $records] > 0} {
      if {![regexp {"invocation_id": "([^"]+)"} [lindex $records 0] -> id]} {
         set id "$tsrec(invocation_id)-module-[clock milliseconds]"
      }
      if {[catch {
         set fd [open "$tsrec(dir)/$id.jsonl" a]
         fconfigure $fd -encoding utf-8 -translation lf
         puts $fd [join $records "\n"]
         close $fd
      } msg]} {
         puts "tsrec: cannot write the module test stream $id: $msg"
      }
   }
   return [join $kept "\n"]
}
