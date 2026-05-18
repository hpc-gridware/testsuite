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

## @brief Expand an SGE memory size to bytes.
#
# Converts a "<number><suffix>" memory value (e.g. "10G") into its byte
# value (e.g. "10737418240") using the SGE multiplier table. Values that
# do not match the number+multiplier pattern are returned unchanged, so
# non-size tokens (host names, queue names, plain numbers) pass through.
#
# @param value the raw value token (e.g. "10G", "100M", "sleep")
# @return the value expanded to bytes, or the original value if not a size
proc sge_mem_to_bytes {value} {
   array set mult {
      k 1000 K 1024
      m 1000000 M 1048576
      g 1000000000 G 1073741824
      t 1000000000000 T 1099511627776
   }
   if {[regexp {^([0-9]+(?:\.[0-9]+)?)([kKmMgGtT])$} $value -> num suf]} {
      set bytes [expr {$num * $mult($suf)}]
      if {$bytes == int($bytes)} {
         return [format "%.0f" $bytes]
      }
      return $bytes
   }
   return $value
}

## @brief Normalise a resource request string for comparison.
#
# Splits a "name=value [name=value ...]" string and expands every memory
# size value to bytes via sge_mem_to_bytes. This makes a comparison accept
# both the suffixed form ("h_rss=10G") and the byte form
# ("h_rss=10737418240") that qstat -r / qstat -j may print.
#
# @param str the resource string (reported or expected)
# @return the string with all size values expanded to bytes
proc sge_normalize_resource_string {str} {
   set out {}
   foreach tok [regexp -all -inline {\S+} $str] {
      if {[regexp {^([^=]+)=(.+)$} $tok -> key val]} {
         lappend out "$key=[sge_mem_to_bytes $val]"
      } else {
         lappend out $tok
      }
   }
   return [join $out " "]
}