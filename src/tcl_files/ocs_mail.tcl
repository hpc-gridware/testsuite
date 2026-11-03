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

# ocs_mail.tcl
#
# Capturing the mails the cluster sends. ocs_mail_capture_enable() replaces the
# configured mailer by scripts/ocs_mail_capture.sh, which stores every mail as a
# JSON file in a capture directory instead of delivering it; ocs_mail_capture_get()
# returns the captured mails as dicts with the members argv, subject, recipients,
# body, user, uid, host and time (see the script for their meaning).
#
#    ocs_mail_capture_enable
#    ... provoke a mail ...
#    ocs_mail_capture_get mails 1
#    set subject [dict get [lindex $mails 0] subject]
#    ocs_mail_capture_disable
#
# Only one capture is active at a time. Its state is kept in the global array
# ocs_mail_capture, because source_tcl_files() redefines the procedures.

## @brief Replace the mailer of the cluster by the capturing mailer
#
# Creates the capture directory and the wrapper the cluster calls as its mailer,
# and sets that wrapper as mailer in the global configuration and in every local
# configuration that defines a mailer of its own - the testsuite installs a local
# mailer on the hosts, and a local value hides the global one. The previous
# configurations are kept for ocs_mail_capture_disable().
#
# The directory is in the testsuite results directory, which every host of the
# cluster mounts, and is writable for everybody: the mailer runs as the user the
# daemon runs as, not as the user running the testsuite.
#
# @param hosts the hosts whose local configuration is checked for a mailer;
#              "" means the execution hosts and the master host
# @return the capture directory, "" on error
proc ocs_mail_capture_enable {{hosts ""}} {
   get_current_cluster_config_array ts_config
   global ocs_mail_capture

   if {[info exists ocs_mail_capture(dir)]} {
      ts_log_severe "a mail capture is already active in $ocs_mail_capture(dir)"
      return ""
   }

   set dir [get_tmp_directory_name "" "mail_capture"]
   if {[catch {
      file mkdir $dir
      file attributes $dir -permissions 0777
      set wrapper "$dir/mailer.sh"
      set f [open $wrapper "w"]
      puts $f "#!/bin/sh"
      puts $f "exec $ts_config(testsuite_root_dir)/scripts/ocs_mail_capture.sh $dir \"\$@\""
      close $f
      file attributes $wrapper -permissions 0755
   } err]} {
      ts_log_severe "cannot create the mail capture directory $dir: $err"
      return ""
   }

   if {$hosts == ""} {
      set hosts [lsort -unique [concat $ts_config(execd_nodes) $ts_config(master_host)]]
   }

   if {[get_config global_backup] != 0} {
      file delete -force $dir
      return ""
   }
   set ocs_mail_capture(dir) $dir
   set ocs_mail_capture(global) [array get global_backup]
   set ocs_mail_capture(hosts) {}

   set conf(mailer) $wrapper
   set_config_and_propagate conf

   foreach host $hosts {
      unset -nocomplain host_backup
      if {[get_config host_backup $host 60 0] != 0 || ![info exists host_backup(mailer)]} {
         continue
      }
      lappend ocs_mail_capture(hosts) $host [array get host_backup]
      set hconf(mailer) $wrapper
      set_config_and_propagate hconf $host
   }

   ts_log_fine "capturing mails in $dir"
   return $dir
}

## @brief Return the mails captured so far, waiting for a minimum number
#
# Each mail is one JSON file in the capture directory. The files are written
# under a hidden name and renamed when complete, so a file that is visible is
# complete. The directory is on NFS: a mail written on another host may take a
# moment to become visible here, which the wait covers.
#
# @param mails_var name of the variable the mails are returned in, a list of
#                  dicts ordered by the time they were sent
# @param min       the number of mails to wait for; 0 returns at once
# @param timeout   seconds to wait for them
# @param raise_error whether to report a timeout as an error
# @return the number of mails found, -1 on error
proc ocs_mail_capture_get {mails_var {min 1} {timeout 60} {raise_error 1}} {
   global ocs_mail_capture
   upvar $mails_var mails

   set mails {}
   if {![info exists ocs_mail_capture(dir)]} {
      ts_log_severe "no mail capture is active" $raise_error
      return -1
   }
   package require json

   set end [expr {[clock seconds] + [ts_scale_timeout $timeout]}]
   while {1} {
      set files [glob -nocomplain -directory $ocs_mail_capture(dir) "mail.*.json"]
      if {[llength $files] >= $min || [clock seconds] >= $end} {
         break
      }
      after 1000
   }

   set entries {}
   foreach file $files {
      if {[catch {
         set f [open $file "r"]
         set text [read $f]
         close $f
         set mail [::json::json2dict $text]
      } err]} {
         ts_log_severe "cannot read the captured mail $file: $err" $raise_error
         return -1
      }
      lappend entries [list [dict get $mail time] $file $mail]
   }
   foreach entry [lsort -integer -index 0 [lsort -index 1 $entries]] {
      lappend mails [lindex $entry 2]
   }

   if {[llength $mails] < $min} {
      ts_log_severe "expected at least $min mail(s) in $ocs_mail_capture(dir), got [llength $mails]" \
                    $raise_error
   }
   return [llength $mails]
}

## @brief Remove the mails captured so far, keeping the capture active
#
# @return nothing
proc ocs_mail_capture_clear {} {
   global ocs_mail_capture

   if {[info exists ocs_mail_capture(dir)]} {
      foreach file [glob -nocomplain -directory $ocs_mail_capture(dir) "mail.*.json"] {
         file delete -force $file
      }
   }
}

## @brief Restore the mailer configuration and remove the capture directory
#
# Safe to call when no capture is active, so that a cleanup function can call
# it unconditionally.
#
# @return nothing
proc ocs_mail_capture_disable {} {
   global ocs_mail_capture

   if {![info exists ocs_mail_capture(dir)]} {
      return
   }

   foreach {host backup} $ocs_mail_capture(hosts) {
      unset -nocomplain host_backup
      array set host_backup $backup
      reset_config_and_propagate host_backup $host
   }
   array set global_backup $ocs_mail_capture(global)
   reset_config_and_propagate global_backup

   file delete -force $ocs_mail_capture(dir)
   unset ocs_mail_capture
}
