#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2026 HPC-Gridware GmbH
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

##
# @brief Can docker be used on a host?
#
# Docker is driven as root. The test user is not expected to be in the docker
# group, and on a host outside the cluster there is no reason for it to be.
#
# @param host host to check
# @return 1 if docker answers on that host, else 0
proc docker_is_available {host} {
   # docker is looked up in PATH, so no file check; a host without docker is an
   # expected outcome here, so no error is raised
   start_remote_prog $host "root" "docker" "info" prg_exit_state 30 0 "" "" 0 0 0 0
   if {$prg_exit_state == 0} {
      return 1
   }

   return 0
}

##
# @brief Find a host from the host configuration which can run docker.
#
# Walks the hosts known to the testsuite and returns the first one where docker
# answers. Hosts which are down or have no docker are skipped, so the search
# costs a remote call per host until one succeeds.
#
# The caller decides which roles disqualify a host. A container started on a
# host that is already a submit host of the cluster inherits that host's
# standing once its traffic is NAT'ed to the host address, which would let a
# submission succeed for a reason the test did not intend to exercise. Pass
# skip_submit_hosts in that case.
#
# @param skip_submit_hosts 1 to ignore submit hosts of the current cluster
# @param skip_admin_hosts  1 to ignore administration hosts of the current cluster
# @return name of the first suitable host, or "" if there is none
proc docker_get_host {{skip_submit_hosts 0} {skip_admin_hosts 0}} {
   get_current_cluster_config_array ts_config
   global ts_host_config

   # host names from the host configuration and from qconf need not be written
   # the same way - compare them resolved
   set excluded {}

   if {$skip_submit_hosts} {
      if {[get_submithost_list submit_hosts "" "" 0] != 0} {
         ts_log_fine "docker_get_host: cannot read the submit host list"
         return ""
      }
      foreach host $submit_hosts {
         lappend excluded [resolve_host $host]
      }
   }

   if {$skip_admin_hosts} {
      if {[get_adminhost_list admin_hosts "" "" 0] != 0} {
         ts_log_fine "docker_get_host: cannot read the administration host list"
         return ""
      }
      foreach host $admin_hosts {
         lappend excluded [resolve_host $host]
      }
   }

   foreach host $ts_host_config(hostlist) {
      if {[lsearch -exact $excluded [resolve_host $host]] >= 0} {
         ts_log_finer "docker_get_host: skipping $host, it has an excluded role"
         continue
      }

      if {[docker_is_available $host]} {
         ts_log_fine "docker_get_host: using docker host $host"
         return $host
      }
      ts_log_finer "docker_get_host: no usable docker on $host"
   }

   return ""
}
