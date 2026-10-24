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
#
# Dump the environment of whatever starts this, for the check of CS-2764.
#
# Used as the job script and as the prolog, epilog, pe_start and pe_stop of the
# test queue, so that the check can compare the environment of a procedure which
# runs as another user with the environment of the job itself.
#
#    cs2764_dump_env.sh <role> <directory>
#
# <role>       job, prolog, epilog, pe_start or pe_stop - part of the file name
# <directory>  where the dump is written, has to be writable for the job owner
#              and for root
#
# The uid this runs as is written first, so that the check can prove a procedure
# really ran as the user it was configured for.

role=$1
dir=$2

if [ -z "$role" -o -z "$dir" ]; then
   echo "usage: $0 <role> <directory>" >&2
   exit 1
fi

if [ -z "$JOB_ID" ]; then
   JOB_ID=unknown
fi

out="$dir/env.$JOB_ID.$role"

echo "CS2764_RUN_AS_UID=`id -u`" > "$out"
echo "CS2764_RUN_AS_USER=`id -un`" >> "$out"
env >> "$out"

# the job sleeps for a moment, so that the check sees it running
if [ "$role" = "job" ]; then
   sleep 5
fi

exit 0
