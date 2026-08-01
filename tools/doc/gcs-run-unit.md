# `gcs-run-unit` — run one test group on the assigned cluster

```
gcs-run-unit [--name <ctest-name>] <line> <path> <level> [<path> <level> ...]
```

The execution unit of the whole setup. It knows no scheduler: which cluster is
responsible is taken from the environment, from a different variable depending on
the scheduler.

| scheduler | variable | value |
|---|---|---|
| ctest | `CTEST_RESOURCE_GROUP_0_TS_CLUSTER` | `id:3,slots:1` |
| GCS | `SGE_HGR_ts_cluster` | `3` |
| manual | `TS_SLOT` | `3` |

The same unit therefore runs under ctest locally, as an array task in the lab and
by hand in an emergency. The scheduler is interchangeable, the unit is not.

Several `path level` pairs form a *group*: tests that belong together because
they depend on each other via `check_needs`. They must run one after another on
the **same** cluster, because `validate_needs` (`check.exp:3227`) looks for the
dependency's result file in `results/`, which is separate per runner.

`--name` carries the ctest name of this test. ctest exposes no variable for it,
and without it the outcome cannot be recorded under the name the rest of the
tooling uses — see [`gcs-teststate`](gcs-teststate.md).

Exit status is 0 only if every unit of the group returned 0. Status 3 means the
cluster could not be repaired and nothing was run.

## Health check

Before every group the cluster is checked and repaired if necessary, escalating
by depth of intervention: first `start` (the cell survives), then `install`, then
give up with a clear message.

Without this a single test poisons the whole slot. `bugs/jira/3306` shuts the
qmaster down on purpose in its setup and restarts it instrumented, with a two
second pause against socket reuse. When that restart fails the cluster is dead —
and because a dead slot fails in about 30 s instead of minutes, it attracts a
disproportionate share of tests on the next ctest round and fails them all. In
one observed run, 6 of the first 30 results were such phantom failures.

The check is two-stage because the stages differ by an order of magnitude: the
port check takes 27 ms, the full `qstat` query 481 ms. Across 580 groups that is
the difference between half a minute and four minutes. The case that actually
occurred — qmaster gone — is caught by the first stage.

## Following a running test

ctest captures a test's output and holds it until the test ends -- its own
`Testing/Temporary/LastTest.log.tmp*` sits at the header line until then, and the
testsuite writes nothing to disk while a test runs either: `results/` gets its
`.res` file at the end, `html/` stays empty. So under ctest there was no way to
see what a test was doing.

The output is therefore teed into the runner directory:

| Path | Contents |
|---|---|
| `<line>/runners/r<N>/current.log` | the group running right now, first line naming test, slot and start time |
| `<line>/runners/r<N>/last.log` | the group before it, for a post mortem |

```sh
gcs-teststate 92x running              # which slot is on which test, and for how long
tail -f ~/Clion/92x/runners/r1/current.log
```

`pipefail` is set, so the pipeline still reports the testsuite's exit status
rather than tee's. A dependency group writes all its members into the same file,
one after another.

## Interrupted runs

`check.exp` has no signal handling: no trap for SIGINT or SIGTERM. When ctest is
stopped — Ctrl-C, the IDE's stop button, a test timeout — the test process dies
on the spot and its cleanup function never runs. The cluster then keeps whatever
the test had set up: disabled queues, added complexes, a modified scheduler
configuration, an instrumented qmaster, leftover jobs.

The health check does not see this. A cluster left in a strange state answers
`qstat` perfectly well; only a dead qmaster is caught.

So a marker file `<line>/runners/r<N>/.unit-in-progress` is written before
running and removed after. A marker still present at the next start means the
previous run did not get to the end, and the only reliable way back is a fresh
install.

**Deliberately no `trap`:** a trap on EXIT would also fire when the shell is
killed, and would then remove the very marker that is supposed to record the
kill. The marker is cleared on the normal path only.

A kill does not necessarily reach the test process either. Measured: after a
SIGKILL at 21:32:28 the test still wrote its result at 21:32:31 — `timeout` and
ctest end the direct child, not its expect grandchild.

## Self healing

The test itself is invoked with `CS_SELF_HEAL=1`, which makes the testsuite
reinstall the cluster after a failed test (`installer_reinstall_fresh_cluster`),
so the next test on that slot starts clean. Same behaviour as the `check` branch
of `gcs-ci-cd` in the lab.

## Notes

Two traps that depend on each other, both silent:

- **`set --`** — dot-sourcing without own arguments inherits the caller's
  positional parameters, so the wrapper would receive the test path as its
  action. Clearing them fixes that.
- **`set +u`** — but then the line script, plain `sh` reading `action=$1`, dies
  on the empty `$1` under an inherited `set -u`. That is, exactly once the first
  trap is fixed. One run failed on this: 580 tests, 255 completed, every one a
  failure with two futile repairs.

The runner wrapper is looked up under `<line>/runners/r<N>/config/`, **not** next
to this script: the tools are version controlled, the wrappers are generated per
user and must not be. PATH is the fallback, not the first choice.

## See also

[`gcs-testrun`](gcs-testrun.md) · [`gcs-teststate`](gcs-teststate.md) ·
[`gcs-testscan`](gcs-testscan.md) · [`gcs-runners`](gcs-runners.md)
