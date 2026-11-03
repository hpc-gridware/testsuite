#!/bin/sh
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
#
# Capturing mailer of the testsuite (see ocs_mail_capture_enable() in
# tcl_files/ocs_mail.tcl). Instead of delivering a mail it stores what the
# daemon handed over as one JSON file per mail, so that a check can evaluate it.
#
# The daemons exec the configured mailer as
#
#    execl(mailer, "mail", "-s", subject, recipient..., nullptr)
#
# and write the body into a pipe on its stdin. Because argv[0] is always "mail",
# this script cannot find its capture directory from its own path. The testsuite
# therefore configures a generated wrapper as mailer, which calls
#
#    ocs_mail_capture.sh <capture_dir> "$@"
#
# Every mail becomes <capture_dir>/mail.<time>.<host>.<pid>.json, one line of
# JSON with the members
#
#    argv        all arguments the mailer got, as an array of strings
#    subject     the argument following -s, "" if there is none
#    recipients  the arguments following the subject, as an array
#    body        stdin, every line terminated by a newline
#    user, uid   the user the mailer ran as
#    host        the host the mailer ran on
#    time        seconds since the epoch
#
# The file is written under a hidden name and renamed when complete, so a reader
# never sees half a mail. The body has to be read to its end in any case: it
# carries the shepherd trace and error files, which is more than a pipe holds.
# The script always exits 0 - a failing mailer must not change what the daemon
# does next.

dir=$1
shift

host=`uname -n`
user=`id -un 2>/dev/null || id | sed -e 's/^[^(]*(\([^)]*\)).*/\1/'`
uid=`id | sed -e 's/^uid=\([0-9]*\).*/\1/'`
now=`date +%s`

# a POSIX awk: the legacy /usr/bin/awk of Solaris knows no functions
AWK=awk
for a in /usr/xpg4/bin/awk nawk gawk; do
   if command -v $a >/dev/null 2>&1; then
      AWK=$a
      break
   fi
done

tmp="$dir/.mail.$host.$$.tmp"
LC_ALL=C $AWK '
function esc(s,    out, i, c) {
   out = ""
   for (i = 1; i <= length(s); i++) {
      c = substr(s, i, 1)
      if (c == "\\") {
         out = out "\\\\"
      } else if (c == "\"") {
         out = out "\\\""
      } else if (c in ctl) {
         out = out ctl[c]
      } else {
         out = out c
      }
   }
   return out
}
BEGIN {
   for (i = 1; i < 32; i++) {
      ctl[sprintf("%c", i)] = sprintf("\\u%04x", i)
   }
   ctl["\t"] = "\\t"
   ctl["\r"] = "\\r"
   # ARGV: host user uid time, then the mailer arguments; they are taken out of
   # ARGV so that awk reads the body from stdin
   host = ARGV[1]; user = ARGV[2]; uid = ARGV[3]; now = ARGV[4]
   n = 0
   for (i = 5; i < ARGC; i++) {
      arg[++n] = ARGV[i]
   }
   for (i = 1; i < ARGC; i++) {
      delete ARGV[i]
   }
   body = ""
}
{
   body = body esc($0) "\\n"
}
END {
   subject = ""
   first = 1
   for (i = 1; i <= n; i++) {
      if (arg[i] == "-s" && i < n) {
         subject = arg[i + 1]
         first = i + 2
         break
      }
   }
   argv = ""
   for (i = 1; i <= n; i++) {
      argv = argv (i > 1 ? "," : "") "\"" esc(arg[i]) "\""
   }
   rcpt = ""
   for (i = first; i <= n; i++) {
      rcpt = rcpt (i > first ? "," : "") "\"" esc(arg[i]) "\""
   }
   printf("{\"argv\":[%s],\"subject\":\"%s\",\"recipients\":[%s],\"body\":\"%s\",", argv, esc(subject), rcpt, body)
   printf("\"user\":\"%s\",\"uid\":%d,\"host\":\"%s\",\"time\":%d}\n", esc(user), uid, esc(host), now)
}' "$host" "$user" "$uid" "$now" "$@" > "$tmp" 2>/dev/null && mv "$tmp" "$dir/mail.$now.$host.$$.json"

rm -f "$tmp"
exit 0
