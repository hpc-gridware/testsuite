#!/bin/sh
#
#$ -S /bin/sh
#$ -cwd
#set -x

amount=$1
duration=$2

# do not inherit SGE_DEBUG_LEVEL
unset SGE_DEBUG_LEVEL

# submit n qsub -sync sleeper
x=0
while [ $x -lt $amount ]; do
   qsub -sync y -b y -o /dev/null -j y sleep $duration &
   x=`expr $x + 1`
   if [ `expr $x % 5` -eq 0 ]; then
      sleep 1
   fi
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
