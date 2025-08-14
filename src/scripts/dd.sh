#!/bin/sh

if [ $# -ne 2 ]; then
   echo "usage: $0 <filename> <num kbytes to write>"
   exit 1
fi

FILENAME=$1
NUMKBYTES=$2

exec dd if=/dev/zero of=$FILENAME bs=1024 count=$NUMKBYTES oflag=dsync
