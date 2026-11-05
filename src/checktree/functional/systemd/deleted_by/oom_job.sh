#!/bin/sh
#
# Job script of check systemd_deleted_by: a child of the job allocates and writes more memory than
# the job scope may use (MemoryMax). The job script itself ends successfully if it survives the
# OOM kill of its child.
#
# With a qrsh binary as fifth argument the child is started as a task of a tightly integrated
# parallel job on the first host of the job, it then runs in its own pe task scope.
#
# usage: oom_job.sh <sleep_before> <work_binary> <mb> <sleep_after> [<qrsh_binary>]

sleep_before=$1
work=$2
mb=$3
sleep_after=$4
qrsh=$5

echo "sleeping $sleep_before seconds before allocating memory"
sleep $sleep_before

if [ "$qrsh" = "" ]; then
   $work -touchM $mb -w 1
   echo "work exited with $?"
else
   host=`head -1 $PE_HOSTFILE | cut -d " " -f 1`
   $qrsh -inherit $host $work -touchM $mb -w 1
   echo "qrsh -inherit to host $host exited with $?"
fi

echo "sleeping $sleep_after seconds after allocating memory"
sleep $sleep_after

echo "job script exiting with 0"
exit 0
