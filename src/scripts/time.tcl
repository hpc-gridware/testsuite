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
#  Portions of this software are Copyright (c) 2023-2024,2026 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__
# The remote execution of the testsuite passes its own environment on to the
# remote host, TZ included, and clock format prefers TZ over the timezone the
# host is configured for. Reading the offset with an inherited TZ reports the
# timezone of the testsuite host for every cluster host, which is not what the
# caller wants to know: the day boundary of a daemon is the one of the host it
# runs on. So the inherited value is dropped and the system timezone is used.
unset -nocomplain ::env(TZ)

# The UTC offset is printed before the time on purpose: get_remote_time reads
# everything after "current time is" up to the end of the output, so the time
# has to stay the last line.
puts "utc offset is [clock format [clock seconds] -format %z]"
puts "current time is [clock seconds]"
