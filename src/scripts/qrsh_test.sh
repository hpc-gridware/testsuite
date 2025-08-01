#!/bin/sh

host=$1
qrsh_count=$2

echo "starting $qrsh_count qrsh calls ..."
counter=$qrsh_count
while [ $counter -ne 0 ]; do
   # we can't be sure that the qrsh jobs can be scheduled immediately - submit them as batch jobs
   qrsh -now no -l h=$host hostname &
   counter=`expr $counter - 1`
done
echo "all qrsh calls started"


echo "waiting for qrsh terminations ..."
counter=$qrsh_count
while [ $counter -ne 0 ]; do
   wait
   counter=`expr $counter - 1`
done

echo "qrsh_test.sh script exits now"
exit 0
