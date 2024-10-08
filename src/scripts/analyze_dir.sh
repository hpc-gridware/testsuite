#!/bin/sh
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
# Usage: analyze_dir.sh <path> dirs|files|fileperm
#
# Returns all dirs or files names/permissions (ls -la output) relative to <path>
#
usage_and_exit() {
   echo "usage: analyze_dir.sh <path> dirs|files|fileperm"
   exit 1
}

if [ "$1" = "" ]; then
   echo "please specify base directory"
   usage_and_exit
fi

if [ ! -d "$1" ]; then
   echo "please specify valid base directory. \"$1\" is no directory."
   usage_and_exit
fi

if [ "$2" = "" ]; then
   echo "please specify mode (dirs, files or fileperm)"
   usage_and_exit
fi

if [ "$2" != "dirs" -a "$2" != "files" -a "$2" != "fileperm" ]; then
   echo "unknown mode: \"$2\", allowed values are dirs, files or fileperm"
   usage_and_exit
fi 

if [ "$3" != "" ]; then
   echo "to much parameters specified"
   usage_and_exit
fi

# find all files and directories starting from $1
cd $1
dirs=`find .`
for file in $dirs; do
   if [ "$file" = "." ]; then
      continue
   fi
   if [ "$file" = ".." ]; then
      continue
   fi
   if [ "$2" = "dirs" ]; then
      if [ -d $file  ]; then
         echo $file
      fi
   fi
   if [ "$2" = "files" ]; then
      if [ -f $file  ]; then
         echo $file
      fi
   fi
   if [ "$2" = "fileperm" ]; then
      if [ -f $file  ]; then
         ls -la $file
      fi
   fi
done

