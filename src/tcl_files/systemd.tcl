#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2025 HPC-Gridware GmbH
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
# @brief is host using systemd as init system?
#
# @param[in] host - the host to check
# @returns 1 if systemd is used, 0 otherwise
#
proc host_has_systemd {host} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set has_systemd 0
   set arch [resolve_arch $host]
   if {[string match "lx-*" $arch]} {
      set output [start_remote_prog $host $CHECK_USER "ps" "-p 1 -o comm=" prg_exit_state 60 0 "" "" 1 0]
      if {[string trim $output] == "systemd"} {
         set has_systemd 1
      }
   }

   return $has_systemd
}

###
# @brief get hosts having systemd
#
# Returns a list of hosts from the list of execd nodes which have systemd running.
#
# @param num_hosts Number of hosts to return, defaults to 1.
# @returns A list of hosts that have systemd running.
#
# @note We might want to add parameters to filter for specific systemd versions or configurations in the future.
#
proc systemd_get_suited_hosts {{num_hosts 1}} {
   get_current_cluster_config_array ts_config

   # gather systemd hosts until we have enough or run out of execd nodes
   set systemd_hosts {}
   foreach host $ts_config(execd_nodes) {
      if {[host_has_systemd $host]} {
         lappend systemd_hosts $host
         if {[llength $systemd_hosts] >= $num_hosts} {
            break
         }
      }
   }

   # if we didn't find enough hosts, return an empty list
   if {[llength $systemd_hosts] < $num_hosts} {
      set systemd_hosts {}
   }

   return $systemd_hosts
}

###
# @brief Get non-systemd hosts.
#
# Returns a list of hosts from the list of execd nodes which do not have systemd running.
#
# @param num_hosts Number of hosts to return, defaults to 1.
# @returns A list of hosts that do not have systemd running.
#
proc systemd_get_non_systemd_hosts {{num_hosts 1}} {
   get_current_cluster_config_array ts_config

   # gather non-systemd hosts until we have enough or run out of execd nodes
   set non_systemd_hosts {}
   foreach host $ts_config(execd_nodes) {
      if {![host_has_systemd $host]} {
         lappend non_systemd_hosts $host
         if {[llength $non_systemd_hosts] >= $num_hosts} {
            break
         }
      }
   }

   # if we didn't find enough hosts, return an empty list
   if {[llength $non_systemd_hosts] < $num_hosts} {
      set non_systemd_hosts {}
   }

   return $non_systemd_hosts
}

###
# @brief Get the systemd job scope for a given job ID, task ID, and optional pe_task_id.
#
# Builds the systemd scope unit name for a job based on the provided job ID,
# optional array task ID, and optional parallel task ID.
# The scope is built analogous to the ocs::Job::job_get_systemd_slice_and_scope() method
# in the C++ code.
#
# @param job_id The ID of the job.
# @param task_id The ID of the array task (default is 0 = sequential job).
# @param pe_task_id The ID of the parallel task (default is an empty string = no pe task).
# @returns The systemd job scope as a string.
#
proc systemd_get_job_scope {job_id {task_id 0} {pe_task_id ""}} {
   get_current_cluster_config_array ts_config

   # base
   set scope "ocs$ts_config(commd_port)."
   # add job id
   append scope $job_id

   if {$task_id != 0} {
      # add task id if given
      append scope ".$task_id"
   }

   if {$pe_task_id ne ""} {
      # add pe task id if given
      append scope ".$pe_task_id"
   }

   append scope ".scope"

   ts_log_fine "Job scope for job $job_id (task $task_id, pe_task $pe_task_id) is: $scope"

   return $scope
}

###
# @brief Check if a job is active in systemd.
#
# This function checks if a job is currently active in systemd by querying the
# systemd status of the job's scope.
#
# @param host The host to check the job on.
# @param job_id The ID of the job to check.
# @param task_id The ID of the array task (default is 0 = sequential job).
# @param pe_task_id The ID of the parallel task (default is an empty string = no pe task).
# @returns 1 if the job is active in systemd, 0 otherwise.
#
proc systemd_is_job_active {host job_id {task_id 0} {pe_task_id ""}} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set ret 0

   # get the job scope
   set scope [systemd_get_job_scope $job_id $task_id $pe_task_id]

   # check if the job is active in systemd
   set output [start_remote_prog $host $CHECK_USER "systemctl" "is-active $scope" prg_exit_state 60 0 "" "" 1 0]
   if {[string trim $output] eq "active"} {
      set ret 1
   }

   return $ret
}
