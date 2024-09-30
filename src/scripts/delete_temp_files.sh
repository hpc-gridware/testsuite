#!/bin/sh
#
# script to be called on the file server to delete all the temp files
# created by testsuite
# first argument is the file listing the temp filenames
#echo "$0 running on host `hostname`"

if [ $# -lt 1 ]; then
   echo "Usage: $0 filename [hostname]"
   exit 1
fi

# if the file doesn't exist - nothing to do
orig=$1
if [ ! -f $orig ]; then
   exit 0
fi

hostname="NONE"
if [ $# -eq 2 ]; then
   hostname=$2
fi

# delete the files
for line in `cat $orig`; do
   if [ "$host" = "NONE" ]; then
      file=$line
   else
      host=`echo $line | cut -f 1 -d :`
      if [ "$host" != "$hostname" ]; then
         continue
      fi
      file=`echo $line | cut -f 2 -d :`
   fi

#   echo "file is $file"
   if [ -f "$file" ]; then
#      echo "deleting file $file"
      rm -f $file
   else
      if [ -d "$file" ]; then
#         echo "deleting directory $file"
         rm -rf $file
      fi
   fi
done

exit 0
