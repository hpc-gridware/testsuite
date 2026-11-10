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

# Keeps the qmaster reader threads busy with qstat and qhost requests, so that
# their data store lags behind the main data store.
#
# usage: qstat_load.sh <seconds> <parallel>
#   seconds   maximum run time, the load ends earlier on SIGINT / SIGTERM
#   parallel  number of parallel request loops

duration=${1:-600}
parallel=${2:-4}

# background loops of a non-interactive shell ignore SIGINT, stop them explicitly
trap 'kill 0' INT TERM

end=`expr \`date +%s\` + $duration`
i=0
while [ $i -lt $parallel ]; do
   (
      while [ `date +%s` -lt $end ]; do
         qstat -f -u '*' -r -ext > /dev/null 2>&1
         qhost -F -q > /dev/null 2>&1
      done
   ) &
   i=`expr $i + 1`
done

echo "qstat load started"
wait
echo "qstat load finished"
