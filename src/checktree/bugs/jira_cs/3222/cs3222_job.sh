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

# CS-3222: the master task of a tightly integrated job removes its TMPDIR and starts a pe task,
# then puts a symbolic link at the TMPDIR path and starts another one. It exits with the first
# exit status of qrsh -inherit that is not 0, with 6 when it cannot remove its TMPDIR and 7 when
# it cannot put the link there.
#
# usage: cs3222_job.sh <qrsh_binary> <task_script>

qrsh=$1
task=$2
host=`head -1 $PE_HOSTFILE | cut -d " " -f 1`

rm -rf "$TMPDIR"
[ -e "$TMPDIR" ] && exit 6
$qrsh -inherit $host $task
status=$?
echo "pe task after removing the TMPDIR exited with $status"
[ $status -eq 0 ] || exit $status

rm -rf "$TMPDIR"
ln -s /tmp "$TMPDIR" || exit 7
$qrsh -inherit $host $task
status=$?
echo "pe task after replacing the TMPDIR by a link exited with $status"
exit $status
