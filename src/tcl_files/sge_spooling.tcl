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

# Helpers for reading spooled qmaster objects, independent of the configured
# spooling method (classic file or BerkeleyDB).

#****** sge_spooling/spool_classic_usage_names() ********************************
#  Internal: classic file spooling implementation. Reads the spooled object
#  file directly. Returns the attribute names of the given usage list, or an
#  empty list if the spool file does not exist or the usage line is "NONE".
#
#  Classic spool files store usage as a single top-level line:
#      usage             cpu=10.5 mem=100 io=5
#      long_term_usage   cpu=8.0  mem=80  io=4
#  (or the literal "NONE" when empty). The same line format is used for both
#  user and project objects - only the spool subdirectory differs.
#*******************************************************************************
proc spool_classic_usage_names {object_type object_name list_name} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set names {}

   switch -- $object_type {
      "user"    { set subdir "users" }
      "project" { set subdir "projects" }
      default {
         ts_log_severe "spool_classic_usage_names: unknown object_type \"$object_type\""
         return $names
      }
   }

   set spool_file "[get_spool_dir $ts_config(master_host) qmaster]/$subdir/$object_name"

   if {![is_remote_file $ts_config(master_host) $CHECK_USER $spool_file 1]} {
      return $names
   }

   get_file_content $ts_config(master_host) $CHECK_USER $spool_file file_lines
   for {set i 1} {$i <= $file_lines(0)} {incr i} {
      set line [string trim $file_lines($i)]
      #ts_log_fine $line
      if {[lindex $line 0] == $list_name} {
         # everything behind the leading keyword is a space separated list of
         # <name>=<value> tokens (or the literal NONE)
         set value [string trim [string range $line [string length $list_name] end]]
         if {$value != "NONE"} {
            foreach token $value {
               lappend names [lindex [split $token "="] 0]
            }
         }
         break
      }
   }
   return $names
}

#****** sge_spooling/spool_bdb_usage_names() ************************************
#  Internal: BerkeleyDB spooling implementation. Uses spooledit to dump the
#  object, then walks the dump looking for UA_name entries inside the
#  requested PR_/UU_ usage list. Returns an empty list on dump failure or
#  empty usage list.
#
#  The dump contains usage names of unrelated lists too (e.g. PR_project,
#  PR_debited_job_usage), so we track which top-level PR_/UU_ field we are
#  currently inside.
#*******************************************************************************
proc spool_bdb_usage_names {object_type object_name list_name} {
   get_current_cluster_config_array ts_config

   set names {}

   switch -- $object_type {
      "user"    { set prefix "UU"; set dump_tag "USER" }
      "project" { set prefix "PR"; set dump_tag "PROJECT" }
      default {
         ts_log_severe "spool_bdb_usage_names: unknown object_type \"$object_type\""
         return $names
      }
   }

   set field "${prefix}_$list_name"

   set output [start_sge_utilbin "spooledit" "dump $dump_tag:$object_name" $ts_config(master_host)]
   #ts_log_fine $output
   if {$prg_exit_state != 0} {
      # Object does not exist in spool yet, or spooledit had an error.
      # Treat as "no usage entries", which lets the caller distinguish via
      # the returned (empty) list instead of having to handle a hard failure.
      return $names
   }

   set context ""
   foreach line [split $output "\n"] {
      # a cull dump line looks like:  /* <FIELDNAME> */ <value>
      if {[regexp {/\* +([A-Za-z0-9_ ]+?) +\*/} $line -> dumped_field]} {
         # every top level PR_/UU_ field starts a new section
         if {[string match "${prefix}_*" $dumped_field]} {
            set context $dumped_field
         }
      }
      # collect UA_name values, but only while inside the requested list
      if {$context == $field} {
         if {[regexp {/\* +UA_name +\*/ +"([^"]*)"} $line -> name]} {
            lappend names $name
         }
      }
   }
   return $names
}

#****** sge_spooling/get_spooled_usage_names() **********************************
#  Return the attribute names of a spooled object's usage list, regardless of
#  the spooling method configured for the cluster.
#
#  Parameters:
#    object_type - "user" or "project"
#    object_name - the object's name (e.g. CHECK_USER, "myproject")
#    list_name   - "usage" or "long_term_usage"
#
#  Returns:
#    A TCL list of attribute names (e.g. {cpu mem io finished_jobs}).
#    Empty list if the object is not in the spool, has no usage entries,
#    or spooledit dump failed.
#
#  This is a thin dispatcher around spool_classic_usage_names /
#  spool_bdb_usage_names; callers should use this entry point unless they
#  already know which spooling method is in use.
#*******************************************************************************
proc get_spooled_usage_names {object_type object_name list_name} {
   get_current_cluster_config_array ts_config

   if {$ts_config(spooling_method) == "berkeleydb"} {
      return [spool_bdb_usage_names $object_type $object_name $list_name]
   } else {
      return [spool_classic_usage_names $object_type $object_name $list_name]
   }
}
