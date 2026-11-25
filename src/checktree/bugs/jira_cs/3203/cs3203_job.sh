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

# CS-3203: the job exits 0 when its TMPDIR is a clean, real directory that belongs to the job owner
[ -h "$TMPDIR" ] && exit 4
[ -d "$TMPDIR" ] || exit 3
owner=`ls -ldn "$TMPDIR" | awk '{print $3}'`
[ "$owner" = "`id -u`" ] || exit 5
# nothing of a directory planted at the path is in it
[ -e "$TMPDIR/keep" ] && exit 6
exit 0
