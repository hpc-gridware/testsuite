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

# Submits <count> jobs at the same time, so that the requests are spread over the worker threads
# of sge_qmaster, and reports the exit status and the output of every qsub:
#
#    QSUB <n> RC <exit status>
#    <output of qsub>
#    QSUB <n> END
#
# usage: qsub_burst.sh <count> <job name prefix>

count=$1
prefix=$2

dir=`mktemp -d /tmp/qsub_burst.XXXXXX` || exit 1

i=1
while [ $i -le $count ]; do
   (qsub -b y -o /dev/null -j y -N ${prefix}_$i /bin/sleep 5 >$dir/out.$i 2>&1
    echo $? >$dir/rc.$i) &
   i=`expr $i + 1`
done
wait

i=1
while [ $i -le $count ]; do
   echo "QSUB $i RC `cat $dir/rc.$i`"
   cat $dir/out.$i
   echo "QSUB $i END"
   i=`expr $i + 1`
done

rm -rf "$dir"
exit 0
