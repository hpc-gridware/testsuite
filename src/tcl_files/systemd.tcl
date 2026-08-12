#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2025-2026 HPC-Gridware GmbH
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
# @brief Get all values of a multi-valued systemd unit property.
#
# `systemctl show --property=X` prints one "X=value" line per value for
# list-valued properties such as DeviceAllow. systemd_get_property() returns
# only the first line and is therefore unsuitable for those properties.
#
# @param host The host to query the systemd property from.
# @param scope The systemd unit to query (e.g., the job scope).
# @param property The property to retrieve (e.g., `DeviceAllow`).
# @returns A TCL list with one element per reported value (everything after
#          the first '='). An empty list if the property is unset, carries an
#          empty value, or the command failed.
#
# @note The order of the returned elements is NOT stable - systemd does not
#       preserve the order in which list-valued properties were set. Callers
#       must compare as a set (e.g. with lsearch), never by position.
# @note systemctl sometimes outputs Unicode or other non-ASCII characters,
#       so we use `iconv` to convert the output to ASCII.
proc systemd_get_property_list {host scope property} {
   set args "show --property $property $scope | iconv -f utf-8 -t ascii//TRANSLIT"
   ts_log_fine "systemctl $args"
   set output [start_remote_prog $host "root" "systemctl" $args]
   if {$prg_exit_state != 0} {
      ts_log_severe "systemctl $args failed:\n$output"
      return {}
   }

   # Pick only the "<property>=<value>" lines - this also skips any marker or
   # prompt lines start_remote_prog may add.
   set values {}
   foreach line [split $output "\n"] {
      set line [string trim $line]
      set pos [string first "=" $line]
      if {$pos < 0} {
         continue
      }
      if {[string range $line 0 [expr {$pos - 1}]] ne $property} {
         continue
      }
      set value [string range $line [expr {$pos + 1}] end]
      if {$value ne ""} {
         lappend values $value
      }
   }

   return $values
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
   global l10n_cache l10n_cache_loaded l10n_cache_new host_cgroup_version

   # Which cgroup version a host runs is a property of the machine, not of the
   # test: it cannot change while the testsuite is running. Determining it costs
   # up to two remote calls, and systemd_check_cleanup_job_slices asks for it once
   # per host after EVERY test -- eight remote calls per invocation on a six host
   # setup, for an answer that was already known.
   #
   # Only remembered across invocations when the cache was asked for; within one
   # invocation the answer is reused either way, which costs nothing and cannot
   # surprise anyone.
   if {[info exists host_cgroup_version($host)]} {
      return $host_cgroup_version($host)
   }
   if {[info exists l10n_cache] && $l10n_cache == 1 && ![info exists l10n_cache_loaded]} {
      l10n_cache_load
      if {[info exists host_cgroup_version($host)]} {
         return $host_cgroup_version($host)
      }
   }

   if {[remote_file_isdirectory $host "/sys/fs/cgroup/systemd"]} {
      set version 1
   } elseif {[remote_file_isdirectory $host "/sys/fs/cgroup/system.slice"]} {
      set version 2
   } else {
      ts_log_severe "cannot determine cgroup version for host $host: neither /sys/fs/cgroup/systemd nor /sys/fs/cgroup/systemd.slice exists"
      set version -1
   }

   # -1 means the host could not be classified; that is a finding, not a fact
   # worth keeping, so it is not remembered.
   if {$version > 0} {
      set host_cgroup_version($host) $version
      if {[info exists l10n_cache] && $l10n_cache == 1} {
         incr l10n_cache_new
         l10n_cache_save
      }
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
# @brief Get the cgroup path of the slice which holds the per job slices.
#
# The per job slices of tightly integrated parallel jobs are created below this
# directory, one per job, named `<slice_name>-jobs-<job_id>[.<task_id>].slice`.
#
# @param host The host to build the path for.
# @returns the path, or an empty string if the cgroup version cannot be determined.
#
proc systemd_get_job_slices_path {host} {
   set cgroup_version [systemd_get_cgroup_version $host]
   if {$cgroup_version < 0} {
      return ""
   }

   set slice_name [systemd_get_slice_name]
   if {$cgroup_version == 1} {
      # systemd v1
      set slice_path "/sys/fs/cgroup/systemd/${slice_name}.slice/${slice_name}-jobs.slice"
   } else {
      # systemd v2
      set slice_path "/sys/fs/cgroup/${slice_name}.slice/${slice_name}-jobs.slice"
   }

   return $slice_path
}

###
# @brief Get the per job systemd slices which currently exist on a host.
#
# Looks below the jobs slice of this cluster and returns the names of the slices
# found there. An empty result means that no job slice exists on the host, which
# is the expected state when no tightly integrated parallel job is running.
#
# @param host The host to look at.
# @returns list of slice names, e.g. `ocs8012-jobs-25.slice`.
#
proc systemd_get_job_slices {host} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set slice_path [systemd_get_job_slices_path $host]
   if {$slice_path == ""} {
      return {}
   }

   set slices {}
   if {[remote_file_isdirectory $host $slice_path]} {
      analyze_directory_structure $host $CHECK_USER $slice_path dirs "" ""

      set pattern "ocs$ts_config(commd_port)-jobs-"
      foreach dir $dirs {
         set pos [string first $pattern $dir]
         if {$pos >= 0} {
            lappend slices [string range $dir $pos end]
         }
      }
   }

   return $slices
}

###
# @brief The hosts which can have per job systemd slices.
#
# Job slices are created by the execution daemons, so only execd nodes running
# under systemd control are of interest.
#
# @param host_list Hosts to reduce to the ones with systemd, or an empty list for
#                  all execd nodes of the cluster.
# @returns list of hosts.
#
proc systemd_get_job_slice_hosts {{host_list {}}} {
   get_current_cluster_config_array ts_config

   if {[llength $host_list] == 0} {
      set host_list $ts_config(execd_nodes)
   }

   set hosts {}
   foreach host $host_list {
      if {[host_has_systemd $host]} {
         lappend hosts $host
      }
   }

   return $hosts
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
# This is the final verdict, called once a test has finished: a slice which is
# still there is a defect. A test which shuts an execd down while a tightly
# integrated parallel job is running has to call
# systemd_wait_for_end_of_all_job_slices() in its cleanup first - the slice is
# removed by the execd, and the execd needs a moment for it.
#
# @param host The host to check for leftover systemd job slices.
#
proc systemd_check_cleanup_job_slices {host} {
   set slice_path [systemd_get_job_slices_path $host]
   if {$slice_path == ""} {
      return 0
   }

   # expect everything to be fine
   set ret 1

   ts_log_fine "checking cleanup of systemd slice $slice_path on host $host"

   set left_slices [systemd_get_job_slices $host]
   set errors {}
   set statuses {}
   foreach slice $left_slices {
      ts_log_fine "   -> $slice"
      set output [start_remote_prog $host "root" "systemctl" "status $slice"]
      ts_log_fine $output
      lappend statuses $output
      set output [start_remote_prog $host "root" "systemctl" "stop $slice"]
      if {$prg_exit_state != 0} {
         lappend errors "$slice: $prg_exit_state: $output"
      }
      set ret 0
   }

   if {[llength $left_slices] > 0} {
      set msg "Found and removed leftover systemd job slices on host $host: [join $left_slices ", "]"
      append msg "\nStatus of each leftover slice:\n"
      foreach status $statuses {
         append msg "$status\n\n"
      }
      append msg "\nErrors during cleanup:\n"
      append msg [join $errors "\n"]
      ts_log_severe $msg
   } else {
      ts_log_fine "no leftover systemd job slices found on host $host"
   }

   return $ret
}

###
# @brief Wait until no per job systemd slice is left on the given hosts.
#
# The slice of a tightly integrated parallel job is removed by the execd once the
# job is finished. When a test shuts an execd down and starts it again, the execd
# only learns that the job has ended when it reconciles its jobs, which it does
# periodically - so the slice outlives the job by up to that interval. A test
# doing this has to wait for the slices to vanish in its cleanup function, before
# the framework does its final check with systemd_check_cleanup_job_slices().
#
# @param host_list Hosts to look at, or an empty list (default) for all execd
#                  nodes of the cluster.
# @param timeout   How long to wait in seconds, by default long enough for an
#                  execd which was started immediately before this call.
# @returns 1 if all job slices are gone, 0 if some remained (reported as error).
#
proc systemd_wait_for_end_of_all_job_slices {{host_list {}} {timeout 90}} {
   if {![ge_has_feature "systemd"]} {
      return 1
   }

   set hosts [systemd_get_job_slice_hosts $host_list]
   if {[llength $hosts] == 0} {
      return 1
   }

   ts_log_fine "waiting for systemd job slices to vanish on [join $hosts ", "], timeout ${timeout}s"

   set start_time [clock seconds]
   set end_time [expr $start_time + $timeout]
   while {1} {
      set left_slices {}
      foreach host $hosts {
         foreach slice [systemd_get_job_slices $host] {
            lappend left_slices "$host: $slice"
         }
      }

      set elapsed [expr [clock seconds] - $start_time]
      if {[llength $left_slices] == 0} {
         ts_log_fine "all systemd job slices are gone after ${elapsed}s"
         return 1
      }

      if {[clock seconds] >= $end_time} {
         set msg "systemd job slices still exist after ${elapsed}s:\n"
         append msg [join $left_slices "\n"]
         ts_log_severe $msg
         return 0
      }

      sleep_for_seconds 5 "waiting for systemd job slices to vanish: [join $left_slices ", "]"
   }
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

##
# @brief start a systemd service.
#
# This function starts a specific systemd service on the specified host.
# It uses the `systemctl start` command to start the service.
#
# @param host The host where the service should be started.
# @param service The name of the service to start, e.g., "ocs8012-qmaster.service"
# @returns 1 if the service was started successfully, 0 otherwise.
proc systemd_start_service {host service} {
   set ret 1
   set service_name [systemd_get_service_name $service]
   set output [start_remote_prog $host "root" "systemctl" "start $service_name"]
   if {$prg_exit_state != 0} {
      ts_log_severe "systemctl start $service_name on host $host failed:\n$output"
      set ret 0
   } else {
      ts_log_fine "systemctl start $service_name on host $host exited 0:\n$output"
   }

   return $ret
}

# @todo add functions for enable, disable, ...
