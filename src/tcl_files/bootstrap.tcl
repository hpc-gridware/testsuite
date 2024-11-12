#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2024 HPC-Gridware GmbH
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#___INFO__MARK_END_NEW__

proc bootstrap_from_cluster {bootstrap_template} {
   global CHECK_DEFAULTS_FILE

   puts "bootstrapping testsuite config from existing cluster"

   set ret 1

   # the config file may not yet exist
   if {$ret && [file exists $CHECK_DEFAULTS_FILE]} {
      puts "ERROR: Configuration file $CHECK_DEFAULTS_FILE does already exist."
      set ret 0
   }

   # the template file must exist
   if {![file exists $bootstrap_template]} {
      puts "ERROR: Bootstrap template file $bootstrap_template does not exist."
      set ret 0
   }

   # read the template file
   if {$ret && ![bootstrap_read_template $bootstrap_template bootstrap]} {
      set ret 0
   }

   # need to create the following config files
   # - host_config_file
   # - user_config_file
   # - fs_config_file
   if {$ret && ![bootstrap_create_config_files bootstrap]} {
      set ret 0
   }

   return $ret
}

proc bootstrap_read_template {bootstrap_template bootstrap_var} {
   upvar $bootstrap_var bootstrap

   puts "\t- reading bootstrap template file $bootstrap_template"

   set ret 1

   # read the file to an array
   set bootstrap_text [exec cat $bootstrap_template]
   parse_simple_record bootstrap_text bootstrap 1

   # check required attributes
   set required_attributes {connection_type product_root cell}
   foreach attr $required_attributes {
      if {![info exists bootstrap($attr)]} {
         puts "ERROR: Attribute $attr is missing in bootstrap template."
         set ret 0
         break
      }
   }

   # basic check of the cluster
   if {$ret && ![file exists $bootstrap(product_root)]} {
      puts "ERROR: Cluster root directory $bootstrap(product_root) does not exist."
      set ret 0
   }
   set cell_dir [file join $bootstrap(product_root) $bootstrap(cell)]
   if {$ret && ![file exists $cell_dir]} {
      puts "ERROR: Cell directory $cell_dir does not exist."
      set ret 0
   }
   set common_dir [file join $cell_dir common]
   if {$ret && ![file exists $common_dir]} {
      puts "ERROR: Common directory $common_dir does not exist."
      set ret 0
   }
   set act_qmaster [file join $common_dir act_qmaster]
   if {$ret && ![file exists $act_qmaster]} {
      puts "ERROR: act_qmaster file $act_qmaster does not exist."
      set ret 0
   }

   return $ret
}

proc bootstrap_create_config_files {bootstrap_var} {
   global CHECK_DEFAULTS_FILE

   upvar $bootstrap_var bootstrap

   set ret 1

   set base_dir [file dirname $CHECK_DEFAULTS_FILE]
   set localhost [get_local_hostname]
   set gridengine_version [bootstrap_get_gridengine_version bootstrap]

   if {$ret && ![bootstrap_create_host_config_file $gridengine_version bootstrap $localhost $base_dir]} {
      set ret 0
   }
   if {$ret && ![bootstrap_create_user_config_file $gridengine_version bootstrap $base_dir]} {
      set ret 0
   }
   if {$ret && ![bootstrap_create_testsuite_info_file $gridengine_version $base_dir]} {
      set ret 0
   }
   if {$ret && ![bootstrap_create_config_file $gridengine_version bootstrap $base_dir]} {
      set ret 0
   }
   if {$ret && ![bootstrap_add_hosts_to_host_config_file $gridengine_version bootstrap $base_dir]} {
      set ret 0
   }
   if {$ret && ![bootstrap_create_fs_config_file $gridengine_version bootstrap $base_dir]} {
      set ret 0
   }

   return $ret
}


proc bootstrap_get_gridengine_version {bootstrap_var} {
   upvar $bootstrap_var bootstrap

   set output [bootstrap_exec bootstrap "qconf" "-help"]
   set version_line [string trim [lindex [split $output "\n"] 0]]
   set version [lindex [split $version_line " "] 1]
   set split_version [split $version "."]
   set ret "[lindex $split_version 0][lindex $split_version 1]"

   return $ret
}

proc bootstrap_create_host_config_file {gridengine_version bootstrap_var localhost basedir} {
   global ts_host_config
   global CHECK_DEFAULTS_FILE
   upvar $bootstrap_var bootstrap

   puts "\t- creating host config file"

   set ret 1

   set ts_host_config(NFS-ROOT2NOBODY) $bootstrap(NFS-ROOT2NOBODY)
   set ts_host_config(NFS-ROOT2ROOT) $bootstrap(NFS-ROOT2ROOT)

   host_conf_get_host_defaults host_config
   set host_config(host) $localhost
   set host_config(arch,$gridengine_version) [string trim [exec "$bootstrap(product_root)/util/arch"]]
   # lets assume that we can compile on the testsuite host
   set host_config(compile,$gridengine_version) 1
   set host_config(java_compile,$gridengine_version) 1
   set host_config(doc_compile,$gridengine_version) 1
   # @todo the host template has reasonable defaults for expect, vim, tar, ...
   #       (/usr/bin) - to be 100% sure we would have to call which <bin> for every
   #       binary on every host - this would take by far too long
   set ret [host_conf_add_host_from_template host_config]

   spool_array_to_file "$basedir/testsuite_host.conf" "testsuite host configuration" ts_host_config
   return $ret
}

proc bootstrap_add_hosts_to_host_config_file {gridengine_version bootstrap_var basedir} {
   global ts_config
   global ts_host_config
   upvar $bootstrap_var bootstrap

   puts "\t- adding cluster hosts to host config file"

   set ret 1

   # get unique list of all hosts
   set host_list [concat $ts_config(master_host) $ts_config(shadowd_hosts) $ts_config(execd_hosts) $ts_config(submit_only_hosts) $ts_config(admin_only_hosts)]
   set host_list [lsort -unique $host_list]
   set localhost [get_local_hostname]
   # we already have the local host in the host config file
   set archs $ts_host_config($localhost,arch,$gridengine_version)
   foreach host $host_list {
      # there might be an entry "none", e.g. if there are no submit_only_hosts
      if {$host == "none"} {
         continue
      }
      # testsuite uses short host names in the configuration
      set host [bootstrap_get_short_hostname $host bootstrap]

      # we need to skip the local host - it is already in the host config file
      if {$host == $localhost} {
         continue
      }
      puts "\t\t+$host"
      unset -nocomplain host_config
      host_conf_get_host_defaults host_config
      set host_config(host) $host
      set arch [string trim [exec ssh $host $ts_config(product_root)/util/arch]]
      set host_config(arch,$gridengine_version) $arch
      # we set the first host we find for a specific arch as compile host
      # just to please testsuite - we will not compile for now
      if {[lsearch -exact $archs $arch] < 0} {
         lappend archs $arch
         set host_config(compile,$gridengine_version) 1
      }

      set host_config(spooldir) $bootstrap(spooldir)

      set ret [host_conf_add_host_from_template host_config]
      if {!$ret} {
         break
      }
   }

   spool_array_to_file "$basedir/testsuite_host.conf" "testsuite host configuration" ts_host_config
   return $ret
}

proc bootstrap_create_user_config_file {gridengine_version bootstrap_var basedir} {
   global ts_user_config
   global CHECK_USER CHECK_DEFAULTS_FILE
   upvar $bootstrap_var bootstrap

   puts "\t- creating user config file"

   set ret 1

   set ts_user_config(first_foreign_user) [lindex $bootstrap(test-user-1) 0]
   set ts_user_config(second_foreign_user) [lindex $bootstrap(test-user-2) 0]
   set ts_user_config(first_foreign_group) [lrange $bootstrap(test-user-1) 1 end]
   set ts_user_config(second_foreign_group) [lrange $bootstrap(test-user-2) 1 end]
   set ts_user_config(userlist) $CHECK_USER
   set ts_user_config($CHECK_USER,envlist) ""
   set ts_user_config($CHECK_USER,portlist) "800"
   set qmaster_port [bootstrap_exec bootstrap "echo" "\$SGE_QMASTER_PORT"]
   lappend ts_user_config($CHECK_USER,portlist) $qmaster_port
   set output [bootstrap_exec bootstrap "qconf" "-sconf"]
   parse_simple_record output global_config 1
   set ts_user_config(800) $CHECK_USER
   set ts_user_config(800,$CHECK_USER) "1-2"
   set ts_user_config($qmaster_port) $CHECK_USER
   set ts_user_config($qmaster_port,$CHECK_USER) $global_config(gid_range)

   spool_array_to_file "$basedir/testsuite_user.conf" "testsuite user configuration" ts_user_config

   return $ret
}

proc bootstrap_create_fs_config_file {gridengine_version bootstrap_var basedir} {
   global ts_fs_config ts_config
   upvar $bootstrap_var bootstrap

   puts "\t- creating filesystem config file"

   set ret 1

   # try to figure out the mounted file systems on the master host
   set host $ts_config(master_host)
   set ts_fs_config(fsname_list) {}
   set output [exec "ssh" $host "mount" "-v"]
   foreach line [split $output "\n"] {
      # we are interested in the nfs (nfs or nfs4) mounted file systems
      if {[string first "type nfs" $line] < 0} {
         continue
      }
      set split_line [split [string trim $line]]
      set fsname [lindex $split_line 2]
      if {[lsearch -exact $ts_fs_config(fsname_list) $fsname] < 0} {
         lappend ts_fs_config(fsname_list) $fsname
         set server_entry [split [lindex $split_line 0] ":"]
         set ts_fs_config($fsname,fsserver) [bootstrap_get_short_hostname [lindex $server_entry 0] bootstrap]
         # @todo need to figure out the following 2 parameters in case we want to do full testsuite runs
         set ts_fs_config($fsname,fssulogin) "y"
         set ts_fs_config($fsname,fssuwrite) "y"
         set ts_fs_config($fsname,fstype) [lindex $split_line 4]
      }
   }

   spool_array_to_file "$basedir/testsuite_fs.conf" "testsuite filesystem configuration" ts_fs_config

   return $ret
}

proc bootstrap_get_short_hostname {host bootstrap_var} {
   upvar $bootstrap_var bootstrap

   # strip domain
   set short_host [lindex [split $host "."] 0]

   # if we got an ip address (e.g. from mount) try to resolve it
   if {[string is integer $short_host]} {
      set arch [string trim [exec $bootstrap(product_root)/util/arch]]
      set bin "$bootstrap(product_root)/utilbin/$arch/gethostbyaddr"
      set host [exec $bin "-name" $host]
      set short_host [lindex [split $host "."] 0]
   }

   return $short_host
}

proc bootstrap_create_testsuite_info_file {gridengine_version basedir} {
   set ret 1

   puts "\t- creating testsuite info file"

   exec mkdir "$basedir/source_code_macros"
   exec touch "$basedir/testsuite.info"

   return $ret
}

proc bootstrap_create_config_file {gridengine_version bootstrap_var basedir} {
   global ts_config
   global CHECK_DEFAULTS_FILE
   upvar $bootstrap_var bootstrap

   puts "\t- creating testsuite config file"

   set ret 1

   set working_dir [pwd]
   set config_dir [file dirname $CHECK_DEFAULTS_FILE]
   set config_name [file tail $CHECK_DEFAULTS_FILE]

   set cs_bootstrap_text [exec cat $bootstrap(product_root)/$bootstrap(cell)/common/bootstrap]
   parse_simple_record cs_bootstrap_text cs_bootstrap 1

   set ts_config(gridengine_version) $gridengine_version
   set ts_config(testsuite_root_dir) $working_dir
   set ts_config(checktree_root_dir) "$working_dir/checktree"
   set ts_config(additional_checktree_dirs) "none"
   set ts_config(results_dir) "$working_dir/RESULTS/[file rootname $config_name]"
   set ts_config(connection_type) $bootstrap(connection_type)
   if {[info exists bootstrap(source_dir)]} {
      set ts_config(source_dir) $bootstrap(source_dir)
   } else {
      set ts_config(source_dir) "none"
   }
   if {[info exists bootstrap(uge_ext_dir)]} {
      set ts_config(uge_ext_dir) $bootstrap(uge_ext_dir)
   } else {
      set ts_config(uge_ext_dir) "none"
   }
   set ts_config(host_config_file) "$config_dir/testsuite_host.conf"
   set ts_config(user_config_file) "$config_dir/testsuite_user.conf"
   set ts_config(fs_config_file) "$config_dir/testsuite_fs.conf"
   set ts_config(ge_packages_uri) "file://$config_dir"
   set ts_config(db_config_file) "none"
   set ts_config(additional_config) "none"
   set ts_config(master_host) [bootstrap_get_master_host bootstrap]
   set ts_config(shadowd_hosts) [bootstrap_get_shadowd_hosts bootstrap]
   set ts_config(execd_hosts) [bootstrap_get_execd_hosts bootstrap]
   set ts_config(submit_only_hosts) [bootstrap_get_submit_only_hosts bootstrap]
   set ts_config(admin_only_hosts) [bootstrap_get_admin_only_hosts bootstrap]
   set ts_config(non_cluster_hosts) "none"
   set ts_config(add_compile_archs) "none"
   set ts_config(commd_port) [bootstrap_exec bootstrap "echo" "\$SGE_QMASTER_PORT"]
   set ts_config(reserved_port) "800"
   set ts_config(product_root) $bootstrap(product_root)
   set ts_config(product_type) "sgeee"
   set ts_config(product_feature) "none"
   set ts_config(cell) $bootstrap(cell)
   set ts_config(cluster_name) [string trim [exec cat $bootstrap(product_root)/$bootstrap(cell)/common/cluster_name]]
   set ts_config(spooling_method) $cs_bootstrap(spooling_method)
   set ts_config(bdb_dir) [bootstrap_get_spooldir cs_bootstrap]
   set ts_config(l10n_test_locale) "none"
   set ts_config(aimk_compile_options) "none"
   set ts_config(dist_install_options) "none"
   set ts_config(qmaster_install_options) "none"
   set ts_config(execd_install_options) "none"
   set ts_config(package_directory) "none"
   set ts_config(package_type) "tar"
   set ts_config(package_release) "unknown"
   set ts_config(dns_domain) [string trim [exec hostname -d]]
   if {$ts_config(dns_domain) == ""} {
      # @todo make it configurable (optionally)?
      set ts_config(dns_domain) "fritz.box"
   }
   set ts_config(dns_for_install_script) "none"
   set ts_config(mail_application) "mailx"
   if {[info exists bootstrap(mailx_host)]} {
      set ts_config(mailx_host) $bootstrap(mailx_host)
   } else {
      set ts_config(mailx_host) "none"
   }
   if {[info exists bootstrap(report_mail_to)]} {
      set ts_config(report_mail_to) $bootstrap(report_mail_to)
   } else {
      set ts_config(report_mail_to) "none"
   }
   if {[info exists bootstrap(report_mail_cc)]} {
      set ts_config(report_mail_cc) $bootstrap(report_mail_cc)
   } else {
      set ts_config(report_mail_cc) "none"
   }
   set ts_config(enable_error_mails) "500"

   spool_array_to_file $CHECK_DEFAULTS_FILE "testsuite configuration" ts_config

   return $ret
}

proc bootstrap_get_spooldir {cs_bootstrap_var} {
   upvar $cs_bootstrap_var cs_bootstrap

   set ret "none"
   if {$cs_bootstrap(spooling_method) == "berkeleydb"} {
      set ret $cs_bootstrap(spooling_params)
   }

   return $ret
}

proc bootstrap_exec {bootstrap_var args} {
   upvar $bootstrap_var bootstrap

   set script "scripts/bootstrap_exec.sh"
   set sge_root $bootstrap(product_root)
   set cell $bootstrap(cell)
   set ret [string trim [eval exec $script $sge_root $cell $args]]

   return $ret
}

proc bootstrap_get_master_host {bootstrap_var} {
   upvar $bootstrap_var bootstrap

   set ret [bootstrap_get_short_hostname [string trim [exec cat $bootstrap(product_root)/$bootstrap(cell)/common/act_qmaster]] bootstrap]

   return $ret
}

proc bootstrap_get_shadowd_hosts {bootstrap_var} {
   upvar $bootstrap_var bootstrap

   set output [string trim [exec cat $bootstrap(product_root)/$bootstrap(cell)/common/shadow_masters]]
   set ret {}
   foreach host [split $output "\n"] {
      lappend ret [bootstrap_get_short_hostname $host bootstrap]
   }

   return $ret
}

proc bootstrap_get_execd_hosts {bootstrap_var} {
   upvar $bootstrap_var bootstrap

   set output [bootstrap_exec bootstrap "qconf" "-sel"]
   set ret {}
   foreach host [split $output "\n"] {
      lappend ret [bootstrap_get_short_hostname $host bootstrap]
   }

   return $ret
}

proc bootstrap_get_submit_only_hosts {bootstrap_var} {
   global ts_config
   upvar $bootstrap_var bootstrap

   set output [bootstrap_exec bootstrap "qconf" "-ss"]
   set ret {}
   foreach host [split $output "\n"] {
      set host [bootstrap_get_short_hostname $host bootstrap]
      if {[lsearch -exact $ts_config(execd_hosts) $host] < 0} {
         lappend ret $host
      }
   }

   if {$ret == {}} {
      set ret "none"
   }

   return $ret
}

proc bootstrap_get_admin_only_hosts {bootstrap_var} {
   global ts_config
   upvar $bootstrap_var bootstrap

   set output [bootstrap_exec bootstrap "qconf" "-sh"]
   set ret {}
   foreach host [split $output "\n"] {
      set host [bootstrap_get_short_hostname $host bootstrap]
      if {[lsearch -exact $ts_config(execd_hosts) $host] < 0} {
         lappend ret $host
      }
   }

   if {$ret == {}} {
      set ret "none"
   }

   return $ret
}
