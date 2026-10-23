# Testsuite Reports: Data Formats

Status: accepted 2026-10-22 (CS-2936).

The reporting chain has three separate steps:

1. **Record**: every testsuite invocation writes what it ran and what came out.
2. **Merge**: one or more report directories of the same run are combined into
   one result, taking the verdict of the last attempt per unit.
3. **Render**: the merged result plus an optional test-case catalog become
   Markdown reports and a zip.

This document fixes the three data formats that connect the steps: the
**record stream** (written by the Tcl framework and by C/C++ module tests),
the **merged result** (written by merge, read by render) and the **catalog**
(written by a project-specific parser, read by render). Examples are in
`examples/`.

All files are UTF-8 JSON. Every top-level object carries
`"format": "ts-report/<kind>/1"`; a reader rejects a kind or major version it
does not know. Times are ISO 8601 with milliseconds and an offset
(`2026-10-22T14:03:11.204+02:00`); durations are seconds as numbers.

## 1. Record stream

### 1.1 Location and naming

```
<results_dir>/reports/<run_id>/<invocation_id>.jsonl
```

- `run_id` comes from `TS_REPORT_RUN_ID`. With only `TS_REPORT=1` set, the
  invocation uses its own start time (`YYYYMMDD-HHMMSS`) as run id.
- `invocation_id` is `<host>-<pid>-<epoch_ms>` and identifies one testsuite
  process. A fleet run starts many of them per runner (one per ctest unit),
  each writing its own file, so no file has two writers.
- Recording is off unless `TS_REPORT_RUN_ID` or `TS_REPORT=1` is set. A run
  without either writes nothing new.
- At start, a recording testsuite prints its run id and report directory, so a
  hand run shows where its data goes.

Hand runs:

- With only `TS_REPORT=1`, every invocation is a run of its own, in its own
  directory.
- To combine several hand invocations into one run, set the same
  `TS_REPORT_RUN_ID` for all of them (e.g. `pilot-1`).
- An interactive menu session is one invocation, so one run id and one file.
  Repeating a unit there gives several attempts with `attempt` 0; merge takes
  the one that ended last.
- The line wrapper (`<line>[-<feature>] check|test …`) gets a switch
  `--report [<run_id>]` that sets these variables, so they need not be passed
  through `ssh`. It is part of the fleet integration, not of the testsuite.

### 1.2 Why a line stream

The file is JSON Lines: one JSON object per line, appended and flushed as
events happen. A killed or interrupted invocation therefore leaves every
event up to the kill, and merge can tell an interrupted unit (start without
end) from one that never started. A single JSON document per function would
be lost entirely on a kill and would need a rewrite per event.

A trailing line that is not valid JSON (cut off by the kill) is ignored by
merge and reported as a warning.

### 1.3 Line types

Every line has `"type"` and `"t"` (time). Lines of one file appear in this
order: `invocation`, then any number of `selection` lines, then per check
`phase` (`setup`), per level `unit_start` … `unit_end`, `phase` (`cleanup`),
`cleanup_check`; finally `invocation_end`. A `selection` line may also appear
between checks.

Setup, cleanup and the cleanup check belong to the **check**, not to a level:
the framework runs the check's `setup`, then every selected level, then the
check's `cleanup` and `check_if_test_cleaned_up`. Those lines therefore carry
`check` and the `levels` they cover and stand outside the units.

| type | when | content |
|---|---|---|
| `invocation` | first line | provenance, attempt (the manifest head) |
| `selection` | after `invocation`, or when a check is entered | units the invocation intends to run |
| `phase` | setup, setup_level, cleanup_level, cleanup | phase name, result |
| `unit_start` | before the level setup | check, level, metadata |
| `function_start` | before a check function | function name, index |
| `command` | per spawned command | host, user, command, status, times |
| `poll` | per finished poll context | condition, timeout, outcome, count |
| `error` | per raised error | level, origin, message |
| `function_end` | after a check function | verdict, duration |
| `unit_end` | after the level cleanup | level verdict |
| `cleanup_check` | after the check's cleanup | result, messages, levels |
| `invocation_end` | last line | exit status |

#### `invocation` (the manifest)

```json
{"format": "ts-report/record/1", "type": "invocation", "t": "...",
 "run_id": "20261022-140000",
 "invocation_id": "ts-48211-1792663391204",
 "attempt": 1, "attempt_label": "phase1",
 "producer": "testsuite",
 "provenance": {
   "ts_host": "ts", "ts_user": "ebablick",
   "product": "GCS", "product_version": "9.1.7",
   "product_root": "/usr/local/testsuite/8070/inst",
   "build": {"arch": "lx-amd64", "type": "Debug"},
   "sources": [
     {"repo": "clusterscheduler", "commit": "1a2b3c4d", "dirty": false},
     {"repo": "testsuite", "commit": "5e6f7a8b", "dirty": true}],
   "cluster": {"name": "p8070", "qmaster_host": "host-0012",
               "execd_hosts": ["host-0013", "host-0014"],
               "submit_hosts": ["host-0012"]},
   "results_dir": "/home/ebablick/Clion/91x-features/ts-reports/results"}}
```

- `attempt` is an integer order (`TS_REPORT_ATTEMPT`, default `0`); merge takes
  the highest. `attempt_label` is free text (`TS_REPORT_ATTEMPT_LABEL`,
  default `interactive`), e.g. the gcs-testrun phase.
- `producer` is `testsuite` or `module_test` (section 1.5).
- `dirty` says whether the working tree had uncommitted changes.

#### `selection`

```json
{"type": "selection", "t": "...", "source": "command_line",
 "units": [{"check": "functional/sharetree", "level": 0},
           {"check": "functional/qconf", "level": 2}]}
```

What the invocation intends to run. Merge checks completeness against the
union of all `selection` lines of the run. `source` is

- `command_line`: the `check <path> <level>` pairs of the invocation, written
  right after `invocation` (this is how `gcs-run-unit` starts bundles), so a
  unit of a bundle killed midway shows up as `not_run`;
- `run_test`: written when the framework enters a check, with the levels it
  will run. This covers menu and category runs.

Known limit: when a menu or category run is killed, the checks it had not
reached yet appear nowhere, because their selection is only written on entry.

#### `unit_start`

A unit is one check at one level, the smallest thing a testsuite invocation
selects.

```json
{"type": "unit_start", "t": "...",
 "check": "functional/sharetree", "check_path": "/home/.../checktree/functional/sharetree",
 "level": 0, "description": "share tree basics",
 "categories": ["SYSTEM", "VERIFIED"],
 "functions": ["sharetree_basic", "sharetree_modify"],
 "test_cases": {"sharetree_modify": [{"id": "STR-03", "relation": "covers"},
                                     {"id": "STR-04", "relation": "prepares"}]}}
```

- `test_cases` comes from `check_test_cases(<function>)` in the check and is
  absent when the check declares none. `relation` is `covers` (the function
  verifies the case) or `prepares` (it verifies a precondition only).

#### `phase`

```json
{"type": "phase", "t": "...", "check": "functional/sharetree", "levels": [0],
 "phase": "setup", "result": "ok", "return": 1}
```

`phase` is `setup` or `cleanup` (check-wide, with `levels`) or `setup_level` or
`cleanup_level` (inside a unit, with `level`). `result` is `ok`, `skip` (setup
returned 99) or `error`. A check-wide `setup` error makes every listed unit
`failed`.

#### `function_start` / `function_end`

```json
{"type": "function_start", "t": "...", "function": "sharetree_modify", "index": 2}
{"type": "function_end", "t": "...", "function": "sharetree_modify",
 "verdict": "failed", "duration": 12.418}
```

Function verdicts:

| verdict | meaning |
|---|---|
| `passed` | no error raised |
| `failed` | at least one `SEVERE` or `WARNING` error |
| `unsupported` | only `CONFIG` errors: the environment cannot run it |
| `tcl_error` | the function raised a Tcl error |
| `not_run` | an earlier function stopped the unit (merge also sets it for units missing entirely) |
| `interrupted` | set by merge only: the function started but has no `function_end` |

#### `command`

```json
{"type": "command", "t": "...", "function": "sharetree_modify",
 "host": "host-0012", "user": "ebablick", "root": false,
 "command": "qconf", "args": "-mstnode /soca=200", "cwd": "/tmp",
 "start": "...", "end": "...", "exit": 0, "timed_out": false,
 "background": false, "interactive": false, "framework": false,
 "poll": 3, "diagnostic": false,
 "output": {"bytes": 312, "excerpt": "...", "truncated": false}}
```

- `function` is the check function, or the phase name while a phase runs.
  Errors raised by the post-check cleanup checks carry `cleanup_check`.
- `poll` is the id of the enclosing poll context, absent outside one.
- `framework` marks commands the testsuite framework runs, not the check
  itself: around a check, the cleanup baseline before the setup (`function`
  is `main`) and the post-check cleanup checks (`cleanup_check`); inside a
  check function, the error mail of the logging and the result marker.
- `interactive` marks a session a check drives itself through
  `open_remote_spawn_process`; it has no `exit` (null) and no `output`.
- `user` is the user the command really ran as, after the testsuite mapped
  special user names (e.g. `ts_def_con`).
- `diagnostic` marks commands a helper runs only to explain a failure (for
  example `qstat -f` after a `wait_for_jobstart` timeout); the helper wraps
  them in `tsrec_diagnostic`.
- `exit` is null when the status is unknown (interactive sessions).
- `output.excerpt` holds at most 4 KiB (first 2 KiB and last 2 KiB);
  `truncated` says whether bytes were dropped.
- `command` lines appear when the command finishes; `start` keeps the order
  of overlapping background commands readable.

#### `poll`

```json
{"type": "poll", "t": "...", "id": 3, "parent": null,
 "function": "sharetree_modify", "helper": "wait_for_jobstart",
 "framework": false, "condition": "job 1234 running", "timeout": 60,
 "start": "...",
 "end": "...", "outcome": "met", "commands": 7}
```

A poll context covers one call of a `wait_for_*` helper: the helper opens it
with `tsrec_poll_begin` once it knows its effective timeout, and it closes
when the helper returns, on any path. `timeout` is that effective value in
seconds, after `ts_scale_timeout`. `parent` links a nested context.
`commands` counts the commands recorded directly inside the context.
`framework` has the same meaning as for `command`.

`outcome` is

- `timeout` if a timeout error was raised inside the context, or if the
  deadline was reached without an error (a helper called with its error
  check switched off, e.g. to show that a job does not start);
- `error` if any other error was raised inside the context;
- `met` otherwise.

The helpers count whole seconds, so the deadline counts as reached up to one
second early. A helper that gives up early without raising an error (an
invalid job id with the error check off) reads as `met`.

#### `error`

```json
{"type": "error", "t": "...", "function": "sharetree_modify",
 "level": "SEVERE", "origin": "assertion",
 "message": "share of /soca is 100, expected 200"}
```

`origin` drives the classification of earlier failures in merge:

| origin | raised by | class |
|---|---|---|
| `poll_timeout` | a timeout inside a poll context: the message mentions a timeout or the deadline was reached | load |
| `command_timeout` | a spawned command that did not finish in time | load |
| `connection` | host unreachable, ssh or connection failure, or the cluster is not ready for a level (qmaster not alive, scheduler not connected, a queue without load value) | infrastructure |
| `assertion` | any other error raised by the check | assertion |
| `tcl_error` | a Tcl error in the check | assertion |
| `cleanup` | a post-check cleanup check | assertion |

When the framework cannot tell, it writes `assertion`. An error raised inside
a poll context carries the context's id in `poll`.

#### `unit_end`

```json
{"type": "unit_end", "t": "...", "check": "functional/sharetree", "level": 0,
 "verdict": "failed", "duration": 41.07}
```

The level verdict the framework knows when the level ends, in order of
precedence:

| verdict | rule |
|---|---|
| `skipped` | the level setup returned 99 |
| `failed` | a function `failed` or `tcl_error`, or a setup phase `error` |
| `unsupported` | every function `unsupported` |
| `passed` | otherwise |

#### `cleanup_check`

```json
{"type": "cleanup_check", "t": "...", "check": "functional/sharetree",
 "levels": [0, 1], "result": "error",
 "messages": ["job 1235 still in the cluster"]}
```

The checks the framework runs after the check's cleanup
(`check_if_test_cleaned_up`), once for all levels the check ran in this
invocation.

#### Unit verdict after merge

Merge combines `unit_end` with the check-wide lines:

| verdict | rule |
|---|---|
| `skipped` | `unit_end` says `skipped`, or the check `setup` returned 99 |
| `failed` | `unit_end` says `failed`, or the check `setup` or `cleanup` phase reported `error` |
| `cleanup_failed` | `unit_end` says `passed`, but the check's `cleanup_check` reported `error` |
| `unsupported` | `unit_end` says `unsupported` |
| `passed` | otherwise |
| `interrupted` | `unit_start` without `unit_end`, or the check `setup` passed and the level never started |
| `not_run` | selected, but no `unit_start` |

A check-wide `setup` that reported `error` or `skip` runs no level, so its
units have no `unit_start`; merge makes one attempt per listed level, with the
verdict `failed` or `skipped`.

#### `invocation_end`

```json
{"type": "invocation_end", "t": "..."}
```

Written by the exit handler. `exit` (the exit status) is optional: the
testsuite's handler does not know it, a module test writes it. A file without
`invocation_end` belongs to an invocation that was killed.

### 1.4 Environment

| variable | default | meaning |
|---|---|---|
| `TS_REPORT` | unset | `1` turns recording on with an own run id |
| `TS_REPORT_RUN_ID` | unset | run id, also the directory name; turns recording on |
| `TS_REPORT_ATTEMPT` | `0` | attempt order, higher wins |
| `TS_REPORT_ATTEMPT_LABEL` | `interactive` | free-text label of the attempt |

### 1.5 Module tests

A C/C++ module test started with `--report <file>` writes the same stream
with `"producer": "module_test"`. When the testsuite records, the driving
check (`module_test_generic`, `module_test_cluster`) passes a file in its own
report directory, so the stream lands next to the testsuite's own:

- the unit is the binary (`check` = binary name, `level` = 0);
- each scenario is a function, with `test_cases` from its descriptor;
- each `CHECK` becomes an `assertion` with its number and label, and an
  `error` when it fails:

```json
{"type": "assertion", "t": "...", "function": "RSV-04", "id": 5,
 "label": "delete of @admin_hosts refused", "result": "ok"}
```

- `--describe` prints the scenario descriptors as a catalog fragment
  (section 3) without running anything.

## 2. Merged result

Written by merge (`src/scripts/ts_report_merge.py`) as `merged.json`, one per
run:

```
ts_report_merge.py <run_dir>... [-o merged.json]
ts_report_merge.py <reports_dir> --run-id <run_id> [-o merged.json]
```

The arguments are run directories (`<results_dir>/reports/<run_id>`, one per
runner), single `.jsonl` files, or a reports directory together with
`--run-id`. Streams of another run id or of an unknown format version are an
error. Exit status: 0 when every unit `passed`, was `skipped` or
`unsupported`; 1 when a unit is `failed`, `cleanup_failed`, `interrupted` or
`not_run`; 2 for invalid input.

```json
{"format": "ts-report/merged/1", "run_id": "20261022-140000",
 "merged_at": "...", "inputs": ["/.../r1/results/reports/20261022-140000", "..."],
 "invocations": [{"invocation_id": "...", "attempt": 1,
                  "attempt_label": "phase1", "provenance": {"...": "..."}}],
 "warnings": ["r3: ts-48211-...jsonl: last line cut off"],
 "units": [
   {"check": "functional/sharetree", "level": 0,
    "verdict": "passed", "retried": true, "attention": true,
    "deciding": {"invocation_id": "...", "attempt": 3},
    "functions": [{"function": "sharetree_modify", "verdict": "passed",
                   "test_cases": [{"id": "STR-03", "relation": "covers"}]}],
    "attempts": [
      {"invocation_id": "...", "attempt": 1, "attempt_label": "phase1",
       "verdict": "failed", "class": "assertion",
       "errors": [{"function": "sharetree_modify", "origin": "assertion",
                   "message": "..."}]},
      {"invocation_id": "...", "attempt": 3, "attempt_label": "phase3",
       "verdict": "passed"}]}]}
```

- A unit is keyed by its check path, as recorded, and its level.
- The unit verdict is the verdict of the attempt with the highest `attempt`;
  among equal attempts, the latest `unit_end` (an attempt without one counts
  with its `unit_start`). Equal attempts are the normal case of hand runs: a
  unit repeated in the menu, or several invocations without
  `TS_REPORT_ATTEMPT`.
- `retried` is true when an earlier attempt did not pass, i.e. was `failed`,
  `cleanup_failed` or `interrupted`. An earlier `skipped` or `unsupported`
  does not count.
- `class` of a failed attempt is the worst class of its errors, with
  `assertion` > `infrastructure` > `load`. A failed attempt without any error
  line (killed, or a setup that failed silently) is `assertion`.
- `attention` is true when the unit passed only on retry and an earlier
  attempt has class `assertion`. The internal report lists these first.
- `errors` of an attempt include the check-wide ones (setup, cleanup, cleanup
  checks), because they decide the verdict of every level of the check.
- Only the deciding attempt keeps its lines in full, as `events` of the unit:
  the check-wide lines before the first level (cleanup baseline, `setup`), the
  lines of the unit itself, and the check-wide lines after the last level
  (`cleanup`, cleanup checks), in stream order. A check that ran several levels
  therefore has the same setup and cleanup lines in each of its units. For
  the other attempts, merge keeps the errors only.
- `name`, `description` and `categories` come from the last `unit_start` of
  the unit; `functions` lists the declared functions with the verdict and
  `duration` of the deciding attempt.
- A unit that was selected but never started has `verdict` `not_run`,
  `deciding` null and no attempts.

## 3. Catalog

Written by a project-specific parser (for GCS: the parser of the PIM/RBAC
specification in `gcs-extensions`), read by render.

```json
{"format": "ts-report/catalog/1",
 "source": {"title": "PIM/RBAC specification", "version": "0.39",
            "files": [{"path": "19_Test_Cases.md", "sha256": "..."}]},
 "milestones": [{"id": "M1", "title": "Roles and enforcement"}],
 "test_cases": [
   {"id": "STR-03", "title": "Change shares on own node",
    "section": "ShareTree Tests", "phase": "Phase 1", "milestone": "M3",
    "see": "UC-4.40", "verifies": "...", "steps": ["...", "..."],
    "pass": "...", "notes": [], "owner": "product"}],
 "criteria": [
   {"id": "M3-AC-04", "milestone": "M3",
    "criterion": "Administer ShareTree by subtree",
    "focus": "-sstpath, -mstnode, add and delete",
    "test_ids": ["STR-01", "...", "STR-09", "ADM-09", "ADM-10", "ADM-11"],
    "mapping": "test_ids"},
   {"id": "M3-AC-08", "milestone": "M3",
    "criterion": "Validate the target scope with the automated test suite",
    "mapping": "run"},
   {"id": "M3-AC-10", "milestone": "M3",
    "criterion": "Enable the customer to reproduce tenant-isolation verification",
    "mapping": "manual"}]}
```

- `owner` is `product` or `site`. Site cases appear in the report as not
  covered by the testsuite.
- `mapping` says how a criterion gets its verdict: `test_ids` (all mapped
  cases passed), `run` (the overall result of the run), or `manual` (no
  verdict, listed as verified by the customer). Criteria whose specification
  text names a description instead of IDs get their `test_ids` from the
  project's own mapping table.
- Ranges in the specification (`STR-01 to STR-09`) are expanded by the
  parser; `test_ids` always lists single IDs.

## 4. Examples

`examples/` holds one run (`20261022-140000`) of one unit in two attempts:

- `r2-48211-1792663391204.jsonl`: attempt 1 (`phase1`), `sharetree_modify` fails with an assertion;
- `r1-50332-1792670102117.jsonl`: attempt 3 (`phase3`), the same unit passes;
- `merged.json`: the unit passes, `retried` and `attention` are set (`ts_report_merge.py examples`, with `merged_at` and `inputs` set to fixed values);
- `catalog.json`: excerpt with one product case, one site case and three criteria (`test_ids`, `run`, `manual`).

## 5. Decisions

Accepted with the format on 2026-10-22:

1. One JSON Lines stream per testsuite invocation, not one file per function (section 1.2).
2. Output excerpt of at most 4 KiB per command.
3. `unsupported` for functions with only `CONFIG` errors.
4. `failed` takes precedence over `cleanup_failed`.
