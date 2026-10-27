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

# Tests of ts_report_render.py (CS-2936).
#
# Run from this directory: python3 -B -m unittest test_ts_report_render
# (-B keeps __pycache__ out of the source tree)

import contextlib
import copy
import io
import json
import os
import tempfile
import unittest
import zipfile

import ts_report_render as render

HERE = os.path.dirname(os.path.abspath(__file__))
EXAMPLES = os.path.join(HERE, "..", "..", "doc", "reports", "examples")
CHECK = "/ts/checktree/functional/sharetree"


## @brief A command line of the record stream
# @param args the arguments
# @param fields further fields, overriding the defaults
# @return the line
def command(args, **fields):
    line = {"type": "command", "t": "2026-10-22T15:57:04.000+02:00", "function": "f1",
            "host": "host-0012", "user": "ebablick", "root": False,
            "command": "/inst/bin/lx-amd64/qconf", "args": args,
            "start": "2026-10-22T15:57:03.000+02:00", "end": "2026-10-22T15:57:04.000+02:00",
            "exit": 0, "timed_out": False, "background": False, "interactive": False,
            "framework": False, "diagnostic": False,
            "output": {"bytes": 6, "excerpt": "output", "truncated": False}}
    line.update(fields)
    return line


## @brief A merged unit
# @param verdict the unit verdict
# @param functions (name, verdict, test cases) per function
# @param events the events of the deciding attempt
# @param check the check path
# @return the unit
def unit(verdict, functions, events=None, check=CHECK):
    return {"check": check, "level": 0, "verdict": verdict, "retried": False,
            "attention": False, "deciding": {"invocation_id": "ts-1-1", "attempt": 0},
            "functions": [{"function": name, "verdict": v, "duration": 1.0,
                           "test_cases": [{"id": i, "relation": r} for i, r in cases]}
                          for name, v, cases in functions],
            "attempts": [{"invocation_id": "ts-1-1", "attempt": 0, "attempt_label": "interactive",
                          "verdict": verdict}],
            "events": events or []}


## @brief A merged result
# @param units the units
# @return the merged result
def merged(*units):
    return {"format": "ts-report/merged/2", "run_id": "run-1", "merged_at": "x", "inputs": [],
            "invocations": [{"invocation_id": "ts-1-1", "attempt": 0, "attempt_label": "interactive",
                             "provenance": {"ts_host": "ts", "product": "GCS",
                                            "product_version": "9.1.8"}}],
            "warnings": [], "units": list(units)}


## @brief A catalog with three cases and four criteria
# @return the catalog
def catalog():
    def case(case_id, owner="product", criteria=()):
        return {"id": case_id, "title": "title of " + case_id, "section": "Tests",
                "plan_section": "15.1", "phase": "Phase 1", "milestone": "M1",
                "milestone_text": "M1", "see": "", "verifies": "it works", "steps": ["do it"],
                "pass": "it worked", "notes": [], "owner": owner, "source": "customer",
                "criteria": list(criteria)}
    return {"format": "ts-report/catalog/1", "source": {"title": "Spec", "version": "1.0"},
            "milestones": [{"id": "M1", "title": "First", "date": "T0"}],
            "test_cases": [case("A-01", criteria=["M1-AC-01"]), case("A-02", criteria=["M1-AC-01"]),
                           case("S-01", owner="site"), case("U-01"),
                           dict(case("X-01"), source="additional")],
            "criteria": [{"id": "M1-AC-01", "milestone": "M1", "criterion": "both pass",
                          "mapping": "test_ids", "test_ids": ["A-01", "A-02"]},
                         {"id": "M1-AC-02", "milestone": "M1", "criterion": "described",
                          "mapping": "test_ids", "mapped_by": "Product tests", "test_ids": []},
                         {"id": "M1-AC-03", "milestone": "M1", "criterion": "the run",
                          "mapping": "run"},
                         {"id": "M1-AC-04", "milestone": "M1", "criterion": "by hand",
                          "mapping": "manual"}],
            "unmapped": ["S-01", "U-01", "X-01"]}


## @brief Tests of the render step
class RenderTest(unittest.TestCase):
    ## @brief Build a report
    # @param data the merged result
    # @param with_catalog True to join the test catalog
    # @param internal True for the internal audience
    # @return the Report
    def report(self, data, with_catalog=True, internal=False):
        return render.Report(data, catalog() if with_catalog else None, internal)

    def test_case_verdicts(self):
        data = merged(unit("failed", [("f1", "passed", [("A-01", "covers")]),
                                      ("f2", "failed", [("A-02", "covers")]),
                                      ("f3", "passed", [("U-01", "prepares")])]))
        report = self.report(data)
        self.assertEqual(report.case_verdict("A-01"), "passed")
        self.assertEqual(report.case_verdict("A-02"), "failed")
        self.assertEqual(report.case_verdict("U-01"), "prepared_only")
        self.assertEqual(report.case_verdict("S-01"), "site")
        self.assertEqual(report.criterion_verdict(catalog()["criteria"][0]), "failed")

    def test_unit_wide_failure_fails_every_case(self):
        events = [{"type": "error", "function": "cleanup_check", "level": "SEVERE",
                   "origin": "cleanup", "message": "job left behind"}]
        report = self.report(merged(unit("cleanup_failed", [("f1", "passed", [("A-01", "covers")])],
                                         events)))
        self.assertEqual(report.case_verdict("A-01"), "failed")
        events = [{"type": "phase", "check": CHECK, "levels": [0], "phase": "cleanup",
                   "result": "error"}]
        report = self.report(merged(unit("failed", [("f1", "passed", [("A-01", "covers")]),
                                                    ("f2", "failed", [])], events)))
        self.assertEqual(report.case_verdict("A-01"), "failed")

    def test_criterion_verdicts(self):
        criteria = catalog()["criteria"]
        report = self.report(merged(unit("passed", [("f1", "passed", [("A-01", "covers")])])))
        self.assertEqual(report.criterion_verdict(criteria[0]), "open")
        self.assertIn("A-02", report.open_reason(criteria[0]))
        self.assertEqual(report.criterion_verdict(criteria[1]), "open")
        self.assertIn("Product tests", report.open_reason(criteria[1]))
        self.assertEqual(report.criterion_verdict(criteria[2]), "passed")
        self.assertEqual(report.criterion_verdict(criteria[3]), "manual")
        report = self.report(merged(unit("passed", [("f1", "passed", [("A-01", "covers"),
                                                                      ("A-02", "covers")])])))
        self.assertEqual(report.criterion_verdict(criteria[0]), "passed")
        report = self.report(merged(unit("passed", [("f1", "passed", [("A-01", "covers")])]),
                                    unit("not_run", [("f2", None, [("A-02", "covers")])],
                                         check="/ts/checktree/other")))
        self.assertEqual(report.criterion_verdict(criteria[0]), "failed")
        self.assertEqual(report.criterion_verdict(criteria[2]), "failed")

    def test_consistency_warnings(self):
        report = self.report(merged(unit("passed", [("f1", "passed", [("X-99", "covers"),
                                                                      ("S-01", "covers")])])))
        self.assertTrue(any("X-99" in w and "not in the catalog" in w for w in report.warnings))
        self.assertTrue(any("S-01 is a site case" in w for w in report.warnings))

    def test_trace_sections(self):
        events = [command("-help", function="main", framework=True),
                  {"type": "phase", "phase": "setup", "result": "ok", "levels": [0]},
                  {"type": "unit_start", "check": CHECK, "level": 0},
                  {"type": "function_start", "function": "f1", "index": 1},
                  command("-sq"),
                  {"type": "function_end", "function": "f1", "verdict": "passed"},
                  command("-between"),
                  {"type": "function_start", "function": "f2", "index": 2},
                  command("-sconf"),
                  {"type": "function_end", "function": "f2", "verdict": "passed"},
                  command("-level-cleanup"),
                  {"type": "phase", "phase": "cleanup_level", "result": "ok", "level": 0},
                  {"type": "unit_end", "check": CHECK, "level": 0, "verdict": "passed"},
                  command("-check-cleanup")]
        trace = render.Trace(events)
        keys = [key for key, _ in trace.sections]
        self.assertEqual(keys, ["Check setup", ("function", "f1"), ("function", "f2"),
                                "Level cleanup", "Check cleanup"])
        f1 = render.TraceText(False).lines(trace.function_items("f1"))
        self.assertEqual([l.split("$ ")[1] for l in f1], ["qconf -sq", "qconf -between"])
        self.assertEqual(render.TraceText(False).lines(trace.sections[0][1]), [])
        self.assertIn("[framework]", render.TraceText(True).lines(trace.sections[0][1])[0])

    def test_poll_context_collapses(self):
        events = [{"type": "function_start", "function": "f1"}]
        for second in range(3):
            events.append(command("-u '*'", command="/inst/bin/qstat", poll=1,
                                  start="2026-10-22T15:57:0%d.000+02:00" % second))
        events.append(command("-f", command="/inst/bin/qstat", poll=2, diagnostic=True))
        events.append({"type": "poll", "id": 2, "parent": 1, "helper": "inner",
                       "condition": "inner", "outcome": "met", "commands": 1,
                       "start": "2026-10-22T15:57:02.000+02:00",
                       "end": "2026-10-22T15:57:03.000+02:00"})
        events.append({"type": "poll", "id": 1, "parent": None, "function": "f1",
                       "helper": "wait_for_jobstart", "framework": False,
                       "condition": "job 1 running", "timeout": 60, "outcome": "met",
                       "commands": 3, "start": "2026-10-22T15:57:00.000+02:00",
                       "end": "2026-10-22T15:57:06.000+02:00"})
        trace = render.Trace(events)
        external = render.TraceText(False).lines(trace.function_items("f1"))
        self.assertEqual(len(external), 2)
        self.assertIn("wait_for_jobstart: job 1 running: met after 6.0 s (timeout 60 s)", external[0])
        self.assertIn("qstat -u '*'  (3x)", external[1])
        internal = render.TraceText(True).lines(trace.function_items("f1"))
        self.assertEqual(sum("qstat -u" in l for l in internal), 3)
        self.assertTrue(any("[diagnostic]" in l for l in internal))
        self.assertTrue(any("inner: inner: met" in l for l in internal))

    def test_framework_poll_hidden_externally(self):
        events = [{"type": "function_start", "function": "f1"},
                  command("x", command="/bin/expect", poll=1, framework=True),
                  {"type": "poll", "id": 1, "parent": None, "helper": "wait_for_remote_file",
                   "framework": True, "condition": "file", "outcome": "met", "commands": 1,
                   "start": "2026-10-22T15:57:00.000+02:00", "end": "2026-10-22T15:57:01.000+02:00"}]
        trace = render.Trace(events)
        self.assertEqual(render.TraceText(False).lines(trace.function_items("f1")), [])
        internal = render.TraceText(True).lines(trace.function_items("f1"))
        self.assertTrue(internal[0].startswith("15:57:00 [framework] wait_for_remote_file"))
        self.assertIn("[framework] ebablick@host-0012$ /bin/expect x", internal[1])

    def test_repeated_commands_and_output(self):
        events = [{"type": "function_start", "function": "f1"}, command("-sq"), command("-sq"),
                  command("-dq x", exit=1, output={"bytes": 9, "excerpt": "denied\n",
                                                   "truncated": False})]
        trace = render.Trace(events)
        lines = render.TraceText(False).lines(trace.function_items("f1"))
        self.assertIn("(repeated 2x over", lines[0])
        self.assertTrue(lines[1].endswith("ebablick@host-0012$ qconf -dq x"))
        self.assertEqual([l.strip() for l in lines[2:]], ["exit status 1", "| denied"])
        self.assertNotIn("| output", "\n".join(lines))
        internal = render.TraceText(True).lines(trace.function_items("f1"))
        self.assertIn("/inst/bin/lx-amd64/qconf -sq", internal[0])
        self.assertTrue(any("| output" in l for l in internal))

    def test_step_context_collapses(self):
        events = [{"type": "function_start", "function": "f1"},
                  command("-km", step=1),
                  command("-f /pid", command="/bin/test", step=1),
                  command("-weo pid", command="/bin/ps", poll=2, step=1),
                  {"type": "poll", "id": 2, "parent": 1, "helper": "wait_till_qmaster_is_down",
                   "condition": "qmaster gone", "outcome": "met", "commands": 1,
                   "start": "2026-10-22T15:57:01.000+02:00", "end": "2026-10-22T15:57:02.000+02:00"},
                  {"type": "step", "id": 1, "parent": None, "helper": "shutdown_qmaster",
                   "framework": False, "description": "stop qmaster on host-0012", "outcome": "ok",
                   "commands": 2, "start": "2026-10-22T15:57:00.000+02:00",
                   "end": "2026-10-22T15:57:04.000+02:00"},
                  command("-sq")]
        trace = render.Trace(events)
        external = render.TraceText(False).lines(trace.function_items("f1"))
        self.assertEqual(len(external), 2)
        self.assertIn("shutdown_qmaster: stop qmaster on host-0012: ok after 4.0 s (2 commands)",
                      external[0])
        self.assertIn("qconf -sq", external[1])
        internal = render.TraceText(True).lines(trace.function_items("f1"))
        self.assertTrue(any("wait_till_qmaster_is_down: qmaster gone: met" in l for l in internal))
        self.assertEqual(sum("$" in l for l in internal), 4)
        events[5]["outcome"] = "error"
        external = render.TraceText(False).lines(render.Trace(events).function_items("f1"))
        self.assertIn("ps -weo pid", external[1])

    def test_background_commands_in_start_order(self):
        events = [{"type": "function_start", "function": "f1"},
                  command("-km", start="2026-10-22T15:57:10.000+02:00",
                          t="2026-10-22T15:57:11.000+02:00")]
        # recorded when they end, so after the -km they overlap with
        for second in ("00", "01"):
            events.append(command("-sync y", command="/inst/bin/qsub", interactive=True, exit=None,
                                  output=None, start="2026-10-22T15:57:%s.000+02:00" % second,
                                  t="2026-10-22T15:57:3%s.000+02:00" % second[1]))
        lines = render.TraceText(False).lines(render.Trace(events).function_items("f1"))
        prompts = [l for l in lines if "$" in l]
        self.assertEqual([p[:8] for p in prompts], ["15:57:00", "15:57:01", "15:57:10"])
        self.assertFalse(any("repeated" in l for l in lines))

    def test_fence_survives_backticks(self):
        block = render.fence(["a ``` b"])
        self.assertEqual(block[0], "````text")
        self.assertEqual(block[-1], "````")

    def test_index_groups_by_verdict(self):
        failed = unit("failed", [("f1", "failed", [])], check="/ts/checktree/bugs/b1")
        failed["attempts"][0].update(attempt_label="phase1",
                                     errors=[{"function": "f1", "message": "qconf said no"}])
        not_run = unit("not_run", [], check="/ts/checktree/bugs/b2")
        not_run["attempts"] = []
        passed = [unit("passed", [("f1", "passed", [])],
                       check="/ts/checktree/%s/p%d" % ("functional" if i < 6 else "object", i))
                  for i in range(11)]
        data = merged(*(passed + [not_run, failed]))
        internal = self.report(data, with_catalog=False, internal=True).index()
        order = [internal.index(h) for h in ("### Failed (1)", "### Not run (1)",
                                             "### Attention", "### Passed (11)")]
        self.assertEqual(order, sorted(order))
        self.assertIn("**Result:** failed (1 failed, 1 not_run, 11 passed)", internal)
        # more than GROUP_SPLIT units are split by area, fewer are not
        self.assertIn("#### functional (6)", internal)
        self.assertIn("#### object (5)", internal)
        self.assertNotIn("#### bugs", internal)
        self.assertIn("| phase1 failed | qconf said no |\n", internal)
        self.assertIn("| none | selected, never started |", internal)
        external = self.report(data, with_catalog=False).index()
        self.assertIn("| [bugs/b1](units/bugs.b1-L0.md) | 0 | qconf said no |", external)
        self.assertNotIn("Attempts", external)
        self.assertNotIn("Attention", external)

    def test_additional_scenarios_stay_apart(self):
        data = merged(unit("passed", [("f1", "passed", [("X-01", "covers"), ("A-01", "prepares")])]))
        pages = self.report(data).pages()
        milestone = pages["milestones/M1.md"]
        verified, additional = (milestone.index("## Verified, not acceptance-relevant"),
                                milestone.index("## Additional test scenarios"))
        self.assertLess(verified, additional)
        self.assertNotIn("X-01", milestone[verified:additional])
        self.assertIn("[X-01](../cases/X-01.md)", milestone[additional:])
        self.assertIn("none, an additional test scenario", pages["cases/X-01.md"])
        self.assertIn("not part of the agreed test plan", pages["cases/X-01.md"])
        self.assertIn("preconditions verified only", pages["cases/A-01.md"])

    def test_external_hides_internal_parts(self):
        data = merged(unit("passed", [("f1", "passed", [("A-01", "covers")])]))
        data["units"][0].update(retried=True, attention=True)
        data["units"][0]["attempts"].insert(0, {"invocation_id": "ts-0", "attempt": 0,
                                                "attempt_label": "phase1", "verdict": "failed",
                                                "class": "assertion",
                                                "errors": [{"function": "f1", "message": "boom"}]})
        data["warnings"] = ["a merge warning"]
        external = self.report(data).pages()
        text = "\n".join(external.values())
        for hidden in ("Attempts", "Attention", "boom", "phase1", "a merge warning", "/ts/checktree",
                       "Internal report"):
            self.assertNotIn(hidden, text)
        internal = "\n".join(self.report(data, internal=True).pages().values())
        for shown in ("Attempts", "Attention", "boom", "a merge warning", "Internal report"):
            self.assertIn(shown, internal)

    def test_module_test_unit(self):
        events = [{"type": "assertion", "function": "X-01", "id": 1, "label": "one", "result": "ok"},
                  {"type": "assertion", "function": "X-01", "id": 2, "label": "two", "result": "fail"}]
        data = merged(unit("failed", [("X-01", "failed", [])], events, check="test_x"))
        data["invocations"].append({"invocation_id": "ts-9-1", "attempt": 0, "producer": "module_test",
                                    "provenance": {"ts_host": "host-0013", "binary": "./test_x"}})
        for internal in (False, True):
            pages = self.report(data, with_catalog=False, internal=internal).pages()
            page = next(text for name, text in pages.items() if name.startswith("units/"))
            self.assertIn("## Checks", page)
            self.assertIn("| `X-01` | T02 | two | fail |", page)
            # the provenance describes the testsuite, not the module test
            self.assertIn("GCS 9.1.8", pages["index.md"])
            self.assertIn("## Module tests", pages["guide.md"])
        prompt = render.TraceText(False).prompt(command("--report=- --report-run=r1 user1", command="test_x"),
                                                 False)
        self.assertTrue(prompt.endswith("$ test_x user1"), prompt)

    def test_pages(self):
        data = merged(unit("passed", [("f1", "passed", [("A-01", "covers")])]))
        pages = self.report(data).pages()
        self.assertEqual(sorted(pages), ["cases/A-01.md", "cases/A-02.md", "cases/S-01.md",
                                         "cases/U-01.md", "cases/X-01.md", "guide.md", "index.md",
                                         "milestones/M1.md", "units/functional.sharetree-L0.md"])
        self.assertIn("[How to read this report](guide.md)", pages["index.md"])
        self.assertIn("[How to read this report](../guide.md)", pages["cases/A-01.md"])
        self.assertIn("| prepares |", pages["guide.md"])
        self.assertNotIn("## Internal report", pages["guide.md"])
        milestone = pages["milestones/M1.md"]
        self.assertIn("| [M1-AC-01](#m1-ac-01) | both pass | [A-01](../cases/A-01.md), "
                      "[A-02](../cases/A-02.md) | **open** |", milestone)
        self.assertIn("**manual, verified by the customer**", milestone)
        self.assertIn("## Verified, not acceptance-relevant", milestone)
        self.assertIn("Test cases outside the testsuite", pages["index.md"])
        self.assertIn("No test of this run names this case.", pages["cases/A-02.md"])
        without = self.report(data, with_catalog=False).pages()
        self.assertEqual(sorted(without), ["guide.md", "index.md",
                                           "units/functional.sharetree-L0.md"])
        self.assertNotIn("prepares", without["guide.md"])
        internal = self.report(data, internal=True).pages()
        self.assertIn("## Internal report", internal["guide.md"])
        self.assertIn("## Test cases", without["index.md"])

    def test_examples(self):
        data = render.load(os.path.join(EXAMPLES, "merged.json"), "merged")
        cat = render.load(os.path.join(EXAMPLES, "catalog.json"), "catalog")
        report = render.Report(data, cat, False)
        self.assertEqual(report.case_verdict("STR-03"), "passed")
        criteria = {c["id"]: c for c in cat["criteria"]}
        self.assertEqual(report.criterion_verdict(criteria["M3-AC-04"]), "open")
        self.assertEqual(report.criterion_verdict(criteria["M3-AC-08"]), "passed")
        unit_page = report.pages()["units/functional.sharetree-L0.md"]
        self.assertIn("wait_for_online_usage: usage of job 1234 reported: met after 7.0 s", unit_page)

    ## @brief Stubs: their cases and criteria stay open, the run is open, not passed
    def test_not_implemented(self):
        done = unit("passed", [("f1", "passed", [("A-01", "covers")])])
        stub = unit("not_implemented", [("f2", "not_implemented", [("A-02", "covers")])],
                    check="/ts/checktree/functional/stub")
        stub["functions"][0]["reason"] = "needs the role enforcement"
        for internal in (False, True):
            report = self.report(merged(done, stub), internal=internal)
            self.assertEqual(report.case_verdict("A-02"), "not_implemented")
            criteria = {c["id"]: c for c in report.catalog["criteria"]}
            self.assertEqual(report.criterion_verdict(criteria["M1-AC-01"]), "open")
            self.assertEqual(report.open_reason(criteria["M1-AC-01"]), "not implemented: A-02")
            self.assertEqual(report.run_verdict(), "open")
            self.assertEqual(report.criterion_verdict(criteria["M1-AC-03"]), "open")
            index = report.index()
            self.assertIn("**Result:** open, tests not implemented yet", index)
            self.assertIn("### Not implemented (1)", index)
            self.assertIn("needs the role enforcement", index)
            # stubs come after the failing groups and before the passed ones
            self.assertLess(index.index("### Not implemented"), index.index("### Passed"))
            page = report.case_page(report.cases["A-02"])
            self.assertIn("not implemented yet: needs the role enforcement", page)
        # a stub never hides a failure of the run
        failed = unit("failed", [("f3", "failed", [])], check="/ts/checktree/functional/bad")
        self.assertEqual(self.report(merged(done, stub, failed)).run_verdict(), "failed")

    ## @brief A merged result of format version 1 is still read
    def test_reads_merged_1(self):
        with tempfile.TemporaryDirectory() as tmp:
            source = os.path.join(tmp, "merged.json")
            with open(source, "w", encoding="utf-8") as fd:
                json.dump(dict(merged(), format="ts-report/merged/1"), fd)
            self.assertEqual(render.load(source, "merged")["format"], "ts-report/merged/1")

    def test_main(self):
        with tempfile.TemporaryDirectory() as tmp:
            source = os.path.join(tmp, "merged.json")
            with open(source, "w", encoding="utf-8") as fd:
                json.dump(merged(unit("passed", [("f1", "passed", [])])), fd)
            out = os.path.join(tmp, "report")
            with contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(render.main([source, "--audience", "external", "-o", out,
                                              "--zip"]), 0)
                with zipfile.ZipFile(out + ".zip") as zf:
                    self.assertIn("report/index.md", zf.namelist())
                # a second render must not mix with the first
                self.assertEqual(render.main([source, "--audience", "internal", "-o", out]), 2)
                broken = copy.deepcopy(merged())
                broken["format"] = "ts-report/merged/3"
                with open(source, "w", encoding="utf-8") as fd:
                    json.dump(broken, fd)
                self.assertEqual(render.main([source, "--audience", "external", "-o",
                                              os.path.join(tmp, "other")]), 2)
                with self.assertRaises(SystemExit):
                    render.main([source, "-o", os.path.join(tmp, "third")])


if __name__ == "__main__":
    unittest.main()
