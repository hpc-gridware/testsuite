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
#  Portions of this software are Copyright (c) 2024 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

# get environment
set SGE_ROOT $env(SGE_ROOT)
set ARCH     $env(ARCH)
set HOST     $env(HOST)

# retrieve hostnames
set f [open "|$SGE_ROOT/bin/$ARCH/qhost -l simhost=$HOST" r]

set hosts ""
while {[gets $f line] > 0} {
   set ahost [lindex $line 0]
   if {[string compare [string range $ahost 0 5] lchost] == 0} {
      lappend hosts $ahost
   }
}

close $f

set init_value 0.5
foreach i $hosts {
   set x($i) $init_value
   set init_value [expr $init_value + 0.5]
}

set random_seed 0
while { [gets stdin line] >= 0 } {
   if {[string compare $line "quit"] == 0} {
      exit
   }

   puts "begin"
  
   foreach i $hosts {
      puts "$i:arch:$ARCH"
      puts "$i:num_proc:1"
      set load [expr sin($x($i)) + 1.0]
      set loadstr [format "%0.2f" $load]
      puts "$i:load_avg:$loadstr"
      puts "$i:np_load_avg:$loadstr"
      set random [expr (5 - ($random_seed % 11)) / 29.0]
#      puts "random = $random"
      set x($i) [expr $x($i) + 0.05 + $random]
#      puts "x($i) = $x($i)"
      incr random_seed [expr 1 + $random_seed % 7]
#      puts "random_seed = $random_seed" 
   }
   
   #set x [expr sin($x)]
   
   puts "end"
}
