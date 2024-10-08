#!/bin/sh
#
#$ -S /bin/sh
#$ -cwd
#set -x

amount=$1
duration=$2

start_time=0
if [ $# -ge 3 ]; then
   start_time=$3
fi

# do not inherit SGE_DEBUG_LEVEL
unset SGE_DEBUG_LEVEL

ARCH=`$SGE_ROOT/util/arch`

# wait until start_time
# we want to submit all jobs (from all hosts where we started this script) at the same time
# to put even more load on sge_qmaster / event master
if [ $start_time -gt 0 ]; then
   NOW="$SGE_ROOT/utilbin/$ARCH/now"
   while [ `$NOW` -lt $start_time ]; do
      sleep 1
   done
fi

# workaround for CS-666
# when we set the event client interval to 15 seconds (instead of the default 30 seconds)
# the issue does not happen
SGE_JAPI_EDTIME=15
export SGE_JAPI_EDTIME

# submit n qsub -sync sleeper
x=0
while [ $x -lt $amount ]; do
   qsub -sync y -b y -o /dev/null -j y sleep $duration &
   x=`expr $x + 1`
done

# wait for the qsub -sync to exit
x=0
while [ $x -lt $amount ]; do
   x=`expr $x + 1`
   wait
   wait
done

echo "qsub_sync.sh exiting"

exit 0
