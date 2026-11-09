#!/bin/sh
#
# Load sensor for the check special_variables: records how it was started in
# out/load_sensor.txt next to this script, then reports no load values.

echo "load_sensor $0" >> "`dirname $0`/out/load_sensor.txt"

while read input; do
   if [ "$input" = "quit" ]; then
      exit 0
   fi
   echo "begin"
   echo "end"
done
