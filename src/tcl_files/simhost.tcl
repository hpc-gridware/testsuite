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

###
# @brief initialize the simhost framework
#
# The simhost framework provides a way to easily make use the SIMULATE_EXECDS
# test facility available in Cluster Scheduler.
#
# It expects simulated hosts to be available in the host database on the qmaster host.
# Simulated hosts need to be named "sim-eh-ipa-ipb-ipc-ipd", e.g. "sim-eh-10.1.1.240".
# getent hosts on the qmaster host needs to report them.
#
# Creating a hosts database (for /etc/hosts and/or NIS hosts table based on /etc/hosts)
# can be done by calling testsuite/src/scripts/sim_eh.sh
#
# The simhost framework needs to be initialized once by calling simhost_init.
# Initialization can be done per testsuite test, subsequent calls will just output some
# information about the number of available and used hosts.
#
# @return 1 on success, 0 on failure and a ts_log_config explains why
##
global simhost_cache
set simhost_cache(free_hosts) {}
set simhost_cache(used_hosts) {}
proc simhost_init {} {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   global simhost_cache

   set num_hosts_free [llength $simhost_cache(free_hosts)]
   set num_hosts_used [llength $simhost_cache(used_hosts)]
   if {$num_hosts_free > 0 || $num_hosts_used > 0} {
      ts_log_fine "simhost_init was already called: We have $num_hosts_free free and $num_hosts_used used hosts"
      return 1
   }

   # try to find simulated hosts
   set cmd [get_binary_path $ts_config(master_host) "getent"]
   if {$cmd == "getent"} {
      ts_log_config "cannot initialize simhost: There is no getent command in PATH on $ts_config(master_host)"
      return 0
   }
   set args "hosts | awk '{print \$2}' | grep '^sim-eh-'"
   set output [start_remote_prog $ts_config(master_host) $CHECK_USER $cmd $args]
   if {$prg_exit_state != 0} {
      ts_log_config "cannot initialize simhost: getent failed:\n$output"
      return 0
   }

   # now we should have a list of sim-eh-* hosts
   set num_hosts 0
   #set hosts {}
   foreach host [split [string trim $output] "\n"] {
      #ts_log_fine $host  
      lappend hosts [string trim $host]
      #incr num_hosts
      #if {$num_hosts > 10} {
      #   break
      #}
   }
   #ts_log_fine $hosts
   set simhost_cache(free_hosts) [lsort -dictionary -unique $hosts]
   #ts_log_fine $simhost_cache(free_hosts)
   set num_hosts_free [llength $simhost_cache(free_hosts)]
   ts_log_fine "found $num_hosts_free host names for simulation"

   if {$num_hosts_free == 0} {
      ts_log_config "no simhosts found in $output"
      return 0
   }

   return 1
}

###
# @brief add simulated hosts
#
# A given number of simulated hosts are added as execution hosts.
# Optionally the hosts can be added into a new host group.
#
# ATTENTION
# If necessary host simulation is switched on by adding SIMULATE_EXECDS to the global config/qmaster_params.
# If not yet exists a complex variable "load_report_host" is created.
# It is in the reponsibility of the caller to backup global config and complex before calling simhost_add
# (e.g. in the setup_function) and to restore them after deleting the simulated hosts again!
# If a host group got created this also has to be deleted by the caller!
#
# @param[in] num_hosts
# @param[in] host_group, if != "" the host group will be created and holds the newly created simulated hosts
# @returns a list of hostnames or "" in case of error
##
proc simhost_add {num_hosts {host_group ""}} {
   get_current_cluster_config_array ts_config
   global simhost_cache
 
   set num_hosts_free [llength $simhost_cache(free_hosts)]
   if {$num_hosts_free < $num_hosts} {
      ts_log_config "cannot add $num_hosts simulated hosts: We only have $num_hosts_free available"
      return {}
   }

   # do we have to enable the use of simulated hosts or has it already been done?
   get_config global_config
   if {[string first "SIMULATE_EXECDS" $global_config(qmaster_params)] < 0} {
      ts_log_fine "need to enable SIMULATE_EXECDS"
      set gc(qmaster_params) "$global_config(qmaster_params) SIMULATE_EXECDS=TRUE"
      set_config gc
   }

   # need a complex variable "load_report_host"
   get_complex complex
   if {![info exists complex(load_report_host)]} {
      ts_log_fine "need to create complex variable load_report_host"
      set cplx(load_report_host) "lrh STRING == YES NO NONE 0"
      set_complex cplx
   }

   if {$host_group != ""} {
      ts_log_fine "adding $num_hosts hosts"
   } else {
      ts_log_fine "adding $num_hosts hosts to host group $host_group"
   }
   set num_real_hosts [llength $ts_config(execd_nodes)]
   set added_hosts {}
   for {set i 0} {$i < $num_hosts} {incr i} {
      # get the next free host
      set host [lindex $simhost_cache(free_hosts) 0]
      set simhost_cache(free_hosts) [lrange $simhost_cache(free_hosts) 1 end]
      set eh(hostname) $host

      # get its load_report_host
      set load_report_host [lindex $ts_config(execd_nodes) [expr $i % $num_real_hosts]]
      set eh(complex_values) "load_report_host=$load_report_host"
      add_exechost eh
      # add_exechost doesn't return if it succeeded or not, just assume it did succeed
      lappend added_hosts $host
      lappend simhost_cache(used_hosts) $host
   }

   # create a new host group with these hosts
   if {$host_group != ""} {
      set ret [get_hostgroup $host_group result "" "" 0]

      set hg(hostlist) $added_hosts
      if {$ret == 0} {
         ts_log_fine "adding host to host group $host_group"
         mod_hostgroup $host_group hg
      } else {
         ts_log_fine "creating host group $host_group"
         add_hostgroup $host_group hg
      }
   }

   return $added_hosts
}

###
# @brief delete simulated hosts
#
# Deletes the simulated execution hosts and returns them into the pool of all available simhosts.
#
# @param[in] a list of hosts to delete
##
proc simhost_delete {hosts} {
   get_current_cluster_config_array ts_config
   global simhost_cache

   set cmd "qconf"
   set args "-de "
   append args [join $hosts ","]
   set output [start_sge_bin $cmd $args]
   if {$prg_exit_state != 0} {
      ts_log_severe "deleting hosts (qconf -de) failed $prg_exit_state:\n$output"
   } else {
      set simhost_cache(free_hosts) [lsort -dictionary -unique [concat $simhost_cache(free_hosts) $hosts]]
      foreach host $hosts {
         set pos [lsearch -exact $simhost_cache(used_hosts) $host]
         if {$pos >= 0} {
            set simhost_cache(used_hosts) [lreplace $simhost_cache(used_hosts) $pos $pos]
         }
      }
   }
}
