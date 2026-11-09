#!/bin/sh
#
# Records how it was started, for the check special_variables:
#
#    sv_record.sh <output file> <tag> [<argument> ...]
#
# appends the line "<tag> <path of this script> <arguments>" to the output file.
# Started as terminate_method, it also kills the job: its last argument is the job's pid.

out=$1
tag=$2
shift 2
echo "$tag $0 $*" >> "$out"

if [ "$tag" = "terminate" ]; then
   eval pid=\${$#}
   kill -9 -"$pid" 2>/dev/null || kill -9 "$pid"
fi

exit 0
