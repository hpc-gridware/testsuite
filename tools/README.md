# Testsuite development tools

Scripts for driving the testsuite of a release line, and for running it on
several clusters in parallel.

```
./install ~/.local/bin        # symlinks onto your PATH
```

## What is here

| Tool | Purpose |
|---|---|
| `gcs-pipeline` | Drives one release line: build, install, start, shutdown, run tests. Called through the `90x` / `91x` / `92x` links, which are symlinks to it. |
| `gcs-feature-workspace` | One directory per feature, one git worktree per repository of the line, all on the same branch. |
| `gcs-runners` | N testsuite clusters of one line on a single code base. |
| `gcs-testscan` | Scans the checktree and builds the per-runner test lists. |
| `gcs-testrun` | Complete two-phase run: parallel first, then the failures serially. |
| `gcs-run-unit` | Runs one test group on the cluster the scheduler assigned. |
| `as-root` | Runs a command as root on a lab host. |
| `get_pwd.sh` | Prints the testsuite root password. |

Every tool is documented under [`doc/`](doc/) — start with
[`gcs-pipeline`](doc/gcs-pipeline.md). Markdown rather than man pages, because
the IDE renders it in place and the detour through a terminal buys nothing.

## Why parallel testing exists

A full run of the 92x line takes **18.65 h** serially. Spread over eight
clusters it took **3 h 08 min** — the distribution itself is close to optimal
(1.6 % spread across the eight slots).

The model is `testsuite/jenkins/gcs-ci-cd`, which does the same in the lab with
eight clusters (`gcs-ci-cd-0` through `-7`) on the code base of cluster 0. What
is different here: the binaries are mirrored once instead of building N times,
which is what `as-root` is for — see [`gcs-runners`](doc/gcs-runners.md).

## Setting up the password wallet

Both the testsuite and `as-root` obtain the root password of the lab hosts from
`get_pwd.sh`, which reads a GPG-encrypted file. **That file is personal — it is
not in this repository and must not be.** Each user creates their own:

```sh
mkdir -p ~/.config/gcs
printf '%s' 'the-root-password' | gpg --encrypt --recipient <your-key-id> \
    --output ~/.config/gcs/ts-root-pw.gpg
chmod 600 ~/.config/gcs/ts-root-pw.gpg
```

Verify it, and warm the agent cache while you are at it:

```sh
./get_pwd.sh    # must print the password and nothing else
```

`gpg --batch` never prompts: with a cold agent cache it fails rather than
blocking. That is what makes the helper usable from batch jobs and from CI, but
it also means the cache has to be warm before a long unattended run. A generous
`default-cache-ttl` in `~/.gnupg/gpg-agent.conf` is worth setting.

Overrides, if your site does this differently:

| Variable | Meaning |
|---|---|
| `GCS_PW_COMMAND` | A different helper. Contract: print the password on stdout, nothing else. |
| `GCS_ROOT_PW_FILE` | A different wallet location for the bundled helper. |

## What is not in this repository

Anything specific to one cluster, one user or one machine:

- the GPG wallet (see above)
- the testsuite host, user and filesystem configuration
  (`testsuite_host.conf` and friends) — the user configuration in particular is
  the port registry and vends the `gid_range` per user and port
- the generated wrappers (`92x-fixes`, `92x-r1` …), which `gcs-feature-workspace`
  and `gcs-runners` create locally
- the installed clusters, results and test lists

The display the tests should use is read from `<user>,envlist` of the testsuite
user configuration, so it is a property of the user rather than of these tools.

## Known limitation

The testsuite's wait helpers use absolute timeouts (30 s for a configuration
change, 60 s for load values) and thereby assume exclusive use of the hosts.
Under eight parallel clusters they are exceeded without a real defect being
present: in a measured full run, 13 of 21 failures passed on a serial rerun,
twelve of them two to three times faster.

`gcs-testrun` therefore runs in two phases and separates real defects from
artifacts. **CS-2481** tracks the actual fix, a scalable factor for those
timeouts; once it is in, the second phase becomes short or unnecessary.
