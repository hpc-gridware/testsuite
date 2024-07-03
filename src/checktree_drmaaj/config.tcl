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

###
# @brief verify drmaaj configuration
#
# This function is called for verifying and/or for entering the configuration
# options for the checktree_drmaaj.
# It will also trigger updates to the configuration.
#
# @param[in] config_array - the configuration data
# @param[in] only_check   - if 1 (true): non interactive, just check
# @param[out] parameter_error_list - list of errors if there are any
##
proc drmaaj_verify_config {config_array only_check parameter_error_list} {
   global ts_checktree drmaaj_checktree_nr
   upvar $config_array config
   upvar $parameter_error_list param_error_list
   
   #drmaaj_config_upgrade_1_1 config

   return [verify_config2 config $only_check param_error_list $ts_checktree($drmaaj_checktree_nr,setup_hooks_0_version)]   
}

###
# @brief save the configuration of the checktree_drmaaj
#
# @param[in] filename
##
proc drmaaj_save_configuration {filename} {
   global drmaaj_config ts_checktree drmaaj_checktree_nr

   set conf_name $ts_checktree($drmaaj_checktree_nr,setup_hooks_0_name)
   
   if {![info exists drmaaj_config(version)]} {
      puts "invalid data (no version) in checktree_drmaa configuration"
      wait_for_enter
      return -1
   }

   # first get old configuration
   read_array_from_file  $filename $conf_name old_config
   # save old configuration 
   spool_array_to_file $filename "$conf_name.old" old_config
   spool_array_to_file $filename $conf_name drmaaj_config  
   ts_log_fine "new $conf_name saved"

   return 0
}

###
# @brief initialize the drmaaj configuration
#
# @param config_array - name of the configuration array to fill in
##
proc drmaaj_init_config {config_array} {
   global drmaaj_config drmaaj_checktree_nr ts_checktree
   global CHECK_CURRENT_WORKING_DIR
   
   upvar $config_array config
   # drmaaj_config defaults 
   set ts_pos 1
   set parameter "version"
   set config($parameter)            "1.0"
   set config($parameter,desc)       "DRMAA-Java configuration setup version"
   set config($parameter,default)    "1.0"
   set config($parameter,setup_func) ""
   set config($parameter,onchange)   "stop"
   set config($parameter,pos)        $ts_pos
   incr ts_pos 1

   set parameter "drmaaj_source_dir"
   set config($parameter)            ""
   set config($parameter,desc)       "Path to the DRMAA-Java source directory"
   set config($parameter,default)    ""
   set config($parameter,setup_func) "config_$parameter"
   set config($parameter,onchange)   "stop"
   set config($parameter,pos)        $ts_pos
   incr ts_pos 1

   # @todo further configuration options might be
   #   - build host (use the global java build host for now)
   #   - java version (use Java 8 or newer - we configured compatibilty with Java 8 in pom.xml anyway)

   #drmaaj_config_upgrade_1_1 config
}

###
# @brief Example of an config upgrade procedure
#
# modify to whatever is needed
#
# @param config_array - name of the configuration array to update
##
proc drmaaj_config_upgrade_1_1 { config_array } {
   upvar $config_array config

   if { $config(version) == "1.0" } {
      ts_log_fine "Upgrade to version 1.1"
      # insert new parameter after drmaaj_source_dir parameter
      set insert_pos $config(drmaaj_source_dir,pos)
      incr insert_pos 1
      
      # move positions of following parameters
      set names [array names config "*,pos"]
      foreach name $names {
         if {$config($name) >= $insert_pos} {
            set config($name) [expr $config($name) + 1]
         }
      }
   
      # new parameter compile_host
      set parameter "drmaaj_compile_host"
      set config($parameter)            ""
      set config($parameter,desc)       "DRMAA-Java compile host"
      set config($parameter,default)    "check_host" ;# config_generic will resolve the host
      set config($parameter,setup_func) "config_$parameter"
      set config($parameter,onchange)   "compile"
      set config($parameter,pos) $insert_pos
   
      # now we have a configuration version 1.1
      set config(version) "1.1"
   }
}

###
# @brief config_*: configuration procedures for each parameter
#
# @param only_check     - non interactive, only check the parameter value
# @param name           - name of the parameter
# @param config_array   - name of the configuration array
##
proc config_drmaaj_source_dir { only_check name config_array } {
   global fast_setup
   
   upvar $config_array config
   
   set help_text {  "Enter the full path to DRMAA-Java source directory."
                    "The testsuite needs this directory to build DRMAA-Java." }
   
   set value [config_generic $only_check $name config $help_text "directory" 0]

   if { $value == -1 } { return -1 }

   if {!$fast_setup} {
      if { [ file isfile $value/pom.xml ] != 1 } {
         puts "File \"$value/pom.xml\" not found"
         return -1
}
   }
   return $value
}

proc config_get_drmaaj_source_dir {} {
   global drmaaj_config

   return $drmaaj_config(drmaaj_source_dir)
}
