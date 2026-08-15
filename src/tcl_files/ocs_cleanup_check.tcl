# expect script
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

# ocs_cleanup_check.tcl
#
# CS-984: compare two cluster snapshots (cluster_snapshot_take, ocs_cluster.tcl)
# and say what a test left behind.
#
# The comparison needs no idea of what a default configuration looks like. The
# snapshot taken before the test's setup function IS the definition, and every
# difference after the cleanup function is something the test did not undo. That
# is what makes this stricter than the attribute whitelist it replaces: the
# whitelist tolerated an attribute by name and never looked at its value, which
# is how a foreign execd_spool_dir survived unnoticed (CS-2500).

###
# @brief the object kinds that are compared
#
# Every kind the snapshot covers. The common ones came first and went quiet, so
# the remaining five - checkpoint environments, calendars, roles, the scheduler
# configuration and the share tree - joined them.
#
# @return a list of kind names as used in the snapshot array
##
proc cleanup_check_kinds {} {
   return {
      conf exechost queue pe complex rqs project hgroup userset user
      ckpt calendar role sconf stree
   }
}

###
# @brief the kinds that exist exactly once in a cluster
#
# They have no name of their own - the snapshot files them under the kind name -
# so a finding about them reads better without the "kind \"object\"" shape.
#
# @return a list of {kind label} pairs
##
proc cleanup_check_singletons {} {
   return {
      {sconf "the scheduler configuration"}
      {stree "the share tree"}
   }
}

###
# @brief name one object for a finding message
#
# @param kind   object kind
# @param object object name
# @return "the share tree" for a singleton, otherwise {kind "object"}
##
proc cleanup_check_where {kind object} {
   foreach entry [cleanup_check_singletons] {
      lassign $entry singleton_kind label
      if {$kind eq $singleton_kind} {
         return $label
      }
   }
   return "$kind \"$object\""
}

###
# @brief attributes whose value is a list whose ORDER carries no meaning
#
# qconf writes these as a json array, and the order in it is the qmaster's
# internal one: adding a host to a host group and removing it again leaves the
# remaining names permuted. Comparing them as written would report a difference
# where the configuration is identical.
#
# This is a table and not a rule on the value because ::json::json2dict is lossy
# on types - it returns the array ["a","b"] and the plain string "a b" as the
# very same Tcl value. Sorting anything that merely looks like a list would
# quietly reorder the words inside a command line.
#
# @return the list of attribute names
##
proc cleanup_check_unordered_attributes {} {
   return {
      hostlist entries type login_shells qtype pe_list ckpt_list
      user_lists xuser_lists projects xprojects owner_list
      administrator_mail load_sensor report_variables subordinate_list
      complex_values load_scaling usage_scaling
   }
}

###
# @brief exceptions that hold for every test and every cluster
#
# One entry per rule, {<kind> <object pattern> <attribute pattern>}, matched with
# string match. An EMPTY attribute pattern matches the object's existence only,
# so a rule can say "this object may come and go" without also excusing every
# attribute inside it.
#
# Kept deliberately short. An entry here hides a difference from everybody
# forever, so the bar is "the cluster does this on its own", never "a test we
# have not fixed yet does this" - that is what the per test list is for.
#
# @return the list of rules
##
proc cleanup_check_exceptions {} {
   return {
      {user * delete_time}
   }
}

###
# @brief exceptions derived from this cluster's configuration
#
# The qmaster creates a user object on its own when a job arrives from a user it
# does not know yet, and deletes it again when auto_user_delete_time expires. So
# user objects for the accounts the testsuite submits jobs as appear and vanish
# without any test having done anything wrong, and their delete_time moves while
# they exist. Both were seen in the very first run of the comparison, on tests
# that only manipulate host groups.
#
# This cannot be a static table: the account names come from the testsuite's user
# configuration. Any OTHER user object is a test's doing and stays reportable.
#
# @return the list of rules, in the format of cleanup_check_exceptions
##
proc cleanup_check_cluster_exceptions {} {
   return {}
}

###
# @brief is this user object one the qmaster created on its own?
#
# The qmaster adds a user object when a job arrives from an account it does not
# know yet and deletes it again when auto_user_delete_time expires, so such an
# object appearing or vanishing is not a check's doing.
#
# Told apart by delete_time, not by name: an auto user carries the timestamp at
# which the qmaster will drop it, a user somebody added on purpose has 0. The
# name list this used to be missed every account that was not one of the three
# configured testsuite users - the throughput check submits as "root" as well
# (CS-2589).
#
# @param snap_var name of the snapshot array to look in
# @param object   user name
# @return 1 if the object carries a non-zero delete_time
##
proc cleanup_check_is_auto_user {snap_var object} {
   upvar $snap_var snap

   if {![info exists snap(user,$object,delete_time)]} {
      return 0
   }
   return [expr {[string trim $snap(user,$object,delete_time)] ne "" &&
                 [string trim $snap(user,$object,delete_time)] ne "0"}]
}

###
# @brief kinds that accept no exception at all
#
# Complexes, the scheduler configuration, roles and the share tree tolerate no
# deviation across an upgrade, and the same rule holds here. If one of them ever
# produces noise that is a product question, not an entry to be filed.
#
# @return the list of kind names
##
proc cleanup_check_strict_kinds {} {
   return {complex sconf stree role}
}

###
# @brief may this difference be ignored?
#
# @param kind      object kind as used in the snapshot array
# @param object    object name
# @param attribute attribute name, or "" when the difference is the object's
#                  existence rather than one of its attributes
# @return 1 when a rule covers it
##
proc cleanup_check_is_excepted {kind object attribute} {
   global check_cleanup_expected_changes

   if {[lsearch -exact [cleanup_check_strict_kinds] $kind] >= 0} {
      return 0
   }

   set rules [concat [cleanup_check_exceptions] [cleanup_check_cluster_exceptions]]
   if {[info exists check_cleanup_expected_changes]} {
      set rules [concat $rules $check_cleanup_expected_changes]
   }

   foreach rule $rules {
      lassign $rule rule_kind rule_object rule_attribute
      if {$kind eq $rule_kind &&
          [string match $rule_object $object] &&
          [string match $rule_attribute $attribute]} {
         return 1
      }
   }
   return 0
}

###
# @brief is this value a list of {name value} objects?
#
# qconf writes per host overrides and every name/value collection this way:
#   "slots": [ {"name": "default", "value": 10}, {"name": "h047", "value": 100} ]
# The list order is not stable, so such a value has to be compared as a map.
#
# @param value the parsed json value
# @return 1 if every element is an object with exactly the keys name and value
##
proc cleanup_check_is_name_value_list {value} {
   if {[llength $value] == 0} {
      return 0
   }
   foreach entry $value {
      if {[catch {dict size $entry}]} {
         return 0
      }
      if {[lsort [dict keys $entry]] ne {name value}} {
         return 0
      }
   }
   return 1
}

###
# @brief bring one attribute value into a comparable form
#
# @param attribute the attribute name, used to look up the unordered-list table
# @param value     the parsed json value
# @return a canonical string; two canonical strings are equal exactly when the
#         two configurations are equal
##
proc cleanup_check_canon {attribute value} {
   # An empty value covers the json "" and [] alike - json2dict maps both to the
   # empty Tcl string. For a configuration attribute they mean the same thing,
   # which is also the answer to the old NONE / none / empty question: in json
   # there is only one spelling of "nothing set".
   if {$value eq ""} {
      return ""
   }

   if {[cleanup_check_is_name_value_list $value]} {
      set pairs {}
      foreach entry $value {
         lappend pairs [list [dict get $entry name] \
                             [cleanup_check_canon $attribute [dict get $entry value]]]
      }
      return [lsort -index 0 $pairs]
   }

   if {[lsearch -exact [cleanup_check_unordered_attributes] $attribute] >= 0} {
      return [lsort $value]
   }

   return $value
}

###
# @brief compare two cluster snapshots
#
# @param before_var    name of the snapshot array taken before the test's setup
# @param after_var     name of the snapshot array taken after the test's cleanup
# @param excepted_var  optional name of a variable that receives the number of
#                      differences an exception covered
# @return a list of finding descriptions, empty when the test cleaned up
##
proc cleanup_check_compare {before_var after_var {excepted_var ""}} {
   upvar $before_var before
   upvar $after_var after
   if {$excepted_var ne ""} {
      upvar $excepted_var excepted
   }
   set excepted 0

   set findings {}

   foreach kind [cleanup_check_kinds] {
      # "<kind>,<object>," marks an object that exists, whatever attributes it
      # has - that is what tells "object gone" from "object without attributes".
      set before_objects {}
      foreach key [array names before "$kind,*,"] {
         lappend before_objects [cleanup_check_object_of $kind $key]
      }
      set after_objects {}
      foreach key [array names after "$kind,*,"] {
         lappend after_objects [cleanup_check_object_of $kind $key]
      }

      foreach object [lsort $after_objects] {
         if {[lsearch -exact $before_objects $object] < 0} {
            if {$kind eq "user" && [cleanup_check_is_auto_user after $object]} {
               incr excepted
               continue
            }
            if {[cleanup_check_is_excepted $kind $object ""]} {
               incr excepted
            } else {
               lappend findings "[cleanup_check_where $kind $object] was created and not removed again"
            }
         }
      }
      foreach object [lsort $before_objects] {
         if {[lsearch -exact $after_objects $object] < 0} {
            if {$kind eq "user" && [cleanup_check_is_auto_user before $object]} {
               incr excepted
               continue
            }
            if {[cleanup_check_is_excepted $kind $object ""]} {
               incr excepted
            } else {
               lappend findings "[cleanup_check_where $kind $object] was removed and not restored"
            }
            continue
         }

         # attributes of an object that exists on both sides
         set attributes {}
         foreach key [array names before "$kind,$object,*"] {
            set attribute [cleanup_check_attribute_of $kind $object $key]
            if {$attribute ne ""} {
               lappend attributes $attribute
            }
         }
         foreach key [array names after "$kind,$object,*"] {
            set attribute [cleanup_check_attribute_of $kind $object $key]
            if {$attribute ne "" && [lsearch -exact $attributes $attribute] < 0} {
               lappend attributes $attribute
            }
         }

         foreach attribute [lsort $attributes] {
            if {[cleanup_check_is_excepted $kind $object $attribute]} {
               incr excepted
               continue
            }
            set had [info exists before($kind,$object,$attribute)]
            set has [info exists after($kind,$object,$attribute)]
            if {$had && !$has} {
               lappend findings "[cleanup_check_where $kind $object]: attribute $attribute was removed\
                                 (was \"$before($kind,$object,$attribute)\")"
               continue
            }
            if {!$had && $has} {
               lappend findings "[cleanup_check_where $kind $object]: attribute $attribute was added\
                                 (now \"$after($kind,$object,$attribute)\")"
               continue
            }
            set was [cleanup_check_canon $attribute $before($kind,$object,$attribute)]
            set now [cleanup_check_canon $attribute $after($kind,$object,$attribute)]
            if {$was ne $now} {
               lappend findings "[cleanup_check_where $kind $object]: attribute $attribute changed\
                                 from \"$was\" to \"$now\""
            }
         }
      }
   }

   return $findings
}

###
# @brief the ids in a qstat / qrstat listing
#
# Both print a header line, a line of dashes and then one line per entry that
# starts with the numeric id. Anything else is not an entry.
#
# @param output the command output
# @return the list of ids
##
proc cleanup_check_listed_ids {output} {
   set ids {}
   foreach line [split $output "\n"] {
      set first [lindex [split [string trim $line]] 0]
      if {[string is integer -strict $first]} {
         lappend ids $first
      }
   }
   return $ids
}

###
# @brief which jobs and advance reservations does the cluster hold right now?
#
# Neither has a -S export, so they are asked for directly. The plain qstat view is
# the right notion of "there": a job kept by finished_job_retention has already
# run and is not occupying anything.
#
# @param jobs_var name of the variable that receives the job ids
# @param ars_var  name of the variable that receives the advance reservation ids
# @return 1 when both lists could be read, 0 when a client failed
##
proc cleanup_check_read_jobs_and_ars {jobs_var ars_var} {
   global prg_exit_state
   upvar $jobs_var jobs
   upvar $ars_var ars

   set jobs {}
   set ars {}
   set ret 1

   set output [start_sge_bin "qstat" "-u \"*\"" "" "" prg_exit_state 60]
   if {$prg_exit_state != 0} {
      ts_log_fine "cleanup check: qstat failed, cannot look for jobs:\n$output"
      set ret 0
   } else {
      set jobs [cleanup_check_listed_ids $output]
   }

   set output [start_sge_bin "qrstat" "-u \"*\"" "" "" prg_exit_state 60]
   if {$prg_exit_state != 0} {
      ts_log_fine "cleanup check: qrstat failed, cannot look for advance reservations:\n$output"
      set ret 0
   } else {
      set ars [cleanup_check_listed_ids $output]
   }

   return $ret
}

###
# @brief are there jobs or advance reservations left in the cluster?
#
# An absolute assertion, not a snapshot comparison: no test may leave a job or an
# advance reservation behind, whatever the cluster looked like before. A leftover
# job is also the cleanup failure with the longest reach - it keeps slots occupied
# and makes the NEXT test wait for resources that will never come free.
#
# The expected baseline is therefore always "none", which is why there is nothing
# to compare and no exception to make. The ids present before the test are passed
# in for one purpose only: NOT to charge this test for what it inherited. A test
# that starts on a cluster somebody else left dirty would otherwise report the
# foreign leftover as its own - that is how an unsupported check, which ran
# nothing at all, came to report the reservation of the check before it. Those ids
# are reported separately, against the run rather than against this test.
#
# @param before_jobs ids of the jobs present before the test, empty when unknown
# @param before_ars  ids of the reservations present before the test
# @return a list of finding descriptions, empty when the cluster is clear
##
proc cleanup_check_jobs_and_ars {{before_jobs {}} {before_ars {}}} {
   global check_name

   set findings {}

   cleanup_check_read_jobs_and_ars jobs ars

   foreach {kind after before} [list "job" $jobs $before_jobs \
                                     "advance reservation" $ars $before_ars] {
      set own {}
      set inherited {}
      foreach id $after {
         if {[lsearch -exact $before $id] >= 0} {
            lappend inherited $id
         } else {
            lappend own $id
         }
      }
      if {[llength $own] > 0} {
         lappend findings "[llength $own] ${kind}(s) left in the cluster:\
                           [join $own ", "]"
      }
      if {[llength $inherited] > 0} {
         # Not a finding: the check found them the way it found the cluster. Said
         # out loud all the same, because a cluster that arrives dirty means the
         # check BEFORE this one left something behind and its own report of that
         # is the one to go by.
         ts_log_fine "cleanup check: [llength $inherited] ${kind}(s) were already there\
                      when $check_name started and are not charged to it:\
                      [join $inherited ", "]"
      }
   }

   return $findings
}

###
# @brief the object name out of a "<kind>,<object>," snapshot key
#
# Done by position, not by splitting on commas: object names may contain them.
##
proc cleanup_check_object_of {kind key} {
   set start [expr {[string length $kind] + 1}]
   return [string range $key $start end-1]
}

###
# @brief the attribute name out of a "<kind>,<object>,<attribute>" snapshot key
#
# @return the attribute name, or "" for the "<kind>,<object>," existence marker
##
proc cleanup_check_attribute_of {kind object key} {
   set start [expr {[string length $kind] + [string length $object] + 2}]
   return [string range $key $start end]
}
