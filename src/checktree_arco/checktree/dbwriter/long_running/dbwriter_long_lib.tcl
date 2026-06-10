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

##
# @file dbwriter_long_lib.tcl
# @brief Shared scaffolding for the long-running dbwriter test (CS-2232).
#
# Foundation helpers shared by all phases of the long-running dbwriter
# integration test. Sourced from the test's check.exp.
#
# It provides three namespaces:
#   - dbwriter_long: run-mode (fast vs. real-time) and the helper that
#     registers short-retention deletion rules.
#   - dbwriter_xml: backup / restore / tdom-based edit of the active dbwriter
#     calculation file (dbwriter.xml).
#   - db: a thin engine-aware wrapper around the sqlutil based SQL helpers
#     (sqlutil_create / _connect / _query / _exec).

##
# @namespace dbwriter_long
# @brief Run-mode control for the long-running dbwriter test.
#
# The test has two run modes:
#   - real-time (fast_mode 0): the test runs for several real days so the
#     dbwriter produces hourly and daily derived values and triggers the
#     (shortened) deletion rules on the wall clock.
#   - fast (fast_mode 1): multi-hour and multi-day waits are collapsed so
#     developers can iterate and the nightly CI can run a single phase
#     without real-time waits.
#
# The default is fast_mode 1 so an accidental run never blocks for days;
# the real multi-day run is started explicitly via dbwriter_long::set_fast_mode.
namespace eval dbwriter_long {
   # 1 => collapse long waits (developer / CI), 0 => real-time multi-day run
   variable fast_mode 1
}

##
# @brief Select the run mode of the long-running test.
#
# @param on 1 => fast mode (collapsed waits), 0 => real-time multi-day run
proc dbwriter_long::set_fast_mode {on} {
   variable fast_mode
   set fast_mode [expr {$on ? 1 : 0}]
   ts_log_fine "dbwriter_long: fast_mode = $fast_mode"
}

##
# @brief Query the run mode.
#
# @return 1 if fast mode is active, else 0
proc dbwriter_long::is_fast_mode {} {
   variable fast_mode
   return $fast_mode
}

##
# @brief Sleep, collapsing long waits in fast mode.
#
# Sleeps real_seconds in a real-time run. In fast mode any wait longer than
# a minute is collapsed to 10 seconds so the code path is exercised without
# the real-time delay.
#
# @param real_seconds seconds to wait in a real-time run
# @param reason       optional text logged together with the wait
proc dbwriter_long::wait {real_seconds {reason ""}} {
   variable fast_mode
   if {$fast_mode && $real_seconds > 60} {
      set seconds 10
   } else {
      set seconds $real_seconds
   }
   if {$reason ne ""} {
      ts_log_fine "dbwriter_long: waiting ${seconds}s ($reason)"
   }
   sleep_for_seconds $seconds
}

##
# @brief Shorten all deletion rules to 1-2 days.
#
# Rewrites the deletion rules in the active dbwriter.xml so that all retention
# periods are 1 or 2 days. With the default rules (7 days / 1 month / 1-2
# years) a multi-day test run would never reach the retention boundary. The
# raw-value scopes are shortened to 1 day and the derived-value scopes to
# 2 days, so a run of three or more days observes both the "not yet deleted"
# and the "deleted" state.
#
# dbwriter_xml::backup must have been called first; the original file is put
# back by dbwriter_xml::restore on teardown.
#
# @return 0 if all rules were written, else -1 (error reported via ts_log_severe)
proc dbwriter_long::register_short_retention_rules {} {
   # {scope time_range time_amount {sub_scope ...}}
   # raw-value scopes -> 1 day, derived-value scopes -> 2 days
   set rules {
      {host_values      day 1 {np_load_avg cpu mem_free virtual_free}}
      {host_values      day 2 {}}
      {queue_values     day 1 {slots state}}
      {queue_values     day 2 {}}
      {job              day 2 {}}
      {job_log          day 1 {}}
      {online_usage     day 1 {}}
      {statistic_values day 1 {lines_per_second}}
      {statistic_values day 1 {row_count}}
      {statistic_values day 2 {}}
      {ar_values        day 1 {}}
   }

   foreach rule $rules {
      lassign $rule scope time_range time_amount sub_scopes
      if {[dbwriter_xml::write_delete_rule $scope $time_range $time_amount $sub_scopes] != 0} {
         ts_log_severe "can not register short-retention rule for scope $scope"
         return -1
      }
   }
   ts_log_fine "dbwriter_long: short-retention deletion rules registered"
   return 0
}

##
# @namespace dbwriter_xml
# @brief Backup / restore / edit of the dbwriter calculation file.
#
# The dbwriter reads its derived-value and deletion rules from the calculation
# file dbwriter.xml of the configured database engine
# ($SGE_ROOT/dbwriter/database/<engine>/dbwriter.xml). The test needs to edit
# that file (short-retention deletion rules) and must put the original file
# back on teardown.
#
# The file lives below the shared product root, so plain Tcl file access is
# used - the same assumption startup_dbwriter makes with [file exists].
namespace eval dbwriter_xml {
   # path of the backup created by ::backup ("" => no backup taken)
   variable backup_path ""
}

##
# @brief Path of the active dbwriter.xml.
#
# @return Absolute path of the dbwriter calculation file for the configured
#         database engine.
proc dbwriter_xml::config_path {} {
   get_current_cluster_config_array ts_config
   set engine [get_database_type]
   return "$ts_config(product_root)/dbwriter/database/$engine/dbwriter.xml"
}

##
# @brief Save a pristine copy of dbwriter.xml.
#
# @return 0 if the backup was created, else -1 (error reported via ts_log_severe)
proc dbwriter_xml::backup {} {
   variable backup_path

   set path [dbwriter_xml::config_path]
   if {![file exists $path]} {
      ts_log_severe "can not back up dbwriter calculation file: $path does not exist"
      return -1
   }
   set backup_path "${path}.testsuite_orig"
   if {[catch {file copy -force $path $backup_path} msg]} {
      ts_log_severe "can not back up $path: $msg"
      set backup_path ""
      return -1
   }
   ts_log_fine "dbwriter_xml: backed up $path"
   return 0
}

##
# @brief Put the original dbwriter.xml back.
#
# Restores the file saved by ::backup. Idempotent: calling it when no backup
# exists (or after a previous restore) is a no-op, so aborting the test
# mid-run still leaves the environment in its original state.
#
# @return 0 if restored (or nothing to restore), else -1 (error reported via
#         ts_log_severe)
proc dbwriter_xml::restore {} {
   variable backup_path

   if {$backup_path eq "" || ![file exists $backup_path]} {
      ts_log_fine "dbwriter_xml: nothing to restore"
      set backup_path ""
      return 0
   }
   set path [dbwriter_xml::config_path]
   if {[catch {file copy -force $backup_path $path} msg]} {
      ts_log_severe "can not restore $path: $msg"
      return -1
   }
   file delete -force $backup_path
   set backup_path ""
   ts_log_fine "dbwriter_xml: restored $path"
   return 0
}

##
# @brief Parse the active dbwriter.xml.
#
# Reads and parses the active dbwriter calculation file with tdom.
#
# @return A tdom document handle - the caller is responsible for "$doc delete";
#         "" on error (reported via ts_log_severe).
proc dbwriter_xml::read {} {
   set path [dbwriter_xml::config_path]
   if {![file exists $path]} {
      ts_log_severe "dbwriter calculation file $path does not exist"
      return ""
   }
   set fh [open $path r]
   set content [::read $fh]
   close $fh

   if {[catch {dom parse $content} doc]} {
      ts_log_severe "can not parse $path: $doc"
      return ""
   }
   return $doc
}

##
# @brief Serialize a tdom document back to dbwriter.xml.
#
# @param doc a tdom document handle (as returned by dbwriter_xml::read)
# @return 0 if the file was written, else -1 (error reported via ts_log_severe)
proc dbwriter_xml::write {doc} {
   set path [dbwriter_xml::config_path]
   if {[catch {open $path w} fh]} {
      ts_log_severe "can not write $path: $fh"
      return -1
   }
   puts $fh {<?xml version="1.0" encoding="UTF-8"?>}
   puts $fh [$doc asXML -indent 2]
   close $fh
   return 0
}

##
# @brief Locate a <delete> node.
#
# Returns the <delete> node below root whose scope attribute equals scope and
# whose set of <sub_scope> children equals sub_scopes (compared as a sorted
# set). An empty sub_scopes list matches a rule without sub_scopes.
#
# @param root       the tdom document element to search below
# @param scope      the wanted delete scope
# @param sub_scopes the wanted set of <sub_scope> values (may be empty)
# @return the matching tdom node, or "" if none matches
proc dbwriter_xml::find_delete_rule {root scope sub_scopes} {
   foreach node [$root selectNodes {//delete}] {
      if {[$node getAttribute scope ""] ne $scope} {
         continue
      }
      set node_subs {}
      foreach sub [$node selectNodes sub_scope] {
         lappend node_subs [string trim [$sub text]]
      }
      if {[lsort $node_subs] eq [lsort $sub_scopes]} {
         return $node
      }
   }
   return ""
}

##
# @brief Read a deletion rule's retention.
#
# Convenience accessor for assertions: returns the retention configured for
# the <delete> rule identified by scope and sub_scopes.
#
# @param scope      the delete scope, e.g. "host_values", "job", "ar_values"
# @param sub_scopes optional list of <sub_scope> values identifying the rule
# @return a list {time_range time_amount}, or "" if the rule does not exist
proc dbwriter_xml::get_delete_rule {scope {sub_scopes {}}} {
   set doc [dbwriter_xml::read]
   if {$doc eq ""} {
      return ""
   }
   set node [dbwriter_xml::find_delete_rule [$doc documentElement] $scope $sub_scopes]
   set result ""
   if {$node ne ""} {
      set result [list [$node getAttribute time_range ""] \
                       [$node getAttribute time_amount ""]]
   }
   $doc delete
   return $result
}

##
# @brief List every <derive> rule of a given interval.
#
# Parses the active dbwriter.xml and returns one descriptor per <derive> node
# whose interval matches. Each descriptor is a list {object variable table
# prefix} where table/prefix come from db::value_table_for_object. Rules with
# an unknown object are skipped with a ts_log_severe so a typo in dbwriter.xml
# is visible.
#
# Phase F's "all configured daily rules fired" (CS-2011) check and Phase E's
# rule self-test both walk this list instead of a hard-coded variable set, so
# a new derive rule added to dbwriter.xml is automatically covered.
#
# @param interval the interval to filter on ("hour" or "day")
# @return a list of {object variable table prefix} descriptors, or "" on parse
#         error (reported via ts_log_severe)
proc dbwriter_xml::list_derive_rules {interval} {
   set doc [dbwriter_xml::read]
   if {$doc eq ""} {
      return ""
   }
   set rules {}
   foreach node [[$doc documentElement] selectNodes {//derive}] {
      if {[$node getAttribute interval ""] ne $interval} {
         continue
      }
      set object   [$node getAttribute object   ""]
      set variable [$node getAttribute variable ""]
      if {$object eq "" || $variable eq ""} {
         continue
      }
      set tp [db::value_table_for_object $object]
      if {$tp eq ""} {
         ts_log_severe "dbwriter_xml: unknown <derive> object '$object' for\
                        variable '$variable' - extend\
                        db::value_table_for_object"
         continue
      }
      lassign $tp table prefix
      lappend rules [list $object $variable $table $prefix]
   }
   $doc delete
   return $rules
}

##
# @brief Set a deletion rule's retention.
#
# Sets the retention of the <delete> rule identified by scope and sub_scopes.
# An existing rule is updated in place; if no such rule exists a new <delete>
# element is appended to <DbWriterConfig>. The modified file is written back
# with tdom.
#
# @param scope       the delete scope, e.g. "host_values", "job", "ar_values"
# @param time_range  "day", "month" or "year"
# @param time_amount retention amount (integer)
# @param sub_scopes  optional list of <sub_scope> values identifying the rule
# @return 0 if the rule was written, else -1 (error reported via ts_log_severe)
proc dbwriter_xml::write_delete_rule {scope time_range time_amount {sub_scopes {}}} {
   set doc [dbwriter_xml::read]
   if {$doc eq ""} {
      return -1
   }
   set root [$doc documentElement]
   set node [dbwriter_xml::find_delete_rule $root $scope $sub_scopes]

   if {$node eq ""} {
      # no matching rule - append a new <delete> element
      set node [$doc createElement delete]
      $node setAttribute scope $scope
      foreach sub $sub_scopes {
         set sub_node [$doc createElement sub_scope]
         $sub_node appendChild [$doc createTextNode $sub]
         $node appendChild $sub_node
      }
      $root appendChild $node
      ts_log_fine "dbwriter_xml: added delete rule scope=$scope sub_scopes={$sub_scopes}"
   } else {
      ts_log_fine "dbwriter_xml: updated delete rule scope=$scope sub_scopes={$sub_scopes}"
   }
   $node setAttribute time_range $time_range
   $node setAttribute time_amount $time_amount

   set rc [dbwriter_xml::write $doc]
   $doc delete
   return $rc
}

##
# @namespace db
# @brief Engine-aware SQL helpers for the long-running dbwriter test.
#
# A thin wrapper around the sqlutil based helpers (sqlutil_create,
# sqlutil_connect, sqlutil_query, sqlutil_exec). It keeps a single connection
# in the namespace so the phase functions do not have to pass a spawn id
# around, and provides a hook (db::adapt) for the few places where MySQL,
# PostgreSQL and Oracle differ.
#
# SQL passed to these procs is expected to be written with upper-case
# keywords, matching the project convention.
namespace eval db {
   variable spawn_list ""    ;# result of sqlutil_create ("" => not connected)
   variable sp_id ""         ;# the spawn id used by the sqlutil_* procs
}

##
# @brief Open the ARCO database connection.
#
# @param user optional system user the sqlutil process runs as (defaults to
#             CHECK_USER)
# @return 0 if connected, else -1 (error reported via ts_log_severe)
proc db::connect {{user ""}} {
   variable spawn_list
   variable sp_id

   if {$sp_id ne ""} {
      ts_log_fine "db: already connected"
      return 0
   }
   set spawn_list [sqlutil_create $user]
   if {$spawn_list == "-1"} {
      ts_log_severe "db: can not create sqlutil"
      set spawn_list ""
      return -1
   }
   set sp_id [lindex $spawn_list 1]

   if {[sqlutil_connect $sp_id] != 0} {
      ts_log_severe "db: can not connect to the ARCO database"
      close_spawn_process $spawn_list
      set spawn_list ""
      set sp_id ""
      return -1
   }
   ts_log_fine "db: connected to the ARCO database"
   return 0
}

##
# @brief Close the ARCO database connection.
#
# Closes the sqlutil process. Idempotent - safe to call when not connected.
proc db::disconnect {} {
   variable spawn_list
   variable sp_id

   if {$spawn_list ne ""} {
      close_spawn_process $spawn_list
      ts_log_fine "db: disconnected"
   }
   set spawn_list ""
   set sp_id ""
}

##
# @brief Engine-specific current-timestamp expression.
#
# @return the SQL expression for the current timestamp on the configured engine
proc db::now {} {
   switch -- [get_database_type] {
      oracle  {return "SYSTIMESTAMP"}
      default {return "CURRENT_TIMESTAMP"}
   }
}

##
# @brief Engine-specific "start of today" timestamp expression.
#
# Used by the Phase F CS-1948 assertion: rows with a d_* time_start >= this
# value would belong to the current (still-open) day and must not exist.
#
# Postgres uses LOCALTIMESTAMP (not CURRENT_TIMESTAMP) so the resulting value
# is a timestamp WITHOUT time zone, matching the type of the <pfx>_time_start
# column. With a non-UTC server, comparing a timestamptz to a timestamp would
# shift the boundary by the server's TimeZone offset and either miss real
# CS-1948 rows or false-positive on legitimate ones.
#
# @return the SQL expression for today's day-bucket start on the configured engine
proc db::today_start {} {
   switch -- [get_database_type] {
      postgresql -
      postgres   {return "DATE_TRUNC('day', LOCALTIMESTAMP)"}
      oracle     {return "TRUNC(SYSDATE)"}
      mysql      {return "CURDATE()"}
      default    {return "DATE_TRUNC('day', LOCALTIMESTAMP)"}
   }
}

##
# @brief The SQL expression for the latest ju_end_time the dbwriter's daily
# derived rule is guaranteed to have seen, on the configured engine.
#
# The daily <derive> rule for day D fires at midnight of D+1 + ~11 min and
# SUMs the hourly h_jobs_finished buckets that exist at that moment. The
# hourly bucket for the last hour of D, hour [D 23:00, D+1 00:00), also
# fires at midnight of D+1 + ~11 min - the two rules race. Under a heavy
# ingest load, the daily rule frequently runs before the last-hour hourly
# bucket has been written, so d_jobs_finished for day D systematically
# omits that hour.
#
# Phase F therefore restricts the raw COUNT(*) it compares against
# SUM(d_jobs_finished) to records whose ju_end_time predates the at-risk
# hour by at least one hour. The second-to-last hour's hourly rule fires
# at midnight - 1 h + 11 min, well before the daily rule, so its records
# are reliably accounted for.
#
# @return the SQL expression for "today's day-bucket start, minus one hour"
proc db::daily_rule_cutoff {} {
   switch -- [get_database_type] {
      postgresql -
      postgres   {return "(DATE_TRUNC('day', LOCALTIMESTAMP) - INTERVAL '1 hour')"}
      oracle     {return "(TRUNC(SYSDATE) - 1/24)"}
      mysql      {return "DATE_SUB(CURDATE(), INTERVAL 1 HOUR)"}
      default    {return "(DATE_TRUNC('day', LOCALTIMESTAMP) - INTERVAL '1 hour')"}
   }
}

##
# @brief Apply engine-specific SQL substitutions.
#
# Translates engine-neutral placeholders in sql to the dialect of the
# configured database engine. The recognised placeholders are:
#   - __NOW__               current timestamp (db::now)
#   - __TODAY_START__       start of today's day-bucket (db::today_start)
#   - __DAILY_RULE_CUTOFF__ start of today's day-bucket minus one hour
#                           (db::daily_rule_cutoff) - see there for the
#                           midnight-race rationale
# This proc is the single extension point for further MySQL / PostgreSQL /
# Oracle differences as later phases need them.
#
# @param sql the SQL string with engine-neutral placeholders
# @return the adapted SQL string
proc db::adapt {sql} {
   return [string map [list \
      __NOW__               [db::now] \
      __TODAY_START__       [db::today_start] \
      __DAILY_RULE_CUTOFF__ [db::daily_rule_cutoff]] $sql]
}

##
# @brief The value table and column prefix for a dbwriter derive-rule object.
#
# Maps the object attribute of a <derive> rule in dbwriter.xml (host, user,
# project, queue, statistic) to the value table the dbwriter writes to and
# the prefix every column of that table uses.
#
# @param object the object attribute (host, user, project, queue, statistic)
# @return a list {table prefix}, or "" if the object is unknown
proc db::value_table_for_object {object} {
   switch -- $object {
      host      {return [list sge_host_values      hv]}
      user      {return [list sge_user_values      uv]}
      project   {return [list sge_project_values   pv]}
      queue     {return [list sge_queue_values     qv]}
      statistic {return [list sge_statistic_values sv]}
      default   {return ""}
   }
}

##
# @brief Run a SELECT against the ARCO database.
#
# @param sql       the SELECT statement (upper-case keywords, may use __NOW__)
# @param a_result  name of the array filled with result($row,$col)
# @param a_columns name of the variable filled with the column-name list
# @param timeout   query timeout in seconds
# @return the number of result rows (>= 0), or a negative value on error
proc db::query {sql a_result a_columns {timeout 30}} {
   variable sp_id
   upvar $a_result result
   upvar $a_columns columns

   if {$sp_id eq ""} {
      ts_log_severe "db: not connected"
      return -1
   }
   return [sqlutil_query $sp_id [db::adapt $sql] result columns $timeout]
}

##
# @brief Run a non-SELECT statement against the ARCO database.
#
# @param sql     the statement (upper-case keywords, may use __NOW__)
# @param timeout statement timeout in seconds
# @return 0 if the statement was executed, else a non-zero value
proc db::exec {sql {timeout 30}} {
   variable sp_id

   if {$sp_id eq ""} {
      ts_log_severe "db: not connected"
      return -1
   }
   return [sqlutil_exec $sp_id [db::adapt $sql] $timeout]
}

##
# @brief Count the rows of a table.
#
# @param table the table name
# @param where optional WHERE clause (without the WHERE keyword)
# @return the row count (>= 0), or -1 on error
proc db::count {table {where ""}} {
   set sql "SELECT COUNT(*) FROM $table"
   if {$where ne ""} {
      append sql " WHERE $where"
   }
   array set result {}
   set columns {}
   set rc [db::query $sql result columns]
   if {$rc < 0} {
      return -1
   }
   return $result(0,0)
}

##
# @brief Wait until a table has at least one row.
#
# The dbwriter imports a record some time after qmaster writes it to the
# reporting file, and a parent record (e.g. sge_ar) appears before its
# sub-records (e.g. sge_ar_usage). Callers therefore poll rather than read
# the count once.
#
# @param table   the table name
# @param timeout seconds to wait before giving up (default 300)
# @return 0 once the table has at least one row, -1 on timeout
proc db::wait_for_rows {table {timeout 300}} {
   set deadline [expr {[clock seconds] + $timeout}]
   while {1} {
      set n [db::count $table]
      if {$n > 0} {
         return 0
      }
      if {[clock seconds] >= $deadline} {
         return -1
      }
      ts_log_fine "dbwriter long test: waiting for $table to be imported ($n rows)"
      sleep_for_seconds 15
   }
}
