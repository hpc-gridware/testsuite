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

# Tests of ts_report_merge.py (CS-2936).
#
# Run from this directory: python3 -B -m unittest test_ts_report_merge
# (-B keeps __pycache__ out of the source tree)

import contextlib
import io
import json
import os
import tempfile
import unittest

import ts_report_merge as merge

HERE = os.path.dirname(os.path.abspath(__file__))
EXAMPLES = os.path.join(HERE, "..", "..", "doc", "reports", "examples")
CHECK = "/ts/checktree/functional/sharetree"
OTHER = "/ts/checktree/functional/qconf"


## @brief Build the record lines of one invocation
class StreamBuilder:
    ## @brief Start a stream with its invocation line
    # @param invocation_id the invocation id
    # @param attempt the attempt order
    # @param run_id the run id
    # @param fmt the format of the invocation line
    def __init__(self, invocation_id, attempt=0, run_id="run-1", fmt="ts-report/record/1"):
        self.invocation_id = invocation_id
        self.clock = 0
        self.lines = []
        self.add("invocation", format=fmt, run_id=run_id, invocation_id=invocation_id,
                 attempt=attempt, attempt_label="phase%d" % attempt, producer="testsuite",
                 provenance={"ts_host": "ts"})

    ## @brief Append a line with the next time stamp
    # @param kind the line type
    # @param fields the other fields
    # @return self
    def add(self, kind, **fields):
        self.clock += 1
        line = {"type": kind, "t": "2026-10-22T14:00:%02d.000+02:00" % self.clock}
        line.update(fields)
        self.lines.append(line)
        return self

    ## @brief Append the lines of one check: selection, setup, units, cleanup
    # @param check the check path
    # @param levels dict level -> list of (function, verdict, errors)
    # @param setup the setup result
    # @param cleanup_check the result of the cleanup checks
    # @param unit_verdicts dict level -> unit_end verdict, default from functions
    # @return self
    def check(self, check, levels, setup="ok", cleanup_check="ok", unit_verdicts=None):
        unit_verdicts = unit_verdicts or {}
        self.add("selection", source="run_test",
                 units=[{"check": check, "level": level} for level in levels])
        self.add("command", function="main", command="qstat", framework=True)
        self.add("phase", check=check, levels=list(levels), phase="setup", result=setup)
        if setup != "error":
            for level, functions in levels.items():
                self.unit(check, level, functions, unit_verdicts.get(level))
            self.add("phase", check=check, levels=list(levels), phase="cleanup", result="ok")
        if cleanup_check == "error":
            self.add("error", check=check, function="cleanup_check", level="SEVERE",
                     origin="cleanup", message="job left behind")
        self.add("cleanup_check", check=check, levels=list(levels), result=cleanup_check,
                 messages=["job left behind"] if cleanup_check == "error" else [])
        return self

    ## @brief Append the lines of one unit
    # @param check the check path
    # @param level the level
    # @param functions list of (function, verdict, errors); errors are origins
    # @param verdict the unit_end verdict, None to derive it, "" for no unit_end
    # @return self
    def unit(self, check, level, functions, verdict=None):
        names = [name for name, _, _ in functions]
        self.add("unit_start", check=check, name=os.path.basename(check), level=level,
                 functions=names, test_cases={names[0]: [{"id": "STR-03", "relation": "covers"}]})
        for index, (name, result, origins) in enumerate(functions, start=1):
            self.add("function_start", function=name, index=index)
            self.add("command", function=name, command="qconf", args="-sstree")
            for origin in origins:
                self.add("error", check=check, function=name, level="SEVERE",
                         origin=origin, message="%s in %s" % (origin, name))
            if result is not None:
                self.add("function_end", function=name, verdict=result, duration=1.0)
        if verdict is None:
            failed = any(r in ("failed", "tcl_error") for _, r, _ in functions)
            verdict = "failed" if failed else "passed"
        if verdict != "":
            self.add("unit_end", check=check, level=level, verdict=verdict, duration=3.0)
        return self

    ## @brief Append invocation_end
    # @return self
    def end(self):
        return self.add("invocation_end")

    ## @brief Write the stream into a directory
    # @param directory the run directory
    # @param tail extra raw text appended after the last line
    # @return the file path
    def write(self, directory, tail=""):
        path = os.path.join(directory, "%s.jsonl" % self.invocation_id)
        with open(path, "w", encoding="utf-8") as fd:
            for line in self.lines:
                fd.write(json.dumps(line) + "\n")
            fd.write(tail)
        return path


## @brief Tests of the merge step
class MergeTest(unittest.TestCase):
    ## @brief Create a run directory per test
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.run = os.path.join(self.tmp.name, "reports", "run-1")
        os.makedirs(self.run)

    ## @brief Remove the run directory
    def tearDown(self):
        self.tmp.cleanup()

    ## @brief Merge the run directory
    # @return (merged result, units by (check, level))
    def merged(self):
        result = merge.merge([self.run])
        return result, {(u["check"], u["level"]): u for u in result["units"]}

    ## @brief Run the command line quietly
    # @param argv the arguments
    # @return the exit status
    def run_main(self, argv):
        with contextlib.redirect_stderr(io.StringIO()), contextlib.redirect_stdout(io.StringIO()):
            return merge.main(argv)

    def test_documented_example(self):
        result = merge.merge([EXAMPLES])
        with open(os.path.join(EXAMPLES, "merged.json"), encoding="utf-8") as fd:
            expected = json.load(fd)
        unit = result["units"][0]
        self.assertEqual(len(result["units"]), 1)
        for field in ("check", "level", "verdict", "retried", "attention", "deciding", "attempts"):
            self.assertEqual(unit[field], expected["units"][0][field], field)
        self.assertEqual([(f["function"], f["verdict"], f["test_cases"]) for f in unit["functions"]],
                         [(f["function"], f["verdict"], f["test_cases"])
                          for f in expected["units"][0]["functions"]])
        self.assertEqual([i["invocation_id"] for i in result["invocations"]],
                         [i["invocation_id"] for i in expected["invocations"]])
        self.assertEqual(result["warnings"], [])

    def test_last_attempt_decides_and_keeps_events(self):
        StreamBuilder("r1", attempt=1).check(CHECK, {0: [("f1", "failed", ["assertion"])]}).end().write(self.run)
        StreamBuilder("r2", attempt=2).check(CHECK, {0: [("f1", "passed", [])]}).end().write(self.run)
        _, units = self.merged()
        unit = units[(CHECK, 0)]
        self.assertEqual(unit["verdict"], "passed")
        self.assertEqual(unit["deciding"], {"invocation_id": "r2", "attempt": 2})
        self.assertTrue(unit["retried"])
        self.assertTrue(unit["attention"])
        self.assertEqual([a["verdict"] for a in unit["attempts"]], ["failed", "passed"])
        self.assertEqual(unit["attempts"][0]["class"], "assertion")
        types = [e["type"] for e in unit["events"]]
        self.assertEqual(types[0], "command")
        self.assertIn("unit_start", types)
        self.assertEqual(types[-1], "cleanup_check")
        self.assertNotIn("error", types)

    def test_load_failure_is_no_attention(self):
        StreamBuilder("r1", attempt=1).check(CHECK, {0: [("f1", "failed", ["poll_timeout"])]}).end().write(self.run)
        StreamBuilder("r2", attempt=2).check(CHECK, {0: [("f1", "passed", [])]}).end().write(self.run)
        _, units = self.merged()
        unit = units[(CHECK, 0)]
        self.assertTrue(unit["retried"])
        self.assertFalse(unit["attention"])
        self.assertEqual(unit["attempts"][0]["class"], "load")

    def test_worst_class_wins(self):
        StreamBuilder("r1", attempt=1).check(
            CHECK, {0: [("f1", "failed", ["poll_timeout", "connection"])]}).end().write(self.run)
        StreamBuilder("r2", attempt=1).check(
            OTHER, {0: [("f1", "failed", ["connection", "tcl_error"])]}).end().write(self.run)
        _, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["attempts"][0]["class"], "infrastructure")
        self.assertEqual(units[(OTHER, 0)]["attempts"][0]["class"], "assertion")

    def test_failure_without_error_is_assertion(self):
        StreamBuilder("r1", attempt=1).check(CHECK, {0: [("f1", "passed", [])]},
                                             unit_verdicts={0: "failed"}).end().write(self.run)
        _, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["attempts"][0]["class"], "assertion")

    def test_equal_attempts_latest_end_decides(self):
        builder = StreamBuilder("menu", attempt=0)
        builder.check(CHECK, {0: [("f1", "passed", [])]})
        builder.check(CHECK, {0: [("f1", "failed", ["assertion"])]})
        builder.end().write(self.run)
        _, units = self.merged()
        unit = units[(CHECK, 0)]
        self.assertEqual(unit["verdict"], "failed")
        self.assertEqual(len(unit["attempts"]), 2)
        self.assertFalse(unit["retried"])

    def test_check_setup_error_fails_every_level(self):
        StreamBuilder("r1").check(CHECK, {0: [("f1", "passed", [])], 1: [("f2", "passed", [])]},
                                  setup="error").end().write(self.run)
        _, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["verdict"], "failed")
        self.assertEqual(units[(CHECK, 1)]["verdict"], "failed")
        self.assertEqual(units[(CHECK, 0)]["functions"], [])

    def test_check_setup_skip(self):
        StreamBuilder("r1").check(CHECK, {0: [("f1", "passed", [])]}, setup="skip",
                                  unit_verdicts={0: "skipped"}).end().write(self.run)
        _, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["verdict"], "skipped")
        self.assertEqual(self.run_main([self.run, "-o", os.path.join(self.tmp.name, "m.json")]), 0)

    def test_cleanup_check(self):
        StreamBuilder("r1").check(CHECK, {0: [("f1", "passed", [])]}, cleanup_check="error") \
            .check(OTHER, {0: [("f1", "failed", ["assertion"])]}, cleanup_check="error") \
            .end().write(self.run)
        _, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["verdict"], "cleanup_failed")
        self.assertEqual(units[(OTHER, 0)]["verdict"], "failed")
        errors = units[(CHECK, 0)]["attempts"][0]["errors"]
        self.assertEqual([e["origin"] for e in errors], ["cleanup"])

    def test_unsupported(self):
        StreamBuilder("r1").check(CHECK, {0: [("f1", "unsupported", [])]},
                                  unit_verdicts={0: "unsupported"}).end().write(self.run)
        _, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["verdict"], "unsupported")

    ## @brief A stub unit keeps its verdict and reason, and the run still exits 0
    def test_not_implemented(self):
        stream = StreamBuilder("r1").check(CHECK, {0: [("f1", "not_implemented", [])]},
                                           unit_verdicts={0: "not_implemented"})
        for line in stream.lines:
            if line["type"] == "function_end":
                line["reason"] = "needs the role enforcement"
        stream.end().write(self.run)
        _, units = self.merged()
        unit = units[(CHECK, 0)]
        self.assertEqual(unit["verdict"], "not_implemented")
        self.assertEqual(unit["functions"][0]["verdict"], "not_implemented")
        self.assertEqual(unit["functions"][0]["reason"], "needs the role enforcement")
        self.assertFalse(unit["retried"])
        self.assertEqual(self.run_main([self.run, "-o", "-"]), 0)

    ## @brief A cleanup check that found something outranks a stub
    def test_not_implemented_cleanup_failed(self):
        StreamBuilder("r1").check(CHECK, {0: [("f1", "not_implemented", [])]}, cleanup_check="error",
                                  unit_verdicts={0: "not_implemented"}).end().write(self.run)
        _, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["verdict"], "cleanup_failed")

    def test_module_test_stream(self):
        # the lines ocs_module_test.h writes: no phases, scenarios as functions,
        # one assertion per CHECK, a drift error for an undeclared CHECK
        stream = StreamBuilder("ts-9-1")
        stream.lines[0]["producer"] = "module_test"
        stream.add("selection", source="command_line", units=[{"check": "test_x", "level": 0}])
        stream.add("unit_start", check="test_x", check_path="./test_x", level=0,
                   functions=["X-01", "X-02"], test_cases={"X-02": [{"id": "A-01", "relation": "covers"}]})
        stream.add("function_start", function="X-01", index=1)
        stream.add("assertion", function="X-01", id=1, label="one", result="ok")
        stream.add("function_end", function="X-01", verdict="passed", duration=0.1)
        stream.add("function_start", function="X-02", index=2)
        stream.add("assertion", function="X-02", id=2, label="two", result="ok")
        stream.add("error", function="X-02", level="SEVERE", origin="drift",
                   message="CHECK 2 is not declared by scenario X-02")
        stream.add("function_end", function="X-02", verdict="failed", duration=0.1)
        stream.add("unit_end", check="test_x", level=0, verdict="failed", duration=0.2)
        stream.add("invocation_end", exit=1).write(self.run)
        result, units = self.merged()
        entry = units[("test_x", 0)]
        self.assertEqual(entry["verdict"], "failed")
        self.assertEqual([(f["function"], f["verdict"]) for f in entry["functions"]],
                         [("X-01", "passed"), ("X-02", "failed")])
        self.assertEqual(entry["functions"][1]["test_cases"], [{"id": "A-01", "relation": "covers"}])
        self.assertEqual(entry["attempts"][0]["class"], "assertion")
        self.assertEqual(len([e for e in entry["events"] if e["type"] == "assertion"]), 2)
        self.assertEqual(result["invocations"][0]["producer"], "module_test")

    def test_nested_check(self):
        # a reinstall inside a function runs an INSTALL check through run_test
        builder = StreamBuilder("r1")
        builder.add("selection", source="run_test", units=[{"check": CHECK, "level": 0}])
        builder.add("phase", check=CHECK, levels=[0], phase="setup", result="ok")
        builder.add("unit_start", check=CHECK, name="c", level=0, functions=["f1", "f2"])
        builder.add("function_start", function="f1", index=1)
        builder.check(OTHER, {0: [("install", "passed", [])]})
        builder.add("function_end", function="f1", verdict="passed", duration=1.0)
        builder.add("function_start", function="f2", index=2)
        builder.add("function_end", function="f2", verdict="passed", duration=1.0)
        builder.add("unit_end", check=CHECK, level=0, verdict="passed", duration=3.0)
        builder.add("phase", check=CHECK, levels=[0], phase="cleanup", result="ok")
        builder.add("cleanup_check", check=CHECK, levels=[0], result="ok", messages=[])
        builder.end().write(self.run)
        result, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["verdict"], "passed")
        self.assertEqual([f["verdict"] for f in units[(CHECK, 0)]["functions"]], ["passed", "passed"])
        self.assertEqual(units[(OTHER, 0)]["verdict"], "passed")
        self.assertEqual(result["warnings"], [])

    def test_killed_inside_nested_check(self):
        builder = StreamBuilder("r1")
        builder.add("selection", source="run_test", units=[{"check": CHECK, "level": 0}])
        builder.add("phase", check=CHECK, levels=[0], phase="setup", result="ok")
        builder.add("unit_start", check=CHECK, name="c", level=0, functions=["f1"])
        builder.add("function_start", function="f1", index=1)
        builder.add("selection", source="run_test", units=[{"check": OTHER, "level": 0}])
        builder.unit(OTHER, 0, [("install", None, [])], verdict="")
        builder.write(self.run)
        _, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["verdict"], "interrupted")
        self.assertEqual(units[(OTHER, 0)]["verdict"], "interrupted")

    def test_killed_invocation(self):
        builder = StreamBuilder("r1")
        builder.add("selection", source="command_line",
                    units=[{"check": CHECK, "level": 0}, {"check": OTHER, "level": 0}])
        builder.add("selection", source="run_test", units=[{"check": CHECK, "level": 0}])
        builder.add("phase", check=CHECK, levels=[0], phase="setup", result="ok")
        builder.unit(CHECK, 0, [("f1", "passed", []), ("f2", None, [])], verdict="")
        builder.write(self.run, tail='{"type": "command", "t": "2026-10')
        result, units = self.merged()
        unit = units[(CHECK, 0)]
        self.assertEqual(unit["verdict"], "interrupted")
        self.assertEqual([f["verdict"] for f in unit["functions"]], ["passed", "interrupted"])
        self.assertEqual(units[(OTHER, 0)]["verdict"], "not_run")
        self.assertIsNone(units[(OTHER, 0)]["deciding"])
        self.assertEqual(len(result["warnings"]), 2)
        self.assertIn("last line cut off", result["warnings"][0])
        self.assertIn("killed", result["warnings"][1])
        self.assertEqual(self.run_main([self.run, "-o", os.path.join(self.tmp.name, "m.json")]), 1)

    def test_broken_middle_line_is_skipped(self):
        path = StreamBuilder("r1").check(CHECK, {0: [("f1", "passed", [])]}).end().write(self.run)
        with open(path, encoding="utf-8") as fd:
            lines = fd.read().splitlines()
        lines.insert(3, "not json")
        with open(path, "w", encoding="utf-8") as fd:
            fd.write("\n".join(lines) + "\n")
        result, units = self.merged()
        self.assertEqual(units[(CHECK, 0)]["verdict"], "passed")
        self.assertIn("line 4", result["warnings"][0])

    def test_several_directories(self):
        other = os.path.join(self.tmp.name, "r2", "run-1")
        os.makedirs(other)
        StreamBuilder("a", attempt=1).check(CHECK, {0: [("f1", "failed", ["assertion"])]}).end().write(self.run)
        StreamBuilder("b", attempt=2).check(CHECK, {0: [("f1", "passed", [])]}).end().write(other)
        result = merge.merge([self.run, other, self.run])
        self.assertEqual(len(result["invocations"]), 2)
        self.assertEqual(result["units"][0]["verdict"], "passed")

    def test_reports_directory_needs_run_id(self):
        StreamBuilder("r1").check(CHECK, {0: [("f1", "passed", [])]}).end().write(self.run)
        reports = os.path.dirname(self.run)
        with self.assertRaises(merge.InputError):
            merge.merge([reports])
        self.assertEqual(merge.merge([reports], "run-1")["run_id"], "run-1")

    def test_mixed_run_ids_are_rejected(self):
        StreamBuilder("r1").check(CHECK, {0: [("f1", "passed", [])]}).end().write(self.run)
        StreamBuilder("r2", run_id="run-2").check(CHECK, {0: [("f1", "passed", [])]}).end().write(self.run)
        with self.assertRaises(merge.InputError):
            merge.merge([self.run])
        self.assertEqual(self.run_main([self.run, "-o", os.path.join(self.tmp.name, "m.json")]), 2)

    def test_unknown_format_is_rejected(self):
        StreamBuilder("r1", fmt="ts-report/record/2").end().write(self.run)
        with self.assertRaises(merge.InputError):
            merge.merge([self.run])

    def test_output_file(self):
        StreamBuilder("r1").check(CHECK, {0: [("f1", "passed", [])]}).end().write(self.run)
        out = os.path.join(self.tmp.name, "m.json")
        self.assertEqual(self.run_main([self.run, "-o", out]), 0)
        with open(out, encoding="utf-8") as fd:
            written = json.load(fd)
        self.assertEqual(written["format"], "ts-report/merged/2")
        self.assertEqual(written["units"][0]["functions"][0]["test_cases"],
                         [{"id": "STR-03", "relation": "covers"}])


if __name__ == "__main__":
    unittest.main()
