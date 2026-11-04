#!/bin/sh
#
# Job script of check cs3030: starts a task of a tightly integrated parallel job on the first host
# of the job, which sleeps until the check kills its qrsh_starter, then sleeps until sge_qmaster
# deletes the job because its task failed.
#
# usage: cs3030_job.sh <qrsh_binary>

qrsh=$1

host=`head -1 $PE_HOSTFILE | cut -d " " -f 1`
$qrsh -inherit $host /bin/sleep 300
echo "qrsh -inherit to host $host exited with $?"

sleep 600
exit 0
