#!/bin/sh
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

#
# This script is used to run binaries under valgrind.
usage()
{
   echo "Usage: $0 <source_dir> <protocol_dir> <binary> [args]" >&2
   exit 1
}

if [ $# -lt 3 ]; then
   usage
fi

source_dir=$1
shift
protocol_dir=$1
shift
binary=$1
shift

# get some information about the call
hostname=`hostname`
user=`whoami`
name=`basename $binary`
# %s will be replaced by the pid of the process
# %n will be replaced by a sequence number
output_file="$protocol_dir/$name-$hostname-$user-%p-%n.xml"

# Set the options for valgrind
# we want to do memory leak checking for now but valgrid has many other options
OPTIONS="--tool=memcheck --leak-check=full"
# we want to suppress false positives / tedious to fix memory lost at exit
# the log file will contain the suppressions which we can then add to the suppressions file
OPTIONS="$OPTIONS --suppressions=$source_dir/valgrind.supp --gen-suppressions=all"
# we want to demangle the C++ symbols
OPTIONS="$OPTIONS --demangle=yes"
# we only want to show the relative path of source files
OPTIONS="$OPTIONS --fullpath-after=$source_dir/"
# do XML output - we can load that into clion
OPTIONS="$OPTIONS --xml=yes --xml-file=$output_file"
# follow children processes, e.g. when daemonizing
# OPTIONS="$OPTIONS --trace-children=yes"
# we don't need / want this:
#   - valgrind by default follows forks, the %p placeholder in the output file will be replaced by the pid of
#     the process and (most important) a separate file is written for every process
#   - we actually don't want to follow the shepherd, the job, the jobs child processes

valgrind $OPTIONS $binary "$@"
