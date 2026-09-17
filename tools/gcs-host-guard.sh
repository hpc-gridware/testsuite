# gcs-host-guard.sh -- refuse to start a testsuite run on the wrong host.
#
# Sourced by the fleet tools. Not executable on its own.
#
# Why this exists: builds and testsuite runs belong on the dedicated testsuite
# host, not on somebody's workstation. The tools all sit on PATH on both
# machines, and `~/Clion` plus `/scratch` are the same shared filesystems there,
# so a run started in the wrong place works -- it just puts the load on the
# desktop instead. `gcs-runners install` is the sharpest case: after the rsync
# phase it starts N `<line>-rN install` in parallel, which is N simultaneous
# check.exp processes on whatever host it was invoked from.
#
# Nothing about the command line says where it will run, so getting it right
# depended on remembering the rule at the moment of typing. This makes it
# mechanical instead.
#
# The escape hatch is GCS_ALLOW_LOCAL=1 -- deliberate, visible in the command,
# and it warns rather than staying silent.

## @brief Abort unless we are on the testsuite host
#
# @param tool  name of the calling tool, for the message
# @param args  the arguments it was called with, echoed back as a ready-to-paste
#              ssh command
# @return 0 when the host is right or the override is set; otherwise exits 1
gcs_require_ts_host() {
   local tool="$1"; shift
   local want="${GCS_TS_HOST:-ts}"
   local here
   here="$(hostname -s 2>/dev/null || echo unknown)"

   [ "$here" = "$want" ] && return 0

   if [ "${GCS_ALLOW_LOCAL:-0}" = "1" ]; then
      printf '%s: GCS_ALLOW_LOCAL=1 -- running on %s instead of %s\n' \
             "$tool" "$here" "$want" >&2
      return 0
   fi

   {
      printf '%s: refusing to run on %s.\n\n' "$tool" "$here"
      printf 'Testsuite runs belong on %s. This is not a check on your\n' "$want"
      printf 'permissions -- it would work here, and that is the problem: the\n'
      printf 'load would land on this machine.\n\n'
      printf 'Run it there instead:\n\n'
      printf "    ssh %s '%s" "$want" "$tool"
      local a
      for a in "$@"; do printf ' %q' "$a"; done
      printf "'\n\n"
      printf 'Set GCS_ALLOW_LOCAL=1 if you really mean to run it here, or\n'
      printf 'GCS_TS_HOST=<host> if the testsuite host is not %s.\n' "$want"
   } >&2
   exit 1
}
