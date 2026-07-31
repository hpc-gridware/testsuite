# `gcs-testrun` — complete test run of one line, in two phases

```
gcs-testrun <line> [N] [-- <further ctest arguments>]
```

Phase 1 runs in parallel across N runners, phase 2 reruns the failures of
phase 1 serially. **The verdict is only final after both.**

Phase 0 regenerates the test list beforehand — always, never from a cache. A
checkout can add and remove tests, and a stale list does not merely mislead, it
breaks with `path not found in checktree`. The scan costs 0.14 s, so there is
nothing to save.

Phase 0b refreshes the IDE run configurations, but only for a project that
already has generated ones: their presence is the opt-in, so nobody who never
asked for them finds 700 files appearing in their `.idea`.

## Why two phases

The testsuite's wait helpers use absolute timeouts — 30 s for a configuration
change to take effect, 60 s for load values to arrive — and thereby assume
implicitly that they have the hosts to themselves. Under eight parallel clusters
these are exceeded without any real defect being present.

Measured on 2026-07-31 against the 92x line: of 21 failures from the parallel
run, **13 passed serially**, twelve of them two to three times faster. The same
work, stretched out under load. Only the remaining 8 were real defects.

A single-phase parallel run would therefore report 13 failures that are none. A
purely serial run would need 18.65 h instead of 3.13 h. The two-phase run does
not claim that parallel execution yields the same result — it checks.

The actual fix is **CS-2481**, a scalable factor for those timeouts. After that,
phase 2 becomes unnecessary or at least short.

## Output

Every run gets its own directory under
`~/Clion/<line>/runners/lists/runs/<timestamp>/` containing the manifest of the
test list, both JUnit reports, both ctest logs, the list of failures from
phase 1, and a summary that separates real defects from artifacts.

Exit status is 0 when no test failed in the serial phase, 1 otherwise. Failures
that only occurred in parallel do not affect it.

## Notes

Phase 2 uses `-j 1`, which disables parallelism between test units. The other
clusters keep running but stay idle — a conflict over a resource that an idle
cluster also occupies would therefore persist. For the timing-related failures
this is about, that is immaterial.

## Examples

```sh
92x testrun 8
92x testrun 4 -- -R scheduler
```

## See also

[`gcs-pipeline`](gcs-pipeline.md) · [`gcs-runners`](gcs-runners.md) ·
[`gcs-testscan`](gcs-testscan.md) · [`gcs-teststate`](gcs-teststate.md)
