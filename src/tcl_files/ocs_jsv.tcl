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

## @brief Returns the reported and unspecified parameters from job context contained in qstat_j_info
#
# @param variable_name Name of the variable containing qstat_j_info (default: "qstat_j_info")
# @return List with two elements: list of reported parameters and list of unspecified parameters
#
proc jsv_get_params_from_context {{variable_name "qstat_j_info"}} {
   upvar $variable_name qstat_j_info

   set context $qstat_j_info(context)

   set params_reported {}
   set params_unspecified {}
   set fields_found 0
   foreach pair [split $context ","] {
       set key_value [split $pair "="]
       set key [lindex $key_value 0]
       set value [lindex $key_value 1]

       if {$key == "jsv_params_reported"} {
          set params_reported [split $value "|"]
          incr fields_found
       } elseif {$key == "jsv_params_unspecified"} {
          set params_unspecified [split $value "|"]
          incr fields_found
       }
       if {$fields_found == 2} {
          break
       }
   }
   return [list [split $params_reported ":"] [split $params_unspecified ":"]]
}

## @brief Returns the key and value of a parameter from job context contained in qstat_j_info
#
# @param param_name Name of the parameter to search for (e.g "bamount")
# @param variable_name Name of the variable containing qstat_j_info (default: "qstat_j_info")
# @return List with key and value of the parameter, or empty string if not found
#
proc jsv_get_param_key_value_from_context {param_name {variable_name "qstat_j_info"}} {
   upvar $variable_name qstat_j_info

   set context $qstat_j_info(context)
   foreach pair [split $context ","] {
       set key_value [split $pair "="]
       set key [lindex $key_value 0]
       set value [lindex $key_value 1]

       if {$key == "jsv_$param_name"} {
          set key_without_prefix [string range $key 4 end]; # remove jsv_ prefix
          return [list $key $value]
       }
   }
   return ""
}
