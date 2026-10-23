#!/usr/bin/env python3
#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2026 HPC-Gridware GmbH
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#___INFO__MARK_END_NEW__

# Merge step of the testsuite reports (CS-2936).
#
# Reads the record streams of one run (one or many report directories, e.g.
# one per runner) and writes the merged result: per unit (check and level)
# the verdict of the last attempt, the earlier attempts with their errors and
# failure class, and units that were selected but never ran as not_run. The
# formats are described in testsuite/doc/reports/format.md.
#
# Standard library only, Python 3.9 or newer.
#
# Exit status: 0 every unit passed (or was skipped or unsupported), 1 at least
# one unit failed, did not finish or did not run, 2 invalid input.

import argparse
import datetime
import json
import os
import sys

RECORD_FORMAT = ("record", 1)
MERGED_FORMAT = "ts-report/merged/1"

# unit verdicts that count as "did not pass"
FAILING = ("failed", "cleanup_failed", "interrupted", "not_run")

# error origin -> failure class, and the rank of each class (higher is worse)
ORIGIN_CLASS = {
    "poll_timeout": "load",
    "command_timeout": "load",
    "connection": "infrastructure",
}
CLASS_RANK = {"load": 0, "infrastructure": 1, "assertion": 2}

# lines that describe the invocation, not what happened in a unit
NOT_EVENTS = ("invocation", "selection", "invocation_end")


## @brief Error in the input that makes a merge impossible
class InputError(Exception):
    pass


## @brief Parse an ISO 8601 time stamp of the record stream
# @param text the time stamp, e.g. 2026-10-22T14:03:11.204+02:00
# @return an aware datetime, or the epoch for a missing or invalid stamp
def parse_time(text):
    try:
        return datetime.datetime.fromisoformat(text)
    except (TypeError, ValueError):
        return datetime.datetime.fromtimestamp(0, datetime.timezone.utc)


## @brief Format the current time like the record stream does
# @return ISO 8601 with milliseconds and the local offset
def now_iso():
    return datetime.datetime.now().astimezone().isoformat(timespec="milliseconds")


## @brief Check the format field of a top-level object
# @param value the value of "format"
# @param path the file, for the error message
# @return nothing, raises InputError for an unknown kind or major version
def check_format(value, path):
    parts = str(value).split("/")
    if len(parts) != 3 or parts[0] != "ts-report":
        raise InputError("%s: not a testsuite report record stream (format %r)" % (path, value))
    try:
        major = int(parts[2])
    except ValueError:
        raise InputError("%s: invalid format version %r" % (path, value))
    if (parts[1], major) != RECORD_FORMAT:
        raise InputError("%s: unsupported format %r, expected ts-report/record/1" % (path, value))


## @brief One invocation, read from one record stream file
class Stream:
    ## @brief Create an empty stream
    # @param path the file it was read from
    def __init__(self, path):
        self.path = path
        self.header = None
        self.lines = []
        self.ended = False

    ## @brief The invocation id from the header
    # @return the id
    @property
    def invocation_id(self):
        return self.header.get("invocation_id", os.path.basename(self.path))

    ## @brief The attempt order from the header
    # @return the attempt as integer, 0 if absent or invalid
    @property
    def attempt(self):
        try:
            return int(self.header.get("attempt", 0))
        except (TypeError, ValueError):
            return 0


## @brief Read one record stream file
#
# A line that is not valid JSON is skipped with a warning; when it is the last
# line, the invocation was killed while writing it.
# @param path the .jsonl file
# @param warnings list the warnings are appended to
# @return a Stream, or None for a file without any line
def read_stream(path, warnings):
    stream = Stream(path)
    with open(path, encoding="utf-8", errors="replace") as fd:
        raw = fd.read().split("\n")
    while raw and raw[-1].strip() == "":
        raw.pop()
    for number, text in enumerate(raw, start=1):
        if text.strip() == "":
            continue
        try:
            line = json.loads(text)
            if not isinstance(line, dict) or "type" not in line:
                raise ValueError("no type")
        except ValueError:
            if number == len(raw):
                warnings.append("%s: last line cut off" % path)
            else:
                warnings.append("%s: line %d is not a valid record, skipped" % (path, number))
            continue
        if stream.header is None:
            if line["type"] != "invocation":
                raise InputError("%s: first record is %r, expected invocation" % (path, line["type"]))
            check_format(line.get("format"), path)
            stream.header = line
            continue
        if line["type"] == "invocation":
            warnings.append("%s: line %d is a second invocation record, skipped" % (path, number))
            continue
        if line["type"] == "invocation_end":
            stream.ended = True
        stream.lines.append(line)
    if stream.header is None:
        warnings.append("%s: empty file, skipped" % path)
        return None
    if not stream.ended:
        warnings.append("%s: no invocation_end, the invocation was killed" % path)
    return stream


## @brief Find the record stream files named by the command line
#
# An argument is a .jsonl file, a run directory holding .jsonl files, or a
# reports directory holding one directory per run id (then run_id is needed).
# @param args the paths
# @param run_id the run id to pick from a reports directory, or None
# @return (inputs, files): the directories or files used, and the .jsonl files
def find_files(args, run_id):
    inputs = []
    files = []
    for arg in args:
        if os.path.isfile(arg):
            inputs.append(os.path.abspath(arg))
            files.append(arg)
            continue
        if not os.path.isdir(arg):
            raise InputError("%s: no such file or directory" % arg)
        directory = arg
        if not any(name.endswith(".jsonl") for name in os.listdir(directory)):
            if run_id is None:
                raise InputError("%s: no record streams here; for a reports directory, give --run-id" % arg)
            directory = os.path.join(arg, run_id)
            if not os.path.isdir(directory):
                raise InputError("%s: no run %s" % (arg, run_id))
        inputs.append(os.path.abspath(directory))
        files.extend(os.path.join(directory, name)
                     for name in sorted(os.listdir(directory)) if name.endswith(".jsonl"))
    return inputs, files


## @brief Read all streams and make sure they belong to one run
# @param files the .jsonl files
# @param run_id the expected run id, or None to take it from the streams
# @param warnings list the warnings are appended to
# @return (run_id, streams)
def read_streams(files, run_id, warnings):
    streams = []
    seen_files = set()
    seen_ids = set()
    for path in files:
        real = os.path.realpath(path)
        if real in seen_files:
            continue
        seen_files.add(real)
        stream = read_stream(path, warnings)
        if stream is None:
            continue
        stream_run = stream.header.get("run_id")
        if run_id is not None and stream_run != run_id:
            raise InputError("%s: belongs to run %r, not to run %r" % (path, stream_run, run_id))
        run_id = stream_run
        if stream.invocation_id in seen_ids:
            warnings.append("%s: invocation %s read twice, skipped" % (path, stream.invocation_id))
            continue
        seen_ids.add(stream.invocation_id)
        streams.append(stream)
    if not streams:
        raise InputError("no record streams found")
    return run_id, streams


## @brief One run of one unit (check and level) in one invocation
class Attempt:
    ## @brief Create an attempt
    # @param stream the invocation it belongs to
    # @param check the check path
    # @param level the run level
    def __init__(self, stream, check, level):
        self.stream = stream
        self.check = check
        self.level = level
        self.start = None
        self.end = None
        self.events = []
        self.block = None
        self.synthetic_time = None

    ## @brief The unit key
    # @return (check, level)
    @property
    def key(self):
        return (self.check, self.level)

    ## @brief The time that orders attempts of the same attempt number
    # @return unit_end time, else unit_start time, else the phase that made it
    def order_time(self):
        for line in (self.end, self.start):
            if line is not None:
                return parse_time(line.get("t"))
        return parse_time(self.synthetic_time)

    ## @brief The order of this attempt among all attempts of its unit
    # @return a sort key, the last one decides
    def order(self):
        return (self.stream.attempt, self.order_time())

    ## @brief Every line of this attempt in stream order
    #
    # Check-wide lines (setup, cleanup, cleanup checks) are part of every unit
    # of the check.
    # @return list of record lines
    def all_events(self):
        return self.block.pre + self.events + self.block.post

    ## @brief The error lines of this attempt, check-wide ones included
    # @return list of error lines
    def errors(self):
        return [line for line in self.all_events() if line.get("type") == "error"]

    ## @brief The unit verdict after merge (format.md, "Unit verdict after merge")
    # @return the verdict
    def verdict(self):
        setup = self.block.result("setup")
        cleanup = self.block.result("cleanup")
        if self.start is None:
            # a check-wide setup that failed or was skipped runs no level; a
            # setup that passed but never reached the level was interrupted
            return {"skip": "skipped", "error": "failed"}.get(setup, "interrupted")
        if self.end is None:
            return "interrupted"
        verdict = self.end.get("verdict")
        if verdict == "skipped" or setup == "skip":
            return "skipped"
        if verdict == "failed" or "error" in (setup, cleanup):
            return "failed"
        if verdict == "unsupported":
            return "unsupported"
        if self.block.cleanup_check is not None and self.block.cleanup_check.get("result") == "error":
            return "cleanup_failed"
        return "passed"

    ## @brief The failure class of this attempt
    #
    # The worst class of its errors; a failure without any error line counts
    # as assertion, because that is the safe side.
    # @return load, infrastructure or assertion
    def failure_class(self):
        classes = [ORIGIN_CLASS.get(line.get("origin"), "assertion") for line in self.errors()]
        if not classes:
            return "assertion"
        return max(classes, key=lambda name: CLASS_RANK[name])

    ## @brief The verdicts of the check functions
    # @param functions the functions the unit declares
    # @param test_cases the test cases per function
    # @return list of function entries
    def function_results(self, functions, test_cases):
        started = set()
        ended = {}
        for line in self.events:
            if line.get("type") == "function_start":
                started.add(line.get("function"))
            elif line.get("type") == "function_end":
                ended[line.get("function")] = line
        results = []
        for name in functions:
            entry = {"function": name}
            if name in ended:
                entry["verdict"] = ended[name].get("verdict")
                entry["duration"] = ended[name].get("duration")
            elif name in started:
                entry["verdict"] = "interrupted"
            else:
                entry["verdict"] = "not_run"
            entry["test_cases"] = test_cases.get(name, [])
            results.append(entry)
        return results


## @brief The lines of one check in one invocation, outside its units
class Block:
    ## @brief Create a block
    # @param check the check path, None until known
    def __init__(self, check):
        self.check = check
        self.pre = []
        self.post = []
        self.attempts = []
        self.phases = {}
        self.cleanup_check = None

    ## @brief The result of a check-wide phase
    # @param phase setup or cleanup
    # @return ok, skip, error, or None if not recorded
    def result(self, phase):
        line = self.phases.get(phase)
        return None if line is None else line.get("result")


## @brief Cut a stream into checks and units
#
# The lines between the end of one check and its first unit (the check's
# selection, the cleanup baseline, the setup) form the check's prefix; the
# lines after its last unit (cleanup, cleanup checks) form its suffix. A
# check-wide setup that failed or was skipped has no units; each of its
# levels becomes an attempt of its own.
# @param stream the stream
# @return (attempts, selected): all attempts, and the selected unit keys
def split_stream(stream):
    attempts = []
    selected = []
    block = Block(None)
    unit = None

    def finish(next_check):
        nonlocal block, unit
        if unit is not None:
            unit = None
        setup = block.phases.get("setup")
        if setup is not None and not block.attempts:
            for level in setup.get("levels", []):
                attempt = Attempt(stream, block.check, level)
                attempt.synthetic_time = setup.get("t")
                attempt.block = block
                block.attempts.append(attempt)
        attempts.extend(block.attempts)
        block = Block(next_check)

    for line in stream.lines:
        kind = line.get("type")
        if kind == "selection":
            for item in line.get("units", []):
                selected.append((item.get("check"), item.get("level")))
            if line.get("source") == "run_test":
                checks = [item.get("check") for item in line.get("units", [])]
                if block.attempts or block.phases or block.check is not None:
                    finish(None)
                block.check = checks[0] if checks else None
            continue
        if kind in NOT_EVENTS:
            continue
        check = line.get("check")
        if kind == "unit_start":
            if block.check not in (None, check) or "cleanup" in block.phases:
                finish(check)
            block.check = check
            unit = Attempt(stream, check, line.get("level"))
            unit.start = line
            unit.block = block
            block.attempts.append(unit)
        if kind == "phase" and "levels" in line:
            if line.get("phase") == "setup" and (block.attempts or "setup" in block.phases):
                finish(check)
            block.check = check
            block.phases[line.get("phase")] = line
        if unit is not None:
            unit.events.append(line)
        elif block.attempts:
            block.post.append(line)
        else:
            block.pre.append(line)
        if kind == "unit_end" and unit is not None:
            unit.end = line
            unit = None
        if kind == "cleanup_check":
            block.cleanup_check = line
            finish(None)
    finish(None)
    return attempts, selected


## @brief Merge the attempts of all streams into units
# @param streams the streams of the run
# @return list of unit entries, sorted by check and level
def merge_units(streams):
    by_key = {}
    selected = set()
    for stream in streams:
        attempts, keys = split_stream(stream)
        selected.update(keys)
        for attempt in attempts:
            by_key.setdefault(attempt.key, []).append(attempt)
    units = []
    for key in sorted(set(by_key) | selected, key=lambda k: (str(k[0]), str(k[1]))):
        check, level = key
        attempts = sorted(by_key.get(key, []), key=lambda a: a.order())
        if not attempts:
            units.append({"check": check, "level": level, "verdict": "not_run",
                          "retried": False, "attention": False, "deciding": None,
                          "functions": [], "attempts": [], "events": []})
            continue
        units.append(merge_unit(check, level, attempts))
    return units


## @brief Build the entry of one unit from its attempts
# @param check the check path
# @param level the run level
# @param attempts the attempts, ordered, the last one decides
# @return the unit entry
def merge_unit(check, level, attempts):
    deciding = attempts[-1]
    verdict = deciding.verdict()
    entries = []
    for attempt in attempts:
        entry = {"invocation_id": attempt.stream.invocation_id,
                 "attempt": attempt.stream.attempt,
                 "attempt_label": attempt.stream.header.get("attempt_label"),
                 "verdict": attempt.verdict()}
        if entry["verdict"] in FAILING:
            entry["class"] = attempt.failure_class()
        errors = [{"function": line.get("function"), "origin": line.get("origin"),
                   "message": line.get("message")} for line in attempt.errors()]
        if errors:
            entry["errors"] = errors
        entries.append(entry)
    earlier = entries[:-1]
    retried = any(entry["verdict"] in FAILING for entry in earlier)
    attention = verdict == "passed" and any(entry.get("class") == "assertion" for entry in earlier)

    # the metadata of the unit comes from the last attempt that started it
    meta = next((a.start for a in reversed(attempts) if a.start is not None), {})
    unit = {"check": check, "level": level}
    for field in ("name", "description", "categories"):
        if field in meta:
            unit[field] = meta[field]
    unit.update({"verdict": verdict, "retried": retried, "attention": attention,
                 "deciding": {"invocation_id": deciding.stream.invocation_id,
                              "attempt": deciding.stream.attempt},
                 "functions": deciding.function_results(meta.get("functions", []),
                                                        meta.get("test_cases", {})),
                 "attempts": entries,
                 "events": deciding.all_events()})
    return unit


## @brief Merge record streams into the merged result
# @param paths files or directories, see find_files
# @param run_id the run id, or None
# @return the merged result as a dict
def merge(paths, run_id=None):
    warnings = []
    inputs, files = find_files(paths, run_id)
    run_id, streams = read_streams(files, run_id, warnings)
    streams.sort(key=lambda s: (s.attempt, parse_time(s.header.get("t"))))
    invocations = [{"invocation_id": s.invocation_id, "attempt": s.attempt,
                    "attempt_label": s.header.get("attempt_label"),
                    "producer": s.header.get("producer"),
                    "start": s.header.get("t"),
                    "provenance": s.header.get("provenance", {})} for s in streams]
    return {"format": MERGED_FORMAT, "run_id": run_id, "merged_at": now_iso(),
            "inputs": inputs, "invocations": invocations, "warnings": warnings,
            "units": merge_units(streams)}


## @brief Count the unit verdicts
# @param merged the merged result
# @return dict verdict -> count
def verdict_counts(merged):
    counts = {}
    for unit in merged["units"]:
        counts[unit["verdict"]] = counts.get(unit["verdict"], 0) + 1
    return counts


## @brief Command line entry point
# @param argv the arguments without the program name
# @return the exit status
def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Merge the testsuite report record streams of one run (CS-2936).")
    parser.add_argument("paths", nargs="+", metavar="PATH",
                        help="a record stream (.jsonl), a run directory, or a reports "
                             "directory together with --run-id")
    parser.add_argument("--run-id", help="the run to merge; required for a reports directory")
    parser.add_argument("-o", "--output", default="merged.json",
                        help="the merged result to write, - for stdout (default: merged.json)")
    args = parser.parse_args(argv)
    try:
        merged = merge(args.paths, args.run_id)
    except (InputError, OSError) as error:
        print("ts_report_merge: %s" % error, file=sys.stderr)
        return 2

    text = json.dumps(merged, indent=2, ensure_ascii=False) + "\n"
    if args.output == "-":
        sys.stdout.write(text)
    else:
        with open(args.output, "w", encoding="utf-8") as fd:
            fd.write(text)
    for warning in merged["warnings"]:
        print("warning: %s" % warning, file=sys.stderr)
    counts = verdict_counts(merged)
    summary = ", ".join("%d %s" % (counts[v], v) for v in sorted(counts))
    attention = sum(1 for unit in merged["units"] if unit["attention"])
    print("run %s: %d unit(s) from %d invocation(s): %s%s" %
          (merged["run_id"], len(merged["units"]), len(merged["invocations"]), summary,
           ", %d need attention" % attention if attention else ""), file=sys.stderr)
    if args.output != "-":
        print("written to %s" % args.output, file=sys.stderr)
    return 1 if any(v in FAILING for v in counts) else 0


if __name__ == "__main__":
    sys.exit(main())
