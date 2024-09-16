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

#****** sge_queue/set_queue_defaults() *****************************************
#  NAME
#     set_queue_defaults() -- create version dependent queue settings
#
#  SYNOPSIS
#     set_queue_defaults {change_array}
#
#  FUNCTION
#     Fills the array change_array with queue attributes for the specific 
#     version of SGE.
#
#  INPUTS
#     change_array - the resulting array
#
#*******************************************************************************
proc set_queue_defaults { change_array } {
   get_current_cluster_config_array ts_config
   upvar $change_array chgar

   set chgar(qname)                "template"
   set chgar(seq_no)               "0"
   set chgar(load_thresholds)      "np_load_avg=1.75"
   set chgar(suspend_thresholds)   "NONE"
   set chgar(nsuspend)             "1"
   set chgar(suspend_interval)     "00:05:00"
   set chgar(priority)             "0"
   set chgar(min_cpu_interval)     "00:05:00"
   set chgar(processors)           "UNDEFINED"
   set chgar(rerun)                "FALSE"
   set chgar(slots)                "1"
   set chgar(tmpdir)               "/tmp"
   if {[is_version_in_range "9.0.0"]} {
      set chgar(shell)                "/bin/sh"
      set chgar(shell_start_mode)     "unix_behavior"
   } else {
      set chgar(shell)                "/bin/csh"
      set chgar(shell_start_mode)     "posix_compliant"
   }
   set chgar(prolog)               "NONE"
   set chgar(epilog)               "NONE"
   set chgar(starter_method)       "NONE"
   set chgar(suspend_method)       "NONE"
   set chgar(resume_method)        "NONE"
   set chgar(terminate_method)     "NONE"
   set chgar(notify)               "00:00:60"
   set chgar(owner_list)           "NONE"
   set chgar(user_lists)           "NONE"
   set chgar(xuser_lists)          "NONE"
   set chgar(subordinate_list)     "NONE"
   set chgar(complex_values)       "NONE"
   set chgar(calendar)             "NONE"
   set chgar(initial_state)        "default"
   set chgar(s_rt)                 "INFINITY"
   set chgar(h_rt)                 "INFINITY"
   set chgar(s_cpu)                "INFINITY"
   set chgar(h_cpu)                "INFINITY"
   set chgar(s_fsize)              "INFINITY"
   set chgar(h_fsize)              "INFINITY"
   set chgar(s_data)               "INFINITY"
   set chgar(h_data)               "INFINITY"
   set chgar(s_stack)              "INFINITY"
   set chgar(h_stack)              "INFINITY"
   set chgar(s_core)               "INFINITY"
   set chgar(h_core)               "INFINITY"
   set chgar(s_rss)                "INFINITY"
   set chgar(h_rss)                "INFINITY"
   set chgar(s_vmem)               "INFINITY"
   set chgar(h_vmem)               "INFINITY"

   set chgar(hostlist)             "NONE"
   set chgar(qtype)                "BATCH INTERACTIVE"
   set chgar(ckpt_list)            "NONE"
   set chgar(pe_list)              "make"

   if {$ts_config(product_type) == "sgeee"} {
      set chgar(projects)           "NONE"
      set chgar(xprojects)          "NONE"
   }

}

#****** sge_queue/set_lab_defaults() *******************************************
#  NAME
#     set_lab_defaults() -- adjust the default queue settings
#
#  SYNOPSIS
#     set_lab_defaults {change_array}
#
#  FUNCTION
#     Adjust the default queue settings needed to run the tests in our lab 
#     properly.
#
#  INPUTS
#     change_array - the resulting array
#
#*******************************************************************************
proc set_lab_defaults {change_array} {
   get_current_cluster_config_array ts_config
   upvar $change_array chgar
   
   set chgar(load_thresholds)      "np_load_avg=7.00"
   set chgar(slots)                "10"

}

proc get_queue_tmpdir {} {
   get_current_cluster_config_array ts_config
   
   return "/tmp/testsuite_$ts_config(commd_port)"
}

#****** sge_queue/validate_queue() *********************************************
#  NAME
#     validate_queue() -- validate the queue settings
#
#  SYNOPSIS
#     validate_queue {change_array}
#
#  FUNCTION
#     Validate the queue settings. Adjust the queue settings according to sge 
#     version.
#
#  INPUTS
#     change_array - the resulting array
# 
#*******************************************************************************
proc validate_queue {change_array} {
   get_current_cluster_config_array ts_config
   upvar $change_array chgar
   
   # create cluster dependent tmpdir
   set chgar(tmpdir) [get_queue_tmpdir]

   vdep_validate_queue chgar
}

#****** sge_queue/add_queue() **************************************************
# 
#  NAME
#     add_queue -- Add a new queue configuration object
#
#  SYNOPSIS
#     add_queue {qname hostlist {change_array ""} {fast_add 1} {on_host ""} 
#     {as_user ""} {raise_error 1}} 
#
#  FUNCTION
#     Add a new queue configuration object corresponding to the content of 
#     the change_array.
#     Supports fast (qconf -Aq) and slow (qconf -aq) mode.
#
#  INPUTS
#     q_name        - queue name
#     hostlist      - the list of hosts
#     {change_array ""} - the queue description
#     {fast_add 1}    - use fast mode
#     {on_host ""}    - execute qconf on this host (default: qmaster host)
#     {as_user ""}    - execute qconf as this user (default: CHECK_USER)
#     {raise_error 1} - raise error condition in case of errors?
#
#  RESULT
#       0 - success
#     < 0 - error
#
#  SEE ALSO
#     sge_procedures/handle_sge_error()
#     sge_project/get_queue_messages()
#*******************************************************************************
proc add_queue {qname hostlist {change_array ""} {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   get_current_cluster_config_array ts_config

   upvar $change_array chgar

   set chgar(qname)     "$qname"
   set chgar(hostlist) $hostlist
   validate_queue chgar

   get_queue_messages messages "add" "$qname" $on_host $as_user

   if {$fast_add} {
      ts_log_fine "Add queue $chgar(qname) for hostlist $chgar(hostlist) from file ..."
      set option "-Aq"
      set_queue_defaults default_array
      set_lab_defaults default_array
      update_change_array default_array chgar
      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile default_array $on_host]
      set result [start_sge_bin "qconf" "$option ${tmpfile}" $on_host $as_user]

   } else {
      ts_log_fine "Add queue $chgar(qname) for hostlist $chgar(hostlist) slow ..."
      set option "-aq"
      set vi_commands [build_vi_command chgar]
      set result [start_vi_edit "qconf" $option $vi_commands messages $on_host $as_user]

   }
   unset chgar(qname)
   unset chgar(hostlist)
   return [handle_sge_errors "add_queue" "qconf $option" $result messages $raise_error]
}


#****** sge_queue/mod_queue() **************************************************
#  NAME
#     mod_queue() -- modify existing queue configuration object
#
#  SYNOPSIS
#     mod_queue { qname hostslist hange_array {fast_add 1} {on_host ""} 
#    {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Modify the queue $qname in the Cluster Scheduler (Grid Engine) cluster.
#     Supports fast (qconf -Mq) and slow (qconf -mq) mode.
#
#  INPUTS
#     qname        - name of the (cluster) queue
#     hostlist     - the list of hosts
#     change_array - array containing the changed attributes.
#     {fast_add 1}     - use fast mode
#     {on_host ""}     - execute qconf on this host, default is master host
#     {as_user ""}     - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1}  - raise error condition?
#
#  RESULT
#       0 - success
#     < 0 - error
#
#  SEE ALSO
#     sge_procedures/handle_sge_error()
#     sge_queue/get_queue_messages()
#*******************************************************************************
proc mod_queue { qname hostlist change_array {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   get_current_cluster_config_array ts_config

   upvar $change_array chgar

   set chgar(qname) "$qname"
   validate_queue chgar

   get_queue_messages messages "mod" "$qname" $on_host $as_user
     
   if {$fast_add} {
      ts_log_fine "Modify queue $qname for hostlist $hostlist from file ..."
      # aja: TODO: suppress all messages coming from the procedure
      get_queue "$qname" curr_arr "" "" 0
      if {![info exists curr_arr]} {
         set_queue_defaults curr_arr
     }
      # aja: TODO: is this okay? procedures not checked
      if {$ts_config(gridengine_version) >= 60} {
         if {[llength $hostlist] == 0} {
            set_cqueue_default_values curr_arr chgar
         } else {
            set_cqueue_specific_values curr_arr chgar $hostlist
         }
      } else {
         set chgar(hostlist) "$hostlist"
      }

      update_change_array curr_arr chgar

      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile curr_arr $on_host]
      set option "-Mq"
      set result [start_sge_bin "qconf" "$option $tmpfile" $on_host $as_user]

   } else {
      ts_log_fine "Modify queue $qname for hostlist $hostlist slow ..."
      set vi_commands [build_vi_command chgar]
      set chgar(hostlist) $hostlist
      # BUG: different message for "vi" from fastadd ...
      set NOT_EXISTS [translate_macro MSG_CQUEUE_DOESNOTEXIST_S "$qname"]
      add_message_to_container messages -1 $NOT_EXISTS
      set option "-mq"
      set result [start_vi_edit "qconf" "$option $qname" $vi_commands messages $on_host $as_user]
   }
   set ret [handle_sge_errors "mod_queue" "qconf $option $qname" $result messages $raise_error]
   return $ret
}

#****** sge_queue/del_queue() **************************************************
# 
#  NAME
#     del_queue -- delete queue configuration object
#
#  SYNOPSIS
#     del_queue { q_name hostlist {on_host ""} {as_user ""} {raise_error 1} } 
#
#  FUNCTION
#     remove a queue from the qmaster configuration
#
#  INPUTS
#     q_name - name of the queue to delete
#     {on_host ""}     - execute qconf on this host (default: qmaster host)
#     {as_user ""}     - execute qconf as this user (default: CHECK_USER)
#     {raise_error 1}  - raise error condition in case of errors?
#
#  RESULT
#       0 - success
#     < 0 - error
#
#
#  SEE ALSO
#     sge_procedures/handle_sge_error()
#     sge_queue/get_queue_messages()
#*******************************************************************************
# aja TODO: create procedure del_queue {qname hostlist {on_host ""} {as_user ""} {raise_error 1}}

#****** sge_procedures/get_queue() *********************************************
# 
#  NAME
#     get_queue -- get queue configuration information
#
#  SYNOPSIS
#     get_queue { q_name {output_var result} {on_host ""} {as_user ""} 
#    {raise_error 1} } 
#
#  FUNCTION
#     Get the actual configuration settings for the named queue
#     Represents qconf -sq command in SGE
#
#  INPUTS
#     q_name       - name of the queue
#     {output_var result} - result will be placed here
#     {on_host ""}        - execute qconf on this host (default: qmaster host)
#     {as_user ""}        - execute qconf as this user (default: CHECK_USER)
#     {raise_error 1}     - raise error condition in case of errors?
#
#  RESULT
#       0 - success
#     < 0 - error
#
#  SEE ALSO
#     sge_procedures/handle_sge_error()
#     sge_queue/get_queue_messages()
#*******************************************************************************
proc get_queue { q_name {output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
   ts_log_fine "Get queue $q_name ..."

   upvar $output_var out

   get_queue_messages messages "get" "$q_name" $on_host $as_user
   
   return [get_qconf_object "get_queue" "-sq $q_name" out messages 0 $on_host $as_user $raise_error]

}

#                                                             max. column:     |
#****** sge_queue/suspend_queue() ******
# 
#  NAME
#     suspend_queue -- set a queue in suspend mode
#
#  SYNOPSIS
#     suspend_queue { qname } 
#
#  FUNCTION
#     This procedure will set the given queue into suspend state
#
#  INPUTS
#     qname - name of the queue to suspend 
#
#  RESULT
#     0  - ok
#    -1  - error 
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
proc suspend_queue { qname } {
  global CHECK_USER
  get_current_cluster_config_array ts_config
  log_user 0 
   set WAS_SUSPENDED [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_QINSTANCE_SUSPENDED]]

  
  # spawn process
  set master_arch [resolve_arch $ts_config(master_host)]
  set program "$ts_config(product_root)/bin/$master_arch/qmod"
  set sid [open_remote_spawn_process $ts_config(master_host) $CHECK_USER $program "-s $qname"]
  set sp_id [ lindex $sid 1 ]
  set result -1	

  log_user 0
  set timeout 30
  expect {
     -i $sp_id full_buffer {
         set result -1
         ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
     }
     -i $sp_id "was suspended" {
         set result 0
     }
      -i $sp_id "*${WAS_SUSPENDED}*" {
         set result 0
     }

	  -i $sp_id default {
         ts_log_fine $expect_out(buffer)
	      set result -1
	  }
  }
  # close spawned process 
  close_spawn_process $sid
  log_user 1
  if { $result != 0 } {
     ts_log_severe "could not suspend queue \"$qname\""
  }

  return $result
}

#                                                             max. column:     |
#****** sge_queue/unsuspend_queue() ******
# 
#  NAME
#     unsuspend_queue -- set a queue in suspend mode
#
#  SYNOPSIS
#     unsuspend_queue { queue } 
#
#  FUNCTION
#     This procedure will set the given queue into unsuspend state
#
#  INPUTS
#     queue - name of the queue to set into unsuspend state
#
#  RESULT
#     0  - ok
#    -1  - error 
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
proc unsuspend_queue { queue } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

  set timeout 30
  log_user 0 
   
   set UNSUSP_QUEUE [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_QINSTANCE_NSUSPENDED]]

  # spawn process
  set master_arch [resolve_arch $ts_config(master_host)]
  set program "$ts_config(product_root)/bin/$master_arch/qmod"
  set sid [open_remote_spawn_process $ts_config(master_host) $CHECK_USER $program "-us $queue"]
  set sp_id [ lindex $sid 1 ]
  set result -1	
  log_user 0 

  set timeout 30
  expect {
      -i $sp_id full_buffer {
         set result -1
         ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
      }
      -i $sp_id "unsuspended queue" {
         set result 0 
      }
      -i $sp_id  "*${UNSUSP_QUEUE}*" {
         set result 0 
      }
      -i $sp_id default {
         ts_log_fine $expect_out(buffer) 
         set result -1 
      }
  }
  # close spawned process 
  close_spawn_process $sid
  log_user 1   
  if { $result != 0 } {
     ts_log_severe "could not unsuspend queue \"$queue\""
  }
  return $result
}

#                                                             max. column:     |
#****** sge_queue/disable_queue() ******
# 
#  NAME
#     disable_queue -- disable queues
#
#  SYNOPSIS
#     disable_queue { queue } 
#
#  FUNCTION
#     Disable the given queue/queue list
#
#  INPUTS
#     queue - name of queues to disable
#
#  RESULT
#     0  - ok
#    -1  - error
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
proc disable_queue { queuelist } {
  set ret [mod_queue_state $queuelist "disable"]
  return $ret
}


#                                                             max. column:     |
#****** sge_queue/enable_queue() ******
# 
#  NAME
#     enable_queue -- enable queuelist
#
#  SYNOPSIS
#     enable_queue { queue } 
#
#  FUNCTION
#     This procedure enables a given queuelist by calling the qmod -e binary
#
#  INPUTS
#     queue - name of queues to enable (list)
#
#  RESULT
#     0  - ok
#    -1  - on error
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
proc enable_queue { queuelist } {
   set ret [mod_queue_state $queuelist "enable"]
   return $ret
}

proc mod_queue_state { queuelist state } {
  global ts_config

  set max_args 100 ;# maximum 100 queues at one time (= 2000 byte commandline with avg(len(qname)) = 20

  if {$state == "enable"} {
     set STATE [translate_macro MSG_QINSTANCE_NDISABLED]
     set command "-e"
  } elseif {$state == "disable"} {
     set STATE [translate_macro MSG_QINSTANCE_DISABLED]
     set command "-d"
  } else {
     ts_log_severe "unknown state"
     return -1
  }
  
  set failed 0
  set queues ""
  set queue_nr 0
  foreach elem $queuelist {
     append queues " $elem"
     incr queue_nr 1

     if {$queue_nr == $max_args} {
        set result [start_sge_bin "qmod" "$command $queues"]
        ts_log_fine "$state queue(s) $queues"
        set result [string trim $result]
        set res_split [split $result "\n"]   
        foreach elem $res_split {
           ts_log_fine "line: $elem"
           if {[string match "*${STATE}*" $elem] == 0} {
              incr failed 1
           } 
        }

        set queues ""
        set queue_nr 0
     }
  }

  if {$queue_nr != 0} {
     set result [start_sge_bin "qmod" "$command $queues"]
     ts_log_fine "$state queue(s) $queues"
     set result [string trim $result]
     set res_split [split $result "\n"]   
     foreach elem $res_split {
        ts_log_fine "line: $elem"
        if {[string match "*${STATE}*" $elem] == 0} {
           incr failed 1
        } 
     }
  }

  if {$failed != 0} {
     ts_log_severe "could not $state all queues: $failed failed"
     return -1
  }
  return 0
}


#                                                             max. column:     |
#****** sge_queue/get_queue_state() ******
# 
#  NAME
#     get_queue_state -- get the state of a queue
#
#  SYNOPSIS
#     get_queue_state { queue } 
#
#  FUNCTION
#     This procedure returns the state of the queue by parsing output of qstat -f. 
#
#  INPUTS
#     queue - name of the queue
#
#  RESULT
#     The return value can contain more than one state. Here is a list of possible
#     states:
#
#     u(nknown)
#     a(larm)
#     A(larm)
#     C(alendar  suspended)
#     s(uspended)
#     S(ubordinate)
#     d(isabled)
#     D(isabled)
#     E(rror)
#
#*******************************
proc get_queue_state { queue_name } {
  get_current_cluster_config_array ts_config

  # resolve the queue name
  set queue [resolve_queue $queue_name 0]
  # long queue names would be truncated by plain qstat, e.g.
  # test.1684141028@centos-7-amd64-1
  # set the size of the queue column
  set qstat_env(SGE_LONG_QNAMES) [expr [string length $queue] + 1]
  set result [start_sge_bin "qstat" "-f -q $queue" "" "" prg_exit_state 60 "" "bin" output_lines qstat_env]
  if {$prg_exit_state != 0} {
     ts_log_severe "qstat -f -q $queue failed:\n$result"
     return ""
  }

  # split each line as listelement
  set back ""
  set help [split $result "\n"]
  foreach line $help { 
      if {[string compare [lindex $line 0] $queue] == 0} {
         set back [lindex $line 5]
         return $back
      }
  }

  ts_log_severe "queue \"$queue\" not found" 
  return ""
}

#****** sge_queue/clear_queue() *****************************************
#  NAME
#     clear_queue() -- clear queue $queue
#
#  SYNOPSIS
#     clear_queue { queue {output_var result} {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -cq $queue to clear queue $queue
#
#  INPUTS
#     output_var      - result will be placed here
#     queue           - queue to be cleared
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
#     sge_calendar/get_calendar()
#     sge_calendar/get_calendar_error()
#*******************************************************************************
proc clear_queue {queue {output_var result}  {on_host ""} {as_user ""} {raise_error 1}} {

   upvar $output_var out

   # clear output variable
   if {[info exists out]} {
      unset out
   }

   set ret 0
   set result [start_sge_bin "qconf" "-cq $queue" $on_host $as_user]

   # parse output or raise error
   if {$prg_exit_state == 0} {
      parse_simple_record result out
   } else {
      set ret [clear_queue_error $result $queue $raise_error]
   }

   return $ret

}
#****** sge_queue/clear_queue_error() ***************************************
#  NAME
#     clear_queue_error() -- error handling for clear_queue
#
#  SYNOPSIS
#     clear_queue_error { result queue raise_error }
#
#  FUNCTION
#     Does the error handling for clear_queue.
#     Translates possible error messages of qconf -cq,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     clear_queue. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     queue       - queue for which qconf -cq has been called
#     raise_error - raise error condition?
#
#  RESULT
#     Returncode for clear_queue function:
#      -1:  invalid queue or job "queue"
#     -99: other error
#
#  SEE ALSO
#     sge_calendar/get_calendar
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc clear_queue_error {result queue raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1 "
   set messages(-1) [translate_macro MSG_QUEUE_INVALIDQORJOB_S $queue]

   # we might have version dependent, calendar specific error messages
   get_clear_queue_error_vdep messages $queue

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "get_calendar" "qconf -cq $queue" $result messages $raise_error]

   return $ret
}

#****** sge_queue/get_queue_list() *********************************************
#  NAME
#     get_queue_list() -- get a list of all queues
#
#  SYNOPSIS
#     get_queue_list { {output_var result} {on_host ""} {as_user ""} {raise_error 1}
#
#  FUNCTION
#     Calls qconf -sql to retrieve the list of all queues
#
#  INPUTS
#     {output_var result} - result will be placed here
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
proc get_queue_list {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
   ts_log_fine "Get queue list ..."

   upvar $output_var out

   get_queue_messages messages "list" "" $on_host $as_user 
   
   return [get_qconf_object "get_queue_list" "-sql" out messages 1 $on_host $as_user $raise_error]

}

#****** sge_queue/get_queue_messages() *************************************
#  NAME
#     get_queue_messages() -- returns the set of messages related to action 
#                              on queue, i.e. add, modify, delete, get
#
#  SYNOPSIS
#     get_queue_messages {msg_var action obj_name result {on_host ""} {as_user ""}} 
#
#  FUNCTION
#     Returns the set of messages related to action on sge queue. This function
#     is a wrapper of sge_object_messages which is general for all types of objects
#
#  INPUTS
#     msg_var       - array of messages (the pair of message code and message value)
#     action        - action examples: add, modify, delete,...
#     obj_name      - sge object name
#     {on_host ""}  - execute on this host, default is master host
#     {as_user ""}  - execute qconf as this user, default is $CHECK_USER
#
#  SEE ALSO
#     sge_procedures/sge_client_messages()
#*******************************************************************************
proc get_queue_messages {msg_var action obj_name {on_host ""} {as_user ""}} {
   get_current_cluster_config_array ts_config

   upvar $msg_var messages
   if { [info exists messages]} {
      unset messages
   }

   # CD: why don't we have "cluster queue" in $SGE_OBJ_CQUEUE ?
   set QUEUE "cluster [translate_macro MSG_OBJ_QUEUE]"
     
   # set the expected client messages
   sge_client_messages messages $action $QUEUE $obj_name $on_host $as_user
   
   # the place for exceptions: # VD version dependent  
   #                           # CD client dependent
   # see sge_procedures/sge_client_messages
   switch -exact $action {
      "add" {
         add_message_to_container messages -4 "error: [translate_macro MSG_ULONG_INCORRECTSTRING "*"]"
         add_message_to_container messages -5 [translate_macro MSG_CQUEUE_UNKNOWNUSERSET_S "*"]
         add_message_to_container messages -6 [translate_macro MSG_HGRP_UNKNOWNHOST "*" ]
      }
      "get" {
         add_message_to_container messages -1 [translate_macro MSG_CQUEUE_NOQMATCHING_S "$obj_name"]
      }
      "mod" {
         add_message_to_container messages -5 "error: [translate_macro MSG_ULONG_INCORRECTSTRING "*"]"
         add_message_to_container messages -6 [translate_macro MSG_CQUEUE_UNKNOWNUSERSET_S "*"]
         add_message_to_container messages -7 [translate_macro MSG_HGRP_UNKNOWNHOST "*" ]
         if {$ts_config(gridengine_version) >= 62} {
            #AP: TODO: find the parameters for this message:
            set AR_REJECTED_SSU [translate_macro MSG_PARSE_MOD_REJECTED_DUE_TO_AR_SSU "*" "*"]
            set AR_REJECTED_SU [translate_macro MSG_PARSE_MOD3_REJECTED_DUE_TO_AR_SU "*" "*"]
            set SLOT_RESERVED [translate_macro MSG_QINSTANCE_SLOTSRESERVED_USS "*" "*" "*"]
            add_message_to_container messages -8 $AR_REJECTED_SSU
            add_message_to_container messages -9 $AR_REJECTED_SU
            add_message_to_container messages -10 $SLOT_RESERVED
         }
      }
      "del" {
         set STILL_RUNNING_JOBS [translate_macro MSG_QINSTANCE_STILLJOBS]
         add_message_to_container messages -2 $STILL_RUNNING_JOBS
      }
      "list" {
         set NOT_DEFINED [translate_macro MSG_QCONF_NOXDEFINED_S "cqueue list"]
         add_message_to_container messages -1 $NOT_DEFINED
      }
   } 
}


#                                                             max. column:     |
#****** sge_queue.60/get_queue_instance() **************************************
#  NAME
#     get_queue_instance () -- get the queue instance name
#
#  SYNOPSIS
#     get_queue_instance {queue host}
#
#  FUNCTION
#     Returns the name of the queue instance which is constructed by given queue
#     name and the hostname.
#
#  INPUTS
#     queue - the name of the queue
#     host  - the hostname
#
#*******************************************************************************
proc get_queue_instance {queue host} {
   set resolved_host [resolve_host $host 1]
   return "${queue}@${resolved_host}"
}

#                                                             max. column:     |
#****** sge_queue/vdep_validate_queue() *********************************************
#  NAME
#     vdep_validate_queue() -- validate the default queue settings for sge 60.
#
#  SYNOPSIS
#     vdep_validate_queue {change_array}
#
#  FUNCTION
#     Validate the queue configuration values. Adjust the queue settings
#     according to sge version 60 systems.
#
#  INPUTS
#     change_array - the resulting array
#
#*******************************************************************************
proc vdep_validate_queue { change_array } {
   get_current_cluster_config_array ts_config
   upvar $change_array chgar

   if {[info exists chgar(qtype)]} {
      if { [string match "*CHECKPOINTING*" $chgar(qtype)] ||
           [string match "*PARALLEL*" $chgar(qtype)] } {

         set new_chgar_qtype ""
         foreach elem $chgar(qtype) {
            if { [string match "*CHECKPOINTING*" $elem] } {
               ts_log_fine "queue type CHECKPOINTING is set by assigning a checkpointing environment to the queue"
            } else {
               if { [string match "*PARALLEL*" $elem] } {
                  ts_log_fine "queue type PARALLEL is set by assigning a parallel environment to the queue"
               } else {
                  append new_chgar_qtype "$elem "
               }
            }
         }
         set chgar(qtype) [string trim $new_chgar_qtype]
         ts_log_fine "using qtype=$chgar(qtype)"
      }
   }
}

proc vdep_set_queue_values { hostlist change_array } {
   upvar $change_array chgar

   if {[info exists curr_arr]} {
      if {[llength $hostlist] == 0} {
         set_cqueue_default_values curr_arr chgar
      } else {
         set_cqueue_specific_values curr_arr chgar $hostlist
      }
      }
   }

# this won't be needed
proc qinstance_to_cqueue { change_array } {
   upvar $change_array chgar

   if { [info exists chgar(hostname)] } {
      unset chgar(hostname)
   }

}

proc set_cqueue_default_values { current_array change_array } {
   upvar $current_array currar
   upvar $change_array chgar
   ts_log_finer "calling set_cqueue_default_values"

   # parse each attribute to be changed and set the queue default value
   foreach attribute [array names chgar] {
      ts_log_finest "--> setting queue default value for attribute $attribute"
      ts_log_finest "--> old_value = $currar($attribute)"
      # set the default
      set new_value $chgar($attribute)
      ts_log_finest "--> new_value = $new_value"

      # get position of host(group) specific values and append them
      set comma_pos [string first ",\[" $currar($attribute)]
      ts_log_finest "--> comma pos = $comma_pos"
      if {$comma_pos != -1} {
         append new_value [string range $currar($attribute) $comma_pos end]
      }

      ts_log_finest "--> new queue default value = $new_value"
      # write back to chgar
      set chgar($attribute) $new_value
   }
}

proc set_cqueue_specific_values {current_array change_array hostlist} {
   upvar $current_array currar
   upvar $change_array chgar
   ts_log_finer "calling set_cqueue_specific_values"

   # parse each attribute to be changed
   foreach attribute [array names chgar] {
      if {[string compare $attribute qname] == 0 || [string compare $attribute hostlist] == 0} {
         continue
      }

      ts_log_finest "--> setting queue default value for attribute $attribute"
      ts_log_finest "--> old_value = $currar($attribute)"

      # split old value and store host specific values in an array
      if {[info exists host_values]} {
         unset host_values
      }

      # split attribute value into default and host specific components
      set value_list [split $currar($attribute) "\["]

      # copy the default value
      if {$hostlist == ""} {
         # use the new value for the cluster queue
         set new_value $default_value
      } else {
         # use old cqueue value as default, set new host specific
         set default_value [string trimright [lindex $value_list 0] ","]
         ts_log_finest "--> default value = $default_value"

         # copy host specific values to array
         for {set i 1} {$i < [llength $value_list]} {incr i} {
            set host_value [lindex $value_list $i]
            set first_equal_position [string first "=" $host_value]
            incr first_equal_position -1
            set host [string range $host_value 0 $first_equal_position]
            set host [resolve_host $host]
            incr first_equal_position 2
            set value [string range $host_value $first_equal_position end]
            set value [string trimright $value ",\]\\"]
            ts_log_finest "--> \"$host\" = \"$value\""
            set host_values($host) $value
         }

         # change (or set) host specific values from chgar
         foreach unresolved_host $hostlist {
            set host [resolve_host $unresolved_host]
            ts_log_finest "--> setting host_values($host) = $chgar($attribute)"
            set host_values($host) $chgar($attribute)
         }

         # dump host specific values to new_value
         set new_value $default_value
         foreach host [array names host_values] {
            if {[string compare -nocase $default_value $host_values($host)] != 0} {
               append new_value ",\[$host=$host_values($host)\]"
            }
         }
      }

      ts_log_finest "--> new queue value = $new_value"

      # write back to chgar
      set chgar($attribute) $new_value
   }

   # check if all hosts / hostgroups are in the hostlist attribute
#   if { $hostlist != "" } {
#      set new_hosts {}
#      foreach host $hostlist {
#         if { [lsearch -exact $currar(hostlist) $host] == -1 } {
#            lappend new_hosts $host
#            ts_log_finest "--> host $host is not yet in hostlist"
#         }
#      }
#
#      if { [llength $new_hosts] > 0 } {
#         set chgar(hostlist) "$currar(hostlist) $new_hosts"
#      }
#   }
}

#****** sge_procedures.60/queue/set_queue() ******************************************
#  NAME
#     set_queue() -- set queue attributes
#
#  SYNOPSIS
#     set_queue { qname hostlist change_array {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Sets the attributes given in change_array in the cluster queue qname.
#     If hostlist is an empty list, the cluster queue global values are set.
#     If a list of hosts or host groups is specified, the attributes for these
#     hosts or host groups are set.
#
#  INPUTS
#     qname        - name of the (cluster) queue
#     hostlist     - list of hosts / host groups.
#     change_array - array containing the changed attributes.
#     {fast_add 1} - 0: modify the attribute using qconf -mq,
#                  - 1: modify the attribute using qconf -Mq, faster
#     {on_host ""} - execute qconf on this host, default is master host
#     {as_user ""} - execute qconf as this user, default is $CHECK_USER
#     raise_error  - raise error condition in case of errors
#
#  RESULT
#
#*******************************************************************************
proc set_queue {qname hostlist change_array {fast_add 1}  {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $change_array chgar
   return [mod_queue $qname $hostlist chgar $fast_add $on_host $as_user $raise_error]
}

#                                                             max. column:     |
#****** sge_queue.60/del_queue() ***********************************************
#
#  NAME
#     del_queue -- Delete a queue
#
#  SYNOPSIS
#     del_queue { qname {on_host ""} {as_user ""} {raise_error 1} }
#
#  FUNCTION
#     Deletes a queue using qconf -dq
#
#  INPUTS
#     qname -  Name of the queue
#     {on_host ""}        - execute qconf on this host (default: qmaster host)
#     {as_user ""}        - execute qconf as this user (default: CHECK_USER)
#     {raise_error 1}     - raise error condition in case of errors?
#
#  RESULT
#     0 - on success
#    <0 - on error

#
#  SEE ALSO
#     sge_procedures/handle_sge_errors
#     sge_procedures/sge_object_messages
#*******************************************************************************

proc del_queue { q_name hostlist {ignore_hostlist 0} {del_cqueue 0} {on_host ""} {as_user ""} {raise_error 1}} {
  global CHECK_USER
  get_current_cluster_config_array ts_config

   if {!$ignore_hostlist} {
      # delete individual queue instances or queue domaines
      foreach host $hostlist {
         set result [start_sge_bin "qconf" "-dattr queue hostlist $host $q_name"]
         if { $prg_exit_state != 0 } {
            ts_log_severe "could not delete queue instance or queue domain: $result" $raise_error 
         }
      }
   }

   if {$ignore_hostlist || $del_cqueue} {
      ts_log_fine "Delete queue $q_name ..."
      get_queue_messages messages "del" "$q_name" $on_host $as_user
      set output [start_sge_bin "qconf" "-dq $q_name" $on_host $as_user]
      return [handle_sge_errors "del_queue" "qconf -dq $q_name" $output messages $raise_error]
      }

   return 0
}

proc get_qinstance_list {{filter ""} {on_host ""} {as_user ""} {raise_error 1}} {
   # try to get qinstance list
   if { $filter != "" } {
      set arg1 [lindex $filter 0]
      set arg2 [lindex $filter 1]
      set result [start_sge_bin "qselect" "$arg1 $arg2" $on_host $as_user]
      set command_line "qselect $arg1 $arg2"
   } else {
      set result [start_sge_bin "qselect" "" $on_host $as_user]
      set command_line "qselect"
   }
   if {$prg_exit_state != 0} {
      # command failed because queue list is empty
      set messages(index) "-1"
      set messages(-1) "*[translate_macro MSG_QSTAT_NOQUEUESREMAININGAFTERXQUEUESELECTION_S "*"]"

      # this is no error
      set ret [handle_sge_errors "get_qinstance_list" "$command_line" $result messages 0]
      set result ""
   }

   return $result
}

# queue for -q request or as subordinate queue
# is the 6.0 cluster queue
proc get_requestable_queue { queue host } {
   return $queue
}

proc get_cluster_queue {queue_instance} {
   set cqueue $queue_instance

   if {$queue_instance != "" } {
      set at [string first "@" $queue_instance]
      if {$at > 0} {
         set cqueue [string range $queue_instance 0 [expr $at - 1]]
      }
   }

   ts_log_fine "queue instance $queue_instance is cluster queue $cqueue"

   return $cqueue
}

proc get_clear_queue_error_vdep {messages_var host} {
   upvar $messages_var messages

   #lappend messages(index) "-3"
   #set messages(-3) [translate_macro MSG_XYZ_S $host] #; another exechost specific error message
   #set messages(-3,description) "a highlevel description of the error"    ;# optional parameter
   #set messages(-3,level) WARNING  ;# optional parameter: we only want to raise a warning
}

#****** sge_queue.60/purge_queue() *****************************************
#  NAME
#     purge_queue() -- purge queue instance or queue domain
#
#  SYNOPSIS
#     purge_queue { queue object {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Calls qconf -purge queue attribute queue_instance|queue_domain.
#
#  INPUTS
#     queue           - queue instance or queue domain to purge
#     object          - attribute to be purged: hostlist, load_threshold, ...
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
#     sge_calendar/get_calendar()
#     sge_calendar/get_calendar_error()
#*******************************************************************************
proc purge_queue {queue object {on_host ""} {as_user ""} {raise_error 1}} {
   set ret 0

   set result [start_sge_bin "qconf" "-purge queue $object $queue" $on_host $as_user]
   set ret [purge_queue_error $result $queue $object $raise_error]

   puts "### $ret ### $result"

   return $ret

}
#****** sge_queue.60/purge_queue_error() ***************************************
#  NAME
#     purge_queue_error() -- error handling for purge_queue
#
#  SYNOPSIS
#     purge_queue_error { result queue host object raise_error }
#
#  FUNCTION
#     Does the error handling for purge_queue.
#     Translates possible error messages of qconf -purge,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     purge_queue. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     queue       - queue intance or queue domain for which qconf -purge
#                   has been called
#     object      - object  which queue will be purged
#     raise_error - raise error condition in case of errors
#
#  RESULT
#     Returncode for purge_queue function:
#        0: the queue was modified
#       -1: a cluster queue name was passed to purge_queue (handled in purge_queue)
#       -2: cluster queue entry "queue" does not exist
#     -999: other error
#
#  SEE ALSO
#     sge_calendar/get_calendar
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc purge_queue_error {result queue object raise_error} {
   global CHECK_USER

   set pos [string first "@" $queue]
   if {$pos < 0} {
      set cqueue $queue
      set host_or_group ""
   } else {
      set cqueue [string range $queue 0 [expr $pos -1]]
      set host_or_group [string range $queue [expr $pos + 1] end]
   }

   # recognize certain error messages and return special return code
   set messages(index) 0
   set messages(0) [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS $CHECK_USER "*" $cqueue "*"]

   lappend messages(index) -1
   set messages(-1) "*[translate_macro MSG_CQUEUE_DOESNOTEXIST_S $cqueue]"

   lappend messages(index) -2
   set messages(-2) [translate_macro MSG_QCONF_ATTR_ARGS_NOT_FOUND $object $host_or_group]

   lappend messages(index) -3
   set messages(-3) [translate_macro MSG_QCONF_MODIFICATIONOFOBJECTNOTSUPPORTED_S]

   lappend messages(index) -4
   set messages(-4) "*[translate_macro MSG_QCONF_NOATTRIBUTEGIVEN]*"

   lappend messages(index) -5
   set messages(-5) "*[translate_macro MSG_QCONF_GIVENOBJECTINSTANCEINCOMPLETE_S "*"]*"

   lappend messages(index) -6
   set messages(-6) [translate_macro MSG_QCONF_MODIFICATIONOFHOSTNOTSUPPORTED_S "*"]

   lappend messages(index) -7
   set messages(-7) "*[translate_macro MSG_QCONF_NOOPTIONARGPROVIDEDTOX_S "*"]*"

   # we might have version dependent, queue specific error messages
   get_clear_queue_error_vdep messages $queue

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "purge_queue" "qconf -purge $object $queue" $result messages $raise_error]

   return $ret
}

