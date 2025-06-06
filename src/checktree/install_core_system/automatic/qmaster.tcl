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

proc install_qmaster {} {
   global ts_config
   global CHECK_USER
   global CORE_INSTALLED
   global check_use_installed_system CHECK_ADMIN_USER_SYSTEM
   global CHECK_DEBUG_LEVEL CHECK_QMASTER_INSTALL_OPTIONS
   global CHECK_PROTOCOL_DIR

   ts_log_fine "install qmaster ($ts_config(product_type) system) on host $ts_config(master_host) ..."

   if {$check_use_installed_system != 0} {
      puts "no need to install qmaster on host $ts_config(master_host), noinst parameter is set"
      set CORE_INSTALLED ""
      if {[startup_qmaster] == 0} {
         lappend CORE_INSTALLED $ts_config(master_host)
         write_install_list
      }
      return
   }

   set CORE_INSTALLED ""
   write_install_list

   if {![file isfile "$ts_config(product_root)/inst_sge"]} {
      ts_log_severe "inst_sge - inst_sge file not found"
      return
   }

   #dump hostlist to file
   set admin_hosts "$ts_config(all_nodes) $ts_config(shadowd_hosts)"
   set admin_hosts [lsort -unique $admin_hosts]

   set host_file_name "$CHECK_PROTOCOL_DIR/hostlist"
   set f [open $host_file_name w]
   foreach host $admin_hosts {
      puts $f $host
   }
   close $f

   set feature_install_options ""
   if {$ts_config(product_feature) == "csp"} {
      append feature_install_options "-csp"
   }
   if {$ts_config(product_feature) == "munge"} {
      append feature_install_options "-munge"
   }

   set my_timeout 500
   set exit_val 0

   switch_spooling

   ts_log_fine "install_qmaster $CHECK_QMASTER_INSTALL_OPTIONS $feature_install_options -auto $ts_config(product_root)/autoinst_config_$ts_config(cell).conf"
   if {$CHECK_ADMIN_USER_SYSTEM == 0} {
      set output [start_remote_prog "$ts_config(master_host)" "root"  "./install_qmaster" "$CHECK_QMASTER_INSTALL_OPTIONS $feature_install_options -auto $ts_config(product_root)/autoinst_config_$ts_config(cell).conf" exit_val $my_timeout 0 $ts_config(product_root) env_list]
   } else {
      ts_log_finer "--> install as user $CHECK_USER <--"
      set output [start_remote_prog "$ts_config(master_host)" "$CHECK_USER"  "./install_qmaster" "$CHECK_QMASTER_INSTALL_OPTIONS $feature_install_options -auto $ts_config(product_root)/autoinst_config_$ts_config(cell).conf" exit_val $my_timeout 0 $ts_config(product_root) env_list]
   }

   ts_log_fine "installation output:\n$output"

   log_user 1

   set hostcount 0

   set do_log_output 0;# _LOG
   if {$CHECK_DEBUG_LEVEL == 2} {
      set do_log_output  1 ;# 1
   }

   # Wait for NFS availability of the settings file on each host
   foreach host [get_all_hosts] {
      wait_for_remote_file $host $CHECK_USER $ts_config(product_root)/$ts_config(cell)/common/settings.sh
   }


   if {$exit_val == 0} {
      lappend CORE_INSTALLED $ts_config(master_host)
      write_install_list
      return
   } else {
      ts_log_warning "install failed:\n$output"
      return
   }
}

#****** qmaster.60/write_autoinst_config() *************************************
#  NAME
#     write_autoinst_config() -- write the autoinst config file
#
#  SYNOPSIS
#     write_autoinst_config {filename host {do_cleanup 1} {file_delete_wait 1}}
#
#  FUNCTION
#     Writes the config file for autoinstallation.
#
#  INPUTS
#     filename             - filename of the config file
#     host                 - config file is for this host
#     {do_cleanup 1}       - clean spool directories?
#     {file_delete_wait 1} - delete the file before writing it, and wait for it
#                            to vanish / reappear
#     {exechost 0}         - is this a config for an exechost installation?
#     {set_file_perms 0}   - shall the file permissions be checked
#                            during (qmaster) installation?
#     {{shadowd 0}         - is this a config for a shadowd host installation?
#*******************************************************************************
proc write_autoinst_config {filename host {do_cleanup 1} {file_delete_wait 1} {exechost 0} {set_file_perms 0} {shadowd 0}} {
   global CHECK_USER local_execd_spool_set
   global CHECK_INSTALL_RC
   global ts_config

   set execd_port [expr $ts_config(commd_port) + 1]
   set gid_range [get_gid_range $CHECK_USER $ts_config(commd_port)]

   set db_dir [get_bdb_spooldir $ts_config(master_host) 1]

   # deleting berkeley db spool dir. autoinstall will stop, if
   # bdb spooldir exists.
   # db_dir might be empty if classic spooling is used, should skip removing such directory
   if {$do_cleanup && $exechost == 0 && $shadowd == 0 && [string compare $ts_config(spooling_method) "classic"] != 0} {
      if {[remote_file_isdirectory $ts_config(master_host) $db_dir]} {
         remote_delete_directory $ts_config(master_host) $db_dir
      }
   }
   ts_log_fine "db_dir is \"$db_dir\""

   if {$file_delete_wait} {
      delete_remote_file $host $CHECK_USER $filename
   }

   set auto_config_content ""
   append auto_config_content "SGE_ROOT=\"$ts_config(product_root)\"\n"
   append auto_config_content "SGE_QMASTER_PORT=\"$ts_config(commd_port)\"\n"
   append auto_config_content "SGE_EXECD_PORT=\"$execd_port\"\n"

   # some GE 6.2 specific parameters
   append auto_config_content "SGE_ENABLE_SMF=\"false\"\n"
   append auto_config_content "SGE_CLUSTER_NAME=\"$ts_config(cluster_name)\"\n"

   # SGE 6.* uses SERVICE_TAGS
   if {$ts_config(gridengine_version) < 80} {
      append auto_config_content "SERVICE_TAGS=\"disable\"\n"
   }
   append auto_config_content "CELL_NAME=\"$ts_config(cell)\"\n"
   append auto_config_content "ADMIN_USER=\"$CHECK_USER\"\n"

   if {$exechost || $shadowd} {
      set spooldir [get_local_spool_dir $host qmaster 0]
   } else {
      set spooldir [get_local_spool_dir $host qmaster $do_cleanup]
   }
   if {$spooldir != ""} {
      append auto_config_content "QMASTER_SPOOL_DIR=\"$spooldir\"\n"
   } else {
      append auto_config_content "QMASTER_SPOOL_DIR=\"$ts_config(product_root)/$ts_config(cell)/spool/qmaster\"\n"
   }
   append auto_config_content "EXECD_SPOOL_DIR=\"$ts_config(product_root)/$ts_config(cell)/spool\"\n"
   append auto_config_content "GID_RANGE=\"$gid_range\"\n"
   append auto_config_content "SPOOLING_METHOD=\"$ts_config(spooling_method)\"\n"
   append auto_config_content "DB_SPOOLING_DIR=\"$db_dir\"\n"
   # exec/shadowd host install: only use the given host in the host lists
   if {$exechost || $shadowd} {
      append auto_config_content "ADMIN_HOST_LIST=\"$host\"\n"
      append auto_config_content "SUBMIT_HOST_LIST=\"\"\n"
      append auto_config_content "EXEC_HOST_LIST=\"$host\"\n"
      append auto_config_content "EXEC_HOST_LIST_RM=\"$host\"\n"
      if {$exechost} {
         set spooldir [get_local_spool_dir $host "execd" $do_cleanup]
      } else {
         set spooldir [get_local_spool_dir $host "execd" 0]
      }
      append auto_config_content "EXECD_SPOOL_DIR_LOCAL=\"$spooldir\"\n"
   } else {
      if {$ts_config(admin_only_hosts) != "none"} {
         append auto_config_content "ADMIN_HOST_LIST=\"$ts_config(all_nodes) $ts_config(admin_only_hosts)\"\n"
      } else {
         append auto_config_content "ADMIN_HOST_LIST=\"$ts_config(all_nodes)\"\n"
      }
      if {$ts_config(submit_only_hosts) != "none"} {
         append auto_config_content "SUBMIT_HOST_LIST=\"$ts_config(all_nodes) $ts_config(submit_only_hosts)\"\n"
      } else {
         append auto_config_content "SUBMIT_HOST_LIST=\"$ts_config(all_nodes)\"\n"
      }
      append auto_config_content "EXEC_HOST_LIST=\"$ts_config(execd_nodes)\"\n"
      append auto_config_content "EXEC_HOST_LIST_RM=\"$ts_config(execd_nodes)\"\n"
      append auto_config_content "EXECD_SPOOL_DIR_LOCAL=\"\"\n"
   }
   append auto_config_content "HOSTNAME_RESOLVING=\"true\"\n"
   append auto_config_content "SHELL_NAME=\"rsh\"\n"
   append auto_config_content "COPY_COMMAND=\"rcp\"\n"
   append auto_config_content "DEFAULT_DOMAIN=\"none\"\n"
   append auto_config_content "ADMIN_MAIL=\"$ts_config(report_mail_to)\"\n"
   if {$CHECK_INSTALL_RC && [ge_has_feature "systemd"]} {
      append auto_config_content "ADD_TO_RC=\"true\"\n"
   } else {
      append auto_config_content "ADD_TO_RC=\"false\"\n"
   }
   if {[ge_has_feature "systemd"]} {
      append auto_config_content "SLICE_NAME=\"ocs$ts_config(commd_port)\"\n"
   }
   if {$set_file_perms} {
      append auto_config_content "SET_FILE_PERMS=\"true\"\n"
   } else {
      append auto_config_content "SET_FILE_PERMS=\"false\"\n"
   }
   append auto_config_content "RESCHEDULE_JOBS=\"wait\"\n"
   append auto_config_content "SCHEDD_CONF=\"1\"\n"
   append auto_config_content "SHADOW_HOST=\"$ts_config(shadowd_hosts)\"\n"
   append auto_config_content "REMOVE_RC=\"false\"\n"
   append auto_config_content "CSP_RECREATE=\"true\"\n"
   append auto_config_content "CSP_COPY_CERTS=\"true\"\n"
   append auto_config_content "CSP_COUNTRY_CODE=\"DE\"\n"
   append auto_config_content "CSP_STATE=\"Germany\"\n"
   append auto_config_content "CSP_LOCATION=\"Building\"\n"
   append auto_config_content "CSP_ORGA=\"Devel\"\n"
   append auto_config_content "CSP_ORGA_UNIT=\"Software\"\n"
   append auto_config_content "CSP_MAIL_ADDRESS=\"$ts_config(report_mail_to)\"\n"

   set cur_line 1
   foreach line [split $auto_config_content "\n"] {
      set auto_config_content_array($cur_line) $line
      incr cur_line 1
   }
   incr cur_line -1
   set auto_config_content_array(0) $cur_line

   write_remote_file $host $CHECK_USER $filename auto_config_content_array
}

#                                                             max. column:     |
#****** install_core_system/create_autoinst_config() ******
#
#  NAME
#     create_autoinst_config -- ???
#
#  SYNOPSIS
#     create_autoinst_config { }
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
proc create_autoinst_config {} {
   global ts_config
   global CHECK_USER
   global CORE_INSTALLED
   global check_use_installed_system CHECK_ADMIN_USER_SYSTEM
   global CHECK_DEBUG_LEVEL CHECK_QMASTER_INSTALL_OPTIONS
   global CHECK_PROTOCOL_DIR


   # do setting of the file permissions only if we use tar.gz packages,
   # and try to do it on the file server
   set set_file_perm 0
   if {$ts_config(package_type) == "tar" || $ts_config(package_type) == "create_tar"} {
      set fileserver [fs_config_get_server_for_path $ts_config(product_root) 0]
      if {$fileserver != ""} {
         ts_log_fine "starting setfileperm.sh on fileserver $fileserver"
         set output [start_remote_prog $fileserver "root" "$ts_config(product_root)/util/setfileperm.sh" "-auto $ts_config(product_root)" prg_exit_state 120 0 $ts_config(product_root)]
         if {$prg_exit_state != 0} {
            ts_log_warning "setfileperm.sh on host $fileserver failed:\n$output"
         } else {
            ts_log_fine "done"
         }
      } else {
         # if we don't know the file server,
         # try to set the file permissions during installation on the master host
         set set_file_perm 1
      }
   }

   ts_log_finer "creating automatic install config file ..."
   set config_file "$ts_config(product_root)/autoinst_config_$ts_config(cell).conf"
   write_autoinst_config $config_file $ts_config(master_host) 1 1 0 $set_file_perm
   ts_log_finer "automatic install config file successfully created ..."
}
