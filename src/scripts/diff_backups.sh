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

# This script compares two backup directories while excluding certain files
# and lines containing specific patterns.

# Usage: diff_backups.sh <backup_dir1> <backup_dir2>
dir1="${1:?First backup directory not specified}"
dir2="${2:?Second backup directory not specified}"

find "$dir1" -type f | while read -r file1; do
   rel_path="${file1#$dir1/}"
   file2="$dir2/$rel_path"

   # find the directory name (object_type) containing the file (object_name) to compare
   basepath=$(dirname "$rel_path")
   object_type=$(basename "$basepath")
   object_name=$(basename "$rel_path")

   # Exclude specific files from comparison
   if [ "$object_name" = "backup_date" ]; then
      echo "Skipping excluded file '$object_name'"
      continue
   fi

   # Set up filtering based on object type
   if [ "$object_type" = "users" ]; then

      # Users delete_time will differ for different backups, exclude it
      echo "Excluding 'delete_time' from diff of '$object_type' object '$object_name'"
      filter="grep -v ^delete_time"
   else
      filter="cat"
   fi

   # Compare the files after applying the filter and exit on first difference
   if [[ -f "$file2" ]]; then
      diff <($filter "$file1") <($filter "$file2") && echo "$rel_path: OK"
      ret=$?
      if [ $ret -ne 0 ]; then
         echo "$rel_path: DIFFER"
         exit $ret
      fi
   else
      echo "$rel_path: only in $dir1"
   fi
done

# If we reach here, all compared files are identical
exit 0