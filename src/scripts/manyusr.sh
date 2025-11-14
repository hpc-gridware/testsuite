#!/bin/sh

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
      groupadd -g 10000 manyusr

      for i in $(seq $FIRSTUID $LASTUID); do
         user=`printf "usr%4d" $i`
         echo "adding $user"
         useradd -b /scratch/manyusr -U -G manyusr -m $user
      done
      ;;
   -del)
      for i in $(seq $FIRSTUID $LASTUID); do
         user=`printf "usr%4d" $i`
         echo "deleting $user"
         userdel -r $user
      done
      groupdel manyusr
esac
