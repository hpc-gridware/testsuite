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

##
# @file dbwriter_long_workload.tcl
# @brief Job-load generator for the long-running dbwriter test (CS-2234).
#
# Provides the workload namespace, which generates the job load the
# long-running dbwriter test verifies. The workload has two distinct parts:
#
#   1. First-hour deterministic workload: a fixed, defined number of jobs of
#      every type, run by every user, all completing within one clock hour,
#      so the hourly derived value h_jobs_finished for that hour has a known
#      expected value. Started only after workload::wait_for_test_hour has
#      aligned the run to a clean hour.
#
#   2. Background load: self-resubmitting pminiworm.sh chains that keep
#      producing accounting records across the multi-day part of the test.
#
# It also creates the parallel environment / queue used by the tightly-
# coupled jobs and an advance reservation so the sge_ar* tables get populated.

##
# @namespace workload
# @brief Job-load generator for the long-running dbwriter test.
namespace eval workload {
   # tunables - the defaults give a small, reproducible first-hour workload
   variable config
   array set config {
      seq_jobs_per_user      3
      array_jobs_per_user    1
      array_tasks            4
      pe_jobs_per_user       2
      pe_array_jobs_per_user 1
      pe_array_tasks         2
      job_runtime            30
      pe_slots               2
      pe_name                "dbwriter_long_pe"
      queue_name             "dbwriter_long_q"
      first_hour_budget      900
      hour_margin            15
      submit_retries         3
      worms_per_user         2
      worm_sleep             120
      worm_max_index         6000
      ar_duration            7200
   }

   variable pe_created 0       ;# 1 once setup_pe_queue created the PE
   variable queue_created 0    ;# 1 once setup_pe_queue created the queue
   variable background_jobs {} ;# job ids of the started pminiworm chains
}

##
# @brief The four test users of the long-running test.
#
# @return a list of system user names: root, CHECK_USER and the first and
#         second foreign user
proc workload::users {} {
   global CHECK_USER CHECK_FIRST_FOREIGN_SYSTEM_USER CHECK_SECOND_FOREIGN_SYSTEM_USER
   return [list "root" $CHECK_USER \
                $CHECK_FIRST_FOREIGN_SYSTEM_USER $CHECK_SECOND_FOREIGN_SYSTEM_USER]
}

##
# @brief Check that all four test users are configured.
#
# @return 0 if all users are usable, else -1 (error reported via ts_log_severe)
proc workload::verify_users {} {
   foreach user [workload::users] {
      if {$user eq ""} {
         ts_log_severe "workload: a required test user is not configured -\
                        the test needs root, CHECK_USER and two foreign users"
         return -1
      }
   }
   return 0
}

##
# @brief Number of accounting records the first-hour workload produces per user.
#
# Each array task and each PE array task is a separate finished job, so they
# count individually; a sequential PE job counts once (the PE is created with
# accounting_summary TRUE).
#
# @return the expected per-user finished-job count for the first test hour
proc workload::expected_finished_per_user {} {
   variable config
   return [expr {$config(seq_jobs_per_user) +
                 $config(array_jobs_per_user) * $config(array_tasks) +
                 $config(pe_jobs_per_user) +
                 $config(pe_array_jobs_per_user) * $config(pe_array_tasks)}]
}

##
# @brief Create the parallel environment and queue for the tightly-coupled jobs.
#
# Creates a PE with control_slaves TRUE (tight integration) and a cluster
# queue referencing it. Remembers what it created so cleanup_pe_queue can
# remove exactly those objects.
#
# @param host the host the queue is created on
# @return 0 on success, else -1 (error reported via ts_log_severe)
proc workload::setup_pe_queue {host} {
   variable config
   variable pe_created
   variable queue_created

   set pe_def(slots)              $config(pe_slots)
   set pe_def(control_slaves)     "TRUE"
   set pe_def(allocation_rule)    "\$round_robin"
   set pe_def(job_is_first_task)  "FALSE"
   set pe_def(accounting_summary) "TRUE"
   set pe_def(start_proc_args)    "NONE"
   set pe_def(stop_proc_args)     "NONE"
   set pe_def(user_lists)         "NONE"
   set pe_def(xuser_lists)        "NONE"
   if {[add_pe $config(pe_name) pe_def] != 0} {
      ts_log_severe "workload: can not create PE $config(pe_name)"
      return -1
   }
   set pe_created 1

   set q_def(slots)   [expr {$config(pe_slots) * 2}]
   set q_def(pe_list) $config(pe_name)
   if {[add_queue $config(queue_name) $host q_def] != 0} {
      ts_log_severe "workload: can not create queue $config(queue_name)"
      return -1
   }
   set queue_created 1

   ts_log_fine "workload: created PE $config(pe_name) and queue $config(queue_name)"
   return 0
}

##
# @brief Remove the parallel environment and queue created by setup_pe_queue.
#
# Idempotent - only removes objects setup_pe_queue actually created.
#
# @param host the host the queue was created on
proc workload::cleanup_pe_queue {host} {
   variable config
   variable pe_created
   variable queue_created

   if {$queue_created} {
      del_queue $config(queue_name) $host 0 1
      set queue_created 0
   }
   if {$pe_created} {
      del_pe $config(pe_name)
      set pe_created 0
   }
}

##
# @brief Submit a job, retrying transient failures.
#
# Wraps submit_job so a transient qmaster failure (EAGAIN-style) does not
# abort the long-running test - the submission is retried a few times.
#
# @param qsub_args the qsub argument string
# @param user      the system user to submit as
# @return the job id (> 0) on success, else -1 (error reported via ts_log_severe)
proc workload::submit_retry {qsub_args user} {
   variable config

   for {set attempt 1} {$attempt <= $config(submit_retries)} {incr attempt} {
      set jobid [submit_job $qsub_args 0 60 "" $user]
      if {$jobid > 0} {
         return $jobid
      }
      ts_log_fine "workload: submission as $user failed\
                   (attempt $attempt/$config(submit_retries)), retrying"
      sleep_for_seconds 5
   }
   ts_log_severe "workload: job submission as $user failed after\
                  $config(submit_retries) attempts: $qsub_args"
   return -1
}

##
# @brief Submit the first-hour deterministic job set for one user.
#
# Submits, as user, the configured number of sequential, array, tightly-
# coupled PE and PE-array jobs. No pminiworm jobs - those are background load.
#
# @param user the system user to submit as
# @param host unused, reserved for host-targeted submission
# @return a list of submitted job ids, or -1 if a submission failed
proc workload::submit_user_jobs {user host} {
   variable config
   get_current_cluster_config_array ts_config

   set sleeper "$ts_config(product_root)/examples/jobs/sleeper.sh"
   set pe_job  "$ts_config(testsuite_root_dir)/scripts/pe_job.sh"
   set pe_task "$ts_config(testsuite_root_dir)/scripts/pe_task.sh"
   set runtime $config(job_runtime)
   set pe_opts "-pe $config(pe_name) $config(pe_slots) -q $config(queue_name)"

   set job_ids {}

   # sequential sleeper jobs
   for {set i 0} {$i < $config(seq_jobs_per_user)} {incr i} {
      set jid [workload::submit_retry \
         "-N dbwl_seq -o /dev/null -e /dev/null $sleeper $runtime" $user]
      if {$jid <= 0} {
         return -1
      }
      lappend job_ids $jid
   }

   # array sleeper jobs
   for {set i 0} {$i < $config(array_jobs_per_user)} {incr i} {
      set jid [workload::submit_retry \
         "-N dbwl_arr -t 1-$config(array_tasks) -o /dev/null -e /dev/null\
          $sleeper $runtime" $user]
      if {$jid <= 0} {
         return -1
      }
      lappend job_ids $jid
   }

   # tightly-coupled PE jobs (sequential)
   for {set i 0} {$i < $config(pe_jobs_per_user)} {incr i} {
      set jid [workload::submit_retry \
         "-N dbwl_pe $pe_opts -o /dev/null -j y $pe_job $pe_task 1 $runtime" $user]
      if {$jid <= 0} {
         return -1
      }
      lappend job_ids $jid
   }

   # tightly-coupled PE array jobs
   for {set i 0} {$i < $config(pe_array_jobs_per_user)} {incr i} {
      set jid [workload::submit_retry \
         "-N dbwl_pearr -t 1-$config(pe_array_tasks) $pe_opts -o /dev/null -j y\
          $pe_job $pe_task 1 $runtime" $user]
      if {$jid <= 0} {
         return -1
      }
      lappend job_ids $jid
   }

   ts_log_fine "workload: submitted [llength $job_ids] first-hour jobs as $user"
   return $job_ids
}

##
# @brief Decide whether a clean clock-hour window is available at a given time.
#
# Pure helper (no sleeping), so the hour-alignment logic can be unit-tested.
# The hourly derived value h_jobs_finished is calculated at the hour boundary,
# so the first-hour workload must run entirely inside one clock hour, and that
# hour must not be the one ending at midnight (where the daily values are also
# calculated):
#
#   - if less than one hour remains before midnight, the caller must wait
#     until just after midnight and re-decide;
#   - if less than needed_seconds remain in the current hour, the caller must
#     wait until just after the next hour boundary and re-decide;
#   - otherwise a full, sufficient hour window is available now.
#
# @param now            an epoch timestamp (as from clock seconds)
# @param needed_seconds the time the first-hour workload needs to complete
# @return a list {action seconds}: action "start" => a window is available now
#         (seconds is 0); action "wait" => sleep seconds, then call again
proc workload::hour_window_decision {now needed_seconds} {
   variable config
   set margin $config(hour_margin)

   set hh [scan [clock format $now -format %H] %d]
   set mm [scan [clock format $now -format %M] %d]
   set ss [scan [clock format $now -format %S] %d]

   set into_hour        [expr {$mm * 60 + $ss}]
   set left_in_hour     [expr {3600 - $into_hour}]
   set left_to_midnight [expr {(23 - $hh) * 3600 + $left_in_hour}]

   if {$left_to_midnight < 3600} {
      return [list wait [expr {$left_to_midnight + $margin}]]
   }
   if {$left_in_hour >= $needed_seconds} {
      return [list start 0]
   }
   return [list wait [expr {$left_in_hour + $margin}]]
}

##
# @brief Wait for a clean clock-hour window before the first-hour workload.
#
# Blocks until workload::hour_window_decision reports that a full, sufficient
# hour window is available (see there for the rules).
#
# @param needed_seconds the time the first-hour workload needs to complete
# @return 0 once a suitable window has been reached
proc workload::wait_for_test_hour {needed_seconds} {
   while {1} {
      lassign [workload::hour_window_decision [clock seconds] $needed_seconds] \
         action seconds
      if {$action eq "start"} {
         ts_log_fine "workload: a full hour window is available -\
                      starting the first-hour workload"
         return 0
      }
      ts_log_fine "workload: no clean hour window yet - waiting ${seconds}s"
      sleep_for_seconds $seconds "waiting for a clean test hour"
   }
}

##
# @brief Run the first-hour deterministic workload.
#
# Aligns to a clean clock hour (workload::wait_for_test_hour), submits the
# defined job set for all four users, waits for every job to finish and
# verifies the whole set completed inside a single clock hour.
#
# @param host the host the jobs target
# @return 0 on success, else -1 (error reported via ts_log_severe)
proc workload::run_first_hour {host} {
   variable config

   if {[workload::verify_users] != 0} {
      return -1
   }
   if {[workload::wait_for_test_hour $config(first_hour_budget)] != 0} {
      return -1
   }

   set hour_start [clock seconds]
   set all_jobs {}
   foreach user [workload::users] {
      set ids [workload::submit_user_jobs $user $host]
      if {$ids eq "-1"} {
         return -1
      }
      set all_jobs [concat $all_jobs $ids]
   }
   ts_log_fine "workload: first-hour set submitted ([llength $all_jobs] jobs),\
                waiting for completion"

   if {[wait_for_end_of_all_jobs $config(first_hour_budget)] != 0} {
      ts_log_severe "workload: the first-hour jobs did not all finish within\
                     $config(first_hour_budget)s"
      return -1
   }

   set hour_start_h [clock format $hour_start -format %H]
   set hour_end_h   [clock format [clock seconds] -format %H]
   if {$hour_start_h ne $hour_end_h} {
      ts_log_severe "workload: the first-hour workload crossed an hour boundary\
                     ($hour_start_h -> $hour_end_h) - h_jobs_finished is not\
                     deterministic"
      return -1
   }
   ts_log_fine "workload: first-hour workload completed inside clock hour $hour_start_h"
   return 0
}

##
# @brief Create an advance reservation spanning at least two hours.
#
# @param host the host qrsub runs on
# @return the advance reservation id (> 0) on success, else -1 (error
#         reported via ts_log_severe)
proc workload::create_ar {host} {
   variable config

   set ar_id [submit_ar "-d $config(ar_duration) -q $config(queue_name)" $host "" 0]
   if {$ar_id <= 0} {
      ts_log_severe "workload: can not create advance reservation (rc=$ar_id)"
      return -1
   }
   ts_log_fine "workload: created advance reservation $ar_id\
                (duration $config(ar_duration)s)"
   return $ar_id
}

##
# @brief Submit a job into an advance reservation.
#
# @param ar_id the advance reservation id (as returned by workload::create_ar)
# @param user  the system user to submit as
# @param host  unused, reserved for host-targeted submission
# @return the job id (> 0) on success, else -1
proc workload::submit_into_ar {ar_id user host} {
   variable config
   get_current_cluster_config_array ts_config

   set sleeper "$ts_config(product_root)/examples/jobs/sleeper.sh"
   return [workload::submit_retry \
      "-ar $ar_id -N dbwl_ar -o /dev/null -e /dev/null $sleeper $config(job_runtime)" \
      $user]
}

##
# @brief Delete an advance reservation.
#
# @param ar_id the advance reservation id (a value <= 0 is ignored)
proc workload::delete_ar_reservation {ar_id} {
   if {$ar_id > 0} {
      delete_ar $ar_id
   }
}

##
# @brief Start the background load for the multi-day part of the test.
#
# Submits, for every user, the configured number of pminiworm.sh chains.
# pminiworm.sh sleeps and then resubmits itself, so each chain keeps producing
# accounting records over the whole run. The chain is bounded by worm_max_index
# so an aborted test does not leave it resubmitting forever; workload::stop_-
# background_load ends it earlier.
#
# @return 0 once the background load has been started
proc workload::start_background_load {} {
   variable config
   variable background_jobs
   get_current_cluster_config_array ts_config

   set worm "$ts_config(testsuite_root_dir)/scripts/pminiworm.sh"
   set worm_args "-s $config(worm_sleep) -i 1 -m $config(worm_max_index) -e $worm"
   set background_jobs {}

   foreach user [workload::users] {
      for {set i 0} {$i < $config(worms_per_user)} {incr i} {
         set jid [workload::submit_retry \
            "-o /dev/null -e /dev/null $worm $worm_args" $user]
         if {$jid > 0} {
            lappend background_jobs $jid
         }
      }
   }
   ts_log_fine "workload: background load started ([llength $background_jobs] worms)"
   return 0
}

##
# @brief Stop the background load.
#
# The pminiworm chains stop resubmitting once their current job is gone, so
# deleting all jobs ends them. Intended for test teardown, when only the
# background load is still running.
proc workload::stop_background_load {} {
   variable background_jobs

   if {[llength $background_jobs] > 0} {
      delete_all_jobs
      wait_for_end_of_all_jobs 120
   }
   set background_jobs {}
}
