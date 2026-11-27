# Testsuite runs with sanitizer builds

Cluster Scheduler can be built with the address, leak and undefined behaviour sanitizers of GCC.
Running the testsuite against such a build finds memory errors and leaks that a normal run does
not show. This page describes how to set up such a run and which host settings it needs.

## Building and installing

Add `-DENABLE_SANITIZERS=ON` to the compile options of the testsuite configuration
(`compile_options`, menu item 30 or the configuration file). The option is only effective in
`Debug` builds, which is the default.

Do a clean build and install the cluster from it:

```shell
expect check.exp file <config> compile compile_clean
expect check.exp file <config> install
```

`compile_clean` only modifies a compile. Given alone, the testsuite does not compile and stays in
its main menu. Compile and install cannot be combined in one call.

Pass the same options as in the normal runs of this configuration (e.g. `install_rc`) to every
call.

The testsuite detects a sanitizer build by itself: binaries built with sanitizers import
`__asan_init` (or `__tsan_init` with `-DENABLE_TSAN=ON`). When the testsuite reads the version of
the installed binaries, it looks for these symbols in `sge_qmaster` and sets the global variable
`CHECK_IS_SANITIZER_RUN` to 1. After a compile or install it detects it again.

## What the sanitizers report

* An error such as a buffer overflow, a use after free or overlapping memory in `strcpy()` stops
  the process with a report on stderr and exit code 1.
* Leaks are reported when the process exits. A process with leaks exits with code 1 instead of its
  own exit code, so every check that tests the exit status of a command fails.
* A process with leaks also loses output: the leak check ends the process with `_exit()`, so
  stdio buffers are not flushed. Output to a terminal is line buffered and complete, but output
  to a pipe or a file, as the testsuite reads it, is cut off at a buffer boundary. A check then
  fails with an unrelated looking error, e.g. `not well-formed (invalid token)` when parsing the
  XML output of `qstat -xml`. Run the command with stdout redirected to a file to see the leak
  report on stderr.
* Client commands that are not yet free of leaks at exit link `ocs_ClientSanitizerOptions.cc`,
  which switches the leak check off for them. All other checks stay active. Daemons never link it:
  leaks at the shutdown of a daemon are bugs.
* `ASAN_OPTIONS`, `LSAN_OPTIONS` and `UBSAN_OPTIONS` in the environment override the defaults,
  e.g. `ASAN_OPTIONS=detect_leaks=0`.

### Where the reports go

| Process | Report |
|---|---|
| client commands | stderr of the command, i.e. in the output a check sees |
| daemons started by systemd (`install_rc`) | the journal of the unit, readable by root |
| `qrsh_starter` and other commands in a job | the job's stderr, for qrsh the output of qrsh |
| shepherd child before the job's stderr is open | lost, see [below](#analysing-crashes) |

The unit names contain the commd port, e.g. `journalctl -u ocs8028-qmaster.service`.

To collect the reports of all daemons on a host in files instead, set the log path for the
units started by systemd, as root, before the daemons are started:

```shell
mkdir -m 1777 /var/tmp/asan
systemctl set-environment ASAN_OPTIONS=log_path=/var/tmp/asan/asan
```

Every process writes its report to `/var/tmp/asan/asan.<pid>`. This also catches reports that
the journal does not show, e.g. from processes the daemons fork. Remove the setting after the run
with `systemctl unset-environment ASAN_OPTIONS`.

## Host prerequisites

### Every host needs the sanitizer runtime of the build compiler

The binaries are linked dynamically against the sanitizer libraries of the compiler that built
them, e.g. `libasan.so.8` and `libubsan.so.1` for gcc 13. Every host on which the testsuite runs
a binary needs these libraries: execution, submit and admin hosts, and also the
`non_cluster_hosts`, on which checks run commands that are expected to fail. Without them, every
command fails with

```
error while loading shared libraries: libasan.so.8: cannot open shared object file
```

Check a host with

```
ldd $SGE_ROOT/bin/<arch>/qconf | grep -e asan -e ubsan
```

and install the missing libraries from the distribution, e.g. `apt install libasan8` on Ubuntu
22.04. That package comes from gcc 12 and works with binaries built with gcc 13. With other
combinations, `ldd -r` reports symbols that the installed library lacks; if it does, remove the
host from the configuration of the sanitizer run.

Checks that run commands in a container (e.g. `nat_submit_client`) install the two libraries in
the container image themselves in sanitizer runs.

### Hosts with little memory

A sanitized program needs several times the memory of a normal build. On hosts with 2 GB of
memory or less, checks that start many client commands at once can run the host out of memory:
the kernel's OOM killer then ends the commands, and possibly the execd. The commands exit
without output, and an execd unit is reported as failed. Look for `Killed process` in the kernel
log (`journalctl -k`) of the host first.

### Enterprise Linux 8 hosts using NIS: run nscd, or do not use as execution hosts

On Rocky Linux 8 with `nis` in the `passwd` or `group` entries of `/etc/nsswitch.conf`, every job
fails: the shepherd's child crashes with SIGSEGV in `initgroups()` before the job starts. The job
exits with status 139 and the qacct entry shows `failed 100`.

`initgroups()` reaches `libnss_nis`, which uses libtirpc. The sanitizer runtime intercepts
`xdrrec_create()` and passes the call on to the implementation in glibc 2.28 instead of the one in
libtirpc, so libtirpc works on a stream it did not create. This is a problem of the sanitizer
runtime on this system, not of Cluster Scheduler.

The same is to be expected on the other Enterprise Linux 8 distributions (AlmaLinux, CentOS
Stream, RHEL) when they use NIS.

Such a host works as an execution host when nscd caches the `passwd` and `group` databases (the
default of `/etc/nscd.conf`): glibc then gets the users and groups from nscd and does not load
`libnss_nis` into the process, so the intercepted function is never called. nscd has to run before
the daemons start and for the whole run. If glibc cannot reach nscd, it falls back to the modules
of `/etc/nsswitch.conf` in the process, and after a failed connection it does not try nscd again
for some time, so a restart of nscd during a run can crash jobs. Install and enable it, as root:

```shell
dnf install nscd
systemctl enable --now nscd
```

Whether a sanitized program still loads the NIS module can be seen in `/proc/<pid>/maps` of a
process that has looked up a NIS user: with nscd, neither `libnss_nis` nor `libtirpc` is mapped.

Otherwise, either remove such hosts from the execution hosts of the configuration
(`execd_nodes`), or remove `nis` from `/etc/nsswitch.conf` on them if NIS is not needed there.

### Ubuntu 24.04 hosts using NIS: do not use as master host

On Ubuntu 24.04 with `nis` in the `hosts`, `passwd` or `group` entries of `/etc/nsswitch.conf`,
the sanitized `sge_qmaster` crashes with SIGSEGV at address 0 when a name lookup reaches NIS,
e.g. one or two minutes after a host complex value was set to a host name that is resolved
through NIS. The qmaster's own signal handler logs a stack trace that ends at the signal frame;
the sanitizer runtime prints nothing.

`libnss_nis` uses libtirpc. The sanitizer runtime intercepts `xdrstdio_create()`, but glibc 2.39
no longer provides an implementation to pass the call on to, and libtirpc was not yet loaded when
the runtime started, so the interceptor calls a null pointer. As on Enterprise Linux 8, this is a
problem of the sanitizer runtime on this system, not of Cluster Scheduler.

Either use a master host without NIS, or remove `nis` from `/etc/nsswitch.conf` on the master
host if NIS is not needed there. The core dump shows the crash, as root:

```shell
coredumpctl info sge_qmaster
```

### Ubuntu 24.04 (kernel 6.8): reduce the address randomization

On Ubuntu 24.04 with kernel 6.8, a sanitized program started with an unlimited stack limit aborts
at random during startup:

```
==2245180==Shadow memory range interleaves with an existing memory mapping. ASan cannot proceed
correctly. ABORTING.
```

Jobs have an unlimited stack limit by default, so this hits every sanitized program that runs in
a job: `qrsh_starter` (every qrsh job), `qrsh -inherit` in tightly integrated parallel jobs, and
every client command called from a job script. Daemons and commands started from a login shell are
not affected. Ubuntu 24.04 sets `vm.mmap_rnd_bits` to 32, which the sanitizer runtime of GCC 13
does not handle. Hosts with newer kernels and compilers (Ubuntu 26.04) are not affected.

Set the value to 28 on such hosts, as root:

```shell
sysctl -w vm.mmap_rnd_bits=28
```

To keep the setting after a reboot:

```shell
echo "vm.mmap_rnd_bits = 28" > /etc/sysctl.d/90-sanitizer.conf
sysctl --system
```

To check whether a host is affected, run a sanitized binary with an unlimited stack limit a few
times:

```shell
for i in $(seq 10); do
   (ulimit -s unlimited; $SGE_ROOT/utilbin/$($SGE_ROOT/util/arch)/qrsh_starter 2>&1) \
      | grep -c "Shadow memory range"
done
```

Every line printing 1 is an abort.

### Jobs with a virtual memory or data limit fail

A job requesting `h_vmem`, `s_vmem`, `h_data` or `s_data` fails with exit status 1. The execd
logs `can't open file active_jobs/<job>.<task>/error`. `h_rss` and `s_rss` are not affected.

The shepherd's child applies the limits with `setrlimit()` and stays the sanitized shepherd until
it starts the job. The sanitizer runtime reserves terabytes of virtual address space for its
shadow memory, so its next allocation fails under such a limit.

There is no host setting against it. The checks that run jobs with these limits skip them in
sanitizer runs and report them as unsupported, see
[Writing checks for sanitizer runs](#writing-checks-for-sanitizer-runs).

### Daemons started as root

A daemon started by root works with the effective user id of the admin user. Its leak check at
exit needs the process to be switched back to root, otherwise it ends with
`LeakSanitizer has encountered a fatal error` and exit code 1. With systemd, the failing exit of
`sge_shadowd` when it daemonizes makes the whole qmaster unit fail, and the installation of shadow
hosts fails.

Builds of version 9.1.8 or later switch back at exit. Older builds cannot be used for sanitizer
runs with shadow hosts.

## Writing checks for sanitizer runs

A check that cannot work with sanitized binaries, e.g. because its jobs request `h_vmem`,
`s_vmem`, `h_data` or `s_data`, tests `CHECK_IS_SANITIZER_RUN`:

* If the whole check is affected, in its setup function (or setup level function):

  ```tcl
  global CHECK_IS_SANITIZER_RUN
  if {$CHECK_IS_SANITIZER_RUN} {
     ts_log_config "jobs with a virtual memory limit do not work with binaries built with\
                    sanitizers, see doc/sanitizer_runs.md"
     return 99
  }
  ```

* If only some check functions are affected, the same test at the start of each of them, with
  `return` instead of `return 99`.

The check or check function is then reported as unsupported instead of failed.

### Checks that behave differently in sanitizer runs

| Check | Behaviour in a sanitizer run |
|---|---|
| `system_tests/jemalloc` | Unsupported: builds with sanitizers do not link jemalloc, the sanitizers replace the memory allocator. |
| `system_tests/commlib/shutdown` | The error case it waits for needs a message between two commlib calls, which the slower sanitized binaries rarely get. When it did not occur in 15 runs, the check reports a configuration problem instead of an error. |
| `functional/event_client/max_dyn_ec` | Runlevel 1 starts 40 instead of 100 submit clients per host, see [Hosts with little memory](#hosts-with-little-memory). |
| `functional/job_environment/job_environment_basic` | A sanitized program does not start when another library is loaded before the sanitizer runtime. The LD_PRELOAD test therefore preloads the runtime (found with `ldd`) before `libdrmaa.so`. |

## Analysing crashes

A process that changed its user id, e.g. the shepherd's child after switching to the job user,
writes no core dump by default. To get one, set as root on the execution host:

```shell
sysctl -w fs.suid_dumpable=2
```

Reproduce the crash, then read the stack trace and copy the core for gdb:

```shell
coredumpctl info sge_shepherd
coredumpctl dump <pid> -o /tmp/core.sge_shepherd
gdb $SGE_ROOT/bin/<arch>/sge_shepherd /tmp/core.sge_shepherd
```

Set the value back afterwards, it lets cores of setuid programs be written:

```shell
sysctl -w fs.suid_dumpable=0
```

The shepherd resets the signal handlers before it starts the job. A crash in the shepherd's child
therefore shows up as a plain SIGSEGV (exit status 139) without a sanitizer report.

To keep the shepherd's trace files of a job, set `KEEP_ACTIVE=TRUE` in the `execd_params` of the
host's local configuration and remove it after the analysis.
