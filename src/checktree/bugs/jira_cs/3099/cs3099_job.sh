#!/bin/sh
#
# Job script of check cs3099: an array task of a tightly integrated parallel job that runs one
# pe task on the first host of the job and ends, so that the array task finishes with a finished
# pe task in its task list.
#
# usage: cs3099_job.sh <qrsh_binary>

qrsh=$1

host=`head -1 $PE_HOSTFILE | cut -d " " -f 1`
$qrsh -inherit $host /bin/true
echo "qrsh -inherit to host $host exited with $?"

exit 0
