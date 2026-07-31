# Documentation

| Page | Tool |
|---|---|
| [`gcs-pipeline`](gcs-pipeline.md) | Drive one release line — build, install, start, shutdown, run tests. Reached through the `90x` / `91x` / `92x` links. |
| [`gcs-feature-workspace`](gcs-feature-workspace.md) | One directory per feature, one git worktree per repository. |
| [`gcs-runners`](gcs-runners.md) | N testsuite clusters of one line on a single code base. |
| [`gcs-testscan`](gcs-testscan.md) | Scan the checktree; build test lists, the ctest definition and the IDE run configurations. |
| [`gcs-testrun`](gcs-testrun.md) | Complete two-phase run: parallel first, then the failures serially. |
| [`gcs-run-unit`](gcs-run-unit.md) | Run one test group on the cluster the scheduler assigned. |
| [`gcs-teststate`](gcs-teststate.md) | Remember what has run since the last build. |
| [`as-root`](as-root.md) | Run a command as root on a lab host. |

Start with [`gcs-pipeline`](gcs-pipeline.md) for everyday use and
[`gcs-runners`](gcs-runners.md) for the parallel setup.
