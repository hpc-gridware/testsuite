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


## @brief Get load values from qstat -F output
#
# The array is filled with the following structure:
#   array_name(hosts) = list
#   array_name(hostname,complex_name) = value
# where list is a space-separated list of all hostnames found
#
# @param array_name Name of the array to store the results in
# @param complex_name_list List of complex names to fetch
#
proc get_load_values {array_name complex_name_list} {
   upvar $array_name host_array

   # we fetch the following load values via qstat -F
   qstat_F_plain_parse output $complex_name_list

   # move found items to the output array
   set host_array(hosts) {}
   foreach queue $output(queue_list) {
      set hostname [resolve_host [lindex [split $queue "@"] 1]]
      if {[lsearch -exact $host_array(hosts) $hostname] == -1} {
         lappend host_array(hosts) $hostname
         foreach complex_name $complex_name_list {
            if {[info exists output($queue,hl:$complex_name)]} {
               set host_array($hostname,$complex_name) $output($queue,hl:$complex_name)
            }
         }
      }
   }
}


## @brief Validate a topology string
#
# A valid topology string is either "NONE" or a combination of the
# characters N, X, Y, S, C, E, T.
#
# @param topology_string The topology string to validate
# @return 1 if valid, 0 if invalid
#
proc topology_is_valid {topology_string} {
   # Empty string is invalid
   if {[string length $topology_string] == 0} {
      return 0
   }

   # Allow NONE
   if {[string equal -nocase $topology_string "NONE"]} {
      return 1
   }

   # Allow any combination of N, X, Y, S, C, E, T
   if {[regexp {[NXYSCET]+} $topology_string]} {
      return 1
   }

   # Every thing else is invalid
   return 0
}

## @brief Compare the structure of two topology strings
#
# The structure is the sequence of characters in the string, ignoring case.
# The strings must be of the same length and have the same characters in the
# same order.
#
# @param topo1 First topology string
# @param topo2 Second topology string
# @return 1 if the structures are the same, 0 otherwise
#
proc topology_is_same_structure {topo1 topo2} {
   set len1 [string length $topo1]
   set len2 [string length $topo2]

   # Lengths must be the same
   if {$len1 != $len2} {
      return 0
   }

   # Convert to upper case
   set topo1 [string toupper $topo1]
   set topo2 [string toupper $topo2]

   # Compare character by character
   for {set i 0} {$i < $len1} {incr i} {
      set char1 [string index $topo1 $i]
      set char2 [string index $topo2 $i]

      if {$char1 != $char2} {
         return 0
      }
   }

   return 1
}

## @brief Count the number of cores in a topology string
#
# Cores are represented by the characters C, c, E, e
#
# @param topology_string The topology string to analyze
# @return The number of cores found
#
proc host_topology_count_cores {topology_string} {
   set count 0
   foreach char [split $topology_string ""] {
      if {$char == "C" || $char == "c" || $char == "E" || $char == "e"} {
         incr count
      }
   }
   return $count
}

## @brief Count the number of sockets in a topology string
#
# Sockets are represented by the characters S, s
#
# @param topology_string The topology string to analyze
# @return The number of sockets found
#
proc host_topology_count_sockets {topology_string} {
   set count 0
   foreach char [split $topology_string ""] {
      if {$char == "S" || $char == "s"} {
         incr count
      }
   }
   return $count
}

## @brief Get the active binding of a job
#
# The array is filled with the following structure:
#
#   array_name(hostname) = topology_string
#
# where hostname is the name of the host the job was bound to and
# topology_string is the binding topology string.
#
# @param job_id The job ID to query
# @param array_name Name of the array to store the results in
#
proc job_get_binding_active {job_id array_name} {
   upvar $array_name bindings

   set result [get_qstat_j_info $job_id qstat_j_info]
   set idx [get_qstat_j_attribute "exec_binding_list" 1]
   set binding_list $qstat_j_info($idx)

   # early exit if nothing was bound
   if {$binding_list eq "NONE"} {
      return
   }


   # e.g. v01701.fritz.box=SCC,v01702.fritz.box=SCC
   foreach binding [split $binding_list ","] {
      if {[regexp {([a-zA-Z0-9.]+)=([a-zA-Z]+)} $binding all hostname topology_string]} {
         set hostname [get_short_hostname $hostname]
         set bindings($hostname) $topology_string
      }
   }
   return
}

## @brief Get the binding request of a job
#
# The array is filled with the following structure:
#
#   array_name(key) = value
#
# where key is the name of the binding attribute (e.g. bunit, bamount
# etc.) and value is the requested value.
#
# @param job_id The job ID to query
# @param array_name Name of the array to store the results in
#
proc job_get_binding_request {job_id array_name} {
   upvar $array_name bindings

   set result [get_qstat_j_info $job_id qstat_j_info]
   set binding_list $qstat_j_info(binding)

   # early exit if nothing was bound
   if {$binding_list eq "NONE"} {
      return
   }

   # e.g. bunit=C,bamount=1,...
   foreach binding [split $binding_list ","] {
      if {[regexp {([a-zA-Z0-9.]+)=([a-zA-Z0-9.]+)} $binding all key value]} {
         set bindings($key) $value
      }
   }
   return
}


## @brief Get the topology of a host
#
# The topology is fetched from the m_topology complex attribute of the host.
#
# @param hostname The hostname to query
# @return The topology string or "NONE" if not found
#
proc host_get_topology {hostname} {
   array set host_array {}
   get_load_values host_array {m_topology}

   set hostname [get_short_hostname $hostname]
   if {[info exists host_array($hostname,m_topology)]} {
      return $host_array($hostname,m_topology)
   }
   return "NONE"
}

## @brief Get the topology in use of a host
#
# The topology is fetched from the m_topology complex attribute of the host.
# This is the topology that is actually used by the host
#
# @param hostname The hostname to query
# @return The topology string or "NONE" if not found
#
proc host_get_topology_in_use {hostname} {
   array set host_array {}
   get_load_values host_array {m_topology, m_topology_in_use}

   set hostname [get_short_hostname $hostname]
   if {[info exists host_array($hostname,m_topology_in_use)]} {
      return $host_array($hostname,m_topology_in_use)
   }
   return "NONE"
}


## @brief Wait for a host to report a specific fake topology
#
# This is useful after changing the fake topology of a host via topology_file part of the
# global/local configuration. The function waits until the host reports the expected
# topology or the timeout is reached.
#
# @param hostname The hostname to query
# @param expected_topology The expected topology string
# @param timeout Maximum time to wait in seconds (default: 60)
# @return 1 if the expected topology was reported, 0 if timeout was reached
#
proc host_wait_for_fake_topology {hostname expected_topology {timeout 60}} {
   set hostname [get_short_hostname $hostname]

   set waited 0
   while {$waited < $timeout} {
      set topo [host_get_topology $hostname]
      if {$topo == $expected_topology} {
         return 1
      }
      incr waited 1
      after 1000
   }
   ts_log_severe "Host $hostname did not report expected fake topology within $timeout seconds. Expected: $expected_topology, got: $topo"
   return 0
}

## @brief Get the architecture of the local host
#
proc get_arch {} {
   get_current_cluster_config_array ts_config

   # get architecture of local host by executing the arch script
   set root_dir $ts_config(product_root)
   if {[catch {exec "$root_dir/util/arch"} output] == 0} {
      return $output
   }

   return "unknown"
}

## @brief Get the path to the loadcheck binary
#
proc get_loadcheck_path {} {
   get_current_cluster_config_array ts_config

   # find loadcheck binary
   set arch [get_arch]
   set loadcheck_path "$ts_config(product_root)/utilbin/$arch/loadcheck"
   return $loadcheck_path
}

## @brief Get all files in a directory
#
# Returns a list of files (not directories) in the given directory.
# If the directory does not exist or is empty, an empty list is returned.
#
# @param dir The directory to list
# @return A list of files in the directory
#
proc get_files_in_directory {dir} {
    set files [glob -nocomplain -directory $dir *]
    set result {}
    foreach f $files {
        if {[file isfile $f]} {
            lappend result $f
        }
    }
    return $result
}

## @brief Check if a string has equal number of opening and closing brackets
#
# This function checks if the given string has an equal number of opening
# and closing brackets of the specified type.
#
# @param str The string to check
# @param open_char The opening bracket character
# @param close_char The closing bracket character
# @return 1 if equal, 0 if not equal
#
proc has_equal_brackets {str open_char close_char} {
    set open_count 0
    set close_count 0
    foreach char [split $str ""] {
        if {$char == $open_char} {
            incr open_count
        } elseif {$char == $close_char} {
            incr close_count
        }
    }
    return [expr {$open_count == $close_count}]
}

## @brief Get hardware node statistics from a topology string
#
# This function counts the occurrences of each hardware component in the
# given topology string and stores the results in the specified array.
# The array is filled with the following structure:
#
#   array_name(letter) = count
#
# where letter is one of S, C, E, T, N, X, Y and count is the number of
# occurrences of that letter in the topology string.
#
# @param internal_topo_string The topology string to analyze
# @param array_name Name of the array to store the results in
#
proc get_hardware_node_stats {internal_topo_string array_name} {
   upvar $array_name stats

   foreach letter [split $internal_topo_string ""] {
      if {[string first $letter "SCETNXY"] < 0} {
         continue
      }
      incr stats($letter)
   }
}

