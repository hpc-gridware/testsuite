# `gcs-testrun` — complete test run of one line, in three phases

```
gcs-testrun <line> [N] [-- <further ctest arguments>]
```

Phase 1 runs in parallel across N runners, phase 2 reruns its failures with
`-j 4`, and phase 3 gives whatever is left one cluster at a time. **Only
phase 3 decides.** The summary sorts the failures accordingly: real defects,
artifacts of load (cleared only in phase 3) and artifacts of parallel execution
(cleared already in phase 2).

Phase 0 regenerates the test list beforehand — always, never from a cache. A
checkout can add and remove tests, and a stale list does not merely mislead, it
breaks with `path not found in checktree`. The scan costs 0.14 s, so there is
nothing to save.

Phase 0b refreshes the IDE run configurations, but only for a project that
already has generated ones: their presence is the opt-in, so nobody who never
asked for them finds 700 files appearing in their `.idea`.

## Why more than one phase

The testsuite's wait helpers use absolute timeouts — 30 s for a configuration
change to take effect, 60 s for load values to arrive — and thereby assume
implicitly that they have the hosts to themselves. Under eight parallel clusters
these are exceeded without any real defect being present.

Measured on 2026-07-31 against the 92x line: of 21 failures from the parallel
run, **13 passed serially**, twelve of them two to three times faster. The same
work, stretched out under load. Only the remaining 8 were real defects.

A single-phase parallel run would therefore report 13 failures that are none. A
purely serial run would need 18.65 h instead of 3.13 h. The funnel does not
claim that parallel execution yields the same result — it checks, and only the
last phase counts.

The actual fix is **CS-2481**, a scalable factor for those timeouts. After that,
the later phases become unnecessary or at least short.

## Bundling, and why the reruns select by name

Groups shorter than `GCS_BUNDLE_MAX_UNIT` are merged by `gcs-testscan` into
bundles to save invocations, so **a bundle is one ctest entry**. Phases 2 and 3
therefore select by test *name* and never use `ctest --rerun-failed`: that would
repeat every test of a bundle because one of them failed.

The names come from the ledger, which `gcs-run-unit` fills per test — one entry
per test even though ctest sees a single unit — and they resolve to the entries
`gcs-testscan` writes with the label `single`.

## The `--` rule

Own ctest arguments after `--` restrict the run, and then the ledger is **not**
cleared: 600 tests that were not selected are not "still to do". Whatever is
already red at that moment goes to `failed-before.txt` and stays out of the
funnel, so a run of two tests is not blamed for yesterday's failures. Without
`--` the ledger is cleared and every failure goes through all three phases.

```sh
92x testrun 32                    # the whole line
92x testrun 32 -- -R 'qrsh'       # only what matches, ledger kept
92x testrun 32 -- -LE single      # explicitly without the single entries
```

## Output

Every run gets its own directory under
`~/Clion/<line>/runners/lists/runs/<timestamp>/`: `summary.txt`, the ctest logs
of the three phases, `manifest.txt` and `units.tsv` (the plan), `failed-*.log`
(what each phase repeated) and `loadprofile.txt`.

Exit status is 0 when no test failed in the deciding phase, 1 otherwise.
Failures that only occurred in parallel do not affect it.

## Notes

Phase 3 runs one cluster at a time, which disables parallelism between test
units. The other clusters keep running but stay idle — a conflict over a
resource that an idle cluster also occupies would therefore persist. For the
timing-related failures this is about, that is immaterial.

## Examples

```sh
92x testrun 32
92x testrun 4 -- -R scheduler
```

## See also

[`gcs-pipeline`](gcs-pipeline.md) · [`gcs-runners`](gcs-runners.md) ·
[`gcs-testscan`](gcs-testscan.md) · [`gcs-teststate`](gcs-teststate.md)
