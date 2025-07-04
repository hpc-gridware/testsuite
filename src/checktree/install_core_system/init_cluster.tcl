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
#  Portions of this software are Copyright (c) 2011 Univa Corporation
#
#  Portions of this software are Copyright (c) 2023-2024 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

proc kill_running_system {} {
   global ts_config
   global CHECK_USER CORE_INSTALLED
   global check_use_installed_system

   set result [check_all_system_times]
   ts_log_fine "check_all_system_times returned $result"
   if {$result != 0} {
      ts_log_warning "skipping install_core_system"
      return
   }

   set CORE_INSTALLED ""
   write_install_list

   shutdown_core_system

   if {$check_use_installed_system == 0} {
      if {[remote_file_isdirectory $ts_config(master_host) "$ts_config(product_root)/$ts_config(cell)"]} {
         # if the $SGE_ROOT/$SGE_CELL exists, delete it
         delete_directory "$ts_config(product_root)/$ts_config(cell)"
      }
      # wait for the directory to vanish on all cluster hosts - otherwise installation might fail
      foreach host [get_all_hosts] {
         wait_for_remote_dir $host $CHECK_USER "$ts_config(product_root)/$ts_config(cell)" 60 1 1
      }
   }
}


# generating all testsuite cluster user keys and certificates
proc make_user_cert {} {
   global check_use_installed_system
   global CHECK_MAIN_RESULTS_DIR
   global CHECK_FIRST_FOREIGN_SYSTEM_USER CHECK_SECOND_FOREIGN_SYSTEM_USER CHECK_REPORT_EMAIL_TO
   global CHECK_USER CHECK_DEBUG_LEVEL
   global ts_config
   global CHECK_USER CHECK_ADMIN_USER_SYSTEM

   if {$CHECK_ADMIN_USER_SYSTEM == 0 } {
      set cert_user "root"
   } else {
      set cert_user $CHECK_USER
   }

   if { !$check_use_installed_system } {
      # create testsuite user certificates for csp mode
       if {$ts_config(product_feature) == "csp"} {
          ts_log_fine "removing poss. existing user_file.txt \"$CHECK_MAIN_RESULTS_DIR/user_file.txt\" ..."
          set result [ start_remote_prog "$ts_config(master_host)" "$CHECK_USER" "rm" "$CHECK_MAIN_RESULTS_DIR/user_file.txt" ]
          ts_log_fine $result

          ts_log_fine "creating file \"$CHECK_MAIN_RESULTS_DIR/user_file.txt\" ..."
          set script [ open "$CHECK_MAIN_RESULTS_DIR/user_file.txt" "w" ]
          puts $script "$CHECK_FIRST_FOREIGN_SYSTEM_USER:first_testsuite_user:$CHECK_REPORT_EMAIL_TO"
          puts $script "$CHECK_SECOND_FOREIGN_SYSTEM_USER:second_testsuite_user:$CHECK_REPORT_EMAIL_TO"
          flush $script
          close $script

          set result [ start_remote_prog "$ts_config(master_host)" $cert_user "util/sgeCA/sge_ca" "-usercert $CHECK_MAIN_RESULTS_DIR/user_file.txt" prg_exit_state 60 0 $ts_config(product_root)]
          ts_log_fine $result

          ts_log_fine "removing poss. existing user_file.txt \"$CHECK_MAIN_RESULTS_DIR/user_file.txt\" ..."
          set result [ start_remote_prog "$ts_config(master_host)" "$CHECK_USER" "rm" "$CHECK_MAIN_RESULTS_DIR/user_file.txt" ]
          ts_log_fine $result
      } else {
         ts_log_fine "no csp feature enabled"
      }
   }
}

proc cleanup_system {} {
   global env
   global check_use_installed_system CHECK_USER
   global ts_config

#puts "press RETURN"
#set anykey [wait_for_enter 1]
   # check if the system is running and qmaster accessable
   set result [start_sge_bin "qstat" ""]
   if { $prg_exit_state != 0 } {
      ts_log_warning "error connecting qmaster: $result"
      return
   }

   ts_log_newline
   ts_log_fine "cleaning up system"

   # delete all jobs
   delete_all_jobs

   # wait until cluster is empty
   wait_for_end_of_all_jobs

   # remove sharetree
   del_sharetree

   # remove all checkpoint environments
   ts_log_newline
   ts_log_fine "removing ckpt objects ..."
   set NO_CKPT_INTERFACE_DEFINED [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_QCONF_NOXDEFINED_S] "ckpt interface definition"]

   set result [start_sge_bin "qconf" "-sckptl"]

   if { [string first $NO_CKPT_INTERFACE_DEFINED $result] >= 0 } {
      ts_log_fine "no ckpt interface definition defined"
   } else {
      foreach elem $result {
         ts_log_fine "removing ckpt interface $elem"
         del_ckpt $elem
      }
   }

   # remove all parallel environments
   ts_log_newline
  ts_log_fine "removing PE objects ..."
  set NO_PARALLEL_ENVIRONMENT_DEFINED [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_QCONF_NOXDEFINED_S] "parallel environment"]
  set result [start_sge_bin "qconf" "-spl"]

  if { [string first $NO_PARALLEL_ENVIRONMENT_DEFINED $result] >= 0 } {
     ts_log_fine "no parallel environment defined"
  } else {
     foreach elem $result {
        ts_log_fine "removing PE $elem."
        del_pe $elem
     }
  }

   # remove all calendars
   ts_log_newline
  ts_log_fine "removing calendars ..."
  # JG: TODO: calendars can be referenced in queues - first remove all references!
  set NO_CALENDAR_DEFINED [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_QCONF_NOXDEFINED_S] "calendar"]
  set result [start_sge_bin "qconf" "-scall"]

  if { [string first $NO_CALENDAR_DEFINED $result] >= 0 } {
     ts_log_fine "no calendar defined"
  } else {
     foreach elem $result {
        ts_log_fine "removing calendar $elem."
        del_calendar $elem
     }
  }

   # remove all projects
   ts_log_newline
   ts_log_fine "removing project objects ..."
   set NO_PROJECT_LIST_DEFINED [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_QCONF_NOXDEFINED_S] "project list"]
   set result [start_sge_bin "qconf" "-sprjl"]

   if { [string first $NO_PROJECT_LIST_DEFINED $result] >= 0 } {
      ts_log_fine "no project list defined"
   } else {
      foreach elem $result {
         ts_log_fine "removing project $elem."
         del_project $elem
      }
   }

   # JG: TODO: what about SGEEE users?

   # remove all access lists
   # JG: TODO: accesslists are referenced in a variety of objects - first delete them
   #           there!
   ts_log_newline
  ts_log_fine "removing access lists ..."
  set NO_ACCESS_LIST_DEFINED [translate $ts_config(master_host) 1 0 0 [sge_macro MSG_QCONF_NOXDEFINED_S] "userset list"]
  set result [start_sge_bin "qconf" "-sul"]

  if { [string first $NO_ACCESS_LIST_DEFINED $result] >= 0 } {
     ts_log_fine "no userset list defined"
  } else {
     foreach elem $result {
        if { [ string compare $elem defaultdepartment ] == 0 } {
           ts_log_fine "skipping \"defaultdepartment\" ..."
           continue
        }
        ts_log_fine "removing userset list $elem."
        del_access_list $elem
     }
  }

   # remove all queues
   ts_log_newline
   ts_log_fine "removing queues ..."
   get_queue_list queue_list
   foreach elem $queue_list {
      ts_log_fine "removing queue $elem."
      del_queue $elem "" 1 1
   }

   # cleanup the tmpdir's referenced in queues
   cleanup_tmpdirs

   # add new testsuite queues
   ts_log_newline
  ts_log_fine "adding testsuite queues ..."
  add_queue "all.q" "@allhosts" q_param 1


  # execute the clean hooks of all checktrees
  if { [ exec_checktree_clean_hooks ] != 0 } {
     ts_log_config "exec_checktree_clean_hooks reported an error"
  }
}

proc setup_queues {} {
   global env
   global check_use_installed_system CHECK_USER
   global ts_config

   # check if qmaster can be accessed
   set result [start_sge_bin "qstat" ""]
   if {$prg_exit_state != 0} {
      ts_log_warning "error connecting qmaster: $result"
      return
   }

   # for all queues: set load_thresholds and queue type
   set new_values(load_thresholds)       "np_load_avg=11.00"
   set new_values(qtype)                 "BATCH INTERACTIVE CHECKPOINTING PARALLEL"

   set result [mod_queue "all.q" "" new_values]
   switch -- $result {
      -1 {
         ts_log_severe "modify queue all.q - got timeout"
      }
      -100 {
         ts_log_severe "could not modify queue"
      }
   }

   if {$result == 0} {
      # for each individual queue set the slots attribute
      foreach hostname $ts_config(execd_nodes) {
         unset new_values
         set index [lsearch $ts_config(execd_nodes) $hostname]
         set slots_tmp [node_get_processors $hostname]

         if {$slots_tmp <= 0} {
            ts_log_warning "no slots for execd $hostname"
            return
         }

         set slots [expr $slots_tmp * 10]
         # We setup a gid_range of size 100 for the cluster,
         # so we can start a maximum of 100 jobs or tasks per host.
         # Set a maximum of 100 slots
         if {$slots > 100} {
            set slots 100
         }
         set new_values(slots) $slots

         set result [mod_queue "all.q" $hostname new_values]
         switch -- $result {
            -1 {
               ts_log_severe "modify queue ${hostname}.q - got timeout"
            }
            -100 {
               ts_log_severe "could not modify queue"
            }
         }
      }
   }

   # wait until all hosts are up
   if {$result == 0} {
      wait_for_load_from_all_queues 300
   }
}

#                                                             max. column:     |
#****** install_core_system/setup_testcheckpointobject() ******
#
#  NAME
#     setup_testcheckpointobject -- ???
#
#  SYNOPSIS
#     setup_testcheckpointobject { }
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
#*******************************
proc setup_testcheckpointobject {} {
   set ckpt_name "testcheckpointobject"
   add_ckpt $ckpt_name
   assign_queues_with_ckpt_object "all.q" "" $ckpt_name
}

#                                                             max. column:     |
#****** install_core_system/setup_conf() ******
#
#  NAME
#     setup_conf -- ???
#
#  SYNOPSIS
#     setup_conf { }
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
#*******************************
proc setup_conf {} {
  global CHECK_DEFAULT_DOMAIN
  global CHECK_REPORT_EMAIL_TO
  global CHECK_USER
  global CHECK_DNS_DOMAINNAME

  global ts_config

  get_config old_config
  set params(reschedule_unknown) "00:00:00"
  set_config params
  get_config old_config

  # set finished_job in global config
  set params(finished_jobs) "0"
  set params(load_report_time) "00:00:15"
  set params(reschedule_unknown) "00:00:00"
  set params(loglevel) "log_info"
  set params(load_sensor) "none"
  set params(prolog) "none"
  set params(epilog) "none"
  if {[is_version_in_range "9.0.0"]} {
    set params(shell_start_mode) "unix_behavior"
  } else {
    set params(shell_start_mode) "posix_compliant"
  }
  set params(login_shells) "sh,bash,ksh,csh,tcsh"
  set params(min_uid) "0"
  set params(min_gid) "0"
  set params(user_lists) "none"
  set params(xuser_lists) "none"
  set params(max_unheard) "00:01:00"

  if { $CHECK_REPORT_EMAIL_TO == "none" } {
     set params(administrator_mail) "${CHECK_USER}@${CHECK_DNS_DOMAINNAME}"
  } else {
     set params(administrator_mail) $CHECK_REPORT_EMAIL_TO
  }

  set params(set_token_cmd) "none"
  set params(pag_cmd) "none"
  set params(token_extend_time) "none"
  set params(shepherd_cmd) "none"
  set params(qmaster_params) "none"
  set params(reporting_params) "accounting=true reporting=false flush_time=00:00:05 joblog=true sharelog=00:10:00"
  set params(max_aj_instances) "2000"
  set params(max_aj_tasks) "75000"

  # default domain and ignore_fqdn have moved to the bootstrap file
  # in SGE 6.0. Only check them in older systems.
  if [info exists old_config(default_domain)] {
    set params(default_domain) "$CHECK_DEFAULT_DOMAIN"
  }
  if [info exists old_config(ignore_fqdn)] {
    set params(ignore_fqdn) "true"
  }
  if [info exists old_config(mail_tag)] {
     set params(mail_tag) [get_mail_tag]
  }


  set params(execd_params)    "PTF_MIN_PRIORITY=20,PTF_MAX_PRIORITY=0,SET_LIB_PATH=true"
  if {[ge_has_feature "systemd"]} {
     append params(execd_params) ",USAGE_COLLECTION=HYBRID"
  }
  set params(enforce_project) "false"
  set params(projects) "none"
  set params(xprojects) "none"

  set_config params

  get_config new_config

  set arrays_old [ array names old_config ]
  set arrays_new [ array names new_config ]

  if { [ llength $arrays_old] == [ llength $arrays_new ] } {
    foreach param $arrays_old {
       set old  $old_config($param)
       set new  $new_config($param)

       if {[string compare -nocase $old $new] != 0} {
          set name_list [list "reschedule_unknown" "load_report_time" "loglevel" "execd_params" "finished_jobs" "max_unheard" "reporting_params" "mail_tag"]
          if {[lsearch -exact $name_list $param] != -1} {
             continue
          }

          ts_log_config "config parameter $param:\ndefault setup: $old, after testsuite reset: $new"
       }
    }
  } else {
      foreach elem $arrays_old {
         if { [string first $elem $arrays_new] < 0 } {
            ts_log_severe "parameter $elem not in new configuration"
         }
      }
      foreach elem $arrays_new {
         if { [string first $elem $arrays_old] < 0 } {
           ts_log_severe "parameter $elem not in old configuration"
         }
      }

     ts_log_severe "config parameter count new/old configuration error"
  }

   # if we have no local configurations, set a few parameters here
   # based on what the qmaster host needs
   global check_do_not_create_local_config
   if {$check_do_not_create_local_config} {
      set change_config 1
      set xterm [get_binary_path $ts_config(master_host) "xterm"]
      if {$xterm != "xterm"} {
         set add_params(xterm) $xterm
      }
      set mailer [get_binary_path $ts_config(master_host) "mailx"]
      if {$mailer != "mailx"} {
         set add_params(mailer) $mailer
      }
      set execd_spooldir [get_local_spool_dir $ts_config(master_host) execd 0]
      if {$execd_spooldir != ""} {
         set add_params(execd_spool_dir) $execd_spooldir
         set errors ""
         foreach host $ts_config(execd_nodes) {
            set host_spooldir [get_local_spool_dir $host execd 0]
            if {$host_spooldir != $execd_spooldir} {
               append errors "host $host has different spooldir: $host_spooldir, expected $execd_spooldir\n"
            }
         }
         if {$errors != ""} {
            ts_log_severe $errors
            set change_config 0
         }
      }
      if {$change_config} {
         set_config add_params
      }
   }
}

#****** check/setup_execd_conf() ***********************************************
#  NAME
#     setup_execd_conf() -- ???
#
#  SYNOPSIS
#     setup_execd_conf { }
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
proc setup_execd_conf {} {
   global CHECK_DEFAULT_DOMAIN
   global CHECK_INTERACTIVE_TRANSPORT check_use_installed_system
   global ts_config
   global CHECK_USER
   global check_do_not_create_local_config

   set host_list $ts_config(execd_nodes)
   foreach sh_host $ts_config(shadowd_hosts) {
      if {[lsearch -exact $host_list $sh_host] == -1} {
         lappend host_list $sh_host
      }
   }

   # has testsuite has been started with --no_local_config?
   if {$check_do_not_create_local_config} {
      ts_log_fine "not creating local config - deleting existing ones"
      foreach host $host_list {
         ts_log_fine [start_sge_bin "qconf" "-dconf $host" $ts_config(master_host)]
      }
      return
   }

   foreach host $host_list {
      ts_log_fine "get configuration for host $host ..."
      get_config tmp_config $host 60 0
      if {![info exists tmp_config]} {
         ts_log_info "couldn't get conf - adding new local config for host $host"
         set elements "qlogin_command qlogin_daemon rlogin_command rlogin_daemon rsh_command rsh_daemon xterm load_sensor execd_params execd_spool_dir"
         set existing_config 0
      } else {
         set elements [array names tmp_config]
         set existing_config 1
      }

      if {[lsearch -exact $ts_config(execd_nodes) $host] != -1} {
         set is_execd_host 1
         ts_log_fine "host \"$host\" is a execd host!"
      } else {
         set is_execd_host 0
      }

      set counter 0
      set output ""
      set removed ""
      set have_exec_spool_dir [get_local_spool_dir $host execd 0]
      set spool_dir 0
      if {$CHECK_INTERACTIVE_TRANSPORT == "default"} {
         # default for GE versions >= 62 (no rtools)
         set expected_entries 2
      } else {
         # rtools (rlogin, telnetd, rsh) >= 6.2 or ssh
         set expected_entries 8
      }

      if {$have_exec_spool_dir != "" && $is_execd_host} {
         ts_log_fine "host $host has spooldir in \"$have_exec_spool_dir\""
         set spool_dir 1
         incr expected_entries 1
      }

      set spool_dir_found 0
      set win_execd_params_found 0
      foreach elem $elements {
         if {$existing_config} {
            append output "$elem is set to $tmp_config($elem)\n"
         }
         incr counter 1
         switch $elem {
            "mailer" -
            "libjvm_path" -
            "additional_jvm_args" { continue }
            "qlogin_command" -
            "qlogin_daemon" -
            "rlogin_command" -
            "rlogin_daemon" -
            "rsh_command" -
            "rsh_daemon" {
               if {$CHECK_INTERACTIVE_TRANSPORT == "default"} {
                  # in 6.2, we don't have these entries in local config
                  # in earlier releases, we only have qlogin_daemon and rlogin_daemon
                  lappend removed $elem
               }
            }
            "xterm" {
               if {!$existing_config || ![is_remote_file $host $CHECK_USER $tmp_config($elem)]} {
                  set config_xterm_path [get_binary_path $host "xterm" 0]
                  if {$config_xterm_path == "xterm"} {
                     ts_log_config "xterm seems not to be installed on host $host - setting /usr/bin/xterm"
                     set tmp_config($elem) "/usr/bin/xterm"
                  } else {
                     set tmp_config($elem) $config_xterm_path
                  }
               }
            }
            "load_sensor" {
               lappend removed $elem
            }
            "execd_params" {
               lappend removed $elem
            }
            "execd_spool_dir" {
               if {$existing_config && [string compare $have_exec_spool_dir $tmp_config(execd_spool_dir)] == 0} {
                  set spool_dir_found 1
               }
               if {$spool_dir == 0} {
                  lappend removed $elem
               }
            }
            default {
               lappend removed $elem
            }
         }
      }

      # execd_spool_dir has to be set correctly (depending on testsuite configuration)
      if {$spool_dir == 1 && $spool_dir_found == 0 && $is_execd_host} {
         if {$existing_config} {
            ts_log_config "host $host should have spool dir entry \"$have_exec_spool_dir\"\nADDING: execd_spool_dir $have_exec_spool_dir"
         }
         if {[info exists tmp_config(execd_spool_dir)]} {
            ts_log_fine "spooldir (old): $tmp_config(execd_spool_dir)"
         } else {
            ts_log_fine "spooldir (old): <not set>"
         }
         set tmp_config(execd_spool_dir) $have_exec_spool_dir
         ts_log_fine "spooldir (new): $tmp_config(execd_spool_dir)"
      }
      ts_log_finer $output

      if {$existing_config} {
         if {$CHECK_INTERACTIVE_TRANSPORT == "default" || $check_use_installed_system} {
            if {$counter != $expected_entries} {
               ts_log_severe "host $host has $counter from $expected_entries expected entries:\n$output"
            }
         }
         # remove unexpected options
         foreach elem $removed {
            set tmp_config($elem) ""
         }
      }

      # handle interactive job transport
      if {$CHECK_INTERACTIVE_TRANSPORT == "rtools"} {
         # for SGE < 62, this is default
         setup_execd_conf_rtools tmp_config $host
      } elseif {$CHECK_INTERACTIVE_TRANSPORT == "ssh"} {
         # this needs to be configured for all SGE versions
         setup_execd_conf_ssh tmp_config $host
      }

      # handle valgrind
      valgrind_setup_execd_conf tmp_config $host

      # now set the new config
      if {$existing_config} {
         set_config tmp_config $host
      } else {
         set_config tmp_config $host 1
      }
   }
}

proc setup_execd_conf_rtools {conf_name node} {
   global ts_config CHECK_USER

   upvar $conf_name conf

   # get the daemon config for the node via arch_variables
   set output [start_remote_prog $node $CHECK_USER "$ts_config(testsuite_root_dir)/scripts/print_interactive_transport.sh" $ts_config(product_root)]
   parse_simple_record output rtools_conf

   # use SGE provided rsh/rlogin/rshd
   set arch [resolve_arch $node]
   set utilbin "$ts_config(product_root)/utilbin/$arch"
   set rtools_conf(rlogin_command)  "$utilbin/rlogin"
   set rtools_conf(rsh_command)     "$utilbin/rsh"
   set rtools_conf(rsh_daemon)      "$utilbin/rshd -l"

   foreach name [array names rtools_conf] {
      set conf($name) $rtools_conf($name)
   }
}

proc setup_execd_conf_ssh {conf_name node} {
   global ts_config CHECK_PROTOCOL_DIR

   upvar $conf_name conf

   # get the configured ssh,
   # assume it is in <path>/bin, and the sshd is in <path>/sbin
   set ssh [node_get_ssh $node]
   set arch [resolve_arch $node]

   if {[string match "sol-*" $arch] && $ssh == "/usr/bin/ssh"} {
      set sshd "/usr/lib/ssh/sshd"
   } else {
      set ssh_dir [file dirname $ssh]
      set base_dir [file dirname $ssh_dir]
      set sshd "$base_dir/sbin/sshd"
   }

   set qlogin_ssh_wrapper "$CHECK_PROTOCOL_DIR/qlogin_ssh_wrapper.sh"
   set f [open $qlogin_ssh_wrapper w]
   puts $f "#!/bin/sh"
   puts $f "exec $ssh -p \$2 \$1"
   close $f

   set conf(qlogin_command)   $qlogin_ssh_wrapper
   set conf(qlogin_daemon)    "$sshd -i"
   set conf(rlogin_command)   "$ssh"
   set conf(rlogin_daemon)    "$sshd -i"
   set conf(rsh_command)      "$ssh"
   set conf(rsh_daemon)       "$sshd -i"
}


#                                                             max. column:     |
#****** install_core_system/setup_mytestproject() ******
#
#  NAME
#     setup_mytestproject -- ???
#
#  SYNOPSIS
#     setup_mytestproject { }
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
#*******************************
proc setup_mytestproject {} {
  global check_arch env
  global ts_config

  if { [ string compare $ts_config(product_type) "sge" ] == 0 } {
      ts_log_fine "not supported on sge systems"
     return
  }

  # setup project "mytestproject"
  return [add_project "mytestproject"]
}



#                                                             max. column:     |
#****** install_core_system/setup_mytestpe() ******
#
#  NAME
#     setup_mytestpe -- ???
#
#  SYNOPSIS
#     setup_mytestpe { }
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
#*******************************
proc setup_mytestpe {} {
   set change(slots) "5"
   add_pe "mytestpe" change
   assign_queues_with_pe_object "all.q" "" "mytestpe"
}



#                                                             max. column:     |
#****** install_core_system/setup_deadlineuser() ******
#
#  NAME
#     setup_deadlineuser -- ???
#
#  SYNOPSIS
#     setup_deadlineuser { }
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
#*******************************
proc setup_deadlineuser {} {
   global CHECK_USER
   add_access_list $CHECK_USER deadlineusers
}


#                                                             max. column:     |
#****** install_core_system/setup_schedconf() ******
#
#  NAME
#     setup_schedconf -- ???
#
#  SYNOPSIS
#     setup_schedconf { }
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
#*******************************
proc setup_schedconf {} {
   global env CHECK_USER

   global ts_config

  # reset_schedd_config has global error reporting
  get_schedd_config old_config
  reset_schedd_config
  get_schedd_config new_config

  set arrays_old [ array names old_config ]
  set arrays_new [ array names new_config ]

  if { [ llength $arrays_old] == [ llength $arrays_new ] } {
    foreach param $arrays_old {
       set old  $old_config($param)
       set new  $new_config($param)

       if { [ string compare $old $new ] != 0 } {
          if { [ string compare $param "reprioritize_interval" ] == 0 } { continue }
          if { [ string compare $param "weight_tickets_deadline" ] == 0 } { continue }
          if { [ string compare $param "job_load_adjustments" ] == 0 } { continue }
          if { [ string compare $param "schedule_interval" ] == 0 } { continue }
          if { [ string compare $param "flush_submit_sec" ] == 0 } { continue }
          if { [ string compare $param "flush_finish_sec" ] == 0 } { continue }
          ts_log_config "scheduler parameter $param:\ndefault setup: $old, after testsuite reset: $new"
       }
    }
  } else {
     ts_log_severe "parameter count new/old scheduler configuration error"
  }
}



#                                                             max. column:     |
#****** install_core_system/setup_default_calendars() ******
#
#  NAME
#     setup_default_calendars -- ???
#
#  SYNOPSIS
#     setup_default_calendars { }
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
#*******************************
proc setup_default_calendars {} {
  global env CHECK_USER
  global ts_config


  set calendar_param(calendar_name)          "always_suspend"              ;# always in calendar suspend
  set calendar_param(year)                   "NONE"
  set calendar_param(week)                   "mon-sun=0-24=suspended"

  set result [ add_calendar "always_suspend" calendar_param ]
  if { $result != 0 } {
     ts_log_severe "result of add_default_calendars: $result"
     return
  }

  set calendar_param(calendar_name)          "always_disabled"              ;# always in calendar suspend
  set calendar_param(year)                   "NONE"
  set calendar_param(week)                   "mon-sun=0-24=off"

  set result [add_calendar "always_disabled" calendar_param]
  if { $result != 0 } {
     ts_log_severe "result of add_calendar: $result"
     return
  }
}

proc setup_check_message_file_line {line} {
   if {[string first "|C|" $line] >= 0 || \
       [string first "|E|" $line] >= 0 || \
       [string first "|W|" $line] >= 0} {
      ts_log_fine $line
   }
   ts_log_finest $line
}

proc setup_check_messages_files {} {
   global ts_config CHECK_USER
   global check_use_installed_system

   if {$check_use_installed_system} {
      return
   }

   ts_log_fine "qmaster ..."
   set messages [get_qmaster_messages_file]
   get_file_content $ts_config(master_host) $CHECK_USER $messages
   if {$file_array(0) < 1} {
      ts_log_severe "no qmaster messages file:\n$messages"
   }
   for {set i 1} {$i <= $file_array(0)} {incr i} {
      setup_check_message_file_line $file_array($i)
   }

   # Since execd does not immediately write the messages file after
   # startup it might take some time until it is completely available
   set had_timeout 0
   foreach execd $ts_config(execd_nodes) {
      # get messages file path
      set messages [get_execd_messages_file $execd]

      # wait for the file on the remote host
      wait_for_remote_file $execd $CHECK_USER $messages

      set my_timeout [clock seconds]
      incr my_timeout 70

      # read the file it should contain more than one line ...
      while {1} {
         get_file_content $execd $CHECK_USER $messages file_array
         if {$file_array(0) >= 1} {
            # ok we have at least one line in the file
            break
         }
         if {[clock seconds] >= $my_timeout} {
            # reached timeout skipp complete loop
            set had_timeout 1
            break
         }
         after 1000
      }
      if {$had_timeout != 0} {
         ts_log_severe "timeout waiting for messages file on host \"$execd\" - skip"
         break
      }
   }

   # Now check the content of the messages files
   foreach execd $ts_config(execd_nodes) {
      ts_log_fine "execd $execd ..."
      set messages [get_execd_messages_file $execd]
      get_file_content $execd $CHECK_USER $messages
      if {$file_array(0) < 1} {
         ts_log_severe "no execd(host=$execd) messages file:\n$messages"
      }
      for {set i 1} {$i <= $file_array(0)} {incr i} {
         setup_check_message_file_line $file_array($i)
      }
   }
}

proc setup_and_check_users {} {
   global ts_user_config CHECK_USER ts_config
   # setup users to test
   set users "$CHECK_USER $ts_user_config(first_foreign_user) $ts_user_config(second_foreign_user)"
   # select host != qmaster if more than 1 host
   if {[llength [host_conf_get_all_nodes $ts_config(all_nodes)]] == 1} {
      set host $ts_config(master_host)
   } else {
      set host [host_conf_get_suited_hosts 1 {} {} {} 1]
   }
   set error_text ""
   foreach user $users {
      ts_log_fine "check qstat -f as user $user on host $host ..."
      set output [start_sge_bin "qstat" "-f" $host $user prg_exit_state]
      if {$prg_exit_state != 0} {
         append error_text "qstat -f exit state is $prg_exit_state for user $user:\n$output\n"
      } else {
         foreach host $ts_config(execd_nodes) {
            if {[string match "*$host*" $output] == 0} {
               append error_text "execd host name \"$host\" not found in qstat -f output of user $user on host $host!\n$output\n"
            } else {
               ts_log_fine "found hostname \"$host\" in qstat -f output - ok"
            }
         }
      }
      set output [submit_job "$ts_config(product_root)/examples/jobs/sleeper.sh 1" 1 60 "" $user]
      ts_log_fine "job id of job submitted as user \"$user\": $output"
   }

   # additional check testsuite version
   set major_version [string index $ts_config(gridengine_version) 0]
   set minor_version [string index $ts_config(gridengine_version) 1]

   get_version_info version_info
   ts_log_fine "Cluster Scheduler (Grid Engine) version string: \"$version_info(full)\""

   if {$version_info(major_release) != $major_version} {
      append error_text "Installed Cluster Scheduler (Grid Engine) reports version string \"$version_info(full)\" which doesn't match major release string \"$major_version\"\n"
      append error_text "Testsuite release parsing returned \"$version_info(major_release).$version_info(minor_release).$version_info(update_release)\"\n"
      append error_text "Testsuite configuration is set to test version \"$ts_config(gridengine_version)\"! Please check testsuite config!\n"
   }

   if {$version_info(minor_release) != $minor_version} {
      append error_text "Installed Cluster Scheduler (Grid Engine) reports version string \"$version_info(full)\" which doesn't match minor release string \"$minor_version\"\n"
      append error_text "Testsuite release parsing returned \"$version_info(major_release).$version_info(minor_release).$version_info(update_release)\"\n"
      append error_text "Testsuite configuration is set to test version \"$ts_config(gridengine_version)\"! Please check testsuite config!\n"
   }

   ts_log_fine "Testsuite parses this as Cluster Scheduler (Grid Engine) Release \"$version_info(major_release).$version_info(minor_release)u$version_info(update_release)\""

   if {$error_text != ""} {
      ts_log_severe $error_text
   }

   wait_for_end_of_all_jobs
}

#****** init_cluster/setup_win_user_passwd() ***********************************
#  NAME
#     setup_win_user_passwd() -- register the passwd of a windows user
#
#  SYNOPSIS
#     setup_win_user_passwd { user }
#
#  FUNCTION
#     Registeres the passwd of a given windows user by calling the sgepasswd
#     utilbin binary and answering the password questions.
#
#     Requires that passwords have been interactively entered through the
#     set_root_passwd procedure.
#
#  INPUTS
#     user - user whose passwd shall be registered
#
#  SEE ALSO
#     check/set_root_passwd()
#*******************************************************************************
proc setup_win_user_passwd {user} {
   global CHECK_USER CHECK_DEBUG_LEVEL
   global ts_config

   ts_log_fine "setting sgepasswd of user $user ..."

   set id [open_remote_spawn_process $ts_config(master_host) $CHECK_USER "sgepasswd" $user]
   set sp_id [lindex $id 1]

   # in debug mode we want to see all the shell output
   log_user 0
   if {$CHECK_DEBUG_LEVEL != 0} {
      log_user 1
   }

   # wait for and answer passwd questions
   set timeout 60
   expect {
      -i $sp_id full_buffer {
         ts_log_severe "buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
         close_spawn_process $id
         return
      }

      -i $sp_id eof {
         ts_log_severe "unexpected eof"
         close_spawn_process $id
         return
      }

      -i $sp_id timeout {
         ts_log_severe "timeout while waiting for password question"
         close_spawn_process $id;
         return
      }

      -i $sp_id "password:" {
         log_user 0  ;# in any case before sending password
         ts_send $sp_id "[get_passwd $user]\n" $ts_config(master_host) 1
         if {$CHECK_DEBUG_LEVEL != 0} {
            log_user 1
         }
         exp_continue
      }
      -i $sp_id "Password changed" {
         ts_log_progress
         exp_continue
      }
      -i $sp_id "_exit_status_:" {
         ts_log_fine "done"
      }
   }

   # cleanup
   close_spawn_process $id
}

#****** init_cluster/setup_sge_aliases_file() **********************************
#  NAME
#     setup_sge_aliases_file() -- adds automounter prefixes to sge_aliases file
#
#  SYNOPSIS
#     setup_sge_aliases_file { }
#
#  FUNCTION
#     The installation should copy a sge_aliases file to
#     $SGE_ROOT/$SGE_CELL/common which contains all known fixed automounter
#     prefixes.
#     This function checks if the sge_aliases file was copied, if not creates
#     a sge_aliases file. If there is a Windows/Interix host in the cluster,
#     this function determines the automounter prefix of the curren working
#     directory and adds it to the sge_aliases file.
#
#  SEE ALSO
#*******************************************************************************
proc setup_sge_aliases_file {} {
   global CHECK_USER
   global ts_config

   # Check if there is a sge_aliases file in $SGE_ROOT/$SGE_CELL. If not, create one.
   ts_log_fine "Searching '$ts_config(product_root)/$ts_config(cell)/common/sge_aliases' file"
   set file_name "$ts_config(product_root)/$ts_config(cell)/common/sge_aliases"
   if { [ file isfile $file_name ] == 0 } {
      ts_log_fine "Not found, creating it"
      set index 0

      set data(src-path,$index)     "/tmp_mnt/"
      set data(sub-host,$index)     "*"
      set data(exec-host,$index)    "*"
      set data(replacement,$index)  "/"
      incr index 1

      set data(src-path,$index)     "/private/var/automount/"
      set data(sub-host,$index)     "*"
      set data(exec-host,$index)    "*"
      set data(replacement,$index)  "/"
      incr index 1

      create_path_aliasing_file ${file_name} data $index
   } else {
      ts_log_fine "Found '$ts_config(product_root)/$ts_config(cell)/common/sge_aliases' file"
   }
}

proc install_send_answer {sp_id answer {scenario ""}} {
   global CHECK_DEBUG_LEVEL

   if {$scenario == ""} {
      ts_log_newline FINER ; ts_log_finer "--> testsuite: sending >$answer<"
   } else {
      ts_log_newline FINER ; ts_log_finer "--> testsuite ($scenario): sending >$answer<"
   }

   if {$CHECK_DEBUG_LEVEL == 2} {
      wait_for_enter
   }

   ts_send $sp_id "$answer\n"
}

proc setup_ids {} {
   global CHECK_HIGH_JOBIDS
   if {$CHECK_HIGH_JOBIDS} {
      if {[is_version_in_range "9.1.0"]} {
         set_jobseqnum 4000000000
      } elseif {[is_version_in_range "9.0.3"]} {
         set_jobseqnum 2000000000
      } else {
         set_jobseqnum 9000000
      }
   }
}
