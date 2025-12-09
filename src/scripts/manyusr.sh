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

GID=10000
BASEUID=10000
NUMUSER=4000

if [ $# -lt 1 ]; then
   echo "usage: $0 -add|-del"
   exit 1
fi

FIRSTUID="$BASEUID"
LASTUID=$(($BASEUID + $NUMUSER))

echo "$FIRSTUID"
echo "$LASTUID"

case $1 in
   -add)
      # create a group all users will be in
      groupadd -g 10000 manyusr

      # create the users
      for i in $(seq $FIRSTUID $LASTUID); do
         user=`printf "usr%4d" $i`
         echo "adding $user"
         useradd -b /scratch/manyusr -U -G manyusr -m $user
      done

      # add user 10000 (BASEUID) to 150 groups (if we have so many)
      NUMGRPUSER=150
      if [ "$NUMGRPUSER" -gt "$NUMUSER" ]; then
         NUMGRPUSER="$NUMUSER"
      fi
      user=`printf "usr%4d" "$BASEUID"`
      LASTGRPID=$(($BASEUID + $NUMGRPUSER))
      for i in $(seq $FIRSTUID $LASTGRPID); do
         group=`printf "usr%4d" $i`
         echo "adding $user to group $group"
         usermod -a -G "$group" "$user"
      done

      ;;
   -del)
      # delete all users
      for i in $(seq $FIRSTUID $LASTUID); do
         user=`printf "usr%4d" $i`
         echo "deleting $user"
         userdel -r $user
      done

      # delete the group all users are in
      groupdel manyusr
      ;;
esac
