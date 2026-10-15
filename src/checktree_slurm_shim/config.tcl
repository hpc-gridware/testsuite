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


# no checktree specific config yet but config related functions

###
# @brief get the slurm-shim source directory
#
# We expect the slurm-shim repository to be checked out besides the other repositories.
#
# @return absolute path to the slurm-shim source directory or an empty string if not found
##
proc slurm_shim_get_source_dir {} {
   get_current_cluster_config_array ts_config

   set ret ""
   set cs_source_dir $ts_config(source_dir)
   if {$cs_source_dir != "none"} {
      set top_level [file dirname [file dirname $cs_source_dir]]
      set source_dir "$top_level/slurm-shim"
      if {[file isdirectory $source_dir]} {
         set ret $source_dir
      }
   }

   return $ret
}
