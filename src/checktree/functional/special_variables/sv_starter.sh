#!/bin/sh
#
# starter_method for the check special_variables: records how it was started in
# out/starter.txt next to this script, then starts the job.

echo "starter $0" >> "`dirname $0`/out/starter.txt"
exec "$@"
