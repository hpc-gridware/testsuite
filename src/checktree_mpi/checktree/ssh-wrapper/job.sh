#!/bin/sh
#
#$ -S /bin/sh
#$ -cwd
#set -x

script=$1
instances=$2
duration=$3
sleep_after=$4

trap "echo master task received SIGUSR1" USR1
trap "echo master task received SIGUSR2" USR2

# read an attribute from the PE the job is running in
read_pe_attrib()
{
   attrib=`$SGE_ROOT/bin/$ARC/qconf -sp $1 | grep $2 | awk '{print $2}'`
   echo $attrib
}

# convert pe_hostfile to a list of hosts
prepare_host_slots()
{
   HOSTSLOTS=""
   first_host=1
   while read host nproc rest; do
      # if we are on the master host
      if [ $first_host -eq 1 ]; then
         # if job_is_first_task is TRUE
         # then we may only start one task less - the master task (this script) counts as one task
         if [ $job_is_first_task = "TRUE" ]; then
            nproc=`expr $nproc - 1`
         fi
         # if master_forks_slaves is TRUE, then we may not start any tasks on the first host
         if [ $master_forks_slaves = "TRUE" ]; then
            nproc=0
         fi
         first_host=0
      else
         # we are on a slave host
         # if daemon_forks_slaves is TRUE, then we may only start one task on each host
         if [ $daemon_forks_slaves = "TRUE" ]; then
            nproc=1
         fi
      fi

      hosttask=0
      while [ $hosttask -lt $nproc ]; do
         HOSTSLOTS="$HOSTSLOTS $host"
         hosttask=`expr $hosttask + 1`
      done
   done
   echo $HOSTSLOTS
}

unset SGE_DEBUG_LEVEL
printf "master task started with job id %10d and pid %8d\n" $JOB_ID $$

job_is_first_task=`read_pe_attrib $PE job_is_first_task`
master_forks_slaves=`read_pe_attrib $PE master_forks_slaves`
daemon_forks_slaves=`read_pe_attrib $PE daemon_forks_slaves`
printf "job_is_first_task:   %s\n" $job_is_first_task
printf "master_forks_slaves: %s\n" $master_forks_slaves
printf "daemon_forks_slaves: %s\n" $daemon_forks_slaves


# get a list of host names taking one slot each
HOSTSLOTS=`cat $PE_HOSTFILE | prepare_host_slots`

# start a sleeper process on each granted processor
task=0
for host in $HOSTSLOTS; do
   ssh $host $script $task $duration &
   task=`expr $task + 1`
done
echo "master task submitted all sub tasks"

if [ $master_forks_slaves = "TRUE" ]; then
   echo "master task simulating forking slave tasks (sleeping $duration seconds)"
   sleep $duration
   echo "master task simulating slave task finished"
fi

# wait for the pe tasks (ssh / wrapped to qrsh -inherit) to terminate
# we do multiple wait calls, as wait gets interrupted
# when signals are received, even when they are trapped
# see tight_integration check, tight_integration_notify
# We do a double wait for each started pe task to be sure
# not to finish master task before all tasks have finished
for host in $HOSTSLOTS; do
   wait
   wait
done

if [ "$sleep_after" != "" ]; then
   echo "sleeping $sleep_after seconds ..."
   sleep $sleep_after
   echo "sleeping $sleep_after seconds finished"
fi
echo "master task exiting"
exit 0
