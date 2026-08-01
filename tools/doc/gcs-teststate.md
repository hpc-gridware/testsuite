# `gcs-teststate` — remember what has run since the last build

```
gcs-teststate <line> summary | running | pending | passed | failed | reset
gcs-teststate <line> record <name> <ok|fail> [seconds]
```

Keeps a ledger of which tests have never run, which passed and which failed —
and drops all of it the moment the binaries change.

Results are recorded by [`gcs-run-unit`](gcs-run-unit.md) after every test group,
so it does not matter whether a test was started from an IDE, from the command
line or through [`gcs-testrun`](gcs-testrun.md).

## Why not `--rerun-failed`

ctest keeps its own note in `LastTestsFailed.log`, but it holds the failures of
the last run that *had* failures. Measured behaviour:

| what you run | the file afterwards |
|---|---|
| everything, two tests fail | lists those two |
| something else that passes | left untouched |
| something else that fails | **replaced** — the earlier two are gone |

So a stray failure elsewhere discards the list one was working through. It is a
snapshot of one run, not a record of what still needs doing.

## The build decides

The ledger is tied to the build through the mtime and size of
`<line>/inst/bin/<arch>/sge_qmaster` — the binaries the runners mirror, and
therefore the thing the tests are actually testing. When that changes, every test
counts as not yet run again: a result from the previous build says nothing about
this one.

The identifier is kept in the first line of the ledger, so this needs no
bookkeeping of its own.

## Commands

| Command | Meaning |
|---|---|
| `summary` | Counts of passed, failed and not yet run, progress in percent, and the failures with duration and time. Also reports tests that are recorded but no longer registered — a checkout removed or renamed them. |
| `running` | What each slot is working on right now, with how long it has been at it. |
| `pending` | Everything that has not passed under this build, never-run ones first, then the failures, so a run works through the unknown before repeating what is already known to be broken. |
| `passed` | The tests that passed, with duration and time. |
| `failed` | Only the failures, one name per line. |
| `reset` | Forget everything. Rarely needed — a rebuild does this by itself. |
| `record <name> <ok\|fail> [seconds]` | Record one result. Called by `gcs-run-unit`; little reason to call it by hand. |

## What is running right now

The ledger learns of a test only when it ends. What a slot is working on *while*
it runs is known in one place only: the `.unit-in-progress` marker that
[`gcs-run-unit`](gcs-run-unit.md) drops before a group and removes after it.

That marker is deliberately also what survives a kill -- that is how an
interrupted run is detected -- so its presence alone does not mean "running".
`gcs-run-unit` therefore records its pid in it, and `running` checks whether that
process is still there:

```
r5     3:20  qsub_h_rt.0
r7    12:41  (stale marker, no process)  inst_sge_upd+group
```

The first is a live unit, twelve minutes in. The second is the remains of a run
that was stopped; the next test on that slot will reinstall the cluster before it
starts. A marker written by an older `gcs-run-unit` has no pid and is reported as
`(no pid in marker)` rather than guessed at.

The elapsed time is useful on its own: a test that has been at it far longer than
its recorded duration is visible long before any timeout fires.

## Files

| Path | Contents |
|---|---|
| `<line>/runners/r<N>/.unit-in-progress` | Start time, pid and name of the group a slot is working on. Written by `gcs-run-unit`, read by `running`. |
| `<line>/runners/teststate.tsv` | The ledger. First line the build identifier, then one line per test with result, time and duration. Writes are serialised with `flock`, because eight runners record concurrently. |
| `<line>/runners/pending.txt` | Rewritten on every recorded result. The run configuration `ts all pending` points at it with `--tests-from-file` and therefore needs no preparation step — which an IDE could not be taught to run anyway. |
| `<line>/runners/lists/ctest-names.txt` | The registered test names, written by [`gcs-testscan`](gcs-testscan.md). Read from there rather than rescanning the checktree, because this runs once per finished test. |

## Environment

| Variable | Meaning |
|---|---|
| `GCS_CLION_ROOT` | Root of the release lines, default `~/Clion`. |

## Example

Work through a test run over several sessions:

```sh
92x runners install 8 -p     # new build mirrored, ledger drops itself
ctest --test-dir <build> --tests-from-file <line>/runners/pending.txt -j 8
gcs-teststate 92x summary    # what is left
```

## See also

[`gcs-run-unit`](gcs-run-unit.md) · [`gcs-testrun`](gcs-testrun.md) ·
[`gcs-testscan`](gcs-testscan.md)
