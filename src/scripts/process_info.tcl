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
#  =================================================
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
#  Portions of this software are Copyright (c) 2023-2024 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

proc parse_cpu_time {s_cpu} {
   # TODO: handling, if cpu > 1 day
   set l_cpu [split $s_cpu ":"]
   set cpu 0

   while {[llength $l_cpu] > 0} {
      scan [lindex $l_cpu 0] "%02d" part

      switch [llength $l_cpu] {
         1 {
            incr cpu $part
         }
         2 {
            incr cpu [expr $part * 60]
         }
         3 {
            incr cpu [expr $part * 3600]
         }
      }

      set l_cpu [lreplace $l_cpu 0 0]
   }

   return $cpu
}

proc get_ps_cmd {pid} {
   global arch
   global clockticks

   switch -exact $arch {
      "fbsd-amd64" - 
      "fbsd-arm64" {
         set cmd "/bin/ps -p $pid -o vsz,time | tail -1"
      }
      "darwin" -
      "solaris" -
      "sol-sparc" -
      "solaris64" -
      "sol-sparc64" -
      "solaris86" -
      "sol-x86" -
      "sol-amd64" -
      "osol-amd64" -
      "usol-sparc" -
      "usol-sparc64" -
      "usol-x86" {
         set cmd "/usr/bin/ps -p $pid -o vsz,time | tail -1"
      }
      "lx-x86" -
      "lx-amd64" -
      "ulx-x86" -
      "ulx-amd64" -
      "xlx-amd64" {
         #set cmd "/usr/bin/ps -p $pid --no-heading -o vsz,time"
         set cmd "/usr/bin/cat /proc/$pid/stat"
         if {[catch {exec "/bin/sh" "-c" "/usr/bin/getconf CLK_TCK"} output] == 0} {
            set clockticks_str [string trim $output]
            set clockticks [expr double($clockticks_str)]
         } else {
            set clockticks 100.0
         }
      }
      default {
         set cmd ""
      }
   }

   return $cmd
}

proc get_process_info {} {
   global active interval
   global pids process clockticks

   set time_start [clock seconds]
   if {$active} {
      foreach pid $pids {
         # try to exec ps command
         if {[catch {exec "/bin/sh" "-c" $process($pid,cmd)} output] == 0} {
            if {$process($pid,format) == "ps"} {
               # output is result of ps call
               set vsz  [lindex $output 0]
               set time [lindex $output 1]
               set time [parse_cpu_time $time]
            } else {
               # output is content of /proc/pid/stat
               scan $output "%*lu %*s %*c %*d %*d %*d %*d %*d %*u %*u %*u %*u %*u %lu %lu %*d %*d %*d %*d %*d %*d %*u %lu %ld" utime stime vsize rss
               # vsize is in bytes, we report kB
               set vsz [expr $vsize / 1024]
               set time [expr double($utime + $stime) / $clockticks]
            }
            if {[info exists process($pid,time)]} {
               set timediff [expr $time - $process($pid,time)]
            } else {
               set timediff 0
            }
            set timepercent [expr int(100.0 * double($timediff) / double($interval))]
            set process($pid,time) $time
            puts "PROCESS DATA [clock seconds] $pid $process($pid,name) $vsz $timepercent"
         } else {
            puts "PROCESS ERROR [clock seconds] $pid $process($pid,name) $output"
         }
      }
   }
   set time_end [clock seconds]

   # return the number of seconds before next analysis
   set delay [expr $interval - ($time_end - $time_start)]
   if {$delay < 0} {
      set delay 0
   }

   return $delay
}

proc get_arch {} {
   global sge_root

   if {[catch {exec "$sge_root/util/arch"} output] == 0} {
      #puts "architecture is $output"
      return $output
   } else {
      puts "ERROR: cannot evaluate architecture: $output"
      exit 1
   }
}

# MAIN
if { $argc != 1 } {
   puts "usage: $argv0 <SGE_ROOT>"
   exit 1
}

set sge_root [lindex $argv 0]
set arch     [get_arch]

set active 0            ;# do measurements
set interval 5          ;# default info interval: 5 seconds
set pids {}             ;# list of pids to analyze

puts "PROCESS INFO STARTED"

set do_exit 0
log_user 0
while { !$do_exit } {
   set sleep_time [get_process_info]
   set timeout $sleep_time
   expect_user {
      "QUIT\n" {
         set do_exit 1
         puts "PROCESS INFO QUIT OK"
      }
      "INTERVAL*\n" {
         set interval [lindex $expect_out(0,string) 1]
         puts "PROCESS INFO INTERVAL OK"
      }
      "PROCESS*\n" {
         set pid [lindex $expect_out(0,string) 1]
         set cmd [get_ps_cmd $pid]
         if {[string length $cmd] > 0} {
            lappend pids $pid
            set process($pid,name) [lindex $expect_out(0,string) 2]
            set process($pid,cmd) $cmd
            if {[string first "/bin/ps" $cmd] >= 0} {
               set process($pid,format) "ps"
            } else {
               set process($pid,format) "stat"
            }
            puts "PROCESS INFO PROCESS $process($pid,name) OK"
         } else {
            puts "PROCESS INFO PROCESS ERROR: don't know ps syntax for architecture $arch"
         }
      }
      "START\n" {
         set active 1
         puts "PROCESS INFO START OK"
      }
      "STOP\n" {
         set active 0
         puts "PROCESS INFO STOP OK"
      }
      "*\n" {
         puts "ERROR: invalid input:  $expect_out(0,string)"
      }
   }
}
