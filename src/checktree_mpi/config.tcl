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

###
# @brief verify mpi configuration
#
# This function is called for verifying and/or for entering the configuration
# options for the checktree_mpi.
# It will also trigger updates to the configuration.
#
# @param[in] config_array - the configuration data
# @param[in] only_check   - if 1 (true): non interactive, just check
# @param[out] parameter_error_list - list of errors if there are any
##
proc mpi_verify_config {config_array only_check parameter_error_list} {
   global ts_checktree mpi_checktree_nr
   upvar $config_array config
   upvar $parameter_error_list param_error_list

   #mpi_config_upgrade_1_1 config

   return [verify_config2 config $only_check param_error_list $ts_checktree($mpi_checktree_nr,setup_hooks_0_version)]
}

###
# @brief save the configuration of the checktree_mpi
#
# @param[in] filename
##
proc mpi_save_configuration {filename} {
   global mpi_config ts_checktree mpi_checktree_nr

   set conf_name $ts_checktree($mpi_checktree_nr,setup_hooks_0_name)

   if {![info exists mpi_config(version)]} {
      puts "invalid data (no version) in checktree_mpi configuration"
      wait_for_enter
      return -1
   }

   # first get old configuration
   read_array_from_file  $filename $conf_name old_config
   # save old configuration
   spool_array_to_file $filename "$conf_name.old" old_config
   spool_array_to_file $filename $conf_name mpi_config
   ts_log_fine "new $conf_name saved"

   return 0
}

###
# @brief initialize the mpi configuration
#
# @param config_array - name of the configuration array to fill in
##
proc mpi_init_config {config_array} {
   global mpi_config mpi_checktree_nr ts_checktree
   global CHECK_CURRENT_WORKING_DIR

   upvar $config_array config
   # mpi_config defaults
   set ts_pos 1
   set parameter "version"
   set config($parameter)            "1.0"
   set config($parameter,desc)       "MPI configuration setup version"
   set config($parameter,default)    "1.0"
   set config($parameter,setup_func) ""
   set config($parameter,onchange)   ""
   set config($parameter,pos)        $ts_pos
   incr ts_pos 1

   set parameter "mpi_install_dir"
   set config($parameter)            ""
   set config($parameter,desc)       "Path to the directory for MPI installations"
   set config($parameter,default)    ""
   set config($parameter,setup_func) "config_$parameter"
   set config($parameter,onchange)   ""
   set config($parameter,pos)        $ts_pos
   incr ts_pos 1

   set parameter "mpi_list"
   set config($parameter)            ""
   set config($parameter,desc)       "The MPI installations we want to test"
   set config($parameter,default)    ""
   set config($parameter,setup_func) "config_$parameter"
   set config($parameter,onchange)   ""
   set config($parameter,pos)        $ts_pos
   incr ts_pos 1

   #mpi_config_upgrade_1_1 config
}

###
# @brief Example of an config upgrade procedure
#
# modify to whatever is needed
#
# @param config_array - name of the configuration array to update
##
proc mpi_config_upgrade_1_1 {config_array} {
   upvar $config_array config

   if { $config(version) == "1.0" } {
      ts_log_fine "Upgrade to version 1.1"
      # insert new parameter after mpi_source_dir parameter
      set insert_pos $config(mpi_source_dir,pos)
      incr insert_pos 1

      # move positions of following parameters
      set names [array names config "*,pos"]
      foreach name $names {
         if {$config($name) >= $insert_pos} {
            set config($name) [expr $config($name) + 1]
         }
      }

      # new parameter compile_host
      set parameter "mpi_compile_host"
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
proc config_mpi_install_dir {only_check name config_array} {
   global fast_setup

   upvar $config_array config

   set help_text {"Enter the full path to a directory intended to hold MPI installations."
                  "It may already exist or can be built on demand."}

   set value [config_generic $only_check $name config $help_text "directory" 0]

   if {$value == -1} {
      return -1
   }

   if {!$fast_setup} {
      # anything we can check besides existance (which is done in config_generic above)
   }

   return $value
}

###
# @brief configure the list of MPI installations
#
# @param only_check     - non interactive, only check the parameter value
# @param name           - name of the parameter
# @param config_array   - name of the configuration array
##
proc config_mpi_list {only_check name config_array} {
   upvar $config_array config

   set description $config($name,desc)

   if {$only_check == 0} {
      if {![info exists config(mpi_list)] || $config(mpi_list) == {}} {
         config_mpi_add_default_mpi_list config
      }

      set not_ready 1
      while {$not_ready} {
         clear_screen
         puts "\nMPI installations"
         puts "================="
         puts "\n    MPI installations configured: [llength $config(mpi_list)]"
         config_mpi_show_list config
         puts "\n\n(1)  add MPI installation"
         puts "(2)  edit MPI installation"
         puts "(3)  delete MPI installation"
         puts "(10) exit setup"
         puts -nonewline "> "
         set input [wait_for_enter 1]
         switch -- $input {
            1 {
               set result [config_mpi_add_installation config]
               if {$result != 0} {
                  wait_for_enter
               }
            }
            2 {
               set result [config_mpi_edit_installation config]
               if {$result != 0} {
                  wait_for_enter
               }
            }
            3 {
               set result [mpi_config_delete_installation config]
               if {$result != 0} {
                  wait_for_enter
               }
            }
            10 {
               set not_ready 0
            }
         }
      }
   }

   # check database type configuration
   ts_log_finest "mpi_list:"
   foreach mpi $config(mpi_list) {
      ts_log_finest "checking mpi installation \"mpi\" ... "
   }

   return $config(mpi_list)
}

###
# @brief show the list of configured MPI installations
#
# @param array_name - name of the configuration array
##
proc config_mpi_show_list {array_name} {
   upvar $array_name config

   puts "\nMPI installations:\n"
   if {[llength $config(mpi_list)] == 0} {
      puts "no MPI configured"
      return ""
   }

   set index 0
   foreach mpi $config(mpi_list) {
      incr index 1
      puts "($index) $mpi"
   }

   return $config(mpi_list)
}

###
# @brief get the list of parameters for the MPI configuration
#
##
proc config_mpi_get_parameters {} {
   set params {}
   lappend params template
   lappend params versions
   lappend params archs
   lappend params do_build

   return $params
}

###
# @brief display the parameters for a given MPI installation
#
# @param name - name of the MPI installation
# @param config_array - name of the configuration array
##
proc config_mpi_display_params {name config_array} {
   upvar $config_array config

   set max_length 0

   set params [config_mpi_get_parameters]
   foreach param $params {
      set length [string length $param]
      if {$length > $max_length} {
         set max_length $length
      }
   }

   puts "\n"
   puts "   name [get_spaces [expr $max_length - 4]]: $name"
   foreach param $params {
      puts "   $param [get_spaces [expr $max_length - [string length $param]]]: $config($name,$param)"
   }
   puts "\n"
}

###
# @brief add a new MPI installation
#
# @param array_name - name of the configuration array
##
proc config_mpi_add_installation {array_name} {
   upvar $array_name config

   clear_screen
   puts "\nAdd MPI installation"
   puts "===================="
   config_mpi_show_list config
   puts "\n"
   puts -nonewline "Enter new MPI installation: "
   set new_mpi [wait_for_enter 1]

   if {[string length $new_mpi] == 0} {
      puts "no MPI installation entered"
      return -1
   }

   if {[string is integer $new_mpi]} {
      puts "invalid MPI installation entered"
      return -1
   }

   if {[lsearch $config(mpi_list) $new_mpi] >= 0} {
      puts "MPI installation \"$new_mpi\" is already in list"
      return -1
   }

   lappend config(mpi_list) $new_mpi
   foreach param [config_mpi_get_parameters] {
      set config($new_mpi,$param) ""
   }

   config_mpi_edit_installation config $new_mpi

   return 0
}

###
# @brief edit an existing MPI installation
#
# @param array_name - name of the configuration array
# @param have_name - optionally name of the MPI installation to edit, if not given then one can be selected
##
proc config_mpi_edit_installation {array_name {have_name ""}} {
   get_current_cluster_config_array ts_config
   upvar $array_name config

   set goto 0

   if {$have_name != ""} {
      set goto $have_name
   }

   while {1} {
      clear_screen
      puts "\nEdit MPI installation"
      puts "====================="
      config_mpi_show_list config
      puts "\n"
      puts -nonewline "Enter MPI installation/number or return to exit: "
      if {$goto == 0} {
         set mpi [wait_for_enter 1]
         set goto $mpi
      } else {
         set mpi $goto
         ts_log_fine $mpi
      }

      if {[string length $mpi] == 0} {
         break
      }

      if {[string is integer $mpi]} {
         incr mpi -1
         set mpi [lindex $config(mpi_list) $mpi]
      }

      if {[lsearch $config(mpi_list) $mpi] < 0} {
         puts "MPI installation \"$mpi\" not found in list"
         wait_for_enter
         set goto 0
         continue
      }

      config_mpi_display_params $mpi config

      puts -nonewline "Enter category to edit or hit return to exit > "
      set input [wait_for_enter 1]
      if {[string length $input] == 0} {
         set goto 0
         continue
      }

      if {[string compare $input "name"] == 0} {
         puts "Changing \"$input\" is not allowed"
         wait_for_enter
         continue
      }

      if {![info exists config($mpi,$input)]} {
         puts "Not a valid category"
         wait_for_enter
         continue
      }

      set extra 0
      switch -- $input {
         "template"  { set extra 1 }
         "versions"  { set extra 2 }
         "archs"     { set extra 3 }
         "do_build"  { set extra 4 }
      }

      if {$extra == 1} {
         # template
         set help_text {"Choose the template name (from $SGE_ROOT/mpi): "}
         # @todo figure out the templates from $SGE_ROOT/mpi?
         unset -nocomplain templates
         set templates(intel-mpi) ""
         set templates(mpich) ""
         set templates(mvapich) ""
         set templates(openmpi) ""
         set templates(ssh-wrapper) ""
         set value [config_generic 0 "$mpi,$input" config $help_text "choice" 0 1 templates]
         if {$value == -1} {
            wait_for_enter
         } else {
            set config($mpi,$input) $value
         }
         continue
      }

      if {$extra == 2} {
         # versions
         set help_text {"Enter a space separated list of the $mpi versions to be tested: "}
         set value [config_generic 0 "$mpi,$input" config $help_text "string" 0 "1+"]
         if {$value == -1} {
            wait_for_enter
         } else {
            set config($mpi,$input) $value
         }
         continue
      }

      if {$extra == 3} {
         # archs
         set help_text {"Select architectures for $mpi: "}
         unset -nocomplain archs
         foreach host $ts_config(execd_hosts) {
            set archs([resolve_arch $host]) ""
         }

         set value [config_generic 0 "$mpi,$input" config $help_text "choice" 0 "1+" archs]
         if {$value == -1} {
            wait_for_enter
         } else {
            set config($mpi,$input) $value
         }
         continue
      }

      if {$extra == 4} {
         # versions
         set help_text {"Select if the $mpi versions shall be build if not available: "}
         set yes_no(0) "no"
         set yes_no(1) "yes"
         set value [config_generic 0 "$mpi,$input" config $help_text "choice" 0 "1" yes_no]
         if {$value == -1} {
            wait_for_enter
         } else {
            set config($mpi,$input) $value
         }
         continue
      }

   }

   return 0
}

###
# @brief delete an MPI installation
#
# @param array_name - name of the configuration array
# @param have_name - optionally name of the MPI installation to delete, if not given then one can be selected
##
proc mpi_config_delete_installation {array_name {have_name ""}} {
   upvar $array_name config

   while {1} {
      clear_screen
      puts "\nDelete MPI installation"
      puts "======================="
      config_mpi_show_list config
      puts "\n"
      puts -nonewline "Enter MPI installation/number or return to exit: "
      set mpi [wait_for_enter 1]

      if {[string length $mpi] == 0} {
         break
      }

      if {[string is integer $mpi]} {
         incr mpi -1
         set mpi [lindex $config(mpi_list) $mpi]
      }

      if {[lsearch $config(mpi_list) $mpi] < 0} {
         puts "MPI installation \"$mpi\" not found in list"
         wait_for_enter
         continue
      }

      config_mpi_display_params $mpi config

      puts -nonewline "Delete this MPI installation? (y/n): "
      set input [wait_for_enter 1]
      if {[string length $input] == 0} {
         continue
      }

      if {[string compare $input "y"] == 0} {
         set index [lsearch $config(mpi_list) $mpi]
         set config(mpi_list) [lreplace $config(mpi_list) $index $index]
         foreach param [config_mpi_get_parameters] {
            unset config($mpi,$param)
         }
         wait_for_enter
         continue
      }
   }

   return 0
}

###
# @brief add default MPI installations
#
# This function is called for a new mpi configuration
# to add the MPI installations we support.
#
# @param array_name - name of the configuration array
##
proc config_mpi_add_default_mpi_list {array_name} {
   upvar $array_name config

   # add default MPI installations
   # @todo set the archs list to the cluster's architectures, or to whatever archs we support?
   #       sort out non supported architectures, e.g. solaris
   set mpi "intel-mpi"
   lappend config(mpi_list) $mpi
   set config($mpi,template) "intel-mpi"
   set config($mpi,versions) "2021.15"
   set config($mpi,archs) "lx-amd64"
   set config($mpi,do_build) 0
   set mpi "mpich"
   lappend config(mpi_list) $mpi
   set config($mpi,template) "mpich"
   set config($mpi,versions) "3.4.3 4.1.3 4.2.3 4.3.0"
   set config($mpi,archs) "fbsd-amd64 lx-amd64 ulx-amd64 lx-arm64 lx-ppc64le lx-riscv64 lx-s390x"
   set config($mpi,do_build) 1
   set mpi "mvapich"
   lappend config(mpi_list) $mpi
   set config($mpi,template) "mvapich"
   set config($mpi,versions) "4.0"
   set config($mpi,archs) "fbsd-amd64 lx-amd64 ulx-amd64 lx-arm64 lx-ppc64le lx-riscv64 lx-s390x"
   set config($mpi,do_build) 1
   set mpi "openmpi"
   lappend config(mpi_list) $mpi
   set config($mpi,template) "openmpi"
   set config($mpi,versions) "4.0.5 4.0.7 4.1.1 4.1.8 5.0.7"
   set config($mpi,archs) "fbsd-amd64 lx-amd64 ulx-amd64 lx-arm64 lx-ppc64le lx-riscv64 lx-s390x"
   set config($mpi,do_build) 1

   return 0
}

###
# @brief get the base directory for MPI installations
#
##
proc config_mpi_get_mpi_install_dir {} {
   global mpi_config

   return $mpi_config(mpi_install_dir)
}

###
# @brief get the list of MPI installations
#
##
proc config_mpi_get_mpi_list {} {
   global mpi_config

   return $mpi_config(mpi_list)
}

###
# @brief for a given MPI installation get the template directory
#
# relative to $SGE_ROOT/mpi
#
# @param mpi - name of the MPI installation
##
proc config_mpi_get_mpi_template {mpi} {
   global mpi_config

   if {![info exists mpi_config($mpi,template)]} {
      return ""
   }

   return $mpi_config($mpi,template)
}

###
# @brief get the list of versions for a given MPI installation
#
# @param mpi - name of the MPI installation
##
proc config_mpi_get_mpi_versions {mpi} {
   global mpi_config

   if {![info exists mpi_config($mpi,versions)]} {
      return ""
   }

   return $mpi_config($mpi,versions)
}

###
# @brief get the list of architectures we support for a specific MPI
#
# @param mpi - name of the MPI installation
##
proc config_mpi_get_mpi_archs {mpi} {
   global mpi_config

   if {![info exists mpi_config($mpi,archs)]} {
      return ""
   }

   return $mpi_config($mpi,archs)
}

###
# @brief return wether we want to build the MPI installation
#
# if it does not exist
#
# @param mpi - name of the MPI installation
##
proc config_mpi_get_mpi_do_build {mpi} {
   global mpi_config

   if {![info exists mpi_config($mpi,do_build)]} {
      return ""
   }

   return $mpi_config($mpi,do_build)
}

###
# @brief configure the PE for the MPI installation
#
# @param mpi - name of the MPI installation
##
proc mpi_configure_pe {mpi} {
   get_current_cluster_config_array ts_config

   set ret 1

   set template [config_mpi_get_mpi_template $mpi]
   if {[string equal $template ""]} {
      ts_log_severe "no template for $mpi found"
      set ret 0
   }

   if {$ret} {
      # verify if the PE already exists
      set pe_name "$template.pe"
      get_pe_list pe_list
      if {[lsearch -exact $pe_list $pe_name] >= 0} {
         ts_log_fine "PE $pe_name already exists"
         return 1
      }
   }

   if {$ret} {
      set pe_template "$ts_config(product_root)/mpi/$template/$pe_name"
      set output [start_sge_bin "qconf" "-Ap $pe_template"]
      if {$prg_exit_state != 0} {
         ts_log_severe "failed to create PE $pe_template: $output"
         set ret 0
      }
   }

   if {$ret} {
      set output [start_sge_bin "qconf" "-aattr queue pe_list $pe_name mpi.q"]
      if {$prg_exit_state != 0} {
         ts_log_severe "failed to add PE $pe_name to queue mpi.q: $output"
         set ret 0
      }
   }

   return $ret
}

###
# @brief configure the checkpointing environment for the MPI example
#
##
proc mpi_configure_ckpt {} {
   get_current_cluster_config_array ts_config

   set ret 1

   set ckpt_template "$ts_config(product_root)/mpi/examples/testmpi.ckpt"
   set output [start_sge_bin "qconf" "-Ackpt $ckpt_template"]
   if {$prg_exit_state != 0} {
      ts_log_severe "failed to create CKPT $ckpt_template: $output"
      set ret 0
   }

   if {$ret} {
      set output [start_sge_bin "qconf" "-aattr queue ckpt_list testmpi.ckpt mpi.q"]
      if {$prg_exit_state != 0} {
         ts_log_severe "failed to add CKPT testmpi.ckpt to queue mpi.q: $output"
         set ret 0
      }
   }

   return $ret
}

###
# @brief get the list of architectures we can test for a given MPI installation
#
# Determines a list of architectures from the architectures supported by the MPI
# and the architectures of the cluster nodes.
#
# @param mpi - name of the MPI installation
##
proc mpi_get_arch_list {mpi} {
   get_current_cluster_config_array ts_config

   # get the list of architectures for this mpi from the configuration
   set mpi_archs [config_mpi_get_mpi_archs $mpi]

   # gather all architectures of the cluster nodes
   # which are in the list of architectures for this mpi
   set archs {}
   foreach node $ts_config(execd_nodes) {
      set arch [resolve_arch $node]
      if {[lsearch -exact $mpi_archs $arch] >= 0} {
         lappend archs $arch
      }
   }

   return [lsort -unique $archs]
}

###
# @brief make sure the MPI installation is available
#
# This function will check if the MPI installation is available
# and if not it will build it, unless the build is disabled in the configuration.
#
# @param mpi - name of the MPI installation
# @param version - version of the MPI installation
# @param archs - list of architectures to check
##
proc mpi_check_build {mpi version archs} {
   set ret 1

   set base_dir [config_mpi_get_mpi_install_dir]
   foreach arch $archs {
      set install_dir "$base_dir/$mpi-$version/$arch"
      if {[file exists $install_dir]} {
         ts_log_fine "MPI installation directory $install_dir already exists"
         continue
      }

      set do_build [config_mpi_get_mpi_do_build $mpi]
      if {$do_build == 0} {
         ts_log_config "MPI installation directory $install_dir does not exist and build is disabled"
         set ret 0
         break
      }

      # build the MPI installation
      set ret [mpi_build_install $mpi $version $arch $install_dir]
      if {$ret == 0} {
         break
      }
   }

   return $ret
}

###
# @brief build and install a specific MPI installation
#
# @param mpi - name of the MPI installation
# @param version - version of the MPI installation
# @param arch - architecture to build for
# @param install_dir - directory to install the MPI installation
##
proc mpi_build_install {mpi version arch install_dir} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set ret 1

   set template [config_mpi_get_mpi_template $mpi]
   set build_script "$ts_config(product_root)/mpi/$template/build.sh"
   set build_host [compile_search_compile_host $arch]
   if {$build_host == "none"} {
      ts_log_severe "no compile host found for architecture $arch"
      set ret 0
   }

   if {$ret} {
      # build in a local tmp directory
      set dir [get_tmp_directory_name $build_host "build" "tmp" 1]
      remote_file_mkdir $build_host $dir

      set id [open_remote_spawn_process $build_host $CHECK_USER $build_script "$version $install_dir" 0 $dir "" 0]
      if {$id == ""} {
         ts_log_severe "failed to start build process on $build_host"
         set ret 0
      }
   }

   if {$ret} {
      set spawn_id [lindex $id 1]
      set timeout 300
      set done 0
      set exit_status -1
      expect {
         full_buffer {
            ts_log_severe "full buffer: $expect_out(buffer)"
            set ret 0
         }
         eof {
            ts_log_severe "eof"
            set ret 0
         }
         timeout {
            ts_log_severe "timeout"
            set ret 0
         }
         "?*\n" {
            foreach line [split $expect_out(buffer) "\n"] {
               set line [string trim $line]
               if {$line != ""} {
                  ts_log_fine $line
                  if {[string match "_exit_status_:(*)*" $line]} {
                     ts_log_fine "found exit status in line: $line"
                     set exit_status [get_string_value_between "_exit_status_:(" ")" $line]
                     ts_log_fine "exit status: $exit_status"
                     set done 1
                     break
                  }
               }
            }
            if {!$done} {
               exp_continue
            }
         }
      }

      close_spawn_process $id

      if {$exit_status != 0} {
         ts_log_severe "failed to build MPI installation: exit status was $exit_status"
         set ret 0
      }
   }

   return $ret
}

###
# @brief build the example application for a specific MPI installation
#
# @param mpi - name of the MPI installation
# @param version - version of the MPI installation
# @param arch - architecture to build for
# @param dir - directory to build the example application in
##
proc mpi_build_example {mpi version arch dir} {
   get_current_cluster_config_array ts_config
   global CHECK_USER

   set ret 1

   set build_script "$ts_config(product_root)/mpi/examples/build.sh"
   set build_host [compile_search_compile_host $arch]
   if {$build_host == "none"} {
      ts_log_severe "no compile host found for architecture $arch"
      set ret 0
   }

   if {$ret} {
      set base_dir [config_mpi_get_mpi_install_dir]
      set install_dir "$base_dir/$mpi-$version/$arch"
      set myenv(MPIR_HOME) $install_dir

      # we build in a tmp directory - wait for it to be available
      if {[wait_for_remote_dir $build_host $CHECK_USER $dir] != 0} {
         set ret 0
      }
   }

   if {$ret} {
      ts_log_fine "building example application for architecture $arch in $dir"
      set output [start_remote_prog $build_host $CHECK_USER $build_script $arch prg_exit_state 60 0 $dir myenv 1 0]
      if {$prg_exit_state != 0} {
         ts_log_severe "failed to build example application: $output"
         set ret 0
      }
   }

   return $ret
}

