# `90x`, `91x`, `92x` — drive one GCS release line

```
92x [action] [argument [argument]]
92x-<feature> [action]      # feature workspace, same actions
. 92x                       # source only, loads CS_* and SGE_* into the shell
```

There is only one script, `gcs-pipeline`; `90x`, `91x` and `92x` are symlinks to
it. It derives the line from the name it was invoked under and reads the port
from that line's testsuite configuration, so neither value is duplicated
anywhere.

| line | port | root |
|---|---|---|
| 90x | 8006 | `~/Clion/90x` |
| 91x | 8004 | `~/Clion/91x` |
| 92x | 8002 | `~/Clion/92x` |

Feature workspaces created by [`gcs-feature-workspace`](gcs-feature-workspace.md)
get a thin wrapper of their own (`92x-fixes` for instance) that sets the
environment and then sources the line script. All logic lives here; never edit a
wrapper.

## Actions

### Everyday use

| Action | Meaning |
|---|---|
| `build` | Compile and package. Also installs the binaries into the line's `inst/` via `scripts/distinst`. |
| `install` | Install the cluster. **Destructive**: deletes and recreates `$SGE_ROOT/$SGE_CELL`, so cluster configuration and spool are lost. |
| `start` | Start an already installed cluster without reinstalling. Use this when a test shut the qmaster down and failed to bring it back — `install` would be needlessly destructive. |
| `shutdown` | Shut the cluster down. |
| `ts` | Interactive testsuite menu, wrapped in a tmux session named after the pipeline. |
| `clion` | Open this line's CLion project with a matching environment. |

### Running tests

| Action | Meaning |
|---|---|
| `check <test_unit> <level>` | Run one test, or everything below a directory, at one numeric run level. |
| `test <category>` | Run all tests carrying a category tag, across all levels. |
| `fullrun <runlevel>` | Every category, every test, up to the given run level. Long running; nightly or pre-merge, not the dev loop. |
| `dump` | Write the test list — as five Jenkins Job-DSL files **inside the testsuite git tree**, where they are tracked. Prefer [`gcs-testscan`](gcs-testscan.md). |
| `reset` | Mark every test as not yet run, by moving the `.res.<level>` markers into `uncompleted`. It moves, never deletes. |

Pass a real level such as `0` to `check`, never `all` — that is only valid as the
*state* argument of `category` and makes every test report "does not support
actual runlevel".

Relative paths are relative to `checktree_root_dir`, which already ends in
`/checktree`. Tests from the `ocs-testsuite` checktree need an absolute path.

### Parallel testing

Both forward to line-independent helpers and only work for the line itself, not
for a feature workspace.

| Action | Forwards to |
|---|---|
| `runners <subcommand>` | [`gcs-runners`](gcs-runners.md) — `init`, `install`, `status`, `teardown` |
| `testrun [N]` | [`gcs-testrun`](gcs-testrun.md) |

### Pipeline

| Action | Meaning |
|---|---|
| `git` | Pull all source and test repositories of the line. |
| `all <test_unit>` | git, build, install, test, shutdown in sequence. |

## Environment

| Variable | Meaning |
|---|---|
| `CS_PIPELINE` | Name of the pipeline, e.g. `92x` or `92x-fixes`. Set by the wrappers. |
| `CS_HOME` | Root directory of the line or workspace. |
| `CS_MASTER_PORT` | qmaster port; the execd uses this + 1. Only ports registered in `<user>,portlist` work, because that is what vends the matching gid_range. |
| `CS_WRAPPER_ACTIVE` | Set to 1 by a wrapper to mark the three above as authoritative for this call. Cleared once consumed, so stale exports never leak into a later invocation. |
| `CS_TOOL_DIR` | Directory the tools live in. A wrapper passes it in — it knows the absolute path it is sourcing. Deliberately no fallback to PATH: an IDE inherits the desktop session environment, where the tool directory usually is not on it. |
| `CS_SELF_HEAL` | With `1`, `check` passes `re_init_on_tcl_error`: after a failed test the cluster is reinstalled fresh, so the next test on it starts clean. Used by [`gcs-run-unit`](gcs-run-unit.md). Off by default — interactively, an automatic reinstall after every failure would be surprising and expensive. |
| `CS_OUTPUT_LEVEL` | How much the testsuite itself produces, default `FINE`. `FINER` and `FINEST` add the internals of the remote procedures. Separate from ctest's `-V`, which only decides how much is passed through. |
| `GCS_PW_COMMAND` | A different password helper. Contract: print the password on stdout, nothing else. |
| `GCS_CLION_ROOT` | Root of the release lines, default `~/Clion`. |

## Files

| Path | Contents |
|---|---|
| `~/Clion/<line>/config/defaults-<line>.sav` | Testsuite configuration. Also the source of the port and, through `<user>,envlist` of the referenced user configuration, of the DISPLAY the tests use — a property of the user rather than of these tools. |
| `~/Clion/<line>/inst` | Installed cluster (`SGE_ROOT`). |
| `~/Clion/<line>/results` | Test results, including `check_durations.txt`. |
| `~/Applications/gcs/testsuite_{host,user,fs}.conf` | Shared across all lines. The user configuration is the port registry. |

## Notes

### Only VERIFIED tests are supported

A test whose `check.exp` lacks the `VERIFIED` tag had it removed on purpose
because the test has known problems. Do not run it, and do not read its failures
as signal.

```sh
grep 'set check_category' <test>/check.exp
```

### Parallel runs need more than one phase

The testsuite's wait helpers use absolute timeouts (30 s for a configuration
change, 60 s for load values) and implicitly assume exclusive use of the hosts.
Under parallel clusters these are exceeded without any real defect: in a
measured full run, 13 of 21 failures passed on a serial rerun. Use
[`gcs-testrun`](gcs-testrun.md), which funnels failures through three phases and
only lets phase 3 decide. See **CS-2481**.

## Examples

```sh
92x build && 92x install && 92x test SCHEDULER
92x check system_tests/clients/qmod/qmod_general 0

92x runners init 8
92x runners install 8 -p
92x testrun 8

. 92x                 # load the environment into the current shell
```

## See also

[`gcs-runners`](gcs-runners.md) · [`gcs-testrun`](gcs-testrun.md) ·
[`gcs-testscan`](gcs-testscan.md) · [`gcs-run-unit`](gcs-run-unit.md) ·
[`gcs-teststate`](gcs-teststate.md) · [`gcs-feature-workspace`](gcs-feature-workspace.md) ·
[`as-root`](as-root.md)
