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
#  Portions of this software are Copyright (c) 2023-2024 HPC-Gridware GmbH
#
##########################################################################
#___INFO__MARK_END__

global sqlutil_errors

set sqlutil_errors {}

#****** sql_util/send_to_spawn_id() **************************************************
#  NAME
#    send_to_spawn_id() -- send a string to a remote spawn process
#
#  SYNOPSIS
#    send_to_spawn_id { sp_id input { no_nl 0 }  }
#
#  FUNCTION
#     ???
#
#  INPUTS
#    sp_id         --  the spawn id
#    input         --  the string which will be sent
#    no_nl         --  append nl (1) or not (0)
#
#
#  EXAMPLE
#
#  set id [open_remote_spawn_process $ts_config(master_host) $CHECK_USER  "ls" ]
#  set sp_id [ lindex $id 1 ]
#
#  set timeout 30
#  expect {
#     ...
#     -i $sp_id "prompt: " {
#        send_to_spawn_id $sp_id "help" 1 1
#        exp_continue
#     }
#     ...
#  }
#
#*******************************************************************************
proc send_to_spawn_id { sp_id input { no_nl 0 } } {
   global CHECK_DEBUG_LEVEL

   if {$no_nl} {
      if {$CHECK_DEBUG_LEVEL > 0} {
         ts_log_fine "\n -->testsuite: sending $input"
      }
   } else {
      if {$CHECK_DEBUG_LEVEL > 0} {
         ts_log_fine "\n -->testsuite: sending ${input}<NL>"
      }
      append input "\n"
   }
   if {$CHECK_DEBUG_LEVEL > 1} {
      puts "-->testsuite: press RETURN"
      set anykey [wait_for_enter 1]
   }
   set send_slow "1 .01"
   send -i $sp_id -s -- $input
}


proc get_sqlutil_classpath {} {
   global ts_config arco_config

   set jar_list { arco_common.jar jaxb-impl.jar jaxb-api.jar }
   set ret ""

   set jdbc_driver_path [get_jdbc_driver_path]
   if { $jdbc_driver_path != "NONE" } {
      if { ! [file exists $jdbc_driver_path] } {
         ts_log_config "jdbc driver jar file $jdbc_driverpath does not exist"
         return $ret
      }
      append ret $jdbc_driver_path
   }

   foreach jar $jar_list {
      set file_name $ts_config(product_root)/dbwriter/lib/$jar

      if { ! [file exists $file_name] } {
         ts_log_config "Required jar file $file_name for sql_util does not exist"
      }
      if { [ string length $ret ] > 0 } {
         append ret ":$file_name"
      } else {
         set ret "$file_name"
      }
   }

   return $ret
}


#****** sql_util/sqlutil_create() **************************************************
#  NAME
#    sqlutil_create() -- create a sqlutil
#
#  SYNOPSIS
#    sqlutil_create { }
#
#  FUNCTION
#     ???
#
#  INPUTS
#
#  RESULT
#     -1   -- failure
#     else -- spawn id list of the remote spawn process
#  EXAMPLE
#   set id [sqlutil_create]
#   if { $id == "-1" } {
#      ts_log_severe "Can not create sqlutil"
#      return 0
#   }
#   set sp_id [ lindex $id 1 ]
#
#   if { [ sqlutil_connect $sp_id] != 0 } {
#      ts_log_severe "Can not connect to database"
#      close_spawn_process $id;
#      return -2
#   }
#
#   ...
#   close_spawn_process $id;
#  NOTES
#     ???
#
#  BUGS
#     ???
#
#  SEE ALSO
#     ???/???
#*******************************************************************************
proc sqlutil_create { { user "" } } {
   global ts_host_config arco_config CHECK_DEBUG_LEVEL
   global CHECK_USER

   if { $user == "" } {
      set user $CHECK_USER
   }
   set java_build_host [host_conf_get_java_compile_host]
   ts_log_finest "java build host is \"$java_build_host\""

# TODO - change the method for getting java
   set cmd [get_binary_path $java_build_host "java16"]
   set args "com.sun.grid.util.SQLUtil"

   set sql_utilenv(CLASSPATH) [get_sqlutil_classpath]

   log_user 0
   if { $CHECK_DEBUG_LEVEL > 0 } {
      ts_log_fine "CLASSPATH for sqlUtil: $sql_utilenv(CLASSPATH)"
      log_user 1
   }

   set id [open_remote_spawn_process $java_build_host $user "$cmd" "$args" 0 "" sql_utilenv]
   set sp_id [ lindex $id 1 ]

   set error_count 0
   set timeout 60
   expect {
      flush stdout
      -i $sp_id full_buffer {
         ts_log_severe "sqlutil_create - buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
         set res -1
      }
      -i $sp_id eof {
         ts_log_severe "sqlutil_create - unexpected eof";
         set res -1
      }
      -i $sp_id "coredump" {
         ts_log_severe "sqlutil_create - coredump";
         set res -1
      }
      -i $sp_id timeout {
         ts_log_severe "sqlutil_create - timeout while waiting for output";
         set res -1
      }
      -i $sp_id "prompt: " {
         ts_log_finest "sqlutil: started"
         set res 0
      }
      -i $sp_id "_exit_status_:(*)" {
         set exit_status [get_string_value_between "_exit_status_:(" ")" $expect_out(0,string)]
         ts_log_severe "sqlutil_create - unexpected end of sqlutil (exit status ${exit_status})"
         set res 0
       }
      -i $sp_id "*\n" {
         if { $CHECK_DEBUG_LEVEL > 0 } {
            ts_log_fine  "$expect_out(buffer)"
         }
         exp_continue
      }
   }

   if { $res != 0 } {
      close_spawn_process $id;
      return $res
   }

   # turn the exit on error mechanism off
   set cmd "exitonerror off"
   set res [sqlutil_exec $sp_id "$cmd"]
   if { $res == 0 } {
      return $id
   } else {
      close_spawn_process $id;
      return -1
   }
}

#****** sql_util/sqlutil_connect() **************************************************
#  NAME
#    sqlutil_connect() -- connect to the arco database via the sql util
#
#  SYNOPSIS
#    sqlutil_connect { sp_id { use_admin_db 0 }  }
#
#  FUNCTION
#
#  connect to the arco database via the sql util. The connection parameters
#  are read from the arco_config array
#
#  INPUTS
#    sp_id         -- spawn id of the sqlutil
#    use_admin_db  -- 1 => connect to the database $arco_config(database_name)
#                     0 => connect to the database arco_$ts_config(commd_port)
#
#  RESULT
#     -1   -- error
#     0    -- connected to the arco database
#
#  EXAMPLE
#
#  NOTES
#
#  BUGS
#
#  SEE ALSO
#*******************************************************************************
proc sqlutil_connect { sp_id { use_admin_db 0 } } {

   global arco_config CHECK_DEBUG_LEVEL ts_config

   set db_name [get_database_name $use_admin_db]

   set jdbc_driver [get_jdbc_driver]
   set jdbc_url [get_jdbc_url $db_name]

   ts_log_finest "jdbc_url = $jdbc_url"
   set db_user [get_arco_write_user $use_admin_db]
   set db_pw [get_arco_user_pwd $use_admin_db]

   set cmd "connect $jdbc_driver $jdbc_url $db_user $db_pw"

   ts_log_fine "Connect to $jdbc_url as user $db_user"

   return [ sqlutil_exec $sp_id "$cmd"]

}

#****** sql_util/sqlutil_exec() **************************************************
#  NAME
#    sqlutil_exec() -- execute a command with the sql util
#
#  SYNOPSIS
#    sqlutil_exec { sp_id cmd { a_timeout 30 } }
#
#  FUNCTION
#     execute a command with the sql util
#
#  INPUTS
#    sp_id         --  spawn id of the sql util
#    cmd           --  the command
#    a_timeout     --  timeout for the command
#    30 --
#
#  RESULT
#     -1   -- error
#     else -- return code of the command
#*******************************************************************************
proc sqlutil_exec { sp_id cmd { a_timeout 30 } } {

   global CHECK_DEBUG_LEVEL sqlutil_errors

   # split the command into more lines, if the command is too long
   set commd $cmd
   while { 1 } {
      if {[string length $commd] > 250} {
         set pos [string last " " [string range $commd 0 250]]
         send_to_spawn_id $sp_id "[string range $cmd 0 $pos]\\"
         incr pos 1
         set commd [string range $commd $pos end]
      } else {
         send_to_spawn_id $sp_id "$commd"
         break
      }
   }

   set timeout $a_timeout
   if { $CHECK_DEBUG_LEVEL > 0 } {
     log_user 1
   } else {
     log_user 0
   }

   expect {

      flush stdout
      -i $sp_id full_buffer {
         ts_log_severe "sqlutil_exec - buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
         return -1
      }
      -i $sp_id eof {
         ts_log_severe "sqlutil_exec - unexpected eof";
         return -1
      }
      -i $sp_id "coredump" {
         ts_log_severe "sqlutil_exec - coredump";
         return -1
      }
      -i $sp_id timeout {
         ts_log_severe "sqlutil_exec - timeout while waiting for output";
         return -1
      }
      -i $sp_id -re {^(__exit).+?\n} {
         set exit_status [get_string_value_between "__exit(" ")" $expect_out(buffer)]
         exp_continue
      }
      -i $sp_id -re {^(_exit_status_:).+?\n} {
         set exit_status [get_string_value_between "_exit_status_:(" ")" $expect_out(buffer)]
         ts_log_severe "sqlutil_exec - unexpected exit of sqlutil (exit status $exit_status)"
         return -1
       }
       -i $sp_id -re {^(SEVERE:).+?\n} {
          ts_log_severe $expect_out(buffer)
          lappend sqlutil_errors "$expect_out(buffer)"
          exp_continue
       }
       -i $sp_id -re {^(prompt: )} {
         if { [ info exists exit_status ] } {
            ts_log_finest "sqlutil_exec: OK"
            return $exit_status
         } else {
            ts_log_severe "sqlutil_exec: Got no exit status of last command"
            return -1
         }
      }
      -i $sp_id -re {.*?\n} {
         ts_log_finest "$expect_out(buffer)"
         exp_continue
      }
   }
}


#****** sql_util/sqlutil_query() **************************************************
#  NAME
#    sqlutil_query() -- execute a sql query with the sql_util
#
#  SYNOPSIS
#    sqlutil_query { sp_id cmd a_result_array a_column_names { a_timeout 30 } }
#
#  FUNCTION
#     ???
#
#  INPUTS
#    sp_id          --  spawn id of the sql util
#    cmd            --  the sql query
#    a_result_array -- array where the query result is stored
#    a_column_names -- list with the returned columns names
#    a_timeout      -- timeout for the query
#
#  RESULT
#     < 0 -  error
#     else - number of lines of the result of the query
#
#  EXAMPLE
#
#  NOTES
#
#  BUGS
#
#  SEE ALSO
#*******************************************************************************
proc sqlutil_query { sp_id cmd a_result_array a_column_names { a_timeout 30 } } {

   global CHECK_DEBUG_LEVEL sql_util_errors

   upvar $a_result_array result_array
   upvar $a_column_names column_names

   array unset result_array
   set column_names {}

   if {[sqlutil_exec $sp_id "set print_header true"] != 0} {
      return -1
   }
   # send the sql query to the sql util

   if {$CHECK_DEBUG_LEVEL > 0} {
      ts_log_frame
      ts_log_fine "sqlutil_query -- Execute Query"
      ts_log_fine $cmd
      ts_log_frame
   }
   send_to_spawn_id $sp_id "$cmd"

   set line_nr 0
   set first_line 1

   set timeout $a_timeout

   if { $CHECK_DEBUG_LEVEL > 0 } {
     log_user 1
   } else {
     log_user 0
   }


   expect {
      flush stdout
      -i $sp_id full_buffer {
         ts_log_severe "sqlutil_query - buffer overflow please increment CHECK_EXPECT_MATCH_MAX_BUFFER value"
         return -1
      }
      -i $sp_id eof {
         ts_log_severe "sqlutil_query - unexpected eof";
         return -1
      }
      -i $sp_id "coredump" {
         ts_log_severe "sqlutil_query - coredump";
         return -1
      }
      -i $sp_id timeout {
         ts_log_severe "sqlutil_query - timeout while waiting for output";
         return -1
      }
       -i $sp_id -re {^(SEVERE:).+?\n} {
          ts_log_severe $expect_out(buffer)
          lappend sqlutil_errors "$expect_out(buffer)"
          exp_continue
       }
      -i $sp_id -re "^prompt: " {
         if { [info exists exit_status] != 1 } {
            ts_log_severe "sqlutil_query - Got no exit status for query"
            set exit_status -1
         }
         if { $exit_status != 0 } {
            ts_log_severe "sqlutil_query - query '$cmd' failed"
            return -1;
         } else {
            if { $CHECK_DEBUG_LEVEL > 0 } {
               sql_util_print_result result_array $column_names
            }
            return $line_nr;
         }
      }
      -i $sp_id -re {^(__exit).*?\n} {
         set exit_status [get_string_value_between "__exit(" ")" $expect_out(buffer)]
         if { $CHECK_DEBUG_LEVEL > 0 } {
            ts_log_fine "Got exist_status $exit_status"
         }
         exp_continue
      }
      -i $sp_id -re {^(_exit_status_:).+?\n} {
         set exit_status [get_string_value_between "_exit_status_:(" ")" $expect_out(buffer)]
         ts_log_severe "sqlutil_query - unexpected end of sqlutil (exit status ${exit_status})"
         return -1
       }
       -i $sp_id -re {.*?\n} {
          set line [string trim $expect_out(buffer) " \n\r"]
          if { $CHECK_DEBUG_LEVEL > 1 } {
            ts_log_fine "Got line '$line'"
          }
          if { $first_line == 1 && $line == $cmd } {
             exp_continue
          }
          set line_fields [split $line "\t"]
          if { $first_line == 1 } {
             set col_count [llength $line_fields]
             foreach field $line_fields {
                lappend column_names [string tolower $field]
             }
             set first_line 0
          } else {
             for {set i 0} { $i < $col_count} {incr i 1} {
                set result_array($line_nr,$i) [lindex $line_fields $i]
             }
             incr line_nr 1
          }
          exp_continue
       }
   }
}


#****** sql_util/sql_util_print_result() **************************************************
#  NAME
#    sql_util_print_result() -- print the result of a sql query
#
#  SYNOPSIS
#    sql_util_print_result { result_array columns }
#
#  FUNCTION
#     The function prints the result of a sql query
#
#  INPUTS
#    result_array -- the array which holds the result
#    columns      -- the list with the column names
#
#  EXAMPLE
#
#      set sql "select a, b from foo"
#
#      array set result {}
#      set columns {}
#
#      sqlutil_query $id $sql result columns
#
#      sql_util_print_result result $columns
#
#
#  SEE ALSO
#     sql_util/sqlutil_query
#*******************************************************************************
proc sql_util_print_result { result_array columns } {

   upvar $result_array result

   set col_count [llength $columns]
   set col 0
   foreach column $columns {
      set col_width($col) [string length $column]
      incr col
   }

   set row_count 0
   for { set row 0 } { [info exists result($row,0)] } { incr row } {
      for { set col 0 } { $col < $col_count } { incr col } {
         set len [string length $result($row,$col)]
         if { $len > $col_width($col) } {
            set col_width($col) $len
         }
      }
      incr row_count
   }

   set col_del " | "
   set col 0
   set line_delimiter ""
   foreach column $columns {
      if { $col > 0 } {
         puts -nonewline $col_del
         append line_delimiter "-+-"
      } else {
         puts -nonewline "| "
         append line_delimiter "|-"
      }
      set format($col) "% $col_width($col)s"
      puts -nonewline [format $format($col) $column]
      for { set i 0 } { $i < $col_width($col) } { incr i } {
         append line_delimiter "-"
      }
      incr col
   }
   append line_delimiter "-|"

   puts " |"
   puts $line_delimiter

   for { set row 0 } { [info exists result($row,0)] } { incr row } {
      puts -nonewline "| "
      for { set col 0 } { $col < $col_count } { incr col } {
         if { $col > 0 } {
            puts -nonewline $col_del
         }
         puts -nonewline [format $format($col) $result($row,$col)]
      }
      puts " |"
   }
   puts [string map { + - | + } $line_delimiter]
   if { $row_count == 1 } {
      puts "$row_count row"
   } else {
      puts "$row_count rows"
   }

}

# deprecated
proc add_sql_error { procname error_code msg } {

   global sqlutil_errors

   foreach error_msg $sqlutil_errors {
      append msg "\n   $error_msg"
   }
   set sqlutil_errors {}
   add_proc_error $procname $error_code $msg

}

