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
#  Portions of this software are Copyright (c) 2024 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

#****** sge_users/set_user_defaults() ******************************************
#  NAME
#     set_user_defaults() -- create version dependent user settings
#
#  SYNOPSIS
#     set_user_defaults {change_array}
#
#  FUNCTION
#     Fills the array change_array with user attributes for the specific 
#     version of SGE.
#
#  INPUTS
#     change_array - the resulting array
#
#*******************************************************************************
proc set_user_defaults {change_array} {
   get_current_cluster_config_array ts_config
   upvar $change_array chgar

   set chgar(name)              "template"
   set chgar(oticket)           "0"
   set chgar(fshare)            "0"
   set chgar(default_project)   "NONE"
   set chgar(delete_time)    "0"
}

#****** sge_users/add_user() ***************************************************
#  NAME
#     add_user -- Add a new user configuration object
#
#  SYNOPSIS
#     add_user {user {change_array ""} {fast_add 1} {on_host ""} {as_user ""} 
#     {raise_error 1}}
#
#  FUNCTION
#     Add a user to the Cluster Scheduler (Grid Engine) cluster.
#     Supports fast (qconf -Auser) and slow (qconf -auser) mode.
#
#  INPUTS
#     user            - the name of the user
#     {change_array ""}- name of an array variable that will be set by get_config
#     {fast_add 1}    - use fast mode
#     {on_host ""}    - execute qconf on this host (default: qmaster host)
#     {as_user ""}    - execute qconf as this user (default: CHECK_USER)
#     {raise_error 1} - raise error condition in case of errors?
#
#  RESULT
#       0 - success
#     < 0 - error
#
#  SEE ALSO:
#     sge_procedures/handle_sge_error()
#     sge_project/get_project_messages()
#*******************************************************************************
proc add_user {user {change_array ""} {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   if { [ string compare $ts_config(product_type) "sge" ] == 0 } {
      ts_log_config "not possible for sge systems"
      return -9
   }

   upvar $change_array chgar
   set chgar(name) "$user"

   get_user_messages messages "add" "$user" $on_host $as_user
  
   if {$fast_add} {
      ts_log_fine "Add user $user from file ..."
      set option "-Auser"
      set_user_defaults old_config
      update_change_array old_config chgar
      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile old_config $on_host]
      set result [start_sge_bin "qconf" "$option $tmpfile" $on_host $as_user]
   } else {
      ts_log_fine "Add user $user slow ..."
      set option "-auser"
      set vi_commands [build_vi_command chgar]
      set result [start_vi_edit "qconf" "$option" $vi_commands messages $on_host $as_user]

   }
   unset chgar(name)
   return [handle_sge_errors "add_user" "qconf $option" $result messages $raise_error]
}

#****** sge_users/get_user() ***************************************************
#  NAME
#     get_user() -- get the user(s) info
#
#  SYNOPSIS
#     get_user {user change_array {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Calls qconf -suser $user to retrieve a user configuration
#
#  INPUTS
#     user                - user(s) name(s)
#     {change_array}      - result will be placed here
#     {on_host ""}        - execute qconf on this host, default is master host
#     {as_user ""}        - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1}     - raise an error condition on error (default), or just
#                           output the error message to stdout
#
#  RESULT
#     0 on success, an error code on error.
#     For a list of error codes, see sge_procedures/get_sge_error().
#
#  SEE ALSO
#     sge_procedures/handle_sge_error()
#     sge_users/get_user_messages()
#*******************************************************************************
proc get_user {user {change_array ""} {on_host ""} {as_user ""} {raise_error 1}} {
   get_current_cluster_config_array ts_config

   # user doesn't exist for sge systems
   if {[string compare $ts_config(product_type) "sge"] == 0} {
      ts_log_config "not possible for sge systems"
      return -9
}

   upvar $change_array out

   ts_log_fine "Get user $user ..."

   get_user_messages messages "get" "$user" $on_host $as_user
   
   return [get_qconf_object "get_user" "-suser $user" out messages 0 $on_host $as_user $raise_error]

}

#****** sge_users/del_user() ***************************************************
# 
#  NAME
#     del_user -- delete the user(s)
#
#  SYNOPSIS
#     del_user { user {on_host ""} {as_user ""} {raise_error 1} } 
#
#  FUNCTION
#     Deletes a user(s) using qconf -duser $user
#
#  INPUTS
#     user            - name(s) of the user(s)
#     {on_host ""}     - execute qconf on this host (default: qmaster host)
#     {as_user ""}     - execute qconf as this user (default: CHECK_USER)
#     {raise_error 1}  - raise error condition in case of errors?
#
#  RESULT
#       0 - success
#     < 0 - error
#
#  SEE ALSO
#     sge_procedures/handle_sge_errors
#     sge_users/sge_user_messages
#*******************************************************************************
proc del_user {user {on_host ""} {as_user ""} {raise_error 1}} {
   get_current_cluster_config_array ts_config

   if {$ts_config(product_type) == "sge"} {
      ts_log_config "del_user (qconf -duser) not available for sge systems" $raise_error
      return -1
   }

   ts_log_fine "Delete user $user ..."

   get_user_messages messages "del" "$user" $on_host $as_user

   set result [start_sge_bin "qconf" "-duser $user" $on_host $as_user]

   return [handle_sge_errors "del_user" "qconf -duser $user" $result messages $raise_error]
}

#****** sge_users/get_user_list() ***********************************************
#  NAME
#    get_user_list () -- get the list of users
#
#  SYNOPSIS
#     get_user_list { {output_var result} {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -suserl to retrieve the user list
#
#  INPUTS
#     {output_var result}  - result will be placed here
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#       0 - success
#     < 0 - error
#
#  SEE ALSO
#     sge_procedures/handle_sge_error()
#     sge_users/get_user_messages()
#*******************************************************************************
proc get_user_list {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
   get_current_cluster_config_array ts_config

   # user doesn't exist for sge systems
   if {[string compare $ts_config(product_type) "sge"] == 0} {
      ts_log_config "not possible for sge systems"
      return -9
   }
   
   ts_log_fine "Get user list ..."

   upvar $output_var out
   
   get_user_messages messages "list" "" $on_host $as_user 
   
   return [get_qconf_object "get_user_list" "-suserl" out messages 1 $on_host $as_user $raise_error]
}


#****** sge_users/mod_userlist() ******************************************
#  NAME
#     mod_userlist() -- Modify user list
#
#  SYNOPSIS
#     mod_userlist { userlist array  {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}}
#
#  FUNCTION
#     Modifies user in userlist
#
#  INPUTS
#     userlist     - user name to be modifies
#     array        - array containing the changed attributes.
#     {fast_add 1} - 0: modify the attribute using qconf -mckpt,
#                  - 1: modify the attribute using qconf -Mckpt, faster
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise an error condition on error (default), or just
#                       output the error message to stdout
#
#  RESULT
#
#*******************************************************************************
proc mod_userlist {userlist array {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   upvar $array current_ul

   get_userset_messages messages "mod" $userlist $on_host $as_user

   # Modify userlist from file
   if {$fast_add} {
      get_ulist $userlist old_ul
      foreach elem [array names current_ul] {
         set old_ul($elem) "$current_ul($elem)"
      }

      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile old_ul $on_host]
      set option "-Mu $tmpfile"
      set result [start_sge_bin "qconf" $option $on_host $as_user]
   } else {
      # do the work via vi
      set vi_commands [build_vi_command current_ul]
      set option "-mu $userlist"
      set result [start_vi_edit "qconf" $option $vi_commands messages $on_host $as_user]
   }

   set ret [handle_sge_errors "mod_userlist" "qconf $option" $result messages $raise_error]
   return $ret
}


#****** sge_users/mod_user() ***************************************************
#  NAME
#     mod_user() -- modify user configuration object
#
#  SYNOPSIS
#     mod_user {user change_array {fast_add 1} {on_host ""} {as_user ""} }
#
#  FUNCTION
#     modify user with qconf -muser or -Muser
#
#  INPUTS
#     user            - user name
#     change_array    - array name with settings to modifiy
#                       (e.g. set my_settings(default_project) NONE )
#                       -> array name "name" must be set (for username)
#     {fast_add 1} - if not 0 the add_calendar procedure will use a file for
#                    adding a calendar
#     {on_host ""}    - execute qconf on this host, default is master host
#     {as_user ""}    - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1} - raise error condition in case of errors
#
#  RESULT
#       0 - success
#     < 0 - error
#
#  SEE ALSO
#     sge_procedures/handle_sge_error()
#     sge_users/get_user_messages()
#*******************************************************************************
proc mod_user {user change_array {fast_add 1} {on_host ""} {as_user ""} {raise_error 1}} {
   global CHECK_USER
   get_current_cluster_config_array ts_config

   if { [ string compare $ts_config(product_type) "sge" ] == 0 } {
      ts_log_severe "not possible for sge systems"
      return -9
   }

   upvar $change_array chgar
   set chgar(name) "$user"

   get_user_messages messages "mod" "$user" $on_host $as_user

   if { $fast_add } {
      ts_log_fine "Modify user $user from file ..."
      set option "-Muser"
      get_user $user curr_user $on_host $as_user 0
      if {![info exists curr_user]} {
         set_user_defaults curr_user
      }
      update_change_array curr_user chgar
      if {$on_host == ""} {
         set on_host [config_get_best_suited_admin_host]
      }
      set tmpfile [dump_array_to_tmpfile curr_user $on_host]
      set result [start_sge_bin "qconf" "$option $tmpfile" $on_host $as_user]
   } else {
      ts_log_fine "Modify user $user slow ..."
      set option "-muser"
      set vi_commands [build_vi_command chgar]
      set result [start_vi_edit "qconf" "$option $user" $vi_commands messages $on_host $as_user]
   }

   return [handle_sge_errors "mod_user" "qconf $option $user" $result messages $raise_error]
}

#****** sge_users/get_manager_list() *****************************************
#  NAME
#     get_manager_list() -- get the list of managers
#
#  SYNOPSIS
#     get_manager_list { {output_var result} {on_host ""} {as_user ""} 
#     {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -sm to retrieve a list of managers
#
#  INPUTS
#     {output_var result} - result output
#     {on_host ""}        - execute qconf on this host, default is master host
#     {as_user ""}        - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1}     - raise an error condition on error (default), or just
#                           output the error message to stdout
#
#  RESULT
#     0 on success, an error code on error.
#     For a list of error codes, see sge_procedures/get_sge_error().
#
#  SEE ALSO
#     sge_procedures/get_sge_error()
#     sge_procedures/get_qconf_list()
#*******************************************************************************
proc get_manager_list {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $output_var out

   return [get_qconf_list "get_manager_list" "-sm" out $on_host $as_user $raise_error]

}
#****** sge_users/add_manager() *****************************************
#  NAME
#     add_manager() -- add manager
#
#  SYNOPSIS
#     add_manager {manager {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -am $manager to add manager
#
#  INPUTS
#     manager         - manager to be added by qconf -am
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
proc add_manager {manager {on_host ""} {as_user ""} {raise_error 1}} {
   return [get_qconf_list "add_manager" "-am $manager" out $on_host $as_user $raise_error]
}

#****** sge_users/del_manager() *****************************************
#  NAME
#     del_manager() -- delete manager
#
#  SYNOPSIS
#     del_manager {manager {on_host ""} {as_user ""} {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -dm $manager to add manager
#
#  INPUTS
#     manager         - manager to be deleted by qconf -dm
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
proc del_manager {manager {on_host ""} {as_user ""} {raise_error 1}} {
   return [get_qconf_list "del_manager" "-dm $manager" out $on_host $as_user $raise_error]
}


#****** sge_users/get_operator_list() *****************************************
#  NAME
#     get_operator_list() -- get the list of operators
#
#  SYNOPSIS
#     get_operator_list {{output_var result} {on_host ""} {as_user ""} 
#     {raise_error 1}  }
#
#  FUNCTION
#     Calls qconf -so to retrieve a list of operators
#
#  INPUTS
#     {output_var result} - result output
#     {on_host ""}        - execute qconf on this host, default is master host
#     {as_user ""}        - execute qconf as this user, default is $CHECK_USER
#     {raise_error 1}     - raise an error condition on error (default), or just
#                           output the error message to stdout
#
#  RESULT
#     0 on success, an error code on error.
#     For a list of error codes, see sge_procedures/get_sge_error().
#
#  SEE ALSO
#     sge_procedures/get_sge_error()
#     sge_procedures/get_qconf_list()
#*******************************************************************************
proc get_operator_list {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
   upvar $output_var out
   
   return [get_qconf_list "get_operator_list" "-so" out $on_host $as_user $raise_error]

}

#****** sge_procedures/add_operator() ******
# 
#  NAME
#     add_operator
#
#  SYNOPSIS
#     add_operator { anOperator } 
#
#  FUNCTION
#     Add user ''anOperator'' to operator list.
#
#  INPUTS
#     anOperator - Operator to add
#
#  RESULT
#     0 - Operator has been successfully added
#    -1 - Otherwise 
#
#  SEE ALSO
#     sge_procedures/delete_operator
#
#*******************************
#
proc add_operator { anOperator } {
   get_current_cluster_config_array ts_config

   set result [start_sge_bin "qconf" "-ao $anOperator" ]
   set result [string trim $result]

   set ADDEDTOLIST   [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_ADDEDTOLIST_SSSS] "*" "*" $anOperator "*" ]
   set ALREADYEXISTS [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_ALREADYEXISTS_SS] "*" $anOperator ]

   if {[string match $ADDEDTOLIST $result]} {
      ts_log_fine "added $anOperator to operator list"
      return 0
   } elseif {[string match $ALREADYEXISTS $result]} {
      ts_log_fine "operator $anOperator already exists"
      return 0
      } else {
      return -1
      }
   }

#                                                             max. column:     |
#****** sge_procedures/delete_operator() ******
# 
#  NAME
#     delete_operator
#
#  SYNOPSIS
#     delete_operator { anOperator } 
#
#  FUNCTION
#     Delete user ''anOperator'' from operator list.
#
#  INPUTS
#     anOperator - Operator to delete
#
#  RESULT
#     0 - Operator has been successfully deleted
#    -1 - Otherwise 
#
#  SEE ALSO
#     sge_procedures/add_operator
#
#*******************************
#
proc delete_operator {anOperator} {
   get_current_cluster_config_array ts_config

   set result [start_sge_bin "qconf" "-do $anOperator"]
   set result [string trim $result]

   set REMOVEDFROMLIST [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_REMOVEDFROMLIST_SSSS] "*" "*" $anOperator "*" ]
   set DOESNOTEXIST [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_SGETEXT_DOESNOTEXIST_SS] "*" $anOperator ]

   if {[string match $REMOVEDFROMLIST $result]} {
      ts_log_fine "removed $anOperator from operator list"
      return 0
   } elseif {[string match $DOESNOTEXIST $result]} {
      ts_log_fine "operator $anOperator does not exists"
      return 0
   } else {
      return -1
   }
}

#****** sge_user/get_user_messages() *******************************************
#  NAME
#     get_user_messages() -- returns the set of messages related to action 
#                              on user, i.e. add, modify, delete, get
#
#  SYNOPSIS
#     get_user_messages {msg_var action obj_name result {on_host ""} {as_user ""}} 
#
#  FUNCTION
#     Returns the set of messages related to action on sge object. This function
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
proc get_user_messages {msg_var action obj_name {on_host ""} {as_user ""}} {
   get_current_cluster_config_array ts_config

   upvar $msg_var messages
   if { [info exists messages]} {
      unset messages
   }

   set USER [translate_macro MSG_OBJ_USER]

   sge_client_messages messages $action $USER $obj_name $on_host $as_user

   # the place for exceptions: # VD version dependent  
   #                           # CD client dependent
   # see sge_procedures/sge_client_messages
   switch -exact $action {
      "add" {
         add_message_to_container messages -4 "error: [translate_macro MSG_ULONG_INCORRECTSTRING "*"]"
         add_message_to_container messages -5 [translate_macro MSG_SGETEXT_DOESNOTEXIST_SS "project" "*"]
         #define MSG_USER_INVALIDNAMEX_S             _MESSAGE(23048, _("invalid user name "SFQ))
      }
      "get" {
         add_message_to_container messages -1 [translate_macro MSG_USER_XISNOKNOWNUSER_S $obj_name]
      }
      "list" {
         # BUG: not correct message
         set NOT_DEFINED [translate_macro MSG_QCONF_NOXDEFINED_S "$USER list"]
         add_message_to_container messages -1 $NOT_DEFINED
      }
      "mod" {
         # BUG: not generic message
         add_message_to_container messages -1 [translate_macro MSG_USER_XISNOKNOWNUSER_S $obj_name]
         add_message_to_container messages -6 "error: [translate_macro MSG_ULONG_INCORRECTSTRING "*"]"
         add_message_to_container messages -7 [translate_macro MSG_SGETEXT_DOESNOTEXIST_SS "project" "*"]
      }
      "del" {
         #
      }
   } 
}
