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
# Stand-in mailer for the CS-1697 check, configured as the "mailer" of the
# cluster so that the many mails the check provokes are discarded instead of
# being delivered. The check does not count the mails here but in the execd
# messages file, which carries one "sending admin mail" line per mail.
#
# mail.cc execs the mailer as
#
#    execl(mailer, "mail", "-s", subject, recipient, nullptr)
#
# and writes the body into a pipe on its stdin. The body has to be read to its
# end: it carries the shepherd trace and error files with it, which is more than
# a pipe holds, and a mailer which does not read it leaves the daemon writing
# into a pipe nobody empties. Nothing is written anywhere - the daemon closed
# stdout and stderr before the exec, and the mailer runs as the user the daemon
# runs as, which is not the user running the testsuite.

cat > /dev/null
exit 0
