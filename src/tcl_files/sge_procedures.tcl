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
#  Portions of this code are Copyright 2011 Univa Inc.
#
#  Portions of this software are Copyright (c) 2023-2024 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

global module_name
set module_name "sge_procedures.tcl"

# procedures
#                                                             max. column:     |
# test -- ???
# get_complex_version() -- get information about used qconf version
# get_qmaster_spool_dir() -- return path to qmaster spool directory
# get_execd_spool_dir() -- return spool dir for exec host
# check_messages_files() -- check messages files for errors and warnings
# get_qmaster_messages_file() -- get path to qmaster's messages file
# check_qmaster_messages() -- get qmaster messages file content
# get_schedd_messages_file() -- get path to scheduler's messages file
# check_schedd_messages() -- get schedulers messages file content
# get_execd_messages_file() -- get messages file path of execd
# check_execd_messages() -- get execd messages file content
# start_sge_bin() -- start a sge binary
# start_sge_utilbin() -- start a sge utilbin binary
# start_source_bin() -- start a binary in compile directory
# get_sge_error_generic() -- provide a list of generic error messages
# get_sge_error() -- return error code for sge command
# handle_sge_errors() -- parse error messages from sge commands
# check_for_non_cluster_host_error() -- validate host related error code
# submit_error_job() -- submit job which will get error state
# submit_wait_type_job() -- submit job and wait for accouting info
# submit_time_job() -- Submit a job with execution time
# submit_waitjob_job() -- submit job with hold_jid (wait for other job)
# get_loadsensor_path() -- get loadsensor for host
# get_gid_range() -- get gid range for user
# move_qmaster_spool_dir -- ???
# get_config -- get global or host configuration settings
# set_config -- change global or host specific configuration
# set_config_and_propagate() -- set the config for the given host
# add_exechost -- Add a new exechost configuration object
# get_scheduling_info() -- get scheduling information
# was_job_running -- look for job accounting
# slave_queue_of -- Get the last slave queue of a parallel job
# master_queue_of -- get the master queue of a parallel job
# wait_for_load_from_all_queues -- wait for load value reports from queues
# wait_for_job_state() -- wait for job to become special job state
# wait_for_queue_state() -- wait for queue to become special error state
# soft_execd_shutdown() -- soft shutdown of execd
# wait_for_unknown_load() -- wait for load to get >= 99 for a list of queues
# wait_for_end_of_all_jobs() -- wait for end of all jobs
# mqattr -- Modify queue attributes
# mhattr() -- Modify host qttributes
# mod_attr() -- modify an attribute
# mod_attr_error() -- error handling for mod_attr
# get_attr() -- get an attribute
# del_attr() -- Delete an attribute
# del_attr_error() -- error handling for del_attr_
# add_attr () -- add an attribute
# add_attr_error() -- error handling for add_attr
# replace_attr() -- Replace an attribute
# replace_attr_error() -- error handling for replace_attr
# suspend_job -- set job in suspend state
# unsuspend_job -- set job bakr from unsuspended state
# is_job_id() -- check if job_id is a real sge job id
# delete_job -- delete job with jobid
# submit_job -- submit a job with qsub
# submit_job_parse_job_id() -- parse job id from qsub output
# get_grppid_of_job -- get grppid of job
# get_suspend_state_of_job() -- get suspend state of job from ps command
# get_job_info -- get qstat -ext jobinformation
# get_standard_job_info -- get jobinfo with qstat
# get_extended_job_info -- get extended job information (qstat ..)
# get_qstat_j_info() -- get qstat -j information
# get_qconf_se_info() -- get qconf -se information
# get_qacct_error() -- error handling for get_qacct
# get_qacct -- get job accounting information
# is_job_running -- get run information of job
# get_job_state() -- get job state information
# wait_for_jobstart -- wait for job to get out of pending list
# wait_for_end_of_transfer -- wait transfer end of job
# wait_for_jobpending -- wait for job to get into pending state
# hold_job -- set job in hold state
# release_job -- release job from hold state
# wait_for_jobend -- wait for end of job
# startup_qmaster() -- startup qmaster (and scheduler) daemon
# startup_scheduler() -- ???
# startup_daemon - starts the SGE daemon specified by the argument
# are_master_and_scheduler_running -- ???
# shutdown_master_and_scheduler -- ???
# shutdown_scheduler() -- ???
# is_scheduler_alive() -- ???
# is_qmaster_alive() -- check if qmaster process is running
# is_execd_alive() -- check if execd process is running
# get_qmaster_pid() -- ???
# get_scheduler_pid() -- ???
# get_shadowd_pid() -- ???
# get_execd_pid() -- ???
# get_pid_from_file() -- ???
# shutdown_qmaster() -- ???
# shutdown_all_shadowd -- ???
# shutdown_bdb_rpc -- ???
# is_pid_with_name_existing -- search for process on remote host
# shutdown_system_daemon -- kill running sge daemon
# shutdown_core_system -- shutdown complete cluster
# shutdown_shadowd -- shutdown single shadowd
# shutdown_daemon -- shutdown one sge daemon
# startup_core_system() -- startup complete cluster
# add_operator
# delete_operator
# submit_with_method
# copy_certificates() -- copy csp (ssl) certificates to the specified host
# is_daemon_running
# restore_qtask_file() -- restore qtask file from template
# restore_sge_request_file() -- restore sge_request file from template
# append_to_qtask_file() -- append line(s) to qtask file
# append_to_sge_request_file() -- append line(s) to sge_request file
# get_shared_lib_var() -- get the env var used for the shared lib path
# get_qconf_list() -- return a list from qconf -s* command
# get_scheduler_status () -- get the scheduler status
# get_detached_settings () -- get the detached settings in the cluster  config
# get_event_client_list() -- get the event client list
# trigger_scheduling() -- trigger a scheduler run
# wait_for_job_end() -- waits for a job to leave qmaster
# wait_for_online_usage() -- waits until a job reports online cpu usage
#
#****** sge_procedures/test() ******
#
#  NAME
#     test -- ???
#
#  SYNOPSIS
#     test { m p }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     m - ???
#     p - ???
#
#  RESULT
#     ???
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
proc test {m p} {
   puts "test $m $p"
}

proc ge_get_gridengine_version {} {
   global ts_config CHECK_USER

   if {$ts_config(source_dir) == "none"} {
      ts_log_severe "source directory is set to \"none\" - need source dir for this procedure"
      return ""
   }
   set version_script "$ts_config(testsuite_root_dir)/scripts/sge_version.sh"

   set output [start_remote_prog [gethostname] $CHECK_USER $version_script $ts_config(source_dir)]
   set output [string trim $output]
   regsub -all " " $output "_" output
   return $output
}

#****** sge_procedures/get_complex_version() ***********************************
#  NAME
#     get_complex_version() -- get information about used qconf version
#
#  SYNOPSIS
#     get_complex_version { }
#
#  FUNCTION
#     This procedure returns 0 for qconf supporting complex_list in queue
#     objects, otherwise 1.
#
#  INPUTS
#
#  RESULT
#     0 - qconf supporting complex_list in queue
#     1 - qconf is not supporting complex_list in queue
#
#  SEE ALSO
#*******************************************************************************
proc get_complex_version {} {
   get_current_cluster_config_array ts_config
   set version 0

   ts_log_fine "checking complex version ..."
   set result [start_sge_bin "qconf" "-scl"]
   set INVALID_OPTION [translate $ts_config(master_host) 0 1 0 [sge_macro MSG_ANSWER_INVALIDOPTIONARGX_S] "-scl"]
   set INVALID_OPTION [string trim $INVALID_OPTION]

   if {[string match "*$INVALID_OPTION*" $result] == 1} {
      set version 1
      ts_log_finer "new complex version"
   } else {
      ts_log_finer "old complex version"
   }
   return $version
}


#****** sge_procedures/get_shepherd_pid_list() *********************************
#  NAME
#     get_shepherd_pid_list() -- return list of all running sge_shepherds
#
#  SYNOPSIS
#     get_shepherd_pid_list { user host }
#
#  FUNCTION
#     This procedure is doing a ps on the specified host. After that all pids
#     belonging to the specified user with the command name "sge_shepherd"
#     are returned.
#
#  INPUTS
#     users            - list of users which uid is obtained
#     host             - name of the host where get_ps_info() is called
#     {job_id_list {}} - optional: If the job id of shepherd is known the
#                        returned list will only contain shepherds with
#                        specified job ids.
#
#  RESULT
#     TCL list with pids
#
#  SEE ALSO
#     control_procedures/get_ps_info()
#*******************************************************************************
proc get_shepherd_pid_list { users host {job_id_list {}} } {

   set uid_list {}
   foreach user $users {
      set my_uid [get_uid $user $host]
      ts_log_fine "uid of user \"$user\" on host \"$host\" is \"$my_uid\""
      lappend uid_list $my_uid
   }
   set pid_list {}
   get_ps_info 0 $host ps_info
   for {set i 0} {$i < $ps_info(proc_count) } {incr i 1} {
      if {[string first "sge_shepherd" $ps_info(command,$i)] >= 0} {
         if {[lsearch -exact $uid_list $ps_info(uid,$i)] >= 0} {
            ts_log_finer "ps_info(uid,$i)     = $ps_info(uid,$i)"
            ts_log_finer "ps_info(pid,$i)     = $ps_info(pid,$i)"
            ts_log_finer "ps_info(command,$i) = $ps_info(command,$i)"
            ts_log_fine  "ps_info(string,$i)  = $ps_info(string,$i)"
            if {[llength $job_id_list] > 0} {
               foreach str [split $ps_info(command,$i) "- " ] {
                  if {[string is integer $str]} {
                     set job_id $str
                     if {$job_id > 0} {
                        if {[lsearch -exact $job_id_list $job_id] >= 0} {
                           lappend pid_list $ps_info(pid,$i)
                           ts_log_fine "Found sge_shepherd for job id: \"$job_id\""
                        } else {
                           ts_log_fine "job id \"$job_id\" not in job id list!"
                        }
                        break
                     }
                  }
               }
            } else {
               lappend pid_list $ps_info(pid,$i)
            }
         }
      }
   }
   ts_log_fine "sge_shepherd processes for users \"$users\" on host \"$host\": \"$pid_list\""
   return $pid_list
}


#****** sge_procedures/get_qmaster_spool_dir() *********************************
#  NAME
#     get_qmaster_spool_dir() -- get qmaster spool directory
#
#  SYNOPSIS
#     get_qmaster_spool_dir { }
#
#  FUNCTION
#     This procedure returns the qmaster spool directory string
#
#  INPUTS
#
#  RESULT
#     full path string to qmaster spool directory
#
#  SEE ALSO
#     file_procedures/get_spool_dir()
#*******************************************************************************
proc get_qmaster_spool_dir {} {
   get_current_cluster_config_array ts_config
   return [get_spool_dir $ts_config(master_host) "qmaster"]
}

###
# @brief get feature information for tested Cluster Scheduler (Grid Engine) release
#
# This helper procedure is used to find out if the tested product supports
# the specified feature or not.
#
# The procedure reports an error if an unexpected feature string is used!
#
# @param[in] feature - name of the feature.
#     Supported feature strings are:
#     "new-interactive-job-support"
#     "core-binding"
#     "exclusive-host-usage"
#     "resource-maps"
# @param[in] quiet - if false (0) then the function outputs if the feature is available, else it is quiet
#
# @returns 1 if the feature is available or 0 if the feature is not available or the feature string is invalid
#
global ge_has_feature_cache
unset -nocomplain ge_has_feature_cache
proc ge_has_feature {feature {quiet 0}} {
   get_current_cluster_config_array ts_config
   global CHECK_INTERACTIVE_TRANSPORT
   global CHECK_USER
   global ge_has_feature_cache

   if {[info exists ge_has_feature_cache($feature)]} {
      set cached " Cached"
      set result $ge_has_feature_cache($feature)
   } else {
      set cached ""
      switch -exact $feature {
         "new-interactive-job-support" {
            if {$CHECK_INTERACTIVE_TRANSPORT == "rtools"} {
               set result 0
            } else {
               set result 1
            }
         }
         "core-binding" {
            get_complex complex_array

            if {[info exists complex_array(m_topology)]} {
               set result 1
            } else {
               set result 0
            }
         }
         "resource-maps" {
            set arch [resolve_arch $ts_config(master_host)]
            set binary "$ts_config(product_root)/bin/$arch/sge_qmaster"
            set output [start_remote_prog $ts_config(master_host) $CHECK_USER "strings" "$binary | grep RSMAP"]
            #ts_log_fine $output
            if {$prg_exit_state == 0} {
               set result 1
            } else {
               set result 0
            }
         }
         "scope" {
            set output [start_sge_bin "qsub" "-help"]
            if {[string first "-scope" $output] >= 0} {
               set result 1
            } else {
               set result 0
            }
         }
         "gcs" {
            set output [start_sge_bin "qsub" "-help"]
            if {[string first "GCS" $output] >= 0} {
               set result 1
            } else {
               set result 0
            }
         }
         "ocs" {
            set output [start_sge_bin "qsub" "-help"]
            if {[string first "OCS" $output] >= 0} {
               set result 1
            } else {
               set result 0
            }
         }
         "systemd" {
            start_remote_prog $ts_config(master_host) $CHECK_USER "grep" "RC_FILE=systemd $ts_config(product_root)/util/arch_variables"
            if {$prg_exit_state == 0} {
               set result 1
            } else {
               set result 0
            }
         }
         default {
            ts_log_severe "testsuite error: Unsupported feature string \"$feature\""
            set result 0
         }
      }

      set ge_has_feature_cache($feature) $result
   }

   if {!$quiet} {
      ts_log_fine "**********************************************************************"
      if {$result} {
         ts_log_fine "*$cached Feature \"$feature\" is supported!"
      } else {
         ts_log_fine "*$cached Feature \"$feature\" is NOT supported!"
      }
      ts_log_fine "**********************************************************************"
   }

   return $result
}


#                                                             max. column:     |
#****** sge_procedures/get_execd_spool_dir() ******
#
#  NAME
#     get_execd_spool_dir() -- return spool dir for exec host
#
#  SYNOPSIS
#     get_execd_spool_dir { host }
#
#  FUNCTION
#     This procedure returns the actual execd spool directory on the given host.
#     If no local spool directory is specified for this host, the global
#     configuration is used. If an error accurs the procedure returns "".
#
#  INPUTS
#     host - host name with execd installed on
#
#  RESULT
#     string
#
#  SEE ALSO
#     sge_procedures/get_qmaster_spool_dir()
#*******************************
proc get_execd_spool_dir {host} {
  get_config host_config $host
  if { [info exist host_config(execd_spool_dir) ] == 0 } {
     ts_log_finest "--> no special execd_spool_dir for host $host"
     get_config host_config
  }
  if { [info exist host_config(execd_spool_dir) ] != 0 } {
     set ret [string trimright "$host_config(execd_spool_dir)" "/"]
     return $ret
  } else {
     return "unknown"
  }
}

proc seek_and_destroy_sge_processes {} {
   global ts_host_config CHECK_USER

   set answer_text ""
   if {[info exists kill_list]} {
      unset kill_list
   }

   foreach host $ts_host_config(hostlist) {
      ts_log_fine "host $host ..."

      get_ps_info 0 $host ps_info
      for {set i 0} {$i < $ps_info(proc_count)} {incr i 1} {
         if { [string match "*$CHECK_USER*" $ps_info(string,$i)] } {
            if { [string match "*sge_*" $ps_info(string,$i)]   ||
                 [string match "*qevent*" $ps_info(string,$i)] ||
                 [string match "*qping*" $ps_info(string,$i)]   } {
               puts "ps_info(pid,$i)     = $ps_info(string,$i)"
               append answer_text "host $host: pid $ps_info(pid,$i)\n"
               if {[info exists kill_list($host)]} {
                  lappend kill_list($host) $ps_info(pid,$i)
               } else {
                  set kill_list($host) $ps_info(pid,$i)
               }
            }
         }
      }
   }

   if {$answer_text != ""} {
      ts_log_fine "found matching processes:"
      ts_log_fine "$answer_text"
      foreach host $ts_host_config(hostlist) {
         if {[info exists kill_list($host)]} {
            foreach pid $kill_list($host) {
               ts_log_fine "killing pid $pid on host $host ..."
            }
         }
      }
   }
   wait_for_enter
}

#****** sge_procedures/full_shutdown_and_csp_cleanup() *************************
#  NAME
#     full_shutdown_and_csp_cleanup() -- cleanup on all hosts
#
#  SYNOPSIS
#     full_shutdown_and_csp_cleanup {}
#
#  FUNCTION
#     Does a cleanup on all hosts in the host configuration file:
#     - shutdown of SGE daemons
#     - shutdown of Berkeley DB rpc server
#     - delete CSP certificats of the current cluster
#     - delete contents of local spooldirectories
#*******************************************************************************
proc full_shutdown_and_csp_cleanup {} {
   global ts_host_config
   global CHECK_USER

   get_current_cluster_config_array ts_config

   # we need root access for shutting down daemons
   # and cleaning the /var/sgeCA
   if {[have_root_passwd] == -1} {
      set_root_passwd
   }

   # first do a regular shutdown of our cluster
   shutdown_core_system

   # for each host which is configured in the host config
   # shutdown all sge daemons
   # shutdown berkeleydb rpc server
   # and cleanup csp certificates (/var/sgeCA/...)
   # cleanup the local spool directories
   # TODO: look for processes started with absolute path being our $SGE_ROOT
   foreach host [lsort -dictionary $ts_host_config(hostlist)] {
      # check if host is running and accessable
      start_remote_prog $host $CHECK_USER "echo" "are you there?" prg_exit_state 60 0 "" "" 1 0 0 0
      if {$prg_exit_state != 0} {
         ts_log_info "host $host seems to be unavailable - no cleanup done on host $host"
         continue
      }

      shutdown_system_daemon $host "execd sched qmaster shadowd"
      shutdown_bdb_rpc $host

      ts_log_fine "cleaning /var/sgeCA/port$ts_config(commd_port) on host $host"
      start_remote_prog $host "root" "rm" "-rf /var/sgeCA/port$ts_config(commd_port)"

      get_local_spool_dir $host qmaster 1
      get_local_spool_dir $host execd 1
   }
}

#****** sge_procedures/check_messages_files() **********************************
#  NAME
#     check_messages_files() -- check messages files for errors and warnings
#
#  SYNOPSIS
#     check_messages_files { }
#
#  FUNCTION
#     This procedure reads in all cluster messages files from qmaster and
#     execd and returns the messages with errors or warnings.
#
#  RESULT
#     string with parsed file output
#
#*******************************************************************************
proc check_messages_files {} {
   get_current_cluster_config_array ts_config

   set full_info ""

   foreach host $ts_config(execd_nodes) {
      set status [check_execd_messages $host 1]
      append full_info "\n=========================================\n"
      append full_info "execd: $host\n"
      append full_info "file : [check_execd_messages $host 2]\n"
      append full_info "=========================================\n"
      append full_info $status
   }

   set status [check_qmaster_messages 1]
   append full_info "\n=========================================\n"
   append full_info "qmaster: $ts_config(master_host)\n"
   append full_info "file   : [check_qmaster_messages 2]\n"
   append full_info "=========================================\n"
   append full_info $status
   return $full_info
}


#****** sge_procedures/get_qmaster_messages_file() *****************************
#  NAME
#     get_qmaster_messages_file() -- get path to qmaster's messages file
#
#  SYNOPSIS
#     get_qmaster_messages_file { }
#
#  FUNCTION
#     This procedure returns the path to the running qmaster's messages file
#
#  RESULT
#     path to qmaster's messages file
#
#  SEE ALSO
#     sge_procedures/get_execd_messages_file()
#     sge_procedures/get_schedd_messages_file()
#
#*******************************************************************************
proc get_qmaster_messages_file {} {
   return [check_qmaster_messages 2]
}

#****** sge_procedures/check_qmaster_messages() ********************************
#  NAME
#     check_qmaster_messages() -- get qmaster messages file content
#
#  SYNOPSIS
#     check_qmaster_messages { { show_mode 0 } }
#
#  FUNCTION
#     This procedure locates the qmaster messages file (using qconf -sconf)
#     and returns the output of cat.
#
#  INPUTS
#     { show_mode 0 } - if not 0: return only warning and error lines
#                       if     2: return only path to qmaster messages file
#
#  RESULT
#     output string
#
#  SEE ALSO
#     sge_procedures/check_execd_messages()
#     sge_procedures/check_schedd_messages()
#*******************************************************************************
proc check_qmaster_messages { { show_mode 0 } } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set spool_dir [get_qmaster_spool_dir]

   set messages_file "$spool_dir/messages"

   if { $show_mode == 2 } {
      return $messages_file
   }

   set return_value ""

   get_file_content $ts_config(master_host) $CHECK_USER $messages_file
   for { set i 1 } { $i <= $file_array(0) } { incr i 1 } {
       set line $file_array($i)
       if { ( [ string first "|E|" $line ] >= 0 )   ||
            ( [ string first "|W|" $line ] >= 0 )   ||
            ( $show_mode == 0               )  }   {
            append return_value "line $i: $line\n"
       }
   }
   return $return_value
}

#****** sge_procedures/get_schedd_messages_file() ******************************
#  NAME
#     get_schedd_messages_file() -- get path to scheduler's messages file
#
#  SYNOPSIS
#     get_schedd_messages_file { }
#
#  FUNCTION
#     This procedure returns the path to the running scheduler's messages file
#
#  RESULT
#     path to scheduler's messages file
#
#  SEE ALSO
#     sge_procedures/get_execd_messages_file()
#     sge_procedures/get_qmaster_messages_file()
#*******************************************************************************
proc get_schedd_messages_file { } {
   return [check_schedd_messages 2]
}

#****** sge_procedures/check_schedd_messages() *********************************
#  NAME
#     check_schedd_messages() -- get schedulers messages file content
#
#  SYNOPSIS
#     check_schedd_messages { { show_mode 0 } }
#
#  FUNCTION
#     This procedure locates the schedd messages file (using qconf -sconf)
#     and returns the output of cat.
#
#  INPUTS
#     { show_mode 0 } - if not 0: return only warning and error lines
#                       if     2: return only path to schedd messages file
#
#  RESULT
#     output string
#
#  SEE ALSO
#     sge_procedures/check_execd_messages()
#     sge_procedures/check_qmaster_messages()
#*******************************************************************************
proc check_schedd_messages { { show_mode 0 } } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set spool_dir [get_qmaster_spool_dir]
   # schedd messages are part of the master messages file
   set messages_file "$spool_dir/messages"

   if { $show_mode == 2 } {
      return $messages_file
   }

   set return_value ""

   get_file_content $ts_config(master_host) $CHECK_USER $messages_file
   for { set i 1 } { $i <= $file_array(0) } { incr i 1 } {
       set line $file_array($i)
       if { ( [ string first "|E|" $line ] >= 0 )   ||
            ( [ string first "|W|" $line ] >= 0 )   ||
            ( $show_mode == 0               )  }   {
            append return_value "line $i: $line\n"
       }
   }
   return $return_value
}


#****** sge_procedures/get_execd_messages_file() *******************************
#  NAME
#     get_execd_messages_file() -- get messages file path of execd
#
#  SYNOPSIS
#     get_execd_messages_file { hostname }
#
#  FUNCTION
#     This procedure returns the full path to the given execd's messages file
#
#  INPUTS
#     hostname - hostname where the execd is running
#
#  RESULT
#     path to messages file of the given execd host
#
#  SEE ALSO
#     sge_procedures/get_qmaster_messages_file()
#     sge_procedures/get_schedd_messages_file()
#
#*******************************************************************************
proc get_execd_messages_file { hostname } {
   return [ check_execd_messages $hostname 2 ]
}

#****** sge_procedures/check_execd_messages() **********************************
#  NAME
#     check_execd_messages() -- get execd messages file content
#
#  SYNOPSIS
#     check_execd_messages { hostname { show_mode 0 } }
#
#  FUNCTION
#     This procedure locates the execd messages file (using qconf -sconf)
#     and returns the output of cat.
#
#  INPUTS
#     hostname        - hostname of execd
#     { show_mode 0 } - if not 0: return only warning and error lines
#                       if     2: return only path to execd messages file
#
#  RESULT
#     output string
#
#  SEE ALSO
#     sge_procedures/check_qmaster_messages()
#     sge_procedures/check_schedd_messages()
#*******************************************************************************
proc check_execd_messages { hostname { show_mode 0 } } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set program_arg "-sconf $hostname"
   set output [start_sge_bin "qconf" $program_arg]
   if { [string first "execd_spool_dir" $output ] < 0 } {
      set program_arg "-sconf global"
      set output [start_sge_bin "qconf" $program_arg]
   }

   set output [ split $output "\n" ]
   set spool_dir "unknown"
   foreach line $output {
      if { [ string first "execd_spool_dir" $line ] >= 0 } {
         set spool_dir [ lindex $line 1 ]
      }
   }

   set messages_file "$spool_dir/$hostname/messages"
   if { $show_mode == 2 } {
      return $messages_file
   }

   set return_value ""

   get_file_content $hostname $CHECK_USER $messages_file
   for { set i 1 } { $i <= $file_array(0) } { incr i 1 } {
       set line $file_array($i)
       if { ( [ string first "|E|" $line ] >= 0 ) ||
            ( [ string first "|W|" $line ] >= 0 ) ||
            ( $show_mode == 0 )                }  {
            append return_value "line $i: $line\n"
       }
   }
   return $return_value
}

#****** sge_procedures/start_sge_bin() *****************************************
#  NAME
#     start_sge_bin() -- start a sge binary
#
#  SYNOPSIS
#     start_sge_bin { bin args {host ""} {user ""} {exit_var prg_exit_state}
#     {timeout 60} {sub_path "bin"} }
#
#  FUNCTION
#     Starts a binary in $SGE_ROOT/bin/<arch>
#
#  INPUTS
#     bin                       - binary to start, e.g. qconf
#     args                      - arguments, e.g. "-sel"
#     {host ""}                 - host on which to execute command - default: any host
#     {user ""}                 - user who shall call command
#     {exit_var prg_exit_state} - variable for returning command exit code
#     {timeout 60}              - timeout for command execution
#     {cd_dir ""}               - directory to start command in
#     {sub_path "bin"}          - component of binary path, e.g. "bin" or "utilbin"
#     {line_array output_lines} - array containing output lines
#                                 Note: nr of lines = $output_lines(0)
#                                       first line  = $output_lines(1)
#     {env_list ""}             - users envlist
#
#  RESULT
#     Output of called command.
#     The exit code will be placed in exit_var.
#
#  SEE ALSO
#     sge_procedures/start_sge_utilbin()
#     remote_procedures/start_remote_prog()
#*******************************************************************************
proc start_sge_bin {bin args {host ""} {user ""} {exit_var prg_exit_state} {timeout 60} {cd_dir ""} {sub_path "bin"} {line_array output_lines} {env_list ""} {new_grp ""}} {
   global CHECK_USER
   global CHECK_DISPLAY_OUTPUT
   global check_category

   upvar $exit_var exit_state
   upvar $line_array line_buf

   if {$env_list != ""} {
      upvar $env_list envlist
   }

   get_current_cluster_config_array ts_config

   if {$host == ""} {
      set host [host_conf_get_suited_hosts]
      ts_log_finer "starting \"$bin $args\" on host \"$host\"!"
   }

   if {$user == ""} {
      set user $CHECK_USER
   }

   if { [info exists check_category] == 1 } {
      set USE_CLIENT [string match "*USE_CLI*" $check_category]
   } else {
      set USE_CLIENT 0
   }

   #We allow only qconf and qstat and exlude broken options that cause critical failures
   #LP disabled qstat due to crashing issues
   if { !([string compare "qconf" $bin] == 0) ||
        [string match "*-kec *" $args] ||
        [string match "*-Msconf *" $args] ||
        [string match "*-msconf *" $args] ||
        [string match "*-aattr *" $args] ||
        ([string compare "qstat" $bin] && [string match "*-j *" $args]) } {
        set USE_CLIENT 1
   }

   # We test only qconf and qstat for now
   set arch [resolve_arch $host]
   set ret 0
   set binary "$ts_config(product_root)/$sub_path/$arch/$bin"

   if {[string compare $bin "qsh"] == 0 && [string compare $CHECK_DISPLAY_OUTPUT ""] != 0} {
      #We should always use CHECK_DISPLAY_OUTPUT when available
      ts_log_fine "setting DISPLAY=$CHECK_DISPLAY_OUTPUT"
      set envlist(DISPLAY) $CHECK_DISPLAY_OUTPUT
   }

   ts_log_finest "executing $binary $args\nas user $user on host $host"
   # Add " around $args if there are more the 1 args....
   set result [start_remote_prog $host $user $binary "$args" exit_state $timeout 0 $cd_dir envlist 1 1 0 1 0 0 $new_grp]

   ts_log_finer "result:\n\"$result\""

   if {[info exists line_buf]} {
      unset line_buf
   }
   if {![info exists result]} {
      return ""
   }
   set help_res [split $result "\n"]
   set index 1
   foreach hr $help_res {
      set line_buf($index) [string trim $hr]
      incr index 1
   }
   incr index -1
   set line_buf(0) $index
   return $result
}

#****** sge_procedures/start_sge_utilbin() *************************************
#  NAME
#     start_sge_utilbin() -- start a sge utilbin binary
#
#  SYNOPSIS
#     start_sge_utilbin { bin args {host ""} {user ""}
#     {exit_var prg_exit_state} }
#
#  FUNCTION
#     Starts a binary in $SGE_ROOT/utilbin/<arch>
#
#  INPUTS
#     bin                       - command to start
#     args                      - arguments for command
#     {host ""}                 - host on which to start command - default: any host
#     {user ""}                 - user who shall start command
#     {exit_var prg_exit_state} - variable for returning command exit code
#     {timeout 60}              - timeout for command execution
#     {cd_dir ""}               - directory to start command in
#
#  RESULT
#     Output of called command.
#     The exit code will be placed in exit_var.
#
#  SEE ALSO
#     sge_procedures/start_sge_bin()
#*******************************************************************************
proc start_sge_utilbin {bin args {host ""} {user ""} {exit_var prg_exit_state} {timeout 60} {cd_dir ""}} {
   upvar $exit_var exit_state

   return [start_sge_bin $bin $args $host $user exit_state $timeout $cd_dir "utilbin"]
}

proc get_source_path {bin host} {
   get_current_cluster_config_array ts_config

   set arch [resolve_build_arch_installed_libs $host]
   set source_path "$ts_config(source_dir)/$arch/$bin"

   return $source_path
}

#****** sge_procedures/start_source_bin() *****************************************
#  NAME
#     start_source_bin() -- start a binary in compile directory
#
#  SYNOPSIS
#     start_source_bin { bin args {host ""} {user ""} {exit_var prg_exit_state}
#     {timeout 60} {sub_path "bin"} }
#
#  FUNCTION
#     Starts a binary in the compile directory (clusterscheduler/source/$buildarch).
#
#  INPUTS
#     bin                       - binary to start, e.g. test_drmaa
#     args                      - arguments, e.g. "-sel"
#     {host ""}                 - host on which to execute command - default: any host
#     {user ""}                 - user who shall call command
#     {exit_var prg_exit_state} - variable for returning command exit code
#     {timeout 60}              - timeout for command execution
#
#  RESULT
#     Output of called command.
#     The exit code will be placed in exit_var.
#
#  SEE ALSO
#     sge_procedures/start_sge_bin()
#     remote_procedures/start_remote_prog()
#*******************************************************************************
proc start_source_bin {bin args {host ""} {user ""} {exit_var prg_exit_state} {timeout 60} {background 0} {envlist ""}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   upvar $exit_var exit_state

   if {$ts_config(source_dir) == "none"} {
      ts_log_severe "source directory is set to \"none\" - need source directory for this procedure"
      set exit_state 123456789
      return "source directory is set to \"none\" - need source directory for this procedure"
   }

   # pass on environment
   set env_var ""
   if {$envlist != ""} {
      upvar $envlist env
      set env_var env
   }

   if {$host == ""} {
      set host [host_conf_get_suited_hosts]
   }

   if {$user == ""} {
      set user $CHECK_USER
   }

   set bin_path [get_source_path $bin $host]

   ts_log_finest "executing $bin_path $args\nas user $user on host $host"
   # Add " around $args if there are more the 1 args....
   set result [start_remote_prog $host $user $bin_path "$args" exit_state $timeout $background "" $env_var 1 0 1]

   return $result
}

proc get_test_path {bin host} {
   get_current_cluster_config_array ts_config

   set arch [resolve_arch $host]
   set test_bin "$ts_config(product_root)/testbin/$arch/$bin"

   return $test_bin
}

proc get_test_or_source_path {bin host} {
   global CHECK_USER

   set path [get_test_path $bin $host]
   if {![is_remote_file $host $CHECK_USER $path]} {
      set path [get_source_path $bin $host]
   }

   return $path
}

proc start_test_bin {bin args {host ""} {user ""} {exit_var prg_exit_state} {timeout 60} {envlist_var ""}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   upvar $exit_var prg_exit_state

   if {$envlist_var != ""} {
      upvar $envlist_var envlist
   }

   if {$host == ""} {
      set host [host_conf_get_suited_hosts]
   }

   set test_bin [get_test_path $bin $host]
   if {[is_remote_file $host $CHECK_USER $test_bin]} {
      ts_log_finer "found test binary $test_bin"
      set output [start_sge_bin $bin $args $host $user prg_exit_state $timeout "" "testbin" output_lines envlist]
   } else {
      ts_log_finer "didn't find test binary $test_bin - trying to start from aimk build"
      set output [start_source_bin $bin $args $host $user prg_exit_state $timeout 0 envlist]
   }

   return $output
}

#****** sge_procedures/get_sge_error_generic() *********************************
#  NAME
#     get_sge_error_generic() -- provide a list of generic error messages
#
#  SYNOPSIS
#     get_sge_error_generic { messages_var }
#
#  FUNCTION
#     The function builds a list of SGE generic error messages, i.e. messages
#     that might be returned by any SGE command, for example, if the qmaster
#     cannot be contacted.
#
#     Messages that are common to multiple SGE versions are added directly in
#     this function.
#     For version specific messages, a function get_sge_error_generic_vdep
#     is called.
#     get_sge_error_generic_vdep is implemented in the version specific
#     sge_procedures files (sge_procedures.80.tcl, sge_procedures.81.tcl, ...).
#
#  INPUTS
#     messages_var - TCL array containing error message description, see
#                    sge_procedures/handle_sge_errors().
#
#  NOTES
#     A list of all generic error messages is maintained in the ADOC header
#     for sge_procedures/get_sge_error().
#     If you add messages here or in the version specific functions, please
#     document them in the sge_procedures/get_sge_error() ADOC header.
#
#  SEE ALSO
#     sge_procedures/get_sge_error()
#*******************************************************************************
global g_generic_messages
unset -nocomplain g_generic_messages

proc init_global_generic_messages {} {
   get_current_cluster_config_array ts_config

   global g_generic_messages
   unset -nocomplain g_generic_messages

   upvar 0 g_generic_messages messages
   ts_log_fine "get_sge_error_generic: translating messages"

   # CSP errors
   lappend messages(index) "-100"
   set messages(-100) "*[translate_macro MSG_CL_RETVAL_SSL_COULD_NOT_SET_CA_CHAIN_FILE]*"

   # generic communication errors
   lappend messages(index) "-120"
   set messages(-120) "*[translate_macro MSG_GDI_UNABLE_TO_CONNECT_SUS "qmaster" "*" "*"]*"
   set messages(-120,description) "probably sge_qmaster is down"

   lappend messages(index) "-121"
   set messages(-121) "*[translate_macro MSG_GDI_CANT_SEND_MSG_TO_PORT_ON_HOST_SUSS "qmaster" "*" "*" "*"]*"
   set messages(-121,description) "probably sge_qmaster is down"

   # messages indicating insufficient host privileges
   lappend messages(index) -200
   lappend messages(index) -201
   lappend messages(index) -202
   set messages(-200) "*[translate_macro MSG_SGETEXT_NOSUBMITORADMINHOST_S "*"]"
   set messages(-201) "*[translate_macro MSG_SGETEXT_NOADMINHOST_S "*"]"
   set messages(-202) "*[translate_macro MSG_SGETEXT_NOSUBMITHOST_S "*"]"

   # messages indicating insufficient user privileges
   lappend messages(index) -210
   lappend messages(index) -211
   set messages(-210) "*[translate_macro MSG_SGETEXT_MUSTBEMANAGER_S "*"]"
   set messages(-211) "*[translate_macro MSG_SGETEXT_MUSTBEOPERATOR_S "*"]"

   if {$ts_config(gridengine_version) > 90} {
      lappend messages(index) -212
      lappend messages(index) -213
      lappend messages(index) -214
      lappend messages(index) -215
      set messages(-212) "*[translate_macro MSG_SGETEXT_MUSTBEMANAGERFOROP_SS "*" "*"]"
      set messages(-213) "*[translate_macro MSG_SGETEXT_MUSTBEOPERATORFOROP_SS "*" "*"]"
      set messages(-214) "*[translate_macro MSG_SGETEXT_MUSTBEMANAGERFORTAR_SS "*" "*"]"
      set messages(-215) "*[translate_macro MSG_SGETEXT_MUSTBEOPERATORFORTAR_SS "*" "*"]"
   }

   # file io problems
   lappend messages(index) -300
   set bootstrap "$ts_config(product_root)/$ts_config(cell)/common/bootstrap"
   set messages(-300) "*[translate_macro MSG_FILE_FOPENFAILED_SS $bootstrap "*"]"

   lappend messages(index) -301
   set act_qmaster "$ts_config(product_root)/$ts_config(cell)/common/act_qmaster"
   set messages(-301) "*[translate_macro MSG_FILE_FOPENFAILED_SS $act_qmaster "*"]"

   lappend messages(index) -900
   lappend messages(index) -901
   set messages(-900) "*?egmentation ?ault*"
   set messages(-901) "*?ore ?umped*"

   get_sge_error_generic_vdep messages
}

proc get_sge_error_generic {messages_var} {
   get_current_cluster_config_array ts_config
   global g_generic_messages

   upvar 0 g_generic_messages messages

   if {![info exists messages(index)]} {
      init_global_generic_messages
   }

   # copy the messages to the target array
   upvar $messages_var copy
   foreach idx $messages(index) {
      set copy($idx) $messages($idx)
      lappend copy(index) $idx
   }
   # remove possible duplicates
   set copy(index) [lsort -unique $copy(index)]
}

# STUB for version dependent messages generation
# include and fill it out in sge_procedures.<version>.tcl
# ADOC see sge_procedures/get_sge_error_generic()
proc get_sge_error_generic_vdep {messages_var} {
#   upvar $messages_var messages

#   lappend messages(index) "-100"
#   set messages(-100) "*[translate_macro MSG_SEC_KEYFILENOTFOUND_S "*"]"
}




#****** sge_procedures/get_act_qaster() ****************************************
#  NAME
#     get_act_qaster() -- Get content of act_qmaster file
#
#  SYNOPSIS
#     get_act_qaster { {used_file_path ""} {raise_error 1} }
#
#  FUNCTION
#     This procedure checks and reads the act_qmaster file and returns the
#     current qmaster host which is stored in the act_qmaster file. The
#     act_qmaster file path is returned if the optional parameter used_file_path
#     is set to a tcl variable name where the path should be stored.
#     Standard path of act_qmaster file is $SGE_ROOT/$SGE_CELL/common/act_qmaster
#
#  INPUTS
#     {used_file_path ""} - Name of a TCL variable where the used path should
#                           be saved
#     {raise_error 1}     - if 1 report errors, else ingnore errors
#
#  RESULT
#     The name of the actual qmaster from the act_qmaster file
#*******************************************************************************
proc get_act_qaster { {used_file_path ""} {raise_error 1} } {
   global CHECK_USER
   global ts_config
   if {$used_file_path != ""} {
      upvar $used_file_path act_qmaster_file_path
   }
   set error_text ""
   # get path to act_qmaster file
   set act_qmaster_file_path $ts_config(product_root)/$ts_config(cell)/common/act_qmaster

   # check if act_qmaster file is available
   if {[is_remote_file $ts_config(master_host) $CHECK_USER $act_qmaster_file_path] != 1} {
      append error_text "file $act_qmaster_file_path not found!\n"
   }

   # read act_qmaster file
   get_file_content $ts_config(master_host) $CHECK_USER $act_qmaster_file_path act_qmaster_file
   set act_qmaster_file_content "n.a."
   # check if content is exactly one line
   if {$act_qmaster_file(0) != 1} {
      append error_text "file $act_qmaster_file_path has $act_qmaster_file(0) lines!\n"
   } else {
      set act_qmaster_file_content [string trim $act_qmaster_file(1)]
      ts_log_fine "act_qmaster file content: \"$act_qmaster_file_content\""
   }

   if {$error_text != ""} {
      ts_log_severe $error_text $raise_error
   }


   return $act_qmaster_file_content
}


#****** sge_procedures/get_sge_error() *****************************************
#  NAME
#     get_sge_error() -- return error code for sge command
#
#  SYNOPSIS
#     get_sge_error { procedure command result {raise_error 1} }
#
#  FUNCTION
#     Parses the result of a sge command and tries to find certain known
#     error messages.
#     If an error message is recognized in result, a specific error message
#     will be returned.
#     If result doesn't contain a known error message, -999 will be returned.
#
#     If requested (raise_error), an error situation will be raised.
#
#     Error codes are grouped by error situation:
#        - 100-199: communication errors
#        - 200-299: permission specific error messages
#        - 300-399: file io problems
#        - 900-999: other errors
#
#     List of error codes:
#        -100: CSP certificate expired or invalid (or not existing)
#        -120: qmaster cannot be contacted
#
#        -200: host executing command is no admin or submit host
#        -201: host executing command is no admin host
#        -202: host executing command is no submit host
#        -210: user executing command is no manager
#        -210: user executing command is no operator
#
#        -300: cannot open bootstrap file
#        -301: cannot open act_qmaster file
#        -900: Segmentation fault
#        -901: core dumped
#
#  INPUTS
#     procedure       - name of the calling procedure (for error message)
#     command         - executed command (for error message)
#     result          - output of a SGE command
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#     -999, or specific error code, see above
#
#  SEE ALSO
#     sge_procedures/handle_sge_errors()
#*******************************************************************************
proc get_sge_error {procedure command result {raise_error 1}} {
   # initialize array.
   # handle_sge_errors will add the sge generic messages
   set messages(index) {}

   # parse error messages and map to return code
   set ret [handle_sge_errors $procedure $command $result messages $raise_error]
   return $ret
}

#****** sge_procedures/handle_sge_errors() *************************************
#  NAME
#     handle_sge_errors() -- parse error messages from sge commands
#
#  SYNOPSIS
#     handle_sge_errors { procedure command result messages_var {raise_error 1}
#     }
#
#  FUNCTION
#     Parse error messages and raise an error condition, if
#     this is required.
#
#     Which messages can be recognized, a highlevel description and error
#     code are passed in the variable referenced by messages_var.
#     This variable is a TCL array containing the following fields:
#     - "index", containing all possible error codes
#     - <error_code>, containing the message for a certain error code
#     - <error_code,description>, a highlevel description for the error
#     - <error_code,level>, the error level for ts_log (SEVERE, WARNING, ...)
#
#     handle_sge_errors will add generic sge error messages to the list of
#     application specific error messages provided by the caller.
#
#     For application specific error messages, a range from -1 to -99 is reserved.
#     For a list of the generic error messages, see sge_procedures/get_sge_error().
#
#  INPUTS
#     procedure       - name of the procedure calling the function
#                       (for error output)
#     command         - sge command that had been called (for error output)
#     result          - output of the command
#     messages_var    - array with possible messages and info how to handle them
#     {raise_error 1} - whether to raise an error condition
#                       or not
#     {prg_exit_state ""} - exit state of sge command
#     {ignore_id_list {}} - ignore errors inside list
#
#  RESULT
#     error code, for recognized messages the corresponding error code from
#                 messages array, or -999, if the error message is not contained
#                 in messages array
#
#  EXAMPLE
#     set messages(index) "-1 -2"
#     set messages(-1) [translate_macro MSG_SGETEXT_CANTRESOLVEHOST_S $host]
#     set messages(-2) [translate_macro MSG_EXEC_XISNOTANEXECUTIONHOST_S $host]
#     set messages(-2,description) "$host is not configured as exec host"
#     set messages(-2,level) CONFIG    ;# we only raise an configuration warning
#     set ret [handle_sge_errors "get_exechost" "qconf -se $host" $result
#              messages $raise_error]
#
#  SEE ALSO
#     logging/ts_log()
#     sge_procedures/get_sge_error()
#*******************************************************************************
proc handle_sge_errors {procedure command result messages_var {raise_error 1} {prg_exit_state ""} {ignore_id_list {}}} {
   upvar $messages_var messages

   set ret -999

   # add sge generic error messages to the array of specific error messages
   get_sge_error_generic messages

   # remove trailing garbage
   set result [string trim $result]
   # try to find error message
   foreach errno $messages(index) {
      if {[lsearch -exact $ignore_id_list $errno] != -1} {
         ts_log_fine "ignoring errno=$errno"
         continue
      }
      if {[string match "*$messages($errno)*" $result]} {
         set ret $errno
         break
      }
   }

   # in case of errors, do error reporting
   if {$ret < 0} {
      set error_level SEVERE
      set error_message "$command failed ($ret):\n"

      if {$ret == -999} {
         append error_message "$result"
      } else {
         # we might have a high level error description
         if {[info exists messages($ret,description)]} {
            append error_message "$messages($ret,description)\n"
            append error_message "command output was:\n"
         }

         append error_message "$result"

         # we might have a special error level (error, warning, unsupported)
         if {[info exists messages($ret,level)]} {
            set error_level $messages($ret,level)
         }
      }

      # generate error message or just informational/error output
      ts_log $error_level $error_message $raise_error $procedure

      if {$prg_exit_state != ""} {
         if {$prg_exit_state == 0 && $ret < 0} {
            ts_log_info "$command returned 0 while reporting the error message:\n$result"
         }
         if {$prg_exit_state != 0 && $ret >= 0} {
            ts_log_info "$command returned error state while its output reports success:\n$result"
         }
      }
   }

   if {$ret == -999} {
      ts_log_fine "output: $result"
   }

   return $ret
}

#****** sge_procedures/check_for_non_cluster_host_error() **********************
#  NAME
#     check_for_non_cluster_host_error() -- validate host related error code
#
#  SYNOPSIS
#     check_for_non_cluster_host_error { errno access }
#
#  FUNCTION
#     For certain SGE operations, host privileges are needed, e.g. modifying
#     an exec host object requires admin host privileges.
#
#     This function has a look at an error code (returned from a SGE command),
#     and validates it according to certain privileges.
#
#     Privileges are "admin" (for admin host), "submit" (for submit host),
#     and "any" (submit or admin host).
#
#     Special handling for CSP: In csp mode, on a non cluster host,
#     no certificates are installed. Therefore establishing a connection to
#     qmaster will fail, even before qmaster could check the host privileges.
#
#  INPUTS
#     errno  - return code from handle_sge_errors
#     access - "admin", "submit", or "any"
#
#  RESULT
#     1, if the error code is the expected one, else 0
#
#  SEE ALSO
#     sge_procedures/handle_sge_error()
#*******************************************************************************
proc check_for_non_cluster_host_error {errno access} {
   get_current_cluster_config_array ts_config

   # in csp mode, a non cluster host will get csp error
   if {$ts_config(product_feature) == "csp" && $errno == -100} {
      return 1
   }

   # look for error code specific to certain host properties missing
   switch -exact $access {
      "submit" {
         if {$errno == -202} {
            return 1
         }
      }
      "admin" {
         if {$errno == -201} {
            return 1
         }
      }
      "any" {
         if {$errno == -200} {
            return 1
         }
      }
   }

   # error code didn't match scenario
   return 0
}

#****** sge_procedures/submit_error_job() **************************************
#  NAME
#     submit_error_job() -- submit job which will get error state
#
#  SYNOPSIS
#     submit_error_job { jobargs }
#
#  FUNCTION
#     This procedure is submitting a job with a wrong shell option (-S). This
#     will set the job in error state. (E)
#
#  INPUTS
#     jobargs - job arguments (e.g. -o ... -e ... jobscript path)
#
#  RESULT
#     job id
#
#  SEE ALSO
#     sge_procedures/submit_error_job()
#     sge_procedures/submit_waitjob_job()
#     sge_procedures/submit_time_job()
#*******************************************************************************
proc submit_error_job { jobargs } {
    return [submit_job "-S __no_shell $jobargs"]
}

#****** sge_procedures/submit_wait_type_job() **********************************
#  NAME
#     submit_wait_type_job() -- submit job and wait for accouting info
#
#  SYNOPSIS
#     submit_wait_type_job { job_type host user {variable qacct_info} }
#
#  FUNCTION
#     This function can be used to submit different job types (standard
#     qsub job, qsh, qrsh, qrlogin, qlogin and tight integrated jobs) and
#     wait for the jobs to appear in the accouting file. The function
#     returns the job id of the job.
#
#  INPUTS
#     job_type              - "qsub", "qsh", "qrsh", "qrlogin", "qlogin" or
#                             "tight_integrated"
#     host                  - host where the job should run
#     user                  - user who should submit the job
#     {variable qacct_info} - return value for job accounting information
#
#  INFO
#     1) user must be != $CHECK_USER
#
#     2) "tight_integrated" job need pe "tight_job_start"
#
#
#  RESULT
#     job id (>= 1) or -1 on error
#
#*******************************************************************************
proc submit_wait_type_job {job_type host user {variable qacct_info}} {
   global CHECK_DEBUG_LEVEL CHECK_USER
   global CHECK_DISPLAY_OUTPUT
   get_current_cluster_config_array ts_config
   upvar $variable qacctinfo

   delete_all_jobs
   wait_for_end_of_all_jobs 30

   set job_id 0
   set remote_host_arg "-l h=$host"
   set output_argument "-o /dev/null -e /dev/null"
   set job_argument "$ts_config(product_root)/examples/jobs/sleeper.sh 5"

   ts_log_fine "submitting job type \"$job_type\" ..."
   switch -exact $job_type {
      "qsub" {
         set job_id [submit_job "$remote_host_arg $output_argument $job_argument" 1 60 "" $user]
         wait_for_jobstart $job_id "leeper" 30 1 1
         wait_for_jobend $job_id "leeper" 30 0 1
      }

      "qrlogin" { ;# without command (qrsh without command)
         ts_log_fine "starting qrsh $remote_host_arg as user $user on host $ts_config(master_host) ..."
         set sid [open_remote_spawn_process $ts_config(master_host) $user "qrsh" "$remote_host_arg"]
         set sp_id [lindex $sid 1]
         set timeout 1
         set my_tries 60

         while {1} {
            expect {
               -i $sp_id "_start_mark_*\n" {
                  ts_log_finest "got start mark ..."
                  break
               }
               -i $sp_id default {
                       if { $my_tries > 0 } {
                           incr my_tries -1
                           ts_log_progress
                           continue
                       } else {
                          ts_log_severe "startup timeout"
                          break
                       }
                   }
            }
         }

         set my_tries 60
         while {1} {
            expect {
               -i $sp_id {[A-Za-z>$%]*} {
                       ts_log_finest "startup ..."
                       break
                   }
               -i $sp_id default {
                       if { $my_tries > 0 } {
                           incr my_tries -1
                           ts_log_progress
                           continue
                       } else {
                          ts_log_severe "startup timeout"
                          break
                       }
                   }

            }
         }

         set max_timeouts 60
         set done 0
         while {!$done} {
            expect {
               -i $sp_id full_buffer {
                  ts_log_severe "expect full_buffer error"
                  set done 1
               }
               -i $sp_id timeout {
                  incr max_timeouts -1

                  if { $job_id == 0 } {
                     set job_list [get_standard_job_info 0 0 1]
                     foreach job $job_list {
                        ts_log_finest $job
                        if { [lindex $job 2] == "QRLOGIN" && [lindex $job 3] == $user && [lindex $job 4] == "r"  } {
                           ts_log_fine "qrlogin job id is [lindex $job 0]"
                           set job_id [lindex $job 0]
                        }
                     }
                  } else {
                     set shell_start_output [get_ts_local_script $host "shell_start_output.sh"]
                     ts_send $sp_id "\n$shell_start_output\n" $host
                  }

                  if { $max_timeouts <= 0 } {
                     ts_log_severe "got 15 timeout errors - break"
                     set done 1
                  }
               }
               -i $sp_id "ts_shell_response*\n" {
                  ts_log_finest "found matching shell response text! Sending exit ..."
                  ts_send $sp_id "exit\n" $host
               }

               -i $sp_id eof {
                  ts_log_severe "got eof"
                  set done 1
               }
               -i $sp_id "_start_mark_" {
                  ts_log_finest "remote command started"
                  set done 0
               }
               -i $sp_id "_exit_status_" {
                  ts_log_finest "remote command terminated"
                  set done 1
               }
               -i $sp_id "assword" {
                  ts_log_severe "unexpected password question for user $user on host $host"
                  set done 1
               }
               -i $sp_id "*\n" {
                  set output $expect_out(buffer)
                  set output [ split $output "\n" ]
                  foreach line $output {
                     set line [string trim $line]
                     if { [string length $line] == 0 } {
                        continue
                     }
                     ts_log_finest $line
                  }
               }
               -i $sp_id default {
               }
            }
         }
         close_spawn_process $sid
      }

      "qrsh" { ;# with sleeper job
         ts_log_fine "starting qrsh $remote_host_arg $job_argument as user $user on host $ts_config(master_host) ..."
         set sid [open_remote_spawn_process $ts_config(master_host) $user "qrsh" "$remote_host_arg $job_argument"]
         set sp_id [lindex $sid 1]
         set timeout 1
         set max_timeouts 15
         set done 0
         while {!$done} {
            expect {
               -i $sp_id full_buffer {
                  ts_log_severe "expect full_buffer error"
                  set done 1
               }
               -i $sp_id timeout {
                  incr max_timeouts -1

                  set job_list [get_standard_job_info 0 0 1]
                  foreach job $job_list {
                     ts_log_finest $job
                     if { [lindex $job 2] == "sleeper.sh" && [lindex $job 3] == $user } {
                        ts_log_fine "qrsh job id is [lindex $job 0]"
                        set job_id [lindex $job 0]
                     }
                  }

                  if { $max_timeouts <= 0 } {
                     ts_log_severe "got 15 timeout errors - break"
                     set done 1
                  }
               }
               -i $sp_id eof {
                  ts_log_severe "got eof"
                  set done 1
               }
               -i $sp_id "_start_mark_" {
                  ts_log_finest "remote command started"
                  set done 0
               }
               -i $sp_id "_exit_status_" {
                  ts_log_finest "remote command terminated"
                  set done 1
               }
               -i $sp_id "assword" {
                  ts_log_severe "unexpected password question for user $user on host $host"
                  set done 1
               }
               -i $sp_id "*\n" {
                  set output $expect_out(buffer)
                  set output [ split $output "\n" ]
                  foreach line $output {
                     set line [string trim $line]
                     if { [string length $line] == 0 } {
                        continue
                     }
                     ts_log_finest $line
                  }
               }
               -i $sp_id default {
               }
            }
         }
         close_spawn_process $sid
      }

      "qlogin" {
         ts_log_fine "starting qlogin $remote_host_arg ..."
         set sid [open_remote_spawn_process $ts_config(master_host) $user "qlogin" "$remote_host_arg"]
         set sp_id [lindex $sid 1]
         set timeout 1
         set max_timeouts 15
         set done 0
         while {!$done} {
            expect {
               -i $sp_id full_buffer {
                  ts_log_severe "expect full_buffer error"
                  set done 1
               }
               -i $sp_id timeout {
                  incr max_timeouts -1

                  if { $job_id == 0 } {
                     set job_list [get_standard_job_info 0 0 1]
                     foreach job $job_list {
                        ts_log_finest $job
                        if { [lindex $job 2] == "QLOGIN" && [lindex $job 3] == $user } {
                           ts_log_fine "qlogin job id is [lindex $job 0]"
                           set job_id [lindex $job 0]
                           ts_send $sp_id "exit\n"
                        }
                     }
                  }

                  if { $max_timeouts <= 0 } {
                     ts_log_severe "got 15 timeout errors - break"
                     set done 1
                  }
               }
               -i $sp_id eof {
                  ts_log_severe "got eof"
                  set done 1
               }
               -i $sp_id "_start_mark_" {
                  ts_log_finest "remote command started"
                  set done 0
               }
               -i $sp_id "_exit_status_" {
                  ts_log_finest "remote command terminated"
                  set done 1
               }

               -i $sp_id "login:" {
                  ts_send $sp_id "$user\n" $host 1
               }

               -i $sp_id "assword" {
                  ts_log_finest "got password question for user $user on host $host"
                  if { $job_id == 0 } {
                     set job_list [get_standard_job_info 0 0 1]
                     foreach job $job_list {
                        ts_log_finest $job
                        if { [lindex $job 2] == "QLOGIN" && [lindex $job 3] == $user } {
                           ts_log_fine "qlogin job id is [lindex $job 0]"
                           set job_id [lindex $job 0]
                        }
                     }
                  }
                  ts_log_finest "deleting job with id $job_id, because we don't know user password ..."
                  delete_job $job_id
               }

               -i $sp_id "*\n" {
                  set output $expect_out(buffer)
                  set output [ split $output "\n" ]
                  foreach line $output {
                     set line [string trim $line]
                     if { [string length $line] == 0 } {
                        continue
                     }
                     ts_log_finest $line
                  }
               }
               -i $sp_id default {
               }
            }
         }
         close_spawn_process $sid
      }

      "qsh" {
         ts_log_fine "starting qsh $remote_host_arg on host $ts_config(master_host) as user $user ..."
         ts_log_fine "setting DISPLAY=$CHECK_DISPLAY_OUTPUT"

         set my_qsh_env(DISPLAY) $CHECK_DISPLAY_OUTPUT
         set abort_count 60
         set sid [open_remote_spawn_process $ts_config(master_host) $user "qsh" "$remote_host_arg -now yes" 0 "" my_qsh_env]
         set sp_id [lindex $sid 1]
         set timeout 1
         set done 0
         while {!$done} {
            expect {
               -i $sp_id full_buffer {
                  ts_log_severe "expect full_buffer error"
                  set done 1
               }
               -i $sp_id timeout {

                  if { $job_id == 0 } {
                     set job_list [get_standard_job_info 0 0 1]
                     foreach job $job_list {
                        ts_log_finest $job
                        if { [lindex $job 2] == "INTERACTIV" && [lindex $job 3] == $user && [lindex $job 4] == "r" } {
                           ts_log_fine "qsh job id is [lindex $job 0]"
                           set job_id [lindex $job 0]
                        }
                     }
                  } else {
                        ts_log_finest "ok, now deleting job $job_id ..."
                        delete_job $job_id
                        set done 1
                  }
                  incr abort_count -1
                  if { $abort_count <= 0 } {
                     ts_log_severe "timeout waiting for start of $job_type job of user $user"
                     set done 1
                  }
               }
               -i $sp_id eof {
                  ts_log_severe "got eof"
                  set done 1
               }
               -i $sp_id "_start_mark_" {
                  ts_log_finest "remote command started"
                  set done 0
               }
               -i $sp_id "_exit_status_" {
                  ts_log_finest "remote command terminated"
                  set done 0
               }

               -i $sp_id "*\n" {
                  set output $expect_out(buffer)
                  set output [ split $output "\n" ]
                  foreach line $output {
                     set line [string trim $line]
                     if { [string length $line] == 0 } {
                        continue
                     }
                     ts_log_finest $line
                  }
               }
            }
         }
         close_spawn_process $sid
      }

      "tight_integrated" {
         ts_log_fine "starting tightly integrated job"
         set master_task_id [submit_job "$remote_host_arg $output_argument -pe tight_job_start 1 $ts_config(product_root)/examples/jobs/sleeper.sh 30" 1 60 "" $user]
         wait_for_jobstart $master_task_id "leeper" 30 1 1
         ts_log_finer "tight integration job has been submitted, now submitting task ..."

         set my_tight_env(JOB_ID) $master_task_id
         set my_tight_env(SGE_TASK_ID) 1

         ts_log_finer "starting qrsh -inherit $host $ts_config(product_root)/examples/jobs/sleeper.sh 15 ..."
         set sid [open_remote_spawn_process $ts_config(master_host) $user "qrsh" "-inherit $host $ts_config(product_root)/examples/jobs/sleeper.sh 15" 0 "" my_tight_env]
         set sp_id [lindex $sid 1]
         set timeout 1
         set max_timeouts 30
         set done 0
         while {!$done} {
            expect {
               -i $sp_id full_buffer {
                  ts_log_severe "expect full_buffer error"
                  set done 1
               }
               -i $sp_id timeout {
                  incr max_timeouts -1

                  set job_list [get_standard_job_info 0 0 1]
                  foreach job $job_list {
                     ts_log_finest $job
                     if { [lindex $job 2] == "Sleeper" && [lindex $job 3] == $user } {
                        ts_log_fine "qrsh job id is [lindex $job 0]"
                        set job_id [lindex $job 0]
                     }
                  }

                  if { $max_timeouts <= 0 } {
                     ts_log_severe "got 15 timeout errors - break"
                     set done 1
                  }
               }
               -i $sp_id eof {
                  ts_log_severe "got eof"
                  set done 1
               }
               -i $sp_id "_start_mark_" {
                  ts_log_finest "remote command started"
                  set done 0
               }
               -i $sp_id "_exit_status_" {
                  ts_log_finest "remote command terminated"
                  set done 1
               }
               -i $sp_id "assword" {
                  ts_log_severe "unexpected password question for user $user on host $host"
                  set done 1
               }
               -i $sp_id "*\n" {
                  set output $expect_out(buffer)
                  set output [ split $output "\n" ]
                  foreach line $output {
                     set line [string trim $line]
                     if { [string length $line] == 0 } {
                        continue
                     }
                     ts_log_finest $line
                  }
               }
               -i $sp_id default {
               }
            }
         }
         close_spawn_process $sid
         wait_for_jobend $master_task_id "leeper" 60 0 1
      }
   }

   if { $job_id == 0 } {
      ts_log_severe "could not submit \"$job_type\" job to host \"$host\" as user \"$user\". XWindow DISPLAY=$CHECK_DISPLAY_OUTPUT.\nPlease be informed that this test only works if your display is shared to other users/hosts!!!"
      return -1
   }


   ts_log_finer "waiting for job $job_id to disapear "
   set my_timeout [clock seconds]
   incr my_timeout 30
   while { [is_job_running $job_id "" ] != -1 } {
      after 500
      ts_log_progress
      if {[clock seconds] > $my_timeout } {
         break
      }
   }



   # if job is now still running or pending, the job had problems => error
   if { [is_job_running $job_id "" ] != -1 } {
      ts_log_severe "job still registered! Skipping test for \"$job_type\" job to host \"$host\" as user \"$user\".\nXWindow DISPLAY=$CHECK_DISPLAY_OUTPUT\nPLEASE check that user $user can open an xterm on your display!!!"
      return -1
   }


   set my_timeout [clock seconds]
   incr my_timeout 60
   ts_log_finer "waiting for accounting file to have information about job $job_id"
   while {[get_qacct $job_id qacctinfo "" "" 0] != 0 } {
      after 500
      ts_log_progress
      if {[clock seconds] > $my_timeout} {
         break
      }
   }

   ts_log_fine "waiting for accounting file to have information about job $job_id slave"
   if { $job_type == "tight_integrated" } {
      set my_timeout [clock seconds]
      incr my_timeout 60
      while { 1 } {
         get_qacct $job_id qacctinfo
         if { [llength $qacctinfo(exit_status)] == 2 } {
            break
         }
         after 500
         ts_log_progress
         if {[clock seconds] > $my_timeout} {
            break
         }
      }
   }


   if {[get_qacct $job_id qacctinfo] != 0} {
      return -1
   }

   return $job_id
}

#****** sge_procedures/submit_time_job() ***************************************
#  NAME
#     submit_time_job() -- Submit a job with execution time
#
#  SYNOPSIS
#     submit_time_job { jobargs }
#
#  FUNCTION
#     This procedure will submit a job with the -a option. The start time
#     is set to function call time + 2 min.
#
#  INPUTS
#     jobargs - job arguments (e.g. -o ... -e ... job start script path)
#
#  RESULT
#     job id
#
#  SEE ALSO
#     sge_procedures/submit_error_job()
#     sge_procedures/submit_waitjob_job()
#     sge_procedures/submit_time_job()
#*******************************************************************************
proc submit_time_job { jobargs } {

   set hour   [clock format [clock seconds] -format "%H"]
   set minute [clock format [clock seconds] -format "%M"]

   if { [string first "0" $hour] == 0 } {
      set hour [string index $hour 1 ]
   }
   if { [string first "0" $minute] == 0 } {
      set minute [string index $minute 1 ]
   }

   if {$minute < 58 } {
     set minute [expr ($minute + 2) ]
   } else {
     set minute [expr ($minute + 2 - 60) ]
      if {$hour < 23 } {
         set hour [expr ($hour + 1) ]
      } else {
         set hour "00"
      }
   }

   set rhour $hour
   set rminute $minute

   if {$hour < 10} {
     set rhour "0$hour"
   }
   if {$minute < 10} {
     set rminute "0$minute"
   }

   set start "[clock format [clock seconds] -format \%Y\%m\%d]$rhour$rminute"
   set result [submit_job "-a $start $jobargs"]
   return $result
}


#****** sge_procedures/submit_waitjob_job() ************************************
#  NAME
#     submit_waitjob_job() -- submit job with hold_jid (wait for other job)
#
#  SYNOPSIS
#     submit_waitjob_job { jobargs wait_job_id }
#
#  FUNCTION
#     This procedure will submit a job with hold_jid option set. This means that
#     the job is not started while an other job is running
#
#  INPUTS
#     jobargs     - additional job arguments ( jobscript, -e -o option ...)
#     wait_job_id - job id to wait for
#
#  RESULT
#     job id of hold_jid job
#
#  SEE ALSO
#     sge_procedures/submit_error_job()
#     sge_procedures/submit_waitjob_job()
#     sge_procedures/submit_time_job()
#*******************************************************************************
proc submit_waitjob_job { jobargs wait_job_id} {
   return [submit_job "-hold_jid $wait_job_id $jobargs"]
}


#****** sge_procedures/get_loadsensor_path() ***********************************
#  NAME
#     get_loadsensor_path() -- get loadsensor for host
#
#  SYNOPSIS
#     get_loadsensor_path { host }
#
#  FUNCTION
#     This procedure will read the load sensor path for the given host
#
#  INPUTS
#     host - hostname to get loadsensor for
#
#  RESULT
#     full path name of loadsensor
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc get_loadsensor_path { node } {
   global ts_host_config
   get_current_cluster_config_array ts_config

   set host [node_get_host $node]

   set loadsensor ""

   set arch [resolve_arch $host]

   # if we have a custom loadsensor defined in hostconfig, use this one
   if {[info exists ts_host_config($host,loadsensor)]} {
      set loadsensor $ts_host_config($host,loadsensor)
   } else {
      ts_log_severe "no host configuration found for host \"$host\""
   }

   # if we have no custom loadsensor
   # but we are on aix, we need the ibm-loadsensor to get the default load values
   if { $loadsensor == "" } {
      if {$arch == "aix43" || $arch == "aix51"} {
         set loadsensor "$ts_config(product_root)/util/resources/loadsensors/ibm-loadsensor"
      }
   }

   return $loadsensor
}

#
#                                                             max. column:     |
#
#****** sge_procedures/get_gid_range() ******
#  NAME
#     get_gid_range() -- get gid range for user
#
#  SYNOPSIS
#     get_gid_range { user port }
#
#  FUNCTION
#     This procedure ist used in the install_core_system test. It returns the
#     gid range of the requested user and port
#
#  INPUTS
#     user - user name
#     port - port number on which the cluster commd is running
#
#  RESULT
#     gid range, e.g. 13501-13700
#
#  SEE ALSO
#     ???/???
#*******************************
#
proc get_gid_range { user port } {
   get_current_cluster_config_array ts_config
  global ts_user_config

  if { [ info exists ts_user_config($port,$user) ] } {
     return $ts_user_config($port,$user)
  }
  ts_log_severe "no gid range defined for user $user on port $port"
  return ""
}



#                                                             max. column:     |
#****** sge_procedures/get_config() ******
#
#  NAME
#     get_config -- get global or host configuration settings
#
#  SYNOPSIS
#     get_config { change_array {host "global"} }
#
#  FUNCTION
#     Get the global or host specific configuration settings.
#
#  INPUTS
#     change_array    - name of an array variable that will get set by
#                       get_config
#     {host "global"} - get configuration for a specific hostname (host)
#                       or get the global configuration (global)
#
#  RESULT
#     The change_array variable is build as follows:
#
#     set change_array(xterm)   "/bin/xterm"
#     set change_array(enforce_project) "true"
#     ...
#     0  - on success
#     -1 - on error
#
#
#  EXAMPLE
#     get_config gcluster1 lobal
#     puts $cluster1(qmaster_spool_dir)
#
#     Here the possible change_array values with some typical settings:
#
#     execd_spool_dir      /../$SGE_CELL/spool
#     qsi_common_dir       /../$SGE_CELL/common/qsi
#     mailer               /usr/sbin/Mail
#     xterm                /usr/bin/X11/xterm
#     load_sensor          none
#     prolog               none
#     epilog               none
#     shell_start_mode     posix_compliant
#     login_shells         sh,ksh,csh,tcsh
#     min_uid              0
#     min_gid              0
#     user_lists           none
#     xuser_lists          none
#     projects             none
#     xprojects            none
#     load_report_time     00:01:00
#     stat_log_time        12:00:00
#     max_unheard          00:02:30
#     loglevel             log_info
#     enforce_project      false
#     administrator_mail   none
#     set_token_cmd        none
#     pag_cmd              none
#     token_extend_time    none
#     shepherd_cmd         none
#     qmaster_params       none
#     execd_params         none
#     finished_jobs        0
#     gid_range            13001-13100
#     admin_user           crei
#     qlogin_command       telnet
#     qlogin_daemon        /usr/etc/telnetd
#
#
#  SEE ALSO
#     sge_procedures/set_config()
#*******************************
proc get_config {change_array {host global} {atimeout 60} {raise_error 1}} {
  get_current_cluster_config_array ts_config
  upvar $change_array chgar

  if {[info exists chgar]} {
     unset chgar
  }

  set result [start_sge_bin "qconf" "-sconf $host" "" "" prg_exit_state $atimeout]
  if {$prg_exit_state != 0} {
     ts_log_severe "qconf -sconf $host failed:\n$result" $raise_error
     return -1
  }

  # split each line as listelement
  set help [split $result "\n"]
  foreach elem $help {
     set id [lindex $elem 0]
     set value [lrange $elem 1 end]
     if { [string compare $value ""] != 0 } {
       set chgar($id) $value
     }
  }
  return 0
}

#                                                             max. column:     |
#****** sge_procedures/set_config() ******
#
#  NAME
#     set_config -- change global or host specific configuration
#
#  SYNOPSIS
#     set_config { change_array {host global}{do_add 0} }
#
#  FUNCTION
#     Set the cluster global or exec host local configuration corresponding to
#     the content of the change_array.
#
#  INPUTS
#     change_array  - name of an array variable that will be set by get_config
#     {host global} - set configuration for a specific hostname (host) or set
#                     the global configuration (global)
#     {do_add 0}    - if 1: this is a new configuration, no old one exists)
#     {raise_error} - raise error condition (1), or not (0)
#     {do_reset 0}  - if 1: any existing parameter is removed if not in change_array
#
#  RESULT
#     < 0 : error
#     >= 0 : ok
#
#     The change_array variable is build as follows:
#
#     set change_array(xterm)   "/bin/xterm"
#     set change_array(enforce_project) "true"
#     ...
#     (every value that is set will be changed)
#
#
#  EXAMPLE
#     get_config gcluster1 lobal
#     set cluster1(execd_spool_dir) "/bla/bla/tmp"
#     set_config cluster1
#
#     Here the possible change_array values with some typical settings:
#
#     execd_spool_dir      /../$SGE_CELL/spool
#     qsi_common_dir       /../$SGE_CELL/common/qsi
#     mailer               /usr/sbin/Mail
#     xterm                /usr/bin/X11/xterm
#     load_sensor          none
#     prolog               none
#     epilog               none
#     shell_start_mode     posix_compliant
#     login_shells         sh,ksh,csh,tcsh
#     min_uid              0
#     min_gid              0
#     user_lists           none
#     xuser_lists          none
#     projects             none
#     xprojects            none
#     load_report_time     00:01:00
#     stat_log_time        12:00:00
#     max_unheard          00:02:30
#     loglevel             log_info
#     enforce_project      false
#     administrator_mail   none
#     set_token_cmd        none
#     pag_cmd              none
#     token_extend_time    none
#     shepherd_cmd         none
#     qmaster_params       none
#     execd_params         none
#     finished_jobs        0
#     gid_range            13001-13100
#     admin_user           crei
#     qlogin_command       telnet
#     qlogin_daemon        /usr/etc/telnetd
#
#  SEE ALSO
#     sge_procedures/get_config()
#*******************************
global g_set_config_messages_add g_set_config_messages_mod
unset -nocomplain g_set_config_messages_add g_set_config_messages_mod
proc set_config {change_array {host global} {do_add 0} {raise_error 1} {do_reset 0}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER CHECK_JOB_OUTPUT_DIR
   global g_set_config_messages_add g_set_config_messages_mod

   upvar $change_array chgar_orig

   foreach elem [array names chgar_orig] {
      set chgar($elem) $chgar_orig($elem)
   }

   if {$do_add} {
      upvar 0 g_set_config_messages_add messages
   } else {
      upvar 0 g_set_config_messages_mod messages
   }
   if {![info exists messages(index)]} {
      ts_log_finest "set_config($do_add): translating messages"

      add_message_to_container messages -1 [translate_macro_if_possible MSG_CONF_THEPATHGIVENFORXMUSTSTARTWITHANY_S "*"]
      add_message_to_container messages -2 [translate_macro_if_possible MSG_WARN_CHANGENOTEFFECTEDUNTILRESTARTOFEXECHOSTS "execd_spool_dir"]
      add_message_to_container messages -3 [translate_macro MSG_CONFIG_CONF_GIDRANGELESSTHANNOTALLOWED_I "*"]
      add_message_to_container messages -4 [translate_macro MSG_PARSE_EDITFAILED]
      if {$do_add} {
         add_message_to_container messages 0 [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS $CHECK_USER "*" "*" "*"]
         add_message_to_container messages 1 [translate_macro MSG_SGETEXT_ADDEDTOLIST_SSSS $CHECK_USER "*" "*" "*"]
      } else {
         add_message_to_container messages 0 [translate_macro MSG_SGETEXT_ADDEDTOLIST_SSSS $CHECK_USER "*" "*" "*"]
         add_message_to_container messages 1 [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS $CHECK_USER "*" "*" "*"]
      }
   }

   if {$do_add} {
      set tmpfile "$CHECK_JOB_OUTPUT_DIR/$host"
      set qconf_cmd "-Aconf $tmpfile"
      array set data {}
      set line_cnt 0
      foreach elem [array names chgar] {
         incr line_cnt 1
         set data($line_cnt) "$elem $chgar($elem)"
      }
      set data(0) $line_cnt
      write_remote_file $ts_config(master_host) $CHECK_USER $tmpfile data
      set output [start_sge_bin qconf $qconf_cmd $ts_config(master_host) $CHECK_USER]
      delete_remote_file $ts_config(master_host) $CHECK_USER $tmpfile
      unset data
   } else {
      set config_return [get_config current_values $host]
      if {$do_reset && $config_return == 0} {
         # Any elem in current_values which should not be in new config
         # have to be defined in new config as parameter with empty string
         foreach elem [array names current_values] {
            if {![info exists chgar($elem)]} {
               set chgar($elem) ""
            }
         }
      }
      set qconf_cmd "-mconf $host"
      set vi_commands [build_vi_command chgar current_values]
      set output [start_vi_edit qconf $qconf_cmd $vi_commands messages $ts_config(master_host) $CHECK_USER]
   }

   set result [handle_sge_errors "set_config" "qconf $qconf_cmd" [string trim $output] messages $raise_error]
   if {$result < 0}  {
      ts_log_severe "could not add or modify configuration for host $host ($result)" $raise_error
   }

   return $result
}

#****** sge_procedures/reset_config() ******************************************
#  NAME
#     reset_config() -- reset configuration to specified configuration
#
#  SYNOPSIS
#     reset_config { change_array {host global} {raise_error 1} }
#
#  FUNCTION
#     This procedure sets the specified configuration values and removes
#     values which are additional set from the current config. The resulting
#     config will reflect the set values in the specified array.
#
#
#  INPUTS
#     change_array    - values to set
#     {host global}   - hostname or "global" for global config
#     {raise_error 1} - if 0: Do not report errors
#
#  RESULT
#     return value of set_config()
#
#  SEE ALSO
#     sge_procedures/set_config()
#*******************************************************************************
proc reset_config {change_array {host global} {raise_error 1}} {
   upvar $change_array ch_array
   return [set_config ch_array $host 0 $raise_error 1]
}

#****** sge_procedures/set_config_and_propagate() ******************************
#  NAME
#     set_config_and_propagate() -- set the config for the given host
#
#  SYNOPSIS
#     set_config_and_propagate { config {host global} }
#
#  FUNCTION
#     Set the given config for the given host, and wait until the change has
#     propagated.  It knows that the change has progated when the last config
#     entry change appears in an execd's messages file.  If the host is global,
#     an execd is selected from the list of execution daemons.  This method
#     opens a remote process as $ts_user_config(first_foreign_user).
#
#  INPUTS
#     config        - the configuration to set
#     {host global} - the host for which the configuration should be set
#     {do_reset 0}  - parameter used for set_config (do a reset if 1)
#*******************************************************************************
proc set_config_and_propagate {config {host global} {do_reset 0}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config
   upvar $config my_config

   if {[array size my_config] > 0} {
      set host_list {}
      set joined_spawn_list {}

      # get host and spooldir of an execd - where to look for messages file
      if {$host == "global"} {
         set host_list $ts_config(execd_nodes)
      } else {
         set host_list $host
      }

      foreach conf_host $host_list {
         # Begin watching messages file for changes,
         # consume the lines output immediately by tail -f
         set spool_dir [get_spool_dir $conf_host "execd"]
         set messages_name "$spool_dir/messages"
         ts_log_fine "starting tail -1f $messages_name on host $conf_host ..."
         set tail_id [open_remote_spawn_process $conf_host $CHECK_USER [get_binary_path $conf_host "tail"] "-1f $messages_name"]
         set sp_id [lindex $tail_id 1]
         set timeout 40
         expect {
            -i $sp_id full_buffer {
               ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
            }
            -i $sp_id timeout {
               ts_log_severe "timeout while waiting for tail output on host $conf_host"
            }
            -i $sp_id "*\n" {
            }
         }
         lappend joined_spawn_list $sp_id
         set host_spawn_map($sp_id) $conf_host
         set sp_tail_id_map($sp_id) $tail_id
      }

      # check actual load_report_time
      set load_report_time_string "00:00:15"
      get_config tmp_config $host
      if {[info exists tmp_config(load_report_time)]} {
         set load_report_time_string $tmp_config(load_report_time)
      }
      ts_log_fine "load report time seems to be \"$load_report_time_string\""
      set split_list [split $load_report_time_string ":"]
      set lr_sec [lindex $split_list 2]
      set lr_min [lindex $split_list 1]
      set lr_hrs [lindex $split_list 0]
      set change_timeout_value [expr ($lr_hrs * 3600 + $lr_min * 60 + $lr_sec) * 2]
      ts_log_fine "timeout used for change to happen: $change_timeout_value seconds"
      if {$change_timeout_value < 30} {
         set change_timeout_value 30
         ts_log_fine "adapted timeout used for change to happen to: $change_timeout_value seconds"
      }

      # Make configuration change
      set result [set_config my_config $host 0 1 $do_reset]
      if {$result < 0 && $result != -3 && $result != -5}  {
         #Exit when this failed, otherwise we might get stuck
         foreach spawn_id $joined_spawn_list {
           close_spawn_process $sp_tail_id_map($spawn_id)
         }
         ts_log_severe "there was a problem when setting the config! Result was $result"
         return
      }

      # choose a config to wait for
      # if it is an empty string (e.g. as we deleted an entry), use wildcards
      set value ""
      foreach name [array names my_config] {
         if {$my_config($name) != ""} {
            set value $my_config($name)
            break
         }
      }
      if {$value == ""} {
         set name "*"
         set value "*"
      }

      foreach conf_host $host_list {
         set expected_value($conf_host) $value
      }

      # local values might overwrite global once
      if {$host == "global" && $name != "*"} {
         foreach conf_host $host_list {
            get_config tmp_config $conf_host
            if {[info exists tmp_config($name)]} {
               set expected_value($conf_host) $tmp_config($name)
               ts_log_fine "$conf_host: Overwriting expected value for $name to \"$tmp_config($name)\". Local config overwrites global one!"
            }
            if {[info exists tmp_config(load_report_time)]} {
               set local_load_report_time $tmp_config(load_report_time)
               set split_list [split $load_report_time_string ":"]
               set lr_sec [lindex $split_list 2]
               set lr_min [lindex $split_list 1]
               set lr_hrs [lindex $split_list 0]
               set local_change_timeout_value [expr ($lr_hrs * 3600 + $lr_min * 60 + $lr_sec) * 2]
               if {$local_change_timeout_value > $change_timeout_value} {
                  set change_timeout_value $local_change_timeout_value
                  ts_log_fine "$conf_host: Local load report interval is larger than global interval!"
                  ts_log_fine "new timeout used for change to happen: $change_timeout_value seconds"
               }
            }
         }
      }

      foreach conf_host $host_list {
         if {[string length $value] >= 99} {
            ts_log_fine "=> changed value is to long - using only the first 100 characters"
            set expected_value($conf_host) [string range $expected_value($conf_host) 0 99]
         }
         ts_log_fine "$conf_host: Searching for $name = \"$expected_value($conf_host)\""
      }


      foreach conf_host $host_list {
         set is_host_ok($conf_host) 0
      }
      ts_log_fine "waiting for configuration change to propagate to execd(s) $host_list ..."

      set timeout $change_timeout_value
      expect {
         -i $joined_spawn_list full_buffer {
            ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
         }
         -i $joined_spawn_list timeout {
            set error_text ""
            foreach tmp_host $host_list {
               if {$is_host_ok($tmp_host) == 0} {
                  append error_text "setup failed (timeout for config change of $name = \"$expected_value($tmp_host)\" on host \"$tmp_host\")\n"
               }
            }
            ts_log_severe $error_text
         }
         -i $joined_spawn_list "*\n" {
            set spawn_id $expect_out(spawn_id)
            set host $host_spawn_map($spawn_id)
            set buffer [string trim $expect_out(0,string)]
            set splitline [split $buffer "\n"]
            foreach line $splitline {

               # if we have a time string then convert it to sec
               set search_sec 0
               set sec 0
               set num_colon [llength [split $expected_value($host) ":"]]
               if {$num_colon == 3} {
                  set hours 0
                  set minutes 0
                  set seconds 0
                  scan $expected_value($host) "%02d:%02d:%02d" hours minutes seconds
                  set sec [expr $hours * 3600 + $minutes * 60 + $seconds]
                  set search_sec 1
               }

               if {[string match "*$host*\|I\|*using \"$expected_value($host)\" for $name*" $line]} {
                  # this will match all string based configuration values
                  # or all values in 9.0.* because also there numbers are quoted
                  ts_log_fine "$host: Found config string: $name = \"$expected_value($host)\""
                  set is_host_ok($host) 1
                  # send CTRL-C to end tail
                  ts_send $spawn_id "\003"
               } elseif {[string match "*$host*\|I\|*using $expected_value($host) for $name*" $line]} {
                  # beginning with v9.1.0 this will match number based configuration values that are not quoted anymore
                  ts_log_fine "$host: Found config value: $name = $expected_value($host)"
                  set is_host_ok($host) 1
                  # send CTRL-C to end tail
                  ts_send $spawn_id "\003"
               } elseif {$search_sec == 1 &&
                         [string match "*$host*\|I\|*using $sec for $name*" $line]} {
                  # beginning with 9.1.0 all time based values will be converted to sec before output
                  # this also verfies the CS internal parsing
                  ts_log_fine "$host: Found time converted to sec: $name = $sec"
                  set is_host_ok($host) 1
                  # send CTRL-C to end tail
                  ts_send $spawn_id "\003"
               }
            }

            set wait_host_list {}
            foreach tmp_host $host_list {
               if {$is_host_ok($tmp_host) == 0} {
                  lappend wait_host_list $tmp_host
               }
            }
            if {[llength $wait_host_list] > 0} {
               ts_log_fine "still waiting for configuration changes on host(s): $wait_host_list"
               exp_continue
            } else {
               ts_log_fine "all configuration changed!"
               # Once all daemons have logged their new config the config is valid !!!
            }
         }
      }
      foreach spawn_id $joined_spawn_list {
         close_spawn_process $sp_tail_id_map($spawn_id)
      }
   } else {
      ts_log_fine "my_config array size is =< 0"
   }
}

#****** sge_procedures/reset_config_and_propagate() ****************************
#  NAME
#     reset_config_and_propagate() -- reset configuration to specified configuration
#
#  SYNOPSIS
#     reset_config_and_propagate { config {host global} }
#
#  FUNCTION
#     This procedure sets the specified configuration values and removes
#     values which are additional set from the current config. The resulting
#     config will reflect the set values in the specified array. It waits until
#     all (specified) execds (global means all) have got the new config.
#
#  INPUTS
#     config        - values to set
#     {host global} - hostname or "global" for global config
#
#  RESULT
#     return value of set_config_and_propagate()
#
#  SEE ALSO
#     sge_procedures/set_config_and_propagate()
#*******************************************************************************
proc reset_config_and_propagate { config {host global} } {
   upvar $config conf
   return [set_config_and_propagate conf $host 1]
}

proc compare_complex {a b} {
   set len [llength $a]

   if { $len != [llength $b] } {
      return 1
   }

   # compare shortcut (case sensitive)
   if {[string compare [lindex $a 0] [lindex $b 0]] != 0} {
      return 1
   }
   # compare the complex entry element by element
   for {set i 1} {$i < $len} {incr i} {
      if {[string compare -nocase [lindex $a $i] [lindex $b $i]] != 0} {
         return 1
      }
   }

   return 0
}

## @grief create one gdi_request_limit rule
#
# fnmatch pattern are allowed for all fields except for the limit value
#
# @param src source (qsub, qconf, ...)
# @param type type (ADD, MOD, DEL, GET)
# @param obj object (JOB, CQUEUE, EHOST, ...)
# @param user user or user set name
# @param host host or hostgroup name
# @param limit limit value
proc build_gdi_request_limit {src type obj user host limit} {
    set rule "$src:$type:$obj:$user:$host=$limit"
    return $rule
}

#                                                             max. column:     |
#****** sge_procedures/add_exechost() ******
#
#  NAME
#     add_exechost -- Add a new exechost configuration object
#
#  SYNOPSIS
#     add_exechost { change_array {fast_add 1} }
#
#  FUNCTION
#     Add a new execution host configuration object corresponding to the content of
#     the change_array.
#
#  INPUTS
#     change_array - name of an array variable can contain special settings
#     {fast_add 1} - if not 0 the add_exechost procedure will use a file for
#                    queue configuration. (faster) (qconf -Ae, not qconf -ae)
#
#  RESULT
#     -1   timeout error
#     -2   host already exists
#      0   ok
#
#  EXAMPLE
#     set new_host(hostname) "test"
#     add_exechost new_host
#
#  NOTES
#     the array should look like this:
#
#     set change_array(hostname) MYHOST.domain
#     ....
#     (every value that is set will be changed)
#
#     here is a list of all valid array names (template host):
#
#     change_array(hostname)                    "template"
#     change_array(load_scaling)                "NONE"
#     change_array(complex_list)                "NONE"
#     change_array(complex_values)              "NONE"
#     change_array(user_lists)                  "NONE"
#     change_array(xuser_lists)                 "NONE"
#
#     additional names for an enterprise edition system:
#     change_array(projects)                    "NONE"
#     change_array(xprojects)                   "NONE"
#     change_array(usage_scaling)               "NONE"
#     change_array(resource_capability_factor)  "0.000000"
#*******************************
proc add_exechost {change_array {fast_add 1}} {
   get_current_cluster_config_array ts_config

   upvar $change_array chgar
   set values [array names chgar]

   if {$fast_add != 0} {
      # add queue from file!
      set default_array(hostname)          "template"
      set default_array(load_scaling)      "NONE"
      set default_array(complex_values)    "NONE"
      set default_array(user_lists)        "NONE"
      set default_array(xuser_lists)       "NONE"

      set default_array(projects)                    "NONE"
      set default_array(xprojects)                   "NONE"
      set default_array(usage_scaling)               "NONE"
      set default_array(report_variables)            "NONE"

      foreach elem $values {
         set value $chgar($elem)
         ts_log_finest "--> setting \"$elem\" to \"$value\""
         set default_array($elem) $value
      }

      set tmpfile [get_tmp_file_name]
      set file [open $tmpfile "w"]
      set values [array names default_array]
      foreach elem $values {
         set value $default_array($elem)
         puts $file "$elem                   $value"
      }
      close $file

      set result [start_sge_bin "qconf" "-Ae ${tmpfile}"]
      ts_log_finest $result

      set ADDED [translate_macro MSG_SGETEXT_ADDEDTOLIST_SSSS "*" "*" "*" "*"]

      if {[string match "*$ADDED*" $result] == 0} {
         ts_log_severe "qconf -Ae $tmpfile failed:\n$result"
         return
      }
      return
  }

  set vi_commands [build_vi_command chgar]

  set ALREADY_EXISTS [translate_macro MSG_SGETEXT_ALREADYEXISTS_SS "*" "*"]
  set ADDED [translate_macro MSG_SGETEXT_ADDEDTOLIST_SSSS "*" "*" "*" "*"]

  set master_arch [resolve_arch $ts_config(master_host)]
  set result [handle_vi_edit "$ts_config(product_root)/bin/$master_arch/qconf" "-ae" $vi_commands $ADDED $ALREADY_EXISTS]
  if {$result != 0} {
     ts_log_severe "could not add queue $chgar(qname):\n$result"
  }
  return $result
}

#****** sge_procedures/get_scheduling_info() ***********************************
#  NAME
#     get_scheduling_info() -- get scheduling information
#
#  SYNOPSIS
#     get_scheduling_info { job_id { check_pending 1 } }
#
#  FUNCTION
#     This procedure starts the get_qstat_j_info() procedure and returns
#     the "scheduling info" value. The procedure returns ALLWAYS a valid
#     text string.
#
#  INPUTS
#     job_id              - job id
#     { check_pending 1 } - 1(default): do a wait_forjob_pending first
#                           0         : no wait_for_jobpending() call
#
#  RESULT
#     scheduling info text
#
#  SEE ALSO
#     sge_procedures/get_qstat_j_info()
#     sge_procedures/wait_forjob_pending()
#
#*******************************************************************************
proc get_scheduling_info { job_id { check_pending 1 }} {
   get_current_cluster_config_array ts_config

   if { $check_pending == 1 } {
      set result [ wait_for_jobpending $job_id "leeper" 120 ]
      if { $result != 0 } {
         return "job not pending"
      }
   }
   trigger_scheduling

   set my_timeout [expr [clock seconds] + 30]
   ts_log_finer "waiting for scheduling info information ..."
   while { 1 } {
      if { [get_qstat_j_info $job_id ] } {
         set help_var_name "scheduling info"
         if { [info exists qstat_j_info($help_var_name)] } {
            set sched_info $qstat_j_info($help_var_name)
         } else {
            set sched_info "no messages available"
         }
         set help_var_name [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SCHEDD_SCHEDULINGINFO]]
         if { [info exists qstat_j_info($help_var_name)] } {
            set sched_info $qstat_j_info($help_var_name)
         } else {
            set sched_info "no messages available"
         }


         set INFO_NOMESSAGE [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SCHEDD_INFO_NOMESSAGE]]

         if { [string first "no messages available" $sched_info] < 0 && [string first $INFO_NOMESSAGE $sched_info] < 0 } {
            ts_log_finest $sched_info
            return $sched_info
         }
      }
      ts_log_progress
      after 500
      if {[clock seconds] > $my_timeout} {
         return "timeout"
      }
   }
}

#                                                             max. column:     |
#****** sge_procedures/was_job_running() ******
#
#  NAME
#     was_job_running -- look for job accounting
#
#  SYNOPSIS
#     was_job_running { jobid {do_errorcheck 1} }
#
#  FUNCTION
#     This procedure will start a qacct -j jobid. If the hob was not found in
#     the output of the qacct command, this function will return -1. This
#     means that the job is still running, or was never running.
#
#  INPUTS
#     jobid             - job identification number
#     {do_errorcheck 1} - 1: call ts_log_severe if job was not found
#                         0: do not generate error messages
#
#  RESULT
#     "-1"  : if job was not found
#     or the output of qacct -j
#
#  SEE ALSO
#     logging/ts_log_severe
#*******************************
proc was_job_running {jobid {do_errorcheck 1} } {
   get_current_cluster_config_array ts_config

   set ret [get_qacct $jobid qacct_info "" "" $do_errorcheck -1 0 1 qacct_output]

   if {$ret != 0} {
      return -1
   }

   return $qacct_output
}


proc match_queue {qname qlist} {
   ts_log_finest "trying to match $qname to queues in $qlist"

   set ret {}
   foreach q $qlist {
      if {[string match "$qname*" $q] == 1} {
         lappend ret $q
      }
   }

   return $ret
}

#                                                             max. column:     |
#****** sge_procedures/slave_queue_of() ******
#
#  NAME
#     slave_queue_of -- Get the last slave queue of a parallel job
#
#  SYNOPSIS
#     slave_queue_of { job_id {qlist {}}}
#
#  FUNCTION
#     This procedure will return the name of the last slave queue of a
#     parallel job or "" if the SLAVE queue was not found.
#
#     If a queue list is passed via qlist parameter, the queue name returned
#     by qstat will be matched against the queue names in qlist.
#     This is sometimes necessary, if the queue name printed by qstat is
#     truncated (SGE(EE) 5.3, long hostnames).
#
#  INPUTS
#     job_id - Identification number of the job
#     qlist  - a list of queues - one has to match the slave_queue.
#
#  RESULT
#     empty or the last queue name on which the SLAVE task is running
#
#  SEE ALSO
#     sge_procedures/master_queue_of()
#*******************************
proc slave_queue_of { job_id {qlist {}}} {
   get_current_cluster_config_array ts_config
# return last slave queue of job
# no slave -> return ""
   ts_log_fine "Looking for SLAVE QUEUE of Job $job_id."
   set slave_queue ""         ;# return -1, if there is no slave queue

   set result [get_standard_job_info $job_id]
   foreach elem $result {
      set whatami [lindex $elem 8]
      if { [string compare $whatami "SLAVE"] == 0 } {
         set slave_queue [lindex $elem 7]
         if {[llength $qlist] > 0} {
            # we have to match queue name from qstat against qlist
            set matching_queues [match_queue $slave_queue $qlist]
            if {[llength $matching_queues] == 0} {
               ts_log_severe "no queue is matching queue list"
            } else {
               if {[llength $matching_queues] > 1} {
                  ts_log_severe "multiple queues are matching queue list"
               } else {
                  set slave_queue [lindex $matching_queues 0]
               }
            }
         }
         ts_log_fine "Slave is running on queue \"$slave_queue\""
      }
   }

   #set slave_queue [get_cluster_queue $slave_queue]

   if {$slave_queue == ""} {
     ts_log_severe "no slave queue for job $job_id found"
   }

   return $slave_queue
}

#                                                             max. column:     |
#****** sge_procedures/master_queue_of() ******
#
#  NAME
#     master_queue_of -- get the master queue of a parallel job
#
#  SYNOPSIS
#     master_queue_of { job_id {qlist {}}}
#
#  FUNCTION
#     This procedure will return the name of the master queue of a
#     parallel job or "" if the MASTER queue was not found.
#
#     If a queue list is passed via qlist parameter, the queue name returned
#     by qstat will be matched against the queue names in qlist.
#     This is sometimes necessary, if the queue name printed by qstat is
#     truncated (SGE(EE) 5.3, long hostnames).
#
#  INPUTS
#     job_id - Identification number of the job
#     qlist  - a list of queues - one has to match the slave_queue.
#
#  RESULT
#     empty or the last queue name on which the MASTER task is running
#
#  SEE ALSO
#     sge_procedures/slave_queue_of()
#*******************************
proc master_queue_of { job_id {qlist {}}} {
   get_current_cluster_config_array ts_config
# return master queue of job
# no master -> return "": ! THIS MAY NOT HAPPEN !
   ts_log_fine "Looking for MASTER QUEUE of Job $job_id."
   set master_queue ""         ;# return -1, if there is no master queue

   set result [get_standard_job_info $job_id]
   foreach elem $result {
      set whatami [lindex $elem 8]
      if { [string compare $whatami "MASTER"] == 0 } {
         set master_queue [lindex $elem 7]
         if {[llength $qlist] > 0} {
            # we have to match queue name from qstat against qlist
            set matching_queues [match_queue $master_queue $qlist]
            if {[llength $matching_queues] == 0} {
               ts_log_severe "no queue is matching queue list"
            } else {
               if {[llength $matching_queues] > 1} {
                  ts_log_severe "multiple queues are matching queue list"
               } else {
                  set master_queue [lindex $matching_queues 0]
               }
            }
         }
         ts_log_fine "Master is running on queue \"$master_queue\""
         break                  ;# break out of loop, if Master found
       }
   }

   #set master_queue [get_cluster_queue $master_queue]

   if {$master_queue == ""} {
     ts_log_severe "no master queue for job $job_id found"
   }

   return $master_queue
}


#                                                             max. column:     |
#****** sge_procedures/wait_for_load_from_all_queues() ******
#
#  NAME
#     wait_for_load_from_all_queues -- wait for load value reports from queues
#
#  SYNOPSIS
#     wait_for_load_from_all_queues { seconds }
#
#  FUNCTION
#     This procedure waits until all queues are reporting a load value smaller
#     than 99. If this is the case all execd should be successfully connected
#     to the qmaster.
#
#  INPUTS
#     seconds         - timeout value in seconds
#     {raise_error 1} - optional: report errors if set to 1
#
#  RESULT
#     "-1" on error
#
#  SEE ALSO
#     sge_procedures/wait_for_load_from_all_queues()
#     sge_procedures/wait_for_unknown_load()
#     file_procedures/wait_for_file()
#     sge_procedures/wait_for_jobstart()
#     sge_procedures/wait_for_end_of_transfer()
#     sge_procedures/wait_for_jobpending()
#     sge_procedures/wait_for_jobend()
#*******************************
proc wait_for_load_from_all_queues { seconds {raise_error 1} } {
   get_current_cluster_config_array ts_config
   global CHECK_VALGRIND

   if {$CHECK_VALGRIND == "master"} {
      # re-connect might take longer
      set seconds [expr $seconds + 60]
   }

   set time [clock seconds]

   ts_log_fine "waiting for load value report from all queues ..."
   while {1} {
      after 1000
      ts_log_progress
      set result [start_sge_bin "qstat" "-f"]
      if {$prg_exit_state == 0} {
         # split each line as listelement
         set help [split $result "\n"]

         #remove first line
         set help [lreplace $help 0 0]
         set data ""

         #get every line after "----..." line
         set len [llength $help]
         for {set ind 0} {$ind < $len } {incr ind 1} {
            if {[lsearch [lindex $help $ind] "------*"] >= 0 } {
               lappend data [lindex $help [expr ( $ind + 1 )]]
            }
         }

         set qcount [ llength $data]
         set qnames ""
         set slots ""
         set load ""

         # get line data information for queuename used/tot and load_avg
         foreach elem $data {
            set linedata $elem
            lappend qnames [lindex $linedata 0]
            set used_tot [lindex $linedata 2]
            set pos1 [ expr ( [string first "/" $used_tot] + 1 ) ]
            set pos2 [ expr ( [string length $used_tot]          - 1 ) ]

            lappend slots [string range $used_tot $pos1 $pos2 ]
            lappend load [lindex $linedata 3]
         }

         # check if load of an host is set > 99 (no exed report)
         set failed 0
         foreach elem $load {
           if {$elem == "-NA-" || $elem >= 99} {
              incr failed 1
           }
         }

         if { $failed == 0 } {
            return 0
         }
      } else {
        ts_log_fine "qstat -f failed:\n$result"
      }

      set runtime [expr [clock seconds] - $time]
      if { $runtime >= $seconds } {
          ts_log_severe "timeout waiting for load values < 99. last qstat output was: $result" $raise_error
          return -1
      }
   }
}

#                                                            max. column:     |
#****** ge_3747/wait_for_online_usage() ******************************
#
#  NAME
#     wait_for_online_usage() -- wait until a job reports online usage
#
#  SYNOPSIS
#     proc wait_for_online_usage {job_id {mytimeout 60}}
#
#  FUNCTION
#     Waits until a given job reports online CPU usage. Repeatedly calls
#     "qstat -j <job_id>" and waits until the "usage    1" contains a
#     CPU value that is neither "N/A" nor "00:00:00".
#
#  INPUTS
#     job_id    - the job which should be observed
#     mytimeout - the number of seconds this function should wait for
#                 online usage to be reported
#
#  RESULT
#     0 - No online usage was reported within timeout seconds
#     1 - Online usage was reported
#
#***************************************************************************
proc wait_for_online_usage {job_id {mytimeout 60}} {
   # we can't use the index "usage    1" directly in TCL-arrays because of
   # the spaces, have to use it in a variable
   set usage_name [get_qstat_j_attribute "usage" 1]
   set ret        1
   set time       [clock seconds]

   while {1} {
      set usage ""
      # get "qstat -j $job_id" output
      if {[get_qstat_j_info $job_id] == 1} {
         if {[info exists qstat_j_info($usage_name)] == 1} {
            # if usage is already reported, save it in a variable.
            # The code below is prepared for an empty string in $usage
            set usage $qstat_j_info($usage_name)
         }
      }

      # evaluate usage only if it already has been reported
      if {[string length $usage] > 0} {
         set cpu_index [string first "cpu=" $usage]
         set cpu_usage [string range $usage $cpu_index+4 $cpu_index+11]
         set remaining_time [expr $time + $mytimeout - [clock seconds]]
         ts_log_fine "cpu_usage is $cpu_usage, remaining time is $remaining_time s"

         # transform format 00:01:17 in 77 seconds
         set cpu_seconds [transform_cpu $cpu_usage]
         if {[string equal $cpu_seconds "NA"] == 0} {
            # the cpu usage string contains a value
            if {$cpu_seconds == 0} {
               # in principle cpu usage gets reported, but it is still 00:00:00
               ts_log_finer "got no online usage value so far"
            } else {
               # something like 00:00:17 is reported!
               ts_log_fine "got online usage, fine!"
               break
            }
         }
      }
      # check if timeout time span is already reached
      set runtime [expr [clock seconds] - $time]
      if {$runtime > 60} {
         ts_log_fine "got no online usage after 60 s!"
         set ret 0
         break
      }
      after 2000
   }
   return $ret
}

#****** sge_procedures/wait_for_connected_scheduler() **************************
#  NAME
#     wait_for_connected_scheduler() -- wait for scheduler connected to master
#
#  SYNOPSIS
#     wait_for_connected_scheduler { {seconds 90} {raise_error 1} }
#
#  FUNCTION
#     This function tries to do a qconf -sss to get the scheduler status
#     If getting scheduler status is reporting an error the scheduler is not
#     connected. If the scheduler status is not available during the specified
#     time the function fails.
#
#  INPUTS
#     seconds - timeout waiting for connected scheduler
#
#  RESULT
#     0 when there is a scheduler connected, 1 on error
#*******************************************************************************
proc wait_for_connected_scheduler { {seconds 90} {raise_error 1} } {
   get_current_cluster_config_array ts_config
   set mytimeout [clock seconds]
   incr mytimeout $seconds
   set error_text ""
   set result1 "unknown"

   while {1} {
      after 1000
      if {[clock seconds] > $mytimeout} {
         append error_text "Timeout waiting for scheduler event client status information!\n"
         break
      }

      set ret [get_scheduler_status result1 "" "" 0]
      if { [llength $result1] == 1 && $ret == 0 } {
         if { [host_list_compare $ts_config(master_host) $result1 0 1] == 0 } {
            break
         }
      }
      set timeout_in [expr $mytimeout - [clock seconds]]
      ts_log_fine "waiting for connected scheduler event client (timeout in $timeout_in seconds) ..."
      after 4000
   }

   if { $error_text != ""} {
      ts_log_severe $error_text $raise_error
      return 1
   }
   ts_log_fine "scheduler connected to master \"$result1\""
   return 0
}



#****** sge_procedures/wait_for_job_state() ************************************
#  NAME
#     wait_for_job_state() -- wait for job to become special job state
#
#  SYNOPSIS
#     wait_for_job_state { jobid state wait_timeout }
#
#  FUNCTION
#     This procedure is checking the job state of the given job id by parsing
#     the qstat -f command. If the job has the state given in the parameter
#     state the procedure returns the job state. If an timeout occurs the
#     procedure returns -1.
#
#  INPUTS
#     jobid        - job id of job to check state
#     state        - state to check for
#     wait_timeout - given timeout in seconds
#
#  RESULT
#     job state or -1 on error
#
#  SEE ALSO
#     sge_procedures/wait_for_queue_state()
#*******************************************************************************
proc wait_for_job_state {jobid state wait_timeout {raise_error 1}} {
   get_current_cluster_config_array ts_config

   set my_timeout [expr [clock seconds] + $wait_timeout]
   ts_log_fine "waiting for job $jobid to become job state ${state} ..."
   while {1} {
      ts_log_progress
      set job_state [get_job_state $jobid]
      if {[string first $state $job_state] >= 0} {
         return $job_state
      }
      if {[clock seconds] > $my_timeout} {
         if {$raise_error == 1} {
            ts_log_severe "timeout waiting for job $jobid to get in \"$state\" state"
         }
         return -1
      }
      after 1000
   }

   return $job_state
}

#****** sge_procedures/wait_for_queue_state() **********************************
#  NAME
#     wait_for_queue_state() -- wait for queue to become special error state
#
#  SYNOPSIS
#     wait_for_queue_state { queue state wait_timeout }
#
#  FUNCTION
#     This procedure is checking the queue by parsing the qstat -f command.
#
#  INPUTS
#     queue        - name of queue to check
#     state        - state to check for
#     wait_timeout - given timeout in seconds
#
#  RESULT
#     queue state or -1 on error
#
#  SEE ALSO
#     sge_procedures/wait_for_job_state()
#*******************************************************************************
proc wait_for_queue_state {queue state wait_timeout} {
   get_current_cluster_config_array ts_config

   ts_log_fine "waiting for queue $queue to get in \"${state}\" state "
   set my_timeout [expr [clock seconds] + $wait_timeout]
   while {1} {
      ts_log_progress
      after 500
      set q_state [get_queue_state $queue]
      if {[string first $state $q_state] >= 0} {
         return $q_state
      }
      if {[clock seconds] > $my_timeout} {
         set qstat_output [start_sge_bin "qstat" "-f -q $queue"]
         ts_log_severe "timeout waiting for queue $queue to get in \"${state}\" state\n$qstat_output"
         return -1
      }
   }
}


#****** sge_procedures/soft_execd_shutdown() ***********************************
#  NAME
#     soft_execd_shutdown() -- soft shutdown of execd
#
#  SYNOPSIS
#     soft_execd_shutdown { host_list }
#
#  FUNCTION
#     This procedure starts a qconf -ke $host. If qconf reports an error,
#     the execd is killed by the shutdown_system_daemon() procedure.
#     After that qstat is called. When the load value for the given
#     host-queue ($host.q) is 99.99 the procedure returns without error.
#
#  INPUTS
#     host - list containing all execution daemon hosts to shutdown
#
#  RESULT
#     0 - success
#    -1 - error
#
#  SEE ALSO
#     sge_procedures/shutdown_system_daemon()
#*******************************************************************************
proc soft_execd_shutdown {host_list {timeout 60}} {
   return [shutdown_execd $host_list 1 $timeout]
}

proc shutdown_execd {host_list {soft 0} {timeout 60}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   global CHECK_INSTALL_RC

   foreach host $host_list {
      set execd_pid($host) [get_execd_pid $host]
      if {$execd_pid($host) == 0} {
         ts_log_severe "no execd pid for host $host"
         return -1
      }
   }

   set error_text ""

   # first shutdown the execds
   foreach host $host_list {
      ts_log_fine "shutdown execd pid=$execd_pid($host) on host \"$host\""
      if {$CHECK_INSTALL_RC && [ge_has_feature "systemd"] && [host_has_systemd $host] && [systemd_is_service_active $host "execd"]} {
         ts_log_fine "   via systemd"
         if {!$soft} {
            # first stop possibly running jobs / shepherds
            # @todo once jobs are running in their own slice, stop that one instead
            if {[systemd_is_service_active $host "shepherds"]} {
               systemd_stop_service $host "shepherds"
            }
         }
         # now (soft) stop the execd service
         if {![systemd_stop_service $host "execd"]} {
            shutdown_system_daemon $host execd
         }
      } else {
         ts_log_fine "   via qconf -ke\[j\]"
         set option "-ke"
         if {!$soft} {
            append option "j"
         }
         set result [start_sge_bin "qconf" "$option $host" $ts_config(master_host) $CHECK_USER]
         if {$prg_exit_state != 0} {
            ts_log_fine "qconf -ke $host returned $prg_exit_state, hard killing execd"
            shutdown_system_daemon $host execd
         }
      }
   }

   # check loads
   foreach host $host_list {
      set queue "*@$host"
      set load [wait_for_unknown_load $timeout $queue 0]
      if {$load == 0} {
         ts_log_finer "execd on host $host reports 99.99 load value"
         #execd might not be down yet, let's check!
      } else {
         ts_log_severe "timeout while waiting for unknown load for host $host:\n[start_sge_bin "qhost -h $host]"
         break
         return -1
      }
   }

   #execd might not be down yet, let's check!
   set error_text ""
   foreach host $host_list {
      set counter 0
      set is_ok 0
      while {$counter < $timeout} {
         incr counter 1
         #Check if execd pid is gone
         if {[is_pid_with_name_existing $host $execd_pid($host) "sge_execd" ] != 0} {
            ts_log_finer "Waited $counter secs for execd to disappear"
            set is_ok 1
            break
         }
         after 1000
      }
      if {$is_ok != 1} {
         append error_text "Timeout $counter secs: Could not shutdown execd ( pid=$execd_pid($host) ) on host $host\n"
      }
   }
   if {$error_text != ""} {
      ts_log_severe "could not shutdown all execds:\n$error_text"
      return -1
   }
   return 0
}

#****** sge_procedures/wait_for_unknown_load() *********************************
#  NAME
#     wait_for_unknown_load() -- wait for load to get >= 99 for a list of queues
#
#  SYNOPSIS
#     wait_for_unknown_load { seconds queue_array { do_error_check 1 } }
#
#  FUNCTION
#     This procedure is starting the qstat -f command and parse the output for
#     the queue load values. If the load value of the given queue(s) have a value
#     greater than 99 the procedure will return. If not an error message is
#     generated after timeout.
#
#  INPUTS
#     seconds        - number of seconds to wait before creating timeout error
#     queue_array    - an array of queue names for which to wait
#     do_error_check - (optional) if 1: report errors
#                                 if 0: don't report errors
#
#  SEE ALSO
#     sge_procedures/wait_for_load_from_all_queues()
#
#*******************************************************************************
proc wait_for_unknown_load { seconds queue_array { do_error_check 1 } } {
   get_current_cluster_config_array ts_config
   set time [clock seconds]


   ts_log_fine "wait_for_unknown_load - waiting for queues \"$queue_array\" to get unknown load state (timeout=${seconds}s) ..."

   set master_arch [resolve_arch $ts_config(master_host)]
   if { [ file isfile $ts_config(product_root)/bin/$master_arch/qstat ] != 1} {
      ts_log_severe "qstat file not found!!!" $do_error_check
      return -1
   }

   while {1} {
      after 500
      ts_log_progress
      set result [start_sge_bin "qstat" "-f"]
      if {$prg_exit_state == 0} {
         # split each line as listelement
         set help [split $result "\n"]

         #remove first line
         set help [lreplace $help 0 0]
         set data ""

         #get every line after "----..." line
         set len [llength $help]
         for {set ind 0} {$ind < $len } {incr ind 1} {
            if {[lsearch [lindex $help $ind] "------*"] >= 0 } {
               lappend data [lindex $help [expr ($ind + 1)]]
            }
         }

         set qcount [ llength $data]
         set qnames ""
         set slots ""
         set load ""

         # get line data information for queuename used/tot and load_avg
         foreach elem $data {
            set linedata $elem

            set queue_name [lindex $linedata 0]
            set load_value [lindex $linedata 3]
            set load_values($queue_name) $load_value
         }

         # check if load of an host is set > 99 (no exed report)
         set failed 0
         set q_r ""
         foreach queue $queue_array {
            lappend q_r [array names load_values "$queue"]
         }
         ts_log_finest "queue_list=$q_r"

         foreach queue $q_r {
            if {[info exists load_values($queue)] == 1} {
               if {$load_values($queue) < 99} {
                   incr failed 1
                   if {[string compare $load_values($queue) "-NA-"] == 0} {
                      incr failed -1
                   }
               }
            }
         }

         if {$failed == 0} {
            return 0
         }
      } else {
        ts_log_finer "qstat -f failed:\n$result"
        if {$do_error_check == 1} {
           ts_log_severe "qstat -f failed:\n$result"
        }
        return -1
      }

      set runtime [expr [clock seconds] - $time]
      if {$runtime >= $seconds} {
          if {$do_error_check == 1} {
             ts_log_severe "timeout waiting for load values >= 99 (timeout was $seconds)\n$result"
          }
          return -1
      }
   }

   return 0
}


#
#                                                             max. column:     |
#
#****** sge_procedures/wait_for_end_of_all_jobs() ******
#  NAME
#     wait_for_end_of_all_jobs() -- wait for end of all jobs
#
#  SYNOPSIS
#     wait_for_end_of_all_jobs { seconds }
#
#  FUNCTION
#     This procedure will wait until no further jobs are remaining in the cluster.
#
#  INPUTS
#     {seconds 60}        - optional: timeout value (if < 1 no timeout is set)
#     {raise_error 1}     - optional: report errors
#     {check_spool_dir 1} - optional: also check that job spooling is done
#
#  RESULT
#     0 - ok
#    -1 - timeout
#
#  SEE ALSO
#     sge_procedures/wait_for_jobend()
#     sge_procedures/wait_for_end_of_all_jobs()
#     sge_procedures/get_spooled_jobs()
#*******************************
#
proc wait_for_end_of_all_jobs {{seconds 60} {raise_error 1} {check_spool_dir 1}} {
   get_current_cluster_config_array ts_config

   set time [clock seconds]
   ts_log_fine "waiting for end of all jobs (qstat -s pr)"
   while {1} {
      set result [start_sge_bin "qstat" "-s pr"]
      if {$prg_exit_state == 0} {
         if {[string trim $result] == ""} {
            ts_log_finer "qstat -s pr shows no jobs ..."
            if {$check_spool_dir != 1} {
               ts_log_fine "spool dir checking disabled!"
               return 0
            }
            while {1} {
               # to be sure we also check that no job is spooled somewere
               set spooled_jobs [get_spooled_jobs]
               if {[llength $spooled_jobs] == 0} {
                  return 0
               } else {
                  ts_log_fine "Following jobs are still spooled: $spooled_jobs"
                  set result "Following jobs are still spooled: $spooled_jobs"
                  # we might have a high scheduling interval but scheduler needs to send a delete order
                  trigger_scheduling
               }
               # check timeout
               if {$seconds > 0} {
                  set runtime [expr [clock seconds] - $time]
                  if {$runtime >= $seconds} {
                      ts_log_severe "timeout (1) (= $seconds seconds) waiting for end of all jobs (spooled):\n\"$result\"" $raise_error
                      return -1
                  }
               }
               after 2500
            }
         }

         # split each line as listelement
         set help [split $result "\n"]

         #remove first two lines
         set help [lreplace $help 0 1]
         ts_log_finest "qstat -s pr output:"
         foreach elem $help {
            ts_log_finest $elem
         }
      } else {
        ts_log_severe "qstat -s pr failed:\n$result" $raise_error
        return -1
      }
      ts_log_progress

      # check timeout
      if {$seconds > 0} {
         set runtime [expr [clock seconds] - $time]
         if {$runtime >= $seconds} {
             ts_log_severe "timeout (2) (= $seconds seconds) waiting for end of all jobs (spooled):\n\"$result\"" $raise_error
             return -1
         }
      }
      after 500
   }
}

#****** sge_procedures/get_spooled_jobs() **************************************
#  NAME
#     get_spooled_jobs() -- check spooling framework for jobs
#
#  SYNOPSIS
#     get_spooled_jobs { }
#
#  FUNCTION
#     This procedure returns a list of job ids which are currently spooled
#     at qmaster. The procedure is using spooledit tool or checking the
#     spool directory in case of classic spooling.
#
#  INPUTS
#     no inputs
#
#  RESULT
#     list of currently found jobs in spooling framework
#
#  SEE ALSO
#     sge_procedures/wait_for_end_of_all_jobs()
#     sge_procedures/get_spooled_jobs()
#*******************************************************************************
proc get_spooled_jobs {} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set spooled_jobs_list {}
   set supported 0

   # BDB implementation
   if {$ts_config(spooling_method) == "berkeleydb" } {
      ts_log_finer "we have berkeleydb spooling ..."
      set supported 1
      set execute_host $ts_config(master_host)
      start_sge_bin "spooledit" "list" $execute_host $CHECK_USER prg_exit_state 120 "" "utilbin" out ""
      for {set i 0} {$i <= $out(0)} {incr i 1} {
         if {[string match "*JOB*" $out($i)]} {
            set job_id [string trim [lindex [split $out($i) ":"] 1]]
            lappend spooled_jobs_list [string trimleft $job_id "0"]
         }
      }
   }

   # classic implementation
   if {$ts_config(spooling_method) == "classic" } {
      ts_log_finer "we have classic spooling ..."
      set supported 1
      set execute_host $ts_config(master_host)
      set spooldir [get_qmaster_spool_dir]

      analyze_directory_structure $execute_host $CHECK_USER "$spooldir/jobs" "" files ""
      foreach file $files {
         set job_id [file tail $file]
         lappend spooled_jobs_list [string trimleft $job_id "0"]
      }

   }

   if {$supported != 1} {
      ts_log_severe "spooling method not supported"
   }

   return $spooled_jobs_list
}

#                                                             max. column:     |
#****** sge_procedures/mqattr() ******
#
#  NAME
#     mqattr -- Modify queue attributes
#
#  SYNOPSIS
#     mqattr { attribute entry queue_list { add_error 1  }
#
#  FUNCTION
#     This procedure enables the caller to modify particular queue attributes.
#     Look at set_queue for queue attributes.
#
#  INPUTS
#     attribute  - name of attribute to modify
#     entry      - new value for attribute
#     queue_list - name of queues to change
#     add_error  - execute ts_log_severe
#
#  RESULT
#     -1 - error
#     0  - ok
#
#  EXAMPLE
#     set return_value [mqattr "calendar" "always_disabled" "$queue_list"]
#
#  SEE ALSO
#     sge_procedures/mqattr()
#     sge_procedures/set_queue()
#     sge_procedures/add_queue()
#     sge_procedures/del_queue()
#     sge_procedures/get_queue()
#     sge_procedures/suspend_queue()
#     sge_procedures/unsuspend_queue()
#     sge_procedures/disable_queue()
#     sge_procedures/enable_queue()
#*******************************
proc mqattr {attribute entry queue_list {add_error 1}} {
# returns
# -1 on error
# 0 on success

  global CHECK_USER
  get_current_cluster_config_array ts_config

  puts "Trying to change attribute $attribute of queues $queue_list to $entry."

  set help "$attribute \"$entry\""   ;# create e.g. slots "5" as string
  set result [start_sge_bin "qconf" "-rattr queue $help $queue_list"]
  if {$prg_exit_state != 0} {
     if {$add_error == 1} {
        ts_log_severe "qconf -rattr queue $help $queue_list failed:\n$result"
     }
     return -1
  }
  # split each line as listelement
  set result [string trim $result]
  set help [split $result "\n"]
  set counter 0
  set return_value 0

  foreach elem $help {
     ts_log_finest "line: $elem"
     set queue_name [lindex $queue_list $counter]
     set MODIFIED [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS] $CHECK_USER "*" "*" "*"]
     if { [ string match "*$MODIFIED*" $elem ] != 1 } {
        ts_log_fine "Could not modify queue $queue_name."
        set return_value -1
     } else {
        puts "Modified queue $queue_name successfully."
     }
     incr counter 1
   }

   if { $return_value != 0 } {
     if { $add_error == 1} {
       ts_log_severe "could not modify queue \"$queue_name\""
     }
   }

   return $return_value
}

#****** sge_procedures/mhattr() ************************************************
#  NAME
#     mhattr() -- Modify host qttributes
#
#  SYNOPSIS
#     mhattr { attribute entry host_name { add_error 1 } }
#
#  FUNCTION
#     This procedure enables the caller to moidify particular host attributes.
#     Look at set_exechost for host attributes.
#
#  INPUTS
#     attribute       - name of attribute to modify
#     entry           - new value for attribute
#     host_name       - name of the host to change
#     { add_error 1 } - execute ts_log_severe
#
#  RESULT
#     -1 - error
#     0  - ok
#
#  EXAMPLE
#     set return_value [mhattr "complex" "bla=test" "$host_name" ]
#
#  SEE ALSO
#     sge_procedures/mqattr()
#     sge_procedures/set_exechost()
#*******************************************************************************
proc mhattr { attribute entry host_name { add_error 1 } } {
# returns
# -1 on error
# 0 on success

  global CHECK_USER
  get_current_cluster_config_array ts_config

  ts_log_fine "Trying to change attribute $attribute for host $host_name to $entry."

  set help "$attribute \"$entry\""   ;# create e.g. slots "5" as string
  set result [start_sge_bin "qconf" "-rattr exechost $help $host_name"]
  if {$prg_exit_state != 0} {
     if {$add_error == 1} {
        ts_log_severe "qconf -rattr exechost $help $host_name failed:\n$result"
     } else {
        ts_log_fine "Could not modify host $host_name:\n$result"
     }
     return -1
  }

  # split each line as listelement
  set return_value 0

  set MODIFIED [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS] $CHECK_USER "*" "*" "*"]
  if {[string match "*$MODIFIED*" $result] != 1} {
     if {$add_error == 1} {
        ts_log_severe "qconf -rattr exechost $help $host_name failed:\n$result"
     } else {
        ts_log_fine "Could not modify host $host_name:\n$result"
     }
     set return_value -1
  } else {
     ts_log_fine "Modified host $host_name successfully."
  }

  if {$return_value != 0} {
     if {$add_error == 1} {
       ts_log_severe "could not modify host \"$host_name\""
     }
  }

  return $return_value
}


#****** sge_procedures/mod_attr() ******************************************
#  NAME
#     mod_attr() -- modify an attribute
#
#  SYNOPSIS
#     mod_attr { object attribute value target {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Modifies attribute of object with value for object_instance
#
#  INPUTS
#     object       - object we are modifying
#     attribute    - attribute of object we are modifying
#     value        - value of attribute of object we are modifying
#     target       - target object
#     {fast_add 1} - 0: modify the attribute using qconf -mattr,
#                  - 1: modify the attribute using qconf -Mattr, faster
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     integer value  0 on success, -2 on error
#
#*******************************************************************************
proc mod_attr { object attribute value target {fast_add 1} {on_host ""} {as_user ""} {raise_error 1} } {
   global CHECK_USER
   get_current_cluster_config_array ts_config


   ts_log_fine "Modifying object \"$object\" attribute  \"$attribute\" value \"$value\" for target \"$target\" "

   # add queue from file?
    if { $fast_add } {
      set default_array($attribute) "$value"
      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile default_array $on_host]
      set result [start_sge_bin "qconf" "-Mattr $object $tmpfile $target"  $on_host $as_user]

      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [mod_attr_file_error $result $object $attribute $tmpfile $target $raise_error]
      }

   } else {
      # add by -mattr

      set result [start_sge_bin "qconf" "-mattr  $object $attribute $value $target" $on_host $as_user ]
      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [mod_attr_error $result $object $attribute $value $target $raise_error]
      }

   }

   return $ret
}

#****** sge_procedures/mod_attr_error() ***************************************
#  NAME
#     mod_attr_error() -- error handling for mod_attr
#
#  SYNOPSIS
#     mod_attr_error {result object attribute value target raise_error }
#
#  FUNCTION
#     Does the error handling for mod_attr.
#     Translates possible error messages of qconf -mattr,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     mod_attr. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     object      - object qconf is modifying
#     tmpfile     - temp file for qconf -Mattr
#     attribute    - attribute of object we are modifying
#     value        - value of attribute of object we are modifying
#     target      - target object
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     Returncode for mod_attr function:
#      -1: "wrong_attr" is not an attribute
#      -2: "empty or invalid file" supplied
#     -99: other error
#
#  SEE ALSO
#     sge_calendar/get_calendar
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc mod_attr_file_error {result object attribute tmpfile target raise_error} {
   global ts_config

   # recognize certain error messages and return special return code
   set messages(index) "-1 -2"
   set messages(-1) [translate_macro MSG_UNKNOWNATTRIBUTENAME_S $attribute ]
   set messages(-2) "*[translate_macro MSG_FLATFILE_ERROR_READINGFILE_S "*"]*"

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "mod_attr" "qconf -Mattr $object $tmpfile $target" $result messages $raise_error]

   return $ret
}

proc mod_attr_error {result object attribute value target raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1 -2"
   set messages(-1) [translate_macro MSG_QCONF_BAD_ATTR_ARGS_SS $attribute $value]
   set messages(-2) [translate_macro MSG_QCONF_CANTCHANGEOBJECTNAME_SS "qconf" $attribute]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "mod_attr" "qconf -mattr $object $attribute $value $target" $result messages $raise_error]

   return $ret
}



#****** sge_procedures/get_attr() ******************************************
#  NAME
#     get_attr() -- get an attribute
#
#  SYNOPSIS
#     get_attr {object attribute  target {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Get attribute of object
#
#  INPUTS
#     object       - object we are getting
#     attribute    - attribute of object we are modifying
#     target       - target object
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#     array of attribute information
#
#*******************************************************************************
proc get_attr { object attribute target {on_host ""} {as_user ""} {raise_error 1} } {

   return [get_qconf_list "get_attr" "-sobjl $object $attribute $target " out $on_host $as_user $raise_error]

}
#****** sge_procedures/del_attr() ******************************************
#  NAME
#     del_attr() -- Delete an attribute
#
#  SYNOPSIS
#     del_attr { object attribute value target {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Delete attribute of object
#
#  INPUTS
#     object       - object we are deleting
#     attribute    - attribute of queue we are deleting
#     value        - value of attribute we are deleting
#     target       - target object
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {fast_add 1} - 0: modify the attribute using qconf -dattr,
#                  - 1: modify the attribute using qconf -Dattr, faster
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     integer value  0 on success, -2 on error
#
#*******************************************************************************
proc del_attr { object attribute value target {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   ts_log_fine "Deleting attribute \"$attribute\" for object \"$object\""

   # add queue from file?
    if { $fast_add } {
      set default_array($attribute) "$value"
      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile default_array $on_host]
      set result [start_sge_bin "qconf" "-Dattr $object $tmpfile $target" $on_host $as_user]

      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [del_attr_file_error $result $object $tmpfile  $attribute $target $raise_error]
      }


   } else {
   # add by -dattr

      set result [start_sge_bin "qconf" "-dattr $object $attribute $value $target" $on_host $as_user]

      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [del_attr_error $result $object $attribute $value $target $raise_error]
      }

   }

   return $ret
}

#****** sge_procedures/del_attr_error() ***************************************
#  NAME
#     del_attr_error() -- error handling for del_attr_
#
#  SYNOPSIS
#     del_attr_error {result object attribute value target raise_error }
#
#  FUNCTION
#     Does the error handling for mod_attr.
#     Translates possible error messages of qconf -dattr,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     mod_attr. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     object      - object qconf is modifying
#     attribute    - attribute of object we are modifying
#     value        - value of attribute of object we are modifying
#     target      - target object
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     Returncode for del_attr function:
#      -1: "wrong_attr" is not an attribute
#     -99: other error
#
#  SEE ALSO
#     sge_calendar/get_calendar
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc del_attr_error {result object attribute value target raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1"
   set messages(-1) [translate_macro MSG_QCONF_BAD_ATTR_ARGS_SS $attribute $value]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "del_attr" "qconf -dattr $object $attribute $value $target" $result messages $raise_error]

   return $ret
}

proc del_attr_file_error {result object tmpfile attribute target raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1"
   set messages(-1) [translate_macro MSG_UNKNOWNATTRIBUTENAME_S $attribute ]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "del_attr" "qconf -Dattr $object $tmpfile $target " $result messages $raise_error]

   return $ret
}


#****** sge_procedures/add_attr() ******************************************
#  NAME
#    add_attr () -- add an attribute
#
#  SYNOPSIS
#     add_attr { object attribute value target {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Modifies attribute of object with value for object_instance
#
#  INPUTS
#     object       - object we are modifying
#     attribute    - attribute of queue we are modifying
#     value        - value of attribute of object we are modifying
#     target       - target object
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {fast_add 1} - 0: modify the attribute using qconf -aattr,
#                  - 1: modify the attribute using qconf -Aattr, faster
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     integer value  0 on success, -2 on error
#
#*******************************************************************************
proc add_attr { object attribute value target {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   ts_log_fine "Adding attribute \"$attribute\" for object \"$object\""

   # add queue from file?
    if { $fast_add } {
      set default_array($attribute) "$value"
      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile default_array $on_host]
      set result [start_sge_bin "qconf" "-Aattr $object $tmpfile $target" $on_host $as_user]

      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [add_attr_file_error $result $object $tmpfile  $attribute $target $raise_error]
      }


   } else {
      # add by -aattr

      set result [start_sge_bin "qconf" "-aattr  $object $attribute $value $target" $on_host $as_user]
      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [add_attr_error $result $object $attribute $value $target $raise_error]
      }

   }

   return $ret
}

#****** sge_procedures/add_attr_error() ***************************************
#  NAME
#     add_attr_error() -- error handling for add_attr
#
#  SYNOPSIS
#     add_attr_error {result object attribute value target raise_error }
#
#  FUNCTION
#     Does the error handling for add_attr.
#     Translates possible error messages of qconf -aattr,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     add_attr. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     object      - object qconf is modifying
#     attribute    - attribute of object we are modifying
#     value        - value of attribute of object we are modifying
#     target      - target object
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     Returncode for add_attr function:
#      -1: "wrong_attr" is not an attribute
#     -99: other error
#
#  SEE ALSO
#     sge_calendar/get_calendar
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc add_attr_error {result object attribute value target raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1"
   set messages(-1) [translate_macro MSG_QCONF_BAD_ATTR_ARGS_SS $attribute $value]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "add_attr" "qconf -aattr $object $attribute $value $target" $result messages $raise_error]

   return $ret
}

proc add_attr_file_error {result object tmpfile attribute target raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1"
   set messages(-1) [translate_macro MSG_UNKNOWNATTRIBUTENAME_S $attribute ]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "add_attr" "qconf -Aattr $object $tmpfile $target " $result messages $raise_error]

   return $ret
}


#****** sge_procedures/replace_attr() ******************************************
#  NAME
#     replace_attr() -- Replace an attribute
#
#  SYNOPSIS
#     replace_attr {object attribute value target {fast_add 1} {on_host ""} {as_user ""} {raise_error 1} }
#
#  FUNCTION
#     Replace attribute of object
#
#  INPUTS
#     object       - object we are deleting
#     attribute    - attribute of object we are deleting
#     value        - value of attribute we are deleting
#     target       - target object
#     {fast_add 1} - 0: modify the attribute using qconf -rattr,
#                  - 1: modify the attribute using qconf -Rattr, faster
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     integer value  0 on success, -2 on error
#
#*******************************************************************************
proc replace_attr { object attribute value target {fast_add 1} {on_host ""} {as_user ""} {raise_error 1} } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   ts_log_fine "Replacing attribute \"$attribute\" of object \"$object\""

   # add queue from file?
    if { $fast_add } {
      set default_array($attribute) "$value"
      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile default_array $on_host]
      set result [start_sge_bin "qconf" "-Rattr $object $tmpfile $target" $on_host $as_user]

      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [replace_attr_file_error $result $object $attribute $tmpfile $target $raise_error]
      }
   } else {
      # add by -rattr

      set result [start_sge_bin "qconf" "-rattr $object $attribute $value $target" $on_host $as_user ]

      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [replace_attr_error $result $object $attribute $value $target $raise_error]
      }

   }

   return $ret

}

#****** sge_procedures/replace_attr_error() ***************************************
#  NAME
#     replace_attr_error() -- error handling for replace_attr
#
#  SYNOPSIS
#     replace_attr_error {result object attribute value target raise_error }
#
#  FUNCTION
#     Does the error handling for mod_attr.
#     Translates possible error messages of qconf -rattr,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     replace_attr. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     object      - object qconf is modifying
#     attribute    - attribute of object we are modifying
#     value        - value of attribute of object we are modifying
#     target      - target object
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     Returncode for replace_attr function:
#      -1: "wrong_attr" is not an attribute
#     -99: other error
#
#  SEE ALSO
#     sge_calendar/get_calendar
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc replace_attr_error {result object attribute value target raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1"
   set messages(-1) [translate_macro MSG_QCONF_BAD_ATTR_ARGS_SS $attribute $value]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "replace_attr" "qconf -rattr $object $attribute $value $target" $result messages $raise_error]

   return $ret
}


proc replace_attr_file_error {result object attribute tmpfile target raise_error} {
   get_current_cluster_config_array ts_config

   # recognize certain error messages and return special return code
   set messages(index) -1
   set messages(-1) "error: [translate_macro MSG_UNKNOWNATTRIBUTENAME_S $attribute ]"

   lappend messages(index) -2
   set messages(-2) [translate_macro MSG_PARSE_MOD_REJECTED_DUE_TO_AR_SSU "*" "*" "*"]
   lappend messages(index) -3
   set messages(-3) [translate_macro MSG_PARSE_MOD3_REJECTED_DUE_TO_AR_SU "*" "*"]
   lappend messages(index) -4
   set messages(-4) [translate_macro MSG_QINSTANCE_SLOTSRESERVED_USS "*" "*" "*"]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "replace_attr" "qconf -Rattr $object $tmpfile $target" $result messages $raise_error]

   return $ret
}

#                                                             max. column:     |
#****** sge_procedures/suspend_job() ******
#
#  NAME
#     suspend_job -- set job in suspend state
#
#  SYNOPSIS
#     suspend_job { id }
#
#  FUNCTION
#     This procedure will call qmod to suspend the given job id.
#
#  INPUTS
#     id          - job identification number
#     force       - do a qmod -f
#     error_check - raise an error in case qmod fails
#
#  RESULT
#     0  - ok
#     -1 - error
#
#  SEE ALSO
#     sge_procedures/unsuspend_job()
#*******************************
proc suspend_job { id {force 0} {error_check 1}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   ts_log_fine "suspending job $id"

   set SUSPEND1 [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_JOB_SUSPENDTASK_SUU] $CHECK_USER $id "*" ]
   set SUSPEND2 [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_JOB_SUSPENDJOB_SU] $CHECK_USER $id ]
   set ALREADY_SUSP1 [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_JOB_ALREADYSUSPENDED_SUU] $CHECK_USER $id "*"]
   set ALREADY_SUSP2 [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_JOB_ALREADYSUSPENDED_SU] $CHECK_USER $id]
   set FORCED_SUSP1 [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_JOB_FORCESUSPENDTASK_SUU] $CHECK_USER $id "*"]
   set FORCED_SUSP2 [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_JOB_FORCESUSPENDJOB_SU] $CHECK_USER $id]
   log_user 0
   set master_arch [resolve_arch $ts_config(master_host)]
   set program "$ts_config(product_root)/bin/$master_arch/qmod"
   if {$force} {
      set sid [open_remote_spawn_process $ts_config(master_host) $CHECK_USER $program "-f -s $id"]
   } else {
      set sid [open_remote_spawn_process $ts_config(master_host) $CHECK_USER $program "-s $id"]
   }

   set sp_id [ lindex $sid 1 ]
   set timeout 30
   set result -1
   log_user 0

   expect {
      -i $sp_id full_buffer {
         set result -1
         ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
      }
      -i $sp_id -- "$SUSPEND1" {
         ts_log_finest "$expect_out(0,string)"
         set result 0
      }
      -i $sp_id -- "$SUSPEND2" {
         ts_log_finest "$expect_out(0,string)"
         set result 0
      }
      -i $sp_id -- "$ALREADY_SUSP1" {
         ts_log_finest "$expect_out(0,string)"
         set result -1
      }
      -i $sp_id -- "$ALREADY_SUSP2" {
         ts_log_finest "$expect_out(0,string)"
         set result -1
      }
      -i $sp_id -- "$FORCED_SUSP1" {
         ts_log_finest "$expect_out(0,string)"
         set result 0
      }
      -i $sp_id -- "$FORCED_SUSP2" {
         ts_log_finest "$expect_out(0,string)"
         set result 0
      }
      -i $sp_id "suspended job" {
         set result 0
      }
      -i $sp_id default {
         ts_log_finest "unexpected output: $expect_out(0,string)"
         set result -1
      }
   }
   # close spawned process
   close_spawn_process $sid

   # error check
   if { $error_check && $result != 0 } {
      ts_log_severe "could not suspend job $id"
   }

   return $result
}

#                                                             max. column:     |
#****** sge_procedures/unsuspend_job() ******
#
#  NAME
#     unsuspend_job -- set job bakr from unsuspended state

#
#  SYNOPSIS
#     unsuspend_job { job }
#
#  FUNCTION
#     This procedure will call qmod to unsuspend the given job id.
#
#  INPUTS
#     job - job identification number

#
#  RESULT
#     0   - ok
#     -1  - error
#
#  SEE ALSO
#     sge_procedures/suspend_job()
#*******************************
proc unsuspend_job { job } {
  global CHECK_USER
  get_current_cluster_config_array ts_config

   ts_log_fine "unsuspending job $job"


  set UNSUSPEND1 [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_JOB_UNSUSPENDTASK_SUU] "*" "*" "*" ]
  set UNSUSPEND2 [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_JOB_UNSUSPENDJOB_SU] "*" "*" ]

  log_user 0
  # spawn process
  set master_arch [resolve_arch $ts_config(master_host)]
  set program "$ts_config(product_root)/bin/$master_arch/qmod"
  set sid [open_remote_spawn_process $ts_config(master_host) $CHECK_USER $program "-us $job"]
  set sp_id [ lindex $sid 1 ]
  set timeout 30
  set result -1
  log_user 0

  expect {
       -i $sp_id full_buffer {
          set result -1
          ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
       }
       -i $sp_id $UNSUSPEND1 {
          set result 0
       }
       -i $sp_id $UNSUSPEND2 {
          set result 0
       }
       -i $sp_id "unsuspended job" {
          set result 0
       }
       -i $sp_id default {
          set result -1
       }

  }

  # close spawned process
  close_spawn_process $sid
  if { $result != 0 } {
     ts_log_severe "could not unsuspend job $job"
  }
  return $result
}


#****** sge_procedures/is_job_id() *********************************************
#  NAME
#     is_job_id() -- check if job_id is a real sge job id
#
#  SYNOPSIS
#     is_job_id { job_id }
#
#  FUNCTION
#     This procedure returns 1 if the given job id is a valid sge job id
#
#  INPUTS
#     job_id - job id
#
#  RESULT
#     1 on success, 0 on error
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc is_job_id { job_id } {
   if { [string is integer $job_id] != 1} {
      if { [set pos [string first "." $job_id ]] >= 0 } {
         incr pos -1
         set array_id [  string range $job_id 0 $pos]
         incr pos 2
         set task_rest [ string range $job_id $pos end]
         if { [string is integer $array_id] != 1} {
            ts_log_severe "unexpected task job id: $array_id (no integer)"
            return 0
         }
      } else {
         ts_log_severe "unexpected job id: $job_id (no integer)"
         return 0
      }
   }
   if { $job_id <= 0 } {
      ts_log_severe "unexpected job id: $job_id (no positive number)"
      return 0
   }
   return 1
}

#                                                             max. column:     |
#****** sge_procedures/delete_job() ******
#
#  NAME
#     delete_job -- delete job with jobid
#
#  SYNOPSIS
#     delete_job { jobid { wait_for_end 0 }}
#
#  FUNCTION
#     This procedure will delete the job with the given jobid
#
#  INPUTS
#     jobid            - job identification number
#     {wait_for_end 0} - optional, if not 0: wait for end of job
#                          (till qstat -f $jobid returns "job not found")
#     {all_users 0}    - delete jobs of all users (as administrator), default no
#     {raise_error 1}  - raise an error condition on error, default yes
#
#  RESULT
#     0   - ok
#    -1   - qdel error
#    -4   - unknown message from qdel
#    -5   - timeout or buffer overflow error
#
#  SEE ALSO
#     sge_procedures/submit_job()
#*******************************
global g_delete_job_messages
unset -nocomplain g_delete_job_messages
proc delete_job {jobid {wait_for_end 0} {all_users 0} {raise_error 1} {user ""}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   global g_delete_job_messages
   upvar 0 g_delete_job_messages messages

   if {$user == ""} {
      set user $CHECK_USER
   }
   ts_log_fine "deleting job $jobid as $user"

   if {![info exists messages(ALREADYDELETED)]} {
      set messages(ALREADYDELETED) [translate_macro MSG_JOB_ALREADYDELETED_U "*"]
      set messages(REGISTERED1)    [translate_macro MSG_JOB_REGDELTASK_SUU "*" "*" "*"]
      set messages(REGISTERED2)    [translate_macro MSG_JOB_REGDELX_SSU "*" "job" "*" ]
      set messages(DELETED1)       [translate_macro MSG_JOB_DELETETASK_SUU "*" "*" "*"]
      set messages(DELETED2)       [translate_macro MSG_JOB_DELETEX_SSU "*" "job" "*" ]
      set messages(UNABLETOSYNC)   [translate_macro MSG_COM_NOSYNCEXECD_SU $user "*"]
   }

   set result -100
   if {[is_job_id $jobid]} {
      # spawn process
      set program "$ts_config(product_root)/bin/[resolve_arch $ts_config(master_host)]/qdel"

      # beginning with SGE 6.0 we need to specify if we want to delete jobs from
      # other users (as admin user)
      set args ""
      if {$all_users} {
         set args "-u '*'"
      }
      set id [open_remote_spawn_process $ts_config(master_host) $user $program "$args $jobid"]
      set sp_id [ lindex $id 1 ]
      set timeout 60
      log_user 1

      while {$result == -100} {
      expect {
          -i $sp_id timeout {
             ts_log_severe "timeout waiting for qdel" $raise_error
             set result -5
          }

          -i $sp_id full_buffer {
             set result -5
             ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value" $raise_error
          }
          -i $sp_id $messages(REGISTERED1) {
             ts_log_finest $expect_out(0,string)
             set result 0
          }
          -i $sp_id $messages(REGISTERED2) {
             ts_log_finest $expect_out(0,string)
             set result 0
          }
          -i $sp_id "registered the job" {
             ts_log_finest $expect_out(0,string)
             set result 0
          }
          -i $sp_id  $messages(DELETED1) {
             ts_log_finest $expect_out(0,string)
             set result 0
          }
          -i $sp_id  $messages(DELETED2) {
             ts_log_finest $expect_out(0,string)
             set result 0
          }
          -i $sp_id "has deleted job" {
             ts_log_finest $expect_out(0,string)
             set result 0
          }
          -i $sp_id $messages(ALREADYDELETED) {
             ts_log_finest $expect_out(0,string)
             set result 0
          }
          -i $sp_id $messages(UNABLETOSYNC) {
            ts_log_severe "$messages(UNABLETOSYNC)" $raise_error
            set result -1
          }
          -i default {
             if {[info exists expect_out(buffer)]} {
                ts_log_severe "expect default switch\noutput was:\n>$expect_out(buffer)<"
             }
             set result -4
          }
      }
      }
      # close spawned process
      close_spawn_process $id 1
   } else {
      ts_log_severe "job id is no integer" $raise_error
   }
   if {$result != 0} {
      ts_log_severe "could not delete job $jobid\nresult=$result" $raise_error
   }
   if {$wait_for_end != 0 && $result == 0} {
      set my_timeout [clock seconds]
      set my_second_qdel_timeout $my_timeout
      incr my_second_qdel_timeout 80
      incr my_timeout 160
      ts_log_fine "waiting for jobend (1) (qstat -j $jobid)"
      # we might do scheduling on demand, trigger scheduling to make scheduler send delete order
      trigger_scheduling
      after 500
      while {[get_qstat_j_info $jobid ] != 0} {
          if {[clock seconds] > $my_timeout} {
             ts_log_severe "timeout while waiting for jobend" $raise_error
             break
          }
          if {[clock seconds] > $my_second_qdel_timeout} {
             ts_log_fine "timeout - deleting job!"
             set my_second_qdel_timeout $my_timeout
             delete_job $jobid
             continue
          }
          ts_log_progress
          # we might do scheduling on demand, trigger scheduling to make scheduler send delete order
          trigger_scheduling
          after 500
      }
   }
   return $result
}


#                                                             max. column:     |
#****** sge_procedures/submit_job() ******
#
#  NAME
#     submit_job -- submit a job with qsub
#
#  SYNOPSIS
#     submit_job { args {do_error_check 1} {submit_timeout 60} {host ""}
#                  {user ""} { cd_dir ""} { show_args 1 } {qcmd "qsub"} }
#
#  FUNCTION
#     This procedure will submit a job.
#
#  INPUTS
#     args                - a string of qsub arguments/parameters
#     {raise_error 1}     - if 1 (default): add global errors (ts_log_severe)
#                           if 0: do not add errors
#     {submit_timeout 30} - timeout (default is 30 sec.)
#     {host ""}           - host on which to execute qsub (default $ts_config(master_host))
#     {user ""}           - user who shall submit job (default $CHECK_USER)
#     {cd_dir ""}         - optional: do cd to given directory first
#     {show_args 1 }      - optional: show job arguments
#     {qcmd "qsub"}       - optional: to allow different command as f.e. qsh, qrsh
#     {dev_null 1}        - optional: indicate if the job standard/error output will
#                           be redirected to /dev/null, true by default
#                           if the qsub options -o/-e are specified, this parameter
#                           will be ignored
#     {the_output ""}     - optional: if set the specified variable contains the output
#                           of the submit command
#     {ignore_list{}}     - optional: list which error jobid errors should be ignored
#                           e.g.: "-38 -2"
#
#  RESULT
#     This procedure returns:
#
#     jobid   of array or job if submit was successfull (value > 1)
#        -1   general error
#        -2   if usage was printed on -help or commandfile argument
#        -3   if usage was printed NOT on -help or commandfile argument
#        -6   job could not be scheduled, try later
#        -7   has to much tasks - error
#        -8   unknown resource - error
#        -9   can't resolve hostname - error
#       -10   resource not requestable - error
#       -11   not allowed to submit jobs - error
#       -12   no access to project - error
#       -13   unknown option - error
#       -22   user tries to submit a job with a deadline, but the user is not in
#             the deadline user access list
#       -36   user tries to submit a job with same path for -i and -o
#
#      -100   on error
#
#
#  EXAMPLE
#     set jobs ""
#     set my_outputs "-o /dev/null -e /dev/null"
#     set arguments "$my_outputs -q $rerun_queue -r y $ts_config(product_root)/examples/jobs/sleeper.sh 1000"
#     lappend jobs [submit_job $arguments]
#
#  SEE ALSO
#     sge_procedures/delete_job()
#     sge_procedures/submit_job_parse_job_id()
#*******************************
global g_submit_job_messages
unset -nocomplain g_submit_job_messages
proc init_global_submit_job_messages {} {
   global g_submit_job_messages
   unset -nocomplain g_submit_job_messages

   upvar 0 g_submit_job_messages messages

   ts_log_fine "init_global_submit_job_messages: translating and caching messages"
   # we first want to parse errors first, then the positive messages,
   # as e.g. an immediate job might be correctly submitted, but then cannot be scheduled
   set messages(index) "-3 -6 -7 -8 -9 -10 -11 -12 -13 -14 -15 -16 -17 -18 -19 -20 -21 -22 -23 -24 -25 -26 -27 -28 -29 -30 -31 -32 -33 -34 -35 -36 -37 -38"
   append messages(index) " 0 1 2"

   # success messages:
   set messages(0)      "*[translate_macro MSG_JOB_SUBMITJOB_US "*" "*"]*"
   set messages(1)      "*[translate_macro MSG_QSUB_YOURIMMEDIATEJOBXHASBEENSUCCESSFULLYSCHEDULED_S "*"]*"
   set messages(2)      "*[translate_macro MSG_JOB_SUBMITJOBARRAY_UUUUS "*" "*" "*" "*" "*"]*"

   # failure messages:
   set messages(-14)   "TODO: jobnet handling changed, old message NON_AMBIGUOUS"
   set messages(-15)   "TODO: jobnet handling changed, old message UNAMBIGUOUSNESS"
   set messages(-24)   "*[translate_macro MSG_JOB_NAMETOOLONG_I "*"]*"
   set messages(-25)   "*[translate_macro MSG_JOB_JOBALREADYEXISTS_S "*"]*"
   set messages(-26)   "*[translate_macro MSG_INVALIDJOB_REQUEST_S "*"]*"
   set messages(-28)   "*[translate_macro MSG_QREF_QUNKNOWN_S "*"]*"

   set messages(-29)    "*[translate_macro MSG_JOB_NONADMINPRIO]*"
   set messages(-37)    "*[translate_macro MSG_EVAL_EXPRESSION_LONG_EXPRESSION "*"]*"
   set messages(-36)   "*[translate_macro MSG_JOB_SAMEPATHSFORINPUTANDOUTPUT_SSS "*" "*" "*"]"

   set messages(-35)    "*[translate_macro MSG_JOB_HRTLIMITTOOLONG_U "*"]*"

   set messages(-3)     "*[translate_macro MSG_GDI_USAGE_USAGESTRING] qsub*"
   set messages(-6)     "*[translate_macro MSG_QSUB_YOURQSUBREQUESTCOULDNOTBESCHEDULEDDTRYLATER]*"
   set messages(-7)     "*[translate_macro MSG_JOB_MORETASKSTHAN_U "*"]*"
   set messages(-8)     "*[translate_macro MSG_SGETEXT_UNKNOWN_RESOURCE_S "*"]*"
   set messages(-9)     "*[translate_macro MSG_SGETEXT_CANTRESOLVEHOST_S "*"]*"
   set messages(-10)    "*[translate_macro MSG_SGETEXT_RESOURCE_NOT_REQUESTABLE_S "*"]*"
   set messages(-11)    "*[translate_macro MSG_JOB_NOPERMS_SS "*" "*"]*"
   set messages(-12)    "*[translate_macro MSG_SGETEXT_NO_ACCESS2PRJ4USER_SS "*" "*"]*"
   if {[is_version_in_range "9.0.0"]} {
      set messages(-13)    "*[translate_macro MSG_ANSWER_UNKNOWNOPTIONX_S "*"]*"
   } else {
      set messages(-13)    "*[translate_macro MSG_ANSWER_UNKOWNOPTIONX_S "*"]*"
   }
   set messages(-16)    "*[translate_macro MSG_FILE_ERROROPENINGXY_SS "*" "*"]*"
   set messages(-17)    "*[translate_macro MSG_GDI_KEYSTR_MIDCHAR_SC [translate_macro MSG_GDI_KEYSTR_COLON] ":"]*"
   set messages(-18)    "*[translate_macro MSG_QCONF_ONLYONERANGE]*"
   set messages(-19)    "*[translate_macro MSG_PARSE_DUPLICATEHOSTINFILESPEC]*"
   set messages(-20)    "*[translate_macro MSG_GDI_NEGATIVSTEP]*"
   set messages(-21)    "*[translate_macro MSG_GDI_INITIALPORTIONSTRINGNODECIMAL_S "*"] *"
   set messages(-22)    "*[translate_macro MSG_JOB_NODEADLINEUSER_S "*"]*"
   set messages(-23)    "*[translate_macro MSG_CPLX_WRONGTYPE_SSS "*" "*" "*"]*"
   set messages(-27)    "*[translate_macro MSG_PARSE_INVALIDPRIORITYMUSTBEINNEG1023TO1024]*"
   set messages(-30)    "*[translate_macro MSG_GDI_KEYSTR_MIDCHAR_SC "*" "*"]*"
   set messages(-31)    "*[translate_macro MSG_ANSWER_INVALIDOPTIONARGX_S "*"]*"
   set messages(-32)    "*[translate_macro MSG_JOB_PRJNOSUBMITPERMS_S "*"]*"
   set messages(-33)    "*[translate_macro MSG_STREE_USERTNOACCESS2PRJ_SS "*" "*"]*"
   set messages(-34)    "*[translate_macro MSG_JOB_NOSUITABLEQ_S "*"]*"
   if {[is_version_in_range "9.1.0"]} {
      set messages(-39)    "*[translate_macro MSG_REQLIMIT_EXCEEDED_S "*"]*"
      set messages(-40)    "*[translate_macro MSG_JOB_USERNOTPARTDEPT_SS "*" "*"]*"
   }
   # should be last message
   set messages(-38)    "*[translate_macro MSG_QSUB_COULDNOTRUNJOB_S "*"]*"
}

proc submit_job {args {raise_error 1} {submit_timeout 60} {host ""} {user ""} {cd_dir ""} {show_args 1} {qcmd "qsub"} {dev_null 1} {the_output "qsub_output"} {ignore_list {}} {new_grp ""} {env_var ""}} {
   get_current_cluster_config_array ts_config
   global g_submit_job_messages
   global CHECK_USER

   if {$the_output != ""} {
      upvar $the_output output
      set output ""
   }

   if {$env_var != ""} {
      upvar $env_var myenv
   }

   # cache the messages in a global variable, map it to our local messages variable
   upvar 0 g_submit_job_messages messages
   if {![info exists messages(index)]} {
      init_global_submit_job_messages
   }

   # add the standard/error output options if necessary
   if { $qcmd == "qsub" } {
      if { [string first "-o " $args] == -1 && $dev_null == 1} {
         set args "-o /dev/null $args"
         ts_log_finest "added submit argument: -o /dev/null"
      }
      if { [string first "-e " $args] == -1 && $dev_null == 1} {
         set args "-e /dev/null $args"
         ts_log_finest "added submit argument: -e /dev/null"
      }
   }

   set output [start_sge_bin $qcmd $args $host $user prg_exit_state $submit_timeout $cd_dir "bin" output_lines myenv $new_grp]

   set ret [handle_sge_errors "submit_job" "$qcmd $args" $output messages $raise_error "" $ignore_list]

   # some special handling
   switch -exact -- $ret {
      0 -
      1 -
      2 {
         set ret_code [submit_job_parse_job_id output $ret $messages($ret)]
      }

      -3 {
         if {[string first "help" $args] >= 0 || [string first "commandfile" $args] >= 0} {
            set ret_code -2
         }
      }

      default {
         set ret_code $ret
      }
   }
   if {$show_args == 1} {
      set my_user $user
      if {$my_user == ""} {
         set my_user $CHECK_USER
      }
      if {$ret_code > 0} {
         ts_log_fine "job \"$ret_code\" submitted as \"$my_user\" with args=\"$args\""
      }
   }

   # return job id or error code
   return $ret_code
}

#****** sge_procedures/submit_sleeper_job() ************************************
#  NAME
#     submit_sleeper_job() -- Submit a sleeper job into the cluster
#
#  SYNOPSIS
#     submit_sleeper_job { sleep_time {additional_qsub_args ""} }
#
#  FUNCTION
#     Submits a sleeber job into the cluster, with its output redirected to /dev/null
#
#  INPUTS
#     sleep_time           - the sleep time in seconds
#     additional_qsub_args - additional arguments for qsub
#
#  RESULT
#     Result of the submit_job method
#
#  EXAMPLE
#     submit_sleeper_job 30 "-N MySleeper"
#
#  SEE ALSO
#     sge_procedures/submit_job()
#*******************************************************************************
proc submit_sleeper_job { sleep_time { additional_qsub_args "" } } {

  global ts_config

  return [submit_job "$additional_qsub_args -o /dev/null -e /dev/null $ts_config(product_root)/examples/jobs/sleeper.sh $sleep_time"]

}

#****** sge_procedures/quick_submit_job() ******
#
#  NAME
#     quick_submit_job -- submit a job, quick version
#
#  SYNOPSIS
#     quick_submit_job {args {host ""} {user ""}}
#
#  FUNCTION
#     This procedure will submit a job.
#     Minimal error handling (only checking return code of qsub)0
#     makes it faster than submit_job.
#
#  INPUTS
#     args                - a string of qsub arguments/parameters
#     {host ""}           - host on which to execute qsub (default is to use
#                           various hosts (see host_conf_get_suited_hosts))
#     {user ""}           - user who shall submit job (default $CHECK_USER)
#
#  RESULT
#     1: job submission succeeded
#     0: job submission failed. An error will be created containing the
#        qsub error output.
#
#  SEE ALSO
#     sge_procedures/submit_job()
#*******************************************************************************
proc quick_submit_job {args {host ""} {user ""}} {
   set output [start_sge_bin "qsub" $args $host $user]

   if {$prg_exit_state != 0} {
      ts_log_severe "qsub $args failed:\n$output"
      return 0
   }

   return 1
}

#****** sge_procedures/resubmit_job() ******************************************
#  NAME
#     resubmit_job() -- Resubmit a job and scan the output for macros.
#
#  SYNOPSIS
#     resubmit_job { args {raise_error 1} {submit_timeout 60} {host ""}
#     {user ""} {show_args 1} }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     args                - qresub arguments
#     {raise_error 1}     - see submit_job
#     {submit_timeout 60} - see submit_job
#     {host ""}           - see submit_job
#     {user ""}           - see submit_job
#     {show_args 1}       - see submit_job
#
#  RESULT
#      1 - output message "job has been submitted" found
#      2 - usage string (the help) in output found
#      3 - job could successfully be submitted
#      -1 - unknown hold list option
#      -2 - invalid job task id found
#      -3 - job does not exist
#      -4 - user must have operator privileges
#      -5 - user must have manager privileges
#
#  SEE ALSO
#     sge_procedures/submit_job()
#*******************************************************************************
global g_resubmit_job_messages
unset -nocomplain g_resubmit_job_messages
proc resubmit_job {args {raise_error 1} {submit_timeout 60} {host ""} {user ""} {show_args 1}} {
   global g_resubmit_job_messages
   upvar 0 g_resubmit_job_messages messages

   if {![info exists messages(index)]} {
      ts_log_fine "resubmit_job: translating messages"
      # job was submitted
      add_message_to_container messages 1 [translate_macro MSG_QSUB_YOURJOBHASBEENSUBMITTED_SS "*" "*"]
      add_message_to_container messages 2 [translate_macro MSG_GDI_USAGE_USAGESTRING "qresub"]
      add_message_to_container messages 3 [translate_macro MSG_JOB_SUBMITJOB_US "*" "*"]

      # modied hold
      add_message_to_container messages -1 [translate_macro MSG_PARSE_UNKNOWNHOLDLISTXSPECTOHOPTION_S "*"]
      add_message_to_container messages -2 [translate_macro MSG_JOB_XISINVALIDJOBTASKID_S "*"]
      add_message_to_container messages -3 [translate_macro MSG_ERROR_JOBDOESNOTEXIST]

      # when modification is not allowed because of needed manager/operator rights
      add_message_to_container messages -4 [translate_macro MSG_SGETEXT_MUST_BE_OPR_TO_SS "*" "*"]
      add_message_to_container messages -5 [translate_macro MSG_SGETEXT_MUST_BE_MGR_TO_SS "*" "*"]
   }

   # process
   set output [start_sge_bin "qresub" $args $host $user prg_exit_state $submit_timeout]

   return [handle_sge_errors "resubmit_job" "qresub $args" $output messages $raise_error]
}


#****** sge_procedures/submit_job_parse_job_id() *******************************
#  NAME
#     submit_job_parse_job_id() -- parse job id from qsub output
#
#  SYNOPSIS
#     submit_job_parse_job_id { output_var type message }
#
#  FUNCTION
#     Analyzes qsub output and parsed the job id from this output.
#     The qsub output may contain additional warning messages.
#
#  INPUTS
#     output_var - qsub output (pass by reference)
#     type       - 0: sequential job
#                  1: array job
#                  2: immediate job
#     message    - expected job submission message
#
#  RESULT
#     the job id, or -1 on error
#
#  SEE ALSO
#     sge_procedures/submit_job()
#*******************************************************************************
global g_submit_job_parse_pos
unset -nocomplain g_submit_job_parse_pos

proc init_global_submit_job_parse_job_id_messages {} {
   global g_submit_job_parse_pos
   unset -nocomplain g_submit_job_parse_pos

   ts_log_fine "submit_job_parse_job_id: translating messages"
   set JOB_SUBMITTED_DUMMY [translate_macro MSG_JOB_SUBMITJOB_US "__JOB_ID__" "__JOB_NAME__"]
   set g_submit_job_parse_pos(0) [lsearch -exact $JOB_SUBMITTED_DUMMY "__JOB_ID__"]

   # 6.0 and higher
   set JOB_IMMEDIATE_DUMMY [translate_macro MSG_QSUB_YOURIMMEDIATEJOBXHASBEENSUCCESSFULLYSCHEDULED_S "__JOB_ID__"]
   set g_submit_job_parse_pos(1) [lsearch -exact $JOB_IMMEDIATE_DUMMY "__JOB_ID__"]

   set JOB_ARRAY_SUBMITTED_DUMMY [translate_macro MSG_JOB_SUBMITJOBARRAY_UUUUS "__JOB_ID__" "" "" "" "__JOB_NAME__"]
   set g_submit_job_parse_pos(2) [lsearch -exact $JOB_ARRAY_SUBMITTED_DUMMY "__JOB_ID__.-:"]
}

proc submit_job_parse_job_id {output_var type message} {
   get_current_cluster_config_array ts_config
   global g_submit_job_parse_pos

   upvar $output_var output

   set ret -1

   # we need to determine the position of the job id in the output message
   if {![info exists g_submit_job_parse_pos(0)]} {
      init_global_submit_job_parse_job_id_messages
   }

   set pos $g_submit_job_parse_pos($type)

   # output might contain multiple lines, e.g. with additional warning messages
   # we have to find the right one
   foreach line [split $output "\n"] {
      if {[string match $message $line]} {
         # read job id from line
         set help [lindex $line $pos]
         # strip possibly contained array task info
         set ret [lindex [split $help "."] 0]
         break
      }
   }

   # we didn't find the expected job start message in qsub output
   # should never happen, as message has been matched before by handle_sge_errors
   if {$ret == -1} {
      ts_log_severe "couldn't find qsub success message\n$message\nin qsub output\n$output"
   }

   return $ret
}



#                                                             max. column:     |
#****** sge_procedures/get_grppid_of_job() ******
#
#  NAME
#     get_grppid_of_job -- get grppid of job
#
#  SYNOPSIS
#     get_grppid_of_job { jobid }
#
#  FUNCTION
#     This procedure opens the job_pid file in the execution host spool directory
#     and returns the content of this file (grppid).
#
#
#  INPUTS
#     jobid - identification number of job
#
#  RESULT
#     grppid of job
#
#  SEE ALSO
#     sge_procedures/get_suspend_state_of_job()
#*******************************
proc get_grppid_of_job { jobid {host ""}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   # default for host parameter, use localhost
   if {$host == ""} {
      set host $ts_config(master_host)
   }

   # read execd spooldir from local or global config
   get_config value $host
   if {[info exists value(execd_spool_dir)]} {
      set spool_dir $value(execd_spool_dir)
      ts_log_finest "using local exec spool dir"
   } else {
      ts_log_finest "using global exec spool dir"
      get_config value
      set spool_dir $value(execd_spool_dir)
   }

   ts_log_finest "Exec Spool Dir is: $spool_dir"

   # build name of pid file
   set pidfile "$spool_dir/$host/active_jobs/$jobid.1/job_pid"

   wait_for_remote_file $host $CHECK_USER $pidfile

   # read pid from pidfile on execution host
   set real_pid [start_remote_prog $host $CHECK_USER "cat" "$pidfile"]
   if {$prg_exit_state != 0} {
      ts_log_severe "can't read $pidfile on host $host: $real_pid"
      set real_pid ""
   }

   # trim trailing newlines etc.
   set real_pid [string trim $real_pid]
   return $real_pid
}


#
#****** sge_procedures/get_suspend_state_of_job() ******************************
#
#  NAME
#     get_suspend_state_of_job() -- get suspend state of job from ps command
#
#  SYNOPSIS
#     get_suspend_state_of_job { jobid { pidlist pid_list } {do_error_check 1}
#     { pgi process_group_info } }
#
#  FUNCTION
#     This procedure returns the suspend state of jobid (letter from ps command).
#     Beyond that a array (pidlist) is set, in which all process id of the process
#     group are listed. The caller of the function can access the array pid_list!
#
#  INPUTS
#     jobid                      - job identification number
#     { host "" }                - host the job is running on, default $ts_config(master_host)
#     { pidlist pid_list }       - name of variable to store the pidlist
#     {do_error_check 1}         - enable error messages (ts_log_severe), default
#                                  if not 1 the procedure will not report errors
#     { pgi process_group_info } - string with ps output of process group of job
#
#  RESULT
#     suspend state (letter from ps command)
#
#  SEE ALSO
#     sge_procedures/get_grppid_of_job()
#     sge_procedures/ts_log_severe()
#*******************************************************************************
proc get_suspend_state_of_job { jobid {host ""} { pidlist pid_list } {do_error_check 1} { pgi process_group_info } } {
   get_current_cluster_config_array ts_config

   upvar $pidlist pidl
   upvar $pgi pginfo

   if {$host == ""} {
      set host $ts_config(master_host)
   }

   # get process group id
   set real_pid [get_grppid_of_job $jobid $host]
   ts_log_fine "grpid is \"$real_pid\" on host \"$host\""


   set time_now [clock seconds]
   set time_out [expr $time_now + 60]   ;# timeout is 60 seconds

   set have_errors 0
   while {[clock seconds] < $time_out} {
      # get current process list (ps)
      get_ps_info $real_pid $host ps_list


      # copy pid_list from ps_list
      set pscount $ps_list(proc_count)
      set pidl ""
      for {set i 0} { $i < $pscount } {incr i 1} {
         if { $ps_list(pgid,$i) == $real_pid } {
            lappend pidl $ps_list(pid,$i)
         }
      }
      ts_log_finest "Process group has [llength $pidl] processes ($pidl)"

      #
      set state_count 0
      set state_letter ""
      set pginfo ""
      foreach elem $pidl {
         ts_log_finest $ps_list($elem,string)
         append pginfo "$ps_list($elem,string)\n"
         if { $state_count == 0 } {
            set state_letter $ps_list($elem,state)
         }
         incr state_count 1
         if { ( [string compare $state_letter $ps_list($elem,state)] != 0 ) && ($do_error_check == 1 ) } {
            if { [string compare $state_letter "T"] == 0} {
               set have_errors 1
               # we report an error if not all processes have the state "T
            }
         }
      }
      if { $have_errors == 0 } {
         break
      }
   }

   if { $have_errors != 0 } {
      ts_log_severe "not all processes in pgrp has the same state \"$state_letter\""
   }

   return $state_letter
}




#                                                             max. column:     |
#****** sge_procedures/get_job_info() ******
#
#  NAME
#     get_job_info -- get qstat -ext jobinformation
#
#  SYNOPSIS
#     get_job_info { jobid }
#
#  FUNCTION
#     This procedure runs the qstat -ext command and returns the output
#
#  INPUTS
#     jobid - job id (if job id = -1 the complete joblist is returned)
#
#  RESULT
#     "" if job was not found or the call fails
#     output of qstat -ext
#
#  SEE ALSO
#     sge_procedures/get_job_info()
#     sge_procedures/get_standard_job_info()
#     sge_procedures/get_extended_job_info()
#*******************************
proc get_job_info {jobid} {
# return:
# info of qstat -ext for jobid
# nothing if job was not found
# complete joblist if jobid is -1
   get_current_cluster_config_array ts_config

   if {[string compare $ts_config(product_type) "sge"] == 0} {
      ts_log_severe "this call is not accepted for sge system"
      return ""
   }

   set result [start_sge_bin "qstat" "-ext"]
   if {$prg_exit_state != 0} {
      ts_log_severe "qstat -ext failed:\n$result"
      return ""
   }

   # split each line as listelement
   set back ""
   set help [split $result "\n"]
   foreach line $help {
      if {[lindex $line 0] == $jobid} {
         set back $line
         return $back
      }
   }

   if {$jobid == -1 && [llength $help] > 2} {
      set help [lreplace $help 0 1]
      return $help
   }

   return $back
}

#                                                             max. column:     |
#****** sge_procedures/get_standard_job_info() ******
#
#  NAME
#     get_standard_job_info -- get jobinfo with qstat
#
#  SYNOPSIS
#     get_standard_job_info { jobid { add_empty 0} { get_all 0 } }
#
#  FUNCTION
#     This procedure will call the qstat command without arguments.
#
#  INPUTS
#     jobid           - job id
#     { add_empty 0 } - if 1: add lines with does not contain a job id
#                       information (SLAVE jobs)
#     { get_all   0 } - if 1: get every output line (ignore job id)
#
#  RESULT
#     - info of qstat for jobid
#     - nothing if job was not found
#
#     each list element has following sublists:
#     job-ID        (index 0)
#     prior         (index 1)
#     name          (index 2)
#     user          (index 3)
#     state         (index 4)
#     submit/start  (index 5)
#     at            (index 6)
#     queue         (index 7)
#     master        (index 8)
#     ja-task-ID    (index 9)
#
#  EXAMPLE
#     set result [get_standard_job_info 5]
#     if { llength $results > 0 } {
#        puts "user [lindex $result 3] submitted job 5"
#     }
#
#
#  SEE ALSO
#     sge_procedures/get_job_info()
#     sge_procedures/get_standard_job_info()
#     sge_procedures/get_extended_job_info()
#*******************************
proc get_standard_job_info {jobid {add_empty 0} {get_all 0}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   # some tests need this done via catch/exec because there is no additional user
   # who can run this in an open connetion.
   set result [start_sge_bin "qstat" "-u \"*\" -g t"]

   if {$prg_exit_state != 0} {
      ts_log_severe "qstat failed:\n$result"
      return ""
   }


  # split each line as listelement
   set back ""
   set help [split $result "\n"]
   foreach hline $help {
      # ingore empty lines
      set line [string trim $hline]
      if {$line == ""} {
         continue
      }
      if {[lindex $line 0] == $jobid} {
         lappend back $line
         continue
      }
      if {$add_empty != 0} {
         if {[llength $line] == 8} {
            lappend back "-1 $line"
            ts_log_finest "adding empty job lines"
            continue
         }

         if {[llength $line] == 2} {
            lappend back "-1 0 x x x x x $line"
            ts_log_finest "adding empty job lines"
            continue
         }
      }
      if {$get_all != 0} {
         lappend back $line
      }
   }
   return $back
}

#                                                             max. column:     |
#****** sge_procedures/get_extended_job_info() ******
#
#  NAME
#     get_extended_job_info -- get extended job information (qstat ..)
#
#  SYNOPSIS
#     get_extended_job_info { jobid {variable job_info} }
#
#  FUNCTION
#     This procedure is calling the qstat (qstat -ext if sgeee) and returns
#     the output of the qstat in array form.
#
#  INPUTS
#     jobid               - job identifaction number, if "" all jobs are reported
#     {variable job_info} - name of variable array to store the output
#     {do_replace_NA}     - 1 : if not set, don't replace NA settings
#
#  RESULT
#     0, if job was not found
#     1, if job was found
#
#     fills array $variable with info found in qstat output with the following symbolic names:
#     id
#     prior
#     name
#     user
#     state
#     time (submit or starttime) [UNIX-timestamp]
#     queue
#     master
#     jatask
#
#     additional entries in case of SGEEE system:
#     project
#     department
#     deadline [UNIX-timestamp]
#     cpu [s]
#     mem [GBs]
#     io [?]
#     tckts
#     ovrts
#     otckt
#     dtckt
#     ftckt
#     stckt
#     share
#
#  EXAMPLE
#  proc testproc ... {
#     ...
#     if {[get_extended_job_info $job_id] } {
#        if {$job_info(cpu) < 10} {
#           ts_log_severe "online usage probably does not work on $host"
#        }
#     } else {
#        ts_log_severe "get_extended_jobinfo failed for job $job_id on host $host"
#     }
#     ...
#  }
#
#  SEE ALSO
#     sge_procedures/get_job_info()
#     sge_procedures/get_standard_job_info()
#     sge_procedures/get_extended_job_info()
#*******************************
proc get_extended_job_info {jobid {variable job_info} {do_replace_NA 1} {do_group 0}} {
   get_current_cluster_config_array ts_config
   upvar $variable jobinfo

   if {[info exists jobinfo]} {
      unset jobinfo
   }
   set qstat_options "-u '*'"

   set group_options ""
   if {$do_group} {
      set group_options "-g t"
   }

   set myenv(SGE_LONG_QNAMES) 50
   set result [start_sge_bin "qstat" "$qstat_options -ext $group_options" "" "" exit_code 60 "" "bin" output_lines myenv]
   set ext 1

   if {$exit_code == 0} {
      parse_qstat result jobinfo $jobid $ext $do_replace_NA
      if {$jobid != ""} {
         if {![info exists jobinfo(id)] || $jobinfo(id) != $jobid} {
            ts_log_fine "didn't find job $jobid in qstat output"
            return 0
         }
      }
      return 1
   } else {
      ts_log_severe "qstat $all_qstat_options failed:\n$result"
   }

   return 0
}

#****** sge_procedures/get_qstat_j_info() **************************************
#  NAME
#     get_qstat_j_info() -- get qstat -j information
#
#  SYNOPSIS
#     get_qstat_j_info { jobid {variable qstat_j_info} }
#
#  FUNCTION
#     This procedure starts qstat -j for the given job id and returns
#     information in an tcl array.
#
#  INPUTS
#     jobid                   - job id of job
#     {my_variable qstat_j_info} - array to store information
#     {add_switch ""}         - additional switch for qstat -j
#     {host ""}               - host on which to execute qstat -j (default: any host)
#     {user ""}               - user who shall execute qstat -j (default: CHECK_USER)
#
#  RESULT
#     1 on success
#     0 on failure (qstat exit code was not 0)
#
#  SEE ALSO
#     parser/parse_qstat_j()
#*******************************************************************************
proc get_qstat_j_info {jobid {my_variable qstat_j_info} {add_switch ""} {host ""} {user ""}} {
   get_current_cluster_config_array ts_config
   upvar $my_variable jobinfo

   if {[info exists jobinfo]} {
      unset jobinfo
   }

   set result [start_sge_bin "qstat" "$add_switch -j $jobid" $host $user]
   set jobinfo(output) $result
   if {$prg_exit_state == 0} {
      set result "$result\n"
      set my_result ""
      set help [split $result "\n"]
      foreach elem_org $help {
         set elem $elem_org
         # removing message id for localized strings
         if { [string first "\[" $elem ] == 0 } {
            set close_pos [ string first "\]" $elem ]
            incr close_pos 1
            set elem [ string range $elem $close_pos end]
            set elem [ string trim $elem]
            ts_log_finest "removing message id: \"$elem\""
         }
         if { [string first ":" $elem] >= 0 && [string first ":" $elem] < 30 } {
            append my_result "\n$elem"
         } else {
            append my_result ",$elem"
         }
      }
      set my_result "$my_result\n"
      parse_qstat_j my_result jobinfo $jobid
#      set a_names [array names jobinfo]
#      foreach elem $a_names {
#         ts_log_fine "$elem: $jobinfo($elem)"
#      }
      return 1
   }
   ts_log_fine "qstat -j $jobid exit value not 0!\nOutput:\n$result"
   return 0
}

proc get_qstat_j_attribute {name {task 1}} {
   if {[ge_has_feature "resource-maps" 1]} {
      return [format "%-12s %11d" $name $task]
   } else {
      return [format "%s %4d" $name $task]
   }
}

#****** sge_procedures/get_qconf_se_info() *************************************
#  NAME
#     get_qconf_se_info() -- get qconf -se information
#
#  SYNOPSIS
#     get_qconf_se_info { hostname {variable qconf_se_info} }
#
#  FUNCTION
#     This procedure starts qconf -se for the given hostname and returns
#     an tcl array with the output of the command.
#
#  INPUTS
#     hostname                 - execution host name
#     {variable qconf_se_info} - array to store information
#
#
#  SEE ALSO
#      parser/parse_qconf_se()
#*******************************************************************************
proc get_qconf_se_info {hostname {variable qconf_se_info}} {
   global CHECK_USER
   upvar $variable jobinfo

   get_current_cluster_config_array ts_config

   if {[info exists jobinfo]} {
      unset jobinfo
   }

   set arch [resolve_arch $ts_config(master_host)]
   set qconf "$ts_config(product_root)/bin/$arch/qconf"
   set result [start_remote_prog $ts_config(master_host) $CHECK_USER $qconf "-se $hostname"]

   if { $prg_exit_state == 0 } {
      set result "$result\n"
      parse_qconf_se result jobinfo $hostname
      return 1
   } else {
      ts_log_severe "cannot get qconf -se $hostname information"
   }

   return 0
}


#****** sge_procedures/get_qacct_error() ***************************************
#  NAME
#     get_qacct_error() -- error handling for get_qacct
#
#  SYNOPSIS
#     get_qacct_error { result job_id raise_error }
#
#  FUNCTION
#     Does the error handling for get_qacct.
#     Translates possible error messages of qacct -j <job_id>
#
#  INPUTS
#     result      - qacct output
#     job_id      - job_id for which qacct -j has been called
#     raise_error - do ts_log_severe in case of errors
#
#  RESULT
#     Returncode for get_qacct function:
#       -1: if accounting file cannot be found (no job ran since cluster startup)
#       -2: if job id is not found in accounting file
#     -999: other error
#
#  NOTES
#     There are most certainly much more error codes that could be handled.
#*******************************************************************************
global g_get_qacct_error_messages
unset -nocomplain g_get_qacct_error_messages
proc get_qacct_error {result job_id raise_error} {
   get_current_cluster_config_array ts_config
   global g_get_qacct_error_messages
   upvar 0 g_get_qacct_error_messages messages

   # recognize certain error messages and return special return code
   if {![info exists messages(index)]} {
      ts_log_fine "get_qacct_error: translating messages"
      set messages(index) "-1 -2"
      set messages(-1) "*[translate_macro MSG_HISTORY_NOJOBSRUNNINGSINCESTARTUP]"
      if {[is_version_in_range "9.1.0"]} {
         set messages(-2) "*[translate_macro MSG_HISTORY_JOBIDXNOTFOUND_U $job_id]"
      } else {
         set messages(-2) "*[translate_macro MSG_HISTORY_JOBIDXNOTFOUND_D $job_id]"
      }
   }

   # should we have version dependent error messages, create following
   # procedure in sge_procedures.<version>.tcl
   # get_qacct_error_vdep messages

   # now evaluate return code and raise errors
   set ret [handle_sge_errors "get_qacct" "qacct -j $job_id" $result messages $raise_error]

   return $ret
}

#                                                             max. column:     |
#****** sge_procedures/get_qacct() ******
#
#  NAME
#     get_qacct -- get job or task accounting information
#
#  SYNOPSIS
#     get_qacct {job_id {variable qacct_info} {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     This procedure will parse the qacct output for the given job id and fill
#     up the given variable name with information.
#
#  INPUTS
#     job_task_spec           - job identification number, if format is job.task only the
#                               record(s) for the selected task is/are returned
#                               a pe task id can be appended separated by a space, e.g.
#                               "123.1 1.rocky-8-amd64-1" to get a specific pe task of a parallel job, or
#                               "123.1 NONE" to get only the master task of a parallel job
#     {variable qacct_info}   - name of variable to save the results
#     {on_host ""}            - execute qacct on this host
#     {as_user ""}            - execute qacct as this user
#     {raise_error 1}         - do add_proc error, or only output error messages
#     {expected_amount -1}    - expected amount of records (tasks)
#     {atimeout_value 0}      - timeout waiting for accounting info
#     {sum_up_tasks 1}        - generate the sum of all task related accounting values
#
#  RESULT
#     0, if job was found
#     < 0, on error - see get_qacct_error for a description of possible error codes
#
#  EXAMPLE
#
#     if { [get_qacct $job_id] == 0 } {
#        set cpu [expr $qacct_info(ru_utime) + $qacct_info(ru_stime)]
#        if { $cpu < 30 } {
#           ts_log_severe "cpu entry in accounting ($qacct_info(cpu)) seems
#                                     to be wrong for job $job_id on host $host"
#        }
#     }
#
#  NOTES
#     look at parser/parse_qacct() for more information
#
#  SEE ALSO
#     parser/parse_qacct()
#     sge_procedures/get_qacct_error()
#*******************************
proc get_qacct {job_task_spec {my_variable "qacct_info"} {on_host ""} {as_user ""} {raise_error 1} {expected_amount -1} {atimeout_value 0} {sum_up_tasks 1} {qacct_output_var qacct_output}} {
   get_current_cluster_config_array ts_config

   upvar $my_variable qacctinfo
   upvar $qacct_output_var qacct_output
   set timeout_value $atimeout_value

   if {[info exists qacctinfo]} {
      unset qacctinfo
   }

   # beginning with SGE 6.0, writing the accounting file may be buffered
   # accept getting errors for some seconds
   if {$atimeout_value == 0} {
      set timeout_value 30
      ts_log_finer "get_qacct(): will repeat getting accounting info up to 30 seconds for GE versions >= 60!"
   }

   # if qacct host is not master host we have also to add some NFS timeout
   if {$on_host == ""} {
      set on_host $ts_config(master_host)
   }
   if {$on_host != $ts_config(master_host)} {
      incr timeout_value 60
      ts_log_finer "get_qacct(): increasing timeout to $timeout_value because qacct host might not be master host \"$ts_config(master_host)\"!"
   }

   # we might have a job specification with a pe task id
   if {[string first " " $job_task_spec] >= 0} {
      set split_spec [split $job_task_spec " "]
      set job_id [lindex $split_spec 0]
      set pe_task_id [lindex $split_spec 1]
   } else {
      set job_id $job_task_spec
      set pe_task_id ""
   }

   if {[string first "." $job_id] >= 0} {
      set job_array [split $job_id "."]
      set job_id [lindex $job_array 0]
      set task_id [lindex $job_array 1]
      if {$task_id == "undefined"} {
         set task_id 0
      }
      set qacct_args "-j $job_id -t $task_id"
   } else {
      set qacct_args "-j $job_id"
   }

   set ret 0
   set my_timeout [clock seconds]
   incr my_timeout $timeout_value
   while {1} {
      # clear output variable
      if {[info exists qacctinfo]} {
         unset qacctinfo
      }
      set qacct_output [start_sge_bin "qacct" "$qacct_args" $on_host $as_user]
      if {$prg_exit_state == 0} {
         if {$expected_amount == -1} {
            # we have the qacct info without errors
            parse_qacct qacct_output qacctinfo $job_id $sum_up_tasks $pe_task_id
            break
         } else {
            # we want to have $expected_amount accounting data sets
            parse_qacct qacct_output qacctinfo $job_id $sum_up_tasks $pe_task_id
            set num_acct [llength $qacctinfo(exit_status)]
            if {$num_acct == $expected_amount} {
               ts_log_fine "found all $num_acct expected accounting records!"
               return 0
            } else {
               ts_log_finer "found $num_acct of $expected_amount expected accounting records"
            }
            after 1000
         }
      }
      # check timeout
      if {[clock seconds] > $my_timeout} {
         if {$expected_amount == -1} {
            ts_log_severe "timeout while waiting for qacct info for job $job_id! Timeout was $timeout_value" $raise_error
         } else {
            ts_log_severe "timeout while waiting for $expected_amount accounting records for job $job_id! Timeout was $timeout_value" $raise_error
         }
         break
      }
      ts_log_finer "timeout in [expr $my_timeout - [clock seconds]] seconds!"
      after 1000
   }

   # parse output or raise error
   if {$prg_exit_state != 0} {
      set ret [get_qacct_error $qacct_output $job_id $raise_error]
   }

   return $ret
}

###
# @brief get multiple accounting records with qacct -j *
#
# This function calls qacct -j * and processes the output from the qacct output stream.
# Accounting records are filtered by job id range (first_job_id to last_job_id).
# The function returns the accounting information in an array variable with the following structure:
# qacct_info(index) = list of job_id,task_id pairs
# qacct_info(job_id,task_id,attribute) = value for all attributes of the accounting record
#
# @param first_job_id    - first job id to get accounting information for
# @param last_job_id     - last job id to get accounting information for
# @param qacct_info_var  - variable name to store the accounting information, default: qacct_info
# @param on_host         - host to run qacct on, default: "" = file server or master host
# @param as_user         - user to run qacct as, default: "" = CHECK_USER
# @param raise_error     - do ts_log_severe in case of errors, default: 1
# @param attrib_list     - optionally list of attributes to store in the accounting information, default: "" = all attributes
# @return 0 on success, -1 on error
##
proc get_qacct_multi {first_job_id last_job_id {qacct_info_var "qacct_info"} {on_host ""} {as_user ""} {raise_error 1} {attrib_list ""}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   upvar $qacct_info_var qacct_info
   unset -nocomplain qacct_info
   set qacct_info(index) {}

   # if no host is given run qacct on the file server if possible, else on the master host
   if {$on_host == ""} {
      set on_host [fs_config_get_server_for_path $ts_config(product_root) 0]
      if {$on_host == ""} {
         set on_host $ts_config(master_host)
      }
   }
   if {$as_user == ""} {
      set as_user $CHECK_USER
   }
   ts_log_fine "calling qacct -j * on host $on_host as user $as_user"

   # call qacct -j "*" and process the records as they come in
   set id [open_remote_spawn_process $on_host $as_user "qacct" "-j '*'"]
   if {$id == ""} {
      ts_log_severe "could not start qacct -j * on $on_host as user $as_user"
      return -1
   }

   set sp_id [lindex $id 1]
   set record_buffer ""
   set job_id 0
   set task_id 0
   log_user 0
   set done 0
   set timeout 60
   expect_user {
      -i $sp_id timeout {
         ts_log_severe "timeout while processing qacct data" $raise_error
      }
      -i $sp_id eof {
         ts_log_severe "eof while processing qacct data" $raise_error
      }
      -i $sp_id full_buffer {
         ts_log_severe "full_buffer while processing qacct data" $raise_error
      }
      -i $sp_id  "?*\n" {
         foreach line [split $expect_out(buffer) "\n"] {
            set line [string trim $line]
            if {[string length $line] > 0} {
               switch -glob $line {
                  "=================*" {
                     # a new record starts here, parse the last one (unless it is the first one)
                     if {[string length $record_buffer] > 80 &&
                         $job_id >= $first_job_id && $job_id <= $last_job_id} {
                        get_qacct_multi_append_record $job_id $task_id record_buffer qacct_info $attrib_list
                     }
                     set record_buffer "$line\n"
                  }
                  "jobnumber*" {
                     set job_id [string trim [lindex $line 1]]
                     append record_buffer "$line\n"
                  }
                  "taskid*" {
                     set task_id [string trim [lindex $line 1]]
                     append record_buffer "$line\n"
                  }
                  "_start_mark_:*" {
                     # ignore
                  }
                  "_exit_status_:(*)*" {
                     set done 1
                  }
                  "script done. (_END_OF_FILE_)" {
                     set done 1
                  }
                  default {
                     append record_buffer "$line\n"
                  }
               }
            }
         }
         if {!$done} {
            exp_continue
         }
      }
   }

   close_spawn_process $id

   # there might be a final record in the buffer, parse it
   if {[string length $record_buffer] > 80 &&
       $job_id >= $first_job_id && $job_id <= $last_job_id} {
      get_qacct_multi_append_record $job_id $task_id record_buffer qacct_info $attrib_list
   }

   return 0
}

###
# @brief append one accounting record to a get_qacct_multi result
#
# (internal function, called only from get_qacct_multi)
#
# @param job_id         - job id
# @param task_id        - task id
# @param input_var      - qacct -j * output for one accounting record
# @param qacct_info_var - variable name to store the accounting information, default: qacct_info
# @param attrib_list    - optionally list of attributes to store in the accounting information, default: "" = all attributes
##
proc get_qacct_multi_append_record {job_id task_id input_var {qacct_info_var "qacct_info"} {attrib_list ""}} {
   upvar $input_var input
   upvar $qacct_info_var qacct_info

   set data [string trim $input]
   parse_qacct data one_record $job_id 0
   if {$attrib_list == ""} {
      foreach attrib [array names one_record] {
         if {$attrib == "index"} {
            continue
         }
         set qacct_info($job_id,$task_id,$attrib) $one_record($attrib)
      }
   } else {
      foreach attrib $attrib_list {
         if {$attrib == "index"} {
            continue
         }
         if {[info exists one_record($attrib)]} {
            set qacct_info($job_id,$task_id,$attrib) $one_record($attrib)
         }
      }
   }
   lappend qacct_info(index) "$job_id,$task_id"
}

#                                                             max. column:     |
#****** sge_procedures/is_job_running() ******
#
#  NAME
#     is_job_running -- get run information of job
#
#  SYNOPSIS
#     is_job_running { jobid jobname }
#
#  FUNCTION
#     This procedure will call qstat -f for job information
#
#  INPUTS
#     jobid   - job identifaction number
#     jobname - name of the job (string)
#
#  RESULT
#      0 - job is not running (but pending)
#      1 - job is running
#     -1 - not in stat list
#
#  NOTES
#     This procedure returns 1 (job is running) when the job
#     is spooled to a queue. This doesn not automatically mean
#     that the job is "real running".
#
#  SEE ALSO
#     sge_procedures/is_job_running()
#     sge_procedures/is_pid_with_name_existing()
#*******************************
proc is_job_running {jobid jobname} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   if {$jobname == ""} {
      set check_job_name 0
   } else {
      set check_job_name 1
   }

   set result [start_sge_bin "qstat" "-u '*' -f" "" "" catch_state]

   if {$catch_state != 0} {
      ts_log_severe "qstat returned error:\n$result"
      return -1
   }

   # split each line as listelement
   set help [split $result "\n"]
   set running_flag 1

   set found 0
   foreach line $help {
     if {[lsearch $line "####*"] >= 0} {
       set running_flag 0
     }

     if {$check_job_name != 0} {
        if {[string first $jobname $line] >= 0 && [lindex $line 0] == $jobid} {
          set found 1
          break
        }
     } else {
        if {[lindex $line 0] == $jobid} {
          set found 1
          break
        }
     }
   }

   if {$found == 1} {
      return $running_flag
   }

   return -1
}



#****** sge_procedures/get_job_state() *****************************************
#  NAME
#     get_job_state() -- get job state information
#
#  SYNOPSIS
#     get_job_state { jobid { not_all_equal 0 } { taskid task_id } }
#
#  FUNCTION
#     This procedure parses the output of the qstat -f command and returns
#     the job state or an tcl array with detailed information
#
#  INPUTS
#     jobid               - Job id of job to get information for
#     { not_all_equal 0 } - if 0 (default): The procedure will wait until
#                           all tasks of a job array have the same state
#                           if 1: The procedure will return an tcl list
#                           with the job states and fill the array (given
#                           optional in parameter 3) "task_id" with information.
#     { taskid task_id }  - tcl array name to fill information if not_all_equal
#                           is set to 1
#
#  RESULT
#     tcl array:
#          task_id($lfnr,state)     -> task state
#          task_id($lfnr,task)      -> task no
#
#          lfnr is a number between 0 and the length of the returned tcl list
#
#
#*******************************************************************************
proc get_job_state {jobid {not_all_equal 0} {taskid task_id}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   upvar $taskid r_task_id

   if {[info exists r_task_id]} {
      unset r_task_id
   }

   set my_timeout [expr [clock seconds] + 100]
   set states_all_equal 0
   while {$my_timeout > [clock seconds] && $states_all_equal == 0} {
      set states_all_equal 1

      set result [start_sge_bin "qstat" "-f -g t -u '*'" "" $CHECK_USER]
      if {$prg_exit_state != 0} {
         return -1
      }

      # split each line as listelement
      set help [split $result "\n"]
      set running_flag 1

      set states ""
      set lfnr 0
      foreach line $help {
        if {[lindex $line 0] == $jobid} {
           lappend states [lindex $line 4]
           ts_log_finest "debug: $line"
           if {[lindex $line 7] == "MASTER"} {
              set r_task_id($lfnr,task)  [lindex $line 8]
           } else {
              set r_task_id($lfnr,task)  [lindex $line 7]
           }
           set r_task_id($lfnr,state) [lindex $line 4]
           incr lfnr 1
        }
      }
      if {$states == ""} {
         set states -1
      }

      set main_state [lindex $states 0]
      if {$not_all_equal == 0} {
         for {set elem 0} {$elem < [llength $states]} {incr elem 1} {
            if {[string compare [lindex $states $elem] $main_state] != 0} {
               ts_log_finest "jobstate of task $elem is: [lindex $states $elem], waiting ..."
               set states_all_equal 0
            }
         }
         after 1000
      }
   }
   if {$not_all_equal != 0} {
      return $states
   }

   if {$states_all_equal == 1} {
      return $main_state
   }

   ts_log_severe "more than one job id found with different states"
   return -1
}

# wait for start of job ($jobid,$jobname) ; timeout after $seconds
# results : -1 on timeout ; 0 on jobstart
#                                                             max. column:     |
#****** sge_procedures/wait_for_jobstart() ******
#
#  NAME
#     wait_for_jobstart -- wait for job to get out of pending list
#
#  SYNOPSIS
#     wait_for_jobstart { jobid jobname seconds {do_errorcheck 1} {do_tsm 0} }
#
#  FUNCTION
#     This procedure will call the is_job_running procedure in a while
#     loop. When the job is scheduled to a queue the job is "running"
#     and the procedure returns.
#
#  INPUTS
#     jobid             - job identification number
#     jobname           - name of the job
#     seconds           - timeout in seconds
#     {do_errorcheck 1} - enable error check (default)
#                         if 0: do not report errors
#     {do_tsm 0}        - do qconf -tsm before waiting
#                         if 1: do qconf -tsm (trigger scheduler)
#
#  RESULT
#     -1 - job is not running (timeout error)
#      0 - job is running (not in pending state)
#
#  EXAMPLE
#     foreach elem $jobs {
#        wait_for_jobstart $elem "Sleeper" 300
#        wait_for_end_of_transfer $elem 300
#        append jobs_string "$elem "
#     }
#
#  SEE ALSO
#     sge_procedures/wait_for_load_from_all_queues()
#     file_procedures/wait_for_file()
#     sge_procedures/wait_for_jobstart()
#     sge_procedures/wait_for_end_of_transfer()
#     sge_procedures/wait_for_jobpending()
#     sge_procedures/wait_for_jobend()
#  NOTES
#     TODO: add an option to wait for all array tasks of a job
#           to be running
#*******************************
proc wait_for_jobstart {jobid jobname seconds {do_errorcheck 1} {do_tsm 0}} {
   get_current_cluster_config_array ts_config

   if {[is_job_id $jobid] != 1} {
      if {$do_errorcheck == 1} {
         ts_log_severe "got unexpected job id: $jobid"
      }
      return -1
   }

   if {$do_tsm == 1} {
      trigger_scheduling
   }

   if {$do_errorcheck != 1} {
      ts_log_finest "error check is switched off"
   }

   ts_log_fine "Waiting for start of job $jobid ($jobname)"
   set time [clock seconds]
   while {1} {
      set is_job_running_result [is_job_running $jobid $jobname]
      if {$is_job_running_result == 1} {
         break
      }
      set runtime [expr [clock seconds] - $time]
      if {$runtime >= $seconds} {
         if {$do_errorcheck == 1} {
            set qstat_output [start_sge_bin "qstat" "-f -g t -u '*'"]
            set qstat_wp_output [start_sge_bin "qalter" "-w p $jobid"]
            ts_log_severe "timeout waiting for job $jobid \"$jobname\"\n$qstat_output\n$qstat_wp_output"
         }
         return -1
      }
      # check if job was already running (only if job is not in qstat output)
      if {$is_job_running_result == -1} {
         set result [was_job_running $jobid 0]
         if {$result != -1} {
            ts_log_fine "job $jobid was already running, checking accounting ..."
            get_qacct $jobid
            if {[info exists qacct_info(exit_status)]} {
               if {$qacct_info(exit_status) == 0} {
                  ts_log_fine "job \"$jobid\" already executed with exit status \"$qacct_info(exit_status)\""
                  break
               }
               if {$do_errorcheck == 1} {
                  ts_log_severe "job \"$jobid\" already finished with exit status \"$qacct_info(exit_status)\" and is not shown by qstat command!"
               }
               return -1
            }
         }
      }
      ts_log_progress
      after 1000
   }
   return 0
}

#                                                             max. column:     |
#****** sge_procedures/wait_for_end_of_transfer() ******
#
#  NAME
#     wait_for_end_of_transfer -- wait transfer end of job
#
#  SYNOPSIS
#     wait_for_end_of_transfer { jobid seconds }
#
#  FUNCTION
#     This procedure will parse the qstat output of the job for the t state. If
#     no t state is found for the given job id, the procedure will return.
#
#  INPUTS
#     jobid   - job identification number
#     seconds - timeout in seconds
#
#  RESULT
#      0 - job left transfer state, i.e. it is running or beyond
#     -1 - timeout
#      1 - jobid not found in qstat output, probably it finished already?
#
#  EXAMPLE
#     see "sge_procedures/wait_for_jobstart"
#
#  SEE ALSO
#     sge_procedures/wait_for_load_from_all_queues()
#     file_procedures/wait_for_file()
#     sge_procedures/wait_for_jobstart()
#     sge_procedures/wait_for_end_of_transfer()
#     sge_procedures/wait_for_jobpending()
#     sge_procedures/wait_for_jobend()
#*******************************
proc wait_for_end_of_transfer { jobid seconds } {
   ts_log_fine "Waiting for job $jobid to finish transfer state"

   set result 0
   set time [clock seconds]
   while {$result == 0} {
      set qstat_result [get_standard_job_info $jobid ]

      # qstat_result contains the output of "qstat" without options.
      # search the line of the job we are looking for in this list.
      set tmp_jobid 0
      set job_state ""
      foreach line $qstat_result {
         set tmp_jobid [lindex $line 0]
         if {$tmp_jobid == $jobid} {
            # we found the right line
            set job_state [lindex $line 4]
            # break out of foreach loop
            break
         }
      }

      if {$job_state == ""} {
         # the job is not in the list
         ts_log_fine "Didn't find job $jobid in qstat output!"
         set result 1
         # break out of while loop
         break
      } else {
         # analyze job state
         if {[string first "qw" $job_state] >= 0} {
            ts_log_fine "job $jobid is still queued ($job_state), checking again..."
         } elseif {[string first "t" $job_state] >= 0} {
            ts_log_fine "job $jobid is still being transferred ($job_state), checking again..."
         } elseif {[string first "r" $job_state] >= 0} {
            ts_log_fine "job $jobid is running ($job_state), fine!"
            # break out of while loop
            break
         } else {
            ts_log_fine "job $jobid is in an unhandled state ($job_state) which \
                         is not the transfer state, so this function returns now."
            # break out of while loop
            break
         }
      }

      set runtime [expr [clock seconds] - $time]
      if { $runtime >= $seconds } {
         ts_log_severe "timeout waiting for job \"$jobid\""
         set result -1
         # break out of while loop
         break
      }
      after 1000
   }
   return $result
}

# wait for job to be in pending state ($jobid,$jobname) ; timeout after $seconds
# results : -1 on timeout ; 0 on pending
#                                                             max. column:     |
#****** sge_procedures/wait_for_jobpending() ******
#
#  NAME
#     wait_for_jobpending -- wait for job to get into pending state
#
#  SYNOPSIS
#     wait_for_jobpending { jobid jobname seconds { or_running 0 } }
#
#  FUNCTION
#     This procedure will return when the job is in pending state.
#
#  INPUTS
#     jobid   - job identification number
#     jobname - name of the job
#     seconds - timeout value in seconds
#     { or_running 0 } - if job is already running, report no error
#
#  RESULT
#     -1  on timeout
#     0   when job is in pending state
#
#  EXAMPLE
#     foreach elem $sched_jobs {
#         wait_for_jobpending $elem "Sleeper" 300
#     }
#
#  SEE ALSO
#     sge_procedures/wait_for_load_from_all_queues()
#     file_procedures/wait_for_file()
#     sge_procedures/wait_for_jobstart()
#     sge_procedures/wait_for_end_of_transfer()
#     sge_procedures/wait_for_jobpending()
#     sge_procedures/wait_for_jobend()
#*******************************
proc wait_for_jobpending {jobid jobname seconds {or_running 0}} {
  get_current_cluster_config_array ts_config

  ts_log_fine "Waiting for job $jobid ($jobname) to get in pending state"

  if {[is_job_id $jobid] != 1} {
     ts_log_severe "unexpected job id: $jobid"
     return -1
  }
  after 500
  set time [clock seconds]
  while {1} {
    set run_result [is_job_running $jobid $jobname]
    if {$run_result == 0} {
       break
    }
    if {$run_result == 1 && $or_running == 1} {
       break
    }
    set runtime [expr [clock seconds] - $time]
    if { $runtime >= $seconds } {
       ts_log_severe "timeout waiting for job \"$jobid\" \"$jobname\" (timeout was $seconds sec)"
       return -1
    }
    after 500
  }
  return 0
}


# set job in hold state
# results: -1 on timeout, 0 ok
#                                                             max. column:     |
#****** sge_procedures/hold_job() ******
#
#  NAME
#     hold_job -- set job in hold state
#
#  SYNOPSIS
#     hold_job { jobid }
#
#  FUNCTION
#     This procedure will use the qhold binary to set a job into hold state.
#
#  INPUTS
#     jobid - job identification number
#
#  RESULT
#        0 - ok
#       -1 - timeout error
#
#  SEE ALSO
#     sge_procedures/release_job()
#     sge_procedures/hold_job()
#*******************************
proc hold_job { jobid } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set MODIFIED_HOLD [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_MOD_JOBS_SU] "*" "*"]

   # spawn process
   log_user 0
   set master_arch [resolve_arch $ts_config(master_host)]
   set program "$ts_config(product_root)/bin/$master_arch/qhold"
   set id [open_remote_spawn_process $ts_config(master_host) $CHECK_USER $program "$jobid"]

   set sp_id [ lindex $id 1 ]
   set timeout 30
   set result -1

   log_user 0

   expect {
       -i $sp_id full_buffer {
          set result -1
          ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
       }
       -i $sp_id "modified hold of job" {
          set result 0
       }
       -i $sp_id $MODIFIED_HOLD {
          set result 0
       }
       -i $sp_id default {
          set result -1
       }

   }
   # close spawned process
   close_spawn_process $id
   if { $result != 0 } {
      ts_log_severe "could not hold job $jobid"
   }
   return $result

}


#                                                             max. column:     |
#****** sge_procedures/release_job() ******
#
#  NAME
#     release_job -- release job from hold state
#
#  SYNOPSIS
#     release_job { jobid }
#
#  FUNCTION
#     This procedure will release the job from hold.
#
#  INPUTS
#     jobid - job identification number
#
#  RESULT
#      0   - ok
#     -1   - timeout error
#
#  SEE ALSO
#     sge_procedures/release_job()
#     sge_procedures/hold_job()
#*******************************
proc release_job { jobid } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   # spawn process
   log_user 0

   set MODIFIED_HOLD [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_MOD_JOBS_SU] "*" "*"]
   set MODIFIED_HOLD_ARRAY [ translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_MOD_JATASK_SUU] "*" "*" "*"]

   set master_arch [resolve_arch $ts_config(master_host)]
   set program "$ts_config(product_root)/bin/$master_arch/qrls"
   set id [open_remote_spawn_process $ts_config(master_host) $CHECK_USER $program "$jobid"]

   set sp_id [ lindex $id 1 ]
   set timeout 30
   set result -1
   log_user 0

   expect {
       -i $sp_id full_buffer {
          set result -1
          ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
       }
       -i $sp_id $MODIFIED_HOLD {
          set result 0
       }
       -i $sp_id $MODIFIED_HOLD_ARRAY {
          set result 0
       }

       -i $sp_id "modified hold of job" {
          set result 0
       }
       -i $sp_id default {
          set result -1
       }
   }

   # close spawned process
   close_spawn_process $id
   if { $result != 0 } {
      ts_log_severe "could not release job $jobid"
   }
   return $result

}


#                                                             max. column:     |
#****** sge_procedures/wait_for_jobend() ******
#
#  NAME
#     wait_for_jobend -- wait for end of job
#
#  SYNOPSIS
#     wait_for_jobend { jobid jobname seconds
#                       { runcheck 1}
#                       { wait_for_end 0 } }
#
#  FUNCTION
#     This procedure is testing first if the given job is really running. After
#     that it waits for the job to disappear in the qstat output.
#
#  INPUTS
#     jobid   - job identification number
#     jobname - name of job
#     seconds - timeout in seconds
#
#     optional parameters:
#     { runcheck }     - if 1 (default): check if job is running
#     { wait_for_end } - if 0 (default): no for real job end waiting (job
#                                        removed from qmaster internal list)
#                        if NOT 0:       wait for qmaster to remove job from
#                                        internal list
#     {raise_error 1}  - shall an error condition be raised, in case it is a
#                        SEVERE, WARNING, or CONFIG message
#     {trigger_scheduler 0} - trigger schedling runs while waiting for the job to end
#
#  RESULT
#      0 - job stops running
#     -1 - timeout error
#     -2 - job is not running
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
#     sge_procedures/wait_for_end_of_all_jobs()
#     sge_procedures/wait_for_load_from_all_queues()
#     file_procedures/wait_for_file()
#     sge_procedures/wait_for_jobstart()
#     sge_procedures/wait_for_end_of_transfer()
#     sge_procedures/wait_for_jobpending()
#     sge_procedures/wait_for_jobend()
#*******************************
proc wait_for_jobend {jobid jobname seconds {runcheck 1} {wait_for_end 0} {raise_err 1}} {
   get_current_cluster_config_array ts_config

   if {$runcheck == 1} {
      if {[is_job_running $jobid $jobname] != 1} {
         ts_log_severe "job \"$jobid\" \"$jobname\" is not running" $raise_err
         return -2
      }
   }

   ts_log_fine "Waiting for end of job $jobid ($jobname)"
   after 500
   set time [clock seconds]
   while {1} {
     set run_result [is_job_running $jobid $jobname]
     if {$run_result == -1} {
        break
     }
     set runtime [expr [clock seconds] - $time]
     if { $runtime >= $seconds } {
        ts_log_severe "timeout waiting for job \"$jobid\" \"$jobname\":\nis_job_running returned $run_result" $raise_err
        return -1
     }
     ts_log_progress
     after 500
   }

   if {$wait_for_end != 0} {
       set my_timeout [clock seconds]
       incr my_timeout 90
       ts_log_fine "waiting for jobend (2) (qstat -j $jobid)"
       while { [get_qstat_j_info $jobid ] != 0 } {
           if {[clock seconds] > $my_timeout} {
              ts_log_severe "timeout while waiting for jobend" $raise_err
              return -1
           }
           after 1000
           ts_log_progress
       }
   }
   return 0
}


#****** sge_procedures/startup_qmaster() ***************************************
#  NAME
#     startup_qmaster() -- startup qmaster (and scheduler) daemon
#
#  SYNOPSIS
#     startup_qmaster { {and_scheduler 1}  {env_list ""}  }
#
#  FUNCTION
#     Startup the qmaster daemon on the configured testsuite host. An environ
#     ment can be set which is used as parameter for the start_remote_prog()
#     call.
#
#  INPUTS
#     {and_scheduler 1} - optional: also start the schedd daemon
#     env_list          - optional: use given environment
#
#  SEE ALSO
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#*******************************************************************************
proc startup_qmaster {{and_scheduler 1} {env_list ""} {on_host ""}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   global CHECK_ADMIN_USER_SYSTEM
   global CHECK_DEBUG_LEVEL
   global schedd_debug master_debug CHECK_DISPLAY_OUTPUT CHECK_SGE_DEBUG_LEVEL
   global CHECK_INSTALL_RC

   if {$env_list != ""} {
      upvar $env_list envlist
   }

   set start_host $ts_config(master_host)

   if {$on_host != ""} {
      set start_host $on_host
   }

   if {$CHECK_ADMIN_USER_SYSTEM == 0} {
      if {[have_root_passwd] != 0} {
         ts_log_warning "no root password set or ssh not available"
         return -1
      }
      set startup_user "root"
   } else {
      set startup_user $CHECK_USER
   }

   set schedd_message ""

   ts_log_fine "starting up qmaster $schedd_message on host \"$start_host\" as user \"$startup_user\""
   set arch [resolve_arch $start_host]

   set output ""
   if {$master_debug != 0} {
      set xterm_path [get_binary_path $start_host "xterm"]
      ts_log_finest "using DISPLAY=${CHECK_DISPLAY_OUTPUT}"
      set output [start_remote_prog $start_host $startup_user $xterm_path "-bg darkolivegreen -fg navajowhite -sl 5000 -sb -j -display $CHECK_DISPLAY_OUTPUT -e $ts_config(testsuite_root_dir)/scripts/debug_starter.sh /tmp/out.$CHECK_USER.qmaster.$start_host \"$CHECK_SGE_DEBUG_LEVEL\" $ts_config(product_root)/bin/${arch}/sge_qmaster &" prg_exit_state 60 2 "" envlist]
   } else {
      # if we have an env list, cannot use systemd to startup qmaster
      if {$env_list == "" && $CHECK_INSTALL_RC && [ge_has_feature "systemd"] && [host_has_systemd $ts_config(master_host)]} {
         set service_name [systemd_get_service_name "qmaster"]
         set output [start_remote_prog $start_host $startup_user "systemctl" "start $service_name"]
      } else {
         set output [start_remote_prog $start_host $startup_user "$ts_config(product_root)/bin/${arch}/sge_qmaster" ";sleep 2" prg_exit_state 60 0 "" envlist]
      }
   }

   if {$prg_exit_state != 0} {
      ts_log_severe "Qmaster did not start exit_code=$prg_exit_state output=$output"
      return
   } else {
      ts_log_fine $output
   }

   # now wait until qmaster is availabe
   set my_timeout [clock seconds]
   incr my_timeout 60
   set is_reachable 0
   while {[clock seconds] < $my_timeout} {
      start_sge_bin qstat "" $ts_config(master_host)
      if {$prg_exit_state == 0} {
         set is_reachable 1
         ts_log_fine "qmaster is reachable!"
         break
      } else {
         ts_log_fine "waiting for qmaster startup ..."
      }
      after 1000
   }
   if {$is_reachable == 0} {
      ts_log_severe "qmaster is not reachable timeout!"
      return -1
   }

   global CHECK_VALGRIND CHECK_VALGRIND_LAST_DAEMON_RESTART
   if {$CHECK_VALGRIND == "master"} {
      set CHECK_VALGRIND_LAST_DAEMON_RESTART [clock seconds]
      # wait a little bit for qmaster to be really up and mirror threads having been initialized
      after 5000
   }

   return 0
}

#****** sge_procedures/startup_scheduler() *************************************
#  NAME
#     startup_scheduler() -- ???
#
#  SYNOPSIS
#     startup_scheduler { }
#
#  FUNCTION
#     ???
#
#  INPUTS
#
#  RESULT
#     ???
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
#*******************************************************************************
proc startup_scheduler {} {
   global CHECK_USER
   global CHECK_ADMIN_USER_SYSTEM
   global CHECK_DEBUG_LEVEL
   global schedd_debug CHECK_DISPLAY_OUTPUT CHECK_SGE_DEBUG_LEVEL
   get_current_cluster_config_array ts_config

   if { $CHECK_ADMIN_USER_SYSTEM == 0 } {
      if { [have_root_passwd] != 0  } {
         ts_log_warning "no root password set or ssh not available"
         return -1
      }
      set startup_user "root"
   } else {
      set startup_user $CHECK_USER
   }

   ts_log_fine "starting up scheduler on host \"$ts_config(master_host)\" as user \"$startup_user\""
   set arch [resolve_arch $ts_config(master_host)]
   if { $schedd_debug != 0 } {
      set xterm_path [get_binary_path $ts_config(master_host) "xterm"]
      ts_log_finest "using DISPLAY=${CHECK_DISPLAY_OUTPUT}"
      start_remote_prog "$ts_config(master_host)" "$startup_user" $xterm_path "-bg darkolivegreen -fg navajowhite -sl 5000 -sb -j -display $CHECK_DISPLAY_OUTPUT -e $ts_config(testsuite_root_dir)/scripts/debug_starter.sh /tmp/out.$CHECK_USER.schedd.$ts_config(master_host) \"$CHECK_SGE_DEBUG_LEVEL\" $ts_config(product_root)/bin/${arch}/sge_schedd &" prg_exit_state 60 2
   } else {
      start_remote_prog "$ts_config(master_host)" "$startup_user" "$ts_config(product_root)/bin/${arch}/sge_schedd" ""
   }

   return 0
}

#********* sge_procedures/startup_daemon() *************************************
#  NAME
#     startup_daemon() -- startup SGE daemon
#
#  SYNOPSIS
#     startup_daemon { hostname service }
#
#  FUNCTION
#     Startup daemon on remote host
#
#  INPUTS
#     host - host to start up execd
#     service - daemon/service to start
#
#  RESULT
#     0 -> ok   -1 -> error
#
#  SEE ALSO
#     smf_procedures/startup_smf_service()
#*******************************************************************************
proc startup_daemon { host service } {
   global ts_config arco_config

   switch -exact $service {
      "master" -
      "qmaster" {
         if {[string compare $host $ts_config(master_host)] != 0} {
            ts_log_severe "Can't startup $service on host $host. Qmaster host is only $ts_config(master_host)"
            return -1
         }
         startup_qmaster
      }
      "shadow" -
      "shadowd" {
         if {[lsearch -exact $ts_config(shadowd_hosts) $host] == -1} {
            ts_log_severe "Can't start $service. Host $host is not a $service host"
            return -1
         }
         startup_shadowd $host
      }
      "execd" {
         if {[lsearch -exact $ts_config(execd_nodes) $host] == -1} {
            ts_log_severe "Can't start $service. Host $host is not a $service host"
            return -1
         }
         startup_execd $host
      }
      "dbwriter" {
         if {[string compare $host $arco_config(dbwriter_host)] != 0} {
            ts_log_severe "Can't start $service. Host $host is not a $service host"
            return -1
         }
         startup_dbwriter $host
      }
      default {
         ts_log_severe "Invalid argument $service passed to shutdown_daemon{}"
         return -1
      }
   }
}



#****** sge_procedures/are_master_and_scheduler_running() ******
#
#  NAME
#     are_master_and_scheduler_running -- test if qmaster is running
#
#  SYNOPSIS
#     are_master_and_scheduler_running { hostname qmaster_spool_dir }
#
#  FUNCTION
#     Check whether qmaster and/or scheduler processes are shown in
#     ps output.
#
#  INPUTS
#     hostname          - qmaster host
#     qmaster_spool_dir - spool dir of qmaster
#
#  RESULT
#     for GE < 62 or AR branch:
#        3 - master and scheduler running
#        2 - master running
#        1 - scheduler running
#        0 - neither master or scheduler running
#
#     for GE >= 62 (scheduler is now thread in qmaster)
#        2 - master running
#        0 - neither master or scheduler running
#*******************************
proc are_master_and_scheduler_running { hostname qmaster_spool_dir } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set qmaster_pid -1
   set scheduler_pid -1

   set running 0


   set qmaster_pid [start_remote_prog "$hostname" "$CHECK_USER" "cat" "$qmaster_spool_dir/qmaster.pid"]
   set qmaster_pid [ string trim $qmaster_pid ]
   if { $prg_exit_state != 0 } {
      set qmaster_pid -1
   }

   get_ps_info $qmaster_pid $hostname

   if { ($ps_info($qmaster_pid,error) == 0) && ( [ string first "qmaster" $ps_info($qmaster_pid,string)] >= 0 )  } {
      incr running 2
   }

   return $running
}


# kills master and scheduler on the given hostname
#                                                             max. column:     |
#****** sge_procedures/shutdown_master_and_scheduler() ******
#
#  NAME
#     shutdown_master_and_scheduler -- ???
#
#  SYNOPSIS
#     shutdown_master_and_scheduler { hostname qmaster_spool_dir }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname          - ???
#     qmaster_spool_dir - ???
#
#  RESULT
#     ???
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
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#*******************************
proc shutdown_master_and_scheduler {hostname qmaster_spool_dir} {
   get_current_cluster_config_array ts_config

   shutdown_qmaster $hostname $qmaster_spool_dir
}

#****** sge_procedures/shutdown_scheduler() ************************************
#  NAME
#     shutdown_scheduler() -- ???
#
#  SYNOPSIS
#     shutdown_scheduler { hostname qmaster_spool_dir }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname          - ???
#     qmaster_spool_dir - ???
#
#  RESULT
#     ???
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
#*******************************************************************************
proc shutdown_scheduler {hostname qmaster_spool_dir} {
   global CHECK_USER CHECK_ADMIN_USER_SYSTEM
   get_current_cluster_config_array ts_config

   ts_log_fine "shutdown_scheduler ..."

   ts_log_finer "killing scheduler on host $hostname ..."
   ts_log_finest "retrieving data from spool dir $qmaster_spool_dir"



   set scheduler_pid [ get_scheduler_pid $hostname $qmaster_spool_dir ]

   get_ps_info $scheduler_pid $hostname
   if { ($ps_info($scheduler_pid,error) == 0) } {
      if { [ is_pid_with_name_existing $hostname $scheduler_pid "sge_schedd" ] == 0 } {
         ts_log_finest "shutdown schedd with pid $scheduler_pid on host $hostname"
         ts_log_finest "do a qconf -ks ..."
         set result [start_sge_bin "qconf" "-ks"]
         ts_log_finest $result
         after 1500
         shutdown_system_daemon $hostname sched
      } else {
         ts_log_severe "scheduler pid $scheduler_pid not found"
         set scheduler_pid -1
      }
   } else {
      ts_log_severe "ps_info failed (1), pid=$scheduler_pid"
      set scheduler_pid -1
   }

   ts_log_finest "done."
}
#****** sge_procedures/is_scheduler_alive() ************************************
#  NAME
#     is_scheduler_alive() -- ???
#
#  SYNOPSIS
#     is_scheduler_alive { hostname qmaster_spool_dir }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname          - ???
#     qmaster_spool_dir - ???
#
#  RESULT
#     1, if it is alive
#     0, if it is not alive
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
#*******************************************************************************
proc is_scheduler_alive { hostname qmaster_spool_dir } {
   get_current_cluster_config_array ts_config
   set scheduler_pid [get_scheduler_pid $hostname $qmaster_spool_dir]
   get_ps_info $scheduler_pid $hostname

   set alive 0
   if { ($ps_info($scheduler_pid,error) == 0) } {
      if { [ is_pid_with_name_existing $hostname $scheduler_pid "sge_schedd" ] == 0 } {
         set alive 1
      }
   }

   return $alive
}

#****** sge_procedures/is_qmaster_alive() **************************************
#  NAME
#     is_qmaster_alive() -- check if qmaster process is running
#
#  SYNOPSIS
#     is_qmaster_alive { hostname qmaster_spool_dir }
#
#  FUNCTION
#     This function searches the process table for a running qmaster process
#
#  INPUTS
#     hostname          - qmaster hostname
#     qmaster_spool_dir - qmaster spool dir
#
#  RESULT
#     1 on success
#     0 on error
#
#  SEE ALSO
#     sge_procedures/is_scheduler_alive()
#*******************************************************************************
proc is_qmaster_alive { hostname qmaster_spool_dir } {
   get_current_cluster_config_array ts_config
   set qmaster_pid [get_qmaster_pid]
   get_ps_info $qmaster_pid $hostname

   set alive 0
   if { ($ps_info($qmaster_pid,error) == 0) } {
      if { [ is_pid_with_name_existing $hostname $qmaster_pid "sge_qmaster" ] == 0 } {
         set alive 1
      }
   }

   return $alive
}

#****** sge_procedures/is_execd_alive() **************************************
#  NAME
#     is_execd_alive() -- check if execd process is running
#
#  SYNOPSIS
#     is_execd_alive {hostname execd_spool_dir}
#
#  FUNCTION
#     This function searches the process table for a running execd process
#
#  INPUTS
#     hostname          - execd hostname
#     execd_spool_dir   - execd spool dir
#
#  RESULT
#     1 on success
#     0 on error
#
#  SEE ALSO
#     sge_procedures/is_scheduler_alive()
#     sge_procedures/is_qmaster_alive()
#*******************************************************************************
proc is_execd_alive {hostname {execd_spool_dir ""}} {
   get_current_cluster_config_array ts_config
   set execd_pid [get_execd_pid $hostname $execd_spool_dir]
   get_ps_info $execd_pid $hostname

   set alive 0
   if {$ps_info($execd_pid,error) == 0} {
      if {[is_pid_with_name_existing $hostname $execd_pid "sge_execd"] == 0} {
         set alive 1
      }
   }

   return $alive
}

#****** sge_procedures/get_qmaster_pid() ***************************************
#  NAME
#     get_qmaster_pid() -- ???
#
#  SYNOPSIS
#     get_qmaster_pid { hostname qmaster_spool_dir }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname          - ???
#     qmaster_spool_dir - ???
#
#  RESULT
#     ???
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
#*******************************************************************************
proc get_qmaster_pid { {hostname ""} {qmaster_spool_dir ""}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   if {[string length $hostname] == 0} {
      set hostname $ts_config(master_host)
   }

   if {[string length $qmaster_spool_dir] == 0} {
      set qmaster_spool_dir [get_qmaster_spool_dir]
   }

   set pid_file "$qmaster_spool_dir/qmaster.pid"
   return [get_pid_from_file $hostname $pid_file]
}

#****** sge_procedures/get_scheduler_pid() *************************************
#  NAME
#     get_scheduler_pid() -- ???
#
#  SYNOPSIS
#     get_scheduler_pid { hostname qmaster_spool_dir }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname          - ???
#     qmaster_spool_dir - ???
#
#  RESULT
#     ???
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
#*******************************************************************************
proc get_scheduler_pid { hostname qmaster_spool_dir } {
   return [get_pid_from_file $hostname "$qmaster_spool_dir/schedd/schedd.pid"]
}

#****** sge_procedures/get_shadowd_pid() ***************************************
#  NAME
#     get_shadowd_pid() -- ???
#
#  SYNOPSIS
#     get_shadowd_pid { hostname qmaster_spool_dir }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname          - ???
#     qmaster_spool_dir - ???
#
#  RESULT
#     ???
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
#*******************************************************************************
proc get_shadowd_pid { hostname {qmaster_spool_dir ""}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   if {[string length $qmaster_spool_dir] == 0} {
      set qmaster_spool_dir [get_qmaster_spool_dir]
   }
   set arch [resolve_arch $hostname]
   set HOST [string trim [start_remote_prog $hostname $CHECK_USER "$ts_config(product_root)/utilbin/$arch/gethostname" "-aname"]]
   set UQHOST [lindex [split $HOST "."] 0]
   set pid_file "$qmaster_spool_dir/shadowd_$UQHOST.pid"
   start_remote_prog $hostname $CHECK_USER "test" "-f $pid_file"
   if {$prg_exit_state != 0} {
      set pid_file "$qmaster_spool_dir/shadowd_$HOST.pid"
      start_remote_prog $hostname $CHECK_USER "test" "-f $pid_file"
      if {$prg_exit_state != 0} {
         ts_log_fine "No pid file. Shadowd is not running on host $hostname"
         return 0
      }
   }

   return [get_pid_from_file $hostname $pid_file]
}

#****** sge_procedures/get_execd_pid() *****************************************
#  NAME
#     get_execd_pid() -- ???
#
#  SYNOPSIS
#     get_execd_pid { hostname execd_spool_dir }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname          - ???
#     execd_spool_dir - ???
#
#  RESULT
#     ???
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
#*******************************************************************************
proc get_execd_pid { hostname {execd_spool_dir ""}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   if {[string length $execd_spool_dir] == 0} {
      set execd_spool_dir [get_execd_spool_dir $hostname]
   }

   set pid_file "$execd_spool_dir/$hostname/execd.pid"
   return [get_pid_from_file $hostname $pid_file]
}

#****** sge_procedures/get_pid_from_file() *************************************
#  NAME
#     get_pid_from_file() -- ???
#
#  SYNOPSIS
#     get_pid_from_file {host pid_file}
#
#  FUNCTION
#     ???
#
#  INPUTS
#     host        - ???
#     pid_file    - ???
#
#  RESULT
#     ???
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
#*******************************************************************************
proc get_pid_from_file {host pid_file} {
   global CHECK_USER

   start_remote_prog "$host" $CHECK_USER "test" "-f $pid_file"
   if {$prg_exit_state != 0} {
      ts_log_fine "No pid file. Process is not running on host $host"
      return 0
   }

   set dpid 0
   set dpid [start_remote_prog "$host" "$CHECK_USER" "cat" "$pid_file"]
   set dpid [ string trim $dpid ]
   if { $prg_exit_state != 0 } {
      ts_log_fine "Could not read pid file $pid_file on host $host"
      set dpid 0
   }
   return $dpid
}

#****** sge_procedures/shutdown_qmaster() **************************************
#  NAME
#     shutdown_qmaster() -- ???
#
#  SYNOPSIS
#     shutdown_qmaster { hostname qmaster_spool_dir }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname          - ???
#     qmaster_spool_dir - ???
#
#  RESULT
#     ???
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
#*******************************************************************************
proc shutdown_qmaster {hostname qmaster_spool_dir {timeout 60}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER CHECK_ADMIN_USER_SYSTEM
   global CHECK_VALGRIND CHECK_INSTALL_RC

   ts_log_fine "shutdown_qmaster ..."

   ts_log_finer "killing qmaster on host $hostname ..."
   ts_log_finest "retrieving data from spool dir $qmaster_spool_dir"

   if {$CHECK_VALGRIND == "master" && $timeout < 900} {
      set timeout 900
   }

   set qmaster_pid [get_qmaster_pid $hostname $qmaster_spool_dir]
   if {$qmaster_pid == 0} {
      return -1
   }

   get_ps_info $qmaster_pid $hostname
   if {$ps_info($qmaster_pid,error) == 0} {
      # is_pid_with_name_existing does not work if qmaster is running under valgrind
      if {[is_pid_with_name_existing $hostname $qmaster_pid "sge_qmaster"] == 0} {
         if {$CHECK_INSTALL_RC == 1 && [ge_has_feature "systemd"] && [host_has_systemd $hostname] && [systemd_is_service_active $hostname "qmaster"]} {
            ts_log_fine "killing qmaster with pid $qmaster_pid on host $hostname, via systemd"
            systemd_stop_service $hostname "qmaster"
         } else {
            ts_log_finest "killing qmaster with pid $qmaster_pid on host $hostname with qconf -km"
            ts_log_finest "do a qconf -km ..."
            set result [start_sge_bin "qconf" "-km"]
            ts_log_finest $result
         }
         wait_till_qmaster_is_down $hostname $timeout
         shutdown_system_daemon $hostname qmaster
      } else {
         ts_log_severe "qmaster pid $qmaster_pid not found"
         return -1
      }
   } else {
      ts_log_info "ps_info failed (2), pid=$qmaster_pid"
      return -1
   }

   ts_log_finest "done."
   return 0
}

#*********** sge_procedures/shutdown_shadowd() **********
#
#  NAME
#     shutdown_adowd -- ???
#
#  SYNOPSIS
#     shutdown_shadowd { hostname }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname - ???
#
#  RESULT
#     ???
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
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#*******************************
proc shutdown_shadowd { hostname } {
   global CHECK_ADMIN_USER_SYSTEM
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set shadowd_pid [get_shadowd_pid $hostname]
   if {$shadowd_pid == 0} {
      return -1
   }

   ts_log_fine "shutdown shadowd pid=$shadowd_pid on host \"$hostname\""

   if { $CHECK_ADMIN_USER_SYSTEM == 0 } {
      start_remote_prog "$hostname" "root" "kill" "$shadowd_pid"
   } else {
      start_remote_prog "$hostname" "$CHECK_USER" "kill" "$shadowd_pid"
   }

   if { [ is_pid_with_name_existing $hostname $shadowd_pid "sge_shadowd" ] == 0 } {
         ts_log_info "could not shutdown shadowd at host $hostname with term signal"
         ts_log_finest "Killing process $shadowd_pid with kill signal ..."
         if { [ have_root_passwd ] == -1 } {
            set_root_passwd
         }
         if { $CHECK_ADMIN_USER_SYSTEM == 0 } {
             start_remote_prog "$hostname" "root" "kill" "-9 $shadowd_pid"
         } else {
             start_remote_prog "$hostname" "$CHECK_USER" "kill" "-9 $shadowd_pid"
         }
   }
   if { [is_pid_with_name_existing $hostname $shadowd_pid "sge_shadowd" ] != 0 } {
      return 0
   }
   ts_log_severe "could not shutdown shadowd at host $hostname with kill signal"
   return -1
}

#                                                             max. column:     |
#****** sge_procedures/shutdown_all_shadowd() ******
#
#  NAME
#     shutdown_all_shadowd -- ???
#
#  SYNOPSIS
#     shutdown_all_shadowd { hostname }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname - ???
#
#  RESULT
#     ???
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
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#*******************************
proc shutdown_all_shadowd {hostname} {
   get_current_cluster_config_array ts_config
   global CHECK_ADMIN_USER_SYSTEM
   global CHECK_USER CHECK_INSTALL_RC

   # if we are running a root user system, we need root access
   if {$CHECK_ADMIN_USER_SYSTEM == 0} {
      if {[have_root_passwd] == -1} {
         set_root_passwd
      }
   }

   # if we are running under systemd control, then use systemctl stop to shutdown the shadowd
   # BUT: only on non qmaster hosts - on the qmaster host shutting down the master will also stop shadowd
   # DISABLED for now: No rc-scripts are installed on shadow hosts, see CS-1218
   if {0 && $CHECK_INSTALL_RC == 1 && [ge_has_feature "systemd"] && [host_has_systemd $hostname] && [systemd_is_service_active $hostname "qmaster"]} {
      if {$hostname != $ts_config(master_host)} {
         ts_log_fine "killing shadowd on host $hostname, via systemd"
         systemd_stop_service $hostname "qmaster"
      }
      return 1
   }

   # killing of sge_shadowd without systemd
   set num_proc 0

   ts_log_fine "shutdown all shadowd daemon for system installed at $ts_config(product_root) ..."

   set index_list [ps_grep $ts_config(product_root) $hostname]
   set new_index ""
   foreach elem $index_list {
      if {[string first "shadowd" $ps_info(string,$elem)] >= 0} {
         lappend new_index $elem
      }
   }
   set num_proc [llength $new_index]
   ts_log_finest "Number of matching processes: $num_proc"
   foreach elem $new_index {
      ts_log_finest $ps_info(string,$elem)
      if {[is_pid_with_name_existing $hostname $ps_info(pid,$elem) "sge_shadowd"] == 0} {
         ts_log_finest "killing process [set ps_info(pid,$elem)] ..."
         if {[have_root_passwd] == -1} {
            set_root_passwd
         }
         if {$CHECK_ADMIN_USER_SYSTEM == 0} {
             start_remote_prog "$hostname" "root" "kill" "$ps_info(pid,$elem)"
         } else {
             start_remote_prog "$hostname" "$CHECK_USER" "kill" "$ps_info(pid,$elem)"
         }
      }
   }

   foreach elem $new_index {
      ts_log_finest $ps_info(string,$elem)
      if { [ is_pid_with_name_existing $hostname $ps_info(pid,$elem) "sge_shadowd" ] == 0 } {
         ts_log_info "could not shutdown shadowd at host $hostname with term signal"
         ts_log_finest "Killing process with kill signal [ set ps_info(pid,$elem) ] ..."
         if { [ have_root_passwd ] == -1 } {
            set_root_passwd
         }
         if { $CHECK_ADMIN_USER_SYSTEM == 0 } {
             start_remote_prog "$hostname" "root" "kill" "-9 $ps_info(pid,$elem)"
         } else {
             start_remote_prog "$hostname" "$CHECK_USER" "kill" "-9 $ps_info(pid,$elem)"
         }
      }
   }

   foreach elem $new_index {
      ts_log_finest $ps_info(string,$elem)
      if { [ is_pid_with_name_existing $hostname $ps_info(pid,$elem) "sge_shadowd" ] == 0 } {
         ts_log_severe "could not shutdown shadowd at host $hostname with kill signal"
      }
   }

   return $num_proc
}


#                                                             max. column:     |
#****** sge_procedures/shutdown_bdb_rpc() ******
#
#  NAME
#     shutdown_bdb_rpc -- ???
#
#  SYNOPSIS
#     shutdown_bdb_rpc { hostname }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname - ???
#
#  RESULT
#     ???
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
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_bdb_rpc()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#*******************************
proc shutdown_bdb_rpc { hostname } {
   global CHECK_ADMIN_USER_SYSTEM
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set num_proc 0

   ts_log_fine "shutdown bdb_rpc daemon for system installed at $ts_config(product_root) ..."

   set index_list [ ps_grep "$ts_config(product_root)" "$hostname" ]
   set new_index ""
   foreach elem $index_list {
      if { [ string first "berkeley_db_svc" $ps_info(string,$elem) ] >= 0 } {
         lappend new_index $elem
      }
   }
   set num_proc [llength $new_index]
   ts_log_finest "Number of matching processes: $num_proc"
   foreach elem $new_index {
      ts_log_finest $ps_info(string,$elem)
      if { [ is_pid_with_name_existing $hostname $ps_info(pid,$elem) "berkeley_db_svc" ] == 0 } {
         ts_log_finest "killing process [ set ps_info(pid,$elem) ] ..."
         if { [ have_root_passwd ] == -1 } {
            set_root_passwd
         }
         if { $CHECK_ADMIN_USER_SYSTEM == 0 } {
             start_remote_prog "$hostname" "root" "kill" "$ps_info(pid,$elem)"
         } else {
             start_remote_prog "$hostname" "$CHECK_USER" "kill" "$ps_info(pid,$elem)"
         }
      }
   }

   foreach elem $new_index {
      ts_log_finest $ps_info(string,$elem)
      if { [ is_pid_with_name_existing $hostname $ps_info(pid,$elem) "berkeley_db_svc" ] == 0 } {
         ts_log_info "could not shutdown berkeley_db_svc at host $elem with term signal"
         ts_log_finest "Killing process with kill signal [ set ps_info(pid,$elem) ] ..."
         if { [ have_root_passwd ] == -1 } {
            set_root_passwd
         }
         if { $CHECK_ADMIN_USER_SYSTEM == 0 } {
             start_remote_prog "$hostname" "root" "kill" "-9 $ps_info(pid,$elem)"
         } else {
             start_remote_prog "$hostname" "$CHECK_USER" "kill" "-9 $ps_info(pid,$elem)"
         }
      }
   }

   foreach elem $new_index {
      ts_log_finest $ps_info(string,$elem)
      if { [ is_pid_with_name_existing $hostname $ps_info(pid,$elem) "berkeley_db_svc" ] == 0 } {
         ts_log_severe "could not shutdown berkeley_db_svc at host $elem with kill signal"
    return -1
      }
   }

   return $num_proc
}


#
#                                                             max. column:     |
#
#****** sge_procedures/is_pid_with_name_existing() ******
#  NAME
#     is_pid_with_name_existing -- search for process on remote host
#
#  SYNOPSIS
#     is_pid_with_name_existing { host pid proc_name }
#
#  FUNCTION
#     This procedure will start the checkprog binary with the given parameters.
#
#
#  INPUTS
#     host      - remote host
#     pid       - pid of process
#     proc_name - process program name
#
#  RESULT
#     0 - ok; != 0 on error
#
#  SEE ALSO
#     sge_procedures/is_job_running()
#     sge_procedures/is_pid_with_name_existing()
#*******************************
#
proc is_pid_with_name_existing {host pid proc_name} {
   global CHECK_USER CHECK_VALGRIND
   get_current_cluster_config_array ts_config

   if {$CHECK_VALGRIND != ""} {
      get_ps_info $pid $host
      if {$ps_info($pid,error) == 0 &&
          [info exists ps_info($pid,command)] &&
          [string first $proc_name $ps_info($pid,command)] >= 0} {
         return 0
      } else {
         return 1
      }
   } else {
      ts_log_finer "$host: checkprog $pid $proc_name ..."
      set my_arch [ resolve_arch $host ]
      set output [start_remote_prog $host $CHECK_USER $ts_config(product_root)/utilbin/$my_arch/checkprog "$pid $proc_name"]
      if {$prg_exit_state == 0} {
         ts_log_finest "running"
      } else {
         ts_log_finest "not running"
      }
   }
   return $prg_exit_state
}


#
#                                                             max. column:     |
#
#****** sge_procedures/shutdown_system_daemon() ******
#  NAME
#     shutdown_system_daemon -- kill running sge daemon
#
#  SYNOPSIS
#     shutdown_system_daemon { host type }
#
#  FUNCTION
#     This procedure will kill all commd, execd, qmaster, shadowd or sched
#     processes on the given host.
#     It does not matter weather the system is sgeee or sge (sge or sgeee).
#
#  INPUTS
#     host     - remote host
#     typelist - list of processes to kill (commd, execd, qmaster, shadowd or sched)
#     { do_term_signal_kill_first 1 } - if set to 1 the first kill signal is
#                                       SIG_TERM and SIG_KILL only if SIG_TERM
#                                       wasn't successful
#                                     - if 0 the procedure sends immediately a
#                                       SIG_KILL signal.
#
#  RESULT
#     none
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
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#*******************************
#
proc shutdown_system_daemon { host typelist { do_term_signal_kill_first 1 } } {
   global CHECK_CORE_INSTALLED CHECK_USER
   global CHECK_ADMIN_USER_SYSTEM
   get_current_cluster_config_array ts_config


   ts_log_fine "shutdown_system_daemon ... ($host/$typelist)"
   set process_names ""
   foreach type $typelist {
      if { [ string compare $type "execd" ] == 0 } {
         lappend process_names "sge_execd"
      }
      if { [ string compare $type "sched" ] == 0 } {
         lappend process_names "sge_schedd"
      }
      if { [ string compare $type "qmaster" ] == 0 } {
         lappend process_names "sge_qmaster"
      }
      if { [ string compare $type "commd" ] == 0 } {
         lappend process_names "sge_commd"
      }
      if { [ string compare $type "shadowd" ] == 0 } {
         lappend process_names "sge_shadowd"
      }
   }

   if { [llength $process_names] != [llength $typelist] } {
      ts_log_severe "type should be commd, execd, qmaster, shadowd or sched"
      return -1
   }

   set found_p [ ps_grep "$ts_config(product_root)/" $host ]
   set nr_of_found_qmaster_processes_or_threads 0

   foreach process_name $process_names {
      ts_log_finest "looking for \"$process_name\" processes on host $host ..."
      set nr_of_sig_terms 0
      foreach elem $found_p {
         if { [ string first $process_name $ps_info(string,$elem) ] >= 0 } {
            ts_log_finest "current ps info: $ps_info(string,$elem)"
            if { [ is_pid_with_name_existing $host $ps_info(pid,$elem) $process_name ] == 0 } {
               incr nr_of_found_qmaster_processes_or_threads 1
               ts_log_finest "found running $process_name with pid $ps_info(pid,$elem) on host $host"
               ts_log_finest $ps_info(string,$elem)
               if { [ have_root_passwd ] == -1 } {
                   set_root_passwd
               }
               if { $CHECK_ADMIN_USER_SYSTEM == 0 } {
                   set kill_user "root"
               } else {
                   set kill_user $CHECK_USER
               }
               if { $do_term_signal_kill_first == 1 } {
                  set kill_pid_ids ""
                  foreach tmp_elem $found_p {
                     if { [ string first $process_name $ps_info(string,$tmp_elem) ] >= 0 } {
                        append kill_pid_ids " $ps_info(pid,$tmp_elem)"
                     }
                  }
                  ts_log_finest "killing (SIG_TERM) process(es) $kill_pid_ids on host $host, kill user is $kill_user"
                  ts_log_finest [start_remote_prog $host $kill_user kill $kill_pid_ids]
                  incr nr_of_sig_terms 1

                  if { $nr_of_sig_terms == 1 } {
                     set sig_term_wait_timeout 30
                  } else {
                     set sig_term_wait_timeout 1
                  }
                  while { [is_pid_with_name_existing $host $ps_info(pid,$elem) $process_name] == 0 } {
                     ts_log_finest "waiting for process termination ..."
                     after 1000
                     incr sig_term_wait_timeout -1
                     if { $sig_term_wait_timeout <= 0 } {
                        break
                     }
                  }
               }
               if { [ is_pid_with_name_existing $host $ps_info(pid,$elem) $process_name ] == 0 } {
                   ts_log_finest "killing (SIG_KILL) process $ps_info(pid,$elem) on host $host, kill user is $kill_user"
                   ts_log_finest [start_remote_prog $host $kill_user kill "-9 $ps_info(pid,$elem)"]
                   after 1000
                   if { [ is_pid_with_name_existing $host $ps_info(pid,$elem) $process_name ] == 0 } {
                       ts_log_finest "pid:$ps_info(pid,$elem) kill failed (host: $host)"
                       ts_log_severe "not shutdown \"$process_name\" on host $host"
                   } else {
                       ts_log_finest "pid:$ps_info(pid,$elem) process killed (host: $host)"
                   }
               }
            } else {
               if { $nr_of_found_qmaster_processes_or_threads == 0 } {
                  ts_log_info "could not shutdown \"$process_name\" on host $host"
               }
            }
         }
      }
   }
   ts_log_finer "shutdown_system_daemon ... done"
   return 0
}


#********************* sge_procedures/shutdown__daemon() ***********************
#  NAME
#     shutdown_daemon -- kill running sge daemon
#
#  SYNOPSIS
#     shutdown_daemon { host service }
#
#  FUNCTION
#     This procedure will kill the sge process on the given host.
#     It does not matter weather the system is sgeee or sge (sge or sgeee).
#
#  INPUTS
#     host     - remote host
#     service  - daemon name (qmaster, shadowd, execd, bdb, dbwriter)
#
#  RESULT
#     none
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
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#     smf_procedure/start_smf_service()
#*******************************************************************************
proc shutdown_daemon { host service } {
   global ts_config arco_config

   switch -exact $service {
      "master" -
      "qmaster" {
         if {[string compare $host $ts_config(master_host)] != 0} {
            ts_log_severe "Can't stop $service on host $host. Qmaster host is only $ts_config(master_host)"
            return -1
         }
         return [shutdown_qmaster $host [get_qmaster_spool_dir]]
      }
      "shadow" -
      "shadowd" {
         if {[lsearch -exact $ts_config(shadowd_hosts) $host] == -1} {
            ts_log_severe "Can't stop $service. Host $host is not a $service host"
            return -1
         }
         return [shutdown_shadowd $host]
      }
      "execd" {
         if {[lsearch -exact $ts_config(execd_nodes) $host] == -1} {
            ts_log_severe "Can't stop $service. Host $host is not a $service host"
            return -1
         }
         return [soft_execd_shutdown $host]
      }
      "dbwriter" {
         if {[string compare $host $arco_config(dbwriter_host)] != 0} {
            ts_log_severe "Can't stop $service. Host $host is not a $service host"
            return -1
         }
         return [shutdown_dbwriter $host]
      }
      default {
         ts_log_severe "Invalid argument $service passed to shutdown_daemon{}"
         return -1
      }
   }
}


#                                                             max. column:     |
#****** sge_procedures/shutdown_core_system() ******
#
#  NAME
#     shutdown_core_system -- shutdown complete cluster
#
#  SYNOPSIS
#     shutdown_core_system { }
#
#  FUNCTION
#     ???
#
#  INPUTS
#
#  RESULT
#     ???
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
#     sge_procedures/shutdown_core_system()
#     sge_procedures/startup_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#*******************************
proc shutdown_core_system {{only_hooks 0} {with_additional_clusters 0}} {
   global CHECK_USER
   global CHECK_ADMIN_USER_SYSTEM CHECK_INSTALL_RC
   get_current_cluster_config_array ts_config

   exec_shutdown_hooks

   if {$only_hooks != 0} {
      ts_log_fine "skip shutdown core system, I am in only hooks mode"
      return
   }

   # stop with systemd whereever is possible
   set use_systemd_if_available 0
   if {$CHECK_INSTALL_RC == 1 && [ge_has_feature "systemd"]} {
      set use_systemd_if_available 1
   }
   foreach host $ts_config(execd_nodes) {
      if {$use_systemd_if_available && [host_has_systemd $host] && [systemd_is_service_active $host "execd"]} {
         # shutdown the execds via systemd
         systemd_stop_service $host "execd"
      } else {
         # shutdown via qconf
         set result [start_sge_bin "qconf" "-ke $host"]
         ts_log_fine $result
      }
   }

   # give execds some time to shutdown
   wait_for_unknown_load 60 all.q 0

   # shutdown qmaster via systemd
   set qmaster_shutdown 0
   if {$CHECK_INSTALL_RC == 1 && [ge_has_feature "systemd"]} {
      if {[host_has_systemd $ts_config(master_host)] && [systemd_is_service_active $ts_config(master_host) "qmaster"]} {
         if {[systemd_stop_service $ts_config(master_host) "qmaster"]} {
            set qmaster_shutdown 1
         }
      }
   }

   # shutdown qmaster via qconf
   if {!$qmaster_shutdown} {
      ts_log_fine "do qconf -km ..."
      set result [start_sge_bin "qconf" "-km"]
      ts_log_finest "qconf -km returned $prg_exit_state"
      if {$prg_exit_state == 0} {
         ts_log_finest $result
         if {[wait_till_qmaster_is_down $ts_config(master_host)] != 0} {
            shutdown_system_daemon $ts_config(master_host) "qmaster"
         }
      } else {
         ts_log_fine "shutdown_core_system - qconf -km failed:\n$result"
         #No need to wait until timeout if qconf -km failed
         shutdown_system_daemon $ts_config(master_host) "qmaster"
      }
   }

   shutdown_system_daemon $ts_config(master_host) "execd qmaster"

   # check for processes on
   # - master host
   set hosts_to_check $ts_config(master_host)
   # - execd hosts
   foreach elem $ts_config(execd_nodes) {
      if {[lsearch -exact $hosts_to_check $elem] < 0} {
         lappend hosts_to_check $elem
      }
   }
   # - shadowd hosts (we might have a qmaster running there!)
   foreach elem $ts_config(shadowd_hosts) {
      if {[lsearch -exact $hosts_to_check $elem] < 0} {
         lappend hosts_to_check $elem
      }
   }

   set proccess_names ""
   set real_proccess_names ""
   lappend proccess_names "execd"
   lappend real_proccess_names "sge_execd"
   lappend proccess_names "qmaster"
   lappend real_proccess_names "sge_qmaster"
   lappend proccess_names "shadowd"
   lappend real_proccess_names "sge_shadowd"

   # now check that all daemons are gone
   foreach host $hosts_to_check {
      ts_log_fine "look for running \"$real_proccess_names\" processes on host \"$host\" ..."
      foreach process $real_proccess_names {
         if {[is_daemon_running $host $process 1] != 0} {
            ts_log_fine "process \"$process\" on host \"$host\" is still running!"
            shutdown_system_daemon $host $proccess_names
         }
      }
   }

   # check for core files
   # core file in qmaster spool directory
   set spooldir [get_spool_dir $ts_config(master_host) qmaster]
   check_for_core_files $ts_config(master_host) $spooldir

   # core files in execd spool directories
   foreach host $ts_config(execd_nodes) {
      set spooldir [get_spool_dir $host execd]
      check_for_core_files $host "$spooldir"
   }

   check_for_core_files $ts_config(master_host) $ts_config(product_root)

   # we might have secondary Cluster Scheduler (Grid Engine) clusters
   # shut them down as well
   if {$with_additional_clusters} {
      operate_additional_clusters kill
   }
}

#****** sge_procedures/startup_core_system() ***********************************
#  NAME
#     startup_core_system() -- startup complete cluster
#
#  SYNOPSIS
#     startup_core_system { {only_hooks 0} {with_additional_clusters 0} }
#
#  FUNCTION
#     startup cluster which was shutdown before with shutdown_core_system()
#
#  INPUTS
#     {only_hooks 0}               - if not 0 only hooks are started
#     {with_additional_clusters 0} - if not 0 additional clusters are started
#
#  RESULT
#     ???
#
#  SEE ALSO
#      sge_procedures/shutdown_core_system()
#*******************************************************************************
proc startup_core_system {{only_hooks 0} {with_additional_clusters 0} } {
   global CHECK_USER
   global CHECK_ADMIN_USER_SYSTEM
   get_current_cluster_config_array ts_config

   if {[have_root_passwd] == -1} {
      set_root_passwd
   }

   if {$only_hooks == 0} {
      # startup of schedd and qmaster
      startup_qmaster

      # startup all shadowds
      #
      foreach sh_host $ts_config(shadowd_hosts) {
         ts_log_finer "testing shadowd settings for host $sh_host ..."
         set info [check_shadowd_settings $sh_host]
         if { $info != "" } {
            ts_log_info "skipping shadowd startup for host $sh_host:\n$info"
            continue
         }
         startup_shadowd $sh_host
      }

      # startup of all execd
      foreach ex_host $ts_config(execd_nodes) {
         startup_execd $ex_host
      }

      # here we startup additional clusters
      if {$with_additional_clusters != 0} {
         operate_additional_clusters start
      }
   } else {
      ts_log_finer "skip startup core system, I am in only hooks mode"
   }

   # now execute all startup hooks
   exec_startup_hooks
}

proc wait_till_qmaster_is_down {host {timeout 60}} {
   get_current_cluster_config_array ts_config

   set start_time [clock seconds]

   set process_names "sge_qmaster"
   set qmaster_pid [get_qmaster_pid]

   set start_time [clock seconds]
   set my_timeout [expr $start_time + $timeout]

   set pstack [get_binary_path $ts_config(master_host) "pstack" 0]

   while {1} {
      set found_p [ps_grep "$ts_config(product_root)/" $host]
      set nr_of_found_qmaster_processes_or_threads 0
      set pstack_add_info ""

      foreach process_name $process_names {
         ts_log_finer "looking for \"$process_name\" processes on host $host ..."
         foreach elem $found_p {
            if {[string first $process_name $ps_info(string,$elem)] >= 0} {
               ts_log_finest "current ps info: $ps_info(string,$elem)"
               if {[is_pid_with_name_existing $host $ps_info(pid,$elem) $process_name] == 0} {
                  incr nr_of_found_qmaster_processes_or_threads 1
                  ts_log_finest "found running $process_name with pid $ps_info(pid,$elem) on host $host"
                  ts_log_finest $ps_info(string,$elem)
                  append pstack_add_info "$ps_info(string,$elem)\n"
               }
            }
         }
      }

      # for debugging: send the stack trace of the shutting-down qmaster as info mail
      if {0} {
         set msg "waiting for qmaster to shutdown\n"
         append msg $pstack_add_info
         # if pstack is installed try to get a stack trace (per thread) to see where it is hanging
         if {$pstack != "pstack"} {
            set output [start_remote_prog $ts_config(master_host) "root" "pstack" $qmaster_pid prg_exit_state 60 0 "" "" 1 0]
            if {$prg_exit_state == 0} {
               append msg "stack_trace of qmaster process $qmaster_pid:\n"
            } else {
               append msg "running ptrace $qmaster_pid failed:\n"
            }
            append msg $output
         }
         ts_log_info $msg
      }

      if {[clock seconds] > $my_timeout} {
         set msg "timeout after $timeout seconds while waiting for qmaster going down\n"
         append msg $pstack_add_info
         # if pstack is installed try to get a stack trace (per thread) to see where it is hanging
         if {$pstack != "pstack"} {
            set output [start_remote_prog $ts_config(master_host) "root" "pstack" $qmaster_pid prg_exit_state 60 0 "" "" 1 0]
            if {$prg_exit_state == 0} {
               append msg "stack_trace of qmaster process $qmaster_pid:\n"
            } else {
               append msg "running ptrace $qmaster_pid failed:\n"
            }
            append msg $output
         }
         ts_log_info $msg
         return -1
      }
      if {$nr_of_found_qmaster_processes_or_threads == 0} {
         ts_log_finest "no qmaster processes running"
         ts_log_fine "wait_till_qmaster_is_down: it took [expr [clock seconds] - $start_time] seconds for the sge_qmaster process to vanish"
         return 0
      } else {
         ts_log_finest "still qmaster processes running ..."
      }
      after 1000
   }
}

#                                                             max. column:     |
#****** sge_procedures/submit_with_method() ******
#
#  NAME
#     submit_with_method
#
#  SYNOPSIS
#     submit_with_method {submit_method options script args}
#
#  FUNCTION
#     Submit a job using different submit methods, e.g. qsub, qrsh, qsh,
#     qrlogin (qrsh without command), qlogin
#
#     The job output is available via the sid returned.
#
#  INPUTS
#     submit_method - method to use: "qsub" or "qrsh"
#     options       - options to the submit command
#     script        - script to start
#     args          - arguments to the script
#     tail_host     - host on which a tail to the output file will be done.
#                     This may be important, it should be the host where the job, or
#                     the master task of the job is run to avoid NFS latencies.
#     {user ""}     - the user who is submitting the job - default is the CHECK_USER
#
#  RESULT
#     a session id from open_spawn_process, or an empty string ("") on error
#
#  NOTES
#     Only qsub and qrsh are implemented.
#
#*******************************
#
proc submit_with_method {submit_method options script args tail_host {user ""} {env_var ""}} {
   global CHECK_USER
   global CHECK_PROTOCOL_DIR
   get_current_cluster_config_array ts_config

   if {$user == ""} {
      set user $CHECK_USER
   }
   if {$env_var != ""} {
      upvar $env_var myenv
   }

   # preprocessing args - it is treated as list for some reason - options not.
   set job_args [lindex $args 0]
   foreach arg [lrange $args 1 end] {
      append job_args " $arg"
   }

   switch -exact $submit_method {
      qsub {
         ts_log_fine "submitting job using qsub, reading from job output file"
         # create job output file
         set job_output_file "$CHECK_PROTOCOL_DIR/check.out"
         set output [start_remote_prog  $tail_host $CHECK_USER "touch" $job_output_file]
         ts_log_fine "touch $job_output_file output:\n$output"
         # initialize tail to logfile
         set sid [init_logfile_wait $tail_host $job_output_file]
         # submit job
         submit_job "-o $job_output_file -j y $options $script $job_args" 1 60 "" "" "" 1 "qsub" 1 "qsub_output" {} "" myenv
         # no need to trigger scheduling from 9.0.0 on: we set flush_submit_sec 1
         if {[is_version_in_range "" "9.0.0"]} {
            start_sge_bin "qconf" "-tsm"
            ts_log_fine "triggered scheduler run"
         }
      }

      qrsh {
         ts_log_fine "submitting job as user \"$user\" using qrsh, reading from stdout/stderr"
#         set command "-c \\\"$ts_config(product_root)/bin/[resolve_arch $ts_config(master_host)]/qrsh -noshell $options $script $job_args\\\""
         set command "$ts_config(product_root)/bin/[resolve_arch $ts_config(master_host)]/qrsh"
         set cmd_args "-noshell $options $script $job_args"
#set command ls
#set cmd_args "-la"
         set sid [open_remote_spawn_process $ts_config(master_host) $user $command $cmd_args 0 "" myenv]
         set sp_id [lindex $sid 1]
#         log_user 1
         set timeout 60
         expect {
            -i $sp_id full_buffer {
               ts_log_severe "expect full_buffer error"
            }
            -i $sp_id timeout {
               ts_log_severe "timeout"
            }
            -i $sp_id eof {
               ts_log_severe "got eof"
            }
            -i $sp_id -- "_start_mark_:(0)" {
               ts_log_fine "remote command started"
            }
         }
         # no need to trigger scheduling for qrsh - it is an immediate job by default
         # start_sge_bin "qconf" "-tsm"
         # ts_log_fine "triggered scheduler run"
      }

      qlogin -
      qrlogin {
         if {$submit_method == "qlogin"} {
            set command "$ts_config(product_root)/bin/[resolve_arch $ts_config(master_host)]/qlogin"
         } else {
            # qrlogin is qrsh without command
            set command "$ts_config(product_root)/bin/[resolve_arch $ts_config(master_host)]/qrsh"
         }
         # we add the -verbose switch to get messages about job id and job being scheduled
         set args "-verbose $options"
         set sid [open_remote_spawn_process $ts_config(master_host) $user $command $args 0 "" myenv]
         if {$sid != ""} {
            set sp_id [lindex $sid 1]
            set timeout 60
            expect {
               -i $sp_id full_buffer {
                  ts_log_severe "expect full_buffer error"
               }
               -i $sp_id timeout {
                  ts_log_severe "timeout"
               }
               -i $sp_id eof {
                  ts_log_severe "got eof"
               }
               -i $sp_id -- "_start_mark_:(0)" {
                  ts_log_fine "remote command started"
               }
            }
         }
      }

      default {
         set sid ""
         ts_log_severe "unknown submit method $submit_method"
      }
   }
   ts_log_fine "==>submitted job, sid = $sid"
   return $sid
}

###
# @brief Wait for verbose messages after submitting a job with qlogin or qrlogin
#
# @param sid - session id returned by submit_with_method
# @param job_id_var - variable name to store the job id, if not empty
# @return 1 if job was successfully scheduled, 0 on timeout or error
##
proc submit_with_method_read_startup_messages {sid {job_id_var ""}} {
   set ret 0

   if {$job_id_var != ""} {
      upvar $job_id_var job_id
   }

   set sp_id [lindex $sid 1]
   # Got telnet client name from global/local config: builtin
   # Your job 5 ("QLOGIN") has been submitted
   # waiting for interactive job to be scheduled ...
   # Your interactive job 5 has been successfully scheduled.
   # Establishing builtin session to host ubuntu-22-amd64-1 ...
   set timeout 60
   set done 0
   expect_user {
      -i $sp_id full_buffer {
         ts_log_severe "expect full_buffer error"
      }
      -i $sp_id timeout {
         ts_log_severe "timeout"
      }
      -i $sp_id eof {
         ts_log_severe "got eof"
      }
      -i $sp_id "*\n" {
         foreach line [split $expect_out(buffer) "\n"] {
            set line [string trim $line]
            if {[string length $line] > 0} {
               ts_log_fine $line
               switch -glob $line {
                  "Your job * has been submitted" {
                     set job_id [lindex $line 2]
                  }
                  "Establishing * session to host *" {
                     ts_log_fine "interactive job $job_id was started"
                     set ret 1
                     set done 1
                  }
               }
            }
         }
         if {!$done} {
            exp_continue
         }
      }
   }

   return $ret
}

###
# @brief Wait for shell response after submitting a job with qlogin or qrlogin
#
# @param sid - session id returned by submit_with_method
# @param num_tries - number of tries to send an echo command to the shell, default 5
# @return 1 if shell response was received, 0 on timeout or error
##
proc submit_with_method_wait_for_shell_response {sid {num_tries 5}} {
   set ret 0

   set sp_id [lindex $sid 1]
   set timeout 2
   set done 0
   log_user 0
   expect_user {
      -i $sp_id full_buffer {
         ts_log_severe "expect full_buffer error while waiting for shell response"
      }
      -i $sp_id timeout {
         if {$num_tries > 0} {
            # send an echo command and expect to see the output
            ts_send $sp_id "echo submit_with_method_wait_for_shell_response\n"
            incr num_tries -1
            exp_continue
         } else {
            ts_log_severe "timeout waiting for shell response"
         }
      }
      -i $sp_id eof {
         ts_log_severe "got eof while waiting for shell response"
      }
      -i $sp_id "*\n" {
         foreach line [split $expect_out(buffer) "\n\r"] {
            set line [string trim $line]
            if {[string length $line] > 0} {
               #ts_log_fine "==>$line<=="
               switch $line {
                  "submit_with_method_wait_for_shell_response" {
                     set ret 1
                     set done 1
                  }
               }
            }
         }
         if {!$done} {
            exp_continue
         }
      }
   }

   return $ret
}

#****** sge_procedures/copy_certificates() **********************************
#  NAME
#     copy_certificates() -- copy csp (ssl) certificates to the specified host
#
#  SYNOPSIS
#     copy_certificates { host }
#
#  FUNCTION
#     copy csp (ssl) certificates to the specified host
#
#  INPUTS
#     host - host where the certificates has to be copied. (Master installation
#            must be called before)
#     sync - (optional), by default "1" means that check for clock times using "qstat -f"
#            is done, different value this check is skipped
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc copy_certificates { host { sync 1 } } {
   global ts_user_config
   global CHECK_ADMIN_USER_SYSTEM CHECK_USER
   get_current_cluster_config_array ts_config

   set remote_arch [resolve_arch $host]

   ts_log_fine "installing CA keys on host $host"
   ts_log_finest "architecture: $remote_arch"
   ts_log_finest "port:         $ts_config(commd_port)"
   ts_log_finest "source:       \"/var/sgeCA/port${ts_config(commd_port)}/\" on host $ts_config(master_host)"
   ts_log_finest "target:       \"/var/sgeCA/port${ts_config(commd_port)}/\" on host $host"

   if {$CHECK_ADMIN_USER_SYSTEM == 0} {
      ts_log_finest "we have root access, fine !"
      set CA_ROOT_DIR "/var/sgeCA"
      set TAR_FILE "${CA_ROOT_DIR}/port${ts_config(commd_port)}.tar"
      set UNTAR_OPTS "-xpvf"

      ts_log_finest "removing existing tar file \"$TAR_FILE\" ..."
      set result [start_remote_prog "$ts_config(master_host)" "root" "rm" "$TAR_FILE"]
      ts_log_finest $result

      ts_log_finest "taring Certificate Authority (CA) directory into \"$TAR_FILE\""
      set tar_bin [get_binary_path $ts_config(master_host) "tar"]
      set remote_command_param "$CA_ROOT_DIR; ${tar_bin} -cpvf $TAR_FILE ./port${ts_config(commd_port)}/*"
      set result [start_remote_prog "$ts_config(master_host)" "root" "cd" "$remote_command_param"]
      ts_log_finest $result

      if {$prg_exit_state != 0} {
         ts_log_warning "could not tar Certificate Authority (CA) directory into \"$TAR_FILE\":\n$result"
      } else {
         ts_log_finest "copy tar file \"$TAR_FILE\"\nto \"$ts_config(results_dir)/port${ts_config(commd_port)}.tar\" ..."
         set result [start_remote_prog "$ts_config(master_host)" "$CHECK_USER" "cp" "$TAR_FILE $ts_config(results_dir)/port${ts_config(commd_port)}.tar" prg_exit_state 300]
         ts_log_finest $result

         # tar file will be on nfs - wait for it to be visible
         wait_for_remote_file $host "root" "$ts_config(results_dir)/port${ts_config(commd_port)}.tar"

         ts_log_finest "copy tar file \"$ts_config(results_dir)/port${ts_config(commd_port)}.tar\"\nto \"$TAR_FILE\" on host $host as root user ..."
         set result [start_remote_prog "$host" "root" "cp" "$ts_config(results_dir)/port${ts_config(commd_port)}.tar $TAR_FILE" prg_exit_state 300]
         ts_log_finest $result

         set tar_bin [get_binary_path $host "tar"]

         ts_log_finest "untaring Certificate Authority (CA) directory in \"$CA_ROOT_DIR\""
         start_remote_prog "$host" "root" "cd" "$CA_ROOT_DIR"
         if {$prg_exit_state != 0} {
            set result [start_remote_prog "$host" "root" "mkdir" "-p $CA_ROOT_DIR"]
         }

         set result [start_remote_prog "$host" "root" $tar_bin "$UNTAR_OPTS $TAR_FILE" prg_exit_state 300 0 $CA_ROOT_DIR]
         ts_log_finest $result
         if {$prg_exit_state != 0} {
            ts_log_warning "could not untar \"$TAR_FILE\" on host $host\n$result"
         }

         ts_log_finest "removing tar file \"$TAR_FILE\" on host $host ..."
         set result [start_remote_prog "$host" "root" "rm" "$TAR_FILE"]
         ts_log_finest $result

         ts_log_finest "removing tar file \"$ts_config(results_dir)/port${ts_config(commd_port)}.tar\" ..."
         set result [start_remote_prog "$ts_config(master_host)" "$CHECK_USER" "rm" "$ts_config(results_dir)/port${ts_config(commd_port)}.tar"]
         ts_log_finest $result
      }

      ts_log_finest "removing tar file \"$TAR_FILE\" ..."
      set result [start_remote_prog "$ts_config(master_host)" "root" "rm" "$TAR_FILE"]
      ts_log_finest $result

      # check for syncron clock times
      if { $sync == 1 } {
         set my_timeout [clock seconds]
         incr my_timeout 600
         ts_log_fine "waiting for qstat -f to work ..."
         while {1} {
            set result [start_remote_prog $host $CHECK_USER "$ts_config(product_root)/bin/$remote_arch/qstat" "-f"]
            ts_log_finest $result
            if {$prg_exit_state == 0} {
               ts_log_finer "qstat -f works, fine!"
               break
            }
            if {[string first "not found" $result]} {
               ts_log_severe "$result"
               return 1
            }
            after 3000
            if {[clock seconds] > $my_timeout} {
               ts_log_warning "$host: timeout while waiting for qstat to work (please check hosts for synchron clock times)"
               break
            }
         }
      }
   } else {
      ts_log_warning "$host: can't copy certificate files as user $CHECK_USER"
   }
   return 0
}


#                                                             max. column:     |
#****** sge_procedures/is_daemon_running() ******
#
#  NAME
#     is_daemon_running
#
#  SYNOPSIS
#     is_daemon_running { hostname daemon }
#
#  FUNCTION
#     Checks, if a daemon is running of the given host.
#     This function does a ps_grep, which seeks for the given
#     daemon name running within the actual SGE_ROOT directory.
#     The daemon can be clearly identified.
#
#  INPUTS
#     hostname  - name of host which should be checked
#     daemon    - name of daemon (sge_execd, sge_qmaster, ...)
#
#  RESULT
#     0 - the given daemon is not running on given host
#     Otherwise the number of running daemons is returned
#
#  SEE ALSO
#     sge_procedures/is_daemon_running
#
#*******************************
#

proc is_daemon_running { hostname daemon {disable_daemon_count_check 0} } {
   get_current_cluster_config_array ts_config

   set found_p [ ps_grep "$ts_config(product_root)/" $hostname ]
   set daemon_count 0

   foreach elem $found_p {
      if { [string match "*$daemon*" $ps_info(string,$elem)] } {
         ts_log_finest $ps_info(string,$elem)
         ts_log_finer "$daemon is running on host $hostname"
         incr daemon_count 1
      }
   }
   if {$daemon_count > 1} {
      set err_text ""
      append err_text "Host: $hostname -> Found $daemon_count running $daemon in one environment!:\n"
      foreach elem $found_p {
         append err_text "$ps_info(string,$elem)\n"
      }
      append err_text "TODO: This function will not work on threaded daemons running on linux 24 kernel\n"
      if {$disable_daemon_count_check != 0} {
         ts_log_info $err_text
      } else {
         ts_log_severe $err_text
      }
   }

   return $daemon_count
}

#****** sge_procedures/restore_qtask_file() ************************************
#  NAME
#     restore_qtask_file() -- restore qtask file from template
#
#  SYNOPSIS
#     restore_qtask_file { }
#
#  FUNCTION
#     Copies $SGE_ROOT/util/qtask to $SGE_ROOT/$SGE_CELL/common/qtask
#
#  RESULT
#     1 on success, else 0
#
#  SEE ALSO
#     sge_procedures/append_to_qtask_file()
#*******************************************************************************
proc restore_qtask_file {} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set ret 1

   # restore the qtask file from util/qtask
   ts_log_fine "restoring qtask file from template util/qtask"
   set qtask_file "$ts_config(product_root)/$ts_config(cell)/common/qtask"
   set qtask_template "$ts_config(product_root)/util/qtask"
   set output [start_remote_prog $ts_config(master_host) $CHECK_USER "cp" "$qtask_template $qtask_file"]
   if {$prg_exit_state != 0} {
      ts_log_severe "error restoring qtask file:\n$output"
      set ret 0
   }
   foreach node $ts_config(execd_nodes) {
      wait_for_remote_file $node $CHECK_USER $qtask_file
   }

   return $ret
}

#****** sge_procedures/restore_sge_request_file() ************************************
#  NAME
#     restore_sge_request_file() -- restore sge_request file from template
#
#  SYNOPSIS
#     restore_sge_request_file { }
#
#  FUNCTION
#     Copies $SGE_ROOT/util/sge_request to $SGE_ROOT/$SGE_CELL/common/sge_request
#
#  RESULT
#     1 on success, else 0
#
#  SEE ALSO
#     sge_procedures/append_to_sge_request_file()
#*******************************************************************************
proc restore_sge_request_file {} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set ret 1

   # restore the sge_request file from util/sge_request
   ts_log_fine "restoring sge_request file from template util/sge_request"
   set sge_request_file "$ts_config(product_root)/$ts_config(cell)/common/sge_request"
   set sge_request_template "$ts_config(product_root)/util/sge_request"
   set output [start_remote_prog $ts_config(master_host) $CHECK_USER "cp" "$sge_request_template $sge_request_file"]
   if {$prg_exit_state != 0} {
      ts_log_severe "error restoring sge_request file:\n$output"
      set ret 0
   }
   foreach node $ts_config(execd_nodes) {
      wait_for_remote_file $node $CHECK_USER $sge_request_file
   }

   return $ret
}

#****** sge_procedures/append_to_qtask_file() **********************************
#  NAME
#     append_to_qtask_file() -- append line(s) to qtask file
#
#  SYNOPSIS
#     append_to_qtask_file { content }
#
#  FUNCTION
#     Appends lines given as argument to the global qtask file.
#
#  INPUTS
#     content - lines to be appended
#
#  RESULT
#     1 on success, else 0
#
#  EXAMPLE
#     append_to_qtask_file "mozilla -l h=myhost"
#
#  SEE ALSO
#     sge_procedures/restore_qtask_file()
#*******************************************************************************
proc append_to_qtask_file {content} {
   get_current_cluster_config_array ts_config

   set ret 1

   set qtask_file "$ts_config(product_root)/$ts_config(cell)/common/qtask"

   # make sure we have a qtask file
   if {[file isfile $qtask_file] == 0} {
      set ret [restore_qtask_file]
   }

   if {$ret} {
      set error [catch {
         set f [open $qtask_file "a"]
         puts $f $content
         close $f
      } output]

      if {$error != 0} {
         ts_log_severe "error appending to qtask file:\n$output"
         set ret 0
      }
   }

   return $ret
}


#****** sge_procedures/append_to_sge_request_file() **********************************
#  NAME
#     append_to_sge_request_file() -- append line(s) to sge_request file
#
#  SYNOPSIS
#     append_to_sge_request_file { content }
#
#  FUNCTION
#     Appends lines given as argument to the global sge_request file.
#
#  INPUTS
#     content - lines to be appended
#
#  RESULT
#     1 on success, else 0
#
#  EXAMPLE
#     append_to_sge_request_file "-m a"
#
#  SEE ALSO
#     sge_procedures/restore_sge_request_file()
#*******************************************************************************
proc append_to_sge_request_file {content} {
   get_current_cluster_config_array ts_config

   set ret 1

   set sge_request_file "$ts_config(product_root)/$ts_config(cell)/common/sge_request"

   # make sure we have a sge_request file
   if {[file isfile $sge_request_file] == 0} {
      set ret [restore_sge_request_file]
   }

   if {$ret} {
      set error [catch {
         set f [open $sge_request_file "a"]
         puts $f $content
         close $f
      } output]

      if {$error != 0} {
         ts_log_severe "error appending to sge_request file:\n$output"
         set ret 0
      }
   }

   return $ret
}



#****** sge_procedures/get_shared_lib_var() ************************************
#  NAME
#     get_shared_lib_var() -- get the env var used for the shared lib path
#
#  SYNOPSIS
#     get_shared_lib_var {hostname}
#
#  FUNCTION
#     Returns the name of the variable that holds the shared library path on
#     the given host.
#
#  INPUTS
#     hostname  The name of the host whose shared lib var will be fetched.
#               Defaults to $ts_config(master_host).  Returns "" on failure.
#
#  RESULT
#     The name of the shared library path variable
#
#  EXAMPLE
#     set shlib [get_shared_lib_path foo]
#*******************************************************************************
proc get_shared_lib_var {{hostname ""}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   set shlib_var ""
   set host $hostname

   if {$host == ""} {
      set host $ts_config(master_host)
   }

   set shlib_var [string trim [start_remote_prog $host $CHECK_USER "$ts_config(product_root)/util/arch" "-lib"]]

   return $shlib_var
}


#****** sge_procedures/get_qconf_list() ****************************************
#  NAME
#     get_qconf_list() -- return a list from qconf -s* command
#
#  SYNOPSIS
#     get_qconf_list { procedure option output_var {on_host ""} {as_user ""}
#     {raise_error 1} }
#
#  FUNCTION
#     Calls qconf with the give option and returns the results as a list by
#     splitting multiple lines into list elements.
#
#     The function can be used to call the qconf show list options, e.g.
#     -sh, -ss -sel, -sm, -so, -suserl, ...
#
#     It will usually be called by a wrapper function, e.g. get_adminhost_list().
#
#  INPUTS
#     procedure       - calling procedure
#     option          - qconf option to call
#     output_var      - output list will be placed here (call by reference)
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#     0 on success, an error code on error.
#     For a list of error codes, see sge_procedures/get_sge_error().
#
#  SEE ALSO
#     sge_procedures/get_sge_error()
#     sge_procedures/get_qconf_list()
#     sge_host/get_adminhost_list()
#*******************************************************************************
proc get_qconf_list {procedure option output_var {on_host ""} {as_user ""} {raise_error 1}} {
   get_current_cluster_config_array ts_config
   upvar $output_var out

   # clear output variable
   if {[info exists out]} {
      unset out
   }

   set ret 0
   set result [start_sge_bin "qconf" $option $on_host $as_user]

   # parse output or raise error
   if {$prg_exit_state == 0} {
      parse_multiline_list result out
   } else {
      set out {}
      set ret [get_sge_error $procedure "qconf $option" $result $raise_error]
   }

   return $ret
}

#****** sge_procedures/get_qconf_object() **************************************
#  NAME
#     get_qconf_object() -- return a list from qconf -s* command
#
#  SYNOPSIS
#     get_qconf_object { procedure option output_var msg_var {on_host ""}
#     {as_user ""} {raise_error 1} }
#
#  FUNCTION
#     Calls qconf with the given option and returns the results as a list by
#     splitting multiple lines into list elements.
#
#     The function can be used to call the qconf show, or show list options,
#     -s<obj>, -s<obj>l
#
#  INPUTS
#     procedure       - calling procedure
#     option          - qconf option to call
#     output_var      - output list will be placed here (call by reference)
#     msg_var         - messages array
#     {list 0}        - 1 for list of objects, 0 for a named object
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#     0 on success, an error code on error.
#     For a list of error codes, see sge_procedures/get_sge_error().
#
#*******************************************************************************
proc get_qconf_object {procedure option output_var msg_var {list 0} {on_host ""} {as_user ""} {raise_error 1}} {
   get_current_cluster_config_array ts_config
   upvar $output_var out
   upvar $msg_var messages

   # clear output variable
   if {[info exists out]} {
      unset out
   }
   if {$list} {
      set out {}
   }

   set result [start_sge_bin "qconf" $option $on_host $as_user]

   # parse output or raise error
   if {$prg_exit_state == 0} {
      set ret 0
      set result [string trim $result]
      # BUG: project, user - for non-existing objectname doesn't return correct error code
      if {[string first $messages(-1) $result] >= 0} {
         set ret [handle_sge_errors "$procedure" "qconf $option" $result messages $raise_error]
         ts_log_finer "NOTE: qconf $option doesn't return correct error code"
      } else {
         if {$list == 0} {
            parse_simple_record result out
         } else {
            parse_multiline_list result out
         }
      }
   } else {
      set ret [handle_sge_errors "$procedure" "qconf $option" $result messages $raise_error]
   }

   return $ret
}

#****** sge_procedures/get_scheduler_status() **********************************
#  NAME
#    get_scheduler_status () -- get the scheduler status
#
#  SYNOPSIS
#     get_scheduler_status { {output_var result} {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -sss to retrieve the scheduler status
#
#  INPUTS
#     output_var      - result will be placed here
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#     0 on success, an error code on error.
#     For a list of error codes, see sge_procedures/get_sge_error().
#
#  SEE ALSO
#     sge_procedures/get_sge_error()
#     sge_procedures/get_qconf_list()
#*******************************************************************************
proc get_scheduler_status {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $output_var out

   return [get_qconf_list "get_scheduler_status" "-sss" out $on_host $as_user $raise_error]

}

#****** sge_procedures/get_detached_settings() *****************************************
#  NAME
#    get_detached_settings () -- get the detached settings in the cluster  config
#
#  SYNOPSIS
#     get_detached_settings { {output_var result} {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -sds to retrieve the detached settings in the cluster  config
#
#  INPUTS
#     output_var      - result will be placed here
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#     0 on success, an error code on error.
#     For a list of error codes, see sge_procedures/get_sge_error().
#
#  SEE ALSO
#     sge_procedures/get_sge_error()
#     sge_procedures/get_qconf_list()
#*******************************************************************************
proc get_detached_settings {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $output_var out

   return [get_qconf_list "get_detached_settings" "-sds" out $on_host $as_user $raise_error]

}


#****** sge_procedures/wait_for_event_client() *********************************
#  NAME
#     wait_for_event_client() -- wait for a event client
#
#  SYNOPSIS
#     wait_for_event_client { evc_name {to_go_away 0} }
#
#  FUNCTION
#     procedure calls qconf -secl to find out which event clients are registered
#     and returns when the specified event client is available/not available
#
#  INPUTS
#     evc_name       - name of event client, e.g. "qsub"
#                      (Its allowed to use reg expr. match synatx)
#     {to_go_away 0} - default 0: return when client is connected
#                      if 1: return when client is NOT connected
#
#  RESULT
#     none
#*******************************************************************************
proc wait_for_event_client { evc_name {to_go_away 0}} {
   set my_timeout [clock seconds]
   incr my_timeout 60
   while {[clock seconds] < $my_timeout} {
      set back [get_event_client_list "" "" 1 result]
      if {$back == 0} {
         set found_event_client 0
         foreach elem $result {
            set event_client [string trim [lindex $elem 1]]
            if {$event_client != "" && $event_client != "NAME"} {
               ts_log_fine "check event client \"$event_client\""
               if {[string match "$evc_name" $event_client]} {
                  incr found_event_client 1
               }
            }
         }
         if {$to_go_away == 0 && $found_event_client != 0} {
            ts_log_fine "Found $found_event_client Event client(s) \"$evc_name\""
            return
         }

         if {$to_go_away != 0 && $found_event_client == 0} {
            ts_log_fine "No Event client(s) \"$evc_name\" found"
            return
         }
      }
      after 1000
   }
   ts_log_severe "timeout while waiting for event client \"$evc_name\""
}

#****** sge_procedures/trigger_scheduling() ************************************
#  NAME
#     trigger_scheduling() -- trigger a scheduler run
#
#  SYNOPSIS
#     trigger_scheduling { }
#
#  FUNCTION
#     Triggers a scheduler run by calling qconf -tsm.
#*******************************************************************************
proc trigger_scheduling {} {
   ts_log_fine "triggering scheduler run"

   set output [start_sge_bin "qconf" "-tsm"]
   if {$prg_exit_state != 0} {
      ts_log_severe "qconf -tsm failed:\n$output"
   }
}

#****** sge_procedures/wait_for_job_end() **************************************
#  NAME
#     wait_for_job_end() -- waits for a job to leave qmaster
#
#  SYNOPSIS
#     wait_for_job_end { job_id {timeout 60} }
#
#  FUNCTION
#     Waits until a job is no longer referenced in qmaster (after sge_schedd
#     has sent a job delete order to sge_qmaster).
#
#  INPUTS
#     job_id          - job id to wait for
#     {timeout 60}    - how long to wait
#     {raise_error 1} - report errors if 1
#
#  RESULT
#     0  - on success
#     -1 - on error
#
#  SEE ALSO
#     sge_procedures/get_qstat_j_info()
#*******************************************************************************
proc wait_for_job_end {job_id {timeout 60} {raise_error 1}} {
   get_current_cluster_config_array ts_config
   set result 0

   # we wait until now + timeout
   set my_timeout [expr [clock seconds] + $timeout]

   # if the job is still in qmaster, wait until it leaves qmaster
   if {[get_qstat_j_info $job_id] != 0} {
      ts_log_fine "waiting for job $job_id to leave qmaster ..."

      after 500
      while {[get_qstat_j_info $job_id] != 0} {
         ts_log_progress
         if {[clock seconds] > $my_timeout} {
            set result -1
            ts_log_severe "timeout while waiting for job $job_id leave qmaster" $raise_error
            break
         }
         after 500
      }
   }
   return $result
}

#****** sge_procedures/sge_client_messages() ***********************************
#  NAME
#     sge_client_messages() -- returns the set of expected generic messages
#
#  SYNOPSIS
#     sge_client_messages {msg_var action obj_type obj_name {on_host ""}
#     {as_user ""}}
#
#  FUNCTION
#     Returns the set of expected generic messages related to action on the given
#     sge object which the client can return.
#
#  INPUTS
#     msg_var       - array of messages (the pair of message code and message value)
#     action        - action examples: add, modify, delete,...
#     obj_type      - sge object examples: project, host, user, calendar,...
#     obj_name      - sge object name
#     {on_host ""}  - execute on this host, default is master host
#     {as_user ""}  - execute qconf as this user, default is $CHECK_USER
#
#  SEE ALSO
#     sge_procedures/add_message_to_container
#*******************************************************************************
proc sge_client_messages {msg_var action obj_type obj_name {on_host ""} {as_user ""}} {
   get_current_cluster_config_array ts_config
   upvar $msg_var messages

   # set up the values of host and user for macro messages, if not set
   if {$on_host == ""} {
      set on_host "*"
   }

   if {$as_user == ""} {
      set as_user "*"
   }

   if {[string compare $obj_name ","] != 0} {
      set obj_name "*"
   }

   switch -exact $action {
      "add" {
         # expect: successfully added [ user, host, object type, object name ]
         #         already exists [ object type, object name ]
         #         not modified [ ]
         set ADDED [translate_macro MSG_SGETEXT_ADDEDTOLIST_SSSS $as_user $on_host $obj_name $obj_type]
         add_message_to_container messages 0 $ADDED

         set ALREADY_EXISTS [translate_macro MSG_SGETEXT_ALREADYEXISTS_SS $obj_type $obj_name]
         add_message_to_container messages -2 $ALREADY_EXISTS

         set NOT_MODIFIED [translate_macro MSG_FILE_NOTCHANGED ]
         add_message_to_container messages -3 $NOT_MODIFIED
      }
      "get" {
         # expect: does not exist [ object type, object name ]
         #         object [ result ]
         set NOT_EXISTS [translate_macro MSG_SGETEXT_DOESNOTEXIST_SS $obj_type $obj_name]
         add_message_to_container messages -1 $NOT_EXISTS
      }
      "del" {
         # expect: successfully removed [ user, host, object type, object name ]
         #         does not exist [ object type, object name ]
         set REMOVED [translate_macro MSG_SGETEXT_REMOVEDFROMLIST_SSSS $as_user $on_host $obj_name $obj_type]
         set NOT_EXISTS [translate_macro MSG_SGETEXT_DOESNOTEXIST_SS $obj_type $obj_name]
         add_message_to_container messages 0 $REMOVED
         add_message_to_container messages -1 $NOT_EXISTS
      }
      "mod" {
         # expect: successfully modified [ user, host, object type, object name ]
         #         already exists [ object type, object name ]
         #         not modified [ ]
         #         unknown attribute [ attribute ]
         #         no ulong [ value ]
         #         obiect not exists
         set MODIFIED [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS $as_user $on_host $obj_name $obj_type]
         add_message_to_container messages 0 $MODIFIED

         set ALREADY_EXISTS [translate_macro MSG_SGETEXT_ALREADYEXISTS_SS $obj_type $obj_name]
         add_message_to_container messages -2 $ALREADY_EXISTS

         set NOT_MODIFIED [translate_macro MSG_FILE_NOTCHANGED ]
         add_message_to_container messages -3 $NOT_MODIFIED

         set NO_ULONG [translate_macro MSG_OBJECT_VALUENOTULONG_S "*"]
         add_message_to_container messages -4 $NO_ULONG

         set NO_ATTR "error: [translate_macro MSG_UNKNOWNATTRIBUTENAME_S \"*\" ]"
         add_message_to_container messages -5 $NO_ATTR

         set NOT_EXISTS [translate_macro MSG_SGETEXT_DOESNOTEXIST_SS $obj_type $obj_name]
         add_message_to_container messages -1 $NOT_EXISTS
      }
      "list" {
         # expect: object [ result ]
         #         not defined [ object type ]
         set NOT_DEFINED [translate_macro MSG_QCONF_NOXDEFINED_S $obj_type]
         add_message_to_container messages -1 $NOT_DEFINED
      }
   }
   return 0
}

#****** sge_procedures/add_message_to_container() ******************************
#  NAME
#     add_message_to_container() -- add a new message to message array
#
#  SYNOPSIS
#     add_message_to_container {msg_var msg msg_index {msg_desc ""}}
#
#  FUNCTION
#     Add a new message to message array, If the array does not exist, it will
#     be created. If the message index already exists, the message will be
#     rewritten.
#
#  INPUTS
#     msg_var       - array of messages
#     msg_code      - message code
#     msg           - message
#     {msg_desc ""} - message description
#
#
#*******************************************************************************
proc add_message_to_container {msg_cont msg_code msg {msg_desc ""}} {
   upvar $msg_cont container

   if {[info exists container(index)]} {
      if {![info exists container($msg_code)]} {
         lappend container(index) $msg_code
      }
   } else {
      # message array doesn't exist, add the new message to the container
      set container(index) $msg_code
   }

   set container($msg_code) $msg

   # add the description, if exists
   if {[string match $msg_desc ""]} {
      if {[info exists container($msg_code,description)]} {
         unset container($msg_code,description)
      }
   } else {
      set container($msg_code,description) $msg_desc
   }

   return 0
}

if {[info procs lassign] == ""} {
    proc lassign {values args} {
        uplevel 1 [list foreach $args [linsert $values end {}] break]
        lrange $values [llength $args] end
    }
}


#****** sge_procedures/test_help_and_usage ******
#
#  NAME
#     test_help_and_usage -- Tests the -help option and no option for a given command
#
#  SYNOPSIS
#     test_help_and_usage {cmd}
#
#  FUNCTION
#     Checks if the help text is presented if no option is given.
#     Checks the return codes of cmd -help and cmd with no option.
#
#  INPUTS
#     cmd -- name of command
#*******************************
proc test_help_and_usage {cmd} {
   # do the qconf calls on the same host
   # otherwise we might get different output
   set host [host_conf_get_suited_hosts]

   # check return code of cmd -help
   set output_help [start_sge_bin $cmd "-help" $host "" prg_exit_state]

   if {$prg_exit_state != 0} {
      ts_log_severe "The return code of $cmd -help was not 0 (it was $prg_exit_state), output was \n$output_help"
   }

   # check if cmd is mapped to cmd -help but with error code and
   # return code 1
   set output [start_sge_bin $cmd "" $host "" prg_exit_state]

   if {$prg_exit_state != 1} {
      ts_log_severe "The return code of $cmd with no option was not 1 (it was $prg_exit_state), output was\n$output"
   }

   # compare output: output_help must be a subset of output
   # because output has to contain an error message
   if {[string first $output_help $output] == -1} {
      ts_log_severe "$cmd with no option does not return the text shown by -help:\n$output\n---- expected ----\n$output_help"
   }
}

proc cleanup_tmpdirs {} {
   get_current_cluster_config_array ts_config
   global CHECK_ADMIN_USER_SYSTEM CHECK_USER

   set tmpdir [get_queue_tmpdir]

   # in an admin user system (no root password available)
   # we have to cleanup the tmpdir as CHECK_USER
   # this shouldn't matter, as there shouldn't be subdirectories
   # created by another user than CHECK_USER
   if {$CHECK_ADMIN_USER_SYSTEM} {
      set clean_user $CHECK_USER
   } else {
      set clean_user "root"
   }

   foreach node $ts_config(execd_nodes) {
      ts_log_fine "cleaning tmpdir ($tmpdir) on node $node"
      start_remote_prog $node $clean_user "rm" "-rf $tmpdir"
   }
}

#****** sge_procedures/switch_spooling() ***************************************
#  NAME
#     switch_spooling() -- switch the spooling method
#
#  SYNOPSIS
#     switch_spooling {}
#
#  FUNCTION
#     Switch the spooling method for the auto installation, if necessary.
#
#   SEE ALSO
#      scripts/switch_spooling.sh
#
#*******************************************************************************
proc switch_spooling {} {
   global ts_config CHECK_USER

   set arch [resolve_arch $ts_config(master_host)]
   set args "$arch "
   append args [replace_string $ts_config(spooling_method) berkeleydb bdb]
   set fs_host [fs_config_get_server_for_path $ts_config(product_root) 0]
   if {$fs_host == ""} {
      set fs_host $ts_config(master_host)
   }
   set output [start_remote_prog $fs_host "root" \
                   "$ts_config(testsuite_root_dir)/scripts/switch_spooling.sh" \
                             $args prg_exit_state 10 0 $ts_config(product_root)]
   set output [start_remote_prog $ts_config(master_host) $CHECK_USER \
                                  "ls" "-la $ts_config(product_root)/bin/$arch"]
   set output [start_remote_prog $ts_config(master_host) $CHECK_USER \
                              "ls" "-la $ts_config(product_root)/utilbin/$arch"]
}


#****** sge_procedures/get_short_hostname() ***************************************
#  NAME
#     get_short_hostname() -- short hostname
#
#  SYNOPSIS
#     get_short_hostname {host}
#
#  FUNCTION
#     Returns the first part of a qualified hostname.
#
#  INPUTS
#     host - a long or short hostname
#
#  RESULT
#     short hostname
#*******************************************************************************
proc get_short_hostname {host} {
   regexp {([0-9a-zA-Z_-]*).*} $host match shorthost
   return $shorthost
}

#****** sge_procedures/get_pid_for_job() ***************************************
#  NAME
#     get_pid_for_job() -- returns the pid of a running job
#
#  SYNOPSIS
#     get_pid_for_job {job_id}
#
#  FUNCTION
#     Given the $job_id, returns the pid related to this job.
#
#  INPUTS
#     job_id                      - job id
#
#  RESULT
#     0 -  if no job was found based on job_id
#     pid - the corresponding pid based on the given job_id
#
#  NOTE
#
#  SEE ALSO
#
#*******************************************************************************
proc get_pid_for_job {job_id} {
   global ts_config CHECK_USER

   set ret [get_extended_job_info $job_id job_info]
   if {$ret == 0} {
      return 0
   }

   set host [get_short_hostname [lindex [split $job_info(queue) "@"] 1]]

   set spool_dir [get_execd_spool_dir $host]

   # build name of pid file
   set pidfile "$spool_dir/$host/active_jobs/$job_id.1/job_pid"

   # read pid from pidfile on execution host
   set real_pid [start_remote_prog $host $CHECK_USER "cat" "$pidfile"]
   if {$prg_exit_state != 0} {
      ts_log_severe "can't read $pidfile on host $host: $real_pid"
      set real_pid ""
   }
   set real_pid [string trim $real_pid]

   return $real_pid

}


#****** sge_procedures/get_complex() ****************************************
#  NAME
#     get_complex() -- get defined complex values
#
#  SYNOPSIS
#     get_complex { change_array }
#
#  FUNCTION
#     returns the output of qconf -sc in a tcl array. The array index id is the
#     complex name. The value is the complex line
#
#  INPUTS
#     change_array - tcl name of array variable
#
#  RESULT
#     1 on error, 0 on success
#
#*******************************************************************************
proc get_complex { change_array } {
  get_current_cluster_config_array ts_config
  upvar $change_array chgar

  if {[info exists chgar]} {
     unset chgar
  }

  set result [start_sge_bin "qconf" "-sc"]
  if {$prg_exit_state != 0} {
     ts_log_severe "qconf -sc failed:\n$result"
     return 1
  }

  # split each line as listelement
  set help [split $result "\n"]
  foreach elem $help {
     if {$elem == ""} {
        continue
     }
     set id [lindex $elem 0]
     if { [ string first "#" $id ]  != 0 } {
        set value [lrange $elem 1 end]
        if { [string compare $value ""] != 0 } {
           set chgar($id) $value
        }
     }
  }
  return 0
}

#****** sge_procedures/set_complex() **********************************
#  NAME
#     set_complex() -- set complexes with the qconf -mc commaned
#
#  SYNOPSIS
#     set_complex { change_array {raise_error 1}}
#
#  FUNCTION
#     Modifies, adds or deletes complexes
#
#     If an complex in change_array already exits the complex will be changed
#     If it not exists in will be added
#     If the complex definition in the change_array is a empty string the
#     complex will be deleted
#
#  INPUTS
#     change_array    - array with the complex definitions
#     {raise_error 1} - if unset the error is expected
#     {fast_add 1}    - add from file
#     {do_reset 0}    - if 1: set the config to the values in the change_array
#                       (This means also to delete values which are not
#                        in change_array)
#
#  RETURN:
#
#     >=0 - success  complex definition has been modified
#      <0 - error
#
#  EXAMPLE:
#
#  1. add or modify a complexes
#
#      set tmp_complex(slots) "s   INT <= YES YES 1 1000"
#      set tmp_complex(dummy) "du1 INT <= YES YES 0 500"
#
#      set_complex tmp_complex
#
#   2. delete a complex
#
#      set tmp_complex(dummy) ""
#      set_complex tmp_complex
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc set_complex {change_array {raise_error 1} {fast_add 1} {do_reset 0} } {
   global CHECK_USER
   get_current_cluster_config_array ts_config
   upvar $change_array chgar_orig

   # copy the change_array, we don't want to modify the original
   foreach elem [array names chgar_orig] {
      set chgar($elem) $chgar_orig($elem)
   }


   # get current config
   set config_return [get_complex current_values]

   if { $do_reset != 0 && $config_return == 0 } {
      # Any elem in current_values which should not be in new config
      # have to be defined in new config as parameter with empty string
      foreach elem [array names current_values] {
         if {![info exists chgar($elem)]} {
            ts_log_fine "removing complex \"$elem\""
            set chgar($elem) ""
         }
      }
   }

   set values [array names chgar]
   if {$fast_add} {
      foreach elem $values {
         set current_values($elem) "$chgar($elem)"
      }

      set tmpfile [dump_array_to_tmpfile current_values]
      set result [start_sge_bin "qconf" "-Mc $tmpfile"]
      ts_log_finer "output of qconf -Mc $tmpfile:\n$result"

      # parse output or raise error
      add_message_to_container messages 4 [translate_macro MSG_CENTRY_NOTCHANGED]
      add_message_to_container messages 3 [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS $CHECK_USER "*" "*" "*"]
      add_message_to_container messages 2 [translate_macro MSG_SGETEXT_REMOVEDFROMLIST_SSSS $CHECK_USER "*" "*" "*"]
      add_message_to_container messages 1 [translate_macro MSG_SGETEXT_ADDEDTOLIST_SSSS $CHECK_USER "*" "*" "*"]
      add_message_to_container messages -1 [translate_macro MSG_CENTRYREFINQUEUE_SS "*" "*"]
      add_message_to_container messages -2 [translate_macro MSG_CENTRYREFINHOST_SS "*" "*"]
      add_message_to_container messages -6 [translate_macro MSG_CENTRY_NULL_URGENCY "*" "*"]
      set result [handle_sge_errors "set_complex" "qconf -Mc" $result messages $raise_error]
      if {$result < 0 && $prg_exit_state == 0} {
         ts_log_severe "prg_exit_state was 0 but qconf returned an error" $raise_error
      }
   } else {
      set vi_commands {}
      foreach elem $values {
         # this will quote any / to \/  (for vi - search and replace)
         set newVal $chgar($elem)
         if {[info exists current_values($elem)]} {
            # if old and new config have the same value, create no vi command,
            # if they differ, add vi command to ...
            if { [compare_complex $current_values($elem) $newVal] != 0 } {
               if {$newVal == ""} {
                  # ... delete config entry (replace by comment)
                  lappend vi_commands ":%s/^$elem .*$/#/\n"
               } else {
                  # ... change config entry
                  set newVal1 [split $newVal {/}]
                  set newVal [join $newVal1 {\/}]
                  lappend vi_commands ":%s/^$elem .*$/$elem  $newVal/\n"
               }
            }
         } else {
            # if the config entry didn't exist in old config: append a new line
            lappend vi_commands "1Gi$elem  $newVal\n[format "%c" 27]"
         }
      }

      set MODIFIED [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS $CHECK_USER "*" "*" "*"]
      set ADDED    [translate_macro MSG_SGETEXT_ADDEDTOLIST_SSSS $CHECK_USER "*" "*" "*"]
      set REMOVED  [translate_macro MSG_SGETEXT_REMOVEDFROMLIST_SSSS $CHECK_USER "*" "*" "*"]
      set STILLREF [translate_macro MSG_CENTRYREFINQUEUE_SS "*" "*"]
      set NOT_MODIFIED [translate_macro MSG_CENTRY_NOTCHANGED]

      set NULL_URGENCY [translate_macro MSG_CENTRY_NULL_URGENCY]

      set master_arch [resolve_arch $ts_config(master_host)]

      set result [handle_vi_edit "$ts_config(product_root)/bin/$master_arch/qconf" "-mc" $vi_commands $MODIFIED $REMOVED $ADDED $NOT_MODIFIED $STILLREF $NULL_URGENCY "___ABCDEFG___" $raise_error]
      if {$result != 0 && $result != -2 && $result != -3 && $result != -4} {
         ts_log_severe "could not modify complex: ($result)" $raise_error
      }
      if {$result == -4} {
         ts_log_fine "INFO: could not modify complex: ($result) (unchanged settings)" $raise_error
      }
   }

   return $result
}

#****** sge_procedures/reset_complex() ******************************************
#  NAME
#     reset_complex() -- reset complex configuration to specified complex config
#
#  SYNOPSIS
#     reset_complex { change_array {raise_error 1} {fast_add 1} }
#
#  FUNCTION
#     This procedure sets the specified complexuration values and removes
#     values which are additional set from the current complex. The resulting
#     complex will reflect the set values in the specified array.
#
#  INPUTS
#     change_array    - values to set
#     {raise_error 1} - if 0: Do not report errors
#     {fast_add 1}    - if 1: Add from file
#
#  RESULT
#     return value of set_complex()
#
#  SEE ALSO
#     sge_procedures/set_complex()
#*******************************************************************************
proc reset_complex {change_array {raise_error 1} {fast_add 1} } {
   upvar $change_array ch_array
   return [set_complex ch_array $raise_error $fast_add 1]
}


#****** sge_procedures/switch_to_admin_user_system() ************************
#  NAME
#     switch_to_admin_user_system() -- switch to a admin user system
#
#  SYNOPSIS
#     switch_to_admin_user_system { }
#
#  FUNCTION
#     run install core system and install admin user system
#
#  INPUTS
#
#  RESULT
#     0 - on success
#
#  NOTES
#     not implemented
#
#  SEE ALSO
#     sge_procedures/switch_to_admin_user_system()
#     sge_procedures/switch_to_normal_user_system()
#     sge_procedures/switch_to_root_user_system()
#*******************************************************************************
proc switch_to_admin_user_system {} {
   global actual_user_system

   if { $actual_user_system != "admin user system" } {
      ts_log_fine "switching from $actual_user_system to admin user system ..."
      ts_log_info "Function not implemented"
      set actual_user_system "admin user system"
   }

   return 0
}

#****** sge_procedures/switch_to_root_user_system() *************************
#  NAME
#     switch_to_root_user_system() -- switch to a root user system
#
#  SYNOPSIS
#     switch_to_root_user_system { }
#
#  FUNCTION
#     run install core system and install root user system
#
#  INPUTS
#
#  RESULT
#     0 - on success
#
#  NOTES
#     not implemented
#
#  SEE ALSO
#     sge_procedures/switch_to_admin_user_system()
#     sge_procedures/switch_to_normal_user_system()
#     sge_procedures/switch_to_root_user_system()
#*******************************************************************************
proc switch_to_root_user_system {} {
   global actual_user_system

   ts_log_info "Function not implemented"
   return 1

   if { $actual_user_system != "root user system" } {
      ts_log_fine "switching from $actual_user_system to root user system ..."
      set actual_user_system "root user system"
   }
}

#****** sge_procedures/switch_to_normal_user_system() ***********************
#  NAME
#     switch_to_normal_user_system() -- switch to a standard user system
#
#  SYNOPSIS
#     switch_to_normal_user_system { }
#
#  FUNCTION
#      run install core system and install standard user system
#
#  INPUTS
#
#  RESULT
#     0 - on success
#
#  NOTES
#     not implemented
#
#  SEE ALSO
#     sge_procedures/switch_to_admin_user_system()
#     sge_procedures/switch_to_normal_user_system()
#     sge_procedures/switch_to_root_user_system()
#*******************************************************************************
proc switch_to_normal_user_system {} {
   global actual_user_system

   ts_log_info "Function not implemented"
   return 1

   if { $actual_user_system != "normal user system" } {
      ts_log_fine "switching from $actual_user_system to normal user system ..."
      set actual_user_system "normal user system"
   }
}

#****** sge_procedures/switch_execd_spool_dir() *****************************
#  NAME
#     switch_execd_spool_dir() -- switch execd spool directory
#
#  SYNOPSIS
#     switch_execd_spool_dir { host spool_type { force_restart 0 } }
#
#  FUNCTION
#     This function will shutdown the execd running on $host, switch the
#     spool type depending on $spool_type if the spool directory doesn't
#     match. The optional parameter force_restart can be used to
#     shutdown/restart the execd even when the spool directory is already
#     set to the correct value.
#
#  INPUTS
#     host                - host of execd
#     spool_type          - "cell", "local", "NFS-ROOT2NOBODY" or "NFS-ROOT2ROOT"
#     { force_restart 0 } - optional if 1: do shutdown/restart even when
#                           spool directory is already matching
#
#  RESULT
#     0 - on success
#
#  SEE ALSO
#     file_procedures/get_execd_spooldir()
#*******************************************************************************
proc switch_execd_spool_dir { host spool_type { force_restart 0 } } {
   global ts_config CHECK_USER

   set spool_dir [get_execd_spooldir $host $spool_type]
   set base_spool_dir [get_execd_spooldir $host $spool_type 1]

   if { [info exists execd_config] } {
      unset execd_config
   }
   if { [get_config execd_config $host] != 0 } {
      ts_log_severe "can't get configuration for host $host"
      return -1
   }

   if { $execd_config(execd_spool_dir) == $spool_dir && $force_restart == 0 } {
      ts_log_finest "spool dir is already set to $spool_dir"
      return 0
   }

   ts_log_fine "$host: actual spool dir: $execd_config(execd_spool_dir)"
   ts_log_fine "$host: new spool dir   : $spool_dir"

   delete_all_jobs
   wait_for_end_of_all_jobs 60

   shutdown_system_daemon $host execd

   ts_log_fine "changing execd_spool_dir for host $host ..."
   set execd_config(execd_spool_dir) $spool_dir
   set_config execd_config $host
   ts_log_fine "configuration changed for host $host!"

   ts_log_fine "checking base spool dir: $base_spool_dir"
   if { [ remote_file_isdirectory $host $base_spool_dir ] != 1 } {
      ts_log_fine "creating not existing base spool directory:\n\"$base_spool_dir\""
      remote_file_mkdir $host $base_spool_dir
      wait_for_remote_dir $ts_config(master_host) $CHECK_USER $base_spool_dir
   }

   ts_log_fine "cleaning up spool dir $spool_dir ..."
   cleanup_spool_dir_for_host $host $base_spool_dir "execd"


   startup_execd $host

   wait_for_load_from_all_queues 100

   return 0
}


#                                                             max. column:     |
#****** sge_procedures/startup_shadowd() ******
#
#  NAME
#     startup_shadowd -- ???
#
#  SYNOPSIS
#     startup_shadowd { hostname }
#
#  FUNCTION
#     ???
#
#  INPUTS
#     hostname - ???
#
#  RESULT
#     ???
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
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#*******************************
proc startup_shadowd {hostname {env_list ""}} {
   global CHECK_ADMIN_USER_SYSTEM CHECK_USER CHECK_INSTALL_RC
   get_current_cluster_config_array ts_config

   if {$env_list != ""} {
      upvar $env_list envlist
   }

   if {$CHECK_ADMIN_USER_SYSTEM == 0} {
      if {[have_root_passwd] != 0} {
         ts_log_warning "no root password set or ssh not available"
         return -1
      }
      set startup_user "root"
   } else {
      set startup_user $CHECK_USER
   }

   # if we started qmaster on the master host via systemd, then sge_shadowd is also already running
   if {$CHECK_INSTALL_RC && [ge_has_feature "systemd"] && [host_has_systemd $hostname] && $hostname == $ts_config(master_host)} {
      return 0
   }

   ts_log_fine "starting up shadowd on host \"$hostname\" as user \"$startup_user\""

   set output [start_remote_prog "$hostname" "$startup_user" "$ts_config(product_root)/$ts_config(cell)/common/sgemaster" "-shadowd start" prg_exit_state 60 0 "" envlist]
   ts_log_fine $output
   if { [string first "starting sge_shadowd" $output] >= 0 } {
       if { [is_daemon_running $hostname "sge_shadowd"] == 1 } {
          return 0
       }
   }
   ts_log_severe "could not start shadowd on host $hostname:\noutput:\"$output\""
   return -1
}


#****** sge_procedures/check_shadowd_settings() *****************************
#  NAME
#     check_shadowd_settings() -- check if shadowd installation is supported
#
#  SYNOPSIS
#     check_shadowd_settings { shadowd_host }
#
#  FUNCTION
#     This function is used to find out if the specified shadowd can be installed
#     with the current testsuite/host settings
#
#  INPUTS
#     shadowd_host - name of shadowd host
#
#  RESULT
#     "" (empty string) if there are no problems
#     "some error text" - if there are problems
#*******************************************************************************
proc check_shadowd_settings { shadowd_host } {
   global CHECK_USER
   get_current_cluster_config_array ts_config
   set nr_shadowds [llength $ts_config(shadowd_hosts)]
   ts_log_fine "$nr_shadowds shadowd host configured ..."

   set fine 0
   set test_host [resolve_host $shadowd_host]
   foreach sd_host $ts_config(shadowd_hosts) {
      set sd_res_host [resolve_host $sd_host]
      if { $sd_res_host == $test_host } {
         set fine 1
         break
      }
   }

   if { $fine != 1 } {
      return "shadowd host $shadowd_host not defined in shadowd_hosts list of testsuite"
   }

   # one shadow is ok on master host
   if { $nr_shadowds == 1 } {
      set shadowd_host [resolve_host $ts_config(shadowd_hosts)]
      set master_host [resolve_host $ts_config(master_host)]
      ts_log_fine "shadowd: $shadowd_host"
      ts_log_fine "master:  $master_host"
      if { $master_host == $shadowd_host } {
         return ""
      } else {
         return "shadowd_host is not master_host! Please alter your testsuite configuration!"
      }
   }

   # we have more than one shadow host
   if { $nr_shadowds >= 2 } {
      set heartbeat_file [get_qmaster_spool_dir]/heartbeat
      set qmaster_lock_file [get_qmaster_spool_dir]/lock
      set qmaster_messages_file [get_qmaster_spool_dir]/messages
      set act_qmaster_file "$ts_config(product_root)/$ts_config(cell)/common/act_qmaster"
      set sgemaster_file $ts_config(product_root)/$ts_config(cell)/common/sgemaster

      # read act qmaster file
      if {[wait_for_remote_file $ts_config(master_host) $CHECK_USER $act_qmaster_file] == -1} {
         # act_qmaster_file didn't appear on the master host!
         return "$act_qmaster_file not found on host $ts_config(master_host)"
      }
      get_file_content $ts_config(master_host) $CHECK_USER $act_qmaster_file file_array
      set act_qmaster [string trim $file_array(1)]
      ts_log_fine "act_qmaster: \"$act_qmaster\""


      # read heartbeat file on qmaster host
      wait_for_remote_file $ts_config(master_host) $CHECK_USER $heartbeat_file
      get_file_content $ts_config(master_host) $CHECK_USER $heartbeat_file file_array
      set heartbeat1 [string trim $file_array(1)]
      set heartbeat1 [string trimleft $heartbeat1 "0"]
      ts_log_fine "heartbeat file read on host \"$ts_config(master_host)\": \"$heartbeat1\""

      # read heartbeat file on shadowd host
      wait_for_remote_file $test_host $CHECK_USER $heartbeat_file
      get_file_content $test_host $CHECK_USER $heartbeat_file file_array
      set heartbeat2 [string trim $file_array(1)]
      set heartbeat2 [string trimleft $heartbeat2 "0"]
      ts_log_fine "heartbeat file read on host \"$test_host\": \"$heartbeat2\""

      # diff the contents (allow max + 1)
      set heart_diff [expr ( $heartbeat2 - $heartbeat1 ) ]
      if { $heart_diff > 1 || $heart_diff < -1 } {
         return "heartbeat file diff error: heart_diff=$heart_diff - no nfs shared qmaster spool directory found"
      }

      # We need access to spooling data from shadow hosts, by
      # - classic spooling to a shared filesystem (to qmaster spooldir - if it was not shared,
      #   we would have failed earlier.
      # - bdb spooling with rpc server
      # - bdb spooling to nfsv4
      set spooling_ok 0
      if { $ts_config(spooling_method) == "classic" } {
         ts_log_fine "We have \"classic\" spooling to a shared qmaster spool dir."
         set spooling_ok 1
      } else {
         if {$ts_config(spooling_method) == "berkeleydb"} {
            set bdb_spooldir [get_bdb_spooldir]
            set fstype [fs_config_get_filesystem_type $bdb_spooldir $ts_config(master_host) 0]
            if {$fstype == "nfs4"} {
               ts_log_fine "We have \"berkeleydb\" spooling on NFS v4"
               set spooling_ok 1

            }
         }
      }

      if {!$spooling_ok} {
         return "Spooling database is not shared between master and shadow hosts"
      }
      return ""
   }
   return "some magic error"
}



#****** sge_procedures/startup_execd() ***********************************
#  NAME
#     startup_execd() -- start execd daemon
#
#  SYNOPSIS
#     startup_execd { hostname {envlist ""} {startup_user ""} }
#
#  FUNCTION
#     This procedure will startup the execd on the specified host. If the envlist
#     variable is set the tcl array specified by name is upvar'ed and used
#     as parameter for start_remote_prog() in order to setup the user environment
#     variables which should be set by the startup user. If the startup_user
#     is set the user specified will be the execd startup user.
#
#  INPUTS
#     hostname          - host where execd should be started
#     {envlist ""}      - optional: environment array used to set before starting
#     {startup_user ""} - optional: user who starts the execd
#
#  RESULT
#     0  on success
#     -1 on error
#
#  SEE ALSO
#     sge_procedures/shutdown_core_system()
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/shutdown_all_shadowd()
#     sge_procedures/shutdown_system_daemon()
#     sge_procedures/startup_qmaster()
#     sge_procedures/startup_execd()
#     sge_procedures/startup_shadowd()
#*******************************************************************************
proc startup_execd {hostname {envlist ""} {startup_user ""}} {
   get_current_cluster_config_array ts_config
   global CHECK_ADMIN_USER_SYSTEM CHECK_USER
   global CHECK_VALGRIND CHECK_VALGRIND_HOST CHECK_VALGRIND_LAST_DAEMON_RESTART
   global CHECK_INSTALL_RC

   upvar $envlist my_envlist

   if {$startup_user == ""} {
      if {$CHECK_ADMIN_USER_SYSTEM == 0} {
         if {[have_root_passwd] != 0} {
            ts_log_warning "no root password set or ssh not available"
            return -1
         }
         set startup_user "root"
      } else {
         set startup_user $CHECK_USER
      }
   }

   ts_log_fine "starting up execd on host \"$hostname\" as user \"$startup_user\""
   if {$envlist == "" && $CHECK_INSTALL_RC && [ge_has_feature "systemd"] && [host_has_systemd $hostname]} {
      ts_log_fine "  -> via systemd"
      set service_name [systemd_get_service_name "execd"]
      set output [start_remote_prog $hostname $startup_user "systemctl" "start $service_name"]
      if {$prg_exit_state != 0} {
         ts_log_severe "starting up sge_execd via systemd failed:\n$output"
      }
   } else {
      if {$CHECK_VALGRIND == "execution" && $CHECK_VALGRIND_HOST == $hostname} {
         ts_log_fine "  -> via valgrind wrapper"
         set method "valgrind wrapper"
         set CHECK_VALGRIND_LAST_DAEMON_RESTART [clock seconds]
         set arch [resolve_arch $hostname]
         set execd_cmd "$ts_config(product_root)/bin/$arch/sge_execd"
         set execd_args ""
      } else {
         ts_log_fine "  -> via sgeexecd script"
         set method "sgeexecd script"
         set execd_cmd "$ts_config(product_root)/$ts_config(cell)/common/sgeexecd"
         set execd_args "start"
      }

      set output [start_remote_prog $hostname $startup_user $execd_cmd $execd_args prg_exit_state 60 0 "" my_envlist 1 0]
      if {$prg_exit_state != 0} {
         ts_log_severe "starting up sge_execd via $method failed:\n$output"
      }
   }

   return 0
}

#****** sge_procedures/startup_execd_with_fd_limit() ************************
#  NAME
#     startup_execd_with_fd_limit() -- startup execution daemon
#
#  SYNOPSIS
#     startup_execd_with_fd_limit { host fd_limit {envlist ""} }
#
#  FUNCTION
#     This procedure is used to startup an execution daemon of Cluster Scheduler (Grid Engine)
#     with special file descriptor limit settings.
#
#  INPUTS
#     host         - host where to start an execd
#     fd_limit     - file descriptor limit value
#     {envlist ""} - additional user environment variables to set
#
#  RESULT
#     The parsed output value of ulimit -Sn call which is the used
#     soft file descriptor limit setting before starting the execd.
#
#  SEE ALSO
#     sge_host/get_FD_SETSIZE_for_host()
#     sge_host/get_shell_fd_limit_for_host()
#     sge_procedures/startup_execd_with_fd_limit()
#*******************************************************************************
proc startup_execd_with_fd_limit { host fd_limit {envlist ""}} {
   global CHECK_ADMIN_USER_SYSTEM
   global CHECK_USER
   get_current_cluster_config_array ts_config
   upvar $envlist my_envlist

   set used_fd_limit -1
   set arch [resolve_arch $host]
   set execd_bin "$ts_config(product_root)/bin/$arch/sge_execd"


   if {$CHECK_ADMIN_USER_SYSTEM == 0} {
      if {[have_root_passwd] != 0} {
         ts_log_warning "no root password set or ssh not available"
         return -1
      }
      set startup_user "root"
   } else {
      set startup_user $CHECK_USER
   }

   ts_log_fine "starting up execd on host \"$host\" as user \"$startup_user\" with file descriptor limit set to \"$fd_limit\" ..."

   set startup_arguments "-Hn $fd_limit ; ulimit -Sn $fd_limit ; echo \"--ulimit-output--\" ; ulimit -Sn ; $execd_bin ; sleep 2"
   set output [start_remote_prog "$host" "$startup_user" "ulimit" $startup_arguments prg_exit_state 60 0 $ts_config(product_root) my_envlist]

   if {$prg_exit_state != 0} {
      ts_log_severe "starting execd on host $host as user $startup_user returned $prg_exit_state\noutput:\n$output"
   }

   set found 0
   foreach line [split $output "\n"] {
      if {$found == 1} {
         set used_fd_limit [string trim $line]
         break
      }
      if {[string match "*--ulimit-output--*" $line]} {
         set found 1
      }
   }
   ts_log_fine "execd started with fd soft limit set to \"$used_fd_limit\""

   return $used_fd_limit
}

#                                                             max. column:     |
#****** sge_procedures/get_urgency_job_info() ******
#
#  NAME
#     get_urgency_job_info -- get urgency job information (qstat -urg)
#
#  SYNOPSIS
#     get_urgency_job_info { jobid {variable job_info} }
#
#  FUNCTION
#     This procedure is calling the qstat (qstat -urg if sgeee) and returns
#     the output of the qstat in array form.
#
#  INPUTS
#     jobid               - job identifaction number
#     {variable job_info} - name of variable array to store the output
#     {do_replace_NA}     - 1 : if not set, don't replace NA settings
#
#  RESULT
#     0, if job was not found
#     1, if job was found
#
#     fills array $variable with info found in qstat output with the following symbolic names:
#
#     job-ID prior nurg urg rrcontr wtcontr  dlcontr name  user state submit/start at
#     deadline queue slots ja-task-ID

#
#  EXAMPLE
#  proc testproc ... {
#     ...
#     if {[get_urgency_job_info $job_id] } {
#        if { $job_info(urg) < 10 } {
#           ...
#        }
#     } else {
#        ts_log_severe "get_urgency_job_info failed for job $job_id on host $host"
#     }
#     ...
#  }
#
#  SEE ALSO
#     sge_procedures/get_job_info()
#     sge_procedures/get_standard_job_info()
#     sge_procedures/get_extended_job_info()
#*******************************
proc get_urgency_job_info {jobid {variable job_info} { do_replace_NA 1 } } {
   get_current_cluster_config_array ts_config
   upvar $variable jobinfo
   set myenv(SGE_LONG_QNAMES) 50
   set result [start_sge_bin "qstat" "-urg" "" "" prg_exit_state 60 "" "bin" output_lines myenv]
   if {$prg_exit_state == 0} {
      parse_qstat result jobinfo $jobid 2 $do_replace_NA
      return 1
   }
   return 0
}

#****** sge_procedures/drmaa_redirect_lib() *********************************
#  NAME
#     drmaa_redirect_lib() -- change drmaa lib version
#
#  SYNOPSIS
#     drmaa_redirect_lib { version host }
#
#  FUNCTION
#     This function re-links the drmaa library for the specified host to
#     the specified version.
#
#  INPUTS
#     version           - "0.95" or "1.0"
#     host              - hostname
#
#  SEE ALSO
#     sge_procedures/get_current_drmaa_lib_extension()
#     sge_procedures/drmaa_redirect_lib()
#     sge_procedures/get_current_drmaa_mode()
#*******************************************************************************
proc drmaa_redirect_lib {version host} {
   global CHECK_USER ts_config
   ts_log_fine "Using DRMAA version $version on $host"

   set install_arch [resolve_arch $host]
   set lib_ext [get_current_drmaa_lib_extension $host]
   set fileserver_host [fs_config_get_server_for_path "$ts_config(product_root)/lib/$install_arch/"]

   # delete link on remote file server
   if {[is_remote_file $fileserver_host "root" "$ts_config(product_root)/lib/$install_arch/libdrmaa.$lib_ext"] == 1} {
      start_remote_prog $fileserver_host "root" "rm" "$ts_config(product_root)/lib/$install_arch/libdrmaa.$lib_ext"
   }
   # check if file exists on client side because of NFS timing issues
   if {[is_remote_file $host $CHECK_USER "$ts_config(product_root)/lib/$install_arch/libdrmaa.$lib_ext"] == 1} {
      # wait for link on client host to go away (because of timing issues)
      wait_for_remote_file $host $CHECK_USER "$ts_config(product_root)/lib/$install_arch/libdrmaa.$lib_ext" 120 1 1
   }
   # create link on fileserver
   start_remote_prog $fileserver_host "root" "ln" "-s $ts_config(product_root)/lib/$install_arch/libdrmaa.$lib_ext.$version $ts_config(product_root)/lib/$install_arch/libdrmaa.$lib_ext"

   # wait for link on client host
   wait_for_remote_file $host $CHECK_USER "$ts_config(product_root)/lib/$install_arch/libdrmaa.$lib_ext" 120

}

#****** sge_procedures/get_current_drmaa_mode() *****************************
#  NAME
#     get_current_drmaa_mode() -- return the current drmaa version string
#
#  SYNOPSIS
#     get_current_drmaa_mode { host }
#
#  FUNCTION
#     Return the current linked drmaa library version string.
#
#  INPUTS
#     host - hostname
#
#  RESULT
#     string containting the version information from the libdrmaa link extention
#     (currently "0.95" or "1.0")
#
#  SEE ALSO
#     sge_procedures/get_current_drmaa_lib_extension()
#     sge_procedures/drmaa_redirect_lib()
#     sge_procedures/get_current_drmaa_mode()
#*******************************************************************************
proc get_current_drmaa_mode { host } {
   global ts_config
   ts_log_fine "checking DRMAA version on $host ..."

   set install_arch [resolve_arch $host]

   set files [get_file_names "$ts_config(product_root)/lib/$install_arch" "*drmaa*"]
   foreach file_base $files {
      set file "$ts_config(product_root)/lib/$install_arch/$file_base"
      set file_type [file type $file]
      ts_log_fine "$file_type: $file"
      if { $file_type == "link" } {
         set linked_to [file readlink $file]
         ts_log_fine "found drmaa lib link: $file_base -> $linked_to"
         ts_log_fine "lib is linked to $linked_to"
         set version_pos [string first "." $linked_to]
         incr version_pos 1
         set linked_to [string range $linked_to $version_pos end]
         set version_pos [string first "." $linked_to]
         incr version_pos 1
         set version [string range $linked_to $version_pos end ]
         ts_log_fine "version extension is \"$version\""
         return $version
      }
   }
}

#****** sge_procedures/get_current_drmaa_lib_extension() ********************
#  NAME
#     get_current_drmaa_lib_extension() -- get link extention name for the host
#
#  SYNOPSIS
#     get_current_drmaa_lib_extension { host }
#
#  FUNCTION
#     Find out the host specific dynamic link extention (e.g. "so" or "dylib")
#
#  INPUTS
#     host - host for which the information is needed
#
#  RESULT
#     string containing the lib extention (e.g. "so")
#
#  SEE ALSO
#     sge_procedures/get_current_drmaa_lib_extension()
#     sge_procedures/drmaa_redirect_lib()
#     sge_procedures/get_current_drmaa_mode()
#*******************************************************************************
proc get_current_drmaa_lib_extension { host } {
   global ts_config
   set install_arch [resolve_arch $host]
   set files [get_file_names "$ts_config(product_root)/lib/$install_arch" "*drmaa*"]
   foreach file_base $files {
      set file "$ts_config(product_root)/lib/$install_arch/$file_base"
      set file_type [file type $file]
      #Let's skip all links, we just want the real library extension
      if { $file_type == "link" } {
         continue
      }
      ts_log_fine "DRMMA lib is $file"
      set pos [string first "." $file]
      set lib_ext [string range $file [expr $pos + 1] end]
      set pos [string first "." $lib_ext]
      if { $pos != -1 } {
         set lib_ext [string range $lib_ext 0 [expr $pos - 1]]
      }
      ts_log_fine "lib extension is \"$lib_ext\""
      return $lib_ext
   }
}


# get_daemon_pid -- retrieves running daemon pid on remote host
proc get_daemon_pid { host service } {
   global CHECK_USER

   switch -exact $service {
      "master" -
      "qmaster" {
    return [get_qmaster_pid $host [get_qmaster_spool_dir]]
      }
      "shadow" -
      "shadowd" {
    return [get_shadowd_pid $host [get_qmaster_spool_dir]]
      }
      "execd" {
         return [get_execd_pid $host]
      }
      "bdb" {
    ts_log_severe "NOT IMPLEMENTED"
      }
      "dbwriter" {
    ts_log_severe "NOT IMPLEMENTED"
      }
      default {
    ts_log_severe "Invalid service $service passed to get_daemon_pid{}"
      }
   }
}
#****** sge_procedures/shutdown_and_restart_qmaster() ********************
#  NAME
#     shutdown_and_restart_qmaster() -- Shutdown the qmaster and scheduler
#     if possible
#
#  SYNOPSIS
#     shutdown_and_restart_qmaster { host }
#
#  FUNCTION
#     Shuts the qmaster and scheduler (if version >= 62) proc down and
#     restarts it.
#
#  INPUTS
#
#  RESULT
#     A newly restarted qmaster as side effect.
#
#  SEE ALSO
#     sge_procedures/shutdown_master_and_scheduler()
#     sge_procedures/startup_qmaster()
#*******************************************************************************

proc shutdown_and_restart_qmaster {} {
   global ts_config

   shutdown_master_and_scheduler $ts_config(master_host) [get_qmaster_spool_dir]
   # sometimes the socket can not be re-used immediately
   after 1000
   # startup qmaster with scheduler (if possible)
   startup_qmaster 1
}


proc call_startup_script { host service {script_file ""} {args ""} { timeout 30 } } {
   global ts_config CHECK_USER CHECK_ADMIN_USER_SYSTEM

   set ret 0

   if {[string compare $args "start"] == 0} {
      set msg "Starting"
   } elseif {[string compare $args "stop"] == 0} {
      set msg "Stopping"
   }

   if {[string length $script_file] == 0} {
      switch -exact $service {
         "master" -
         "qmaster" {
            set service "qmaster"
            set script_file "$ts_config(product_root)/$ts_config(cell)/common/sgemaster"
            set args "-$service $args"
         }
         "shadow" -
         "shadowd" {
            set service "shadowd"
            set script_file "$ts_config(product_root)/$ts_config(cell)/common/sgemaster"
            set args "-$service $args"
         }
         "execd" -
         "bdb" -
         "dbwriter" {
            set script_file "$ts_config(product_root)/$ts_config(cell)/common/sge$service"
         }
         default {
            ts_log_severe "Invalid service $service in smf_call_stop_script_and_restart{}"
         }
      }
   }

   if { $CHECK_ADMIN_USER_SYSTEM == 0 } {
      if { [have_root_passwd] != 0  } {
         ts_log_warning "no root password set or ssh not available"
         return -1
      }
      set user "root"
   } else {
      set user $CHECK_USER
   }
   ts_log_fine "$msg $service: '$script_file $args' on host $host as user $user ..."
   set output [start_remote_prog $host $user "$script_file" "$args"]
   ts_log_fine "$output"
   if { $prg_exit_state != 0 } {
      ts_log_severe "Operation failed for $service service!"
      return -1
   }
   return 0
}

###
# @brief add a value to a configuration attribute
#
# The function can be used to add an attribute to a list in configurations, e.g.
#    - complex_values in exec hosts
#    - qmaster_params in the global config
#    - ...
#
# @param[in] old_conf_var - configuration array of the current object (e.g. from get_exechost)
# @param[in] new_conf_var - configuration array which will hold the modified object (to be passed e.g. to set_exechost)
# @param[in] attrib - the name of the configuration attribute, e.g. "complex_values"
# @param[in] value - the value to be set, e.g. "my_int_complex=4"
# @param[in] delimiter - the delimiter within the config list, default is the comma (",")
#
# @todo also do an add_or_replace_config_attribute function
# @todo also do a del_config_attribute function
##
proc add_to_config_attribute {old_conf_var new_conf_var attrib value {delimiter ","}} {
   upvar $old_conf_var old_conf
   upvar $new_conf_var new_conf

   if {[string compare -nocase $old_conf($attrib) "none"] == 0} {
      set new_conf($attrib) $value
   } else {
      set new_conf($attrib) $old_conf($attrib)
      append new_conf($attrib) $delimiter
      append new_conf($attrib) $value
   }
}

###
# @brief get the systemd service name for a given service
#
# @param[in] service - the name of the service, e.g. "execd", "qmaster", ...
# @return the systemd service name, e.g. "ocs6444-execd.service"
#
proc systemd_get_service_name {service} {
   get_current_cluster_config_array ts_config

   set service_name "ocs"
   append service_name $ts_config(commd_port)
   append service_name "-$service"
   append service_name ".service"

   return $service_name
}

###
# @brief get the path to the systemd unit file for a given service name
#
# @param[in] service_name - the name of the service, e.g. "ocs6444-execd.service"
#
proc systemd_get_unit_path {service_name} {
   return "/etc/systemd/system/$service_name"
}

###
# @brief remove OCS from the init system of a host
#
# We shutdown, disable and remove the services for qmaster and execd.
#
# @param[in] host - the host to remove the services from
#
proc remove_from_init_system {host} {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   global CHECK_INSTALL_RC

   # @todo differentiate between the various init systems
   if {$CHECK_INSTALL_RC && [host_has_systemd $host]} {
      ts_log_frame
      ts_log_fine "removing services from init system on host $host"
      set services "qmaster execd"
      foreach service $services {
         set service_name [systemd_get_service_name $service]
         ts_log_fine "   -> $service_name"
         set output [start_remote_prog $host "root" "systemctl" "status $service_name"]
         ts_log_finer $output
         # 0 program is running or service is OK
         # 1 program is dead and /var/run pid file exists
         # 2 program is dead and /var/lock lock file exists
         # 3 program is not running
         # 4 program or service status is unknown
         # 5-99  reserved for future LSB use
         # 100-149   reserved for distribution use
         # 150-199   reserved for application use
         # 200-254   reserved
         if {$prg_exit_state != 4} {
            # service exists - stop it
            if {[systemd_is_service_active $host $service]} {
               # service is running
               systemd_stop_service $host $service
            }
            # service is enabled - disable it
            set output [start_remote_prog $host "root" "systemctl" "is-enabled $service_name"]
            if {$prg_exit_state == 0} {
               # service is running
               set output [start_remote_prog $host "root" "systemctl" "disable $service_name"]
               ts_log_finer $output
            }
            # remove the service
            set unit_path [systemd_get_unit_path $service_name]
            set output [start_remote_prog $host "root" "rm" "-f $unit_path"]
            ts_log_finer $output
            set output [start_remote_prog $host "root" "systemctl" "daemon-reload"]
            ts_log_finer $output
         }
      }
   }
}

###
# @brief remove all cluster hosts from the init system
#
# This function will remove all cluster hosts from the init system.
# It is called when testsuite was started with option "install_rc"
# before building/installing new binaries and when exiting testsuite.
#
proc remove_cluster_hosts_from_init_system {} {
   get_current_cluster_config_array ts_config

   set hosts [concat $ts_config(master_host) $ts_config(shadowd_hosts) $ts_config(execd_nodes)]
   set hosts [lsort -unique $hosts]
   foreach host $hosts {
      remove_from_init_system $host
   }
}

###
# @brief remove all configured hosts from the init system
#
# This function will remove all hosts from the init system
# which are contained in the testsuite host configuration.
# It is called from the testsuite cleanup menu (34, item 4).
#
proc remove_all_hosts_from_init_system {} {
   get_current_cluster_config_array ts_config
   global ts_host_config

   set hosts [host_conf_get_all_nodes $ts_host_config(hostlist)]
   foreach host $hosts {
      remove_from_init_system $host
   }
}

proc systemd_is_service_active {host service} {
   set service_name [systemd_get_service_name $service]
   set ret 0
   set output [start_remote_prog $host "root" "systemctl" "is-active $service_name"]
   if {$prg_exit_state == 0} {
      set ret 1
   }

   return $ret
}

# @todo add functions for is-enabled, ...

proc systemd_stop_service {host service {raise_error 1}} {
   set ret 1
   set service_name [systemd_get_service_name $service]
   set output [start_remote_prog $host "root" "systemctl" "stop $service_name"]
   if {$prg_exit_state != 0} {
      ts_log_severe "systemctl stop $service_name on host $host failed:\n$output"
      set ret 0
   } else {
      ts_log_fine "systemctl stop $service_name on host $host exited 0:\n$output"
   }

   return $ret
}

# @todo add functions for start, enable, disable, ...
