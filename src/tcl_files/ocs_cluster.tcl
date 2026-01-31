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

## @brief deletes almost all cluster objects
#
# Deletes all cluster objects except for those ones that cannot be deleted
# because of OCS/GCS requirements (e.g. builtin complexes, global host, ...)
# Might fails if there are dependencies between objects.
# For example, if a queue is still referenced in a different queue (suspend on subordinate)...
#
# Might cause issues if this function is used in tests that do not restore the cluster because
# some objects might be required by the testsuite framework (e.g. configuration objects)
#
proc cluster_delete_all_objects {} {
   cluster_delete_all_queues
   cluster_delete_all_hostgroups
   cluster_delete_all_exechosts
   cluster_delete_all_calendars
   cluster_delete_all_ckpts
   cluster_delete_all_configs
   cluster_delete_all_pes
   cluster_delete_all_projects
   cluster_delete_all_rqss
   cluster_delete_all_users
   cluster_delete_all_usersets

   # builtin complexes and global host cannot be deleted
}

proc cluster_delete_all_queues {} {
   get_queue_list queue_list "" "" 0

   # exit if list is already empty
   if {[llength $queue_list] == 1 && [lindex $queue_list 0] == "no cqueue list defined"} {
      return
   }

   # delete all queues
   foreach queue_name $queue_list {
      del_queue $queue_name "" 1 1
   }
}

proc cluster_delete_all_hostgroups {} {
   get_hostgroup_list hgroup_list "" "" 0

   # exit if list is already empty
   if {[llength $hgroup_list] == 1 && [lindex $hgroup_list 0] == "no host group list defined"} {
      return
   }

   foreach hgroup_name $hgroup_list {
      del_hostgroup $hgroup_name
   }
}

proc cluster_delete_all_exechosts {} {
   get_exechost_list exec_host_list "" "" 0

   # exit if list is already empty
   if {[llength $exec_host_list] == 1 && [lindex $exec_host_list 0] == "no execution host defined"} {
      return
   }
   foreach exec_host_name $exec_host_list {
      start_sge_bin "qconf" "-de $exec_host_name"
   }
}

proc cluster_delete_all_calendars {} {
   get_calendar_list cal_list "" "" 0

   # exit if list is already empty
   if {[llength $cal_list] == 1 && [lindex $cal_list 0] == "no calendar defined"} {
      return
   }
   foreach cal_name $cal_list {
      start_sge_bin "qconf" "-dcal $cal_name"
   }
}

proc cluster_delete_all_ckpts {} {
   get_ckpt_list ckpt_list "" "" 0

   # exit if list is already empty
   if {[llength $ckpt_list] == 1 && [lindex $ckpt_list 0] == "no ckpt interface definition defined"} {
      return
   }
   foreach ckpt_name $ckpt_list {
      start_sge_bin "qconf" "-dckpt $ckpt_name"
   }
}

proc cluster_delete_all_configs {} {
   get_config_list conf_list "" "" 0

   # exit if list is already empty
   if {[llength $conf_list] == 1 && [lindex $conf_list 0] == "no config defined"} {
      return
   }
   foreach conf_name $conf_list {
      start_sge_bin "qconf" "-dconf $conf_name"
   }
}

proc cluster_delete_all_pes {} {
   get_pe_list pe_list "" "" 0

   # exit if list is already empty
   if {[llength $pe_list] == 1 && [lindex $pe_list 0] == "no parallel environment defined"} {
      return
   }
   foreach pe_name $pe_list {
      start_sge_bin "qconf" "-dp $pe_name"
   }
}

proc cluster_delete_all_projects {} {
   get_project_list project_list "" "" 0

   # exit if list is already empty
   if {[llength $project_list] == 1 && [lindex $project_list 0] == "no project list defined"} {
      return
   }
   foreach project_name $project_list {
      start_sge_bin "qconf" "-dprj $project_name"
   }
}

proc cluster_delete_all_rqss {} {
   get_rqs_list rqs_list "" "" 0

   # exit if list is already empty
   if {[llength $rqs_list] == 1 && [lindex $rqs_list 0] == "no resource quota set list defined"} {
      return
   }
   foreach rqs_name $rqs_list {
      start_sge_bin "qconf" "-drqs $rqs_name"
   }
}

proc cluster_delete_all_users {} {
   global CHECK_USER
   get_user_list user_list "" "" 0

   # exit if list is already empty
   if {[llength $user_list] == 1 && [lindex $user_list 0] == $CHECK_USER} {
      return
   }
   foreach user_name $user_list {
      if {$user_name == $CHECK_USER} {
         continue
      }
      start_sge_bin "qconf" "-duser $user_name"
   }
}

proc cluster_delete_all_usersets {} {
   get_userset_list userset_list "" "" 0

   # exit if list is already empty
   if {[llength $userset_list] == 1 && [lindex $userset_list 0] == "no userset list defined"} {
      return
   }
   foreach userset_name $userset_list {
      start_sge_bin "qconf" "-dul $userset_name"
   }
}

