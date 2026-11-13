#!/bin/bash
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

# Opens several TCP connections and holds them open without sending any data.
# usage: idle_connect.sh <host> <port> <connections> <seconds>

for ((i = 0; i < $3; i++)); do
   exec {fd}<>/dev/tcp/$1/$2 || exit 1
done
echo "idle connections established"
sleep $4
