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

###
# @brief Get a property of a systemd unit.
#
# This function retrieves a specific property of a systemd unit by using the
# `systemctl show` command. It is useful for querying properties like
# `ActiveState`, `AllowedCPUs`, or any other property that can be queried from
# systemd.
#
# @param host The host to query the systemd property from.
# @param scope The systemd unit scope to query (e.g., the job scope).
# @param property The property to retrieve (e.g., `ActiveState`, `AllowedCPUs`).
# @returns The value of the specified property, or an empty string if the
#          property could not be retrieved or the command failed.
# @note systemctl sometimes outputs Unicode or other non-ASCII characters,
#       so we use `iconv` to convert the output to ASCII.
proc systemd_get_property {host scope property} {
   global CHECK_USER

   set args "show --property $property $scope | iconv -f utf-8 -t ascii//TRANSLIT"
   ts_log_fine "systemctl $args"
   set output [start_remote_prog $host "root" "systemctl" $args]
   if {$prg_exit_state != 0} {
      ts_log_severe "systemctl $args failed:\n$output"
      return ""
   }

   # we are only interested in the first line of the output
   set output [string trim [lindex [split $output "\n"] 0]]

   # we return the value after the first '='
   set pos [string first "=" $output]
   set value [string range $output [expr $pos + 1] end]

   return $value
}

###
# @brief Get the cgroup version used by systemd on a host.
#
# This function checks the cgroup structure on the host to determine whether
# it is using cgroup v1 or v2. It looks for the presence of specific directories
# in `/sys/fs/cgroup` to determine the version.
#
# @param host The host to check for the cgroup version.
# @returns 1 if cgroup v1 is used, 2 if cgroup v2 is used, -1 if the version cannot be determined.
proc systemd_get_cgroup_version {host} {
   if {[remote_file_isdirectory $host "/sys/fs/cgroup/systemd"]} {
      set version 1
   } elseif {[remote_file_isdirectory $host "/sys/fs/cgroup/system.slice"]} {
      set version 2
   } else {
      ts_log_severe "cannot determine cgroup version for host $host: neither /sys/fs/cgroup/systemd nor /sys/fs/cgroup/systemd.slice exists"
      set version -1
   }

   return $version
}

###
# @brief Get the name of the toplevel systemd slice for OCS jobs.
#
# Returns the default toplevel slice name used by testsuite: `ocs<commd_port>`.
#
proc systemd_get_slice_name {} {
   get_current_cluster_config_array ts_config
   return "ocs$ts_config(commd_port)"
}

###
# @brief Check and clean up leftover systemd job slices.
#
# This function checks for leftover systemd job slices on the specified host
# and attempts to clean them up by stopping the slices.
#
# It uses the `systemctl stop` command to stop any slices that match the
# pattern `ocs$ts_config(commd_port)-jobs-` (the default used by testsuite).
#
# @param host The host to check for leftover systemd job slices.
#
proc systemd_check_cleanup_job_slices {host} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set cgroup_version [systemd_get_cgroup_version $host]
   if {$cgroup_version < 0} {
      return 0
   }

   # expect everything to be fine
   set ret 1

   set slice_name [systemd_get_slice_name]
   if {$cgroup_version == 1} {
      # systemd v1
      set slice_path "/sys/fs/cgroup/systemd/${slice_name}.slice/${slice_name}-jobs.slice"
   } else {
      # systemd v2
      set slice_path "/sys/fs/cgroup/${slice_name}.slice/${slice_name}-jobs.slice"
   }

   ts_log_fine "checking cleanup of systemd slice $slice_path on host $host"

   set left_slices {}
   set errors {}
   if {[remote_file_isdirectory $host $slice_path]} {
      analyze_directory_structure $host $CHECK_USER $slice_path dirs "" ""
      #ts_log_fine $dirs

      set pattern "ocs$ts_config(commd_port)-jobs-"
      #ts_log_fine "looking for leftover systemd job slices with pattern: $pattern"
      foreach dir $dirs {
         set pos [string first $pattern $dir]
         if {$pos >= 0} {
            set slice [string range $dir $pos end]
            ts_log_fine "   -> $slice"
            lappend left_slices $slice
            set output [start_remote_prog $host "root" "systemctl" "stop $slice"]
            if {$prg_exit_state != 0} {
               lappend errors "$slice: $prg_exit_state: $output"
            }
            set ret 0
         }
      }
   }

   if {[llength $left_slices] > 0} {
      set msg "Found and removed leftover systemd job slices on host $host: [join $left_slices ", "]"
      append msg "\nErrors during cleanup:\n"
      append msg [join $errors "\n"]
      ts_log_severe $msg
   } else {
      ts_log_fine "no leftover systemd job slices found on host $host"
   }

   return $ret
}

###
# @brief Check if a systemd service is active.
#
# This function checks if a specific systemd service is currently active on the
# specified host. It uses the `systemctl is-active` command to determine the
# active state of the service.
#
# @param host The host to check the service on.
# @param service The name of the service to check, e.g., "ocs8012-qmaster.service"
# @returns 1 if the service is active, 0 otherwise.
proc systemd_is_service_active {host service} {
   set service_name [systemd_get_service_name $service]
   set ret 0
   set output [start_remote_prog $host "root" "systemctl" "is-active $service_name"]
   if {$prg_exit_state == 0} {
      set ret 1
   }

   return $ret
}

# @todo add functions for is-enabled, ...

###
# @brief stop a systemd service.
#
# This function stops a specific systemd service on the specified host.
# It uses the `systemctl stop` command to stop the service.
#
# @param host The host where the service should be stopped.
# @param service The name of the service to stop, e.g., "ocs8012-qmaster.service"
# @param raise_error If set to 1 (default), raises an error if the stop command fails.
# @returns 1 if the service was stopped successfully, 0 otherwise.
proc systemd_stop_service {host service {raise_error 1}} {
   set ret 1
   set service_name [systemd_get_service_name $service]
   set output [start_remote_prog $host "root" "systemctl" "stop $service_name"]
   if {$prg_exit_state != 0} {
      ts_log_severe "systemctl stop $service_name on host $host failed:\n$output"
      set ret 0
   } else {
      ts_log_fine "systemctl stop $service_name on host $host exited 0:\n$output"
   }

   return $ret
}

# @todo add functions for start, enable, disable, ...
