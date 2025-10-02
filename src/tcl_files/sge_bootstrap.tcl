#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2024-2025 HPC-Gridware GmbH
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


###
# @brief read the bootstrap file to an array
#
# @param array_var the name of the array to store the bootstrap values
# @return 1 if the file was read successfully, 0 otherwise
##
proc bootstrap_file_read {{array_var "bootstrap"}} {
   get_current_cluster_config_array ts_config
   upvar $array_var bootstrap

   set ret 0

   set bootstrap_file "$ts_config(product_root)/$ts_config(cell)/common/bootstrap"
   if {[file isfile $bootstrap_file]} {
      if {[read_file $bootstrap_file data] == 0} {
         for {set i 1} {$i <= $data(0)} {incr i} {
            if {[string index $data($i) 0] == "#"} {
               continue
            }
            set name [lindex $data($i) 0]
            set value [lrange $data($i) 1 end]
            set bootstrap($name) [join $value]
         }
         set ret 1
      }
   }

   return $ret
}

###
# @brief write the bootstrap file to an array
#
# Reads the existing bootstrap file,
# replaces entries with the values from the given array,
# re-writes the bootstrap file.
# If entries are given as empty string, these entries will be removed from the new bootstrap file.
#
# @param array_var the name of the array containing the bootstrap values
# @param remove_additional optional, if set (1) will remove entries from the bootstrap file which
#                          are not mentioned in the new bootstrap array
# @return 1 if the file was written successfully, 0 otherwise
##
proc bootstrap_file_write {{array_var "bootstrap"} {remove_additional 0}} {
   get_current_cluster_config_array ts_config
   upvar $array_var new_bootstrap

   set ret 0
   set bootstrap_file "$ts_config(product_root)/$ts_config(cell)/common/bootstrap"

   # get the current values
   set ret [bootstrap_file_read bootstrap]

   if {$ret} {
      # overwrite the existing values with the new ones
      foreach name [array names new_bootstrap] {
         if {[string length $new_bootstrap($name)] == 0} {
            # remove empty entries
            unset -nocomplain bootstrap($name)
         } else {
            set bootstrap($name) $new_bootstrap($name)
         }
      }

      # if requested then remove additional entries which are not in the new array
      if {$remove_additional} {
         # remove entries which are not in the new array
         foreach name [array names bootstrap] {
            if {![info exists new_bootstrap($name)]} {
               unset -nocomplain bootstrap($name)
            }
         }
      }

      # write the new values to the file
      set idx 0
      incr idx ; set data($idx) "# Version: [get_version_info]"
      incr idx ; set data($idx) "# modified by testsuite"

      foreach name [lsort [array names bootstrap]] {
         incr idx ; set data($idx) [format "%-24s %s" $name $bootstrap($name)]
      }

      set data(0) $idx

      # bootstrap file cannot be written by default, so we need to change the permissions
      set restore_permissions 0
      if {![file writable $bootstrap_file]} {
         set backup_permissions [file attributes $bootstrap_file -permissions]
         set restore_permissions 1
         file attributes $bootstrap_file -permissions 0644
      }
      save_file $bootstrap_file data
      set ret 1 ;# save_file doesn't return anything, let's assume it worked

      # restore the permissions
      if {$restore_permissions} {
         file attributes $bootstrap_file -permissions $backup_permissions
      }
   }

   return $ret
}
