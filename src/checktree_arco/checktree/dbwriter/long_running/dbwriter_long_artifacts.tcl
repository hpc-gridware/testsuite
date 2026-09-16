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
#  See the License for the specific provisions governing permissions and
#  limitations under the License.
#
###########################################################################
#___INFO__MARK_END_NEW__

##
# @file dbwriter_long_artifacts.tcl
# @brief Artifact collection for the long-running dbwriter test (CS-2240).
#
# A run of this test takes days, and the database it leaves behind is emptied
# by the cleanup. When a phase fails, whatever is needed to understand it has
# to be put aside while the phase is still failing - by the time the run ends
# the evidence is gone. Every analysis this test has needed so far came from
# the same four sources, so those are what a failure captures:
#
#   - the dbwriter log,
#   - the accounting file of the run,
#   - the dbwriter.xml that was in effect,
#   - the newest rows of the tables the assertions look at.
#
# A passing phase writes nothing but its result, so a green run leaves only the
# summary page behind.
#
# Sourced from the test's check.exp.

##
# @namespace dbwriter_long_artifacts
# @brief Per-run artifact directory and the summary page over it.
namespace eval dbwriter_long_artifacts {
   # artifact directory of this run ("" => not initialised)
   variable dir ""
   # {phase rc} of every phase that has finished, in execution order
   variable phases {}
   # base URL a CS-nnnn reference in an assertion message is linked to
   variable issue_url "https://hpc-gridware.atlassian.net/browse"
   # tables a failure exports, with their column prefix
   variable tables {
      sge_host_values      hv
      sge_queue_values     qv
      sge_user_values      uv
      sge_project_values   pv
      sge_statistic_values sv
      sge_job              j
      sge_job_usage        ju
      sge_job_online_usage jou
   }
   # newest rows exported per table
   variable export_rows 5000
}

##
# @brief Create the artifact directory of this run.
#
# The layout follows the one of the throughput test: a per-check directory
# below CHECK_PROTOCOL_DIR holding one directory per run, named
# <version>_<feature>_<time stamp>. The feature of this test is the database it
# ran against, e.g.
#
#   GCS_9.1.5prealpha_postgres_2026-09-15-14-30
#
# The run mode is not part of the name - the time stamp separates runs, and the
# mode is on the summary page.
#
# @return 0 if the directory exists, else -1 (error reported via ts_log_severe)
proc dbwriter_long_artifacts::init {} {
    variable dir
    variable phases
    global CHECK_PROTOCOL_DIR check_name

    set phases {}
    set stamp [clock format [clock seconds] -format "%Y-%m-%d-%H-%M"]
    # spaces and parentheses of a version string would break a directory name
    set version [string map {" " "_" "(" "" ")" ""} [get_version_info]]
    set engine [get_database_type]
    set dir "$CHECK_PROTOCOL_DIR/$check_name/${version}_${engine}_${stamp}"

    if {[catch {file mkdir $dir} msg]} {
       ts_log_severe "dbwriter long test: can not create the artifact directory\
                      $dir: $msg"
       set dir ""
       return -1
    }
    ts_log_fine "dbwriter long test: artifacts of this run go to $dir"
    return 0
}

##
# @brief The artifact directory of this run.
#
# @return the directory, "" if init did not run or failed
proc dbwriter_long_artifacts::path {} {
   variable dir

   return $dir
}

##
# @brief Record the result of a phase and capture artifacts if it failed.
#
# Meant to be the last thing a phase function does:
#
#   return [dbwriter_long_artifacts::finish_phase "phase_g" $rc]
#
# @param phase the phase function name
# @param rc    its return code
# @return rc, unchanged
proc dbwriter_long_artifacts::finish_phase {phase rc} {
   variable phases

   lappend phases [list $phase $rc]
   if {$rc != 0} {
      dbwriter_long_artifacts::capture $phase
   }
   return $rc
}

##
# @brief Put the evidence of a failed phase aside.
#
# Everything lands in a sub-directory named after the phase, so a run in which
# several phases fail keeps the states apart.
#
# @param phase the phase function name
# @return 0 (capturing never fails the test - it reports what it could not get)
proc dbwriter_long_artifacts::capture {phase} {
   variable dir
   get_current_cluster_config_array ts_config

   if {$dir eq ""} {
      ts_log_info "dbwriter long test: no artifact directory, $phase is not\
                   captured"
      return 0
   }

   set target "$dir/$phase"
   if {[catch {file mkdir $target} msg]} {
      ts_log_info "dbwriter long test: can not create $target: $msg"
      return 0
   }
   ts_log_fine "dbwriter long test: capturing the state of $phase in $target"

   set common "$ts_config(product_root)/$ts_config(cell)/common"
   set spool "$ts_config(product_root)/$ts_config(cell)/spool/dbwriter"
   dbwriter_long_artifacts::copy_file "$spool/dbwriter.log" "$target/dbwriter.log"
   dbwriter_long_artifacts::copy_file "$common/accounting" "$target/accounting"
   dbwriter_long_artifacts::copy_file [dbwriter_xml::config_path] \
                                      "$target/dbwriter.xml"
   dbwriter_long_artifacts::export_tables $target

   return 0
}

##
# @brief Copy one file into the artifact directory.
#
# A missing source is reported and skipped: a failure early in the run can hit
# before the dbwriter has written anything, and that must not hide the files
# that are there.
#
# @param src source path
# @param dst destination path
# @return 0 if copied, else -1
proc dbwriter_long_artifacts::copy_file {src dst} {
   if {![file exists $src]} {
      ts_log_info "dbwriter long test: $src does not exist, not captured"
      return -1
   }
   if {[catch {file copy -force $src $dst} msg]} {
      ts_log_info "dbwriter long test: can not capture $src: $msg"
      return -1
   }
   ts_log_fine "dbwriter long test: captured [file tail $dst]\
                ([file size $dst] bytes)"
   return 0
}

##
# @brief Export the newest rows of the tables the assertions read.
#
# The newest rows are the interesting ones: a failure is about what the dbwriter
# did last, and the tables are far too large to export whole - a two day run
# holds more than half a million online_usage rows. Each table goes into its own
# CSV file.
#
# The connection is opened only if the failing phase left none behind, and is
# closed again in that case, so this never takes a connection away from its
# owner.
#
# @param target the directory of this capture
# @return 0
proc dbwriter_long_artifacts::export_tables {target} {
   variable tables
   variable export_rows

   set own_connection 0
   if {![db::is_connected]} {
      if {[db::connect] != 0} {
         ts_log_info "dbwriter long test: no database connection, the tables\
                      are not exported"
         return 0
      }
      set own_connection 1
   }

   foreach {table prefix} $tables {
      dbwriter_long_artifacts::export_table $table $prefix \
         "$target/${table}.csv" $export_rows
   }

   if {$own_connection} {
      db::disconnect
   }
   return 0
}

##
# @brief Export the newest rows of one table as CSV.
#
# @param table  the table to export
# @param prefix the table's column prefix (its id column orders the rows)
# @param file   the CSV file to write
# @param rows   maximum number of rows
# @return 0 if the file was written, else -1
proc dbwriter_long_artifacts::export_table {table prefix file rows} {
   set sql "SELECT * FROM $table ORDER BY ${prefix}_id DESC [db::limit $rows]"
   array set r {}
   set cols {}
   set n [db::query $sql r cols]
   if {$n < 0} {
      ts_log_info "dbwriter long test: can not export $table"
      array unset r
      return -1
   }

   if {[catch {set fh [open $file w]} msg]} {
      ts_log_info "dbwriter long test: can not write $file: $msg"
      array unset r
      return -1
   }
   puts $fh [join $cols ","]
   for {set i 0} {$i < $n} {incr i} {
      set line {}
      for {set c 0} {$c < [llength $cols]} {incr c} {
         set value ""
         if {[info exists r($i,$c)]} {
            set value $r($i,$c)
         }
         # quote what would otherwise break the column separation
         if {[string first "," $value] >= 0 || [string first "\"" $value] >= 0} {
            set value "\"[string map {\" \"\"} $value]\""
         }
         lappend line $value
      }
      puts $fh [join $line ","]
   }
   close $fh
   array unset r

   ts_log_fine "dbwriter long test: exported $n rows of $table"
   return 0
}

##
# @brief The assertion messages a phase produced.
#
# ts_private_log_store_error collects every SEVERE, WARNING and CONFIG of a
# check function in check_errstr, keyed by the function name and formatted as
# "function|check|proc|message". Reading it here means the summary shows what
# the framework recorded, with no second bookkeeping to keep in step.
#
# @param phase the phase function name
# @return a list of message texts, empty if the phase reported nothing
proc dbwriter_long_artifacts::phase_messages {phase} {
   global check_errstr

   if {![info exists check_errstr($phase)]} {
      return {}
   }
   set messages {}
   foreach error $check_errstr($phase) {
      # the message is everything behind the third separator and may itself
      # contain "|", so split off only the first three fields
      lappend messages [join [lrange [split $error "|"] 3 end] "|"]
   }
   return $messages
}

##
# @brief Turn a message into HTML, linking every CS-nnnn it names.
#
# The assertions name the issue a regression would belong to - "CS-1948
# regression", "CS-2012 regression" - so a reader of the summary reaches the
# ticket from the failure without searching for it.
#
# @param message the message text
# @return the escaped message with the issue references linked
proc dbwriter_long_artifacts::link_issues {message} {
   variable issue_url

   set escaped [string map {& &amp; < &lt; > &gt;} $message]
   regsub -all {(CS-[0-9]+)} $escaped "<a href=\"$issue_url/\\1\">\\1</a>" linked
   return $linked
}

##
# @brief Write the summary page of this run.
#
# Called by the cleanup, so it sees every phase. A green run leaves nothing but
# this page, a failed one links to what was captured next to it.
#
# @return 0 if the page was written, else -1
proc dbwriter_long_artifacts::write_index {} {
   variable dir
   variable phases
   get_current_cluster_config_array ts_config

   if {$dir eq ""} {
      return -1
   }

   set engine [get_database_type]
   if {[dbwriter_long::is_fast_mode]} {
      set mode "fast"
   } else {
      set mode "real time"
   }

   set failed 0
   foreach entry $phases {
      if {[lindex $entry 1] != 0} {
         incr failed
      }
   }

   set content ""
   append content "<h2>Run</h2>\n<table border=\"1\" cellpadding=\"4\">\n"
   append content "<tr><td>database</td><td>$engine</td></tr>\n"
   append content "<tr><td>mode</td><td>$mode</td></tr>\n"
   append content "<tr><td>cluster</td><td>$ts_config(master_host)</td></tr>\n"
   append content "<tr><td>finished</td><td>[clock format [clock seconds]\
                   -format {%Y-%m-%d %H:%M:%S}]</td></tr>\n"
   append content "<tr><td>result</td><td>"
   if {$failed == 0} {
      append content "<b>passed</b>"
   } else {
      append content "<b>$failed phase(s) failed</b>"
   }
   append content "</td></tr>\n</table>\n"

   append content "<h2>Phases</h2>\n<table border=\"1\" cellpadding=\"4\">\n"
   append content "<tr><th>phase</th><th>result</th><th>artifacts</th></tr>\n"
   foreach entry $phases {
      lassign $entry phase rc
      append content "<tr><td>$phase</td>"
      if {$rc == 0} {
         append content "<td>passed</td><td></td></tr>\n"
         continue
      }
      append content "<td><b>failed</b></td><td>"
      foreach file [lsort [glob -nocomplain -tails -directory "$dir/$phase" *]] {
         append content "<a href=\"$phase/$file\">$file</a><br>\n"
      }
      append content "</td></tr>\n"
   }
   append content "</table>\n"

   if {$failed > 0} {
      append content "<h2>Reported problems</h2>\n"
      foreach entry $phases {
         lassign $entry phase rc
         if {$rc == 0} {
            continue
         }
         set messages [dbwriter_long_artifacts::phase_messages $phase]
         if {[llength $messages] == 0} {
            continue
         }
         append content "<h3>$phase</h3>\n<ul>\n"
         foreach message $messages {
            append content "<li>[dbwriter_long_artifacts::link_issues $message]</li>\n"
         }
         append content "</ul>\n"
      }
   }

   generate_html_file "$dir/index.html" \
      "dbwriter long running test - $engine ($mode)" $content
   ts_log_fine "dbwriter long test: summary written to $dir/index.html"
   return 0
}
