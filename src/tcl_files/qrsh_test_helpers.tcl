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

## @brief Common setup for the qrsh_* sub-tests.
#
# Extracted from the original single-test check.exp during the qrsh split.
# Sub-tests under system_tests/clients/qrsh/{basic,signals,env_config,
# stdin,alltoall,accounting}/ all reference this as their
# check_setup_level_function — keeping the cluster prep centralised so a
# tweak (slot counts, debugging knobs) only needs to land in one place.
proc qrsh_setup {} {
   global ts_config CHECK_ACT_LEVEL
   global CHECK_FIRST_FOREIGN_SYSTEM_USER CHECK_FIRST_FOREIGN_SYSTEM_GROUP
   global qrsh_hostlist qrsh_submithost qrsh_config_backup
   global QSUB_GID_USER QSUB_GID_GROUPS

   # setup hosts
   set qrsh_submithost $ts_config(master_host)
   switch -exact $CHECK_ACT_LEVEL {
      0 {
         # get one suited host for testing
         set qrsh_hostlist [host_conf_get_suited_hosts]
      }
      200 {
         # get one suited host from each architecture for testing
         # @todo we should have one host per arch and OS (type and version)
         # for now use the whole list of execution nodes
         #set qrsh_hostlist $ts_config(unique_arch_nodes)
         set qrsh_hostlist $ts_config(execd_nodes)
      }
   }

   ts_log_fine "using submit host  $qrsh_submithost"
   ts_log_fine "using exec host(s) $qrsh_hostlist"

   # setup some user info
   set QSUB_GID_USER   $CHECK_FIRST_FOREIGN_SYSTEM_USER
   set QSUB_GID_GROUPS $CHECK_FIRST_FOREIGN_SYSTEM_GROUP

   # increase slots capacity
   setup_host_slots_for_binding

   # for debugging:
   # set KEEP_ACTIVE=ERROR to keep the active jobs directories in case of errors
   #get_config qrsh_config_backup
   #add_or_replace_array_param conf qrsh_config_backup "execd_params" "KEEP_ACTIVE" "TRUE"
   #set_config_and_propagate conf
}

## @brief Common cleanup for the qrsh_* sub-tests.
proc qrsh_cleanup {} {
   global qrsh_hostlist qrsh_submithost qrsh_config_backup
   global QSUB_GID_USER QSUB_GID_GROUPS

   delete_all_jobs
   wait_for_end_of_all_jobs

   cleanup_host_slots_for_binding

   #reset_config_and_propagate conf

   unset -nocomplain qrsh_hostlist qrsh_submithost qrsh_config_backup
   unset -nocomplain QSUB_GID_USER QSUB_GID_GROUPS
}
