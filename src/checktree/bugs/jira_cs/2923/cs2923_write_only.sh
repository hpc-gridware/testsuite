#!/bin/sh
#
# Write-only I/O load for the CS-2923 check.
#
#    cs2923_write_only.sh <writes> <seconds>
#
# One process does <writes> write syscalls and next to no read syscalls, then
# stays alive for <seconds> so that the PDC samples its /proc/<pid>/io before the
# process is gone - a process which lives for less than one PDC interval is never
# seen and its usage is lost.
#
# The writing is done in perl and not in the shell on purpose: a shell buffers the
# output of its echo builtin, so the number of write syscalls would depend on which
# shell runs the job, while perl's syswrite is one write syscall per call.

writes=$1
seconds=$2
out=/tmp/cs2923.$$.dat

perl -e '
   my ($writes, $seconds, $out) = @ARGV;
   open(my $fh, ">", $out) or die "cannot write $out: $!\n";
   syswrite($fh, "x" x 512) for (1 .. $writes);
   close($fh);

   # the kernel counters of this process, so that a failure can be told apart:
   # whether the write syscalls were not counted by the kernel or not read by the PDC
   if (open(my $io, "<", "/proc/$$/io")) {
      print "/proc/self/io after $writes write syscalls:\n", <$io>;
      close($io);
   }
   sleep($seconds);
' "$writes" "$seconds" "$out"
rc=$?

rm -f "$out"
exit $rc
