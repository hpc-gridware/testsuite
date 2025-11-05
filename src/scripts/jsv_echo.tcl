#!/usr/bin/env tclsh
#
#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2024 HPC-Gridware GmbH
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

########################################################################### 
#
# example for a job verification script 
#
# Be careful:  Job verification scripts are started with sgeadmin 
#              permissions if they are executed within the master process
#

set sge_root $env(SGE_ROOT)
set sge_arch [exec $sge_root/util/arch]

source "$sge_root/util/resources/jsv/jsv_include.tcl"

proc jsv_on_start {} {
   jsv_send_env
}

## @brief Returns the list of parameters that are not lists
proc jsv_get_non_list_params {} {
   return [list "a" "A" "ar" "b" "c" "ckpt" "cwd" "dept" "dl" "e" "btype" "bamount" "bfilter" "bunit" \
                "bstrategy" "bsort" "bstart" "bstop" "binstance" "h" "hold_jid" "i" "j" "m" "M" \
                "notify" "now" "N" "o" "ot" "p" "P" "pe_name" "pe_min" "pe_max" "r" "R" "shell" "S" \
                "t_min" "t_max" "t_step" "tc" "u" "CLIENT" "CONTEXT" "CMDNAME" "CMDARGS" "CMDARG0" "CMDARG1" "CMDARG2" "CMDARG3" \
                "CMDARG4" "CMDARG5" "CMDARG6" "CMDARG7" "CMDARG8" "GROUP" "JOB_ID" "USER" "VERSION"]
}

## @brief Returns the list of parameters that are lists
proc jsv_get_list_params {} {
   # ac MUST be first in the list because otherwise the loop in jsv_on_verify changes the context
   return [list "ac" "global_l_hard" "global_l_soft" "master_l_hard" "master_l_soft" "slave_l_hard" "slave_l_soft" \
                "global_q_hard" "global_q_soft" "master_q_hard" "master_q_soft" "slave_q_hard" "slave_q_soft"]
}

## @brief Returns the list of all parameters
#
# @note list parameters are returned first and ac MUST be the first in the list
proc jsv_get_all_params {} {
   set list_params [jsv_get_list_params]
   set non_list_params [jsv_get_non_list_params]
   return [concat $list_params $non_list_params]
}

proc jsv_get_instruction {instructions key} {
   foreach instruction [split $instructions ","] {
      set list [split $instruction "="]
      set name [lindex $list 0]
      set value [lrange $list 1 end]

      if {$key == $name} {
         return $value
      }
   }
}

## @brief Accepts all reported parameters and adds them to the job context
proc jsv_on_verify {} {
   # collect all parameters that were reported or not specified
   set instructions {}
   set params_reported {}
   set params_unspecified {}
   foreach param [jsv_get_all_params] { ;# handle ac first
      # handle ac that might contain instructions
      if {$param == "ac"} {
         set instructions [jsv_get_param $param]
         continue
      }

      # collect names of unspecified parameters
      if {![jsv_is_param $param]} {
         lappend params_unspecified $param
         continue
      }

      # for reported parameters, copy their value to the job context (map , to | because , is used as separator in ac)
      lappend params_reported $param
      set value [jsv_get_param $param]
      set value [string map {"," "|"} $value]
      jsv_sub_add_param "ac" "jsv_$param" $value
   }

   # add all parameter names to the job context
   jsv_sub_add_param "ac" "jsv_params_reported" [join $params_reported "|"]
   jsv_sub_add_param "ac" "jsv_params_unspecified" [join $params_unspecified "|"]

   # handle instructions
   set end [jsv_get_instruction $instructions "jsv_instructions"]
   jsv_log_info "JSV received $end instructions"

   for {set i 0} {$i < $end} {incr i} {
      set instruction [jsv_get_instruction $instructions "jsv_instruction$i"]
      set list [split $instruction ":"]
      set cmd [lindex $list 0]
      set args [lrange $list 1 end]

      jsv_log_info "Handling JSV instruction: $cmd with args: $args"
      $cmd {*}$args
   }

   # accept the job with all job context adjustments
   jsv_correct "Job is accepted"
}

jsv_main

