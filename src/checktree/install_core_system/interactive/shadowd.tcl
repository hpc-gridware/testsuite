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

proc install_shadowd {} {
   global ts_config
   global CORE_INSTALLED
   global check_use_installed_system
   global CHECK_COMMD_PORT CHECK_ADMIN_USER_SYSTEM CHECK_USER
   global CHECK_DEBUG_LEVEL CHECK_EXECD_INSTALL_OPTIONS
   global CHECK_COMMD_PORT
   global CHECK_MAIN_RESULTS_DIR

   set CORE_INSTALLED ""
   read_install_list

   set shadowd_hosts [replace_string $ts_config(shadowd_hosts) "none" ""]
   if {[string trim $shadowd_hosts] == ""} {
      return
   }

   if {!$check_use_installed_system} {
      set feature_install_options ""
      set my_csp_host_list ""

      # are we installing secure Cluster Scheduler (Grid Engine)?
      if {$ts_config(product_feature) == "csp"} {
         set feature_install_options "-csp"
         set my_csp_host_list $shadowd_hosts
      }

      # if $my_csp_host_list != "" we copy certificates
      foreach shadow_host $my_csp_host_list {
         if {$shadow_host == $ts_config(master_host)} {
            continue
         }
         copy_certificates $shadow_host
      }
   }

   foreach shadow_host $shadowd_hosts {
      ts_log_fine "testing shadowd settings for host $shadow_host ..."
      set info [check_shadowd_settings $shadow_host]
      if {$info != ""} {
         ts_log_severe "skipping shadowd installation for host $shadow_host:\n$info"
         continue
      }

      ts_log_fine "installing shadowd on host $shadow_host ($ts_config(product_type) system) ..."
      if {$check_use_installed_system != 0} {
         puts "no need to install shadowd on hosts \"$shadowd_hosts\", noinst parameter is set"
         if {[startup_shadowd $shadow_host] == 0} {
            lappend CORE_INSTALLED $shadow_host
            write_install_list
            continue
         } else {
            ts_log_warning "could not startup shadowd on host $shadow_host"
            return
         }
      }

      if {[file isfile "$ts_config(product_root)/inst_sge"] != 1} {
         ts_log_severe "inst_sge file not found"
         return
      }

      set remote_arch [resolve_arch $shadow_host]

      set HIT_RETURN_TO_CONTINUE       [translate $shadow_host 0 1 0 [sge_macro DISTINST_HIT_RETURN_TO_CONTINUE] ]
      set SHADOWD_INSTALL_COMPLETE     [translate $shadow_host 0 1 0 [sge_macro DISTINST_SHADOWD_INSTALL_COMPLETE] ]
      set ANSWER_YES                   [translate $shadow_host 0 1 0 [sge_macro DISTINST_ANSWER_YES] ]
      set ANSWER_NO                    [translate $shadow_host 0 1 0 [sge_macro DISTINST_ANSWER_NO] ]
      set INSTALL_SCRIPT               [translate $shadow_host 0 1 0 [sge_macro DISTINST_INSTALL_SCRIPT] "*" ]
      set IF_NOT_OK_STOP_INSTALLATION  [translate $shadow_host 0 1 0 [sge_macro DISTINST_IF_NOT_OK_STOP_INSTALLATION] ]
      set MESSAGES_LOGGING             [translate $shadow_host 0 1 0 [sge_macro DISTINST_MESSAGES_LOGGING] ]
      set CURRENT_GRID_ROOT_DIRECTORY  [translate $shadow_host 0 1 0 [sge_macro DISTINST_CURRENT_GRID_ROOT_DIRECTORY] "*" "*" ]
      set CHECK_ADMINUSER_ACCOUNT      [translate $shadow_host 0 1 0 [sge_macro DISTINST_CHECK_ADMINUSER_ACCOUNT] "*" "*" "*" "*" ]
      set CHECK_ADMINUSER_ACCOUNT_ANSWER      [translate $shadow_host 0 1 0 [sge_macro DISTINST_CHECK_ADMINUSER_ACCOUNT_ANSWER] ]
      set SHADOW_INFO                  [translate $shadow_host 0 1 0 [sge_macro DISTINST_SHADOW_INFO] ]
      set SHADOW_ROOT                  [translate $shadow_host 0 1 0 [sge_macro DISTINST_SHADOW_ROOT] "*" ]
      set SHADOW_CELL                  [translate $shadow_host 0 1 0 [sge_macro DISTINST_SHADOW_CELL] ]
      set HOSTNAME_KNOWN_AT_MASTER     [translate $shadow_host 0 1 0 [sge_macro DISTINST_HOSTNAME_KNOWN_AT_MASTER] ]
      set OTHER_USER_ID_THAN_ROOT      [translate $shadow_host 0 1 0 [sge_macro DISTINST_OTHER_USER_ID_THAN_ROOT] ]
      set INSTALL_AS_ADMIN_USER        [translate $shadow_host 0 1 0 [sge_macro DISTINST_INSTALL_AS_ADMIN_USER] "$CHECK_USER" ]
      set DETECT_CHOOSE_NEW_NAME       [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DETECT_CHOOSE_NEW_NAME] ]
      set DETECT_REMOVE_OLD_CLUSTER    [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DETECT_REMOVE_OLD_CLUSTER] ]
      set SMF_IMPORT_SERVICE           [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_SMF_IMPORT_SERVICE] ]
      set DO_YOU_WANT_TO_CONTINUE      [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DO_YOU_WANT_TO_CONTINUE] ]
      set REMOVE_OLD_RC_SCRIPT         [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_REMOVE_OLD_RC_SCRIPT] ]

      ts_log_fine "inst_sge -sm"

      if {$CHECK_ADMIN_USER_SYSTEM == 0} {
         set user "root"
      } else {
         set user $CHECK_USER
         ts_log_fine "--> install as user $CHECK_USER <--"
      }
      set id [open_remote_spawn_process $shadow_host $user "./inst_sge" "-sm" 0 $ts_config(product_root) "" 1 15 0 1 1]
      set sp_id [ lindex $id 1 ]

      set do_stop 0
      while {$do_stop == 0} {
         flush stdout
         if {$CHECK_DEBUG_LEVEL == 2} {
            puts "press RETURN"
            set anykey [wait_for_enter 1]
         }

         set timeout 300
         log_user 1
         expect {
            -i $sp_id full_buffer {
               ts_log_warning "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
               close_spawn_process $id
               return
            }

            -i $sp_id eof {
               ts_log_severe "unexpeced eof"
               set do_stop 1
               continue
            }

            -i $sp_id "coredump" {
               ts_log_warning "coredump on host $shadow_host"
               set do_stop 1
               continue
            }

            -i $sp_id timeout {
               ts_log_severe "timeout while waiting for output"
               set do_stop 1
               continue
            }

            -i $sp_id $SHADOW_CELL {
               install_send_answer $sp_id $ts_config(cell)
               continue
            }

            -i $sp_id -- $DETECT_CHOOSE_NEW_NAME {
               install_send_answer $sp_id $ANSWER_YES
               continue
            }

            # Delete detected services for chosen cluster_name
            -i $sp_id -- $DETECT_REMOVE_OLD_CLUSTER {
               install_send_answer $sp_id $ANSWER_NO
               continue
            }

            # Remove conflicting RC files/SMF service
            -i $sp_id -- $REMOVE_OLD_RC_SCRIPT  {
               install_send_answer $sp_id $ANSWER_YES
               continue
            }

            -i $sp_id $HOSTNAME_KNOWN_AT_MASTER {
               install_send_answer $sp_id ""
               continue
            }

            -i $sp_id $INSTALL_AS_ADMIN_USER {
               install_send_answer $sp_id $ANSWER_YES
               continue
            }

            -i $sp_id $MESSAGES_LOGGING {
               install_send_answer $sp_id ""
               continue
            }

            -i $sp_id -- $IF_NOT_OK_STOP_INSTALLATION {
               if {$CHECK_ADMIN_USER_SYSTEM != 0} {
                  install_send_answer $sp_id ""
                  continue
               } else {
                  ts_log_warning "host $shadow_host: tried to install not as root"
                  close_spawn_process $id
                  return
               }
            }

            -i $sp_id $INSTALL_SCRIPT {
               install_send_answer $sp_id $ANSWER_NO
               continue
            }

            # SMF startup is always disabled in testsuite
            -i $sp_id -- $SMF_IMPORT_SERVICE {
               install_send_answer $sp_id $ANSWER_NO
               continue
            }

            -i $sp_id -- $DO_YOU_WANT_TO_CONTINUE {
               install_send_answer $sp_id $ANSWER_YES
               continue
            }

            -i $sp_id "Error:" {
               ts_log_warning "$expect_out(0,string)"
               close_spawn_process $id
               return
            }
            -i $sp_id "can't resolve hostname*\n" {
               ts_log_warning "$expect_out(0,string)"
               close_spawn_process $id
               return
            }
            -i $sp_id "error:\n" {
               ts_log_warning "$expect_out(0,string)"
               close_spawn_process $id
               return
            }

            -i $sp_id $CURRENT_GRID_ROOT_DIRECTORY {
               install_send_answer $sp_id ""
               continue
            }

            -i $sp_id $SHADOWD_INSTALL_COMPLETE {
               read_install_list
               lappend CORE_INSTALLED $shadow_host
               write_install_list
               set do_stop 1
               # If we compiled with code coverage, we have to
               # wait a little bit before closing the connection.
               # Otherwise the last command executed (infotext)
               # will leave a lockfile lying around.
               if {[coverage_enabled]} {
                  after 2000
               }
               continue
            }

            -i $sp_id $HIT_RETURN_TO_CONTINUE {
               install_send_answer $sp_id ""
               continue
            }

            -i $sp_id $SHADOW_ROOT {
               install_send_answer $sp_id ""
               continue
            }

            -i $sp_id "_exit_status_:(0)" {
               # N1GE 6.0 shadowd installation just stops after starting the shadowd
               # without further notice. Let's hope inst_sge -sm doesn't exit 0 in
               # case of errors - we wouldn't recognize them!
               set do_stop 1
            }

            -i $sp_id default {
               ts_log_warning "undefined behaviour: $expect_out(buffer)"
               close_spawn_process $id
               return
            }
         } ;# expect
      } ;# while

      # close connection to inst_sge
      close_spawn_process $id
   }

   foreach shadow_host $shadowd_hosts {
      set my_timeout [timestamp]
      incr my_timeout 60
      set is_running 0
      while {[timestamp] < $my_timeout} {
         # Expect to see sge_shadowd running.
         # We migth see multiple processes if the sge_shadowd is starting up/daemonizing
         # slowly, e.g. due to coverage testing or other instrumentation,
         # therefore we make is_daemon_running ignore the process count.
         set running_daemons [is_daemon_running $shadow_host "sge_shadowd" 1]
         if {$running_daemons != 1} {
            ts_log_fine "waiting for running shadowd on host $shadow_host (reported daemons=$running_daemons) ..."
         } else {
            set is_running 1
            break
         }
         after 1000
      }
      if {$is_running == 0} {
         ts_log_severe "shadowd on host $shadow_host is not running"
         break
      }
   }
}

