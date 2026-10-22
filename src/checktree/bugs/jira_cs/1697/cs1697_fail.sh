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
# Exits non-zero on purpose. Configured as the prolog, the epilog or a PE start
# or stop procedure of the CS-1697 check's queue, it provokes the "... failed"
# error states, as opposed to the "before ..." states, which come from a path
# that cannot be executed at all.

echo "cs1697: $0 is failing on purpose" >&2
exit 1
