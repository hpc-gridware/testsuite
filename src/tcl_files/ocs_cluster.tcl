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

###
# @brief may this "qconf -d<obj>" option be given a name list?
#
# Most of them split a comma separated list in every supported version, but five
# of them only do so from 9.2 on. Before that they take exactly ONE name and look
# the whole string up as it stands, so "a,b,c" is denied as a missing object.
#
# Verified against the 9.1.4 parser (clients/qconf/ocs_qconf_parse.cc):
# -dcal, -dckpt and -dp call lSetString() on the single argument, -dq and -dhgrp
# hand it to cqueue_create()/hgroup_create(). The others use lString2List(),
# parse_name_list_to_cull() or sge_strtok() and have always taken lists - note
# that the usage text is no help here, 9.1 already prints "-dq destin_id_list".
#
# @param qconf_opt delete option, e.g. "-dq"
# @return 1 if a list may be sent, 0 if the caller has to loop
##
proc cluster_can_delete_list {qconf_opt} {
   if {[lsearch -exact {-dcal -dckpt -dhgrp -dp -dq} $qconf_opt] < 0} {
      return 1
   }
   return [is_version_in_range "9.2.0"]
}

###
# @brief delete a list of objects with a single qconf request
#
# Where the version takes a name list ("-dq a,b,c") a cleanup loop over N objects
# becomes one request instead of N; where it does not, this falls back to one
# request per object - see cluster_can_delete_list().
#
# The result is taken from the exit status, not from the output, because the
# message based check of handle_sge_errors() cannot judge a list deletion: for
# "del" the success message is registered before the error message and the first
# match wins, so a batch where only some objects were removed still looks like a
# complete success. This is why the generic del_<obj> procedures delegate here
# for a list instead of the other way round.
#
# @param qconf_opt  delete option, e.g. "-dq"
# @param names      list of object names, may be empty
# @param what       object type, for the log and the failure message
# @param on_host    host to start qconf on, default: any
# @param as_user    user to start qconf as, default: CHECK_USER
# @param raise_error do add an error message to the error stack
# @return 1 on success, 0 on failure
##
proc cluster_delete_object_list {qconf_opt names what {on_host ""} {as_user ""} {raise_error 1}} {
   if {[llength $names] == 0} {
      return 1
   }

   if {![cluster_can_delete_list $qconf_opt]} {
      set ret 1
      foreach name $names {
         set output [start_sge_bin "qconf" "$qconf_opt $name" $on_host $as_user]
         if {$prg_exit_state != 0} {
            ts_log_severe "deleting $what $name with qconf $qconf_opt failed:\n$output" $raise_error
            set ret 0
         }
      }
      ts_log_fine "deleted [llength $names] $what with one qconf $qconf_opt request each\
                   (this version does not take a name list)"
      return $ret
   }

   set output [start_sge_bin "qconf" "$qconf_opt [join $names ,]" $on_host $as_user]
   if {$prg_exit_state != 0} {
      ts_log_severe "deleting [llength $names] $what with qconf $qconf_opt failed:\n$output" $raise_error
      return 0
   }
   ts_log_fine "deleted [llength $names] $what with one qconf $qconf_opt request"
   return 1
}

###
# @brief delete a list of objects, returning the convention of handle_sge_errors()
#
# Same as cluster_delete_object_list(), but with the return value a del_<obj>
# procedure has to deliver to its callers, so that it can be returned directly.
#
# @return 0 on success, -1 on failure
##
proc cluster_delete_object_list_errno {qconf_opt names what on_host as_user raise_error} {
   if {[cluster_delete_object_list $qconf_opt $names $what $on_host $as_user $raise_error]} {
      return 0
   }
   return -1
}

###
# @brief is bulk object creation available in the version under test?
#
# 9.2 lets "qconf -A<obj>" take a directory and create everything in it with a
# single request (CS-2299).
#
# @return 1 if qconf understands a directory argument, 0 otherwise
##
proc cluster_use_bulk {} {
   return [is_version_in_range "9.2.0"]
}

###
# @brief open a directory to collect objects for one bulk request
#
# @param[out] local_var set to 1 if the directory is on the local host
# @return the directory path
##
proc cluster_bulk_open {local_var} {
   upvar $local_var is_local

   set host [config_get_best_suited_admin_host]
   set dir [get_tmp_directory_name $host "default" "tmp" 1]
   set is_local [expr {$host eq [gethostname]}]
   if {$is_local} {
      file mkdir $dir
   } else {
      remote_file_mkdir $host $dir
   }
   return $dir
}

###
# @brief send one bulk request for everything collected in the directory
#
# Checks the "N object(s) added/modified, M failed" summary. A partially created
# configuration has to be an error: a test running on it would report numbers
# that look plausible and are quietly wrong.
#
# @param dir       directory from cluster_bulk_open
# @param qconf_opt the add option, e.g. "-Aconf"
# @param expected  number of objects written into the directory
# @return 1 on success, 0 on failure
##
proc cluster_bulk_commit {dir qconf_opt expected} {
   if {$expected == 0} {
      return 1
   }

   set host [config_get_best_suited_admin_host]
   set result [start_sge_bin "qconf" "$qconf_opt $dir" $host]

   set failed -1
   regexp {([0-9]+) failed} $result -> failed
   if {$failed != 0} {
      ts_log_severe "bulk creation of $expected object(s) via qconf $qconf_opt failed\
                     ($failed object(s)):\n$result"
      return 0
   }
   # neutral wording on purpose - the same helper sends -A<obj> (create) and
   # -Me (modify) requests
   ts_log_fine "$expected object(s) in one qconf $qconf_opt request"
   return 1
}

###
# @brief write one local configuration into a bulk directory
#
# Configurations do not go through the object writers of the cs_cluster_* helpers
# and cannot: a configuration object has no name attribute, its host comes from
# the FILE NAME. That is also why every file has to be written separately even
# though one request sends them all.
#
# The values are merged over the configuration the host has now and an empty
# value removes an attribute - the same rule set_config() applies, so that both
# paths produce the same object.
#
# Unlike set_config() a missing configuration is never an error here: the caller
# is creating them, and since CS-2311 "-Aconf" upserts, so it does not need to
# know whether the host had one before.
#
# @param dir          directory from cluster_bulk_open
# @param is_local     1 if the directory is on the local host
# @param host         host the configuration belongs to
# @param change_array name of the array holding the values to set
# @return nothing
##
proc cluster_bulk_write_config {dir is_local host change_array} {
   upvar $change_array chgar
   global CHECK_USER

   unset -nocomplain current_values
   get_config current_values $host 60 0
   foreach elem [array names chgar] {
      if {$chgar($elem) eq ""} {
         unset -nocomplain current_values($elem)
      } else {
         set current_values($elem) $chgar($elem)
      }
   }

   unset -nocomplain data
   dump_array_to_file_data current_values data
   if {$is_local} {
      save_file "$dir/$host" data
   } else {
      write_remote_file [config_get_best_suited_admin_host] $CHECK_USER "$dir/$host" data
   }
}

###
# @brief write one object into a bulk directory
#
# Two things have to be done explicitly here, both of which the per-object add_*
# procedures do internally:
#
#   the defaults, because qconf rejects an object missing a required attribute;
#
#   the NAME, because the attribute arrays the callers build do not carry it -
#   add_pe/add_queue/... take it as a separate argument. A bulk request has no
#   such argument, so without this every object in the directory carries the name
#   from the defaults ("template") and qconf rejects the lot with
#   "Keyword (TEMPLATE) not allowed as objectname".
#
# @param dir           directory from cluster_bulk_open
# @param is_local      as returned by cluster_bulk_open
# @param name          object name, also used as the file name
# @param name_attr     attribute holding the name: qname, pe_name, group_name,
#                      name, hostname - one per object type
# @param defaults_proc set_<obj>_defaults procedure to seed the attributes
# @param attr_array    name of the array holding the caller's attributes
# @return nothing
##
proc cluster_bulk_write_object {dir is_local name name_attr defaults_proc attr_array} {
   upvar $attr_array attrs
   global CHECK_USER

   unset -nocomplain full
   $defaults_proc full
   foreach elem [array names attrs] {
      set full($elem) $attrs($elem)
   }
   set full($name_attr) $name

   unset -nocomplain data
   dump_array_to_file_data full data

   if {$is_local} {
      save_file "$dir/$name" data
   } else {
      write_remote_file [config_get_best_suited_admin_host] $CHECK_USER "$dir/$name" data
   }
}

###
# @brief create several objects of one type that share their attributes
#
# For test setups that need N objects differing only in their name. Before 9.2
# there is no directory request, so the caller has to say how a single object is
# created - that call differs per object type and cannot be derived here.
#
# @param qconf_opt     add option, e.g. "-Aq"
# @param names         object names
# @param name_attr     attribute holding the name, e.g. "qname"
# @param defaults_proc set_<obj>_defaults procedure
# @param attr_array    name of the array with the attributes shared by all of them
# @param add_proc      script for the per object fallback, the name is appended
# @return 1 on success, 0 on failure
##
proc cluster_bulk_add_objects {qconf_opt names name_attr defaults_proc attr_array add_proc} {
   upvar $attr_array attrs

   if {[llength $names] == 0} {
      return 1
   }

   if {![cluster_use_bulk]} {
      foreach name $names {
         uplevel 1 [concat $add_proc [list $name]]
      }
      return 1
   }

   set dir [cluster_bulk_open is_local]
   foreach name $names {
      cluster_bulk_write_object $dir $is_local $name $name_attr $defaults_proc attrs
   }
   return [cluster_bulk_commit $dir $qconf_opt [llength $names]]
}

###
# @brief write one execution host object into a bulk directory
#
# Follows set_exechost(): the values are merged over what the host has now, and
# load_values/processors are dropped because "qconf -Me" refuses to take them
# while get_exechost() reports them.
#
# @param dir          directory from cluster_bulk_open
# @param is_local     1 if the directory is on the local host
# @param host         execution host
# @param change_array name of the array holding the values to set
# @return 1 on success, 0 if the host could not be read
##
proc cluster_bulk_write_exechost {dir is_local host change_array} {
   upvar $change_array chgar
   global CHECK_USER

   unset -nocomplain old_values
   if {[get_exechost old_values $host] != 0} {
      ts_log_severe "cannot read execution host $host for a bulk modification"
      return 0
   }
   foreach elem [array names chgar] {
      set old_values($elem) "$chgar($elem)"
   }
   unset -nocomplain old_values(load_values) old_values(processors)

   unset -nocomplain data
   dump_array_to_file_data old_values data
   if {$is_local} {
      save_file "$dir/$host" data
   } else {
      write_remote_file [config_get_best_suited_admin_host] $CHECK_USER "$dir/$host" data
   }
   return 1
}

###
# @brief set the same values on several execution hosts with one request
#
# Typical use is a test setup raising the capacity of every exec host. Before 9.2
# it falls back to one set_exechost() per host.
#
# @param hosts        list of execution hosts
# @param change_array name of the array holding the values to set on each of them
# @return 1 on success, 0 on failure
##
proc cluster_bulk_mod_exechosts {hosts change_array} {
   upvar $change_array chgar

   if {[llength $hosts] == 0} {
      return 1
   }

   if {![cluster_use_bulk]} {
      set ret 1
      foreach host $hosts {
         if {[set_exechost chgar $host] != 0} {
            set ret 0
         }
      }
      return $ret
   }

   set dir [cluster_bulk_open is_local]
   set count 0
   foreach host $hosts {
      if {[cluster_bulk_write_exechost $dir $is_local $host chgar]} {
         incr count
      }
   }
   return [cluster_bulk_commit $dir "-Me" $count]
}

###
# @brief set one attribute per execution host with one request
#
# The counterpart of cluster_bulk_mod_exechosts() for restoring backed up values,
# where every host gets a different one.
#
# @param hosts       list of execution hosts
# @param attribute   name of the attribute to set, e.g. "complex_values"
# @param value_array name of an array mapping host name to the value for it
# @return 1 on success, 0 on failure
##
proc cluster_bulk_mod_exechosts_attr {hosts attribute value_array} {
   upvar $value_array values

   if {[llength $hosts] == 0} {
      return 1
   }

   if {![cluster_use_bulk]} {
      set ret 1
      foreach host $hosts {
         set chgar($attribute) "$values($host)"
         if {[set_exechost chgar $host] != 0} {
            set ret 0
         }
      }
      return $ret
   }

   set dir [cluster_bulk_open is_local]
   set count 0
   foreach host $hosts {
      set chgar($attribute) "$values($host)"
      if {[cluster_bulk_write_exechost $dir $is_local $host chgar]} {
         incr count
      }
   }
   return [cluster_bulk_commit $dir "-Me" $count]
}

### @brief deletes almost all cluster objects
#
# Deletes all cluster objects except for those ones that cannot be deleted
# because of OCS/GCS requirements (e.g. builtin complexes, global host, ...)
# Might fails if there are dependencies between objects.
# For example, if a queue is still referenced in a different queue (suspend on subordinate)...
#
# Might cause issues if this function is used in tests that do not restore the cluster because
# some objects might be required by the testsuite framework (e.g. configuration objects)
#
proc cluster_delete_all_objects {} {
   cluster_delete_all_queues
   cluster_delete_all_hostgroups
   cluster_delete_all_exechosts
   cluster_delete_all_calendars
   cluster_delete_all_ckpts
   cluster_delete_all_configs
   cluster_delete_all_pes
   cluster_delete_all_projects
   cluster_delete_all_rqss
   cluster_delete_all_users
   cluster_delete_all_usersets

   # builtin complexes and global host cannot be deleted
}

proc cluster_delete_all_queues {} {
   get_queue_list queue_list "" "" 0

   # exit if list is already empty
   if {[llength $queue_list] == 1 && [lindex $queue_list 0] == "no cqueue list defined"} {
      return
   }

   # delete all queues
   cluster_delete_object_list "-dq" $queue_list "cluster queue(s)"
}

proc cluster_delete_all_hostgroups {} {
   get_hostgroup_list hgroup_list "" "" 0

   # exit if list is already empty
   if {[llength $hgroup_list] == 1 && [lindex $hgroup_list 0] == "no host group list defined"} {
      return
   }

   cluster_delete_object_list "-dhgrp" $hgroup_list "host group(s)"
}

proc cluster_delete_all_exechosts {} {
   get_exechost_list exec_host_list "" "" 0

   # exit if list is already empty
   if {[llength $exec_host_list] == 1 && [lindex $exec_host_list 0] == "no execution host defined"} {
      return
   }
   cluster_delete_object_list "-de" $exec_host_list "execution host(s)"
}

proc cluster_delete_all_calendars {} {
   get_calendar_list cal_list "" "" 0

   # exit if list is already empty
   if {[llength $cal_list] == 1 && [lindex $cal_list 0] == "no calendar defined"} {
      return
   }
   cluster_delete_object_list "-dcal" $cal_list "calendar(s)"
}

proc cluster_delete_all_ckpts {} {
   get_ckpt_list ckpt_list "" "" 0

   # exit if list is already empty
   if {[llength $ckpt_list] == 1 && [lindex $ckpt_list 0] == "no ckpt interface definition defined"} {
      return
   }
   cluster_delete_object_list "-dckpt" $ckpt_list "checkpointing interface(s)"
}

proc cluster_delete_all_configs {} {
   get_config_list conf_list "" "" 0

   # exit if list is already empty
   if {[llength $conf_list] == 1 && [lindex $conf_list 0] == "no config defined"} {
      return
   }
   cluster_delete_object_list "-dconf" $conf_list "local configuration(s)"
}

proc cluster_delete_all_pes {} {
   get_pe_list pe_list "" "" 0

   # exit if list is already empty
   if {[llength $pe_list] == 1 && [lindex $pe_list 0] == "no parallel environment defined"} {
      return
   }
   cluster_delete_object_list "-dp" $pe_list "parallel environment(s)"
}

proc cluster_delete_all_projects {} {
   get_project_list project_list "" "" 0

   # exit if list is already empty
   if {[llength $project_list] == 1 && [lindex $project_list 0] == "no project list defined"} {
      return
   }
   cluster_delete_object_list "-dprj" $project_list "project(s)"
}

proc cluster_delete_all_rqss {} {
   get_rqs_list rqs_list "" "" 0

   # exit if list is already empty
   if {[llength $rqs_list] == 1 && [lindex $rqs_list 0] == "no resource quota set list defined"} {
      return
   }
   cluster_delete_object_list "-drqs" $rqs_list "resource quota set(s)"
}

proc cluster_delete_all_users {} {
   global CHECK_USER
   get_user_list user_list "" "" 0

   # exit if list is already empty
   if {[llength $user_list] == 1 && [lindex $user_list 0] == $CHECK_USER} {
      return
   }
   # the testsuite user itself must survive the cleanup
   set to_delete {}
   foreach user_name $user_list {
      if {$user_name != $CHECK_USER} {
         lappend to_delete $user_name
      }
   }
   cluster_delete_object_list "-duser" $to_delete "user(s)"
}

proc cluster_delete_all_usersets {} {
   get_userset_list userset_list "" "" 0

   # exit if list is already empty
   if {[llength $userset_list] == 1 && [lindex $userset_list 0] == "no userset list defined"} {
      return
   }
   cluster_delete_object_list "-dul" $userset_list "userset list(s)"
}

