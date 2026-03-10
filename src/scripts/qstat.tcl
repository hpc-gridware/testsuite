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
#  Portions of this software are Copyright (c) 2023-2026 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

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

##
# @brief send either successfull qstat data or error data
#
# @param[in] item the item to send, either "durations" or "error_durations"
# @param[in] send_name the name to send, either "DATA" or "ERROR"
proc send_qstat_data_item {item send_name} {
   global qstat_data

   # only send data if we actually have any
   set num_data [llength $qstat_data($item)]
   if {$num_data > 0} {
      # send data
      # we send the timetamp and the list of durations
      puts "QSTAT $send_name $qstat_data(current_time) $qstat_data($item)"
      set qstat_data($item) {}
   }
}

##
# @brief send qstat data, both successfull and error data
# @param[in] next_time the next timestamp to send data
proc send_qstat_data {next_time} {
   global qstat_data

   send_qstat_data_item "durations" "DATA"
   send_qstat_data_item "error_durations" "ERROR"


   # we store durations until time > next_time
   set qstat_data(current_time) $next_time
}

##
# @brief do a qstat and measure the duration, then send the data if needed
#
# The function calls qstat and measures the duration.
# If the timestamp increased, it sends the data.
# It returns the number of ms to the next qstat, so that the caller can wait for that time.
#
# @return the number of ms to next qstat
proc do_qstat {} {
   global active interval qstat_command qstat_data

   set start_time [clock clicks -milliseconds]
   if {$active} {
      set result [catch {exec "/bin/sh" "-c" "$qstat_command >/dev/null 2>&1"} output]
      # puts $output
      set end_time [clock clicks -milliseconds]
      set end_clock [clock seconds]
      set duration [expr double($end_time - $start_time) / 1000.0]

      # we send qstat data only once a second
      # send it if the timestamp increased
      if {$end_clock > $qstat_data(current_time)} {
         send_qstat_data $end_clock
      }

      if {$result == 0} {
         lappend qstat_data(durations) $duration
      } else {
         lappend qstat_data(error_durations) $duration
      }
   }
   set end_time [clock clicks -milliseconds]

   # return the number of ms to next qstat
   set delay [expr $interval - ($end_time - $start_time)]
   if {$delay > 0} {
      set milli [expr $delay % 1000]
      set delay [expr $delay - $milli]

      # expect only knows timeouts in seconds.
      # so wait for the milliseconds, expect will timeout after the seconds
      # part
      after $milli
   } else {
      set delay 0
   }

   return $delay
}

# MAIN
if {$argc != 2} {
   puts "usage: $argv0 <SGE_ROOT> <gridengine_version>"
   exit 1
}

set sge_root [lindex $argv 0]
set gridengine_version [lindex $argv 1]
set arch     [get_arch]

#set qstat_command "$sge_root/bin/$arch/qstat -f"
#append qstat_command " -u '*'"
set qstat_command "$sge_root/bin/$arch/qstat -g c"
set qstat_data(durations) {}
set qstat_data(error_durations) {}
set qstat_data(current_time) 0

set active 0            ;# do measurements
set interval 1000       ;# default info interval: 1000 milliseconds

puts "QSTAT STARTED"

set do_exit 0
log_user 0
while { !$do_exit } {
   set sleep_time [expr [do_qstat] / 1000]
   set timeout $sleep_time
   expect_user {
      "QUIT\n" {
         set do_exit 1
         puts "QSTAT QUIT OK"
      }
      "INTERVAL*\n" {
         set interval [lindex $expect_out(0,string) 1]
         puts "QSTAT INTERVAL OK"
      }
      "START\n" {
         set active 1
         puts "QSTAT START OK"
         # initialize data time stamp
         set qstat_data(current_time) [clock seconds]
      }
      "STOP\n" {
         set active 0
         puts "QSTAT STOP OK"
         # there might still be data to be sent
         send_qstat_data 0
      }
      "*\n" {
         puts "ERROR: invalid input:  $expect_out(0,string)"
      }
   }
}
