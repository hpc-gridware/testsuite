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
      job_runtime            45
      job_h_rt               600
      pe_slots               2
      pe_name                "dbwriter_long.pe"
      pe_name_summary        "dbwriter_long_summary.pe"
      queue_name             "dbwriter_long.q"
      queue_slots            32
      project_name           "dbwriter_long.prj"
      first_hour_budget      900
      hour_margin            15
      submit_retries         3
      worms_per_user         2
      worm_sleep             30
      worm_max_index         6000
      ar_duration                  7200
      long_hours_past_midnight2    2
      long_h_rt_grace              7200
      long_array_tasks             3
      long_pe_array_tasks          2
   }

   variable pe_created 0         ;# 1 once setup_pe_queue created the per-task PE
   variable pe_summary_created 0 ;# 1 once setup_pe_queue created the summary PE
   variable queue_created 0      ;# 1 once setup_pe_queue created the queue
   variable project_created 0    ;# 1 once setup_project created the project
   variable background_jobs {}   ;# job ids of the started pminiworm chains
   variable first_hour_epoch 0   ;# clock seconds the first-hour workload started
   variable long_running_jobs    ;# array, keyed by kind, of long-running job descriptors
   array set long_running_jobs {}
   variable long_target_end 0    ;# epoch the long-running jobs should finish at
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
# @brief Epoch second when the first-hour workload started.
#
# Set by workload::run_first_hour after the hour-alignment wait. Read by the
# follow-up phase assertions (Phase E, Phase F) to know which clock hour and
# clock day the deterministic workload was active in.
#
# @return the start time of the first-hour workload as clock seconds, or 0
#         if run_first_hour has not run yet
proc workload::get_first_hour_epoch {} {
   variable first_hour_epoch
   return $first_hour_epoch
}

##
# @brief Name of the project the workload jobs run under.
#
# @return the project name (used by per-project assertions)
proc workload::get_project_name {} {
   variable config
   return $config(project_name)
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
# This is the expected per-user row count of the sge_job_usage table - one row
# per finished unit of work:
#   - a sequential job counts once,
#   - an array job counts once per array task,
#   - the PE is created with accounting_summary FALSE and job_is_first_task
#     TRUE, so a tightly-integrated PE job is accounted per task and counts
#     pe_slots times (one record per task - the master/first task plus the
#     pe tasks); a PE array job counts that for every array task.
#
# @return the expected per-user finished-job count for the first test hour
proc workload::expected_finished_per_user {} {
   variable config
   return [expr {$config(seq_jobs_per_user) +
                 $config(array_jobs_per_user) * $config(array_tasks) +
                 $config(pe_jobs_per_user) * $config(pe_slots) +
                 $config(pe_array_jobs_per_user) * $config(pe_array_tasks) * $config(pe_slots)}]
}

##
# @brief Number of sge_job rows the first-hour workload produces per user.
#
# A sge_job row is keyed by (j_job_number, j_task_number, j_pe_taskid). The
# new_job reporting record written at submission time creates a whole-job row
# with j_task_number = -1 (and, for an array job, one row per array task). The
# PE is created with job_is_first_task TRUE, so the master task is the job's
# first task: it carries an empty j_pe_taskid and its accounting record updates
# the whole-job (resp. array-task) row instead of creating a new one. Only the
# pe_slots - 1 additional pe tasks each get their own row. Counted per job type:
#   - sequential job:  1 whole-job row (it is also the finished-unit row),
#   - array job:       1 whole-job row + one row per array task,
#   - PE job:          1 whole-job row (shared by the master task)
#                      + pe_slots - 1 additional pe task rows  => pe_slots rows,
#   - PE array job:    1 whole-job row + per array task: 1 array-task row
#                      (shared by the master task) + pe_slots - 1 pe task rows
#                                      => 1 + pe_array_tasks * pe_slots rows.
#
# @return the expected per-user sge_job row count for the first test hour
proc workload::expected_job_rows_per_user {} {
   variable config
   return [expr {$config(seq_jobs_per_user) +
                 $config(array_jobs_per_user) * (1 + $config(array_tasks)) +
                 $config(pe_jobs_per_user) * $config(pe_slots) +
                 $config(pe_array_jobs_per_user) * (1 + $config(pe_array_tasks) *
                       $config(pe_slots))}]
}

##
# @brief Create the parallel environments and queue for the tightly-coupled jobs.
#
# Creates two PEs and a cluster queue across the given exec hosts:
#   - pe_name        with accounting_summary FALSE (one accounting record per pe-task)
#   - pe_name_summary with accounting_summary TRUE  (one summary record per job)
# Both PEs are tightly integrated (control_slaves TRUE, job_is_first_task TRUE)
# and added to the queue's pe_list. Remembers what it created so cleanup_pe_queue
# can remove exactly those objects.
#
# @param hosts list of exec hosts the queue is created on
# @return 0 on success, else -1 (error reported via ts_log_severe)
proc workload::setup_pe_queue {hosts} {
   variable config
   variable pe_created
   variable pe_summary_created
   variable queue_created

   # base PE definition shared by the summary and per-task PEs
   set pe_def(slots)              [expr {$config(pe_slots) * 10}]
   set pe_def(control_slaves)     "TRUE"
   set pe_def(allocation_rule)    "\$round_robin"
   # job_is_first_task TRUE: the master task counts as the job's first task, so
   # a PE job has exactly pe_slots tasks (the master plus the pe tasks)
   set pe_def(job_is_first_task)  "TRUE"
   set pe_def(start_proc_args)    "NONE"
   set pe_def(stop_proc_args)     "NONE"
   set pe_def(user_lists)         "NONE"
   set pe_def(xuser_lists)        "NONE"

   # per-task PE: every pe-task is reported and accounted on its own, so the
   # dbwriter writes an individual record per task
   set pe_def(accounting_summary) "FALSE"
   if {[add_pe $config(pe_name) pe_def] != 0} {
      ts_log_severe "workload: can not create PE $config(pe_name)"
      return -1
   }
   set pe_created 1

   # summary PE: the master task aggregates the slave tasks' usage and the
   # dbwriter writes one accounting record per job (or per array task)
   set pe_def(accounting_summary) "TRUE"
   if {[add_pe $config(pe_name_summary) pe_def] != 0} {
      ts_log_severe "workload: can not create PE $config(pe_name_summary)"
      return -1
   }
   set pe_summary_created 1

   set q_def(slots)   $config(queue_slots)
   set q_def(pe_list) "$config(pe_name) $config(pe_name_summary)"
   if {[add_queue $config(queue_name) $hosts q_def] != 0} {
      ts_log_severe "workload: can not create queue $config(queue_name)"
      return -1
   }
   set queue_created 1

   ts_log_fine "workload: created PEs $config(pe_name) and\
                $config(pe_name_summary), queue $config(queue_name) on\
                [llength $hosts] host(s)"
   return 0
}

##
# @brief Remove the parallel environments and queue created by setup_pe_queue.
#
# Idempotent - only removes objects setup_pe_queue actually created.
#
# @param hosts list of exec hosts the queue was created on
proc workload::cleanup_pe_queue {hosts} {
   variable config
   variable pe_created
   variable pe_summary_created
   variable queue_created

   if {$queue_created} {
      del_queue $config(queue_name) $hosts 0 1
      set queue_created 0
   }
   if {$pe_created} {
      del_pe $config(pe_name)
      set pe_created 0
   }
   if {$pe_summary_created} {
      del_pe $config(pe_name_summary)
      set pe_summary_created 0
   }
}

##
# @brief Create the project the workload jobs run under.
#
# All workload jobs request this project (see workload::submit_retry) so the
# dbwriter's per-project hourly derived values - e.g. h_jobs_finished - get
# data. Remembers whether the project was created so cleanup_project removes
# exactly that object.
#
# @return 0 on success, else -1 (error reported via ts_log_severe)
proc workload::setup_project {} {
   variable config
   variable project_created

   if {[add_project $config(project_name)] < 0} {
      ts_log_severe "workload: can not create project $config(project_name)"
      return -1
   }
   set project_created 1

   ts_log_fine "workload: created project $config(project_name)"
   return 0
}

##
# @brief Remove the project created by setup_project.
#
# Idempotent - only removes the project if setup_project actually created it.
proc workload::cleanup_project {} {
   variable config
   variable project_created

   if {$project_created} {
      del_project $config(project_name)
      set project_created 0
   }
}

##
# @brief Submit a job, retrying transient failures.
#
# Wraps submit_job so a transient qmaster failure (EAGAIN-style) does not
# abort the long-running test - the submission is retried a few times.
#
# Every job is submitted under the test project so the dbwriter's per-project
# hourly derived values get data.
#
# @param qsub_args the qsub argument string
# @param user      the system user to submit as
# @return the job id (> 0) on success, else -1 (error reported via ts_log_severe)
proc workload::submit_retry {qsub_args user} {
   variable config

   # all workload jobs run under the test project
   set qsub_args "-P $config(project_name) $qsub_args"

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
# Each job carries an explicit h_rt resource request so the dbwriter writes
# sge_job_request rows.
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
   # every job carries an explicit h_rt request, so the dbwriter writes
   # sge_job_request rows the Phase C assertions can verify
   set req     "-l h_rt=$config(job_h_rt)"

   set job_ids {}

   # sequential sleeper jobs
   for {set i 0} {$i < $config(seq_jobs_per_user)} {incr i} {
      set jid [workload::submit_retry \
         "-N dbwl_seq $req -o /dev/null -e /dev/null $sleeper $runtime" $user]
      if {$jid <= 0} {
         return -1
      }
      lappend job_ids $jid
   }

   # array sleeper jobs
   for {set i 0} {$i < $config(array_jobs_per_user)} {incr i} {
      set jid [workload::submit_retry \
         "-N dbwl_arr $req -t 1-$config(array_tasks) -o /dev/null -e /dev/null\
          $sleeper $runtime" $user]
      if {$jid <= 0} {
         return -1
      }
      lappend job_ids $jid
   }

   # tightly-coupled PE jobs (sequential)
   for {set i 0} {$i < $config(pe_jobs_per_user)} {incr i} {
      set jid [workload::submit_retry \
         "-N dbwl_pe $req $pe_opts -o /dev/null -j y $pe_job $pe_task 1 $runtime" $user]
      if {$jid <= 0} {
         return -1
      }
      lappend job_ids $jid
   }

   # tightly-coupled PE array jobs
   for {set i 0} {$i < $config(pe_array_jobs_per_user)} {incr i} {
      set jid [workload::submit_retry \
         "-N dbwl_pearr $req -t 1-$config(pe_array_tasks) $pe_opts -o /dev/null -j y\
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
   variable first_hour_epoch

   if {[workload::verify_users] != 0} {
      return -1
   }
   if {[workload::wait_for_test_hour $config(first_hour_budget)] != 0} {
      return -1
   }

   set hour_start [clock seconds]
   set first_hour_epoch $hour_start
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

   # qrsub runs on the default submit host (master); $host is the reserved
   # queue's host, not where qrsub is invoked
   set ar_id [submit_ar "-d $config(ar_duration) -q $config(queue_name)" "" "" 0]
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
# The worms run in all.q so they do not compete with the workload jobs in
# dbwriter_long.q. The trailing "-- -q all.q" tells pminiworm.sh to pass
# "-q all.q" to every internal qsub (pminiworm.sh propagates everything after
# "--" to the qsub it uses to respawn itself); the outer "-q all.q" places
# the first generation in all.q as well.
#
# @return 0 once the background load has been started
proc workload::start_background_load {} {
   variable config
   variable background_jobs
   get_current_cluster_config_array ts_config

   set worm "$ts_config(testsuite_root_dir)/scripts/pminiworm.sh"
   set worm_args "-s $config(worm_sleep) -i 1 -m $config(worm_max_index)\
                  -e $worm -- -q all.q"
   set background_jobs {}

   foreach user [workload::users] {
      for {set i 0} {$i < $config(worms_per_user)} {incr i} {
         set jid [workload::submit_retry \
            "-q all.q -o /dev/null -e /dev/null $worm $worm_args" $user]
         if {$jid > 0} {
            lappend background_jobs $jid
         }
      }
   }
   ts_log_fine "workload: background load started ([llength $background_jobs]\
                worms in all.q)"
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

##
# @brief Submit the six long-running jobs used by Phase F.
#
# Each job is a long sleeper submitted as CHECK_USER into dbwriter_long.q.
# Together they cover the per-accounting-record shapes the dbwriter has to
# handle:
#   - seq:   one sequential job          -> 1 final accounting record
#   - arr:   one array job, 3 tasks      -> 3 final records (one per task)
#   - pe_ns: one PE job (summary FALSE)  -> pe_slots records (one per pe-task)
#   - pe_s:  one PE job (summary TRUE)   -> 1 final record
#   - pa_ns: PE array (summary FALSE)    -> tasks * pe_slots final records
#   - pa_s:  PE array (summary TRUE)     -> tasks final records (one per task)
# At every midnight the job spans the qmaster writes one intermediate
# accounting record per final-record shape (ju_exit_status = -1), so the jobs
# need to be sized so they straddle two midnights to produce two intermediate
# records per shape.
#
# The runtime is computed so the jobs finish long_hours_past_midnight2 hours
# after the second midnight following the current day - the second intermediate
# accounting record is written in the 10-minute window after that midnight,
# and the test waits for the jobs to finish naturally before running the qacct
# match in block 3 of Phase F. h_rt is set above the computed runtime by
# long_h_rt_grace so a scheduler dispatch delay does not let the qmaster kill
# the job. long_target_end is stored for wait_for_long_running_finish.
#
# The submitted job IDs and the expected shape are stored in the
# long_running_jobs array (keyed by kind) so the Phase F assertions can derive
# the expected sge_job_usage row count per job.
#
# @param ref_epoch  Phase F reference epoch (the same value passed to
#                   dbwriter_long_phase_f_wait_for_midnight). Used to derive
#                   "midnight 2" so submit and wait agree on the boundary
#                   even when ref_epoch and the actual submission instant
#                   straddle a midnight.
# @return 0 if every job was submitted, else -1 (error reported via ts_log_severe)
proc workload::submit_long_running {ref_epoch} {
   variable config
   variable long_running_jobs
   variable long_target_end
   global CHECK_USER
   get_current_cluster_config_array ts_config

   array unset long_running_jobs
   array set long_running_jobs {}

   # Target end time: long_hours_past_midnight2 hours past the second midnight
   # after ref_epoch's day. clock add ... day handles DST.
   set day_str [clock format $ref_epoch -format "%Y-%m-%d"]
   set day_start [clock scan "$day_str 00:00:00" -format "%Y-%m-%d %H:%M:%S"]
   set midnight2 [clock add $day_start 2 day]
   set long_target_end [expr {$midnight2 + $config(long_hours_past_midnight2) * 3600}]
   set runtime [expr {$long_target_end - [clock seconds]}]
   set h_rt    [expr {$runtime + $config(long_h_rt_grace)}]
   ts_log_fine "workload: long-running jobs sized to end at\
                [clock format $long_target_end -format {%Y-%m-%d %H:%M:%S}]\
                (runtime ${runtime}s, h_rt ${h_rt}s)"

   set sleeper "$ts_config(product_root)/examples/jobs/sleeper.sh"
   set pe_job  "$ts_config(testsuite_root_dir)/scripts/pe_job.sh"
   set pe_task "$ts_config(testsuite_root_dir)/scripts/pe_task.sh"
   set req     "-l h_rt=$h_rt -q $config(queue_name)"
   set arr_t   $config(long_array_tasks)
   set pa_t    $config(long_pe_array_tasks)
   set slots   $config(pe_slots)

   # One entry per long-running job kind: {kind name flags summary tasks
   # pe_slots}. The flags strings reference $config(pe_name) and $slots; these
   # are substituted at [list ...] construction time, so the list must stay
   # below the local-variable initialisation above and must NOT be moved into
   # the foreach loop where each iteration would re-evaluate them.
   set defs [list \
      [list seq   "dbwl_long_seq"   "-N dbwl_long_seq"              0 1     1] \
      [list arr   "dbwl_long_arr"   "-N dbwl_long_arr -t 1-$arr_t"  0 $arr_t 1] \
      [list pe_ns "dbwl_long_pe_ns" "-N dbwl_long_pe_ns -pe $config(pe_name) $slots"          0 1     $slots] \
      [list pe_s  "dbwl_long_pe_s"  "-N dbwl_long_pe_s -pe $config(pe_name_summary) $slots"   1 1     $slots] \
      [list pa_ns "dbwl_long_pa_ns" "-N dbwl_long_pa_ns -t 1-$pa_t -pe $config(pe_name) $slots"          0 $pa_t $slots] \
      [list pa_s  "dbwl_long_pa_s"  "-N dbwl_long_pa_s -t 1-$pa_t -pe $config(pe_name_summary) $slots"   1 $pa_t $slots] \
   ]

   foreach def $defs {
      lassign $def kind name flags summary tasks pe_slots

      # PE jobs run pe_job.sh which orchestrates the pe-task starts; non-PE
      # jobs run sleeper.sh directly
      if {[string match "pe_*" $kind] || [string match "pa_*" $kind]} {
         set cmd "$pe_job $pe_task 1 $runtime"
         set io  "-o /dev/null -j y"
      } else {
         set cmd "$sleeper $runtime"
         set io  "-o /dev/null -e /dev/null"
      }
      set jid [workload::submit_retry "$flags $req $io $cmd" $CHECK_USER]
      if {$jid <= 0} {
         ts_log_severe "workload: can not submit long-running job $kind"
         return -1
      }
      set long_running_jobs($kind) [list \
         jid      $jid \
         kind     $kind \
         name     $name \
         summary  $summary \
         tasks    $tasks \
         pe_slots $pe_slots]
      ts_log_fine "workload: submitted long-running $kind (jid $jid, tasks\
                   $tasks, pe_slots $pe_slots, summary $summary)"
   }
   return 0
}

##
# @brief List the kinds of long-running jobs that have been submitted.
#
# @return a list of kind keys (seq, arr, pe_ns, pe_s, pa_ns, pa_s) - empty if
#         submit_long_running has not run yet
proc workload::get_long_running_kinds {} {
   variable long_running_jobs
   return [lsort [array names long_running_jobs]]
}

##
# @brief Return the descriptor of one long-running job.
#
# @param kind the kind key (as returned by get_long_running_kinds)
# @return a dict with keys jid, kind, name, summary, tasks, pe_slots; "" if no
#         such kind was submitted
proc workload::get_long_running_job {kind} {
   variable long_running_jobs
   if {![info exists long_running_jobs($kind)]} {
      return ""
   }
   return $long_running_jobs($kind)
}

##
# @brief Wait for every long-running job to finish.
#
# Polls qstat for the recorded job IDs at a low frequency (long-running jobs
# are not finishing in seconds). Returns once every job has left the system or
# the timeout has expired.
#
# @param timeout maximum seconds to wait. Default: (long_target_end - now) plus
#                4 h grace - the jobs are sized to finish at long_target_end,
#                so anything beyond that plus a few hours of scheduler hiccups
#                and the qmaster's accounting flush is a hang. Falls back to
#                4 h if long_target_end is not set (submit_long_running was
#                skipped).
# @return 0 if every long-running job has finished, else -1 on timeout
proc workload::wait_for_long_running_finish {{timeout 0}} {
   variable config
   variable long_running_jobs
   variable long_target_end

   if {[array size long_running_jobs] == 0} {
      return 0
   }

   if {$timeout <= 0} {
      set grace 14400
      if {$long_target_end > 0} {
         set timeout [expr {$long_target_end - [clock seconds] + $grace}]
      }
      if {$timeout < $grace} {
         set timeout $grace
      }
   }

   set jids {}
   foreach kind [array names long_running_jobs] {
      set jd $long_running_jobs($kind)
      lappend jids [dict get $jd jid]
   }
   ts_log_fine "workload: waiting up to ${timeout}s for long-running jobs:\
                $jids"

   set deadline [expr {[clock seconds] + $timeout}]
   while {1} {
      set still_running {}
      foreach jid $jids {
         # is_job_running returns 1/0 while the job is in qstat output
         # (running / queued), -1 once the job has left the system
         if {[is_job_running $jid ""] != -1} {
            lappend still_running $jid
         }
      }
      set jids $still_running
      if {[llength $jids] == 0} {
         ts_log_fine "workload: all long-running jobs have finished"
         return 0
      }
      if {[clock seconds] >= $deadline} {
         ts_log_severe "workload: long-running jobs did not finish within\
                        ${timeout}s, still in system: $jids"
         return -1
      }
      ts_log_fine "workload: [llength $jids] long-running job(s) still in\
                   system, waiting"
      sleep_for_seconds 300
   }
}
