#!/usr/bin/env bash
#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2026 HPC-Gridware GmbH
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

# This script compares two backup directories (saved with save_config.sh)
# while excluding certain files and lines containing specific patterns.

ret=0

# Usage: diff_backups.sh <backup_dir1> <backup_dir2>
dir1="${1:?First backup directory not specified}"
dir2="${2:?Second backup directory not specified}"

while IFS= read -r file1; do
   rel_path="${file1#$dir1/}"
   file2="$dir2/$rel_path"

   # find the directory name (object_type) containing the file (object_name) to compare
   basepath=$(dirname "$rel_path")
   object_type=$(basename "$basepath")
   object_name=$(basename "$rel_path")

   # Exclude specific files from comparison
   case "$object_name" in
      backup_date|ports|version|sge_root|admin_hosts|submit_hosts|act_qmaster|shadow_masters|cluster_name)
         echo "Skipping excluded file '$object_name'"
      continue
      ;;
   esac

   # Set up filtering based on object type
   if [ "$object_type" = "users" ]; then
      # Users delete_time will differ for different backups, exclude it
      echo "Excluding 'delete_time' from diff of '$object_type' object '$object_name'"
      filter1="grep -v ^delete_time $file1"
      filter2="grep -v ^delete_time $file2"
   elif [ "$object_type" = "cell" ] && [ "$object_name" = "bootstrap" ]; then
      # Users delete_time will differ for different backups, exclude it
      filter1="grep -Ev ^(binary_path|qmaster_spool_dir|security_mode|spooling_params|#) $file1"
      filter2="grep -Ev ^(binary_path|qmaster_spool_dir|security_mode|spooling_params|#) $file2"
   elif [ "$object_type" = "configurations" ] && [ "$object_name" = "global" ]; then
      # Users delete_time will differ for different backups, exclude it
      echo "Excluding 'execd_spool_dir' and 'mail_tag' from diff of '$object_type' object '$object_name'"
      filter1="grep -Ev ^(execd_spool_dir|mail_tag) $file1"
      filter2="grep -Ev ^(execd_spool_dir|mail_tag) $file2"
   elif [ "$object_type" = "configurations" ]; then
      # Users delete_time will differ for different backups, exclude it
      echo "Excluding 'execd_spool_dir' from diff of '$object_type' object '$object_name'"
      filter1="grep -v ^execd_spool_dir $file1"
      filter2="grep -v ^execd_spool_dir $file2"
   elif [ "$object_type" = "hostgroups" ] && [ "$object_name" = "@allhosts" ]; then
      # Users delete_time will differ for different backups, exclude it
      echo "Excluding 'hostlist' from diff of '$object_type' object '$object_name'"
      filter1="grep -v ^hostlist $file1"
      filter2="grep -v ^hostlist $file2"
   elif [ "$object_type" = "cqueues" ]; then
      # Users delete_time will differ for different backups, exclude it
      echo "Excluding 'tmpdir' and 'slots' from diff of '$object_type' object '$object_name'"
      filter1="grep -Ev ^(tmpdir|slots) $file1"
      filter2="grep -Ev ^(tmpdir|slots) $file2"
   else
      filter1="cat $file1"
      filter2="cat $file2"
   fi

   # Compare the files after applying the filter and exit on first difference
   if [[ -f "$file2" ]]; then
      diff -b <($filter1|sort) <($filter2|sort)
      if [ $? -eq 0 ]; then
         echo "$rel_path: OK"
      else
         echo "$object_type - $object_name: DIFFER"
         ret=1
      fi
   else
      echo "$rel_path: only in $dir1"
      ret=1
   fi
done < <(find "$dir1" -type f)

# If we reach here, all compared files are identical
exit $ret