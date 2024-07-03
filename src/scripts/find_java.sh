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

if [ $# -ne 1 ]; then
   echo "usage: $0 <directory>"
   echo "searches for java versions in <directory>"
   exit 1
fi

BASEDIR=$1
JAVADIRS=""

for i in `ls -1 $BASEDIR`; do
   full_path="$BASEDIR/$i"
   if [ -d $full_path -a ! -h $full_path ]; then
      java_bin=$full_path/bin/java
      if [ -x $java_bin ]; then
         version="unknown"
         output=`$java_bin -version 2>&1 | grep " version "`
         if [ $? -eq 0 ]; then
            version=`echo $output | awk '{print $3}'`
         fi
         has_jni=0
         if [ -f "$full_path/include/jni.h" ]; then
            has_jni=1
         fi
         printf "%s|%s|%d\n" $i $version $has_jni
      fi
   fi
done

exit 0
