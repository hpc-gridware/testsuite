#!/bin/sh
#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2025 HPC-Gridware GmbH
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

if [ $# -lt 1 ]; then
   echo "Usage: $0 <path to task.sh> [<job-args>]"
   exit 1
fi

TASK_SCRIPT=$1
shift

# path to the MPI implementation
if [ -z "$MPIR_HOME" ]; then
    echo "MPIR_HOME is not set"
    exit 1
fi
echo "MPIR_HOME=$MPIR_HOME"

PATH=$MPIR_HOME/bin:$PATH
export PATH
echo "PATH=$PATH"

LD_LIBRARY_PATH="$MPIR_HOME/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

echo "Job $JOB_ID"

taskset="not available"
type taskset >/dev/null 2>&1
if [ $? -eq 0 ]; then
   taskset=`taskset -pc $$`
fi
echo "taskset output: $taskset"

echo "Starting in $PWD: mpirun $TASK_SCRIPT $@"

MPIRUN_OPTIONS=""
#echo $MPIR_HOME | grep openmpi > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    MPIRUN_OPTIONS="$MPIRUN_OPTIONS --oversubscribe"
#    MPIRUN_OPTIONS="$MPIRUN_OPTIONS --mca routed binomial"
#    MPIRUN_OPTIONS="$MPIRUN_OPTIONS -mca plm_rsh_no_tree_spawn true"
#fi

exec mpirun $MPIRUN_OPTIONS $TASK_SCRIPT "$@"
