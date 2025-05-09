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
#****** sge_procedures/reset_schedd_config() ******
# 
#  NAME
#     reset_schedd_config -- set schedd configuration default values
#
#  SYNOPSIS
#     reset_schedd_config { } 
#
#  FUNCTION
#     This procedure will call set_schedd_config with default values 
#
#  RESULT
#       -1 : timeout error
#        0 : ok
#
#
#  NOTES
#     The default values are:
#     
#     SGE system:
#    
#     algorithm                   "default"
#     schedule_interval           "0:0:10"
#     maxujobs                    "0"
#     queue_sort_method           "load"
#     user_sort                   "false"
#     job_load_adjustments        "np_load_avg=0.50"
#     load_adjustment_decay_time  "0:7:30"
#     load_formula                "np_load_avg"
#     schedd_job_info             "true", "false" since 62
#     
#     
#     SGEEE differences:
#     queue_sort_method           "share"
#     user_sort                   "false"
#     reprioritize_interval       "00:01:00"
#     halftime                    "168"
#     usage_weight_list           "cpu=1,mem=0,io=0"
#     compensation_factor         "5"
#     weight_user                 "0.2"
#     weight_project              "0.2"
#     weight_jobclass             "0.2"
#     weight_department           "0.2"
#     weight_job                  "0.2"
#     weight_tickets_functional   "0"
#     weight_tickets_share        "0"
#     weight_tickets_deadline     "10000"
#
#  SEE ALSO
#     sge_procedures/set_schedd_config()
#*******************************
proc reset_schedd_config {} {
   get_current_cluster_config_array ts_config

   set default_array(algorithm)                       "default"
   set default_array(schedule_interval)               "0:0:10"
   set default_array(maxujobs)                        "0"
   set default_array(job_load_adjustments)            "np_load_avg=0.15"
   set default_array(load_adjustment_decay_time)      "0:7:30"
   set default_array(load_formula)                    "np_load_avg"
   set default_array(schedd_job_info)                 "false"

   set default_array(flush_submit_sec)                "1"
   set default_array(flush_finish_sec)                "1"
   set default_array(params)                          "none"
   set default_array(reprioritize_interval)           "00:00:00"

   set default_array(halftime)                        "168"
   set default_array(usage_weight_list)               "cpu=1,mem=0,io=0"
   set default_array(compensation_factor)             "5"
   set default_array(weight_user)                     "0.25"
   set default_array(weight_project)                  "0.25"
   set default_array(weight_department)               "0.25"
   set default_array(weight_job)                      "0.25"
   set default_array(weight_tickets_functional)       "0"
   set default_array(weight_tickets_share)            "0"
   set default_array(share_override_tickets)          "true"
   set default_array(share_functional_shares)         "true"
   set default_array(max_functional_jobs_to_schedule) "200"
   set default_array(report_pjob_tickets)             "true"
   set default_array(max_pending_tasks_per_job)       "50"
   set default_array(halflife_decay_list)             "none"
   set default_array(policy_hierarchy)                "OFS"

   set default_array(weight_ticket)                   "0.010000"
   set default_array(weight_waiting_time)             "0.000000"
   set default_array(weight_deadline)                 "3600000"
   set default_array(weight_urgency)                  "0.100000"
   set default_array(weight_priority)                 "1.000000"
   set default_array(max_reservation)                 "0"
   set default_array(default_duration)                "INFINITY"

   vdep_set_sched_conf_defaults default_array

   return [set_schedd_config default_array]
}

# STUB for version dependent scheduler config settings
# put it into sge_sched_conf.<version>.tcl
proc vdep_set_sched_conf_defaults {change_array} {
#   get_current_cluster_config_array ts_config
#   upvar $change_array chgar

#   set chgar(flush_submit_sec)        "0"
#   set chgar(flush_finish_sec)        "0"
}

#                                                             max. column:     |
#****** sge_procedures/set_schedd_config() ******
# 
#  NAME
#     set_schedd_config -- change scheduler configuration
#
#  SYNOPSIS
#     set_schedd_config { change_array {fast_add 1} {on_host ""} {as_user ""} {raise_error 1} } 
#
#  FUNCTION
#     Set the scheduler configuration corresponding to the content of the 
#     change_array.
#
#  INPUTS
#     change_array - name of an array variable that will be set by 
#                    set_schedd_config
#     {fast_add 1} - 0: modify the attribute using qconf -mckpt,
#                  - 1: modify the attribute using qconf -Mckpt, faster
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#  RESULT
#     -1 : timeout
#      0 : ok
#
#  EXAMPLE
#     get_schedd_config myconfig
#     set myconfig(schedule_interval) "0:0:10"
#     set_schedd_config myconfig
#
#  NOTES
#     The array should be build like follows:
#   
#     set change_array(algorithm) default
#     set change_array(schedule_interval) 0:0:15
#     ....
#     (every value that is set will be changed)
#
#     Here the possible change_array values with some typical settings:
#     
#     algorithm                   "default"
#     schedule_interval           "0:0:15"
#     maxujobs                    "0"
#     queue_sort_method           "share"
#     user_sort                   "false"
#     job_load_adjustments        "np_load_avg=0.50"
#     load_adjustment_decay_time  "0:7:30"
#     load_formula                "np_load_avg"
#     schedd_job_info             "true"
#     
#     
#     In case of a SGEEE - System:
#     
#     reprioritize_interval       "00:01:00"
#     halftime                    "168"
#     usage_weight_list           "cpu=0.34,mem=0.33,io=0.33"
#     compensation_factor         "5"
#     weight_user                 "0"
#     weight_project              "0"
#     weight_jobclass             "0"
#     weight_department           "0"
#     weight_job                  "0"
#     weight_tickets_functional   "0"
#     weight_tickets_share        "0"
#     weight_tickets_deadline     "10000"
#     
#
#  SEE ALSO
#     sge_procedures/get_schedd_config()
#*******************************

proc set_schedd_config { change_array {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
  global env
  get_current_cluster_config_array ts_config

  upvar $change_array chgar

  # Modify sched from file?
   if {$fast_add} {
      get_schedd_config old_config $on_host $as_user
      foreach elem [array names chgar] {
         set old_config($elem) "$chgar($elem)"
      }

      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile old_config $on_host]
      set ret [start_sge_bin "qconf" "-Msconf $tmpfile" $on_host $as_user ]

      if {$prg_exit_state == 0} {
         set result 0
      } else {
         set result [set_schedd_config_error $ret $tmpfile $raise_error]
      }

   } else {

      set vi_commands [build_vi_command chgar]
      set CHANGED_SCHEDD_CONFIG [translate_macro MSG_SCHEDD_CHANGEDSCHEDULERCONFIGURATION ]
      set NOTULONG [translate_macro MSG_OBJECT_VALUENOTULONG_S "*" ]
      set ADDNOTULONG [translate_macro MSG_MUST_BE_POSITIVE_VALUE_S "*"]
      set master_arch [resolve_arch $ts_config(master_host)]
      set result [handle_vi_edit "$ts_config(product_root)/bin/$master_arch/qconf" "-msconf" $vi_commands $CHANGED_SCHEDD_CONFIG $NOTULONG $ADDNOTULONG]
      if { $result == -1 } { 
         ts_log_severe "timeout error" $raise_error 
      } elseif { $result == -2 } { 
         ts_log_severe "not a u_long32 value" $raise_error
      } elseif { $result == -3 } { 
         ts_log_severe "must be positive" $raise_error
      } elseif { $result != 0 } { 
         ts_log_severe "error changing scheduler configuration" $raise_error
      }
   }
  return $result
}

#****** sge_sched_conf/set_schedd_config_error() ***************************************
#  NAME
#     set_schedd_config_error() -- error handling for set_schedd_config
#
#  SYNOPSIS
#     set_schedd_config_error { result tmpfile raise_error }
#
#  FUNCTION
#     Does the error handling for set_schedd_config.
#     Translates possible error messages of qconf -Msconf,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     set_schedd_config. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     tmpfile     - temp file for qconf -Msconf
#     raise_error - raise error condition in case of errors
#
#  RESULT
#     Returncode for set_exechost function:
#      -1: "something" does not exist
#     -99: other error
#
#  SEE ALSO
#     sge_calendar/get_calendar
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc set_schedd_config_error {result tmpfile raise_error} {
   get_current_cluster_config_array ts_config
   # build up needed vars
   set messages(index) "-1"
   set messages(-1)  [translate_macro MSG_OBJECT_VALUENOTULONG_S "*" ]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "set_exechost" "qconf -Msconf $tmpfile" $result messages $raise_error]

  return $ret
}


#****** sge_sched_config/mod_schedd_config() ******
#
#  NAME
#     mod_schedd_config -- Wrapper around set_schedd_config
#
#  SYNOPSIS
#     mod_schedd_config { change_array {fast_add 1} {on_host ""} {as_user ""} {raise_error 1 } }
#
#  FUNCTION
#     See set_exechost
#
#  INPUTS
#     change_array - name of an array variable that will be set by set_schedd_config
#     {fast_add 1} - 0: modify the attribute using qconf -msconf,
#                  - 1: modify the attribute using qconf -Msconf, faster
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  SEE ALSO
#     sge_host/get_exechost()
#*******************************
proc mod_schedd_config { change_array {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $change_array chgar
   ts_log_fine "Using mod_schedd_config as wrapper for set_schedd_config \n"

   return [set_schedd_config chgar $fast_add $on_host $as_user $raise_error]

}

#                                                             max. column:     |
#****** sge_procedures/get_schedd_config() ******
# 
#  NAME
#     get_schedd_config -- get scheduler configuration 
#
#  SYNOPSIS
#     get_schedd_config { change_array } 
#
#  FUNCTION
#     Get the current scheduler configuration     
#
#  INPUTS
#     change_array - name of an array variable that will get set by 
#                    get_schedd_config
#     {on_host ""}      - execute qconf on this host (default: qmaster host)
#     {as_user ""}      - execute qconf as this user (default: CHECK_USER)
#     {raise_error 1}   - raise error condition in case of errors?
#
#  EXAMPLE
#     get_schedd_config test
#     puts $test(schedule_interval)
#
#  NOTES
# 
#     The array is build like follows:
#   
#     set change_array(algorithm) default
#     set change_array(schedule_interval) 0:0:15
#     ....
#
#     Here the possible change_array values with some typical settings:
#     
#     algorithm                   "default"
#     schedule_interval           "0:0:15"
#     maxujobs                    "0"
#     queue_sort_method           "share"
#     user_sort                   "false"
#     job_load_adjustments        "np_load_avg=0.50"
#     load_adjustment_decay_time  "0:7:30"
#     load_formula                "np_load_avg"
#     schedd_job_info             "true"
#     
#     
#     In case of a SGEEE - System:
#     
#     reprioritize_interval       "00:01:00"
#     halftime                    "168"
#     usage_weight_list           "cpu=0.34,mem=0.33,io=0.33"
#     compensation_factor         "5"
#     weight_user                 "0"
#     weight_project              "0"
#     weight_jobclass             "0"
#     weight_department           "0"
#     weight_job                  "0"
#     weight_tickets_functional   "0"
#     weight_tickets_share        "0"
#     weight_tickets_deadline     "10000"
#
#  SEE ALSO
#     sge_procedures/set_schedd_config()
#*******************************
proc get_schedd_config { change_array {on_host ""} {as_user ""} {raise_error 1} } {
  get_current_cluster_config_array ts_config
  upvar $change_array chgar

   if {[info exists chgar]} {
      unset chgar
   }

  set result [start_sge_bin "qconf" "-ssconf" $on_host $as_user]
  if {$prg_exit_state != 0} {
     ts_log_severe "qconf -ssconf failed:\n$result"
     return
  }

  # split each line as listelement
  set help [split $result "\n"]

  foreach elem $help {
     if {$elem == ""} {
        continue
     }
     set id [lindex $elem 0]
     set value [lrange $elem 1 end]
     set chgar($id) $value
  }
}

#****** sge_sched_conf/set_schedd_config_from_file() ***************************
#  NAME
#     set_schedd_config_from_file() -- ??? 
#
#  SYNOPSIS
#     set_schedd_config_from_file { filename {on_host ""} {as_user ""} 
#     {raise_error 1} } 
#
#  FUNCTION
#     ??? 
#
#  INPUTS
#     filename        - ??? 
#     {on_host ""}    - ??? 
#     {as_user ""}    - ??? 
#     {raise_error 1} - ??? 
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
proc set_schedd_config_from_file {filename {on_host ""} {as_user ""} {raise_error 1}} {
   set result [start_sge_bin "qconf" "-Msconf $filename"]
   if {$prg_exit_state != 0} {
      ts_log_severe "qconf -Msconf $filename failed:\n$result" $raise_error
      return 0
   }

   return 1
}
