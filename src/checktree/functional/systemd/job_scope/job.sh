#!/bin/sh
#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2026 HPC-Gridware GmbH
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#___INFO__MARK_END_NEW__

# Job script of check systemd_job_scope: writes the job scope from the environment and its
# ActiveState to <dir>/<mode>.<job_id>.
#
# usage: job.sh <dir> job                       - a sequential job
#        job.sh <dir> oom <work_binary>         - a job which exceeds its memory limit
#        job.sh <dir> master <qrsh_binary> <path_of_this_script>
#                                               - the master task of a tightly integrated
#                                                 parallel job, starts a pe task on its host
#        job.sh <dir> task                      - the pe task

dir=$1
mode=$2

file=$dir/$mode.$JOB_ID
echo "scope=$SGE_JOB_SCOPE" > $file.tmp
echo "active=`systemctl is-active $SGE_JOB_SCOPE`" >> $file.tmp
mv $file.tmp $file

case $mode in
   oom)
      $3 -touchM 300 -w 1
      ;;
   master)
      host=`head -1 $PE_HOSTFILE | cut -d " " -f 1`
      $3 -inherit $host $4 $dir task
      ;;
esac
exit 0
