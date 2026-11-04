#!/bin/sh
#
# Job script of check cs3020: a child of the job allocates and writes more memory than the job
# scope may use (MemoryMax), the job script itself survives the OOM kill of its child and ends
# successfully.
#
# usage: cs3020_job.sh <sleep_before> <work_binary> <mb> <sleep_after>

sleep_before=$1
work=$2
mb=$3
sleep_after=$4

echo "sleeping $sleep_before seconds before allocating memory"
sleep $sleep_before

$work -touchM $mb -w 1
echo "work exited with $?"

echo "sleeping $sleep_after seconds after allocating memory"
sleep $sleep_after

echo "job script exiting with 0"
exit 0
