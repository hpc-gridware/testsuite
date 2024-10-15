#!/bin/bash
#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2024 HPC-Gridware GmbH
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

# This script is a shepherd wrapper calling sge_shepherd with valgrind.
# Set as shepherd_cmd in the local configuration (qconf -mconf hostname).

SCRIPT_DIR=`dirname $0`
# we need to pass the source directory to the shepherd
# assume that our source directories are organized in a certain way:
# <basepath>/clusterscheduler
# <basepath>/gcs-extensions
# <basepath>/testsuite
# ...
SOURCE_DIR=`dirname $SCRIPT_DIR` # <basepath>/testsuite/src
SOURCE_DIR=`dirname $SOURCE_DIR` # <basepath>/testsuite
SOURCE_DIR=`dirname $SOURCE_DIR` # <basepath>
SOURCE_DIR="$SOURCE_DIR/clusterscheduler/source"

# we need to pass the protocol directory to the shepherd
PROTOCOL_DIR=/tmp/testsuite_valgrind/$SGE_QMASTER_PORT

# we need to pass the shepherd binary
ARCH=`$SGE_ROOT/util/arch`
SHEPHERD_BINARY=$SGE_ROOT/bin/$ARCH/sge_shepherd

#echo "starting shepherd with valgrind" >/tmp/shepherd_wrapper.log
#id -a >>/tmp/shepherd_wrapper.log
#echo $SCRIPT_DIR/valgrind.sh $SOURCE_DIR $PROTOCOL_DIR $SHEPHERD_BINARY >>/tmp/shepherd_wrapper.log
exec $SCRIPT_DIR/valgrind.sh $SOURCE_DIR $PROTOCOL_DIR $SHEPHERD_BINARY #>>/tmp/shepherd_wrapper.log 2>&1
