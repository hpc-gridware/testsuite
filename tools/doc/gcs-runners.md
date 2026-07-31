# `gcs-runners` — N testsuite clusters of one line on a single code base

```
gcs-runners <line> init     [N]
gcs-runners <line> install  [N] [-p]
gcs-runners <line> status
gcs-runners <line> teardown [N] [--force]
```

Cuts the wall clock of a testsuite run by having several clusters work on the
test list at the same time. The model is `testsuite/jenkins/gcs-ci-cd`, which
runs eight clusters (`gcs-ci-cd-0` through `-7`) on the code base of cluster 0 in
the lab.

Not to be confused with
[`gcs-feature-workspace`](gcs-feature-workspace.md): that creates one workspace
per feature with its own worktrees, hence its own code base. Here it is the
other way round — the code base of the line is shared, and only what a cluster
strictly needs for itself is separated:

| per runner | shared with the line |
|---|---|
| `commd_port` | `source_dir` |
| `cluster_name` | `testsuite_root_dir`, `checktree_root_dir` |
| `product_root` (`inst/`) | `additional_checktree_dirs` |
| `results_dir` | host, user and fs configuration; build artifacts |

## Commands

| Command | Meaning |
|---|---|
| `init [N]` | Create directories, configuration and wrapper for N runners. Idempotent: a runner that already has a port keeps it. Without `N`, as many as there are free ports. |
| `install [N] [-p]` | Mirror the line's `inst/` into each runner and install the cluster. `-p` installs all in parallel — about three minutes for eight instead of twenty. |
| `status` | One line per runner: port, whether binaries are present, whether the cluster is running. |
| `teardown [N] [--force]` | Shut the runners down and remove their configuration. `--force` also deletes the directories including `inst/` and `results/`. |

## Ports

Ports are never invented. Only even ports registered in `<user>,portlist` of the
testsuite user configuration are eligible, because that file is what vends the
matching gid_range.

The window is bounded on both sides. `GCS_RUNNER_PORT_MIN` (default 8010) keeps
the runners off the ports historically assigned to the release lines, even when
no configuration currently claims them; `GCS_RUNNER_PORT_MAX` (default 8100)
leaves everything above to the feature workspaces.

**The real limit is not the port but the gid_range.** The allocator
(`config_user.tcl`) hands out a block of 2000 gids per user and port, starting at
12800, and refuses past the 16 bit ceiling of 65535 — about 24 blocks in total.
It only ever allocates *above* the highest existing block, so a port that is
registered and later dropped frees its block only if it happened to be the
topmost one. Registering ports speculatively burns budget for good.

## Notes

### Why the mirroring runs as root

`inst/utilbin/<arch>/testsuidroot` is installed as `-r-s--x--x root:root`. An
unprivileged user can neither read it nor set the setuid bit at the destination,
so a plain `rsync` aborts with code 23. This is most likely why the Jenkins
pipeline runs a full `build` for every one of its eight clusters: `distinst` runs
partly as root and handles it on the way. Mirroring as root through
[`as-root`](as-root.md) takes seconds instead of N full builds. Exactly one file
is affected; all other ownerships are preserved by `rsync -a`.

### Companion configurations are mandatory

Without `defaults-<runner>.mpi.sav` the verification of the MPI configuration
aborts the install. Companion configurations are located by inserting the project
name before the `.sav` extension of the main configuration in use, so they have
to sit next to it under the runner's name.

### Port visibility

Each runner configuration is symlinked into `<line>/config/` so that
`gcs-feature-workspace` sees the port as taken — its `used_ports` only globs
`~/Clion/*/config/defaults-*.sav`. That same symlink is why `init` has to reuse a
runner's existing port instead of drawing a new one.

## Files

| Path | Contents |
|---|---|
| `~/Clion/<line>/runners/r<N>/` | `inst`, `results`, `html` and `config` of one runner |
| `~/Clion/<line>/config/defaults-<line>-r<N>.sav` | symlink to the runner configuration, for port visibility |

## Examples

```sh
92x runners init 8
92x runners install 8 -p
92x runners status
```

## See also

[`gcs-pipeline`](gcs-pipeline.md) · [`gcs-testrun`](gcs-testrun.md) ·
[`gcs-testscan`](gcs-testscan.md) · [`gcs-run-unit`](gcs-run-unit.md) ·
[`as-root`](as-root.md) · [`gcs-feature-workspace`](gcs-feature-workspace.md)
