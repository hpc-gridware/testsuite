#!/bin/sh
#
# Job script of check systemd_deleted_by: a tightly integrated parallel job, submitted with
# -notify, whose pe task writes more memory than its pe task scope may use (MemoryMax) when it
# gets the notify signal SIGUSR2. When the job is deleted with qdel, the pe task is ended by the
# OOM killer during the notify time, after qdel was recorded as the one who deleted the job.
#
# usage: notify_oom_job.sh master <work_binary> <qrsh_binary> <path_of_this_script>
#        notify_oom_job.sh task <work_binary>

mode=$1
work=$2

if [ "$mode" = "task" ]; then
   trap 'echo "pe task got SIGUSR2"; $work -touchM 300 -w 1; echo "work exited with $?"' USR2
   # wait returns when a trapped signal arrives, the second wait for the trap's sleep
   sleep 300 &
   wait $!
   wait $!
   echo "pe task exiting"
   exit 0
fi

qrsh=$3
script=$4

trap 'echo "master task got SIGUSR2"' USR2
host=`head -1 $PE_HOSTFILE | cut -d " " -f 1`
$qrsh -inherit $host $script task $work &
sleep 300 &
wait $!
wait
echo "master task exiting"
exit 0
