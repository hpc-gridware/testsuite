#!/bin/sh
#$ -S /bin/sh
#
# Job script of a tightly integrated parallel job: starts one task per granted host with
# qrsh -inherit and exits with 1 as soon as one of the tasks failed.
#
# $1: the path of qrsh
# $2: the seconds each task sleeps

qrsh=$1
seconds=$2

# a failed task signals the job script, wait returns at once when the signal arrives
trap 'exit 1' USR1

while read host slots rest; do
   ($qrsh -inherit -nostdin $host sleep $seconds || /bin/kill -USR1 $$) &
done < $PE_HOSTFILE

wait
exit 0
