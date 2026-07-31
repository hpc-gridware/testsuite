# `gcs-feature-workspace` — one directory per feature, one worktree per repository

```
gcs-feature-workspace create   <line> <feature>
gcs-feature-workspace ts-init  <line> <feature> [port] [--force]
gcs-feature-workspace ide-init <line> <feature> [--force]
gcs-feature-workspace teardown <line> <feature> [--force]
gcs-feature-workspace list [<line>] | path <line> <feature> | repos <line>
```

A release line under `~/Clion/` is not a super-repository but a directory of
independent repositories, each on its own base branch. A change spanning several
of them would otherwise be scattered across separate working trees, and building
or testing it would mean cherry-picking.

This creates **one** directory per feature holding a git worktree for every
repository of the line, all on the same branch `gcs-<line>/<feature>`. One tree,
one build, one test run.

It is not a new git feature, just an orchestration wrapper around
`git worktree add/remove` across N repositories with a unified branch name.
Repositories are discovered by scanning the line root, so adding one needs no
change here. An optional `.gcs-line` file in the line root can restrict or order
the set.

## Commands

| Command | Meaning |
|---|---|
| `create` | Add a worktree per repository. Resumes onto an existing feature branch if there is one, otherwise branches from each repository's current HEAD — which may differ per repository and is intentional. |
| `ts-init [port]` | Make the workspace runnable as its own testsuite cluster. |
| `ide-init` | Copy the line's CLion project in and repoint its paths. |
| `teardown` | Remove worktrees and branches. |
| `list` / `path` / `repos` | List workspaces, print one path, list a line's repositories. |

### `ts-init`

Creates `config/`, `inst/`, `pkg/`, `html/` and `results/`, copies the line's
testsuite configuration with every path repointed at the workspace and the port
pair moved, and writes the pipeline wrapper `<line>-<feature>`, symlinked onto
the PATH.

Ports are not invented. A free even port from `<user>,portlist` of the testsuite
user configuration is taken, because that file is what vends the matching
gid_range. Registration order is walked backwards, so the entries added last —
the ones registered for extra clusters — are handed out first and the
long-established low ports stay with the suites that already use them. A port
counts as taken if any line or workspace configuration under `~/Clion` names it,
or if something is listening on it or its execd port. Register more (testsuite
menu, user config) to get more parallel clusters.

Idempotent: an existing configuration keeps its port, and files are left alone
unless `--force`.

### `ide-init`

Copies the line's CLion project into the workspace and rewrites the line root to
the workspace root in the project's top-level XML files, so a feature build never
writes into the line's own `inst/`. The project is named `<version> (<feature>)`
so open windows are tellable apart.

`runConfigurations/` is copied but deliberately **not** rewritten: a workspace has
no runners of its own, so its tests run on the line's clusters against the line's
`pending.txt`, and repointing those paths at the workspace would break them.

### `teardown`

Refuses dirty worktrees and unmerged branches unless `--force`, which also
discards the directory including `config/`, `inst/` and `results/`.

Cleanup here is always explicit. `hermes kanban gc` only reaps scratch workspaces
and never worktrees, so nothing else will do it.

## The wrapper

The generated `<line>-<feature>` is a thin env wrapper: it sets `CS_PIPELINE`,
`CS_HOME`, `CS_MASTER_PORT` and `CS_TOOL_DIR`, marks them authoritative with
`CS_WRAPPER_ACTIVE`, and sources the shared line script. All logic stays there —
never edit a wrapper, fix [`gcs-pipeline`](gcs-pipeline.md) instead.

`CS_TOOL_DIR` is passed in rather than left to be worked out: the wrapper runs
under `/bin/sh`, where the sourced script sees only `$0` — the wrapper, not the
tool directory — and falling back to PATH fails under an IDE, which inherits the
desktop session environment.

## Notes

Feature workspaces deliberately get **no parallel test runners**. They are short
lived and usually aimed at a small slice of the tests, so a runner set per
workspace would cost ports, disk and host load without addressing the bottleneck.
`runners` and `testrun` therefore refuse to work from a workspace; see
[`gcs-runners`](gcs-runners.md).

## Environment

| Variable | Meaning |
|---|---|
| `GCS_CLION_ROOT` | Root of the release lines, default `~/Clion`. |

## Example

```sh
gcs-feature-workspace create   92x my-feature
gcs-feature-workspace ts-init  92x my-feature
gcs-feature-workspace ide-init 92x my-feature
92x-my-feature build && 92x-my-feature install
```

## See also

[`gcs-pipeline`](gcs-pipeline.md) · [`gcs-runners`](gcs-runners.md)
