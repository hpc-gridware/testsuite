#!/bin/sh

# avoid locale specific messages testsuite will report as INFO, e.g.
# unexpected job output: Benutzerdefiniertes Signal 2
LANG=C
export LANG

# for testing limits and/or -notify option
trap "echo pe task received SIGUSR1" USR1
trap "echo pe task received SIGUSR2" USR2

# exit code this task shall use - optional, a caller which does not pass one
# gets the exit code 0 this script always had
exit_code=$3
if [ "$exit_code" = "" ]; then
   exit_code=0
fi

unset SGE_DEBUG_LEVEL
printf "petask %3d with pid %8d started on host %s\n" $1 $$ $HOSTNAME
printf "NSLOTS %3d NHOSTS %3d NQUEUES %3d\n" $NSLOTS $NHOSTS $NQUEUES

now=`$SGE_ROOT/utilbin/$ARC/now`
time_end=`expr $now + $2`
while [ $now -lt $time_end ]; do
   sleep 1
   now=`$SGE_ROOT/utilbin/$ARC/now`
done

printf "petask %3d with pid %8d finished on host %s\n" $1 $$ $HOSTNAME
exit $exit_code
