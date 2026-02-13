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

INFOTEXT="echo"

# OCS related variables
LOG_FILE_NAME="/tmp/ocs_component_starter_$$.log"
DEBUG_LEVEL=""
DO_DAEMONIZE="true"
LOGGER_LEVEL="I"
THREAD_NAME_PATTERN=""
START_VIA_TERMINAL=1

Usage() {
   myname=$(basename "$0")
   $INFOTEXT "Usage: $myname <switches> <ocs_application>\n" \
             "         [-daemonize true|false]\n" \
             "         [-debug_level <debug level>]\n" \
             "         [-display <display>]\n" \
             "         [-log I|W|C]\n" \
             "         [-terminal tilix|xterm]\n" \
             "         [-thread_name_pattern <pattern>]\n" \
             "\n"
}

EXIT() {
   exit "$1"
}

LogIt() {
   urgency="${1:?Urgency is required [I,W,C]}"
   message="${2:?Message is required}"

   #log file contains all messages
   echo "${urgency} $message" >> "$LOG_FILE_NAME"

   #log when urgency and level is meet
   case "${urgency}${LOGGER_LEVEL}" in
      CC|CW|CI)
         $INFOTEXT "[CRITICAL] $message"
      ;;
      WW|WI)
         $INFOTEXT "[WARNING] $message"
      ;;
      II)
         $INFOTEXT "[INFO] $message"
      ;;
   esac
}

if [ -z "$SGE_ROOT" ] || [ -z "$SGE_CELL" ]; then
   LogIt "C" "SGE_ROOT or SGE_CELL is not set!"
   EXIT 1
fi
cd "$SGE_ROOT" || exit

ARGC=$#
while [ "$ARGC" -gt 0 ]; do
   case $1 in
      -log)
         shift
         if [ "$1" != "C" ] && [ "$1" != "W" ] && [ "$1" != "I" ]; then
            LogIt "W" "Invalid log level $1 using I"
         else
            LOGGER_LEVEL="$1"
            shift
         fi
         ARGC=$(($ARGC - 2))
         ;;
      -debug_level)
         shift
         DEBUG_LEVEL="$1"
         shift
         LogIt "I" "Component starter invoked with -debug_level $DEBUG_LEVEL"
         ARGC=$(($ARGC - 2))
         ;;
      -display)
         shift
         THE_DISPLAY="$1"
         shift
         LogIt "I" "Component starter invoked with -display $DISPLAY"
         ARGC=$(($ARGC - 2))
         ;;
      -terminal)
         shift
         THE_TERMINAL="$1"
         shift
         LogIt "I" "Component starter invoked with -terminal $THE_TERMINAL"
         ARGC=$(($ARGC - 2))
         ;;
      -thread_name_pattern)
         shift
         THREAD_NAME_PATTERN="$1"
         shift
         LogIt "I" "Component starter invoked with -thread_name_pattern $SGE_DEBUG_THREAD_NAME_PATTERN"
         ARGC=$(($ARGC - 2))
         ;;
      -daemonize)
         shift
         if [ "$1" != "true" ] && [ "$1" != "false" ]; then
            LogIt "W" "Invalid daemonize option $1 using false"
         else
            LogIt "I" "Component starter invoked with -daemonize $1"
            DO_DAEMONIZE="$1"
            shift
         fi
         ARGC=$(($ARGC - 2))
         ;;
      *)
         break
         ;;
   esac
done

# Show remaining arguments
if [ "$#" -gt 0 ]; then
   LogIt "I" "Remaining arguments: $*"

   if [ -z "$DEBUG_LEVEL" ]; then
      export SGE_DEBUG_LEVEL="0 0 0 0 0 0 0 0"
   else
      export SGE_DEBUG_LEVEL="$DEBUG_LEVEL"
   fi
   if [ "$DO_DAEMONIZE" = "false" ]; then
      LogIt "I" "Disabling daemonizing OCS component"
      export SGE_ND=1
   else
      export SGE_ND=0
   fi
   if [ -n "$THREAD_NAME_PATTERN" ]; then
      export SGE_DEBUG_THREAD_NAME_PATTERN="$THREAD_NAME_PATTERN"
   fi

   if [ $START_VIA_TERMINAL -eq 1 ]; then
      LogIt "I" "Starting following OCS component in tilix-terminal: $*"
      if  [ "$THE_TERMINAL" = "tilix" ] || [ "$THE_TERMINAL" = "xterm" ]; then

         # Depending on the terminal emulator, we have to use different switch to execute the command
         LogIt "I" "Using terminal $THE_TERMINAL"
         if  [ "$THE_TERMINAL" = "tilix" ]; then
            terminal_app=$(which tilix)
            execute_switch="-x"
         else
            terminal_app=$(which xterm)
            #execute_switch="-fa Monostapce -fs 14 -e"
            #execute_switch="-display $THE_DISPLAY -e"
            execute_switch="-e"
         fi

         LogIt "I" "id               : $(id)"
         LogIt "I" "hostname         : $(hostname)"
         LogIt "I" "SGE_ROOT         : $SGE_ROOT"
         LogIt "I" "SGE_QMASTER_PORT : ${SGE_QMASTER_PORT}"
         LogIt "I" "SGE_EXECD_PORT   : ${SGE_EXECD_PORT}"
         LogIt "I" "SGE_DEBUG_LEVEL  : ${SGE_DEBUG_LEVEL}"
         LogIt "I" "DISPLAY          : ${THE_DISPLAY}"
         LogIt "I" "WAYLAND_DISPLAY  : $WAYLAND_DISPLAY"
         LogIt "I" "executed cmd     : $terminal_app $execute_switch bash -lc .... $*"

         # We exec the daemon in debug mode, when the terminal is closed, the daemon will
         # get a SIGHUP and terminate itself, so we don't have to care about killing the daemon
         # after testing
         exec $terminal_app $execute_switch bash -c "
            export SGE_ROOT=$SGE_ROOT
            export SGE_CELL=$SGE_CELL
            export SGE_QMASTER_PORT=${SGE_QMASTER_PORT}
            export SGE_EXECD_PORT=${SGE_EXECD_PORT}
            export SGE_ND=1
            export SGE_DEBUG_LEVEL='$SGE_DEBUG_LEVEL'
            export SGE_DEBUG_THREAD_NAME_PATTERN='$SGE_DEBUG_THREAD_NAME_PATTERN'
            export DISPLAY='$THE_DISPLAY'
            env
            '$*'
            wait
            echo ''
            echo 'OCS component $* terminated. Press enter to exit terminal.'
            read input
         "
      else
         echo "Terminal $THE_TERMINAL is not supported"
         echo "Press enter to terminate"
         read input
      fi
   else
      LogIt "I" "Starting following OCS component: $*"
      exec "$*"
   fi
fi
