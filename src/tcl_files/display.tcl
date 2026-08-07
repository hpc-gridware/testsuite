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

## @brief is CHECK_DISPLAY_OUTPUT a display we can actually open?
#
# Opens a real X client (xterm) rather than probing a port, as the test user and
# as root -- qrsh X11 forwarding needs both.
#
# prg_exit_state has to be BOTH declared global and passed to start_remote_prog
# as its fifth argument (the name of the variable that receives the exit state).
# Without that this proc read a variable it never bound, i.e. whatever an earlier
# unrelated remote command had left in the global, and reported that as the
# verdict of the xterm. A stale 0 made check_start_vncserver believe a server was
# "already running", skip starting one, and let the run continue against a
# display that does not exist -- the X11 checks then fail much later with
# "Can't open display", which is the symptom this proc exists to prevent.
proc check_display {} {
     global CHECK_DISPLAY_OUTPUT CHECK_USER prg_exit_state

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

     start_remote_prog $local_host "$CHECK_USER" $xterm_path "-bg darkolivegreen -fg navajowhite -sl 5000 -sb -j -display $CHECK_DISPLAY_OUTPUT -e sleep 1" prg_exit_state
     if { $prg_exit_state != 0 } {
         puts "can't open display $CHECK_DISPLAY_OUTPUT as user $CHECK_USER from host $local_host"
         return -1
     }

     if { [ have_root_passwd ] != 0 } {
         set_root_passwd
     }
     start_remote_prog "$local_host" "root" $xterm_path "-bg darkolivegreen -fg navajowhite -sl 5000 -sb -j -display $CHECK_DISPLAY_OUTPUT -e sleep 1" prg_exit_state
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

      # WAIT for the display to become usable instead of probing once.
      #
      # "vncserver :N" returns as soon as it has forked Xvnc; the display is not
      # usable yet at that moment, because xstartup still has to run and grant
      # access (xhost / xauth). A single testsuite run usually wins that race by
      # accident, which is why probing once appeared to work. It does not
      # survive concurrency: with 28 runners starting a display each, measured
      # 2026-08-07, all 28 servers came up and all 28 runs aborted here anyway,
      # so 85 of 85 test entries failed before the run was stopped.
      #
      # Retry rather than sleep a fixed time: the cost of being wrong is the
      # whole run, and a fixed sleep is either too short under load or wasted on
      # an idle machine.
      set vnc_wait_max [expr {[info exists ::CHECK_VNC_WAIT] ? $::CHECK_VNC_WAIT : 60}]
      set vnc_ok 0
      for {set vnc_waited 0} {$vnc_waited < $vnc_wait_max} {incr vnc_waited 2} {
         if {[check_display] == 0} {
            set vnc_ok 1
            break
         }
         ts_log_fine "display $vnc_host:$vnc_display not usable yet, waited ${vnc_waited}s ..."
         after 2000
      }
      if {!$vnc_ok} {
         ts_log_fine "VNC server $vnc_display on host $vnc_host does not work (waited ${vnc_wait_max}s)"
         testsuite_shutdown 1
      }
      ts_log_fine "VNC server $vnc_display on host $vnc_host is usable after ${vnc_waited}s"
   }
}


