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

# Validation of the software bill of materials (SBOM) the products ship (CS-2841).
#
# Every product installs a CycloneDX SBOM - the core system as 3rd_party/sbom.cyclonedx.json,
# the products installed by their own checktrees below 3rd_party/<product>/ or in their own
# directory. Wherever the testsuite installs a product it validates that file with cyclonedx-cli
# (https://github.com/CycloneDX/cyclonedx-cli).
#
# cyclonedx-cli is not configured: it is searched on the hosts the testsuite knows, the way
# gnuplot is. Where it is found on none of them, the validation is skipped with a config message.

###
# @brief find cyclonedx-cli on one of the hosts the testsuite knows
#
# Searched for as "cyclonedx" (the name the CycloneDX releases suggest) and "cyclonedx-cli", via
# get_binary_path - that is in the host configuration first, then in the PATH of the user on the
# host. The hosts are tried in this order: the host running the testsuite, the compile hosts, the
# cluster hosts. The result is kept for the rest of the testsuite run, whether a binary was found
# or not.
#
# @param[out] host_var   name of a variable receiving the host cyclonedx-cli was found on
# @param[out] binary_var name of a variable receiving its path on that host
# @return 1 when cyclonedx-cli was found, 0 otherwise
##

# clear the cached values
global sbom_cyclonedx_host sbom_cyclonedx_binary
unset -nocomplain sbom_cyclonedx_host sbom_cyclonedx_binary

proc sbom_find_cyclonedx {host_var binary_var} {
   global sbom_cyclonedx_host sbom_cyclonedx_binary
   upvar $host_var host
   upvar $binary_var binary

   if {![info exists sbom_cyclonedx_host]} {
      set sbom_cyclonedx_host ""
      set sbom_cyclonedx_binary ""

      # the testsuite host first, then the compile hosts, then the cluster hosts - each once
      set hosts [gethostname]
      foreach candidate [concat [compile_host_list] [host_conf_get_cluster_hosts]] {
         if {[lsearch -exact $hosts $candidate] < 0} {
            lappend hosts $candidate
         }
      }

      foreach candidate $hosts {
         foreach name {cyclonedx cyclonedx-cli} {
            # get_binary_path returns the name unchanged when it finds no binary
            set path [get_binary_path $candidate $name 0]
            if {$path ne $name} {
               set sbom_cyclonedx_host $candidate
               set sbom_cyclonedx_binary $path
               break
            }
         }
         if {$sbom_cyclonedx_host ne ""} {
            break
         }
      }

      if {$sbom_cyclonedx_host ne ""} {
         ts_log_fine "using cyclonedx-cli $sbom_cyclonedx_binary on host $sbom_cyclonedx_host"
      } else {
         ts_log_fine "cyclonedx-cli was found on none of the hosts: $hosts"
      }
   }

   set host $sbom_cyclonedx_host
   set binary $sbom_cyclonedx_binary

   return [expr {$sbom_cyclonedx_host ne ""}]
}

###
# @brief validate a CycloneDX SBOM with cyclonedx-cli
#
# Runs "cyclonedx validate" on the host cyclonedx-cli was found on (see sbom_find_cyclonedx), which
# has to see the file - the SBOMs checked here are below the product root, which every testsuite
# host sees. The document is validated against the specification version it declares itself:
# the products produce different ones, and cyclonedx-cli would otherwise assume its latest.
#
# The outcome is recorded as a task of its own in the report, named <component>_sbom_validate,
# or sbom_validate for the core system.
#
# @param[in] sbom_file  absolute path of the SBOM
# @param[in] report_var name of the report array of the calling step
# @param[in] component  the product the SBOM belongs to, e.g. drmaaj - empty for the core system
# @param[in] required   1: a missing file is an error, 0: a missing file is skipped
# @return 0 when the SBOM is valid, or when the validation was skipped (no cyclonedx-cli, or
#         a file which is not required is missing) - -1 when the file is missing although it is
#         required, or the validation failed
##
proc sbom_validate {sbom_file report_var {component ""} {required 1}} {
   global CHECK_USER
   upvar $report_var report

   if {![sbom_find_cyclonedx host binary]} {
      ts_log_config "cyclonedx-cli was found on none of the hosts, $sbom_file is not validated"
      return 0
   }

   set task_name "sbom_validate"
   if {$component ne ""} {
      set task_name "${component}_$task_name"
   }
   set task_nr [report_create_task report $task_name $host]
   report_task_add_message report $task_nr "validating $sbom_file with $binary"

   if {![is_remote_file $host $CHECK_USER $sbom_file 1]} {
      if {$required} {
         report_task_add_message report $task_nr "the SBOM $sbom_file does not exist"
         report_finish_task report $task_nr -1
         return -1
      }
      report_task_add_message report $task_nr "there is no SBOM $sbom_file, nothing to validate"
      report_finish_task report $task_nr 0
      return 0
   }

   # the specification version the document declares, e.g. "specVersion": "1.6" -> v1_6
   set version_arg ""
   get_file_content $host $CHECK_USER $sbom_file content
   for {set i 1} {$i <= $content(0)} {incr i} {
      if {[regexp {"specVersion"\s*:\s*"([0-9]+)\.([0-9]+)"} $content($i) -> major minor]} {
         set version_arg "--input-version v${major}_$minor"
         break
      }
   }

   set args "validate --input-file $sbom_file --input-format json $version_arg --fail-on-errors"
   set output [start_remote_prog $host $CHECK_USER $binary $args prg_exit_state 120]
   report_task_add_message report $task_nr $output
   if {$prg_exit_state != 0} {
      report_task_add_message report $task_nr "the SBOM $sbom_file is not valid"
      report_finish_task report $task_nr -1
      return -1
   }

   report_finish_task report $task_nr 0
   return 0
}

###
# @brief validate the SBOM a checktree installed with its product
#
# Products got their SBOM at different times, and a checktree may install an older version which
# has none. So the build output decides: when the build of the product produced an SBOM, the
# installed copy has to exist and be valid; when it produced none, there is nothing to validate.
#
# @param[in] component      the product, e.g. drmaaj - names the report task, see sbom_validate()
# @param[in] built_sbom     path of the SBOM the build of the product produces
# @param[in] installed_sbom path of the SBOM below the product root
# @param[in] report_var     name of the report array of the install step
# @return 0 when the installed SBOM is valid or there is none to expect, -1 otherwise
##
proc sbom_validate_installed {component built_sbom installed_sbom report_var} {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   upvar $report_var report

   if {![is_remote_file $ts_config(master_host) $CHECK_USER $built_sbom 1]} {
      ts_log_fine "the build produced no SBOM $built_sbom, nothing to validate"
      return 0
   }

   return [sbom_validate $installed_sbom report $component]
}
