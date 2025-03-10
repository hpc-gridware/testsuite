#!/bin/sh
#
#

#___INFO__MARK_BEGIN__
##########################################################################
#
#  The Contents of this file are made available subject to the terms of
#  the Sun Industry Standards Source License Version 1.2
#
#  Sun Microsystems Inc., March, 2001
#
#
#  Sun Industry Standards Source License Version 1.2
#  =================================================
#  The contents of this file are subject to the Sun Industry Standards
#  Source License Version 1.2 (the "License"); You may not use this file
#  except in compliance with the License. You may obtain a copy of the
#  License at http://gridengine.sunsource.net/Gridengine_SISSL_license.html
#
#  Software provided under this License is provided on an "AS IS" basis,
#  WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
#  WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
#  MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
#  See the License for the specific provisions governing your rights and
#  obligations concerning the Software.
#
#  The Initial Developer of the Original Code is: Sun Microsystems, Inc.
#
#  Copyright: 2001 by Sun Microsystems, Inc.
#
#  All Rights Reserved.
#
##########################################################################
#___INFO__MARK_END__

#
# Usage: usage.sh id method time
#        default for time is 60 seconds
#        method is either sleep or work
# 

# -- our name ---
#$ -N usage
#$ -S /bin/sh

method=$1
time=$2

printf "master task started with job id %10d and pid %8d\n" $JOB_ID $$
printf "starting with method %s for %d s\n" $method $time
case $method in
   sleep)
      sleep $time
      ;;
   work)
      $SGE_ROOT/examples/jobsbin/$ARC/work -f 1 -w $time
      ;;
   *)
      echo "error: method must be sleep or work"
      ;;
esac
echo "master task exiting"
