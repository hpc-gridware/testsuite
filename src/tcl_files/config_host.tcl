#___INFO__MARK_BEGIN__
##########################################################################
#
#  The Contents of this file are made available subject to the terms of
#  the Sun Industry Standards Source License Version 1.2
#
#  Sun Microsystems Inc., March, 2001
#
#
#  Sun Industry Standards Source License Version 1.2
#  The contents of this file are subject to the Sun Industry Standards
#  Source License Version 1.2 (the "License"); You may not use this file
#  except in compliance with the License. You may obtain a copy of the
#  License at http://gridengine.sunsource.net/Gridengine_SISSL_license.html
#
#  Software provided under this License is provided on an "AS IS" basis,
#  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
#  WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
#  MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
#  See the License for the specific provisions governing your rights and
#  obligations concerning the Software.
#
#  The Initial Developer of the Original Code is: Sun Microsystems, Inc.
#
#  Copyright: 2001 by Sun Microsystems, Inc.
#
#  All Rights Reserved.
#
#  Portions of this software are Copyright (c) 2024 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__


global ts_host_config               ;# new testsuite host configuration array
global actual_ts_host_config_version      ;# actual host config version number
set    actual_ts_host_config_version "1.17"

if {![info exists ts_host_config]} {
   # ts_host_config defaults
   set parameter "version"
   set ts_host_config($parameter)            "$actual_ts_host_config_version"
   set ts_host_config($parameter,desc)       "Testuite host configuration setup"
   set ts_host_config($parameter,default)    "$actual_ts_host_config_version"
   set ts_host_config($parameter,setup_func) ""
   set ts_host_config($parameter,onchange)   "stop"
   set ts_host_config($parameter,pos)        1

   set parameter "hostlist"
   set ts_host_config($parameter)            ""
   set ts_host_config($parameter,desc)       "Testsuite cluster host list"
   set ts_host_config($parameter,default)    ""
   set ts_host_config($parameter,setup_func) "host_config_$parameter"
   set ts_host_config($parameter,onchange)   "install"
   set ts_host_config($parameter,pos)        4

   set parameter "NFS-ROOT2NOBODY"
   set ts_host_config($parameter)            ""
   set ts_host_config($parameter,desc)       "NFS shared directory with root to nobody mapping"
   set ts_host_config($parameter,default)    ""
   set ts_host_config($parameter,setup_func) "host_config_$parameter"
   set ts_host_config($parameter,onchange)   "install"
   set ts_host_config($parameter,pos)        2

   set parameter "NFS-ROOT2ROOT"
   set ts_host_config($parameter)            ""
   set ts_host_config($parameter,desc)       "NFS shared directory with root read/write rights"
   set ts_host_config($parameter,default)    ""
   set ts_host_config($parameter,setup_func) "host_config_$parameter"
   set ts_host_config($parameter,onchange)   "install"
   set ts_host_config($parameter,pos)        3
}

#****** config_host/host_config_hostlist() *************************************
#  NAME
#     host_config_hostlist() -- host configuration setup
#
#  SYNOPSIS
#     host_config_hostlist { only_check name config_array } 
#
#  FUNCTION
#     Testsuite host configuration setup - called from verify_host_config()
#
#  INPUTS
#     only_check   - 0: expect user input
#                    1: just verify user input
#     name         - option name (in ts_host_config array)
#     config_array - config array name (ts_host_config)
#
#  SEE ALSO
#     check/setup_host_config()
#     check/verify_host_config()
#*******************************************************************************
proc host_config_hostlist { only_check name config_array } {
   global CHECK_USER

   upvar $config_array config

   set description   $config($name,desc)

   set local_host [gethostname]

   if {$only_check == 0} {
      set not_ready 1
      while {$not_ready} {
         clear_screen
         puts "----------------------------------------------------------"
         puts "Global host configuration setup"
         puts "----------------------------------------------------------"
         puts "\n    hosts configured: [llength $config(hostlist)]"
         host_config_hostlist_show_hosts config
         puts "\n\n(1)  add host"
         puts "(2)  edit host"
         puts "(3)  delete host"
         puts "(4)  try nslookup scan"
         puts "(10) exit setup"
         puts -nonewline "> "
         set input [ wait_for_enter 1]
         switch -- $input {
            1 {
               set result [host_config_hostlist_add_host config]
               if { $result != 0 } { wait_for_enter }
               }
            2 {
               set result [host_config_hostlist_edit_host config]
               if { $result != 0 } { wait_for_enter }
               }
            3 {
               set result [host_config_hostlist_delete_host config]
               if { $result != 0 } { wait_for_enter }
               }
            10 { set not_ready 0 }
            4 {
               set result [start_remote_prog $local_host $CHECK_USER "nslookup" $local_host prg_exit_state 60 0 "" "" 1 0]
               if {$prg_exit_state == 0} {
                  set pos1 [string first $local_host $result]
                  set ip [string range $result $pos1 end]
                  set pos1 [string first ":" $ip]
                  incr pos1 1
                  set ip [string range $ip $pos1 end]
                  set pos1 [string last "." $ip]
                  incr pos1 -1
                  set ip [string range $ip 0 $pos1]
                  set ip [string trim $ip]
                  ts_log_fine "ip: $ip"

                  for {set i 1} {$i <= 254} {incr i 1} {
                     set ip_run "$ip.$i"
                     puts -nonewline "\r$ip_run"
                     set result [start_remote_prog $local_host $CHECK_USER "nslookup" $ip_run prg_exit_state 25 0 "" "" 1 0]
                     set pos1 [string first "Name:" $result]   
                     if {$pos1 >= 0} {
                        incr pos1 5
                        set name [string range $result $pos1 end]
                        set pos1 [string first "." $name]
                        incr pos1 -1
                        set name [string range $name 0 $pos1]
                        set name [string trim $name]
                        ts_log_fine "\nHost: $name"
                        set result [host_config_hostlist_add_host config $name]
                     }
                  }
               }
               wait_for_enter
            }
         } 
      }
   }

   # check host configuration
   ts_log_finest "host_config_hostlist:"
   foreach host $config(hostlist) { ts_log_finest "      host: $host" }

   return $config(hostlist)
}

#****** config_host/host_config_NFS-ROOT2NOBODY() ******************************
#  NAME
#     host_config_NFS-ROOT2NOBODY() -- nfs spooling dir setup
#
#  SYNOPSIS
#     host_config_NFS-ROOT2NOBODY { only_check name config_array } 
#
#  FUNCTION
#     NFS directory which is mounted with root to user nobody mapping setup
#     - called from verify_host_config()
#
#  INPUTS
#     only_check   - 0: expect user input
#                    1: just verify user input
#     name         - option name (in ts_host_config array)
#     config_array - config array name (ts_config)
#
#  SEE ALSO
#     check/setup_host_config()
#     check/verify_host_config()
#*******************************************************************************
proc host_config_NFS-ROOT2NOBODY { only_check name config_array } {

   upvar $config_array config

   set help_text {  "Specify a NFS shared directory where the root"
                    "user is mapped to user nobody, or press >RETURN< to"
                    "use the default value." }

   return [config_generic $only_check $name config $help_text "directory" 0]
}

#****** config_host/host_config_NFS-ROOT2ROOT() ********************************
#  NAME
#     host_config_NFS-ROOT2ROOT() -- nfs spooling dir setup
#
#  SYNOPSIS
#     host_config_NFS-ROOT2ROOT { only_check name config_array } 
#
#  FUNCTION
#     NFS directory which is mounted with root to user root mapping setup 
#     - called from verify_host_config()
#
#  INPUTS
#     only_check   - 0: expect user input
#                    1: just verify user input
#     name         - option name (in ts_host_config array)
#     config_array - config array name (ts_config)
#
#  SEE ALSO
#     check/setup_host_config()
#     check/verify_host_config()
#*******************************************************************************
proc host_config_NFS-ROOT2ROOT { only_check name config_array } {

   upvar $config_array config

   set help_text {  "Specify a NFS shared directory where the root"
                    "user is NOT mapped to user nobody and has r/w access,"
                    "or press >RETURN< to use the default value." }

   return [config_generic $only_check $name config $help_text "directory" 0]
}

#****** config_host/host_config_hostlist_show_hosts() **************************
#  NAME
#     host_config_hostlist_show_hosts() -- show host in host configuration
#
#  SYNOPSIS
#     host_config_hostlist_show_hosts { array_name } 
#
#  FUNCTION
#     Print hosts
#
#  INPUTS
#     array_name - ts_host_config
#
#  RESULT
#     the list of configured hosts
#
#  SEE ALSO
#     check/setup_host_config()
#     check/verify_host_config()
#     check/host_config_hostlist_show_compile_hosts()
#     config_host/config_display_hosts()
#*******************************************************************************
proc host_config_hostlist_show_hosts {array_name} {

   upvar $array_name config

   array set hostlist { }
   host_config_get_hostlist config hostlist

   puts "\nHost list:\n"
   if {[array size hostlist] == 0} {
      puts "no hosts configured"
      return ""
   }

   set result [config_assign_indexes hostlist indexes]
   if { $result == -1 } { return "" }

   config_display_hosts hostlist indexes

   set hosts ""
   foreach ind [lsort -integer [array names indexes]] {
      lappend hosts $indexes($ind)
   }

   return $hosts
}  

#****** config_host/host_config_get_host_parameters() **************************
#  NAME
#     host_config_get_host_parameters() -- get the list of host parameters
#
#  SYNOPSIS
#     host_config_get_host_parameters { } 
#
#  FUNCTION
#     get the list of all parameters needed to configure a host
#
#  RESULT
#     the list of host parameters
#
#*******************************************************************************
proc host_config_get_host_parameters { } {
   global ts_config

   set params ""
   lappend params expect
   lappend params vim
   lappend params tar
   lappend params gzip
   lappend params ssh
   lappend params loadsensor
   lappend params processors
   lappend params spooldir
   lappend params arch,62
   lappend params arch,80
   lappend params arch,90
   lappend params arch,91
   lappend params compile,62
   lappend params compile,80
   lappend params compile,90
   lappend params compile,91
   lappend params doc_compile,62
   lappend params doc_compile,80
   lappend params doc_compile,90
   lappend params doc_compile,91
   lappend params java_compile,62
   lappend params java_compile,80
   lappend params java_compile,90
   lappend params java_compile,91
   lappend params compile_time
   lappend params response_time
   lappend params fr_locale
   lappend params ja_locale
   lappend params zh_locale
   lappend params zones
   lappend params send_speed
   lappend params remote_timeout_factor

   return $params
}

proc host_conf_get_host_defaults {varname} {
   upvar $varname conf
   set conf(host)                   "hostname"
   set conf(arch,62)                "unsupported"
   set conf(arch,80)                "unsupported"
   set conf(arch,90)                "unsupported"
   set conf(compile,62)             0
   set conf(compile,80)             0
   set conf(compile,90)             0
   set conf(doc_compile,62)         0
   set conf(doc_compile,80)         0
   set conf(doc_compile,90)         0
   set conf(java_compile,62)        0
   set conf(java_compile,80)        0
   set conf(java_compile,90)        0
   set conf(expect)                 "/usr/bin/expect"
   set conf(vim)                    "/usr/bin/vim"
   set conf(tar)                    "/usr/bin/tar"
   set conf(gzip)                   "/usr/bin/gzip"
   set conf(ssh)                    "/usr/bin/ssh"
   set conf(loadsensor)             ""
   set conf(processors)             "1"
   set conf(spooldir)               "/usr/local/testsuite"
   set conf(response_time)          "1"
   set conf(fr_locale)              ""
   set conf(ja_locale)              ""
   set conf(zh_locale)              ""
   set conf(zones)                  ""
   set conf(send_speed)             "0.0"
   set conf(remote_timeout_factor)  "1"
}

#****** config_host/host_config_display_host_params() **************************
#  NAME
#     host_config_display_host_params() -- display the host configuration
#
#  SYNOPSIS
#     host_config_display_host_params { host config_array } 
#
#  FUNCTION
#     display the list of host parameters and it's values
#
#  INPUTS
#     host         - the host from host configuration
#     config_array - ts_host_config
#
#*******************************************************************************
proc host_config_display_host_params { host config_array } {
   global ts_config

   upvar $config_array config

   set max_length 0

   puts "\n"
   foreach param "[host_config_get_host_parameters] host" {
      if {[string length $param] > $max_length} {
         set max_length [string length $param]
      }
   }

   puts "   host      [get_spaces [expr ( $max_length - [ string length host ] ) ]] : $host"

   set arch [host_conf_get_arch $host config]
   puts "   arch      [get_spaces [expr ( $max_length - [ string length arch ] ) ]] : $arch"

   if {[host_conf_is_compile_host $host config]} {
      set value "compile host for \"$arch\" binaries ($ts_config(gridengine_version))"
   } else {
      set value "not a compile host"
   }
   puts "   compile      [get_spaces [expr ( $max_length - [ string length compile ] ) ]] : $value"

   if {[host_conf_is_doc_compile_host $host config]} {
      set value "compile host for documentation ($ts_config(gridengine_version))"
   } else {
      set value "not a doc compile host"
   }
   puts "   doc_compile      [get_spaces [expr ( $max_length - [ string length doc_compile ] ) ]] : $value"

   if {[host_conf_is_java_compile_host $host config]} {
      set value "compile host for java ($ts_config(gridengine_version))"
   } else {
      set value "not a java compile host"
   }
   puts "   java_compile      [get_spaces [expr ( $max_length - [ string length java_compile ] ) ]] : $value"

   foreach param [host_config_get_host_parameters] {
      set space "     [get_spaces [expr ( $max_length - [ string length $param ] ) ]]"
      set value ""
      set disp_param $param
      switch -glob $param {
         arch* { continue }
         *compile* { continue }
         default { set value $config($host,$param) }
      }
      puts "   $disp_param $space : $value"
   }
   puts "\n"
}

#****** config_host/config_display_hosts() *************************************
#  NAME
#     config_display_hosts() -- Display the list of hosts
#
#  SYNOPSIS
#     config_display_hosts { host_list choice_index {selected ""} }
#
#  FUNCTION
#     This function is used to display configured hosts in lab. The order
#     is given by indexes in host_index.
#
#  INPUTS
#     host_list         - The array of configured hosts to display
#     {host_index ""}   - the array of indexes and it's assigned hosts
#                         see config_assign_indexes() for more information
#     {selected ""}     - the list of selected values
#                         use this variable to mark it in the list
#     {null_value "none"} - see config_choose_value() for more information
#     {disp_usage 0}    - 1 to display detail of host usages in configurations
#                         0 to hide it
#
#  SEE ALSO
#      config/config_choose_value()
#      config/config_display_list()
#      config_host/host_config_get_hostlist()
#*******************************************************************************
proc config_display_hosts { host_list host_index {selected ""} {null_value "none"} {disp_usage 0} } {

   upvar $host_list hosts
   upvar $host_index indexes
   
   if { [array size hosts] == 1 && [lsearch [array names hosts] "new"] < 0 } {
      config_display_list hosts indexes $selected $null_value
      return
   }

   array set archs { }
   set comp_c ""
   set comp_doc ""
   set comp_java ""
   set max_length 0
   foreach host [lsort [array names hosts]] {
      if { [string compare $host "new"] == 0 } { continue }
      if { [string compare $host "usage"] == 0 } { continue }
      if { [string compare $host $null_value] == 0 } { continue }
      if {[string length $host] > $max_length} { set max_length [string length $host] }
      set host_info [split $hosts($host) "|"]
      set is_arch_name 1
      set usage ""
      set max_arch_length 0
      # format: arch|[c]|[java]|[(usage1)|(usage2)|...]
      foreach elem $host_info {
         if { $is_arch_name == 1 } {
            set arch $elem
            set is_arch_name 0
            if {[string length $arch] > $max_arch_length} { set max_arch_length [string length $arch] }
         } elseif { [string compare $elem java] == 0 } {
            lappend comp_java $host
         } elseif { [string compare $elem doc] == 0 } {
            lappend comp_doc $host
         } elseif { [string compare $elem c] == 0 } {
            lappend comp_c "$arch|$host"
         } else { append usage "($elem)" }
      }
      if { [info exists archs($arch)] } {
         lappend archs($arch) $host
      } else { set archs($arch) $host }
      if { [string compare $usage ""] != 0 } {
         if { [info exists archs($arch,$host)] } {
            lappend archs($arch,$host) $usage
         } else { set archs($arch,$host) $usage }
      }
   }
   set index 1
   puts "doc compile host: $comp_doc\n"
   puts "java compile host: $comp_java\n"
   set gap 0
   foreach arch [lsort [array names archs]] {
      if { [set ind [string first "," $arch]] >= 0 } {
         if { $disp_usage == 1 } {
            # display host usages in configuration
            incr ind 1
            puts "   ---> [string range $arch $ind end]: $archs($arch)"
            set gap 1
         }
      } else {
         if { $gap == 1 } { puts "" } else { set gap 0 }
         # display compile hosts and host lists
         set comp_host "none"
         foreach comp $comp_c {
            if { [string match "$arch|*" $comp] == 1 } {
               set ind [string first "|" $comp]
               incr ind 1
               set comp_host [string range $comp $ind end]
               break
            }
         }

         set count 0         
         # display host list
         set host_disp "$arch:[get_spaces [expr ( $max_arch_length - [string length $arch] ) ]]"
         set arch_space "[get_spaces [string length $host_disp]]"
         foreach host $archs($arch) {
            if { $count == 4 } {
               puts $host_disp
               set host_disp $arch_space
               set count 0
            }
            set space "[get_spaces [expr ( $max_length - [string length $host] ) ]]"
            foreach indx [array names indexes] {
               if { [string compare $indexes($indx) $host] == 0 } {
                  set index $indx
                  break
               }
            }
            if { [string compare $host $comp_host] == 0 } {
               set comph "(cc)"
            } else { set comph "    " }
            if { [info exists archs($arch,$host)] } {
               # the host is used, mark it
               if { $index <= 9 } { set ind " \[$index\]" } else { set ind "\[$index\]" }
            } else {
               if { $index <= 9 } { set ind "  $index)" } else { set ind " $index)" }
            }
            if { [info exists selected] && [ lsearch $selected $host ] >= 0 } {
               set sel "*"                             ;# mark the selected host
            } else { set sel " " }
            append host_disp " $sel$ind $host $comph$space"
            incr index 1
            incr count 1
         }
         puts "$host_disp"
      }
   }

   set count [array size indexes]
   if { [lsearch -exact [array names hosts] "new"] >= 0 } { incr index -1 }
   if { [lsearch -exact [array names hosts] "usage"] >= 0 } { incr index -1 }
   if { [string compare $indexes($count) $null_value] == 0 } {
      if { [info exists selected] && [ lsearch $selected $null_value ] >= 0 } {
         set sel "*"                                         ;# mark if selected
      } else { set sel " " }
      puts "\n$arch_space $sel $count) $null_value"
   }

}

#****** config_host/host_config_get_hostlist() *********************************
#  NAME
#     host_config_get_hostlist() -- get the list of host in host configuration
#
#  SYNOPSIS
#     host_config_get_hostlist { array_name result_array {all 1} } 
#
#  FUNCTION
#     Gets the array of hosts with the information if it is compile host
#
#  INPUTS
#     config_array - ts_host_config
#     result_array - result array
#     { all 1 }    - 1 all hosts
#                  - 0 only supported hosts with the configured SGE version
#
#  RESULT
#     the list of hosts
#
#  SEE ALSO
#     config_host/host_conf_get_arch()
#     config_host/host_conf_is_compile_host()
#*******************************************************************************
proc host_config_get_hostlist { config_array result_array { all 1 } } {

   upvar $config_array config
   upvar $result_array host_list

   if {[llength $config(hostlist)] == 0} { return "" }

   foreach host $config(hostlist) {
      set arch [host_conf_get_arch $host config]
      if { $all == 0 && [string compare "$arch" "unsupported"] == 0 } {
         continue 
      }
      if {[host_conf_is_compile_host $host config]} { append arch "|c" }
      if {[host_conf_is_doc_compile_host $host config]} { append arch "|doc" }
      if {[host_conf_is_java_compile_host $host config]} { append arch "|java" }
      set host_list($host) $arch
   }

   return [array names host_list]
}

#****** config_host/host_config_hostlist_get_architectures() *******************
#  NAME
#     host_config_hostlist_get_architectures() -- get architectures
#
#  SYNOPSIS
#     host_config_hostlist_get_architectures { array_name } 
#
#  FUNCTION
#     This procedure gets the list of architectures and compile host for each
#     architecture
#
#  INPUTS
#     config_array - ts_host_config array
#     result_array - the result array
#
#  SEE ALSO
#     config_host/host_conf_is_compile_host()
#     config_host/host_conf_get_arch()
#*******************************************************************************
proc host_config_hostlist_get_architectures { config_array result_array } {
  
   upvar $config_array config
   upvar $result_array arch_list

   if {[llength $config(hostlist)] == 0} { return }

   foreach host $config(hostlist) {
      if {[host_conf_is_compile_host $host config]} {
         set arch [host_conf_get_arch $host config]
         if {[string compare $arch "unsupported"] != 0} {
            set arch_list($arch) "$host"
         }
      }
   }

   return
}

#****** config_host/host_config_hostlist_add_host() ****************************
#  NAME
#     host_config_hostlist_add_host() -- add host to host configuration
#
#  SYNOPSIS
#     host_config_hostlist_add_host { array_name { have_host "" } } 
#
#  FUNCTION
#     This procedure is used to add a host to the testsuite host configuration 
#
#  INPUTS
#     array_name       - ts_host_config
#     { have_host "" } - if not "": add this host without questions
#
#  SEE ALSO
#     check/setup_host_config()
#     check/verify_host_config()
#*******************************************************************************
proc host_config_hostlist_add_host {array_name {have_host ""}} {
   global ts_config
   global CHECK_USER

   upvar $array_name config
  
   if {$have_host == ""} {
      clear_screen
      puts "\nAdd host to global host configuration"
      puts "====================================="
      host_config_hostlist_show_hosts config
      puts -nonewline "\nEnter new hostname: "
      set new_host [wait_for_enter 1]
   } else { set new_host $have_host }

   if {[string length $new_host] == 0} {
      puts "no hostname entered"
      return -1
   }
     
   if {[lsearch $config(hostlist) $new_host] >= 0} {
      puts "host \"$new_host\" is already in list"
      return -1
   }
   
   set time [timestamp]
   set result [start_remote_prog $new_host $CHECK_USER "echo" "\"hello $new_host\"" prg_exit_state 12 0 "" "" 1 0]
   if {$prg_exit_state != 0} {
      if {$have_host == ""} {
         puts "connect timeout error\nEnter a timeout value > 12 or press return to abort"
         set result [ wait_for_enter 1 ]
         if {[string length $result] == 0  || $result < 12} {
            puts "aborting ..."
            return -1
         }
         set config($new_host,remote_timeout_factor) 5 ;# host might be slow, increase all timeouts by factor 5
         set result [start_remote_prog $new_host $CHECK_USER "echo" "\"hello $new_host\"" prg_exit_state $result 0 "" "" 1 0]
      }
   }
   
   if {$prg_exit_state != 0} {
      puts "rlogin to host $new_host doesn't work correctly"
      return -1
   }
   if {[string first "hello $new_host" $result] < 0} {
      puts "$result"
      puts "echo \"hello $new_host\" doesn't work"
      return -1
   }

   set arch [resolve_arch $new_host]

   lappend config(hostlist) $new_host

   array set vars {}
   foreach prg "expect vim tar gzip ssh" {
      set prg_bin [start_remote_prog $new_host $CHECK_USER "$ts_config(testsuite_root_dir)/scripts/mywhich.sh" "$prg" prg_exit_state 12 0 "" "" 1 0]
      if {$prg_exit_state != 0} { set prg_bin "" }
      set vars(${prg}_bin) $prg_bin
   }
   
   foreach param [host_config_get_host_parameters] {
      switch -glob $param {
         arch* {
            set config($new_host,$param) "unsupported"
            if { [string compare $param "arch,$ts_config(gridengine_version)"] == 0 } {
               set config($new_host,$param) $arch
            } 
         }
         *compile* { set config($new_host,$param) 0 }
         response_time { set config($new_host,$param) [ expr ( [timestamp] - $time ) ] }
         send_speed { set config($new_host,$param) 0.0 }
         processors { set config($new_host,$param) 1 }
         remote_timeout_factor { set config($new_host,$param) 1 }
         default {
            if { [info exists vars(${param}_bin)] } {
               set config($new_host,$param) [string trim $vars(${param}_bin)]
            } else { set config($new_host,$param) "" }
         }
      }
   }

   wait_for_enter

   if {$have_host == ""} { host_config_hostlist_edit_host config $new_host }

   return 0   
}

#****** config_host/host_config_hostlist_edit_host() ***************************
#  NAME
#     host_config_hostlist_edit_host() -- edit host in host configuration
#
#  SYNOPSIS
#     host_config_hostlist_edit_host { array_name { has_host "" } } 
#
#  FUNCTION
#     This procedure is used for host edition in host configuration
#
#  INPUTS
#     array_name      - ts_host_config
#     { has_host "" } - if not "": just edit this host
#
#  SEE ALSO
#     config_host/host_config_hostlist_show_hosts()
#     check/setup_host_config()
#     check/verify_host_config()
#*******************************************************************************
proc host_config_hostlist_edit_host {array_name {has_host ""}} {
   global ts_config ts_host_config CHECK_USER

   upvar $array_name config

   set goto 0
   if {$has_host != ""} { set goto $has_host } 

   while {1} {
      clear_screen
      puts "\nEdit host in global host configuration"
      puts "======================================"
      set hostlist [host_config_hostlist_show_hosts config]
      puts -nonewline "\nEnter hostname/number or return to exit: "
      if {$goto == 0} {
         set host [wait_for_enter 1]
         set goto $host
      } else {
         set host $goto
         ts_log_fine $host
      }
 
      if {[string length $host] == 0} { break }
     
      if {[string is integer $host]} {
         incr host -1
         set host [lindex $hostlist $host]
      }

      if {[lsearch $hostlist $host] < 0} {
         puts "host \"$host\" not found in list"
         wait_for_enter
         set goto 0
         continue
      }

      host_config_display_host_params $host config

      puts -nonewline "\n\nEnter category to edit or hit return to exit > "
      set input [wait_for_enter 1]
      if {[string length $input] == 0 } {
         set goto 0
         continue
      }

      set help_text ""
      lappend help_text "Enter new $input value:"
      set check_type "string"
      set allow_null 1
      set count 1
      set isfile 0
      set isdir 0
      set islocale 0
      set check_zones 0
      array set add_params { }
      switch -- $input {
         "expect" -
         "vim" -
         "tar" -
         "gzip" -
         "ssh" -
         "loadsensor" { 
            set isfile 1
         }
         "spooldir" {
            set isdir 1 
         }
         "compile" -
         "doc_compile" -
         "java_compile" { 
            set help_text ""
            lappend help_text "Use this host for $input of $ts_config(gridengine_version) version?"
            set input "$input,$ts_config(gridengine_version)"
            set check_type "choice"
            set allow_null 0
            set add_params(screen_clear) 0
            set choices(1) "yes"
            set choices(0) "no"
         }
         "zones" { 
            set help_text { "Enter a space separated list of zones: " }
            set check_zones 1
            set count 0
         }
         "fr_locale" -
         "ja_locale" -
         "zh_locale" { 
            set help_text { "INFO:"
                            "Enter an environment list to get localized output on that host!"
                            "e.g.: LANG=fr_FR.ISO8859-1 LC_MESSAGES=fr"
                            "Enter new locale: " }
            set islocale 1
         }
         "processors" -
         "send_speed" {
         }
         "remote_timeout_factor" {
            set help_text { "Enter a factor"
                            "by which all timeouts in the remote procedures"
                            "(e.g. open_remote_spawn_process() or start_remote_prog()"
                            "are scaled. Default is 1 (no scaling)" }

         }
         "arch" {
            set input "arch,$ts_config(gridengine_version)"
            set help_text { "Enter a valid architecture name"
                            "or \"unsupported\", if the hosts architecture" }
            lappend help_text "is not supported on Cluster Scheduler (Grid Engine) $ts_config(gridengine_version) systems:"
         }
         "host" -
         "compile_time" -
         "response_time" {
            puts "Setting \"$input\" is not allowed"
            wait_for_enter
            continue
         }
         default {
            puts "Not a valid category"
            wait_for_enter
            continue
         }
      }

      set value [config_generic 0 "$host,$input" config $help_text $check_type $allow_null $count choices add_params]

      if { $allow_null && $value == "none" } {
         set value ""
                     wait_for_enter
                  continue
               }
      # check for valid file name
      if {$isfile} {
         set result [start_remote_prog $host $CHECK_USER "ls" "$value" prg_exit_state 12 0 "" "" 1 0]
         if {$prg_exit_state != 0} {
            puts $result
            puts "file $value not found on host $host"
            wait_for_enter
            continue
         }
      }
      
      # check for valid directory name
      if {$isdir} {
         set result [start_remote_prog $host $CHECK_USER "cd" "$value" prg_exit_state 12 0 "" "" 1 0]
         if {$prg_exit_state != 0} {
            puts $result
            puts "can't cd to directory $value on host $host"
            wait_for_enter
            continue
         }
      }

      # locale test
      if {$islocale == 1} {
         set mem_it $ts_host_config($host,$input)
         set mem_l10n $ts_config(l10n_test_locale)
       
         set ts_config(l10n_test_locale) [string range $input 0 1]
         set ts_host_config($host,$input) $value

         set test_result [perform_simple_l10n_test ]

         set ts_host_config($host,$input) $mem_it
         set ts_config(l10n_test_locale) mem_l10n

         if {$test_result != 0} {
            puts "l10n errors" 
            wait_for_enter
            continue
         }
         puts "you have to enable l10n in testsuite setup too!"
         wait_for_enter
      }

      # check if zones exist
      if {$check_zones == 1} {
         if {[llength $value] != 0 } {
            set host_error 0
            foreach zone $value {
               set result [start_remote_prog $zone $CHECK_USER "id" "" prg_exit_state 12 0 "" "" 1 0]
               if { $prg_exit_state != 0 } {
                  puts $result
                  puts "can't connect to zone $zone"
                  wait_for_enter
                  set host_error 1
                  break
               }
            }
            if {$host_error} { continue }
         }
      }

      set config($host,$input) $value
      wait_for_enter
      continue
   }
   
   return 0   
}

#****** config_host/host_config_hostlist_delete_host() *************************
#  NAME
#     host_config_hostlist_delete_host() -- delete host from host configuration
#
#  SYNOPSIS
#     host_config_hostlist_delete_host { array_name } 
#
#  FUNCTION
#     This procedure is called to delete a host from host configuration
#
#  INPUTS
#     array_name - ts_host_config
#
#  SEE ALSO
#     config_host/host_config_hostlist_show_hosts()
#     check/setup_host_config()
#     check/verify_host_config()
#*******************************************************************************
proc host_config_hostlist_delete_host { array_name } {
   global ts_config CHECK_USER

   upvar $array_name config

   while {1} {
      clear_screen
      puts "\nDelete host from global host configuration"
      puts "=========================================="
      set hostlist [host_config_hostlist_show_hosts config]
      puts -nonewline "\nEnter hostname/number or return to exit: "
      set host [wait_for_enter 1]
 
      if {[string length $host] == 0} { break }
     
      if {[string is integer $host]} {
         incr host -1
         set host [lindex $hostlist $host]
      }

      if {[lsearch $hostlist $host] < 0} {
         puts "host \"$host\" not found in list"
         wait_for_enter
         continue
      }

      host_config_display_host_params $host config
      
      puts -nonewline "Delete this host? (y/n): "
      set input [wait_for_enter 1]
      if {[string length $input] == 0} { continue }

      if {[string compare $input "y"] == 0} {
         set index [lsearch $config(hostlist) $host]
         set config(hostlist) [lreplace $config(hostlist) $index $index]
         foreach param [host_config_get_host_parameters] {
            unset config($host,$param)
         }
         continue
      }
   }

   return 0   
}

#****** config_host/host_config_add_newhost() **********************************
#  NAME
#     host_config_add_newhost() -- add host to host configuration
#
#  SYNOPSIS
#     host_config_add_newhost { hostname } 
#
#  FUNCTION
#     This procedure is used to add a host to the testsuite global host configuration 
#
#  INPUTS
#     hostname - host name
#
#  SEE ALSO
#     config_host/host_config_hostlist_add_host()
#     config_host/host_config_hostlist_edit_host()
#     config_host/host_config_get_host_parameters()
#     check/save_host_configuration()
#*******************************************************************************
proc host_config_add_newhost { hostname } {
   global ts_config ts_host_config

   set errors 0

   incr errors [host_config_hostlist_add_host ts_host_config $hostname]

   if { $errors == 0 } {

      incr errors [host_config_hostlist_edit_host ts_host_config $hostname]
      incr errors [verify_host_config ts_host_config 1 err_list]

      if { $errors == 0 } {
         incr errors [save_host_configuration $ts_config(host_config_file)]
      } 
      if { $errors != 0 } {
         set index [lsearch $ts_host_config(hostlist) $hostname]
         if { $index >= 0 } {
            set ts_host_config(hostlist) [ lreplace $ts_host_config(hostlist) $index $index ]
         }
         foreach param [host_config_get_host_parameters] {
            if { [info exists ts_host_config($hostname,$param)] } {
               unset ts_host_config($hostname,$param)
            }
         }
      }
   }

   wait_for_enter
   return
}

#****** config_host/verify_host_config() ***************************************
#  NAME
#     verify_host_config() -- verify testsuite host configuration setup
#
#  SYNOPSIS
#     verify_host_config { config_array only_check parameter_error_list 
#     { force_params "" } } 
#
#  FUNCTION
#     This procedure will verify or enter host setup configuration
#
#  INPUTS
#     config_array         - array name with configuration (ts_host_config)
#     only_check           - if 1: don't ask user, just check
#     parameter_error_list - returned list with error information
#     { force_params "" }  - the list of parameters to edit
#                            for allowed values see the configured parameters
#                            in host configuration
#
#  RESULT
#     number of errors
#
#  SEE ALSO
#     check/verify_host_config()
#     check/verify_user_config()
#     check/verify_config()
#*******************************************************************************
proc verify_host_config {config_array only_check parameter_error_list {force_params ""}} {
   global actual_ts_host_config_version be_quiet
   upvar $config_array config
   upvar $parameter_error_list error_list

   set errors 0
   set error_list ""

   if {[info exists config(version)] != 1} {
      puts "Could not find version info in host configuration file"
      lappend error_list "no version info"
      incr errors 1
      return -1
   }

   if {$config(version) != $actual_ts_host_config_version} {
      puts "Host configuration file version \"$config(version)\" not supported."
      puts "Expected version is \"$actual_ts_host_config_version\""
      lappend error_list "unexpected host config file version $config(version)"
      incr errors 1
      return -1
   } else { ts_log_finest "Host Configuration Version: $config(version)" }

   set local_host [gethostname]
   if {$local_host == "unknown"} {
      puts "Could not get local host name" 
      return -1
   }

   if { [lsearch -exact $config(hostlist) $local_host] < 0 } {
      ts_log_warning "Host $local_host doesn't exist in host configuration!"
      if { [lsearch -exact $force_params "hostlist"] < 0 } { lappend force_params "hostlist" }
   }

   set max_pos [get_configuration_element_count config]

   set uninitalized ""
   if {$be_quiet == 0} { puts "" }

   for {set param 1} {$param <= $max_pos} {incr param 1} {
      set par [get_configuration_element_name_on_pos config $param]
      if {$be_quiet == 0} { 
         puts -nonewline "      $config($par,desc) ..."
         ts_log_progress
      }
      if {$config($par) == "" || [lsearch -exact $force_params $par] >= 0 } {
         ts_log_finest "not initialized or forced!"
         lappend uninitalized $param
         if { $only_check != 0 } {
            lappend error_list ">$par< configuration not initialized"
            incr errors 1
         }
      } else {
         set procedure_name  $config($par,setup_func)
         set default_value   $config($par,default)
         set description     $config($par,desc)
         if {[string length $procedure_name] == 0} {
             ts_log_finest "no procedure defined"
         } else {
            if {[info procs $procedure_name] != $procedure_name} {
               ts_log_warning "unknown procedure name: \"$procedure_name\" !!!"
               lappend uninitalized $param

               if {$only_check == 0} { wait_for_enter }
            } else {
               # call procedure only_check == 1
               ts_log_finest "starting >$procedure_name< (verify mode) ..."
               set value [$procedure_name 1 $par config]
               if {$value == -1} {
                  incr errors 1
                  lappend error_list $par 
                  lappend uninitalized $param
                  ts_log_warning "verify error in procedure \"$procedure_name\" !!!"
               } 
            }
         }
      }
      if {$be_quiet == 0} { ts_log_fine "\r      $config($par,desc) ... ok" }
      }

   if {[set count [llength $uninitalized]] != 0 && $only_check == 0} {
      puts "$count parameters are not initialized!"
      puts "Entering setup procedures ..."
      wait_for_enter
      
      foreach pos $uninitalized {
         clear_screen
         set p_name [get_configuration_element_name_on_pos config $pos]
         set procedure_name  $config($p_name,setup_func)
         set default_value   $config($p_name,default)
       
         ts_log_finest "Starting configuration procedure for parameter \"$p_name\" ($config($p_name,pos)) ..."
         set use_default 0
         if {[string length $procedure_name] == 0} {
            ts_log_finest "no procedure defined"
            continue
         } else {
            if {[info procs $procedure_name] != $procedure_name} {
               ts_log_warning "unknown procedure name: \"$procedure_name\" !!!"
               if {$only_check == 0} {wait_for_enter}
               set use_default 1
            }
         } 

         if {$use_default != 0} {
            # check again if we have value ( force flag) 
            if {$config($p_name) == ""} {
               # we have no setup procedure
               if {$default_value != ""} {
                  puts "using default value: \"$default_value\"" 
                  set config($p_name) $default_value 
               } else {
                  puts "No setup procedure and no default value found!!!"
                  if {$only_check == 0} {
                     puts -nonewline "Enter value for parameter \"$p_name\": "
                     set value [wait_for_enter 1]
                     puts "using value: \"$value\"" 
                     set config($p_name) $value
                  }
               }
            }
         } else {
            # call setup procedure ...
            ts_log_finest "starting >$procedure_name< (setup mode) ..."
            set value [$procedure_name 0 $p_name config]
            if {$value != -1} {
               puts "using value: \"$value\"" 
               set config($p_name) $value
            }
         }
         if {$config($p_name) == ""} {
            ts_log_warning "no value for \"$p_name\" !!!"
            incr errors 1
            lappend error_list $p_name
         }
         wait_for_enter
      } 
   }
   return $errors
}

#****** config_host/update_ts_host_config_version() ****************************
#  NAME
#     update_ts_host_config_version() -- used for version update of ts_host_config
#
#  SYNOPSIS
#     update_ts_host_config_version { filename } 
#
#  FUNCTION
#     This procedure is called when the versions of the testsuite host configuration
#     are not equal.
#
#  INPUTS
#     filename - host configuration file
#
#  SEE ALSO
#     check/update_ts_config_version()
#*******************************************************************************
proc update_ts_host_config_version { filename } {
   global actual_ts_host_config_version
   global ts_host_config
   global CHECK_USER

   if { [string compare $ts_host_config(version)  "1.0"] == 0 } {
      puts "\ntestsuite host configuration update from 1.0 to 1.1 ..."

      foreach host $ts_host_config(hostlist) {
         set ts_host_config($host,fr_locale) ""
         set ts_host_config($host,ja_locale) ""
         set ts_host_config($host,zh_locale) ""
      }
      set ts_host_config(version) "1.1"
     
      show_config ts_host_config
      wait_for_enter
      if { [ save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.1"] == 0 } {
      puts "\ntestsuite host configuration update from 1.1 to 1.2 ..."
	
      foreach host $ts_host_config(hostlist) {
         set ts_host_config($host,ssh) ""
      }
      set ts_host_config(version) "1.2"
     
      show_config ts_host_config
      wait_for_enter
      if { [ save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.2"] == 0 } {
      puts "\ntestsuite host configuration update from 1.2 to 1.3 ..."

      foreach host $ts_host_config(hostlist) {
         set ts_host_config($host,java) ""
      }
      set ts_host_config(version) "1.3"
     
      show_config ts_host_config
      wait_for_enter
      if { [ save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.3"] == 0 } {
      puts "\ntestsuite host configuration update from 1.3 to 1.4 ..."

      foreach host $ts_host_config(hostlist) {
         set ts_host_config($host,zones) ""
      }
      set ts_host_config(version) "1.4"
     
      show_config ts_host_config
      wait_for_enter
      if { [ save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.4"] == 0 } {
      puts "\ntestsuite host configuration update from 1.4 to 1.5 ..."

      # insert new parameter after version parameter
      set insert_pos $ts_host_config(version,pos)
      incr insert_pos 1

      # move positions of following parameters for 2 steps
      set new_parameter_cont 2
      set names [array names ts_host_config "*,pos"]
      foreach name $names {
         if { $ts_host_config($name) >= $insert_pos } {
            set ts_host_config($name) [ expr ( $ts_host_config($name) + $new_parameter_cont ) ]
         }
      }

      # parameter 1
      set parameter "NFS-ROOT2NOBODY"
      set ts_host_config($parameter)            ""
      set ts_host_config($parameter,desc)       "NFS shared directory with root to nobody mapping"
      set ts_host_config($parameter,default)    ""
      set ts_host_config($parameter,setup_func) "host_config_$parameter"
      set ts_host_config($parameter,onchange)   "install"
      set ts_host_config($parameter,pos)        $insert_pos

       
      # increment position for the second parameter 
      incr insert_pos 1

      # parameter 2
      set parameter "NFS-ROOT2ROOT"
      set ts_host_config($parameter)            ""
      set ts_host_config($parameter,desc)       "NFS shared directory with root read/write rights"
      set ts_host_config($parameter,default)    ""
      set ts_host_config($parameter,setup_func) "host_config_$parameter"
      set ts_host_config($parameter,onchange)   "install"
      set ts_host_config($parameter,pos)        $insert_pos

 
      # now we have version 1.5
      set ts_host_config(version) "1.5"

      show_config ts_host_config
      wait_for_enter
      if { [ save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.5"] == 0 } {
      puts "\ntestsuite host configuration update from 1.5 to 1.6 ..."

      foreach host $ts_host_config(hostlist) {
         # convert the one architecture string to a version dependent one
         set arch $ts_host_config($host,arch)
         unset ts_host_config($host,arch)
         set ts_host_config($host,arch,53) [host_conf_53_arch $arch]
         set ts_host_config($host,arch,60) [host_conf_60_arch $arch]
         set ts_host_config($host,arch,61) [host_conf_61_arch $arch]

         # we now store compile host property depending on Cluster Scheduler (Grid Engine) version
         # assume our current compile hosts compile for 53, 60, and 61
         if {$ts_host_config($host,compile) == 1} {
            set ts_host_config($host,compile,53) 1
            set ts_host_config($host,compile,60) 1
            set ts_host_config($host,compile,61) 1
         } else {
            set ts_host_config($host,compile,53) 0
            set ts_host_config($host,compile,60) 0
            set ts_host_config($host,compile,61) 0
         }
         unset ts_host_config($host,compile)
      }
      set ts_host_config(version) "1.6"
     
      show_config ts_host_config
      wait_for_enter
      if { [ save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.6"] == 0 } {
      puts "\ntestsuite host configuration update from 1.6 to 1.7 ..."

      foreach host $ts_host_config(hostlist) {
         # convert the java home string to a version dependent one
         puts -nonewline " ... "
         set myenv(EN_QUIET) "1"
         set java15_bin [start_remote_prog $host $CHECK_USER [get_binary_path $host "csh"] "-c \"source /vol2/resources/en_jdk15 ; $ts_config(testsuite_root_dir)/scripts/mywhich.sh java\"" prg_exit_state 12 0 "" myenv 1 0]
         if { $prg_exit_state != 0 } {
            set java15_bin "" 
         }
         set java15_bin [string trim $java15_bin]
         if { ![file isfile $java15_bin] } {
            puts "file not found"
            set java15_bin ""
         }
         puts "setting java15 for host $host to \"$java15_bin\""
         set ts_host_config($host,java15) $java15_bin
      }
      set ts_host_config(version) "1.7"
     
      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.7"] == 0 } {
      puts "\ntestsuite host configuration update from 1.7 to 1.8 ..."

      foreach host $ts_host_config(hostlist) {
         # we now store java compile host property depending on Cluster Scheduler (Grid Engine) version
         set ts_host_config($host,java_compile,53) 0
         set ts_host_config($host,java_compile,60) 0
         set ts_host_config($host,java_compile,61) 0
      }
      set ts_host_config(version) "1.8"
     
      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.8"] == 0 } {
      puts "\ntestsuite host configuration update from 1.8 to 1.9 ..."

      foreach host $ts_host_config(hostlist) {
         # we now expect send speed property - disable send speed
         set ts_host_config($host,send_speed) 0.0
      }
      set ts_host_config(version) "1.9"
     
      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.9"] == 0 } {
      puts "\ntestsuite host configuration update from 1.9 to 1.10 ..."

      # we have to update all version dependent settings from 65 to 61
      foreach host $ts_host_config(hostlist) {
         set ts_host_config($host,arch,61) $ts_host_config($host,arch,65)
         set ts_host_config($host,arch,62) $ts_host_config($host,arch,65)
         unset ts_host_config($host,arch,65)

         set ts_host_config($host,compile,61) $ts_host_config($host,compile,65)
         set ts_host_config($host,compile,62) $ts_host_config($host,compile,65)
         unset ts_host_config($host,compile,65)

         set ts_host_config($host,java_compile,61) $ts_host_config($host,java_compile,65)
         set ts_host_config($host,java_compile,62) $ts_host_config($host,java_compile,65)
         unset ts_host_config($host,java_compile,65)
      }

      set ts_host_config(version) "1.10"

      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if { [string compare $ts_host_config(version)  "1.10"] == 0 } {
      puts "\ntestsuite host configuration update from 1.10 to 1.11 ..."

      # change the one java setting to java14, java15, java16
      foreach host $ts_host_config(hostlist) {
         puts "$host"
         #Remove java from host_config
         puts "---removing java for host $host"
         unset ts_host_config($host,java)
         #Add java 1.4
         set ts_host_config($host,java14) [autodetect_java $host "1.4"]
         #Check if java1.5 is valid
         set java15_bin $ts_host_config($host,java15)
         if { [check_java_version $host $java15_bin "1.5"] != 0 } {
            set ts_host_config($host,java15) [autodetect_java $host "1.5"]
         }
         #Add java1.6
         set ts_host_config($host,java16) [autodetect_java $host "1.6"]
         #Add ant
         set ts_host_config($host,ant) [autodetect_ant $host]
         puts "================="
      }

      set ts_host_config(version) "1.11"

      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
   }

   if {[string compare $ts_host_config(version)  "1.11"] == 0} {
      puts "\ntestsuite host configuration update from 1.11 to 1.12 ..."

      # introduce new version 80, remove obsolete versions 53, 60, 61
      foreach host $ts_host_config(hostlist) {
         puts "$host"
         set ts_host_config($host,arch,80) $ts_host_config($host,arch,62)
         unset ts_host_config($host,arch,53)
         unset ts_host_config($host,arch,60)
         unset ts_host_config($host,arch,61)

         set ts_host_config($host,compile,80) $ts_host_config($host,compile,62)
         unset ts_host_config($host,compile,53)
         unset ts_host_config($host,compile,60)
         unset ts_host_config($host,compile,61)

         set ts_host_config($host,java_compile,80) $ts_host_config($host,java_compile,62)
         unset ts_host_config($host,java_compile,53)
         unset ts_host_config($host,java_compile,60)
         unset ts_host_config($host,java_compile,61)
      }

      set ts_host_config(version) "1.12"

      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
      return
   }

   if {[string compare $ts_host_config(version)  "1.12"] == 0} {
      puts "\ntestsuite host configuration update from 1.12 to 1.13 ..."

      # introduce new version 90
      foreach host $ts_host_config(hostlist) {
         puts $host
         set ts_host_config($host,arch,90) $ts_host_config($host,arch,80)
         set ts_host_config($host,compile,90) $ts_host_config($host,compile,80)
         set ts_host_config($host,java_compile,90) $ts_host_config($host,java_compile,80)
      }

      set ts_host_config(version) "1.13"

      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
      return
   }

   if {[string compare $ts_host_config(version)  "1.13"] == 0} {
      puts "\ntestsuite host configuration update from 1.13 to 1.14 ..."

      # introduce doc_compile host
      foreach host $ts_host_config(hostlist) {
         puts $host
         set ts_host_config($host,doc_compile,62) 0
         set ts_host_config($host,doc_compile,80) 0
         set ts_host_config($host,doc_compile,90) 0
      }

      set ts_host_config(version) "1.14"

      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
      return 0
   }

   if {[string compare $ts_host_config(version)  "1.14"] == 0} {
      puts "\ntestsuite host configuration update from 1.14 to 1.15 ..."

      # remove old java versions
      # we auto-detect them now on demand
      foreach host $ts_host_config(hostlist) {
         puts $host
         unset ts_host_config($host,java14)
         unset ts_host_config($host,java15)
         unset ts_host_config($host,java16)
         unset ts_host_config($host,ant)
      }

      set ts_host_config(version) "1.15"

      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
      return 0
   }

   if {[string compare $ts_host_config(version)  "1.15"] == 0} {
      puts "\ntestsuite host configuration update from 1.15 to 1.16 ..."

      # introduce remote timeout factor
      foreach host $ts_host_config(hostlist) {
         puts $host
         set ts_host_config($host,remote_timeout_factor) 1
      }

      set ts_host_config(version) "1.16"

      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
      return 0
   }

   if {[string compare $ts_host_config(version)  "1.16"] == 0} {
      puts "\ntestsuite host configuration update from 1.16 to 1.17 ..."

      # introduce new version 91
      foreach host $ts_host_config(hostlist) {
         puts $host
         set ts_host_config($host,arch,91) $ts_host_config($host,arch,90)
         set ts_host_config($host,compile,91) $ts_host_config($host,compile,90)
         set ts_host_config($host,java_compile,91) $ts_host_config($host,java_compile,90)
      }

      set ts_host_config(version) "1.17"

      show_config ts_host_config
      wait_for_enter
      if {[save_host_configuration $filename] != 0} {
         puts "Could not save host configuration"
         wait_for_enter
         return
      }
      return 0
   }

   puts "\nunexpected version"
   return -1
}

# keeping autodetect_ant as it might still be called in some update function
proc autodetect_ant { host } {
   return ""
}

#****** config_host/check_java_version() ***************************************
#  NAME
#     check_java_version() -- java_bin is of a version specified
#
#  SYNOPSIS
#      check_java_version { host java_bin version }
#
#  FUNCTION
#     This procedure is called each time java14 java15 and java16 locations are 
#     modified in host configuration.
#
#  INPUTS
#     host - host where we expect the java_bin
#     java_bin - whole path to java binary
#     version - expected java version of java_bin
#
#  SEE ALSO
#
#  NOTE
#     deprecated
#
#  TODO
#     Having valid java_bin is not enough. We also need JAVA_HOME/include dir.
#     E.g.: /usr/jdk/jre/bin/java is invalid, correct would be /usr/jdk/bin/java
#*******************************************************************************
proc check_java_version {host java_bin version} {
   global CHECK_USER
   if {[string trim $java_bin] == ""} {
      return -1
   }
   set output [start_remote_prog $host $CHECK_USER "$java_bin" "-version" prg_exit_state 12 0 "" "" 1 0]
   if {[string match "*java version \"$version.*\"*" $output]} {
      return 0
   }
   return -1
}

# keeping autodetect_java as it might still be called in some update function
proc autodetect_java { host {version "1.4"} } {
   return ""
}

#****** config_host/setup_host_config() ****************************************
#  NAME
#     setup_host_config() -- testsuite host configuration initalization
#
#  SYNOPSIS
#     setup_host_config { file { force 0 } } 
#
#  FUNCTION
#     This procedure will initalize the testsuite host configuration
#
#  INPUTS
#     file        - host configuration file
#     { force_params "" }  - the list of parameters to edit
#                            for allowed values see the configured parameters
#                            in host configuration
#
#  SEE ALSO
#     check/setup_user_config()
#*******************************************************************************
proc setup_host_config {file {force_params "" } } {
   global ts_host_config actual_ts_host_config_version

   if { [read_array_from_file $file "testsuite host configuration" ts_host_config ] == 0 } {
      if { $ts_host_config(version) != $actual_ts_host_config_version } {
         puts "unknown host configuration file version: $ts_host_config(version) actual version: $actual_ts_host_config_version"
         while { [update_ts_host_config_version $file] != 0 } {
            wait_for_enter
         }
      }

      # got config
      if { [verify_host_config ts_host_config 1 err_list $force_params ] != 0 } {
         # configuration problems
         foreach elem $err_list { puts "$elem" } 
         puts "Press enter to edit host setup configurations"
         set answer [wait_for_enter 1]

         set not_ok 1
         while { $not_ok } {
            if { [verify_host_config ts_host_config 0 err_list $force_params ] != 0 } {
               set not_ok 1
               foreach elem $err_list { puts "error in: $elem" } 
               puts "try again? (y/n)"
               set answer [wait_for_enter 1]
               if { $answer == "n" } {
                  puts "Do you want to save your changes? (y/n)"
                  set answer [wait_for_enter 1]
                  if { $answer == "y" } {
                     if { [ save_host_configuration $file] != 0} {
                        puts "Could not save host configuration"
                        wait_for_enter
                     }
                  }
                  return
               } else { continue }
            } else { set not_ok 0 }
               }
         if { [ save_host_configuration $file] != 0} {
            puts "Could not save host configuration"
            wait_for_enter
            return
         }
      }
      if { [string compare $force_params ""] != 0 } {
         if { [ save_host_configuration $file] != 0} {
            puts "Could not save host configuration"
            wait_for_enter
         }
      }
      return
   } else {
      puts "could not open host config file \"$file\""
      puts "press return to create new host configuration file"
      wait_for_enter 1
      if { [ save_host_configuration $file] != 0} { return -1 }
      setup_host_config $file
   }
}

#****** config_host/host_conf_get_nodes() **************************************
#  NAME
#     host_conf_get_nodes() -- return a list of exechosts and zones
#
#  SYNOPSIS
#     host_conf_get_nodes { host_list } 
#
#  FUNCTION
#     Iterates through host_list and builds a new node list, that contains
#     both hosts and zones.
#     If zones are available on a host, only the zones are contained in the new
#     node list,
#     if no zones are available on a host, the hostname will be contained in the
#     new node list.
#
#  INPUTS
#     host_list - list of physical hosts
#
#  RESULT
#     node list
#
#  SEE ALSO
#     config_host/host_conf_get_unique_nodes()
#*******************************************************************************
proc host_conf_get_nodes {host_list} {
   global ts_host_config

   set node_list {}

   foreach host $host_list {
      if {![info exists ts_host_config($host,zones)]} {
         ts_log_severe "host $host is not contained in testsuite host configuration!"
      } else {
         set zones $ts_host_config($host,zones)
         if {[llength $zones] == 0} {
            lappend node_list $host
         } else {
            set node_list [concat $node_list $zones]
         }
      }
   }

   return [lsort -dictionary $node_list]
}

#****** config_host/host_conf_get_unique_nodes() *******************************
#  NAME
#     host_conf_get_unique_nodes() -- return a unique list of exechosts and zones
#
#  SYNOPSIS
#     host_conf_get_unique_nodes { host_list } 
#
#  FUNCTION
#     Iterates through host_list and builds a new node list, that contains
#     both hosts and zones, but only one entry per physical host.
#     If zones are available on a host, only the first zone is contained in the new
#     node list,
#     if no zones are available on a host, the hostname will be contained in the
#     new node list.
#
#  INPUTS
#     host_list - list of physical hosts
#
#  RESULT
#     node list
#
#  SEE ALSO
#     config_host/host_conf_get_nodes()
#*******************************************************************************
proc host_conf_get_unique_nodes {host_list} {
   global ts_host_config

   set node_list {}

   foreach host $host_list {
      if {![info exists ts_host_config($host,zones)]} {
         ts_log_severe "host $host is not contained in testsuite host configuration!"
      } else {
         set zones $ts_host_config($host,zones)
         if {[llength $zones] == 0} {
            lappend node_list $host
         } else {
            set node_list [concat $node_list [lindex $zones 0]]
         }
      }
   }

   return [lsort -dictionary $node_list]
}

proc host_conf_get_unique_arch_nodes {host_list} {
   global ts_host_config

   set node_list {}
   set covered_archs {}

   # we have tests looping over the unique_arch_nodes
   # in case we test with valgrind we want the valgrind host to be included
   global CHECK_VALGRIND CHECK_VALGRIND_HOST
   if {$CHECK_VALGRIND == "clients" || $CHECK_VALGRIND == "tests"} {
      set valgrind_arch [host_conf_get_arch $CHECK_VALGRIND_HOST]
      lappend covered_archs $valgrind_arch
      lappend node_list $CHECK_VALGRIND_HOST
   }

   foreach node $host_list {
      set host [node_get_host $node]
      set arch [host_conf_get_arch $host]
      if {[lsearch -exact $covered_archs $arch] == -1} {
         lappend covered_archs $arch
         lappend node_list $node
      }
   }

   return $node_list
}

proc host_conf_get_all_nodes {host_list} {
   global ts_host_config

   set node_list {}

   foreach host $host_list {
      lappend node_list $host

      if {![info exists ts_host_config($host,zones)]} {
         ts_log_severe "host $host is not contained in testsuite host configuration!"
      } else {
         set zones $ts_host_config($host,zones)
         if {[llength $zones] > 0} {
            set node_list [concat $node_list $zones]
         }
      }
   }

   return [lsort -dictionary $node_list]
}

proc node_get_host {nodename} {
   global physical_host

   if {[info exists physical_host($nodename)]} {
      set ret $physical_host($nodename)
   } else {
      set ret $nodename
   }

   return $ret
}

proc node_set_host {nodename hostname} {
   global physical_host

   set physical_host($nodename) $hostname
}

proc node_get_processors {nodename} {
   global ts_host_config

   set host [node_get_host $nodename]

   return $ts_host_config($host,processors)
}

proc node_get_ssh {nodename} {
   global ts_host_config

   set host [node_get_host $nodename]

   return $ts_host_config($host,ssh)
}

#****** config_host/host_conf_get_archs() **************************************
#  NAME
#     host_conf_get_archs() -- get all archs covered by a list of hosts
#
#  SYNOPSIS
#     host_conf_get_archs { nodelist } 
#
#  FUNCTION
#     Takes a list of hosts and returns a unique list of the architectures
#     of the hosts.
#
#  INPUTS
#     nodelist - list of nodes
#
#  RESULT
#     list of architectures
#*******************************************************************************
proc host_conf_get_archs {nodelist} {
   global ts_host_config

   set archs {}
   foreach node $nodelist {
      set host [node_get_host $node]
      lappend archs [host_conf_get_arch $host]
   }

   return [lsort -unique $archs]
}

#****** config_host/host_conf_get_arch_hosts() *********************************
#  NAME
#     host_conf_get_arch_hosts() -- find hosts of certain architectures
#
#  SYNOPSIS
#     host_conf_get_arch_hosts { archs } 
#
#  FUNCTION
#     Returns all hosts configured in the testuite host configuration,
#     that have one of the given architectures.
#
#  INPUTS
#     archs - list of architecture names
#
#  RESULT
#     list of hosts
#*******************************************************************************
proc host_conf_get_arch_hosts {archs} {
   global ts_host_config

   set hostlist {}
   foreach host $ts_host_config(hostlist) {
      if {[lsearch -exact $archs [host_conf_get_arch $host]] >= 0} {
         lappend hostlist $host
      }
   }

   return $hostlist
}

# return non-cluster host having the given architecture
proc host_conf_get_non_cluster_hosts {archs} {
   global ts_config

   set hostlist {}
   foreach host $ts_config(non_cluster_hosts) {
      if {[lsearch -exact $archs [host_conf_get_arch $host]] >= 0} {
         lappend hostlist $host
      }
   }

   return $hostlist
}

#****** config_host/host_conf_get_unused_host() ********************************
#  NAME
#     host_conf_get_unused_host() -- find a host not being referenced in our cluster
#
#  SYNOPSIS
#     host_conf_get_unused_host { {raise_error 1} } 
#
#  FUNCTION
#     Tries to find a host in the testsuite host configuration that
#     - is not referenced in the installed cluster (master/exec/submit)
#     - has an installed architecture
#
#  INPUTS
#     {raise_error 1} - raise an error (unsupported warning) if no such host is found
#
#  RESULT
#     The name of a host matching the above description.
#*******************************************************************************
proc host_conf_get_unused_host {{raise_error 1}} {
   global ts_config ts_host_config

   # return an empty string if we don't find a suited host
   set ret ""

   # get a list of all hosts referenced in the cluster
   set cluster_hosts [host_conf_get_cluster_hosts]

   # get a list of all available architectures
   set archs [host_conf_get_archs $cluster_hosts]
   set archs [lsort -unique $archs]

   # now search a host having an installed architecture
   # and not being part of our cluster
   set installed_hosts [host_conf_get_arch_hosts $archs]
   foreach host $installed_hosts {
      if {[lsearch -exact $cluster_hosts $host] == -1} {
         set ret $host
         break
      }
   }

   if {$ret == "" && $raise_error} {
      ts_log_config "cannot find an unused host having an installed architecture" 
   }

   return $ret
}

proc host_conf_get_non_cluster_host {{raise_error 1}} {
   global ts_config ts_host_config

   # return an empty string if we don't find a suited host
   set ret ""

   # get a list of all available architectures
   set cluster_hosts [host_conf_get_cluster_hosts]
   set archs [host_conf_get_archs $cluster_hosts]
   set archs [lsort -unique $archs]

   # now search a non-cluster host having an installed arch
   set non_cluster_hosts [host_conf_get_non_cluster_hosts $archs]
   set ret [lindex $non_cluster_hosts 0]

   # handle error if requested
   if {$ret == "" && $raise_error} {
      ts_log_config "cannot find a non-cluster host having one of the architecture: $archs"
   }

   return $ret
}


#****** config_host/get_java_home_for_host() ***********************************
#  NAME
#    get_java_home_for_host() -- Get the java home directory for a host. If no/unknown java 
#                                version specified returns java home for java 1.4.
#
#  SYNOPSIS
#    get_java_home_for_host { host {java_version "1.4"} } 
#
#  FUNCTION
#     Reads the java home directory for a host from the host configuration
#
#  INPUTS
#    host -- name of the host
#    {java_version "1.4"} -- e.g.: 1.5+ => "15 16"
#
#  RESULT
#     
#     the java home directory of an empty string if the java is not set 
#     in the host configuration
#
#  EXAMPLE
#
#     set java_home [get_java_home_for_host $ts_config(master_host) "1.6"]
#
#     if { $java_home == "" } {
#         puts "java not configurated for host $ts_config(master_host)"
#     }
#
#  NOTES
#     TODO: store JAVA_HOME in host config!
#
#  BUGS
#     Doesn't work for MAC OS X
#  SEE ALSO
#*******************************************************************************
# @todo: replace by host_conf_get_java
proc get_java_home_for_host { hosti {java_version "1.4"} {raise_error 1}} {
    global ts_host_config
    set version [get_testsuite_java_version $java_version]
    set host [node_get_host $hosti]
    foreach vers [split $version " "] {
       set input $ts_host_config($host,java$vers)
       if {$input != ""} {
          break
       }
    }

    if { $input == "" } {
       if { $raise_error } {
          ts_log_info "Error: java $java_version is not set for host: $host"
       }
       return ""
    }
    
    set input_len [ string length $input ]
    set java_len  [ string length "/bin/java" ]
    
    set last [ expr ( $input_len - $java_len -1 ) ]
    
    set res [ string range $input 0 $last]
    
    return $res
}

#****** config_host/get_jvm_lib_path_for_host() ********************************
#  NAME
#    get_jvm_lib_path_for_host() -- Get the absolute libjvm.so path for a host.
#
#  SYNOPSIS
#    get_jvm_lib_path_for_host { host {java_version "1.5+"} } 
#
#  FUNCTION
#     returns the absolute libjvm.so path
#
#  INPUTS
#    host -- name of the host
#    java_version -- java version to use
#
#  RESULT
#     
#     the absolute libjvm.so path or an empty string if java is not set 
#     in the host configuration
#
#  EXAMPLE
#
#     set libjvm_path [get_jvm_lib_path_for_host $ts_config(master_host) "1.6"]
#
#     if { $libjvm_path == "" } {
#         puts "libjvm_path not available for host $ts_config(master_host)"
#     }
#
#  NOTES
#     TODO: store JAVA_HOME in host config!
#
#  SEE ALSO
#*******************************************************************************
proc get_jvm_lib_path_for_host { host {java_version "1.5+"} } {
   set java_home [get_java_home_for_host $host $java_version]
   set arch [host_conf_get_arch $host]
   set jvm_lib_path ""
   switch -glob -- $arch {
      "sol-sparc64" {
         set jvm_lib_path $java_home/jre/lib/sparcv9/server/libjvm.so
      } 
      "sol-amd64" { 
         set jvm_lib_path $java_home/jre/lib/amd64/server/libjvm.so
      }
      "sol-x86" {
         # set jvm_lib_path $java_home/jre/lib/i386/server/libjvm.so
         set jvm_lib_path $java_home/jre/lib/i386/client/libjvm.so
      }
      "lx*-amd64" {
         set jvm_lib_path $java_home/jre/lib/amd64/server/libjvm.so
      }
      "lx*-x86" {
         set jvm_lib_path $java_home/jre/lib/i386/server/libjvm.so
      }
      "darwin-x64" {
         set jvm_lib_path $java_home/../Libraries/libjvm.dylib
      }
      "lx*-ia64" {
         set jvm_lib_path $java_home/jre/lib/ia64/server/libjvm.so
      }
   }
   return $jvm_lib_path
}

proc get_testsuite_java_version {{version "1.4"}} {
   switch -exact $version {
     "1.4" {
        return "14"
     }
     "1.4+" {
        return "14 15 16"
     }
     "1.5" {
        return "15"
     }
     "1.5+" {
        return "15 16"
     }
     "1.6" {
        return "16"
     }
   }
   ts_log_config "Warning: Unknown java_version: $version. Java 1.4 will be used instead!"
   return "14"
}

#****** config_host/host_conf_get_cluster_hosts() ******************************
#  NAME
#     host_conf_get_cluster_hosts() -- get a list of cluster hosts
#
#  SYNOPSIS
#     host_conf_get_cluster_hosts { } 
#
#  FUNCTION
#     Returns a list of all hosts that are part of the given cluster.
#     The list contains
#     - the master host
#     - the execd hosts
#     - the execd nodes (execd hosts with Solaris zones resolved)
#     - submit only hosts
#     - a berkeleydb RPC server host
#
#     The list is sorted by hostname, hostnames are unique.
#
#  RESULT
#     hostlist
#*******************************************************************************
proc host_conf_get_cluster_hosts {{with_non_cluster_hosts 0} {with_compile_hosts 0}} {
   global ts_config

   set hosts "$ts_config(master_host) $ts_config(execd_hosts) $ts_config(execd_nodes) $ts_config(admin_only_hosts) $ts_config(submit_only_hosts) $ts_config(shadowd_hosts)"

   # we want the non cluster host as well
   if {$with_non_cluster_hosts} {
      set hosts [concat $hosts $ts_config(non_cluster_hosts)]
   }

   # we want the compile hosts as well
   if {$with_compile_hosts} {
      set cluster_hosts [lsort -dictionary -unique $hosts]

      # remove "none" entries from the list
      regsub "none" $cluster_hosts "" cluster_hosts

      set archs [host_conf_get_archs $cluster_hosts]
      # compile host per architecture
      foreach arch $archs {
         set host [compile_search_compile_host $arch]
         if {$host != "none"} {
            lappend hosts $host
         }
      }
      foreach arch $ts_config(add_compile_archs) {
         set host [compile_search_compile_host $arch]
         if {$host != "none"} {
            lappend hosts $host
         }
      }
      # doc and java compile host
      set host [host_conf_get_doc_compile_host 0]
      if {$host != ""} {
         lappend hosts $host
      }
      set host [host_conf_get_java_compile_host 0]
      if {$host != ""} {
         lappend hosts $host
      }
   }

   # make the list unique and remove "none"
   set cluster_hosts [lsort -dictionary -unique $hosts]
   set none_elem [lsearch $cluster_hosts "none"]
   if {$none_elem >= 0} {
      set cluster_hosts [lreplace $cluster_hosts $none_elem $none_elem]
   }

   return $cluster_hosts
}

#****** config_host/host_conf_is_compile_host() ********************************
#  NAME
#     host_conf_is_compile_host() -- is a given host compile host?
#
#  SYNOPSIS
#     host_conf_is_compile_host { host {config_var ""} } 
#
#  FUNCTION
#     Returns if a given host is used as compile host.
#     The information is retrieved from the ts_host_config array,
#     unless another array is specified (e.g. during configuration).
#
#  INPUTS
#     host            - the host
#     {config_var ""} - configuration array, default ts_host_config
#
#  RESULT
#     0: is not compile host
#     1: is compile host
#*******************************************************************************
proc host_conf_is_compile_host {host {config_var ""}} {
   global ts_config ts_host_config
   
   # we might work on a temporary config
   if {$config_var == ""} { 
      upvar 0 ts_host_config config
   } else {
      upvar 1 $config_var config
   }

   set ret 0

   if {[info exists config($host,compile,$ts_config(gridengine_version))]} {
      set ret $config($host,compile,$ts_config(gridengine_version))
   }

   return $ret
}

###
# @brief is a given host a doc compile host?
#
# Returns if a given host is used as doc compile host.
# The information is retrieved from the ts_host_config array,
# unless another array is specified (e.g. during configuration).
#
# @param[in] host       - name of the host to check
# @param[in] config_var - optional: name of a TCL array holdig a host configuration
# @return 1, if it is a doc build host, else 0
##
proc host_conf_is_doc_compile_host {host {config_var ""}} {
   global ts_config ts_host_config
   
   # we might work on a temporary config
   if {$config_var == ""} { 
      upvar 0 ts_host_config config
   } else {
      upvar 1 $config_var config
   }

   set ret 0

   if {[info exists config($host,doc_compile,$ts_config(gridengine_version))]} {
      set ret $config($host,doc_compile,$ts_config(gridengine_version))
   }

   return $ret
}

#****** config_host/host_conf_is_java_compile_host() ***************************
#  NAME
#     host_conf_is_java_compile_host() -- is a given host compile host for java?
#
#  SYNOPSIS
#     host_conf_is_java_compile_host { host {config_var ""} } 
#
#  FUNCTION
#     Returns if a given host is used as java compile host.
#     The information is retrieved from the ts_host_config array,
#     unless another array is specified (e.g. during configuration).
#
#  INPUTS
#     host            - the host
#     {config_var ""} - configuration array, default ts_host_config
#
#  RESULT
#     0: is not java compile host
#     1: is compile host
#*******************************************************************************
proc host_conf_is_java_compile_host {host {config_var ""}} {
   global ts_config ts_host_config
   
   # we might work on a temporary config
   if {$config_var == ""} { 
      upvar 0 ts_host_config config
   } else {
      upvar 1 $config_var config
   }

   set ret 0

   if {[info exists config($host,java_compile,$ts_config(gridengine_version))]} {
      set ret $config($host,java_compile,$ts_config(gridengine_version))
   }

   return $ret
}

#****** config_host/host_conf_get_arch() ***************************************
#  NAME
#     host_conf_get_arch() -- return a host's architecture
#
#  SYNOPSIS
#     host_conf_get_arch { host {config_var ""} } 
#
#  FUNCTION
#     Returns the architecture that is configured in the testsuite
#     host configuration.
#     The architecture string may be Cluster Scheduler (Grid Engine) version dependent, that
#     means, the function may return different architecture strings for
#     different Cluster Scheduler (Grid Engine) version (62, 80, ...).
#     If a host is not supported platform for a certain Cluster Scheduler (Grid Engine) version,
#     "unsupported" is returned as archictecture name.
#
#  INPUTS
#     host            - the host
#     {config_var ""} - configuration array, default ts_host_config
#
#  RESULT
#     an architecture string, e.g. sol-sparc64, darwin, ...
#*******************************************************************************
# CR checked
proc host_conf_get_arch {hostname {config_var ""}} {
   global ts_host_config
   get_current_cluster_config_array ts_config

   # we might work on a temporary config
   if {$config_var == ""} { 
      upvar 0 ts_host_config config
   } else {
      upvar 1 $config_var config
   }

   set ret ""

   # if host resolves long we have always short config entry
   # so we use the name before the first "." as hostname
   set host [string trim $hostname]
   set host [split $host "."]
   set host [lindex $host 0]
   if {[info exists config($host,arch,$ts_config(gridengine_version))]} {
      set ret $config($host,arch,$ts_config(gridengine_version))
   }

   return $ret
}

#****** config_host/host_conf_is_known_host() **********************************
#  NAME
#     host_conf_is_known_host() -- is a host configured in testsuite host conf
#
#  SYNOPSIS
#     host_conf_is_known_host { host {config_var ""} } 
#
#  FUNCTION
#     Checks if a given host is configured in the testsuite host configuration.
#
#  INPUTS
#     host            - the host
#     {config_var ""} - configuration array, default ts_host_config
#
#  RESULT
#     0: host is not configured in testsuite host config
#     1: is a configured host
#
#  SEE ALSO
#     config_host/host_conf_is_supported_host()
#*******************************************************************************
proc host_conf_is_known_host {host {config_var ""}} {
   global ts_config ts_host_config

   # we might work on a temporary config
   if {$config_var == ""} { 
      upvar 0 ts_host_config config
   } else {
      upvar 1 $config_var config
   }

   set ret 1

   if {[lsearch $config(hostlist) $host] < 0} {
      ts_log_fine "Host \"$host\" is not in host configuration file"
      set ret 0
   }

   return $ret
}

#****** config_host/host_conf_is_supported_host() ******************************
#  NAME
#     host_conf_is_supported_host() -- is host supported for given GE version
#
#  SYNOPSIS
#     host_conf_is_supported_host { host {config_var ""} } 
#
#  FUNCTION
#     Checks if the given host is configured in the Cluster Scheduler (Grid Engine) host
#     configuration and if it has an architecture, that is supported by the
#     given Cluster Scheduler (Grid Engine) version.
#
#  INPUTS
#     host            - the host
#     {config_var ""} - configuration array, default ts_host_config
#
#  RESULT
#     0: host is not supported
#     1: is a supported host
#
#  SEE ALSO
#     config_host/host_conf_is_known_host()
#*******************************************************************************
proc host_conf_is_supported_host {host {config_var ""}} {
   global ts_config ts_host_config

   # we might work on a temporary config
   if {$config_var == ""} { 
      upvar 0 ts_host_config config
   } else {
      upvar 1 $config_var config
   }

   set ret [host_conf_is_known_host $host config]

   if {$ret} {
      if {[host_conf_get_arch $host config] == "unsupported"} {
         ts_log_fine "Host \"$host\" is not supported with Cluster Scheduler (Grid Engine) $ts_config(gridengine_version)"
         set ret 0
      }
   }

   return $ret
}

#****** config_host/host_conf_53_arch() ****************************************
#  NAME
#     host_conf_53_arch() -- convert any arch string to 53 arch string
#
#  SYNOPSIS
#     host_conf_53_arch { arch } 
#
#  FUNCTION
#     Takes an architecture string and tries to convert it to a Cluster Scheduler (Grid Engine)
#     5.3 architecture string.
#
#     If the given architecture string cannot be converted, "unknown" will
#     be returned.
#
#  INPUTS
#     arch - any arch string
#
#  RESULT
#     5.3 architecture string or "unknown"
#
#  SEE ALSO
#     config_host/host_conf_60_arch()
#     config_host/host_conf_61_arch()
#*******************************************************************************
proc host_conf_53_arch {arch} {
   switch -glob $arch {
      "sol-sparc" { return "solaris" }
      "sol-sparc64" { return "solaris64" }
      "sol-x86" { return "solaris86" }
      "lx*-x86" { return "glinux" }
      "lx*-alpha" { return "alinux" }
      "lx*-sparc" { return "slinux" }
      "lx*-ia64" { return "ia64linux" }
      "lx*-amd64" { return "lx24-amd64" }

      "darwin" -
      "fbsd-*" -
      "nbsd-*" {
         return $arch
      }
   }

   return "unsupported"
}

#****** config_host/host_conf_60_arch() ****************************************
#  NAME
#     host_conf_60_arch() -- convert any arch string to 60 arch string
#
#  SYNOPSIS
#     host_conf_60_arch { arch } 
#
#  FUNCTION
#     Takes an architecture string and tries to convert it to a Cluster Scheduler (Grid Engine)
#     6.0 architecture string.
#
#     If the given architecture string cannot be converted, "unknown" will
#     be returned.
#
#  INPUTS
#     arch - any arch string
#
#  RESULT
#     6.0 architecture string or "unknown"
#
#  SEE ALSO
#     config_host/host_conf_53_arch()
#     config_host/host_conf_61_arch()
#*******************************************************************************
proc host_conf_60_arch {arch} {
   # map old 5.3 names to 6.0
   # map 6.1 names to 6.0
   # allow all sol-, lx, fbsd, nbsd platforms for testsuite
   # allow selected architecture names
   # the rest will be unsupported
   switch -glob $arch {
      "solaris" { return "sol-sparc" }
      "solaris64" { return "sol-sparc64" }
      "solaris86" { return "sol-x86" }
      "glinux" { return "lx24-x86" }
      "alinux" { return "lx24-alpha" }
      "slinux" { return "lx24-sparc" }
      "ia64linux" { return "lx24-ia64" }

      "sol-*" -
      "lx??-*" -
      "fbsd-*" -
      "nbsd-*" -

      "darwin" {
         return $arch
      }
   }

   return "unsupported"
}

#****** config_host/host_conf_61_arch() ****************************************
#  NAME
#     host_conf_61_arch() -- convert any arch string to 61 arch string
#
#  SYNOPSIS
#     host_conf_61_arch { arch } 
#
#  FUNCTION
#     Takes an architecture string and tries to convert it to a Cluster Scheduler (Grid Engine)
#     6.1 architecture string.
#
#     If the given architecture string cannot be converted, "unknown" will
#     be returned.
#
#  INPUTS
#     arch - any arch string
#
#  RESULT
#     6.1 architecture string or "unknown"
#
#  SEE ALSO
#     config_host/host_conf_53_arch()
#     config_host/host_conf_60_arch()
#*******************************************************************************
proc host_conf_61_arch {arch} {
   # map old 5.3 names to 6.1
   # map 6.0 names to 6.1
   # allow all sol-, lx, fbsd, nbsd platforms for testsuite
   # allow selected architecture names
   # the rest will be unsupported
   switch -glob $arch {
      "solaris" { return "sol-sparc" }
      "solaris64" { return "sol-sparc64" }
      "solaris86" { return "sol-x86" }

      "sol-*" -
      "lx??-*" -
      "fbsd-*" -
      "nbsd-*" -
      "darwin-x64" {
         return $arch
      }
   }

   return "unsupported"
}

#****** config_host/host_conf_have_windows() ***********************************
#  NAME
#     host_conf_have_windows() -- do we have a windows host
#
#  SYNOPSIS
#     host_conf_have_windows { } 
#
#  FUNCTION
#     Returns whether we have a windows host in our testsuite cluster 
#     configuration.
#
#  RESULT
#     1 - if we have a windows host, else 0
#
#  SEE ALSO
#     config_host/host_conf_have_windows()
#     config_host/host_conf_get_cluster_hosts()
#     config_host/host_conf_get_arch()
#*******************************************************************************
proc host_conf_have_windows {} {
   set ret 0

   # get a list of all hosts referenced in the cluster
   set cluster_hosts [host_conf_get_cluster_hosts]

   # search for a windows host
   foreach host $cluster_hosts {
      if {[host_conf_get_arch $host] == "win32-x86"} {
         set ret 1
         break
      }
   }

   return $ret
}

#****** config_host/host_conf_get_windows_host() *******************************
#  NAME
#     host_conf_get_windows_host() -- get a windows host
#
#  SYNOPSIS
#     host_conf_get_windows_host { } 
#
#  FUNCTION
#     Returns the hostname of the first windows host in our testsuite cluster
#     configuration.
#
#  RESULT
#     A hostname of a windows host, or an empty string, if we don't have a 
#     windows host in our cluster.
#
#  SEE ALSO
#     config_host/host_conf_have_windows()
#     config_host/host_conf_get_cluster_hosts()
#     config_host/host_conf_get_arch()
#*******************************************************************************
proc host_conf_get_windows_host {} {
   set ret ""

   # get a list of all hosts referenced in the cluster
   set cluster_hosts [host_conf_get_cluster_hosts]
   
   # search and return the first windows host
   foreach host $cluster_hosts {
      if {[host_conf_get_arch $host] == "win32-x86"} {
         set ret $host
         break
      }
   }

   return $ret
}

#****** config_host/host_conf_get_windows_exec_host() **************************
#  NAME
#     host_conf_get_windows_exec_host() -- get a windows exec host
#
#  SYNOPSIS
#     host_conf_get_windows_exec_host { } 
#
#  FUNCTION
#     Returns the hostname of the first windows exec host in our testsuite
#     cluster configuration.
#
#  RESULT
#     A hostname of a windows exec host, or an empty string, if we don't have a 
#     windows exec host in our cluster.
#
#  SEE ALSO
#     config_host/host_conf_get_arch()
#*******************************************************************************
proc host_conf_get_windows_exec_host {} {
   global ts_config
   set ret ""

   # get a list of all exec hosts referenced in the cluster
   set exec_hosts $ts_config(execd_nodes)

   # search for a windows host
   foreach host $exec_hosts {
      if {[host_conf_get_arch $host] == "win32-x86"} {
         set ret $host
         break
      }
   }

   return $ret
}

### 
# @brief get doc compile host
#
# Returns the name of the doc host configured in the host config.
# If no doc compile host is found, an error is raised and an empty string
# is returned.
#
# @param[in] raise_error  - raise an error condition if no doc compile host is found, default: yes
# @param[in] resolve_long - if 1 the the host name including the dns_domain is resolved
# @return the host name of an empty string ("") if no doc compile host is configured
##
proc host_conf_get_doc_compile_host {{raise_error 1} {resolve_long 0}} {
   global ts_config ts_host_config

   set compile_host ""
   foreach host $ts_host_config(hostlist) {
      if {[host_conf_is_doc_compile_host $host]} {
         set compile_host $host
         break
      }
   }

   if {$compile_host == ""} {
      ts_log_config "didn't find doc compile host in host configuration"
   } else {
      if { $resolve_long != 0 } {
         set short_compile_host [resolve_host $compile_host 0]
         set compile_host [resolve_host "${short_compile_host}.$ts_config(dns_domain)" 1]
      }
      if {$compile_host == "unknown"} {
         ts_log_severe "cannot get doc build host name"
         set compile_host ""
      }
   }
   return $compile_host
}

#****** config_host/host_conf_get_java_compile_host() **************************
#  NAME
#     host_conf_get_java_compile_host() -- get java compile host
#
#  SYNOPSIS
#     host_conf_get_java_compile_host { {raise_error 1} } 
#
#  FUNCTION
#     Returns the name of the java compile host configured in the host config.
#     If no compile host is found, an error is raised and an empty string
#     is returned.
#
#  INPUTS
#     {raise_error 1}  - raise error condition or just output error message
#     {resolve_long 0} - if set to 1 the build host is returned with domain name
#                        (long hostname)
#
#  RESULT
#     name of compile host or "", if no compile host was found
#
#  SEE ALSO
#     config_host/host_conf_is_java_compile_host()
#*******************************************************************************
proc host_conf_get_java_compile_host {{raise_error 1} {resolve_long 0}} {
   global ts_config ts_host_config

   set compile_host ""
   foreach host $ts_host_config(hostlist) {
      if {[host_conf_is_java_compile_host $host]} {
         set compile_host $host
         break
      }
   }

   if {$compile_host == ""} {
      ts_log_config "didn't find java compile host in host configuration"
   } else {
      if { $resolve_long != 0 } {
         set short_compile_host [resolve_host $compile_host 0]
         set compile_host [resolve_host "${short_compile_host}.$ts_config(dns_domain)" 1]
      }
      if {$compile_host == "unknown"} {
         ts_log_severe "cannot get java build host name"
         set compile_host ""
      }
   }
   return $compile_host
}

#****** config_host/host_conf_get_send_speed() *********************************
#  NAME
#     host_conf_get_send_speed() -- get send speed for a certain host
#
#  SYNOPSIS
#     host_conf_get_send_speed {host} 
#
#  FUNCTION
#     Returns the send speed configured for a given host in the testsuite 
#     host configuration.
#
#     If the given hostname is a Solaris zone, the send speed configured
#     for the physical host is returned.
#
#     If the host is not (yet) known, e.g. while it is added to the host config,
#     a default value of 0.0 is returned.
#
#  INPUTS
#     host - name of the host or zone
#            if "" is given as hostname, the default value will be returned
#
#  RESULT
#     send_speed configured in host configuration, or default 0.0
#     Meant to set as "send_slow" before calls to "send -s".
#
#  SEE ALSO
#     remote_procedures/ts_send()
#*******************************************************************************
proc host_conf_get_send_speed {host_in} {
   global ts_host_config
   global GLOBAL_SEND_SPEED

   if { [info exists GLOBAL_SEND_SPEED] } {
      return $GLOBAL_SEND_SPEED
   }

   # if we don' know the host: return default
   if {$host_in == ""} {
      return 0.0
   }

   # remove domain part of hostname
   set host [lindex [split $host_in "."] 0]

   # resolve node (poss. zone) to physical host
   set host [node_get_host $host]
   if {[info exists ts_host_config($host,send_speed)]} {
      return $ts_host_config($host,send_speed)
   }

   # don't know the host yet (e.g. when adding a new host): return default
   return 0.0
}

#****** config_host/host_has_newgrp() ******************************************
#  NAME
#     host_has_newgrp() -- does host have newgrp
#
#  SYNOPSIS
#     host_has_newgrp {host {raise_error 1}} 
#
#  FUNCTION
#     Evaluate if a given host has a newgrp command.
#     On certain architectures (e.g. windows, netbsd), newgrp is not available.
#
#  INPUTS
#     host            - host on which we'd like to execute newgrp
#     {raise_error 1} - raise an unsupported warning, if no newgrp is available?
#
#  RESULT
#     0 - no newgrp is available
#     1 - newgrp is available
#*******************************************************************************
proc host_has_newgrp {host {raise_error 1}} {
   set ret 1

   set arch [resolve_arch $host]
   switch -exact $arch {
      "nbsd-i386" -
      "darwin*" -
      "win32-x86" {
         ts_log_config "host $host ($arch) doesn't support newgrp" $raise_error
         set ret 0
      }
   }

   return $ret
}

#****** config_host/host_get_id_a_command() ************************************
#  NAME
#     host_get_id_a_command() -- return the id command for a host
#
#  SYNOPSIS
#     host_get_id_a_command { host } 
#
#  FUNCTION
#     Returns the id -a equivalent for the given host.
#     This is either "id -a", or "id", depending on hosts architecture.
#
#  INPUTS
#     host - host for which we need a valid id -a command
#
#  RESULT
#     The command.
#
#  EXAMPLE
#     host_get_id_a_command a_linux_host will return "/usr/bin/id -a"
#     host_get_id_a_command a_netbsd_host will return "/usr/bin/id"
#*******************************************************************************
proc host_get_id_a_command {host} {
   set arch [resolve_arch $host]

   switch -exact $arch {
      "darwin-x64" -
      "nbsd-i386" {
         set ret "/usr/bin/id"
      }
      default {
         set ret "/usr/bin/id -a"
      }
   }

   return $ret
}

#****** config_host/host_conf_get_suited_hosts() *******************************
#  NAME
#     host_conf_get_suited_hosts() -- get hosts suited for operation
#
#  SYNOPSIS
#     host_conf_get_suited_hosts { {num_hosts 1} {preferred_archs {}} {selected_archs {}} 
#     {excluded_archs {}} {exclude_qmaster 0} {as_config_error 0}} 
#
#  FUNCTION
#     Returns hosts from the exec node list, selected by certain criteria.
#
#     For many checks, or for operations like calling a Cluster Scheduler (Grid Engine) binary
#     (qstat, qconf, ...), we need to decide, on which host to do the check.
#     This can be done by calling host_conf_get_suited_host.
#     host_conf_get_suited_host allows filtering the host list following 
#     certain criteria:
#        - by preferred architecture:
#          Hosts will be returned matching these preferred architectures.
#          If more hosts are needed than provided with the preferred
#          architectures, other hosts will be returned as well.
#        - by selecting architectures:
#          In this case, only hosts of the selected architectures will
#          be returned.
#        - by excluding certain architectures:
#          Hosts having these architectures will excluded from the host list.
#
#     If no preferred architectures are specified at the function call,
#     but the preferred_archs commandline switch has been used, the archs
#     specified at the commandline will be used as preferred archs.
#
#     If multiple hosts are candiates for host selection, the host(s) will be
#     returned, that have not been used for the longest time period.
#
#  INPUTS
#     { num_hosts_param 1  }  - number of hosts to return
#     { preferred_archs {} }  - if possible, select this architecture
#     { selected_archs  {} }  - select this architecture
#     { excluded_archs  {} }  - do not select this architecture
#     { exclude_qmaster 0  }  - if set to 1: exclude qmaster host
#     { as_config_error 0  }  - if set to 1: report config error if no host found
#
#  RESULT
#     A list of hosts matching the criteria.
#
#  EXAMPLE
#     host_conf_get_suited_hosts
#        will return one host (the one not being used for the longest time).
#
#     host_conf_get_suited_hosts 2
#        will return 2 hosts (the ones not being used for the longest time).
#
#     host_conf_get_suited_hosts 1 {sol-sparc64 sol-x86}
#        will return one host, if possible a sol-sparc64, or a sol-x86, or
#        if we have neither sol-sparc64 nor sol-x86 host, any other arch.
#
#     host_conf_get_suited_hosts 1 {} {sol-sparc64}
#        will return one sol-sparc64 host, or raise an error, if we don't
#        have sol-sparc64 in our cluster
#
#     host_conf_get_suited_hosts 1 {sol-sparc64} {sol-amd64 sol-sparc64}
#        will return one host, either sol-amd64 or sol-sparc, but we prefer
#        to get a sol-sparc64 host.
#
#     host_conf_get_suited_hosts 1 {} {sol-amd64 sol-sparc64} {sol-amd64}
#        error: selected and excluded architecture may not overlap
#
#     host_conf_get_suited_hosts 4 {} {} {lx-ia64}
#        return 4 hosts of any architecture, but not on Linux on Itanic.
#
#     host_conf_get_suited_hosts 4 {sol-sparc64} {} {lx-ia64}
#        return 4 hosts of any architecture, we prefer to get sol-sparc64 hosts,
#        but cannot use Linux on Itanic.
#*******************************************************************************
proc host_conf_get_suited_hosts {{num_hosts_param 1} {preferred_archs {}} {selected_archs {}} {excluded_archs {}} {exclude_qmaster 0} {as_config_error 0}} {
   global CHECK_PREFERRED_ARCHS
   get_current_cluster_config_array ts_config

   set num_hosts $num_hosts_param
   if {$exclude_qmaster != 0} {
      ts_log_finer "exclude master host is selected, requesting one additional host ..."
      incr num_hosts 1
   }
   
   # preferred archs as option to the function call will override
   # globally defined preferred archs (through commandline option at testsuite start).
   if {$preferred_archs == {} && $CHECK_PREFERRED_ARCHS != {}} {
      set preferred_archs $CHECK_PREFERRED_ARCHS
   }

   # (re)build cache
   host_conf_get_suited_hosts_rebuild_cache

   # build a list of candidates from parameters
   set return_error [host_conf_get_suited_hosts_candidates $preferred_archs $selected_archs $excluded_archs preferred_hosts remaining_hosts $as_config_error]
   if {$return_error == 1} {
      set msg "host_conf_get_suited_hosts_candidates failed $return_error"
      if {$as_config_error} {
         ts_log_config $msg
      } else {
         ts_log_severe $msg
      }
      return {} 
   }

   if {[expr [llength $preferred_hosts] + [llength $remaining_hosts]] < $num_hosts} {
      set msg  "host_selection doesn't return the required number of hosts ($num_hosts):\npreferred_archs:    $preferred_archs\nselected_archs:     $selected_archs\nexcluded_archs:     $excluded_archs\nresulting hostlist: $preferred_hosts $remaining_hosts"
      if {$as_config_error} {
         ts_log_config $msg
      } else {
         ts_log_severe $msg
      }
      return {}
   }

   set hosts [host_conf_get_suited_hosts_select $num_hosts $preferred_hosts $remaining_hosts]

   # check if qmaster is in returned list and check nr of hosts selected
   if {$exclude_qmaster != 0} {
      ts_log_finer "exclude master host is selected, check host list ..."
      set nr_hosts 0
      set new_host_list {}
      set is_ok 0
      set master_host [resolve_host $ts_config(master_host)]
      foreach host $hosts {
         if {$nr_hosts == $num_hosts_param} {
            set is_ok 1
            break
         }
         set hostA [resolve_host $host]
         if {$hostA != $master_host} {
            lappend new_host_list $host
            incr nr_hosts 1
         }
      }
      return $new_host_list
   }
   return $hosts
}

#****** config_host/host_conf_get_suited_hosts_rebuild_cache() *****************
#  NAME
#     host_conf_get_suited_hosts_rebuild_cache() -- initialization (internal)
#
#  SYNOPSIS
#     host_conf_get_suited_hosts_rebuild_cache { } 
#
#  FUNCTION
#     Initializes the caches used by host_conf_get_suited_hosts
#     Internal - do not call in tests.
#
#  SEE ALSO
#     config_host/host_conf_get_suited_hosts()
#*******************************************************************************
proc host_conf_get_suited_hosts_rebuild_cache {} {
   global suited_host_cache suited_arch_cache
   global suited_exec_node_backup
 
   get_current_cluster_config_array ts_config


   # first call, initialize some variables
   if {![info exists suited_exec_node_backup]} {
      set suited_exec_node_backup $ts_config(execd_nodes)
   } else {
      # if the exec_node_list changed, clear cache
      if {$suited_exec_node_backup != $ts_config(execd_nodes)} {
         ts_log_fine "the exec node list was modified - rebuilding suited host cache"
         if {[info exists suited_host_cache]} {
            unset suited_host_cache
         }
         if {[info exists suited_arch_cache]} {
            unset suited_arch_cache
         }
         set suited_exec_node_backup $ts_config(execd_nodes)
      }
   }

   # (re)build cache, if it doesn't exist
   if {![info exists suited_host_cache]} {
      foreach host $ts_config(execd_nodes) {
         set suited_host_cache($host) 0
         set arch [host_conf_get_arch $host]
         if {![info exists suited_arch_cache($arch)]} {
            set suited_arch_cache($arch) {}
         }
         lappend suited_arch_cache($arch) $host
      }
   }
}

#****** config_host/host_conf_get_suited_hosts_candidates() ********************
#  NAME
#     host_conf_get_suited_hosts_candidates() -- select possible hosts (internal)
#
#  SYNOPSIS
#     host_conf_get_suited_hosts_candidates { preferred selected excluded 
#     preferred_var remaining_var } 
#
#  FUNCTION
#     Selects host matching certain criteria.
#     Internal use only in host_conf_get_suited_hosts.
#
#  INPUTS
#     preferred       - list of preferred architectures
#     selected        - list of selected architectures
#     excluded        - list of excluded architectures
#     preferred_var   - return preferred hosts here
#     remaining_var   - return all other possible hosts here
#     as_config_error - if 1 then throw config error, if no host found
#
#  RESULT
#     List of hosts for preferred use, and a list of other hosts that match the
#     selection criteria, but are not the preferred ones.
#
#  SEE ALSO
#     config_host/host_conf_get_suited_hosts()
#*******************************************************************************
proc host_conf_get_suited_hosts_candidates {preferred selected excluded preferred_var remaining_var {as_config_error 0}} {
   global suited_host_cache suited_arch_cache
   upvar $preferred_var preferred_hosts
   upvar $remaining_var remaining_hosts
   set preferred_hosts {}
   set remaining_hosts {}

   # check: selected and excluded may not overlap 
   foreach arch $selected {
      if {[lsearch -exact $excluded $arch] >= 0} {
         ts_log_severe "selected and excluded architecture list overlap:\nselected: $selected\nexcluded: $excluded"
         return
      }
   }

   # check: selected archs must exist in the cluster
   set all_archs [array names suited_arch_cache]
   set nr_of_matches 0
   set available_selected {}
   foreach arch $selected {
      if {[lsearch -exact $all_archs $arch] < 0} {
         ts_log_fine "selected architecture \"$arch\" is not available in our cluster:\nselected:  $selected\navailable: $all_archs"
      } else {
         incr nr_of_matches 1
         lappend available_selected $arch
      }
   }

   if {$nr_of_matches == 0 && [llength $selected] > 0} {
      if {$as_config_error == 1} {
         ts_log_config "none of the selected architectures is available in our cluster:\nselected:  $selected\navailable: $all_archs"
      } else {
         ts_log_severe "none of the selected architectures is available in our cluster:\nselected:  $selected\navailable: $all_archs"
      }
      return 1
   }

   # if we have selected archs, use these
   if {$available_selected != {}} {
      set all_archs $available_selected
   } else {
      # remove the excluded archs from all available
      foreach arch $excluded {
         set pos [lsearch -exact $all_archs $arch]
         if {$pos >= 0} {
            set all_archs [lreplace $all_archs $pos $pos]
         }
      }
   }

   # rebuild preferred arch list from the available archs
   # build the list of remaining_archs
   set new_preferred {}
   set remaining_archs {}
   foreach arch $all_archs {
      if {[lsearch $preferred $arch] >= 0} {
         lappend new_preferred $arch
      } else {
         lappend remaining_archs $arch
      }
   }
   set preferred $new_preferred

   # finally build the host lists
   foreach arch $preferred {
      foreach host $suited_arch_cache($arch) {
         lappend preferred_hosts $host
      }
   }
   foreach arch $remaining_archs {
      foreach host $suited_arch_cache($arch) {
         lappend remaining_hosts $host
      }
   }
}

#****** config_host/host_conf_get_suited_hosts_select() ************************
#  NAME
#     host_conf_get_suited_hosts_select() -- select hosts from candiates (internal)
#
#  SYNOPSIS
#     host_conf_get_suited_hosts_select { num_hosts preferred_hosts 
#     remaining_hosts } 
#
#  FUNCTION
#     Selects hosts from a list of preferred hosts and a list of other
#     possible hosts.
#     Internal function - only to be called from host_conf_get_suited_hosts.
#
#  INPUTS
#     num_hosts       - number of hosts to return
#     preferred_hosts - the preferred hosts
#     remaining_hosts - other hosts (second choice)
#
#  RESULT
#     List of selected hosts.
#
#  SEE ALSO
#     config_host/host_conf_get_suited_hosts()
#*******************************************************************************
proc host_conf_get_suited_hosts_select {num_hosts preferred_hosts remaining_hosts} {
   global suited_host_cache
   global CHECK_DETERMINISTIC_HOST_SELECT

   set ret {}

   # first take hosts from the preferred host list
   if {$CHECK_DETERMINISTIC_HOST_SELECT} {
      set hosts $preferred_hosts
   } else {
      # sort the list by "not used for the longest time"
      set hosts [lsort -command host_conf_sort_suited $preferred_hosts]
   }
   set hosts [valgrind_sort_hosts $hosts]

   foreach host $hosts {
      if {$num_hosts <= 0} {
         break
      }
      lappend ret $host
      set suited_host_cache($host) [timestamp]
      incr num_hosts -1
   }

   # if we need more hosts than available in the preferred hosts, 
   # take hosts from the remaining_hosts
   if {$num_hosts > 0} {
      if {$CHECK_DETERMINISTIC_HOST_SELECT} {
         set hosts $remaining_hosts
      } else {
         # sort the list by "not used for the longest time"
         set hosts [lsort -command host_conf_sort_suited $remaining_hosts]
      }
      set hosts [valgrind_sort_hosts $hosts]

      foreach host $hosts {
         if {$num_hosts <= 0} {
            break
         }
         lappend ret $host
         set suited_host_cache($host) [timestamp]
         incr num_hosts -1
      }
   }

   return $ret
}

#****** config_host/host_conf_sort_suited() ************************************
#  NAME
#     host_conf_sort_suited() -- sorting function (internal)
#
#  SYNOPSIS
#     host_conf_sort_suited { a b } 
#
#  FUNCTION
#     Used for sorting hosts by "last used" criteria.
#     Internal use only from host_conf_get_suited_host.
#
#  INPUTS
#     a - host a
#     b - host b
#
#  RESULT
#     -1, 0, 1 - similar to string compare
#
#  SEE ALSO
#     config_host/host_conf_get_suited_hosts()
#*******************************************************************************
proc host_conf_sort_suited {a b} {
   global suited_host_cache

   if {$suited_host_cache($a) < $suited_host_cache($b)} {
      return -1
   } elseif {$suited_host_cache($a) == $suited_host_cache($b)} {
      return 0
   } else {
      return 1
   }
}

proc private_test_host_conf_get_suited_host {} {
   # any host(s) - increase number of hosts until it failes
   set num_hosts 1
   while {1} {
      set hosts [host_conf_get_suited_hosts $num_hosts]
      puts "-> $num_hosts\t$hosts"
      if {$hosts == {}} {
         break
      }
      after 1000
      incr num_hosts
   }

   # test preferred hosts
   # 1 which should match my test cluster
   set hosts [host_conf_get_suited_hosts 1 "sol-sparc64"]
   puts "-> $hosts" ; wait_for_enter
   # here we should see fillup with other archs
   set hosts [host_conf_get_suited_hosts 4 "sol-sparc64"]
   puts "-> $hosts" ; wait_for_enter
   # this one will fail
   set hosts [host_conf_get_suited_hosts 1 "nonexisting-arch"]
   puts "-> $hosts" ; wait_for_enter

   # test selected hosts
   # 1 which should match my test cluster
   set hosts [host_conf_get_suited_hosts 1 {} "sol-sparc64"]
   puts "-> $hosts" ; wait_for_enter
   # this one should fail due to lack of 4 sol-sparc64 hosts
   set hosts [host_conf_get_suited_hosts 4 {} "sol-sparc64"]
   puts "-> $hosts" ; wait_for_enter
   # this one will fail due to unknown arch
   set hosts [host_conf_get_suited_hosts 1 {} "nonexisting-arch"]
   puts "-> $hosts" ; wait_for_enter
   # multiple selected archs with a preferred one
   set hosts [host_conf_get_suited_hosts 2 "sol-sparc64" "sol-amd64 sol-sparc64"]
   puts "-> $hosts" ; wait_for_enter

   # test excluded archs
   set hosts [host_conf_get_suited_hosts 6 "" "" "sol-amd64"]
   puts "-> $hosts" ; wait_for_enter

   # this one should return a error
   set hosts [host_conf_get_suited_hosts 1 "" "sol-amd64 sol-sparc64" "sol-amd64"]
   puts "-> $hosts" ; wait_for_enter
}

# ============================= start JAVA ===============================
# The cache of detected java versions per host has the following format
# cache(hostlist) {host1 host2 host3 ...}
# cache(<host>,versions)            list of versions found on this host
# cache(<host>,<version>,path)      path to java installation
# cache(<host>,<version>,major)     major version, e.g. 8, 11, 17, 21
# cache(<host>,<version>,has_jni)   0|1, has include/jni.h
global host_conf_java_cache
unset -nocomplain host_conf_java_cache

# detect java installations on cluster hosts as well as compile hosts
# no need to call this function explicitly, it is called implicitly by
# - host_conf_get_java
# - host_conf_get_java_host
proc host_conf_detect_java {} {
   global host_conf_java_cache

   ts_log_fine "searching java installations on all hosts - this can take some time"

   # clear cache
   unset -nocomplain host_conf_java_cache
   set host_conf_java_cache(hosts) {}

   # get a list of all hosts which might be used by this testsuite
   # this includes non cluster hosts and compile hosts
   set host_list [host_conf_get_cluster_hosts 1 1]

   # search java on every host
   foreach host $host_list {
      ts_log_finer "looking for java on host $host"
      host_conf_detect_java_on_host $host
   }
}

# detect java installations on a specific host
# private function
proc host_conf_detect_java_on_host {host} {
   get_current_cluster_config_array ts_config
   global CHECK_USER
   global host_conf_java_cache

   # this is where we search
   set arch [resolve_arch $host]
   set default_locations {}
   switch -glob $arch {
      "fbsd-*" {
         lappend default_locations "/usr/local"
      }
      "lx-*" -
      "ulx-*" - 
      "xlx-*" {
         lappend default_locations "/usr/lib/jvm"
         lappend default_locations "/usr/lib64/jvm"
      }
      "sol-*" {
         lappend default_locations "/usr/jdk/instances"
      }
      default {
         ts_log_config "don't know where to search for Java on host $host with arch $arch"
      }
   }

   # initialize cache for this host
   lappend host_conf_java_cache(hosts) $host
   set host_conf_java_cache($host,versions) {}

   foreach location $default_locations {
      # check if location exists
      if {![remote_file_isdirectory $host $location]} {
         continue
      }
      # check for entries
      #  - being a directory
      #  - not being a link
      #  - having bin/java
      #  - optionally having include/jni.h
      set cmd "$ts_config(testsuite_root_dir)/scripts/find_java.sh"
      set output [start_remote_prog $host $CHECK_USER $cmd $location prg_exit_state 60 0 "" "" 1 0]
      if {$prg_exit_state == 0} {
         # output contains path, version, has_jni, e.g.
         #    java-11-openjdk-amd64|"11.0.23"|0
         #    java-17-openjdk-amd64|"17.0.11"|1
         #    java-21-openjdk-amd64|"21.0.3"|1
         #    java-8-openjdk-amd64|"1.8.0_412"|1
         foreach line [split $output "\n"] {
            if {[string trim $line] != ""} {
               set split_line [split $line "|"]
               set dir [lindex $split_line 0]
               set version [string trim [lindex $split_line 1] "\""]
               set has_jni [lindex $split_line 2]
               ts_log_finest "$dir:$version:$has_jni"
               set major_version [host_conf_get_major_java_version $version]

               # store in cache
               lappend host_conf_java_cache($host,versions) $version
               set host_conf_java_cache($host,$version,path) "$location/$dir"
               set host_conf_java_cache($host,$version,major) $major_version
               set host_conf_java_cache($host,$version,has_jni) $has_jni
            }
         }
      }
   }
}

# return the major version of a specific java version
proc host_conf_get_major_java_version {version} {
   if {[string match "1.8.*" $version]} {
      return 8
   } else {
      return [lindex [split $version "."] 0]
   }
}

###
# @brief returns path to java installation
#
# returns the path to a java installation on a specific host
# having a specific major version (optionally: or a newer version)
# 
# @param[in] host
# @param[in] major version
# @param[in] optionally: require_jni: java must have include/jni.h, default 0(false)
# @param[in] optionally: allow_newer: if the exact version is not found, return a newer one? default 0(false)
##
proc host_conf_get_java {host major {require_jni 0} {allow_newer 0}} {
   global host_conf_java_cache
   # detect java versions on demand
   if {![info exists host_conf_java_cache(hosts)]} {
      host_conf_detect_java
   }
   set ret ""
   if {[info exists host_conf_java_cache($host,versions)]} {
      # not exacly matching candidate versions
      set candidates {}
      foreach version $host_conf_java_cache($host,versions) {
         if {$host_conf_java_cache($host,$version,major) == $major} {
            if {$require_jni && $host_conf_java_cache($host,$version,has_jni) == 0} {
               # cannot use this version
               continue
            }
            set ret $host_conf_java_cache($host,$version,path)
            # we found what we want and are done
            break
         } elseif {$allow_newer && $host_conf_java_cache($host,$version,major) > $major} {
            if {$require_jni && $host_conf_java_cache($host,$version,has_jni) == 0} {
               # cannot use this version
               continue
            }
            # we found a possible newer candidate
            lappend candidates $version
         }
      }

      # if we didn't find the exact version but have newer candiates: find the oldest (nearest the expected)
      if {$ret == ""} {
         set min_major 99999
         foreach version $candidates {
            if {$host_conf_java_cache($host,$version,major) < $min_major} {
               set min_major $host_conf_java_cache($host,$version,major)
               set ret $host_conf_java_cache($host,$version,path)
            }
         }
      }
   }

   return $ret
}

###
# @brief return the lowest java version on a host
#
# @param[in] host
#
# @returns path of the lowest java version found on the host
##
proc host_conf_get_lowest_java {host} {
   global host_conf_java_cache
   # detect java versions on demand
   if {![info exists host_conf_java_cache(hosts)]} {
      host_conf_detect_java
   }
   set ret ""
   if {[info exists host_conf_java_cache($host,versions)]} {
      set lowest 99999
      foreach version $host_conf_java_cache($host,versions) {
         if {$host_conf_java_cache($host,$version,major) < $lowest} {
            set lowest $host_conf_java_cache($host,$version,major)
            set ret $host_conf_java_cache($host,$version,path)
         }
      }
   }

   return $ret
}

###
# @brief return a list of all java installations on a host
#
# @param[in] host
#
# @returns list of the paths of all detected java versions on the host
##
proc host_conf_get_all_java {host} {
   global host_conf_java_cache
   # detect java versions on demand
   if {![info exists host_conf_java_cache(hosts)]} {
      host_conf_detect_java
   }
   set ret {}
   if {[info exists host_conf_java_cache($host,versions)]} {
      foreach version $host_conf_java_cache($host,versions) {
         lappend ret $host_conf_java_cache($host,$version,path)
      }
   }

   return $ret
}

###
# @brief returns a host having java installed
#
# returns the name of a host
# having a specific major Java version installed (optionally: or a newer version)
# 
# @param[in] major version
# @param[in] optionally: require_jni: java must have include/jni.h, default 0(false)
# @param[in] optionally: allow_newer: if the exact version is not found, return a newer one? default 0(false)
##
proc host_conf_get_java_host {major {require_jni 0} {allow_newer 0}} {
   global host_conf_java_cache
   # detect java versions on demand
   if {![info exists host_conf_java_cache(hosts)]} {
      host_conf_detect_java
   }

   set ret ""
   # try to find the exact version on any host
   foreach host $host_conf_java_cache(hosts) {
      set path [host_conf_get_java $host $major $require_jni 1]
      if {$path != ""} {
         set ret $host
         break
      }
   }
   # not found the exact version but a newer one is OK as well?
   if {$ret == "" && $allow_newer} {
      # try to find a newer version
      foreach host $host_conf_java_cache(hosts) {
         set path [host_conf_get_java $host $major $require_jni 0]
         if {$path != ""} {
            set ret $host
            break
         }
      }
   }

   return $ret
}

# ============================== end JAVA ================================

proc host_conf_scale_timeout {host timeout_value} {
   global ts_host_config

   set factor 1
   if {[info exists ts_host_config($host,remote_timeout_factor)]} {
      set factor $ts_host_config($host,remote_timeout_factor)
   }

   return [expr $timeout_value * $factor]
}

proc host_conf_add_host_from_template {host_template_var} {
   global ts_host_config
   upvar $host_template_var host_template

   set ret 1
   set host $host_template(host)
   unset -nocomplain ts_host_config(host)

   if {[lsearch -exact $ts_host_config(hostlist) $host] >= 0} {
      puts "host $host already exists in host configuration"
      set ret 0
   }

   if {$ret} {
      lappend ts_host_config(hostlist) $host

      foreach attrib [array names host_template] {
         set ts_host_config($host,$attrib) $host_template($attrib)
      }
   }

   return $ret
}
