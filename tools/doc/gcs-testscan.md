# `gcs-testscan` — scan the checktree and build runner lists

```
gcs-testscan <line> list | groups | verify | ctest-names
gcs-testscan <line> split <N> [--out DIR] [--filter REGEX]
gcs-testscan <line> clion-configs <DIR> [--jobs N] [--profile NAME]
                                        [--min-label N] [--no-tests]
gcs-testscan <line> diff <snapshot>
```

Replaces the detour through `check.exp dump_test_list`, which writes five Groovy
files of Jenkins Job DSL **into the testsuite git tree**, where they are tracked
and not ignored — one run produced 3783 changed lines here.

What is scanned is what the `check.exp` files declare:

```tcl
set check_name           "<name>"
set check_category       "... VERIFIED ..."
set check_needs          "init_core_system display_test"
set check_description(N) "..."        ;# level N is supported
lappend check_functions  "..."        ;# test has any test functions at all
```

## Commands

| Command | Output |
|---|---|
| `list` | All units as TSV: path, level, duration, origin of the duration, name. |
| `groups` | The dependency groups, largest first. |
| `split N [--out DIR]` | Distribute over N runners, report the expected makespan. With `--out` also the per-runner lists, `CTestTestfile.cmake`, the resource specification, `manifest.txt`, `units.tsv` and `ctest-names.txt`. |
| `ctest-names` | The names ctest registers, one per line — the vocabulary every other tool speaks when it refers to a test. |
| `clion-configs DIR` | IDE run configurations, see below. |
| `diff <snapshot>` | What a checkout has added and removed since that snapshot. |
| `verify` | Compare against `dump_test_list`. Currently 583 to 583, identical. |

`--filter` restricts what is registered at generation time. Use sparingly: it
does not hide tests, it leaves them out entirely — with a filter on the framework
self-tests the ocs-testsuite ones are not in the project at all.

## Selection

The same rules `dump_test_list` applies, three of which are only implicit there:

- **A leaf is a directory without subdirectories.** A node with children is a
  container, not a test. Verified against all 455 dumped paths — none has a
  subdirectory. This is what excludes `install_core_system`.
- **`check_version_range`**, `from` inclusive, `to` **exclusive**. So
  `{"9.1.0" "9.2.0"}` means 9.1.x only and drops out for the 9.2 line. There is a
  per-runlevel variant as an array, and two spellings — braces and quotes.
- `check_functions` non-empty, `check_category` present, not `JENKINS_DISABLED`,
  must be `VERIFIED`.

## Dependencies

`validate_needs` (`check.exp:3227`) checks whether a result file for each entry
of `check_needs` exists in `CHECK_RESULT_DIRS(completed|unsupported)` — and that
directory is **per runner**. A dependency satisfied on r1 is invisible to r2.
Hence:

- Infrastructure dependencies are ignored: `init_core_system`, `display_test`,
  `connection_test`. They run once per runner up front.
- Anything coupled beyond that forms a group that goes to one runner as a whole.
  Grouping is by connected component, not topological — `save_config` needs
  `load_config` and vice versa, which is a cycle and cannot be ordered.

The scope is small: **583 units, 580 groups, exactly one with more than one
test.**

Levels are *not* coupled. They are units in their own right, which is also the
proven behaviour — `dump_test_list` has always produced one Jenkins job per
(test, level).

## Durations

Distribution is by measured runtime, longest group first, onto the emptiest
runner. Sources in order of preference:

1. The line's own measurement from `results/check_durations.txt`.
2. The same location under a different line. That file keys on *absolute* paths
   which contain the line, so a freshly set up line would otherwise find nothing,
   even though the very same test has long been measured elsewhere. The key is
   stripped of the line prefix and the median taken across lines.
3. The median of everything known.

What that is worth:

| data available | real makespan | speedup |
|---|---|---|
| own measurements | 2.33 h | 7.98x |
| other lines only | 2.42 h | 7.70x |
| none at all | **4.17 h** | 4.47x |

With no data at all every unit gets the same cost and LPT degenerates into an
equal split by count. `split` reports the origin and warns once more than a fifth
is estimated. That first run is lopsided but produces exactly the data that makes
the second one right.

## IDE run configurations

`clion-configs` generates them from the same scan. The axis comes first in the
name so a search box narrows on it:

```
all     everything                 ts dir  gcs/component/qrsh  [37]
all     rerun failed               ts cat  QMASTER  [19]
ts all  testsuite  [580]           ts      ts/testsuite/connection_test.0
ts all  pending (not yet passed)
unit    C++ module tests
```

The count is the number of registered ctest tests, not of units — a dependency
group is one test and carries `(+group)` — and for a directory it counts the
whole subtree, because the filter is a prefix.

Everything written is named `gcs_ts_*.xml`; regenerating replaces exactly those
and leaves hand-made configurations alone.

**`all everything` is the only entry without a name filter, and that matters:**
an IDE re-running a single test from its results tree passes the *position* of
that test, and a position only means the same thing to ctest when nothing has
filtered and renumbered the set beforehand.

## Environment

| Variable | Meaning |
|---|---|
| `GCS_TS_OVERHEAD` | Cost per `check.exp` invocation in seconds, default 48. A single measurement on an idle machine gives 25 s, but under eight parallel invocations it is a median of 48 s — the setup opens ssh connections to all hosts, and eight of those at once against the same six VMs do not come for free. The test bodies themselves do not get slower. |
| `GCS_CLION_ROOT` | Root of the release lines, default `~/Clion`. |

## See also

[`gcs-testrun`](gcs-testrun.md) · [`gcs-teststate`](gcs-teststate.md) ·
[`gcs-runners`](gcs-runners.md) · [`gcs-pipeline`](gcs-pipeline.md)
