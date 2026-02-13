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

global gperf_scenario_name
set gperf_scenario_name "default"

global gperf_threads_name
set gperf_threads_name "scheduler"

## @brief Set scenario name and name of threads to be profiled.
#
# This procedure sets the scenario name and the name of the threads to be profiled for the performance test.
# The scenario name is used to identify the performance test scenario, while the name of the threads is used to
# specify the category (threads/component/unit) to be profiled during the performance test.
# The procedure also updates the qmaster parameters to include the gperf_name and gperf_threads parameters,
# which are used by the performance testing framework to generate the appropriate performance reports.
#
# @param gperf_name The name of the performance test scenario. Default is "binding_with_pe_wildcard_and_reservation".
# @param gperf_threads The name of the threads to be profiled. Default is "scheduler". Note that this also
#                      needs to be available within the component that is profiled.app_path
#
proc perf_set_gperf_name {{gperf_name "default"} {gperf_threads "scheduler"}} {
   global gperf_scenario_name

   # remember scenario name for later use
   set gperf_scenario_name $gperf_name
   set gperf_threads_name $gperf_threads

   # fetch current qmaster_params
   get_config cluster_config
   set qmaster_params $cluster_config(qmaster_params)

   # set or delete gperf_name and gperf_threads parameters
   if {$gperf_name != ""} {
      set qmaster_params [add_or_replace_param $qmaster_params "gperf_name" "gperf_name=$gperf_name"]
      set qmaster_params [add_or_replace_param $qmaster_params "gperf_threads" "gperf_threads=$gperf_threads"]
   } else {
      set qmaster_params [add_or_replace_param $qmaster_params "gperf_name" ""]
      set qmaster_params [add_or_replace_param $qmaster_params "gperf_threads" ""]
   }
   set cluster_config(qmaster_params) $qmaster_params
   reset_config_and_propagate cluster_config
}

## @brief Reset scenario name and name of thread/component/unit to be profiled.
proc perf_reset_gperf_name {} {
   global gperf_scenario_name
   global gperf_threads_name

   set gperf_scenario_name ""
   set gperf_threads_name ""
   perf_set_gperf_name $gperf_scenario_name
}

## @brief Get the appropriate pprof switch for the given output format.
#
# This procedure takes an output format extension (e.g., "pdf" or "txt") and returns the corresponding switch to be
# used with the pprof tool for generating performance reports in that format. If the provided format extension is not
# recognized, it logs a severe error message and returns a default switch indicating an unknown format.
#
# @param format_ext The output format extension for which to get the pprof switch (e.g., "pdf", "txt").
# @return The pprof switch corresponding to the given output format extension, or "--unknown" if the format is not recognized.
#
proc perf_get_switch_for_format {format_ext} {
   switch -- $format_ext {
      "pdf" {
         return "--pdf"
      }
      "txt" {
         return "--text"
      }
      default {
         ts_log_severe "Unknown output format $format. Cannot determine pprof switch for this format."
         return "--unknown"
      }
   }
}

# @brief Find the path of the first available application from a list of applications on a given host.
#
# This procedure takes a list of application names and an optional host name, and checks for the presence of each
# application on the specified host. If no host is provided, it defaults to checking on the master host. The procedure
# returns the path of the first application found on the host. If none of the applications are found, it logs a severe
# error message and returns an empty string.
#
# @param app_list A list of application names to check for (e.g., {"pprof-symbolize" "pprof"}).
# @param host (Optional) The host on which to check for the applications. If not provided, the master host will be used.
# @return The path of the first application found on the specified host, or an empty string if none of the applications are found.
#
proc perf_find_app {app_list {host ""}} {
   get_current_cluster_config_array ts_config

   # if no host is given then we look for the app on the master host
   if {$host == ""} {
      set host $ts_config(master_host)
   }

   # look for the app in the given order and return the path of the first one found
   foreach app $app_list {
      set app_path [get_binary_path $host $app]
      if {$app_path != $app} {
         return $app_path
      }
      set app_path ""
   }

   # if we are here, none of the apps was found
   if {$app_path == ""} {
      ts_log_severe "None of the applications in $app_list found on host $host"
   }
   return ""
}

## @brief Generate performance reports in specified formats while ignoring certain functions.
#
# This procedure generates performance reports in the specified output formats (e.g., "txt", "pdf") using the pprof
# tool. It takes into account a list of functions to ignore during report generation, which can help reduce noise in
# the reports by excluding irrelevant functions. The procedure determines the appropriate pprof binary to use,
# constructs the necessary arguments for report generation, and executes the command on the master host where the
# pprof profile files are located.
#
# @param output_formats A list of output formats for the reports (e.g., {"txt" "pdf"}).
# @param ignore_functions A list of function names to ignore in the reports (e.g., {"schedd_log" "rmon_mprintf"}).
#
proc perf_generate_reports {{output_formats {"txt" "pdf"}} {ignore_functions {"schedd_log" "rmon_mprintf"}}} {
   global CHECK_USER
   global gperf_scenario_name
   global gperf_threads_name
   get_current_cluster_config_array ts_config

   # find the master host. there also the pprof dumps are located and there we need to run pprof to generate the report
   set pprof_host $ts_config(master_host)
   set pprof_user $CHECK_USER

   # find pprof-symbolize or pprof binary. we prefer pprof-symbolize, but if it is not available we can also use pprof
   # which was the name some releases ago. if none of them is available, we cannot generate the report
   set app_list [list "pprof-symbolize" "pprof"]
   set pprof_path [perf_find_app $app_list $pprof_host]
   if {$pprof_path == ""} {
      return
   }

   # determine the correct qmaster binary for the master host architecture
   set ocs_arch [resolve_arch $pprof_host]
   set ocs_qmaster_path "$ts_config(product_root)/bin/${ocs_arch}/sge_qmaster"

   # pprof profile file and output directory on master host
   set pprof_profile_file "/tmp/${gperf_threads_name}-$gperf_scenario_name"
   set pprof_result_dir "$ts_config(results_dir)/protocols/sperf/${gperf_threads_name}"
   set pprof_ignore_args ""
   foreach pprof_ignore_switch $ignore_functions {
      append pprof_ignore_args " --ignore=$pprof_ignore_switch"
   }

   # ensure output directory exists
   remote_file_mkdir $pprof_host $pprof_result_dir

   # generate report for different output formats
   foreach pprof_output_format $output_formats {

      # output file
      set pprof_pdf_file "$pprof_result_dir/${gperf_scenario_name}.$pprof_output_format"


      # pprof arguments
      set pperf_switch [perf_get_switch_for_format $pprof_output_format]
      set pprof_args $pperf_switch; # output format
      append pprof_args " $pprof_ignore_args"; # avoid noise we are not interested in
      append pprof_args " $ocs_qmaster_path"
      append pprof_args " $pprof_profile_file"
      append pprof_args " >$pprof_pdf_file"; # redirection to output file
      ts_log_info "Generating $pprof_output_format report with command: $pprof_path $pprof_args"

      # generate the report
      set output [start_remote_prog $pprof_host $pprof_user $pprof_path $pprof_args prg_exit_state 60]
   }
}
