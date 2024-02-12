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
##########################################################################
#___INFO__MARK_END__


#****** checktree_helper/exec_compile_hooks() **************************************************
#  NAME
#    exec_compile_hooks() -- execute a compile hooks
#
#  SYNOPSIS
#    exec_compile_hooks { compile_hosts report } 
#
#  FUNCTION
#     ??? 
#
#  INPUTS
#    compile_hosts --  list of all compile hosts
#    a_report      --  the report object
#
#  RESULT
#     0   --  all compile hooks are executed
#     > 0 --  number of failed compile hooks
#     -1  --  a compile has not been found
#
#  EXAMPLE
#
#  NOTES
#
#  BUGS
#
#  SEE ALSO
#
#*******************************************************************************
proc exec_compile_hooks { compile_hosts a_report } {
   global ts_checktree

   upvar $a_report report
   
   set error_count 0
   for {set i 0} { $i < $ts_checktree(next_free)} {incr i 1 } {
      for {set ii 0} {[info exists ts_checktree($i,compile_hooks_${ii})]} {incr ii 1} {
         
         set compile_proc $ts_checktree($i,compile_hooks_${ii})
         
         if { [info procs $compile_proc ] != $compile_proc } {
            report_add_message report "Can not execute compile hook ${ii} of checktree $ts_checktree($i,dir_name), compile proc not found"
            return -1
         } else {
            set res [$compile_proc $compile_hosts report]
            if { $res != 0 } {
               report_add_message report "compile hook ${ii}  of checktree  $ts_checktree($i,dir_name) failed, $compile_proc returned $res\n"
               incr error_count
            }
         }
      }
   }
   return $error_count
}

#****** checktree_helper/exec_compile_clean_hooks() **************************************************
#  NAME
#    exec_compile_clean_hooks() -- execute a compile clean hook
#
#  SYNOPSIS
#    exec_compile_clean_hooks { compile_hosts report } 
#
#  FUNCTION
#     This method executes all registered compile_clean hooks of the
#     checktree
#
#  INPUTS
#    compile_hosts -- list of compile hosts
#    a_report      -- the report object
#
#  RESULT
#     0   -- all compile_clean hooks has been executed
#    >0   -- number of failed compile_clean hooks
#    <0   -- configuration error
#
#  EXAMPLE
#
#  NOTES
#
#  BUGS
#
#  SEE ALSO
#*******************************************************************************
proc exec_compile_clean_hooks { compile_hosts a_report } {
   global ts_checktree
   upvar $a_report report
   
   ts_log_fine "execute exec_compile_clean_hooks ..."
   set error_count 0
   for {set i 0} { $i < $ts_checktree(next_free)} {incr i 1 } {
      for {set ii 0} {[info exists ts_checktree($i,compile_clean_hooks_${ii})]} {incr ii 1} {
         
         set compile_clean_proc $ts_checktree($i,compile_clean_hooks_${ii})
         
         if { [info procs $compile_clean_proc ] != $compile_clean_proc } {
            report_add_message report "Can not execute compile_clean hook ${ii} of checktree $ts_checktree($i,dir_name), compile proc not found"
            return -1
         } else {
            ts_log_fine "execute: $compile_clean_proc $compile_hosts ..."
            set res [$compile_clean_proc $compile_hosts report]
            if { $res != 0 } {
               report_add_message report "compile_clean hook ${ii}  of checktree  $ts_checktree($i,dir_name) failed, $compile_clean_proc returned $res\n"
               incr error_count
            }
         }
      }
   }
   return $error_count
}

#****** checktree_helper/exec_checktree_clean_hooks() **************************
#  NAME
#     exec_checktree_clean_hooks() -- execute all cleanup hooks
#
#  SYNOPSIS
#     exec_checktree_clean_hooks { } 
#
#  FUNCTION
#
#     execute all cleanup hooks for additional checktrees
#     
#
#  INPUTS
#
#  RESULT
#    0   -- all cleanup hooks are successfully executed
#    >0  -- number of failed cleanup hooks
#    <0  -- a cleanup hook was not found
#
#*******************************************************************************
proc exec_checktree_clean_hooks { } {
   
   global ts_checktree

   set error_count 0
   for {set i 0} { $i < $ts_checktree(next_free)} {incr i 1 } {
      for {set ii 0} {[info exists ts_checktree($i,checktree_clean_hooks_${ii})]} {incr ii 1} {
         
         set clean_proc $ts_checktree($i,checktree_clean_hooks_${ii})
         
         if { [info procs $clean_proc ] != $clean_proc } {
            ts_log_warning "Can not execute clean_proc hook ${ii} of checktree $ts_checktree($i,dir_name), clean proc not found"
            return -1
         } else {
            ts_log_fine "running cleanup hook: $clean_proc"
            set res [$clean_proc]
            if { $res != 0 } {
               ts_log_warning "checktree_clean hook ${ii}  of checktree  $ts_checktree($i,dir_name) failed, $clean_proc returned $res\n"
               incr error_count
            }
         }
      }
   }
   return $error_count
}



#****** checktree_helper/exec_install_binaries_hooks() **************************************************
#  NAME
#    exec_install_binaries_hooks() -- ???
#
#  SYNOPSIS
#    exec_install_binaries_hooks { } 
#
#  FUNCTION
#     Execute all registered install_binaries_hooks 
#
#  INPUTS
#    arch_list   -- list of architectures
#    a_report    -- the report object
#
#  RESULT
#     0  - on success
#     >1 - nuber of failed install_binaries_hooks
#     <0 - failure
#
#  EXAMPLE
#
#  NOTES
#
#  BUGS
#
#  SEE ALSO
#*******************************************************************************
proc exec_install_binaries_hooks { arch_list a_report } {
   global ts_checktree

   upvar $a_report report
   set error_count 0
   for {set i 0} { $i < $ts_checktree(next_free)} {incr i 1 } {
      for {set ii 0} {[info exists ts_checktree($i,install_binary_hooks_${ii})]} {incr ii 1} {
         
         set prog $ts_checktree($i,install_binary_hooks_${ii})
         
         if { [info procs $prog ] != $prog } {
            ts_log_severe "Can not execute compile hook $ts_checktree($i,install_binary_hooks_${ii}), compile prog not found"
            return -1
         } else {
            set res [$prog $arch_list report]
            if { $res != 0 } {
               report_add_message report "install hook ${ii} of checktree  $ts_checktree($i,dir_name), $prog returned $res\n"
               incr error_count
            }
         }
      }
   }
   return $error_count
}


#****** checktree_helper/exec_shutdown_hooks() **************************************************
#  NAME
#    exec_shutdown_hooks() -- execute all shutdown hooks
#
#  SYNOPSIS
#    exec_shutdown_hooks { } 
#
#  FUNCTION
#     Executes all registered shutdown hooks
#
#  INPUTS
#
#  RESULT
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
proc exec_shutdown_hooks {} {
   global ts_checktree

   set error_count 0
   for {set i 0} { $i < $ts_checktree(next_free)} {incr i 1 } {
      for {set ii 0} {[info exists ts_checktree($i,shutdown_hooks_${ii})]} {incr ii 1} {
         
         set shutdown_hook $ts_checktree($i,shutdown_hooks_${ii})
         
         if { [info procs $shutdown_hook ] != $shutdown_hook } {
            ts_log_fine "Can not execute shutdown hook ${ii} of checktree $ts_checktree($i,dir_name), shutdown proc not found"
            return -1
         } else {
            set res [$shutdown_hook]
            if { $res != 0 } {
               ts_log_fine "shutdown hook ${ii}  of checktree  $ts_checktree($i,dir_name) failed, $shutdown_hook returned $res\n"
               incr error_count
            }
         }
      }
   }
   return $error_count
}

#****** checktree_helper/exec_start_runlevel_hooks() ***************************
#  NAME
#     exec_start_runlevel_hooks() -- execute runlevel hooks
#
#  SYNOPSIS
#     exec_start_runlevel_hooks { is_starting was_error } 
#
#  FUNCTION
#     execute registered start runlevel hooks procedures
#
#  INPUTS
#     is_starting - if 1 test is in setup phase, otherwise it is cleanup phase
#     was_error   - if != 0 there was an error during running this test
#     path        - actual check path
#
#  RESULT
#     0 on success
#
#*******************************************************************************
proc exec_start_runlevel_hooks { is_starting was_error path } {
   global ts_checktree
   set error_count 0

   # detect the checktree where the test comes from
   for {set i 0} { $i < $ts_checktree(next_free)} {incr i 1 } {
      if {[string compare $ts_checktree($i,dir_name) $path] == 0} {
         ts_log_fine "test comes from checktree node nr. $i ($ts_checktree($i,dir_name))"
         set init_node_nr $i
         break
      }
   }
   set start_node_nr 0
   foreach nr [lsort -integer $ts_checktree(0,children)] {
      ts_log_fine "sub_checks: $nr \"$ts_checktree($nr,dir_name)\""
      if {$nr < $init_node_nr} {
         set start_node_nr $nr
      }
   }

   set did_hook 0
   for {set i $start_node_nr} { $i < $ts_checktree(next_free) && $did_hook == 0} {incr i 1 } {
      for {set ii 0} {[info exists ts_checktree($i,start_runlevel_hooks_${ii})]} {incr ii 1} {
         if {$init_node_nr < $i} {
            continue
         } 
         set start_test_hook $ts_checktree($i,start_runlevel_hooks_${ii})
         if { [info procs $start_test_hook] != $start_test_hook } {
            ts_log_fine "Can not execute start_runlevel_hooks ${ii} of checktree $ts_checktree($i,dir_name), proc \"$start_test_hook\" not found"
            return -1
         } else {
            ts_log_fine "starting test hook \"$start_test_hook\" ..."
            set res [$start_test_hook $is_starting $was_error]
            if { $res != 0 } {
               ts_log_fine "start_runlevel_hooks hook ${ii} of checktree  $ts_checktree($i,dir_name) failed, proc \"$start_test_hook\" returned $res\n"
               incr error_count
            }
         }
         set did_hook 1
      }
   }
   return $error_count
}

#****** checktree_helper/exec_startup_hooks() **************************************************
#  NAME
#    exec_startup_hooks() -- execute all startup hooks
#
#  SYNOPSIS
#    exec_startup_hooks { } 
#
#  FUNCTION
#     Executes all registered startup hooks
#     Additional checktree will be informed that the cluster starts up
#
#  INPUTS
#
#  RESULT
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
proc exec_startup_hooks {} {
   global ts_checktree

   set error_count 0
   for {set i 0} { $i < $ts_checktree(next_free)} {incr i 1 } {
      for {set ii 0} {[info exists ts_checktree($i,startup_hooks_${ii})]} {incr ii 1} {
         
         set startup_hook $ts_checktree($i,startup_hooks_${ii})
         
         if { [info procs $startup_hook ] != $startup_hook } {
            ts_log_severe "Can not execute startup hook ${ii} of checktree $ts_checktree($i,dir_name), startup proc not found"
            return -1
         } else {
            set res [$startup_hook]
            if { $res != 0 } {
               ts_log_severe "startup hook ${ii}  of checktree  $ts_checktree($i,dir_name) failed, $startup_hook returned $res\n"
               incr error_count
            }
         }
      }
   }
   return $error_count
}

#****** checktree_helper/checktree_get_required_hosts() **************************************************
#  NAME
#    checktree_get_required_hosts() -- get a list of required hosts of all checktrees
#
#  SYNOPSIS
#    checktree_get_required_hosts { } 
#
#  FUNCTION
#     get a list of required hosts of all checktrees
#
#  INPUTS
#
#  RESULT
#     list with the required hosts
#
#  EXAMPLE
#     set required_hosts [checktree_get_required_hosts]
#
#*******************************************************************************
proc checktree_get_required_hosts {} {
   global ts_checktree

   set required_hosts {}
   for {set i 0} {$i < $ts_checktree(next_free)} {incr i 1 } {
      if { [info exists ts_checktree($i,required_hosts_hook) ] } {
         set required_hosts_hook $ts_checktree($i,required_hosts_hook)
         if { [info procs $required_hosts_hook ] != $required_hosts_hook } {
            ts_log_severe "Can not execute required_hosts_hook of checktree $ts_checktree($i,dir_name), proc not found"
         } else {
            set required_host_list [$required_hosts_hook]
            if { $required_host_list == -1 } {
               ts_log_severe "required_hosts_hook of checktree  $ts_checktree($i,dir_name) failed"
            } else {
               foreach host $required_host_list {
                  if { [lsearch $required_hosts $host] < 0 } {
                     lappend required_hosts $host
                  }
               }
            }
         }
      }
   }
   return $required_hosts
}

#****** checktree_helper/checktree_get_required_ports() ************************
#  NAME
#     checktree_get_required_ports() -- get required ports from hook functions
#
#  SYNOPSIS
#     checktree_get_required_ports { } 
#
#  FUNCTION
#     Call all required_ports_hook functions and return the port list of
#     additional checktree configurations.
#
#  INPUTS
#
#  RESULT
#     TCL list of ports
#
#  SEE ALSO
#     cluster_procedures/get_all_reserved_ports()
#*******************************************************************************
proc checktree_get_required_ports {} {
   global ts_checktree

   set required_ports {}
   for {set i 0} {$i < $ts_checktree(next_free)} {incr i 1 } {
      if { [info exists ts_checktree($i,required_ports_hook) ] } {
         set required_ports_hook $ts_checktree($i,required_ports_hook)
         if { [info procs $required_ports_hook ] != $required_ports_hook } {
            ts_log_severe "Can not execute required_ports_hook of checktree $ts_checktree($i,dir_name), proc not found"
         } else {
            set required_port_list [$required_ports_hook]
            if { $required_port_list == -1 } {
               ts_log_severe "required_ports_hook of checktree  $ts_checktree($i,dir_name) failed"
            } else {
               foreach port $required_port_list {
                  if { [lsearch -exact $required_ports $port] < 0 } {
                     lappend required_ports $port
                  }
               }
            }
         }
      }
   }
   return $required_ports
}

proc checktree_get_check_levels_by_path {path} {
   global ts_checktree

   set check_number $ts_checktree($path)
   return $ts_checktree($check_number,check_levels)
}

proc checktree_get_highest_level_by_path {path} {
   global ts_checktree

   set check_number $ts_checktree($path)
   return $ts_checktree($check_number,check_highest_level)
}
