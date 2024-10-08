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

#****** sge_host/get_exechost_error() ******************************************
#  NAME
#     get_exechost_error() -- error handling for get_exechost
#
#  SYNOPSIS
#     get_exechost_error { result host raise_error } 
#
#  FUNCTION
#     Does the error handling for get_exechost.
#     Translates possible error messages of qconf -se,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     get_exechost. While the qconf call and parsing the result is 
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     host        - host for which qconf -se has been called
#     raise_error - raise error condition in case of errors
#
#  RESULT
#     Returncode for get_exechost function:
#       -1: host is not resolvable
#       -2: host is not an execution host
#     -999: other error
#
#  SEE ALSO
#     sge_host/get_exechost
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc get_exechost_error {result host raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1 -2"
   set messages(-1) [translate_macro MSG_EXEC_XISNOTANEXECUTIONHOST_S $host]
   set messages(-2) [translate_macro MSG_SGETEXT_CANTRESOLVEHOST_S $host]
 
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "get_exechost" "qconf -se $host" $result messages $raise_error]

   return $ret
}


#****** sge_host/get_exechost() ************************************************
#  NAME
#     get_exechost() -- get exechost properties (qconf -se)
#
#  SYNOPSIS
#     get_exechost {output_var host {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Calls qconf -se $host to retrieve exec host properties.
#
#  INPUTS
#     output_var      - TCL array for storing the result
#     host            - exechost for query
#     {on_host ""}    - execute qconf on this host
#     {as_user ""}    - execute qconf as this user
#     {raise_error 1} - do add_proc error, or only output error messages
#
#  RESULT
#     0 on success.
#     < 0 in case of errors, see sge_host/get_exechost_error()
#
#  SEE ALSO
#     sge_host/get_exechost_error()
#*******************************************************************************
proc get_exechost {output_var {host global} {on_host ""} {as_user ""} {raise_error 1}} {
   get_current_cluster_config_array ts_config

   upvar $output_var out

   # clear output variable
   if {[info exists out]} {
      unset out
   }

   set ret 0
   set result [start_sge_bin "qconf" "-se $host" $on_host $as_user]
   set result [string trim $result]
   # parse output or raise error
   if {$prg_exit_state == 0} {
      parse_simple_record result out
   } else {
      set ret [get_exechost_error $result $host $raise_error]
   }

   return $ret
}

#                                                             max. column:     |
#****** sge_host/set_exechost() ******
#
#  NAME
#     set_exechost -- set/change exec host configuration
#
#  SYNOPSIS
#     set_exechost { change_array host {fast_add 1} {on_host ""} {as_user ""} {raise_error 1} }
#
#  FUNCTION
#     Set the exec host configuration corresponding to the content of the
#     change_array.
#
#  INPUTS
#     change_array - name of an array variable that will be set by set_exechost
#     host         - name of an execution host
#     {fast_add 1} - 0: modify the attribute using qconf -me,
#                  - 1: modify the attribute using qconf -Me, faster
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#     The array should look like follows:
#
#     set change_array(user_list)   "deadlineusers"
#     set change_array(load_scaling) "NONE"
#     ....
#     (every value that is set will be changed)
#
#
#     Here the possible change_array values with some typical settings:
#
#     hostname                   myhost.mydomain
#     load_scaling               NONE
#     complex_list               test
#     complex_values             NONE
#     user_lists                 deadlineusers
#     xuser_lists                NONE
#     projects                   NONE
#     xprojects                  NONE
#     usage_scaling              NONE
#     resource_capability_factor 0.000000
#
#     return value:
#     -100 :    unknown error
#     -1   :    on timeout
#        0 :    ok
#
#  EXAMPLE
#     get_exechost myconfig expo1
#     set myconfig(user_lists) NONE
#     set_exechost myconfig expo1
#
#
#  NOTES
# Need to unset these values since qconf -M(m)e does not
# allow the modifications of "load_values" or "processors"
# but get_exechost gets ALL the parameters for exechost
#
#unset old_values(load_values)
#unset old_values(processors)
#
#
#  BUGS
#     ???
#
#  SEE ALSO
#     sge_host/get_exechost()
#*******************************
proc set_exechost { change_array {host global} {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
# the array should look like this:
#
# set change_array(load_scaling) NONE
# ....
# (every value that is set will be changed)
# hostname                   myhostname
# load_scaling               NONE
# complex_values             NONE
# user_lists                 deadlineusers
# xuser_lists                NONE
# projects                   NONE
# xprojects                  NONE
# usage_scaling              NONE
# report_variables	     0.00000
#
# returns
# -1   on timeout
# 0    if ok
   global env
   get_current_cluster_config_array ts_config

   upvar $change_array chgar
 
   set values [array names chgar]

   set return_value [get_exechost old_values $host]
   if {$return_value != 0} {
      ts_log_severe "get_exechost() returned: $return_value" $raise_error
      return -100
   }

   foreach elem $values {
      set old_values($elem) "$chgar($elem)"
   }

   # Need to unset these values since qconf -M(m)e does not
   # allow the modifications of "load_values" or "processors"
   # but get_exechost gets ALL the parameters for exechost

   unset old_values(load_values)
   unset old_values(processors)

   # Modify exechost from file?
   if {$fast_add} {
      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile old_values $on_host]
      set result [start_sge_bin "qconf" "-Me $tmpfile" $on_host $as_user]

      # parse output or raise error
      if {$prg_exit_state == 0} {
         set ret 0
      } else {
         set ret [set_exechost_error $result old_values $tmpfile $raise_error]
      }

   } else {
      # Use vi
      set vi_commands [build_vi_command old_values]
      set ret 0

      set project "$old_values(projects)"
      set attributes "projects"
      set elem "exechost"
      set host "$old_values(hostname)"

      set CHANGED [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS "*" "*" "*" "*" ]
      set PROJ_DS_NT_EXST [translate_macro MSG_SGETEXT_UNKNOWNPROJECT_SSSS $project $attributes $elem $host ]
      set MODIFIED [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS "*" "*" "*" "*" ]

      # User raise_error to report errors or not
      set master_arch [resolve_arch $ts_config(master_host)]      
      set result [handle_vi_edit "$ts_config(product_root)/bin/$master_arch/qconf" "-me $host" $vi_commands $MODIFIED $CHANGED $PROJ_DS_NT_EXST]

      # $CHANGED is really success
      if { $result == -2 } {
         set result 0
         set ret 0
      } elseif {  $result == -3 } {
         add_proc_error "set_exechost" -1 "$PROJ_DS_NT_EXST " $raise_error
         set ret -3 
      } elseif { $result != 0 } {
         add_proc_error "set_exechost" -1 "could not modifiy exechost $host" $raise_error
         set ret -1
      } 
   }
   return $ret
}

#****** sge_host/set_exechost_error() ***************************************
#  NAME
#     set_exechost_error() -- error handling for set_exechost
#
#  SYNOPSIS
#     set_exechost_error { result host tmpfile raise_error }
#
#  FUNCTION
#     Does the error handling for set_exechost.
#     Translates possible error messages of qconf -Me,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     set_exechost. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     tmpfile     - temp file for qconf -Me 
#     old_values  - array with values for which qconf -Me has been called
#     raise_error - do add_proc_error in case of errors
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
proc set_exechost_error {result old_values tmpfile  raise_error} {
   global ts_config

   # build up needed vars
   if {[info exists old_values(projects)]} {
      set project "$old_values(projects)"
   } else {
      set project "unknown"
   }
   set attributes "projects"
   set elem "exechost"
   if {[info exists old_values(hostname)]} {
      set host "$old_values(hostname)"
   } else {
      set host "unknown"
   }

   add_message_to_container messages -1 [translate_macro MSG_SGETEXT_UNKNOWNPROJECT_SSSS $attributes $project $elem $host]
   add_message_to_container messages -2 [translate_macro MSG_QUEUE_MODCMPLXDENYDUETOAR_SS "*" "*"]
   add_message_to_container messages -3 [translate_macro MSG_CPLX_ATTRIBISNEG_S "*"]
   add_message_to_container messages -4 [translate_macro MSG_RSMAP_INCONSISTENTAMOUNT_SSUU "*" "*" "*" "*"]

   set ret 0
   # now evaluate return code and raise errors
   set ret [handle_sge_errors "set_exechost" "qconf -Me $tmpfile" $result messages $raise_error]

   return $ret
}

#****** sge_host/mod_exechost() ******
#
#  NAME
#     mod_exechost -- Wrapper around set_exechost
#
#  SYNOPSIS
#     mod_exechost { change_array host {fast_add 1} {on_host ""} {as_user ""} {raise_error 1} }
#
#  FUNCTION
#     See set_exechost
#
#  INPUTS
#     change_array - name of an array variable that will be set by set_exechost
#     host         - name of an execution host
#     {fast_add 1} - 0: modify the attribute using qconf -me,
#                  - 1: modify the attribute using qconf -Me, faster
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  SEE ALSO
#     sge_host/get_exechost()
#*******************************
proc mod_exechost {change_array host {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $change_array out
   ts_log_fine "Using mod_exechost as wrapper for set_exechost \n"

   return [set_exechost out $host $fast_add $on_host $as_user $raise_error]

}
#****** sge_host/get_exechost_list() *******************************************
#  NAME
#     get_exechost_list() -- get a list of exec hosts
#
#  SYNOPSIS
#     get_exechost_list {output_var {on_host ""} {as_user ""} {raise_error 1} 
#     } 
#
#  FUNCTION
#     Calls qconf -sel to retrieve a list of execution hosts.
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
proc get_exechost_list {output_var {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $output_var out

   return [get_qconf_list "get_exechost_list" "-sel" out $on_host $as_user $raise_error]
}

#****** sge_host/get_adminhost_list() *******************************************
#  NAME
#     get_adminhost_list() -- get a list of admin hosts
#
#  SYNOPSIS
#     get_adminhost_list {{on_host ""} {as_user ""} {raise_error 1} 
#     } 
#
#  FUNCTION
#     Calls qconf -sel to retrieve a list of admin hosts.
#
#  INPUTS
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
proc get_adminhost_list {{on_host ""} {as_user ""} {raise_error 1}} {

   return [get_qconf_list "get_adminhost_list" "-sh" out $on_host $as_user $raise_error]
}

#****** sge_host/get_submithost_list() *******************************************
#  NAME
#     get_submithost_list() -- get a list of submit hosts
#
#  SYNOPSIS
#     get_submithost_list { {output_var result} {on_host ""} {as_user ""} {raise_error 1} 
#     } 
#
#  FUNCTION
#     Calls qconf -ss to retrieve a list of submit hosts.
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
proc get_submithost_list {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $output_var out

   return [get_qconf_list "get_submithost_list" "-ss" out $on_host $as_user $raise_error]
}

#****** sge_host/get_queue_config_list() *****************************************
#  NAME
#     get_queue_config_list() -- get a list of hosts  for  which  configurations
#                          are  available.
#
#  SYNOPSIS
#     get_queue_config_list { {output_var result} {on_host ""} {as_user ""} {arg ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -sconfl to list of hosts 
#
#  INPUTS
#     output_var      - result will be placed here
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {arg ""}    - value of calendar we wish to see; default is ""
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
proc get_queue_config_list {{output_var result} {on_host ""} {as_user ""} {arg ""} {raise_error 1}} {

   upvar $output_var out

   return [get_qconf_list "get_queue_config_list" "-sconfl" out $on_host $as_user $raise_error]

}
#****** sge_host/get_processor_list() *****************************************
#  NAME
#     get_processor_list() -- get a list of all processors
#
#  SYNOPSIS
#     get_processor_list { {output_var result} {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -sep to retrieve all processors
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
proc get_processor_list {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
  
   upvar $output_var out

   return [get_qconf_list "get_processor_list" "-sep" out $on_host $as_user $raise_error]

}

#****** sge_host/del_adminhost_error() ******************************************
#  NAME
#     del_adminhost_error() -- error handling for del_adminhost
#
#  SYNOPSIS
#     del_adminhost_error { result host raise_error }
#
#  FUNCTION
#     Does the error handling for del_adminhost.
#     Translates possible error messages of qconf -dh,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     del_adminhost. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     host        - host for which qconf -dh has been called
#     raise_error - do add_proc_error in case of errors
#
#  RESULT
#     Returncode for del_adminhost function:
#       -1: administrative host "host" does not exist
#     -999: other error
#
#  SEE ALSO
#     sge_host/get_exechost
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc del_adminhost_error {result host on_host raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1 "
   set messages(-1) [translate_macro MSG_SGETEXT_DOESNOTEXIST_SS "administrative host" $host]

   # now evaluate return code and raise errors
   set ret [handle_sge_errors "del_adminhost" "qconf -dh $host" $result messages $raise_error]

   return $ret
}

#****** sge_host/del_adminhost() *****************************************
#  NAME
#     del_adminhost() -- delete administrative host
#
#  SYNOPSIS
#     del_adminhost { host {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -dh host to delete administrative host
#
#  INPUTS
#     host            - administrative host which will be deleted
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
proc del_adminhost {host  {on_host ""} {as_user ""} {raise_error 1}} {

   get_current_cluster_config_array ts_config
   set ret 0
   set result [start_sge_bin "qconf" "-dh $host" $on_host $as_user]

   # parse output or raise error
   if {$prg_exit_state == 0} {
      set ret  0
   } else {
      set ret [del_adminhost_error $prg_exit_state $host $on_host $raise_error]
   }

   return $ret
}

#****** sge_host/add_adminhost() *****************************************
#  NAME
#     add_adminhost() -- add administrative host
#
#  SYNOPSIS
#     add_adminhost { host  {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -ah host to add administrative host
#
#  INPUTS
#     host            - administrative host which will be added
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
proc add_adminhost {host  {on_host ""} {as_user ""} {raise_error 1}} {

   get_current_cluster_config_array ts_config
   set ret 0
   set result [start_sge_bin "qconf" "-ah $host" $on_host $as_user]

   # parse output or raise error
   if {$prg_exit_state == 0} {
      set ret 0
   } else {
      set ret [add_adminhost_error $prg_exit_state $host $on_host $raise_error]
   }

   return $ret
}

#****** sge_host/add_adminhost_error() ******************************************
#  NAME
#     add_adminhost_error() -- error handling for add_adminhost
#
#  SYNOPSIS
#     add_adminhost_error { result host raise_error }
#
#  FUNCTION
#     Does the error handling for del_adminhost.
#     Translates possible error messages of qconf -dh,
#     builds the datastructure required for the handle_sge_errors
#     function call.
#
#     The error handling function has been intentionally separated from
#     del_adminhost. While the qconf call and parsing the result is
#     version independent, the error messages (macros) usually are version
#     dependent.
#
#  INPUTS
#     result      - qconf output
#     host        - host for which qconf -dh has been called
#     on_host     - valid host on which qconf -dh has been called
#     raise_error - do add_proc_error in case of errors
#
#  RESULT
#     Returncode for add_adminhost function:
#       -1: can't resolve hostname "host" 
#     -999: other error
#
#  SEE ALSO
#     sge_host/get_exechost
#     sge_procedures/handle_sge_errors
#*******************************************************************************
proc add_adminhost_error {result host on_host raise_error} {

   # recognize certain error messages and return special return code
   set messages(index) "-1 "
   set messages(-1) [translate_macro MSG_SGETEXT_ALREADYEXISTS_SS "adminhost" $host]

   # now evaluate return code and raise errors
   set ret [handle_sge_errors "add_adminhost" "qconf -ah $host" $result messages $raise_error]

   return $ret
}

#****** sge_host/host_get_suspended_states() ***********************************
#  NAME
#     host_get_suspended_states() -- return ps suspended states
#
#  SYNOPSIS
#     host_get_suspended_states { host } 
#
#  FUNCTION
#     Returns the states characters used by ps to express the suspended state.
#     Depends on the given hosts architecture.
#
#  INPUTS
#     host - host name
#
#  RESULT
#     state characters
#
#  SEE ALSO
#     sge_host/host_get_running_states()
#*******************************************************************************
proc host_get_suspended_states {host} {
   set arch [resolve_arch $host]

   switch -exact $arch {
      "darwin-x64" {
         set states ST
      }
      default {
         set states T
      }
   }

   return $states
}

#****** sge_host/host_get_running_states() ***********************************
#  NAME
#     host_get_running_states() -- return ps running states
#
#  SYNOPSIS
#     host_get_running_states { host } 
#
#  FUNCTION
#     Returns the states characters used by ps to express the running state.
#     Depends on the given hosts architecture.
#
#  INPUTS
#     host - host name
#
#  RESULT
#     state characters
#
#  SEE ALSO
#     sge_host/host_get_suspended_states()
#*******************************************************************************
proc host_get_running_states {host} {
   set arch [resolve_arch $host]

   switch -exact $arch {
      "darwin-x64" {
         set states R
      }
      default {
         set states OSR
      }
   }

   return $states
}

#****** sge_host/host_list_compare() *******************************************
#  NAME
#     host_list_compare() -- compare two host lists
#
#  SYNOPSIS
#     host_list_compare { list_1 list_2 {raise_error 1} } 
#
#  FUNCTION
#     Compares two host lists.
#     Only the short host names are compared.
#
#  INPUTS
#     list_1          - first list
#     list_2          - second list
#     {raise_error 1} - raise an error condition if the lists differ?
#     {do_resolve 0}  - resolve hosts
#
#  RESULT
#     0   on success
#     < 0 if the lists differ
#*******************************************************************************
proc host_list_compare {list_1 list_2 {raise_error 1} {do_resolve 0}} {
   # lists have to have same length
   if {[llength $list_1] != [llength $list_2]} {
      ts_log_severe "host lists have different length:\n$list_1\n$list_2" $raise_error
      return -1
   }

   # sort lists to compare them host by host
   set list_1 [lsort $list_1]
   set list_2 [lsort $list_2]

   set len [llength $list_1]
   for {set i 0} {$i < $len} {incr i} {
      set host_1_org [lindex $list_1 $i]
      set host_2_org [lindex $list_2 $i]
      if { $do_resolve != 0 } {
         set host_1 [resolve_host $host_1_org]
         set host_2 [resolve_host $host_2_org]
         if { $host_1 != $host_1_org } {
            ts_log_fine "host \"$host_1_org\" resolved to \"$host_1\""
         }
         if { $host_2 != $host_2_org } {
            ts_log_fine "host \"$host_2_org\" resolved to \"$host_2\""
         }
      } else {
         set host_1 $host_1_org
         set host_2 $host_2_org
      }

      # compare only short hosts
      set short_1 [lindex [split $host_1 "."] 0]
      set short_2 [lindex [split $host_2 "."] 0]

      if {[string compare -nocase $short_1 $short_2] != 0} {
         ts_log_severe "host lists not equal:\nlist_1=<$list_1>\nlist_2=<$list_2>" $raise_error
         return -2
      }
   }
   return 0
}

#****** sge_host/get_FD_SETSIZE_for_host() *************************************
#  NAME
#     get_FD_SETSIZE_for_host() -- get FD_SETSIZE value for a host
#
#  SYNOPSIS
#     get_FD_SETSIZE_for_host { host } 
#
#  FUNCTION
#     Starts the test binary test_general on the specified host and parses
#     the output. If FD_SETSIZE line is found return the value.
#
#  INPUTS
#     host - host where to start "test_general" binary
#
#  RESULT
#     parsed output of test_general -> FD_SETSIZE value
#
#  SEE ALSO
#     sge_host/get_FD_SETSIZE_for_host()
#     sge_host/get_shell_fd_limit_for_host()
#     sge_procedures/startup_execd_with_fd_limit()
#*******************************************************************************
proc get_FD_SETSIZE_for_host { host } {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   if {$ts_config(source_dir) == "none"} {
      ts_log_severe "source directory is set to \"none\" - need test binaries for this procedure"
      return "" 
   }
   
   set binary_path [get_test_or_source_path "test_general" $host]
   if {[is_remote_file $host $CHECK_USER $binary_path 1] == 0} {
      ts_log_severe "binary \"$binary_path\" not found on host \"$host\""
      return ""
   }

   set output [start_remote_prog $host $CHECK_USER $binary_path ""]
   set fd_set_size ""
   foreach line [split $output "\n"] {
      if {[string match "*FD_SETSIZE*" $line]} {
         set fd_set_size [string trim [lindex [split $line ":"] 1]]
         break
      }
   }

   if {$fd_set_size == ""} {
      ts_log_severe "cannot get FD_SETSIZE for host \"$host\""
   }
   ts_log_finer "FD_SETSIZE=$fd_set_size on host \"$host\""
   return $fd_set_size
}


#****** sge_host/get_shell_fd_limit_for_host() *********************************
#  NAME
#     get_shell_fd_limit_for_host() -- get /bin/sh limit setting of host
#
#  SYNOPSIS
#     get_shell_fd_limit_for_host { host user {mode "soft"} } 
#
#  FUNCTION
#     This procedure is starting ulimit in the /bin/sh shell to parse
#     the file descriptor limit setting.
#
#  INPUTS
#     host          - host of interest
#     user          - user who starts the shell
#     {mode "soft"} - if "soft": get soft limit
#                     if "hard": get hard limit
#
#  RESULT
#     the limit value of file descriptor limit
#
#  SEE ALSO
#     sge_host/get_FD_SETSIZE_for_host()
#     sge_host/get_shell_fd_limit_for_host()
#     sge_procedures/startup_execd_with_fd_limit()
#*******************************************************************************
proc get_shell_fd_limit_for_host { host user {mode "soft"} } {

   set command ""

   if {$mode == "soft"} {
      set command "-Sn"
   } 
   if {$mode == "hard"} {
      set command "-Hn"
   }
   if {$command == ""} {
      ts_log_severe "wrong argument: $mode\nSupported is \"hard\" or \"soft\""
      return ""
   }

   set output [start_remote_prog $host $user "ulimit" $command]
   set ret_val [string trim $output]
   ts_log_finer "fd $mode limit on host $host for user $user is $ret_val"
   return $ret_val
}

