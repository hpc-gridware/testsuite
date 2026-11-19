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
#  Portions of this software are Copyright (c) 2023-2026 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__


global ts_checktree arco_config
global CHECK_DEFAULTS_FILE
global arco_checktree_nr
global ACT_CHECKTREE

ts_source $ACT_CHECKTREE/config
ts_source $ACT_CHECKTREE/sql_util
ts_source $ACT_CHECKTREE/arco_queries

set arco_config(initialized) 0
set arco_checktree_nr $ts_checktree($ACT_CHECKTREE)

set ts_checktree($arco_checktree_nr,setup_hooks_0_name)         "ARCo configuration"
set ts_checktree($arco_checktree_nr,setup_hooks_0_config_array) arco_config
set ts_checktree($arco_checktree_nr,setup_hooks_0_init_func)    arco_init_config
set ts_checktree($arco_checktree_nr,setup_hooks_0_verify_func)  arco_verify_config
set ts_checktree($arco_checktree_nr,setup_hooks_0_save_func)    arco_save_configuration
set ts_checktree($arco_checktree_nr,setup_hooks_0_filename)     [ get_additional_config_file_path "arco" ]
set ts_checktree($arco_checktree_nr,setup_hooks_0_version)      "1.6"

set ts_checktree($arco_checktree_nr,checktree_clean_hooks_0)  "arco_clean"

set ts_checktree($arco_checktree_nr,compile_hooks_0)        "arco_compile"
set ts_checktree($arco_checktree_nr,compile_clean_hooks_0)  "arco_compile_clean"
set ts_checktree($arco_checktree_nr,install_binary_hooks_0) "arco_install_binaries"

set ts_checktree($arco_checktree_nr,get_dist_files_hook)    "arco_get_distribution_files"
set ts_checktree($arco_checktree_nr,get_package_files_hook) "arco_get_package_files"
set ts_checktree($arco_checktree_nr,mk_dist_options)        "-arco"

set ts_checktree($arco_checktree_nr,shutdown_hooks_0)       "shutdown_dbwriter"
set ts_checktree($arco_checktree_nr,startup_hooks_0)       "startup_dbwriter"

set ts_checktree($arco_checktree_nr,start_runlevel_hooks_0)   "arco_test_run_level_check"

set ts_checktree($arco_checktree_nr,required_hosts_hook)    "arco_get_required_hosts"


proc arco_init_variables {} {
   get_current_cluster_config_array ts_config
   global ARCO_TABLES
   global ARCO_VIEWS
   global DBWRITER_LOG_FNAME

   set DBWRITER_LOG_FNAME "$ts_config(product_root)\/$ts_config(cell)\/spool\/dbwriter\/dbwriter.log"

   set ARCO_TABLES {}
   if {[is_version_in_range "9.1.4"]} {
      lappend ARCO_TABLES sge_job_usage_values
   }
   lappend ARCO_TABLES sge_job_usage
   lappend ARCO_TABLES sge_job_log
   lappend ARCO_TABLES sge_job_request
   if {[is_version_in_range "9.1.2"]} {
      lappend ARCO_TABLES sge_job_online_usage
   }
   lappend ARCO_TABLES sge_job

   lappend ARCO_TABLES sge_queue_values
   lappend ARCO_TABLES sge_queue

   lappend ARCO_TABLES sge_host_values
   lappend ARCO_TABLES sge_host

   lappend ARCO_TABLES sge_department_values
   lappend ARCO_TABLES sge_department

   lappend ARCO_TABLES sge_project_values
   lappend ARCO_TABLES sge_project

   lappend ARCO_TABLES sge_user_values
   lappend ARCO_TABLES sge_user

   lappend ARCO_TABLES sge_group_values
   lappend ARCO_TABLES sge_group

   lappend ARCO_TABLES sge_share_log

   lappend ARCO_TABLES sge_version
   lappend ARCO_TABLES sge_statistic_values
   lappend ARCO_TABLES sge_statistic
   lappend ARCO_TABLES sge_checkpoint

   lappend ARCO_TABLES sge_ar_attribute
   lappend ARCO_TABLES sge_ar_usage
   lappend ARCO_TABLES sge_ar_log
   lappend ARCO_TABLES sge_ar_resource_usage
   lappend ARCO_TABLES sge_ar

   set ARCO_VIEWS { view_job_times_subquery view_job_times view_jobs_completed
                    view_job_log view_department_values view_group_values view_host_values
                    view_project_values view_queue_values view_user_values view_accounting
                    view_statistic
   }

   set ARCO_VIEWS { view_ar_time_usage view_job_times_subquery view_job_times view_jobs_completed
                 view_job_log view_department_values view_group_values view_host_values
                 view_project_values view_queue_values view_user_values view_statistic
                 view_ar_time_usage view_ar_attribute view_ar_log view_ar_usage
                 view_ar_resource_usage view_accounting view_ar_attribute
   }
}

# Intialize the ARCO_TABLES etc. once
# We repeat this after installing a new ARCO version to make sure
# the variables match the ARCO version.
arco_init_variables

#****** checktree/arco_compile() ***********************************************
#  NAME
#    arco_compile() -- ???
#
#  SYNOPSIS
#    arco_compile { compile_hosts a_mail_body a_html_body  }
#
#  FUNCTION
#     Compile hook for the ARCo packages
#
#  INPUTS
#    compile_hosts -- list of all compile host
#    a_mail_body   -- buffer for mail error reporting
#    a_html_body   -- buffer for html error reporting
#
#  RESULT
#     0  -- on succes
#     else  error
#  EXAMPLE
#
#  NOTES
#
#  BUGS
#
#  SEE ALSO
#*******************************************************************************
proc arco_compile { compile_hosts a_report } {
   upvar $a_report report
   return [arco_build [host_conf_get_java_compile_host] "dist" report]
}

#****** checktree/arco_compile_clean() *****************************************
#  NAME
#    arco_compile_clean() -- compile clean hook for ARCo
#
#  SYNOPSIS
#    arco_compile_clean { compile_hosts a_report }
#
#  FUNCTION
#
#    call the arco build script with target clean
#
#  INPUTS
#    compile_hosts -- list of compile hosts
#    a_report      -- the report object
#
#  RESULT
#      0  --  successfull build
#      else -- failure
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
proc arco_compile_clean { compile_hosts a_report } {
   upvar $a_report report
   return [arco_build [host_conf_get_java_compile_host] "clean" report]
}


##
# @brief Start the dbwriter build script.
#
# @param compile_hosts      the host to build on, a list with one host
# @param target             the build target: dist, clean or test
# @param a_report           the report object
# @param build_options      options for the build: with a maven build they are passed to maven,
#                           with an ant build they go into ANT_OPTS
# @param arco_build_timeout timeout in seconds
# @return 0 on success, else a failure
proc arco_build {compile_hosts target a_report {build_options ""} {arco_build_timeout 120}} {
   get_current_cluster_config_array ts_config
   global CHECK_OUTPUT CHECK_USER
   global CHECK_HTML_DIRECTORY CHECK_PROTOCOL_DIR
   global ts_host_config arco_config

   upvar $a_report report

   if {[llength $compile_hosts] != 1} {
      set build_host [host_conf_get_java_compile_host]
      ts_log_config "There was a problem with compile_hosts list: \"$compile_hosts\", using \"$build_host\" for building arco"
   } else {
      set build_host $compile_hosts
   }

   set task_nr [report_create_task report "arco_build_$target" $build_host]

   ts_log_fine "creating target \"$target\" on compile host \"$build_host\""

   if {$ts_config(source_dir) == "none"} {
      report_task_add_message report $task_nr "source directory is set to \"none\" - cannot build"
      report_finish_task report $task_nr -1
      return -1
   }


   report_task_add_message report $task_nr "------------------------------------------"
   report_task_add_message report $task_nr "starting arco build.sh $target on host $build_host ..."

   # setup environment
   set env(JAVA_HOME) [arco_get_java_home $build_host]
   if {$env(JAVA_HOME) eq ""} {
      return -1
   }
   set ind [string first "/java" $env(JAVA_HOME)]
   set java_path [string range $env(JAVA_HOME) 0 $ind]
   set env(ARCH)      [resolve_arch $build_host]
   set env(PATH)      "$java_path:\$PATH"

   if {[arco_have_maven_build]} {
      set options "$target $ts_config(package_release) $build_options"
   } else {
      append build_options " -Dsge.root=$ts_config(product_root)"
      append build_options " -Dsge.srcdir=$ts_config(source_dir)"
      set env(ANT_OPTS) "$build_options"
      if {[coverage_enabled "emma"]} {
         set options "-emma $target"
      } else {
         set options "$target"
      }
   }

   report_task_add_message report $task_nr "environment settings:"
   foreach attr [array names env] {
      report_task_add_message report $task_nr "   $attr=$env($attr)"
   }

   set open_spawn [open_remote_spawn_process $build_host $CHECK_USER "./build.sh" $options 0 $arco_config(arco_source_dir) env]
   set spawn_list [lindex $open_spawn 1]
   set timeout $arco_build_timeout
   set error -1
   set use_output 0
   expect {
      -i $spawn_list full_buffer {
         report_task_add_message report $task_nr "full_buffer error \"$build_host\""
      }
      -i $spawn_list timeout {
         report_task_add_message report $task_nr "got timeout for host \"$build_host\""
      }
      -i $spawn_list eof {
         report_task_add_message report $task_nr "got eof \"$build_host\""
      }
      -i $spawn_list "_exit_status_:(*)" {
         set error [get_string_value_between "_exit_status_:(" ")" $expect_out(0,string)]
         report_task_add_message report $task_nr "arco build script exited with status $error"
      }
      -i $spawn_list "_start_mark_:(0)" {
         set use_output 1
         report_task_add_message report $task_nr "cd $arco_config(arco_source_dir); ./build.sh $target"
         exp_continue
      }
      -i $spawn_list -re {^.*?\n} {
         if { $use_output == 1 } {
            set line [ string trimright $expect_out(buffer) "\n\r" ]
            report_task_add_message report $task_nr "$line"
         }
         exp_continue
      }
   }

   close_spawn_process $open_spawn
   report_finish_task report $task_nr $error

   if { $error != 0 } {
      ts_log_severe "return state: $error"
      return -1
   }
   return 0
}

#****** checktree/arco_get_required_hosts() ************************************
#  NAME
#    arco_get_required_hosts() -- required hosts hook for arco
#
#  SYNOPSIS
#    arco_get_required_hosts { }
#
#  FUNCTION
#    return a list of host which are required for the arco checktree
#
#  INPUTS
#
#  RESULT
#
#    List of required hosts
#
#
#  SEE ALSO
#     checktree_helper/checktree_get_required_hosts
#*******************************************************************************
proc arco_get_required_hosts {} {
   global arco_config
   set res {}
   lappend res $arco_config(dbwriter_host)

   ts_log_fine "Required hosts for arco: $res"
   return $res
}

#****** checktree/arco_install_binaries() **************************************
#  NAME
#    arco_install_binaries() -- ???
#
#  SYNOPSIS
#    arco_install_binaries { }
#
#  FUNCTION
#     ???
#
#  INPUTS
#    arch_list   --   list of architectures for which the binaries should be installed
#    a_mail_body --   buffer for mail error reporting
#    a_html_body --   buffer for html error reporting
#
#  RESULT
#     0  - on success
#     else failure
#
#  EXAMPLE
#
#  NOTES
#
#  BUGS
#
#  SEE ALSO
#*******************************************************************************
proc arco_install_binaries { arch_list a_report } {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   global ts_host_config arco_config

   upvar $a_report report

   set task_nr [ report_create_task report "install_dbwriter_binaries" $ts_config(master_host) ]

   set tar $ts_host_config($ts_config(master_host),tar)

   if {[arco_have_maven_build]} {
      set targz "$arco_config(arco_source_dir)/target/dbwriter/dbwriter.tar.gz"
   } else {
      set targz "$arco_config(arco_source_dir)/dbwriter/dbwriter.tar.gz"
   }

   set tar_args "xzf $targz -C $ts_config(product_root)"

   report_task_add_message report $task_nr "------------------------------------------"
   report_task_add_message report $task_nr "-> $tar $tar_args"
   set output [start_remote_prog $ts_config(master_host) $CHECK_USER "$tar" "$tar_args" prg_exit_state]
   if { $prg_exit_state != 0 } {
      report_task_add_message report $task_nr "------------------------------------------"
      report_task_add_message report $task_nr "return state: $prg_exit_state"
      report_task_add_message report $task_nr "------------------------------------------"
      report_task_add_message report $task_nr "output:\n$output"
      report_task_add_message report $task_nr "------------------------------------------"
      report_finish_task report $task_nr -1
      return -1
   }
   report_finish_task report $task_nr 0

   # the SBOM the maven build produces is part of the tarball
   if {[arco_have_maven_build]} {
      set built_sbom "$arco_config(arco_source_dir)/target/bom.json"
      set installed_sbom "$ts_config(product_root)/dbwriter/3rdparty-licenses/sbom.cyclonedx.json"
      if {[sbom_validate_installed dbwriter $built_sbom $installed_sbom report] != 0} {
         return -1
      }
   }

   # We might have installed a new version which might affect the tables/views.
   # Re-initialize the ARCO_TABLES and ARCO_VIEWS variables.
   arco_init_variables

   return 0
}

#****** checktree/startup_dbwriter() **************************************************
#  NAME
#    startup_dbwriter() -- startup the dbwriter
#
#  SYNOPSIS
#    startup_dbwriter { { hostname "--" } }
#
#  FUNCTION
#    Starts the dbwriter.
#
#  INPUTS
#    hostname --  hostname where dbwriter should run. If the hostname has the
#                 value "--", the host from arco_config(dbwriter_host) is taken.
#    debug_mode -- If 0, then the dbwriter is started in debug mode. The user has
#                  to connect to the dbwriter with a jdpa debugger. When the connectioin
#                  has be established, the testsuite can continue.
#
#  RESULT
#       0 --  dbwriter has been started
#       else -- error, dbwriter could not be started, error has been reported
#               by add_proc_error
#
#  SEE ALSO
#*******************************************************************************
proc startup_dbwriter {{hostname "--"} {debugmode "0"}} {
   get_current_cluster_config_array ts_config
   global arco_config CHECK_USER CHECK_INSTALL_RC

   if {$hostname == "--"} {
      set hostname $arco_config(dbwriter_host)
   }

   ts_log_fine "startup_dbwriter($hostname)"

   # Create spool directory for dbwriter.
   if {![file exists "$ts_config(product_root)/$ts_config(cell)/spool/dbwriter"]} {
      set output [start_remote_prog "$hostname" "$CHECK_USER" "mkdir" "-p $ts_config(product_root)/$ts_config(cell)/spool/dbwriter"]
      if {$prg_exit_state != 0} {
         ts_log_severe "Can not create spool directory for dbwriter: $output"
         return -1;
      }
   }

   # Start dbwriter either via systemd or via sgedbwriter.
   if {$CHECK_INSTALL_RC && [ge_has_feature "systemd"] && [host_has_systemd $hostname]} {
      ts_log_fine "   via systemd"
      if {[systemd_start_service $hostname "dbwriter"]} {
         return 0
      } else {
         # error raised in systemd_stop_service
         return -1
      }
   } else {
      ts_log_fine "   via sgedbwriter"
      # pass special environment variables to sgedbwriter
      # to allow code coverage analysis with EMMA
      if {[coverage_enabled "emma"]} {
         parse_properties_file properties "$arco_config(arco_source_dir)/build.properties"
         parse_properties_file properties "$arco_config(arco_source_dir)/build_private.properties" 1
         set dbwriter_env(DBWRITER_JVMARGS) "-Demma.coverage.out.file=$arco_config(arco_source_dir)/arco/dbwriter/coverage/dbwriter.emma -Demma.coverage.out.merge=true"
         set dbwriter_env(DBWRITER_CLASSPATH) "$properties(emma.dir)/emma.jar"
      }

      set prog "$ts_config(product_root)/$ts_config(cell)/common/sgedbwriter"

      if {[wait_for_remote_file "$hostname" "$CHECK_USER" "$prog"] == 0} {
         set args ""
         if {$debugmode == 1} {
            append args "-debug_port 8000 -debug "
         }
         append args "start"

         set output [start_remote_prog "$hostname" "$CHECK_USER" "$prog" $args prg_exit_state 60 0 "" dbwriter_env]

         if {$debugmode == 1} {
           puts "dbwriter has been started in debug mode"
           puts "Connect with a jpda debugger to $hostname (Port 8000)!"
           wait_for_enter
         } elseif {$prg_exit_state != 0} {
            ts_log_severe "startup of dbwriter failed: $output (exit code $prg_exit_state)"
         }
         return $prg_exit_state;
      } else {
         return -1
      }
   }
}

#****** checktree/get_dbwriter_status() ****************************************
#  NAME
#    get_dbwriter_status() -- get the status of the dbwriter
#
#  SYNOPSIS
#    get_dbwriter_status { { hostname "--" } }
#
#  FUNCTION
#     Check the status of the dbwriter
#
#  INPUTS
#    hostname --  the host where the dbwriter is running. If this
#                 is an empty string the value from arco_config(dbwriter_host) is taken
#
#  RESULT
#     0     --  dbwriter is running
#     1     --  dbwriter is not running, but the pid file exists
#     2     --  Java Web Console is running, pid file does not exists
#     else  --  dbwriter is not installed on this host, or it is
#               not accessable by the CHECK_USER
#
#  EXAMPLE
#
#   set res [get_dbwriter_status]
#
#   if { $res == 0 } {
#      puts "dbwriter is running"
#   } elseif { $res == 1 } {
#      puts "dbwriter is not running
#   } elseif { $res == 2 } {
#      puts "dbwriter is not running, but the pid file exits
#   } else {
#      puts "Can not determine status of the Java Web Console"
#   }
#
#*******************************************************************************
proc get_dbwriter_status { { raise_error 1 } { hostname "--" } } {
   get_current_cluster_config_array ts_config
   global arco_config CHECK_USER

   if {$hostname == "--"} {
      set hostname $arco_config(dbwriter_host)
   }

   set prog "$ts_config(product_root)/$ts_config(cell)/common/sgedbwriter"

   if {$raise_error} {
      set timeout 60
   } else {
      set timeout 5
   }
   if {[wait_for_remote_file $hostname $CHECK_USER $prog $timeout $raise_error] == 0} {
      set output [start_remote_prog $hostname $CHECK_USER $prog "status"]
      ts_log_fine $output
      return $prg_exit_state
   } else {
      if {$raise_error} {
         ts_log_severe "Can not query dbwriter status, $prog does not exists"
      }
      return -1
   }
}

#****** checktree/shutdown_dbwriter() ******************************************
#  NAME
#    shutdown_dbwriter() -- shutdown the dbwriter
#
#  SYNOPSIS
#    shutdown_dbwriter { { hostname "--" } }
#
#  FUNCTION
#    This function stop the dbwriter
#
#  INPUTS
#    hostname -- host where the dbwriter is running. If set to "--" the host
#                is taken from arco_config(dbwriter_host)
#
#  RESULT
#     0    --  dbwriter has been stopped or is not running
#     else --  error, dbwriter can not be stopped
#
#  EXAMPLE
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
proc shutdown_dbwriter { { hostname "--" } } {
   get_current_cluster_config_array ts_config
   global arco_config CHECK_USER CHECK_INSTALL_RC

   if {$hostname == "--"} {
      set hostname $arco_config(dbwriter_host)
   }

   ts_log_fine "shutdown_dbwriter($hostname)"
   if {$CHECK_INSTALL_RC && [ge_has_feature "systemd"] && [host_has_systemd $hostname] && [systemd_is_service_active $hostname "dbwriter"]} {
      ts_log_fine "   via systemd"
      if {[systemd_stop_service $hostname "dbwriter"]} {
         return 0
      } else {
         # error raised in systemd_stop_service
         return -1
      }
   } else {
      ts_log_fine "   via sgedbwriter"
      set prog "$ts_config(product_root)/$ts_config(cell)/common/sgedbwriter"
      if {[file exists $prog]} {
         start_remote_prog "$hostname" "$CHECK_USER" "$prog" "stop"

         switch -- $prg_exit_state {
            0 {
               ts_log_fine "dbwriter has been stopped"
               return 0
            }
            1 {
               ts_log_fine "dbwriter has not been started"
               return 0
            }
            default {
               ts_log_severe "shutdown of dbwriter failed, exit status $prg_exit_state"
               return -1
            }
         }
      } else {
         ts_log_fine "Can not shutdown dbwriter, $prog does not exists"
         return -1
      }
   }
}

proc arco_clean {} {
   if {[arco_clean_database] != 0} {
      return -1
   }

   return 0
}

proc arco_clean_database {{drop 0}} {
   global arco_config

   if {[get_database_type] == "oracle"} {
      return [arco_clean_oracle_database $drop]
   } elseif {[get_database_type] == "postgres"} {
      return [arco_clean_postgres_database $drop]
   } elseif {[get_database_type] == "mysql"} {
      return [arco_clean_mysql_database $drop]
   }
}

proc clean_table { table_name } {
   if {[string compare [string tolower $table_name] "sge_version"] == 0} {
      return 0
   }
   if {[string compare [string tolower $table_name] "sge_checkpoint"] == 0} {
      return 0
   }

   return 1
}

proc arco_clean_oracle_database { { drop 0 } } {
   global ARCO_TABLES ARCO_VIEWS

   set id [sqlutil_create]
   if { $id == "-1" } {
      ts_log_severe "Can not create sqlutil"
      return -1
   }
   set sp_id [ lindex $id 1 ]


   # first of all connect to the admin db and check wether the database exists
   if { [ sqlutil_connect $sp_id 1 ] != 0 } {
      ts_log_severe "Can not connect to admin database"
      close_spawn_process $id;
      return -2
   }

   # Ensure that the test database is available
   set arco_write_user [get_arco_write_user]
   set arco_read_user  [get_arco_read_user]
   set sql "SELECT username FROM dba_users WHERE username = '${arco_write_user}'";
   array set result_array {}
   set column_names {}

   set res [sqlutil_query $sp_id $sql result_array column_names]
   if { $res == 0 } {
      ts_log_fine "user ${arco_write_user} does not exist => nothing to clean"
      close_spawn_process $id;
      return 0
   }

   set result 0

   if { $drop } {
      set synonyms [concat $ARCO_TABLES $ARCO_VIEWS]
      foreach synonym $synonyms {
         set synonym [string toupper $synonym]
         set sql "select SYNONYM_NAME from all_synonyms where SYNONYM_NAME = '$synonym' and OWNER = '${arco_read_user}'"
         set res [sqlutil_query $sp_id $sql result_array column_names]
         if { $res == 0 } {
            ts_log_fine "synonym $synonym does not exist"
            continue
         } elseif { $res < 0 } {
            ts_log_severe "Error: Can not query synonym $synonym"
            set result -1
            close_spawn_process $id;
            return -1
         }

         set sql "DROP SYNONYM ${arco_read_user}.${synonym}"
         ts_log_fine "drop synonym ${arco_read_user}.${synonym}"
         set res [sqlutil_exec $sp_id $sql]
         if { $res != 0 } {
            ts_log_severe "Error: Can not drop synonym $synonym"
            close_spawn_process $id;
            return -1
         }
      }
   }

   # now connect to the test database
   if { [ sqlutil_connect $sp_id 0 ] != 0 } {
      ts_log_severe "Can not connect to database [get_database_name 0]"
      close_spawn_process $id;
      return -2
   }

   if { $drop } {
      # drop views and synonyms
      foreach view $ARCO_VIEWS {
         set view [string toupper $view]
         set sql "select VIEW_NAME from user_views where VIEW_NAME = '$view'"
         set res [sqlutil_query $sp_id $sql result_array column_names]
         if { $res == 0 } {
            ts_log_fine "view $view does not exist"
            continue
         } elseif { $res < 0 } {
            ts_log_severe "Error: Can not query view $view"
            set result -1
            break;
         }

         set sql "DROP VIEW $view"
         ts_log_fine "drop view ${view}"
         set res [sqlutil_exec $sp_id $sql]
         if { $res != 0 } {
            ts_log_severe "Error: Can not query view $view"
            set result -1
            break;
         }
      }

   }

   if { $result == 0 } {
      foreach table $ARCO_TABLES {
         set table [string toupper $table]
         set sql "select table_name from user_tables where table_name = '$table'"
         array set result_array {}
         set column_names {}
         set res [sqlutil_query $sp_id $sql result_array column_names]
         if { $res == 0 } {
            ts_log_fine "table $table does not exist"
            continue
         } elseif { $res < 0 } {
            ts_log_severe "Error: Can not query table $table"
            set result -1
            break;
         }

         if { $drop } {
            set sql "DROP TABLE $table"
            ts_log_fine "drop table ${table}"
            set res [sqlutil_exec $sp_id $sql 120]
            if { $res != 0 } {
               ts_log_severe "Error: Can not drop table $table"
               set result -1
               break;
            }
         } else {
            if { [ clean_table $table ] == 1 } {
               set sql "DELETE FROM $table"
               set res [sqlutil_exec $sp_id $sql 120]
               if { $res != 0 } {
                  ts_log_severe "Error: Can not delete table $table"
                  set result -1
                  break;
               }
            }
         }
         set sql "COMMIT"
         set res [sqlutil_exec $sp_id $sql]
         if { $res != 0 } {
            ts_log_severe "Error: Commit failed"
            set result -1
            break;
         }
      }
   }
   close_spawn_process $id;
   return $result
}


proc arco_clean_postgres_database {{drop 0}} {
   global ARCO_TABLES ARCO_VIEWS

   set id [sqlutil_create]
   if {$id == "-1"} {
      ts_log_severe "Can not create sqlutil"
      return -1
   }
   set sp_id [lindex $id 1]

   # first of all connect to the admin db and check wether the database exists
   if {[sqlutil_connect $sp_id 1] != 0} {
      ts_log_severe "Can not connect to admin database"
      close_spawn_process $id;
      return -2
   }

   # Ensure that the test database is available
   set db_name [get_database_name]
   set sql "select datname from pg_database where datname = '$db_name'"
   array set result_array {}
   set column_names {}
   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res <= 0} {
      ts_log_fine "database $db_name does not exist => nothing to clean"
      close_spawn_process $id;
      return 0
   }

   # now connect to the test database
   if {[sqlutil_connect $sp_id 0] != 0} {
      ts_log_severe "Can not connect to database $db_name"
      close_spawn_process $id;
      return -2
   }

   set result 0

   if {$drop} {
      # drop views
      foreach view $ARCO_VIEWS {
         set view [string tolower $view]

         set sql "SELECT viewname FROM pg_views WHERE viewname = '$view'";
         set res [sqlutil_query $sp_id $sql result_array column_names]
         if {$res == 0} {
            ts_log_fine "view $view does not exist"
            continue
         } elseif { $res < 0 } {
            ts_log_severe "Error: Can not query view $view"
            close_spawn_process $id;
            return -1
         }

         set sql "DROP VIEW $view"
         set res [sqlutil_exec $sp_id $sql]
         if {$res != 0} {
            ts_log_severe "Error: Can not drop view $VIEW"
            close_spawn_process $id;
            return -1
         }
      }
   }
   foreach table $ARCO_TABLES {
      set table [string tolower $table]
      set sql "SELECT tablename, schemaname, tableowner FROM pg_tables WHERE tablename = '$table'"
      array set result_array {}
      set column_names {}
      set res [sqlutil_query $sp_id $sql result_array column_names]
      if {$res == 0} {
         ts_log_fine "table $table does not exist"
         continue
      } elseif {$res < 0} {
         ts_log_severe "Error: Can not query table $table"
         close_spawn_process $id
         return -1
      }

      if {$drop} {
         set sql "DROP TABLE $table CASCADE"
         set res [sqlutil_exec $sp_id $sql]
         if {$res != 0} {
            ts_log_severe "Error: Can not drop table $table"
            set result -1
            break;
         }
      } else {
         if {[clean_table $table] == 1} {
            set sql "DELETE FROM $table"
            set res [sqlutil_exec $sp_id $sql]
            if {$res != 0} {
               ts_log_severe "Error: Can not delete table $table"
               set result -1
               break;
            }
         }
      }
      set sql "COMMIT"
      set res [sqlutil_exec $sp_id $sql]
      if {$res != 0} {
         ts_log_severe "Error: Commit failed"
         set result -1
         break;
      }
   }

   close_spawn_process $id;
   return $result
}

proc arco_clean_mysql_database {{drop 0}} {
   global ARCO_TABLES ARCO_VIEWS

   set id [sqlutil_create]
   if { $id == "-1" } {
      ts_log_severe "Can not create sqlutil"
      return -1
   }
   set sp_id [ lindex $id 1 ]


   # first of all connect to the admin db and check wether the database exists
   if { [ sqlutil_connect $sp_id 1 ] != 0 } {
      ts_log_severe "Can not connect to admin database"
      close_spawn_process $id;
      return -2
   }

   # Ensure that the test database is available
   set db_name [get_database_name]
   set sql "select schema_name FROM information_schema.schemata where schema_name = '${db_name}'"
   array set result_array {}
   set column_names {}
   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res <= 0} {
      ts_log_fine "database $db_name does not exist => nothing to clean"
      close_spawn_process $id;
      return 0
   }

   # now connect to the test database
   if { [ sqlutil_connect $sp_id 0 ] != 0 } {
      ts_log_severe "Can not connect to database $db_name"
      close_spawn_process $id;
      return -2
   }

   set result 0

   if { $drop } {
      # drop views
      foreach view $ARCO_VIEWS {
         set view [string tolower $view]
         set sql "select table_name from information_schema.views where table_name = '$view' and table_schema = '${db_name}'";
         set res [sqlutil_query $sp_id $sql result_array column_names]
         if { $res == 0 } {
            ts_log_fine "view $view does not exist"
            continue
         } elseif { $res < 0 } {
            ts_log_severe "Error: Can not query view $view"
            close_spawn_process $id;
            return -1
         }

         set sql "DROP VIEW $view"
         ts_log_fine "drop view $view"
         set res [sqlutil_exec $sp_id $sql]
         if { $res != 0 } {
            ts_log_severe "Error: Can not drop view $VIEW"
            close_spawn_process $id;
            return -1
         }
      }
   }
   foreach table $ARCO_TABLES {
      set table [string tolower $table]
      set sql "select table_name, table_schema from information_schema.tables where table_name = '$table' and table_schema = '${db_name}'"
      array set result_array {}
      set column_names {}
      set res [sqlutil_query $sp_id $sql result_array column_names]
      if { $res == 0 } {
         ts_log_fine "table $table does not exist"
         continue
      } elseif { $res < 0 } {
         ts_log_severe "Error: Can not query table $table"
         close_spawn_process $id
         return -1
      }

      if { $drop } {
         set sql "DROP TABLE $table CASCADE"
         set res [sqlutil_exec $sp_id $sql]
         if { $res != 0 } {
            ts_log_severe "Error: Can not drop table $table"
            set result -1
            break;
         }
      } else {
         if { [ clean_table $table ] == 1 } {
            set sql "DELETE FROM $table"
            set res [sqlutil_exec $sp_id $sql]
            if { $res != 0 } {
               ts_log_severe "Error: Can not delete table $table"
               set result -1
               break;
            }
         }
      }
      set sql "COMMIT"
      set res [sqlutil_exec $sp_id $sql]
      if { $res != 0 } {
         ts_log_severe "Error: Commit failed"
         set result -1
         break;
      }
   }

   close_spawn_process $id;
   return $result

}

#****** checktree/check_dbwriter_log() *****************************************
#  NAME
#    check_dbwriter_log() -- checks the dbwriter log file
#
#  SYNOPSIS
#    check_dbwriter_log {}
#
#  FUNCTION
#     Reads the dbwriter log file and checks if any error occurs. It looks for
#     occurance of "|E|" in the log output file.
#
#  RESULT
#      0    --   if no error occurs
#     -1    --   if any error occurs
#
#*******************************************************************************
proc check_dbwriter_log { } {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   global DBWRITER_LOG_FNAME

   set return_value ""

   get_file_content $ts_config(master_host) $CHECK_USER $DBWRITER_LOG_FNAME
   for { set i 1 } { $i <= $file_array(0) } { incr i 1 } {
       set line $file_array($i)
         if { [string first "|E|" $line] >= 0 } {
            append return_value "line $i: $line\n"
         }
   }

   if { $return_value != ""} {
      ts_log_severe "Reading $DBWRITER_LOG_FNAME: some errors found."
      return -1
   } else {
      ts_log_finest "Reading $DBWRITER_LOG_FNAME: no errors found."
      return 0
   }

}

proc arco_test_run_level_check {is_starting was_error} {
   # anything to do?
   return 0
}

##
# @brief Do we have a maven build or an ant build for the dbwriter?
#
# @return 1 if we have a maven build, 0 if we have an ant build
proc arco_have_maven_build {} {
   global arco_config

   set ret 0

   if {[file exists $arco_config(arco_source_dir)/pom.xml]} {
      set ret 1
   }

   return $ret
}

##
# @brief Get the JAVA_HOME for the given host
#
# Which Java version to use depends on the version of the SGE installation.
# For SGE 9.1.2 and higher, Java 11 is required,
# for older versions Java 8 is required.
# For SGE 9.1.2 and higher, if Java 11 is not available, but a higher version is available,
# this higher version will be used.
#
# @param host the host for which the JAVA_HOME should be determined
proc arco_get_java_home {host} {
   if {[is_version_in_range "9.1.2"]} {
      set min_version 11
      set allow_higher 1
   } else {
      set min_version 8
      set allow_higher 0
   }
   ts_log_fine "searching JAVA_HOME for host $host, version $min_version, allow_higher $allow_higher"
   set ret [host_conf_get_java $host $min_version 0 $allow_higher]
   if {$ret eq ""} {
      if {$allow_higher} {
         set msg "On host $host the required Java version $min_version (or higher) is not installed"
      } else {
         set msg "On host $host the required Java version $min_version is not installed"
      }
      ts_log_config $msg
   }

   return $ret
}

##
# @brief get the distribution files
#
# Returns the file names of all dbwriter distribution files.
# File names are relative to $SGE_ROOT.
#
# @return list of file names
proc arco_get_distribution_files {} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set dist_files {}
   set host [host_conf_get_java_compile_host]
   analyze_directory_structure $host $CHECK_USER "$ts_config(product_root)/dbwriter" "" files ""
   foreach f $files {
      lappend dist_files "dbwriter/$f"
   }

   return $dist_files
}

##
# @brief get the arco product packages
#
# Returns the names of the arco (dbwriter) packages found in the package
# directory, e.g. "gcs-9.1.5-arco.tar.gz".
#
# @param path directory containing the product packages
# @param type package type, either "tar" or "zip"
# @return list of package file names
proc arco_get_package_files {path type} {
   return [checktree_find_package_files $path $type "arco"]
}

## ----------- installation of the database and the dbwriter --------------------
# Used by the install checks and by checks which have to restore the database.

proc arco_database_install {} {
   global arco_config

   if { [get_database_type] == "oracle" } {
      oracle_init_arco_db
   } elseif { [get_database_type] == "postgres" } {
      postgres_init_arco_db
   } elseif { [get_database_type] == "mysql" } {
      mysql_init_arco_db
   }
}

## ----------- ORACLE ----------------------------------------------------------
proc oracle_init_arco_db {} {

   global ts_config ts_host_config arco_config CHECK_DEBUG_LEVEL


   set id [sqlutil_create]
   if { $id == "-1" } {
      ts_log_severe "Can not create sqlutil"
      return -2
   }
   set sp_id [ lindex $id 1 ]

   # connect to the admin database
   if { [ sqlutil_connect $sp_id 1 ] != 0 } {
      ts_log_severe "Can not connect to database"
      close_spawn_process $id
      return -2
   }

   set arco_write_user [get_arco_write_user]
   set sql "SELECT username FROM dba_users WHERE username = '${arco_write_user}'"

   set res [sqlutil_query $sp_id $sql result_array column_names]
   if { $res < 0 } {
      ts_log_severe "can not query arco_write_user"
      close_spawn_process $id
      return -2
   } elseif { $res > 0 } {
      # database does exists => drop it
      set sql "DROP USER \"$arco_write_user\" CASCADE"
      if { [ sqlutil_exec $sp_id $sql 120 ] != 0 } {
         ts_log_severe "Can't drop user $arco_write_user"
         close_spawn_process $id
         return -2
      }
   }

   set arco_read_user [get_arco_read_user]
   set sql "SELECT username FROM dba_users WHERE username = '${arco_read_user}'"

   set res [sqlutil_query $sp_id $sql result_array column_names]
   if { $res < 0 } {
      ts_log_severe "can not query arco_read_user"
      close_spawn_process $id
      return -2
   } elseif { $res > 0 } {
      set sql "DROP USER \"$arco_read_user\" CASCADE"
      if { [ sqlutil_exec $sp_id $sql 120] != 0 } {
         ts_log_severe "Can't drop user $arco_read_user"
         close_spawn_process $id
         return -2
      }
   }

   set    sql "CREATE USER ${arco_write_user} PROFILE \"DEFAULT\" IDENTIFIED BY secret"
   append sql " DEFAULT TABLESPACE \"$arco_config(tablespace)\" TEMPORARY TABLESPACE \"TEMP\" QUOTA UNLIMITED ON \"$arco_config(tablespace)\" "
   if { [string compare $arco_config(tablespace) $arco_config(tablespace_index)] != 0 } {
      append sql " QUOTA UNLIMITED ON \"$arco_config(tablespace_index)\" "
   }
   append sql " ACCOUNT UNLOCK"

   if { [ sqlutil_exec $sp_id $sql] != 0 } {
      ts_log_severe "Can't create user $arco_write_user"
      close_spawn_process $id
      return -2
   }

   # Grant priviliges for arco_write_user
   # from 6.1u4 and 6.2 version we don't need create any synonym privilege for arco_write_user
   set sql "GRANT CREATE ANY SYNONYM, CREATE TABLE, CREATE VIEW, CREATE SESSION TO ${arco_write_user}"

   if { [ sqlutil_exec $sp_id $sql] != 0 } {
      ts_log_severe "Can't grant privileges to $arco_write_user"
      close_spawn_process $id
      return -2
   }

   set    sql "CREATE USER ${arco_read_user} PROFILE \"DEFAULT\" IDENTIFIED BY secret"
   append sql " DEFAULT TABLESPACE \"$arco_config(tablespace)\" TEMPORARY TABLESPACE \"TEMP\" QUOTA 100 M ON \"$arco_config(tablespace)\" "
   if { [string compare $arco_config(tablespace) $arco_config(tablespace_index)] != 0 } {
      append sql " QUOTA 100 M ON \"$arco_config(tablespace_index)\" "
   }
   append sql " ACCOUNT UNLOCK"

   if { [ sqlutil_exec $sp_id $sql] != 0 } {
      ts_log_severe "Can't create user $arco_write_user"
      close_spawn_process $id
      return -2
   }

   # Grant priviliges for arco_write_user
   # from 6.1u4 and 6.2 version we need create synonym privilege for arco_read_user
   set sql "GRANT CREATE SYNONYM, CREATE SESSION TO ${arco_read_user}"
   if {[sqlutil_exec $sp_id $sql] != 0} {
      ts_log_severe "Can't grant privileges to  $arco_read_user"
      close_spawn_process $id
      return -2
   }

   close_spawn_process $id
   return 0
}

## ----------- POSTGRES --------------------------------------------------------

proc postgres_init_arco_db {} {
   global ts_config ts_host_config arco_config
   global CHECK_DEBUG_LEVEL

   if {[get_dbwriter_status 0] == 0} {
      shutdown_dbwriter
   }

   set id [sqlutil_create]
   if {$id == "-1"} {
      ts_log_severe "Can not create sqlutil"
      return -2
   }
   set sp_id [lindex $id 1]

   # connect to the admin database
   if {[sqlutil_connect $sp_id 1] != 0} {
      ts_log_severe "Can not connect to database"
      close_spawn_process $id
      return -2
   }

   set db_name [get_database_name]
   set sql "SELECT datname FROM pg_database WHERE datname = '${db_name}'"

   set column_names {}
   array set result_array {}
   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res < 0} {
      ts_log_severe "can not query database name"
      close_spawn_process $id
      return -2
   } elseif {$res > 0} {
      # database does exists => drop it
      set sql "DROP DATABASE $db_name"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't drop database $db_name, may be another user is using this database"
         close_spawn_process $id
         return -2
      }
   }

   set arco_write_user [get_arco_write_user]
   set sql "SELECT usename FROM pg_user WHERE usename = '${arco_write_user}'"

   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res < 0} {
      ts_log_severe "can not query arco_write_user"
      close_spawn_process $id
      return -2
   } elseif {$res > 0} {
      #revoke priviledges on tablespace so we can drop the user
      set sql "revoke all on tablespace $arco_config(tablespace) from $arco_write_user"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't revoke priviledges on $arco_config(tablespace) from $arco_write_user"
         close_spawn_process $id
         return -2
      }
      # user does exists => drop it
      set sql "DROP USER $arco_write_user"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't drop user $arco_write_user"
         close_spawn_process $id
         return -2
      }
   }

   set arco_read_user [get_arco_read_user]
   set sql "SELECT usename FROM pg_user WHERE usename = '${arco_read_user}'"

   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res < 0} {
      ts_log_severe "can not query arco_read_user"
      close_spawn_process $id
      return -2
   } elseif {$res > 0} {
      set sql "DROP USER $arco_read_user"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't drop user $arco_read_user"
         close_spawn_process $id
         return -2
      }
   }

   set sql "CREATE USER $arco_write_user PASSWORD 'secret'"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't create user $arco_write_user"
      close_spawn_process $id
      return -2
   }

   set sql "GRANT ALL ON TABLESPACE $arco_config(tablespace) TO $arco_write_user"
   if {[sqlutil_exec $sp_id $sql] != 0} {
      ts_log_severe "Can't grant privileges to $arco_write_user"
      close_spawn_process $id
      return -2
   }

   if {[string compare "$arco_config(tablespace)" "$arco_config(tablespace_index)"] != 0} {
      set sql "grant all on tablespace $arco_config(tablespace_index) to $arco_write_user"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't grant privileges to $arco_write_user"
         close_spawn_process $id
         return -2
      }
   }

   set sql "CREATE USER $arco_read_user PASSWORD 'secret'"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't create user $arco_read_user"
      close_spawn_process $id
      return -2
   }

   set sql "CREATE DATABASE $db_name OWNER $arco_write_user"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't create database $db_name"
      close_spawn_process $id
      return -2
   }

   # connect to the newly created database
   if {[sqlutil_connect $sp_id 0] != 0} {
      ts_log_severe "Can not connect to database $db_name"
      close_spawn_process $id
      return -2
   }

   set sql "SELECT nspname FROM pg_catalog.pg_namespace WHERE nspname = '$arco_config(database_schema)'"
   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res < 0} {
      ts_log_severe "Can't query schema $arco_config(database_schema)"
      close_spawn_process $id
      return -2
   }
   if {$res == 0} {
      # schema doesn't exist, create it
      set sql "CREATE SCHEMA $arco_config(database_schema)"
      if {[sqlutil_exec $sp_id $sql] != 0 } {
         ts_log_severe "Can't create schema $arco_config(database_schema)"
         close_spawn_process $id
         return -2
      }

      # grant usage on schema to arco_read users
      set sql "GRANT USAGE ON SCHEMA $arco_config(database_schema) TO $arco_read_user"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't grant usage on $arco_config(database_schema) to $arco_read_user"
         close_spawn_process $id
         return -2
      }
   }

   if {[string compare $arco_config(database_schema) "public"] != 0} {
      # connect to the admin database
      if {[sqlutil_connect $sp_id 1] != 0} {
         ts_log_severe "Can not connect to database $db_name"
         close_spawn_process $id
         return -2
      }

      # alter the arco_write user's search path
      set sql "ALTER USER $arco_write_user SET search_path=$arco_config(database_schema), public"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't alter $arco_write_user search_path"
         close_spawn_process $id
         return -2
      }

      # alter the arco_read user's search path
      set sql "ALTER USER $arco_read_user SET search_path=$arco_config(database_schema), public"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't alter $arco_read_user search_path"
         close_spawn_process $id
         return -2
      }
   }

   close_spawn_process $id
   return 0
}

## ----------- MySQL --------------------------------------------------------
proc mysql_init_arco_db {} {

   global ts_config ts_host_config arco_config
   global CHECK_DEBUG_LEVEL

   if {[get_dbwriter_status 0] == 0} {
      shutdown_dbwriter
   }

   set id [sqlutil_create]
   if {$id == "-1"} {
      ts_log_severe "Can't create sqlutil"
      return -2
   }
   set sp_id [lindex $id 1]

   # connect to the admin database
   if {[sqlutil_connect $sp_id 1] != 0} {
      ts_log_severe "Can not connect to database"
      close_spawn_process $id
      return -2
   }

   set db_name [get_database_name]
   set column_names {}
   array set result_array {}

   # drop database ${db_name} if exists
   set sql "SELECT schema_name FROM information_schema.schemata where schema_name = '${db_name}'"
   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res < 0} {
      ts_log_severe "can not query database name"
      close_spawn_process $id
      return -2
   } elseif {$res > 0} {
      # database does exists => drop it
      set sql "DROP DATABASE $db_name"
      if {[sqlutil_exec $sp_id $sql] != 0} {
         ts_log_severe "Can't drop database $db_name, may be another user is using this database"
         close_spawn_process $id
         return -2
      }
   }

   # drop user if exists
   set arco_write_user [get_arco_write_user]
   set sql "SELECT user, host FROM mysql.user WHERE user = '${arco_write_user}'"
   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res < 0} {
      ts_log_severe "Can't query user $arco_write_user"
      close_spawn_process $id
      return -2
   } elseif {$res > 0} {
      # user does exists => drop it
      foreach i [array names result_array] {
         if {"$result_array($i)" != "${arco_write_user}"} {
            # revoke user's privileges
            set sql "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${arco_write_user}'@'$result_array($i)'"
            if {[sqlutil_exec $sp_id $sql] != 0} {
               ts_log_severe "Can't revoke privileges from user '$arco_write_user'@'$result_array($i)'"
               close_spawn_process $id
               return -2
            }
            # drop user
            set sql "DROP USER '$arco_write_user'@'$result_array($i)'"
            if {[sqlutil_exec $sp_id $sql] != 0} {
               ts_log_severe "Can't drop user '$arco_write_user'@'$result_array($i)'"
               close_spawn_process $id
               return -2
            }
         }
      }
   }

   set arco_read_user [get_arco_read_user]
   set sql "SELECT user, host FROM mysql.user WHERE user = '${arco_read_user}'"

   set res [sqlutil_query $sp_id $sql result_array column_names]
   if {$res < 0} {
      ts_log_severe "Can't query user $arco_read_user"
      close_spawn_process $id
      return -2
   } elseif {$res > 0} {
      foreach i [array names result_array] {
         if {"$result_array($i)" != "${arco_read_user}"} {
            # before dropping the user we have to revoke his privileges
            set sql "REVOKE SELECT, SHOW VIEW on ${db_name}.* FROM '${arco_read_user}'@'$result_array($i)'"
            if {[sqlutil_exec $sp_id $sql] != 0} {
               ts_log_severe "Can't revoke privileges from user '${arco_read_user}'@'$result_array($i)'"
               close_spawn_process $id
               return -2
            }
            # drop user
            set sql "DROP USER '$arco_read_user'@'$result_array($i)'"
            if {[sqlutil_exec $sp_id $sql] != 0} {
               ts_log_severe "Can't drop user '$arco_read_user'@'$result_array($i)'"
               close_spawn_process $id
               return -2
            }
         }
      }
   }

   set sql "CREATE DATABASE $db_name"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't create database $db_name"
      close_spawn_process $id
      return -2
   }

   # Note:
   # In MySQL database user is identified by the host from which he connects and his username
   # We have to create users: 'username'@'%'
   #                          'username'@'database_host' [ mandatory if swc_host = database_host ]
   # The grant statement also creates the user in the database

   # With older MySQL versions the user was implicitly created on a GRANT statement if it did not exist.
   # With newer MySQL versions this is not the case anymore.
   # So we have to create the user before granting privileges to it.
   # This should also work with older versions of MySQL (which we will probably never support again).
   set sql "CREATE USER '$arco_write_user'@'%' IDENTIFIED BY 'secret'"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't grant privileges to user '$arco_write_user'@'$host'"
      close_spawn_process $id
      return -2
   }

   set sql "CREATE USER '$arco_read_user'@'%' IDENTIFIED BY 'secret'"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't grant privileges to user '$arco_write_user'@'$host'"
      close_spawn_process $id
      return -2
   }

   # Grant access to the arco_write_user for all hosts.
   set sql "GRANT ALL on ${db_name}.* TO '$arco_write_user'@'%' WITH GRANT OPTION"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't grant privileges to user '$arco_write_user'@'%'"
      close_spawn_process $id
      return -2
   }

   # Grant access to the arco_read_user for all hosts.
   set sql "GRANT SELECT, SHOW VIEW on ${db_name}.* to '$arco_read_user'@'%'"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't grant privileges to user '$arco_read_user'@'%'"
      close_spawn_process $id
      return -2
   }

   # Flush privileges to make sure that all changes are applied.
   set sql "FLUSH PRIVILEGES"
   if {[sqlutil_exec $sp_id $sql] < 0} {
      ts_log_severe "Can't flush privileges"
      close_spawn_process $id
      return -2
   }

   # Close connection to sql util.
   close_spawn_process $id

   return 0
}

proc arco_dbwriter_install {} {
   global CHECK_TESTSUITE_INSTALL_MODE

   # If we are doing automatic installation, use it if available (since 9.1.3)
   if {$CHECK_TESTSUITE_INSTALL_MODE == "automatic" && [is_version_in_range "9.1.3"]} {
      return [arco_dbwriter_install_auto]
   }
   return [arco_dbwriter_install_manual]
}

# Steps shared by manual and automatic dbwriter installation: stop any
# running dbwriter, sanity-check the install script, and stage the JDBC
# driver next to dbwriter.jar on the install host. Returns 0 on success,
# -1 on a setup failure that should abort the install.
proc arco_dbwriter_install_prepare {} {
   global CHECK_USER
   global ts_config arco_config

   if {[get_dbwriter_status 0] == 0} {
      shutdown_dbwriter
   }

   ts_log_fine "install dbwriter on host $arco_config(dbwriter_host) ..."

   if {[file isfile "$ts_config(product_root)/dbwriter/inst_dbwriter"] != 1} {
      ts_log_severe "dbwriter install script not found"
      return -1
   }

   set jdbc_driver [get_jdbc_driver_path]
   if {$jdbc_driver != "NONE"} {
      # copy the jdbc driver
      set args "$jdbc_driver $ts_config(product_root)/dbwriter/lib"
      start_remote_prog "$arco_config(dbwriter_host)" $CHECK_USER "cp" $args
      if {$prg_exit_state != 0} {
         set fs_server [fs_config_get_filesystem_server $ts_config(product_root)]
         start_remote_prog $fs_server "root" "cp" $args
         if {$prg_exit_state != 0} {
            ts_log_severe "copy jdbc driver failed"
            return -1
         }
      }
   }
   return 0
}

proc arco_dbwriter_install_manual {} {
   global CHECK_USER CHECK_DEBUG_LEVEL CHECK_INSTALL_RC
   global ts_config arco_config ts_host_config

   set ret [arco_dbwriter_install_prepare]
   if {$ret != 0} {
      return $ret
   }

   set LICENSE_AGREEMENT            [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_LICENSE_AGREEMENT] ]
   set ANSWER_YES                   [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_ANSWER_YES] ]
   set HIT_RETURN_TO_CONTINUE       [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_HIT_RETURN_TO_CONTINUE] ]
   set CURRENT_GRID_ROOT_DIRECTORY  [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CURRENT_GRID_ROOT_DIRECTORY] "*" "*" ]
   set GRID_ROOT_DIRECTORY_NOT_SET  [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_GRID_ROOT_DIRECTORY_NOT_SET]]
   set CELL_NAME_FOR_QMASTER        [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_CELL_NAME_FOR_QMASTER] "*"]
   set DETECT_CHOOSE_NEW_NAME       [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DETECT_CHOOSE_NEW_NAME] ]
   set DETECT_REMOVE_OLD_CLUSTER    [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_DETECT_REMOVE_OLD_CLUSTER] ]
   set REMOVE_OLD_RC_SCRIPT         [translate $ts_config(master_host) 0 1 0 [sge_macro DISTINST_REMOVE_OLD_RC_SCRIPT] ]

   ts_log_fine "inst_dbwriter"
   set id [open_remote_spawn_process "$arco_config(dbwriter_host)" "root"  "./inst_dbwriter" "" 0 "$ts_config(product_root)/dbwriter"]
   set sp_id [ lindex $id 1 ]

   log_user 1

    set error_count 0
    while { $error_count == 0 } {
       if {$CHECK_DEBUG_LEVEL > 0} {
         flush stdout
         if {$CHECK_DEBUG_LEVEL > 1 } {
            puts "-->testsuite: press RETURN"
            set anykey [wait_for_enter 1]
         }
       }
       log_user 1
       set timeout 60
       expect {
          flush stdout
          -i $sp_id full_buffer {
             ts_log_severe "install_dbwriter - buffer overflow, increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
             incr error_count 1
             break
          }
          -i $sp_id "More" {
             ts_send $sp_id " "
             continue
          }
          -i $sp_id $LICENSE_AGREEMENT {
             ts_send $sp_id "$ANSWER_YES\n"
             continue
          }
          -i $sp_id eof {
             ts_log_severe "install_dbwriter - unexpected eof"
             incr error_count 1
             break
          }
          -i $sp_id "coredump" {
             ts_log_severe "install_dbwriter - coredump"
             incr error_count 1
             break
          }
          -i $sp_id timeout {
             ts_log_severe "install_dbwriter - timeout while waiting for output"
             incr error_count 1
             break
          }
          -i $sp_id "Hit <RETURN> to continue >> " {
             send_to_spawn_id $sp_id ""
             continue
          }
          -i $sp_id $CURRENT_GRID_ROOT_DIRECTORY {
             send_to_spawn_id $sp_id $ts_config(product_root)
             continue
          }

          # the installer asks for the path instead of confirming it - it does
          # that when SGE_ROOT is empty in its environment
          -i $sp_id $GRID_ROOT_DIRECTORY_NOT_SET {
             ts_log_fine "SGE_ROOT is not set, answering with $ts_config(product_root)"
             send_to_spawn_id $sp_id $ts_config(product_root)
             continue
          }
          -i $sp_id $CELL_NAME_FOR_QMASTER {
             send_to_spawn_id $sp_id $ts_config(cell)
             continue
          }

          -i $sp_id -- $DETECT_CHOOSE_NEW_NAME {
             send_to_spawn_id $sp_id "y"
             continue
          }

          #Delete detected dbwriter service for chosen cluster_name
          -i $sp_id -- $DETECT_REMOVE_OLD_CLUSTER {
             send_to_spawn_id $sp_id "n"
             continue
          }

          #Remove conflicting RC files/SMF service
          -i $sp_id -- $REMOVE_OLD_RC_SCRIPT  {
             send_to_spawn_id $sp_id "y"
             continue
          }

          -i $sp_id "*nter the path to your java installation * >> " {
             set java_home [arco_get_java_home $arco_config(dbwriter_host)]
             if {$java_home == ""} {
               ts_log_severe "didn't find a Java version >= 8 on host $arco_config(dbwriter_host)"
               incr error_count 1
               break
             }
             send_to_spawn_id $sp_id $java_home
             continue
          }
          -i $sp_id "*nter your database type * >> " {
             set input [string range [get_database_type] 0 0 ]
             send_to_spawn_id $sp_id $input
             continue
          }
          -i $sp_id "*nter the name of your * host * >> " {
             send_to_spawn_id $sp_id [get_database_host]
             continue
          }
          -i $sp_id "*nter the port of your * >> " {
             send_to_spawn_id $sp_id [get_database_port]
             continue
          }
          -i $sp_id "*nter the name of your * database * >> " {
             send_to_spawn_id $sp_id [get_database_name]
             continue
          }
          -i $sp_id "*nter the name of the database user * >> " {
             send_to_spawn_id $sp_id [get_arco_write_user]
             continue
          }
          -i $sp_id "*nter the password of the database user >> " {
             send_to_spawn_id $sp_id [get_arco_user_pwd]
             continue
          }
          -i $sp_id "*etype the password >> " {
             send_to_spawn_id $sp_id [get_arco_user_pwd]
             continue
          }
          -i $sp_id "Should the connection to the database be tested? (y/n) * >> " {
             send_to_spawn_id $sp_id "y"
             continue
          }
          -i $sp_id "Do you want to use the existing dbwriter configuration file? (y/n) * >> " {
             # Test CS-2323: Repeat the dbwriter installation (menu item 60, arco_database_install, arco_dbwriter_install_manual
             send_to_spawn_id $sp_id "y"
             continue
          }
          -i $sp_id "Do you want to repeat database connection setup*>> " {
             ts_log_severe "inst_dbwriter could not setup the database connection"
             incr error_count 1
             break
          }
          -i $sp_id "Should the database model be upgraded to version * >> " {
             send_to_spawn_id $sp_id "y"
             continue
          }
          -i $sp_id "*nter the name of this database user * >> " {
             send_to_spawn_id $sp_id [get_arco_read_user]
             continue
          }
          -i $sp_id "*nter the interval between two dbwriter runs in seconds * >> " {
             send_to_spawn_id $sp_id $arco_config(arco_dbwriter_interval)
             continue
          }
          -i $sp_id "*nter the path of the dbwriter spool directory *>> " {
             send_to_spawn_id $sp_id ""
             continue
          }
          -i $sp_id "*nter the file with the derived value rules * >> " {
             send_to_spawn_id $sp_id ""
             continue
          }
          -i $sp_id "*nter the debug level of the dbwriter * >> " {
             send_to_spawn_id $sp_id $arco_config(arco_dbwriter_debug_level)
             continue
          }
          -i $sp_id "*nter the name of TABLESPACE for tables * >> " {
             send_to_spawn_id $sp_id $arco_config(tablespace)
             continue
          }
          -i $sp_id "*nter the name of TABLESPACE for indexes * >> " {
             send_to_spawn_id $sp_id $arco_config(tablespace_index)
             continue
          }
          -i $sp_id "*nter the name of the database schema * >> " {
             set input [get_database_schema]
             send_to_spawn_id $sp_id $input
             continue
          }
          -i $sp_id "Are * settings correct? (y/n) * >> " {
             send_to_spawn_id $sp_id "y"
             continue
          }
          -i $sp_id "start dbwriter at machine boot (y/n) * >> " {
             if {$CHECK_INSTALL_RC && [ge_has_feature "systemd"] && [host_has_systemd $arco_config(dbwriter_host)]} {
                send_to_spawn_id $sp_id "y"
             } else {
                send_to_spawn_id $sp_id "n"
             }
             continue
          }
          #SMF startup is always disabled in testsuite
          -i $sp_id -- "NOTE: If you select \"n\" SMF will be not used at all"  {
             send_to_spawn_id $sp_id "n"
             continue
          }
          -i $sp_id "Installation of dbWriter completed" {
             break
          }
          -i $sp_id "Installation of dbWriter failed" {
             ts_log_severe "install_dbwriter - FAILED"
             incr error_count 1
             break
          }
          -i $sp_id "Error:" {
             ts_log_severe "install_dbwriter - $expect_out(0,string)"
             break
          }
          -i $sp_id "ommand failed*\n" {
             ts_log_severe "install_dbwriter - $expect_out(0,string)"
             break
          }
          -i $sp_id "_exit_status_:(*)" {
             set exit_status [get_string_value_between "_exit_status_:(" ")" $expect_out(0,string)]
             if { $exit_status != 0 } {
                ts_log_severe "install_dbwriter failed with exist status $exit_status"
                incr error_count 1
             }
             break
          }
          -i $sp_id default {
             ts_log_severe "install_dbwriter - undefined behaviour: $expect_out(buffer)"
             incr error_count 1
             break
          }
       } ;# end of expect
    } ;# end of while
   close_spawn_process $id

   return $error_count
}

# Build the inst_dbwriter auto-install template content as a Tcl array in
# the format expected by write_remote_file (index 0 = line count, indices
# 1..N = lines). Values mirror the choices made by the manual install in
# arco_dbwriter_install_manual.
proc arco_dbwriter_build_autoinst_config {array_name} {
   upvar $array_name data
   global CHECK_INSTALL_RC
   global ts_config arco_config

   set db_type [get_database_type]

   # DBWRITER_CALCULATION_FILE: same path the manual install would derive
   switch -- $db_type {
      "oracle"      { set calc_subdir "oracle" }
      "mysql"       { set calc_subdir "mysql" }
      default       { set calc_subdir "postgres" }
   }

   # DB_SCHEMA: queryDBSchema in inst_util.sh hard-codes "n/a" for MySQL
   if {$db_type == "mysql"} {
      set db_schema "n/a"
   } else {
      set db_schema [get_database_schema]
   }

   set java_home [arco_get_java_home $arco_config(dbwriter_host)]
   if {$java_home == ""} {
      ts_log_severe "didn't find a Java version >= 11 on host $arco_config(dbwriter_host)"
      return -1
   }

   if {$CHECK_INSTALL_RC && [ge_has_feature "systemd"] && [host_has_systemd $arco_config(dbwriter_host)]} {
      set add_to_rc "true"
   } else {
      set add_to_rc "false"
   }

   set lines [list]
   lappend lines "SGE_ROOT=\"$ts_config(product_root)\""
   lappend lines "CELL_NAME=\"$ts_config(cell)\""
   lappend lines "JAVA_HOME=\"$java_home\""
   lappend lines "DB_TYPE=\"$db_type\""
   lappend lines "DB_HOST=\"[get_database_host]\""
   lappend lines "DB_PORT=\"[get_database_port]\""
   lappend lines "DB_NAME=\"[get_database_name]\""
   lappend lines "DB_USER=\"[get_arco_write_user]\""
   lappend lines "DB_PW=\"[get_arco_user_pwd]\""
   lappend lines "READ_USER=\"[get_arco_read_user]\""
   if {$db_type == "oracle"} {
      # Oracle uses READ_USER_PW to create synonyms; same password as DB_USER
      lappend lines "READ_USER_PW=\"[get_arco_user_pwd]\""
   } else {
      lappend lines "READ_USER_PW=\"\""
   }
   lappend lines "DB_SCHEMA=\"$db_schema\""
   lappend lines "TABLESPACE=\"$arco_config(tablespace)\""
   lappend lines "TABLESPACE_INDEX=\"$arco_config(tablespace_index)\""
   lappend lines "DBWRITER_INTERVAL=\"$arco_config(arco_dbwriter_interval)\""
   lappend lines "SPOOL_DIR=\"$ts_config(product_root)/$ts_config(cell)/spool/dbwriter\""
   lappend lines "DBWRITER_CALCULATION_FILE=\"$ts_config(product_root)/dbwriter/database/$calc_subdir/dbwriter.xml\""
   lappend lines "DBWRITER_REPORTING_FILE=\"$ts_config(product_root)/$ts_config(cell)/common/reporting.jsonl\""
   lappend lines "DBWRITER_DEBUG=\"$arco_config(arco_dbwriter_debug_level)\""
   lappend lines "ADD_TO_RC=\"$add_to_rc\""

   set i 1
   foreach line $lines {
      set data($i) $line
      incr i
   }
   set data(0) [llength $lines]
   return 0
}

proc arco_dbwriter_install_auto {} {
   global CHECK_USER
   global ts_config arco_config

   set ret [arco_dbwriter_install_prepare]
   if {$ret != 0} {
      return $ret
   }

   set conf_file "$ts_config(product_root)/dbwriter/autoinst_dbwriter_$ts_config(cell).conf"

   if {[arco_dbwriter_build_autoinst_config conf_array] != 0} {
      return -1
   }

   # We write the file as the admin user,
   # but inst_dbwriter.sh reading it will be started as root.
   # Being root will not help on NFS, so make sure everybody can read it.
   if {[write_remote_file $arco_config(dbwriter_host) $CHECK_USER $conf_file conf_array "644"] != 0} {
      ts_log_severe "could not write dbwriter auto-installation config $conf_file on $arco_config(dbwriter_host)"
      return -1
   }

   ts_log_fine "inst_dbwriter -auto $conf_file"
   set my_timeout 600
   set exit_val 0
   set output [start_remote_prog $arco_config(dbwriter_host) "root" "./inst_dbwriter" "-auto $conf_file" exit_val $my_timeout 0 "$ts_config(product_root)/dbwriter"]

   if {$exit_val != 0} {
      ts_log_severe "inst_dbwriter -auto failed with exit code $exit_val\n$output"
      return 1
   }

   if {[string first "Installation of dbwriter completed" $output] < 0} {
      ts_log_severe "inst_dbwriter -auto did not report successful completion\n$output"
      return 1
   }

   # Keep the autoinstall template for easier debugging.
   # delete_remote_file $arco_config(dbwriter_host) "root" $conf_file
   return 0
}
