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
   return [list $params_reported $params_unspecified]
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
          return [list $param_name $value]
       }
   }
   return ""
}

## @brief Converts a list of JSV instructions into an ac argument list
#
# @param instructions List of JSV instructions
# @return ac argument list representing the instructions
#
proc jsv_instructions2ac_arguments {instructions} {
   # convert instructions in ac argument list
   set ac_arguments {}
   set id 0
   foreach instruction $instructions {
      if {$id > 0} {
         append ac_arguments ","
      }
      append ac_arguments "jsv_instruction$id=$instruction"
      incr id
   }
   set ac_arguments "jsv_instructions=$id,$ac_arguments"

   return $ac_arguments
}

## @brief Submits a job with given JSV script and instructions
#
# Instaructions are strings like `jsv_set_param:bamount:4` that will be handled by the JSV script.
# after : characters have been replaced by spaces. The first part is the TCL procedure to be called,
# the remaining parts are the arguments to be passed to the procedure.
#
# @param jsv_script Path to the JSV script
# @param instructions List of instructions to be passed to JSV via ac
# @param job_command Job command to be submitted
# @return Job ID of the submitted job
#
proc jsv_submit_job_with_instructions {jsv_script instructions job_arguments} {
   get_current_cluster_config_array ts_config

   # take the default echo script if caller does not provide one
   if {$jsv_script == ""} {
      set hostname $ts_config(master_host)
      set jsv_script [get_ts_local_script $hostname "jsv_echo.tcl"]
   }
   set qsub_arguments "-jsv $jsv_script"

   # convert instructions in ac argument list
   if {$instructions != ""} {
      set ac_arguments [jsv_instructions2ac_arguments $instructions]
      append qsub_arguments " -ac \"$ac_arguments\""
   }

   # submit a test job with jsv that echos the job parameters and handles instructions
   append qsub_arguments " $job_arguments -b y sleep 120"
   set job_id [submit_job $qsub_arguments]

   return $job_id
}

## @brief Parses binding request information from qstat_j_info and fills the binding array
#
# @param qstat_array_name Name of the variable containing qstat_j_info
# @param binding_array_name Name of the variable to fill with binding information
#
proc jsv_get_binding_from_qstat {qstat_array_name binding_array_name} {
   upvar $qstat_array_name qstat_j_info
   upvar $binding_array_name binding

   # parse binding from qstat_j_info
   set binding_string $qstat_j_info(binding)
   if {$binding_string != "" && $binding_string != "NONE"} {
      foreach pair [split $binding_string ","] {
         set key_value [split $pair "="]
         set key [lindex $key_value 0]
         set value [lindex $key_value 1]

         set binding($key) $value
      }
   }
}

## @brief Fills the jsv_array with parameter key-value pairs from job context in qstat_j_info
#
# Expects the list of reported parameters to be provided.
#
# @param params_reported List of reported parameters
# @param qstat_array_name Name of the variable containing qstat_j_info
# @param jsv_array_name Name of the variable to fill with parameter key-value pairs
#
proc jsv_get_binding_from_context {params_reported qstat_array_name jsv_array_name} {
   upvar $jsv_array_name jsv_array
   upvar $qstat_array_name qstat_array

   foreach param $params_reported {
      lassign [jsv_get_param_key_value_from_context $param qstat_array] key value

      set jsv_array($key) $value
   }
}
