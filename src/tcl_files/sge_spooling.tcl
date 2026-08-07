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

#****** sge_spooling/spool_db_usage_names() ************************************
#  Internal: BerkeleyDB/PostgreSQL spooling implementation. Uses spooledit to dump the
#  object, then walks the dump looking for UA_name entries inside the
#  requested PR_/UU_ usage list. Returns an empty list on dump failure or
#  empty usage list.
#
#  The dump contains usage names of unrelated lists too (e.g. PR_project,
#  PR_debited_job_usage), so we track which top-level PR_/UU_ field we are
#  currently inside.
#*******************************************************************************
proc spool_db_usage_names {object_type object_name list_name} {
   get_current_cluster_config_array ts_config

   set names {}

   switch -- $object_type {
      "user"    { set prefix "UU"; set dump_tag "USER" }
      "project" { set prefix "PR"; set dump_tag "PROJECT" }
      default {
         ts_log_severe "spool_db_usage_names: unknown object_type \"$object_type\""
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
#  spool_db_usage_names; callers should use this entry point unless they
#  already know which spooling method is in use.
#*******************************************************************************
proc get_spooled_usage_names {object_type object_name list_name} {
   get_current_cluster_config_array ts_config

   if {$ts_config(spooling_method) == "berkeleydb" || $ts_config(spooling_method) == "postgres"} {
      return [spool_db_usage_names $object_type $object_name $list_name]
   } else {
      return [spool_classic_usage_names $object_type $object_name $list_name]
   }
}

# ---------------------------------------------------------------------------
# CS-2522: per cluster PostgreSQL spooling database
#
# ts_config(spool_database) names a *base* database, exactly as
# arco_config(database) does for the dbwriter accounting database. The database
# this cluster actually spools into is derived from the base entry and is called
# spool_<commd_port>, so parallel clusters on one PostgreSQL server never collide.
# The role carries the same name and reuses the base entry's password.
#
# The base entry's user performs the DDL and therefore needs CREATEDB and
# CREATEROLE (or has to be a superuser). sge_qmaster itself connects as the
# per cluster role - inst_qmaster.sh requires database and role to exist and
# only runs "spoolinit init" to create the config and jobs tables.
# ---------------------------------------------------------------------------

##
# @brief Name of the ts_db_config entry holding the base database.
#
# @return the entry name, or "" when postgres spooling is not configured
proc spool_database_get_base_entry {} {
   global ts_config

   if {![info exists ts_config(spool_database)]} {
      return ""
   }
   set entry $ts_config(spool_database)
   if {$entry == "none"} {
      return ""
   }
   return $entry
}

##
# @brief Read one field of the base database entry.
#
# @param field ts_db_config sub-field name, e.g. dbhost, dbport, dbname,
#              username, password
# @return the field's value, or "" when the entry or the field is absent
proc spool_database_get_base_field {field} {
   global ts_db_config

   set entry [spool_database_get_base_entry]
   if {$entry == "" || ![info exists ts_db_config($entry,$field)]} {
      return ""
   }
   return $ts_db_config($entry,$field)
}

##
# @brief Name of this cluster's spooling database.
#
# @return spool_<commd_port>
proc spool_database_get_name {} {
   global ts_config

   return "spool_$ts_config(commd_port)"
}

##
# @brief Name of the role sge_qmaster connects as. Same as the database name.
#
# @return spool_<commd_port>
proc spool_database_get_user {} {
   return [spool_database_get_name]
}

##
# @brief Password of the per cluster role - the base database's password.
#
# @return the password, or "" when none is configured
proc spool_database_get_password {} {
   return [spool_database_get_base_field "password"]
}

##
# @brief Drop and re-create this cluster's spooling database and its role.
#
# Called before the sge_qmaster installation. Dropping first makes the step
# idempotent and gives every run a clean database, which is what the classic and
# berkeleydb spooling methods get for free by deleting $SGE_ROOT/$SGE_CELL.
#
# psql runs on the database host rather than the master host: the database host
# is guaranteed to have psql installed, while the master host may not even have
# a postgres client. The password of the base user is passed via PGPASSWORD so
# it does not show up on the process command line.
#
# @return 0 on success, -1 on error
proc spool_database_init {} {
   global ts_config CHECK_USER

   if {$ts_config(spooling_method) != "postgres"} {
      return 0
   }

   set entry [spool_database_get_base_entry]
   if {$entry == ""} {
      ts_log_severe "spooling_method=postgres but ts_config(spool_database) does not name a base database"
      return -1
   }

   set base_host [spool_database_get_base_field "dbhost"]
   if {$base_host == ""} {
      ts_log_severe "no ts_db_config entry \"$entry\" - cannot create the spooling database"
      return -1
   }
   set base_port [spool_database_get_base_field "dbport"]
   set base_name [spool_database_get_base_field "dbname"]
   set base_user [spool_database_get_base_field "username"]
   set base_pw   [spool_database_get_base_field "password"]

   set db_name [spool_database_get_name]
   set db_user [spool_database_get_user]
   # single quotes inside an SQL string literal are escaped by doubling them
   set db_pw [string map {' ''} [spool_database_get_password]]

   ts_log_fine "creating spooling database $db_name (role $db_user) on $base_host:$base_port"

   # Every statement gets its own -c. psql wraps several statements passed in one
   # -c into a single transaction, and CREATE/DROP DATABASE cannot run inside a
   # transaction block. The order matters as well: the database has to go before
   # the role that owns it, and sessions left behind by a previous run would make
   # DROP DATABASE fail, so they are terminated first.
   set statements {}
   lappend statements "SELECT pg_terminate_backend(pid) FROM pg_stat_activity\
                       WHERE datname = '$db_name' AND pid <> pg_backend_pid()"
   lappend statements "DROP DATABASE IF EXISTS $db_name"
   lappend statements "DROP ROLE IF EXISTS $db_user"
   lappend statements "CREATE ROLE $db_user LOGIN PASSWORD '$db_pw'"
   lappend statements "CREATE DATABASE $db_name OWNER $db_user"

   set args "--no-password -h $base_host -p $base_port -d $base_name -U $base_user -v ON_ERROR_STOP=1"
   foreach statement $statements {
      append args " -c \"$statement\""
   }

   set envlist(PGPASSWORD) $base_pw
   set output [start_remote_prog $base_host $CHECK_USER "psql" $args prg_exit_state 60 0 "" envlist 1 0 0]
   if {$prg_exit_state != 0} {
      ts_log_severe "creating the spooling database $db_name failed:\n$output"
      return -1
   }

   return 0
}
