#___INFO__MARK_BEGIN_NEW__
###########################################################################
#  
#  Copyright 2023-2024 HPC-Gridware GmbH
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

proc check_display {} {
     global CHECK_DISPLAY_OUTPUT CHECK_USER

     if { [ string compare $CHECK_DISPLAY_OUTPUT "undefined" ] == 0 } {
        puts "no debug x display set"
        return -1
     }

     if { [ have_root_passwd ] != 0 } {
         set_root_passwd
     }

     ts_log_fine "using display: $CHECK_DISPLAY_OUTPUT"

     set local_host [gethostname]
     set xterm_path [get_binary_path $local_host "xterm"]

     start_remote_prog $local_host "$CHECK_USER" $xterm_path "-bg darkolivegreen -fg navajowhite -sl 5000 -sb -j -display $CHECK_DISPLAY_OUTPUT -e sleep 1"
     if { $prg_exit_state != 0 } {
         puts "can't open display $CHECK_DISPLAY_OUTPUT as user $CHECK_USER from host $local_host"
         return -1
     }

     if { [ have_root_passwd ] != 0 } {
         set_root_passwd
     }
     start_remote_prog "$local_host" "root" $xterm_path "-bg darkolivegreen -fg navajowhite -sl 5000 -sb -j -display $CHECK_DISPLAY_OUTPUT -e sleep 1"
     if { $prg_exit_state != 0 } {
         puts "can't open display $CHECK_DISPLAY_OUTPUT as user root from host $local_host"
         return -1
     }
     return 0
}

proc start_vncserver {host display} {
   global CHECK_USER

   set cmd "nohup"
   set args "vncserver :$display"
   set output [start_remote_prog $host $CHECK_USER $cmd $args dummy 60 1]
   ts_log_fine $output
}

proc check_start_vncserver {} {
   global CHECK_USER
   global CHECK_DISPLAY_OUTPUT

   if {[string first ":" $CHECK_DISPLAY_OUTPUT] <= 0} {
      puts "vncserver display must be given in the form <hostname>:<display>"
      testsuite_shutdown 1
   }
   set vnc_host [lindex [split $CHECK_DISPLAY_OUTPUT ":"] 0]
   set vnc_display [lindex [split $CHECK_DISPLAY_OUTPUT ":"] 1]
   if {$vnc_host == "" || $vnc_display == ""} {
      puts "vncserver display must be given in the form <hostname>:<display>"
      testsuite_shutdown 1
   }

   ts_log_fine "starting if there is a X-server running on $vnc_host display $vnc_display"
   if {[check_display] == 0} {
      ts_log_fine "vnc server / X-server $vnc_display on host $vnc_host is already running"
   } else {
      ts_log_fine "starting VNC server $vnc_display on host $vnc_host"
      start_vncserver $vnc_host $vnc_display
      if {[check_display] != 0} {
         ts_log_fine "VNC server $vnc_display on host $vnc_host does not work"
         testsuite_shutdown 1
      }
   }
}


