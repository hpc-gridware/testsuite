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

# Render step of the testsuite reports (CS-2936).
#
# Turns a merged result (written by ts_report_merge.py), optionally joined
# with a test-case catalog, into Markdown: an index of the run, one page per
# unit (check and level) with its command trace, and with a catalog one page
# per test case and one per milestone, led by the acceptance criteria. The
# formats and the rules are described in testsuite/doc/reports/format.md.
#
# The audience decides what the report shows: "internal" keeps every attempt,
# the framework and diagnostic commands and every iteration of a polling
# loop; "external" shows the final verdict and the trace of the deciding
# execution only.
#
# Standard library only, Python 3.9 or newer.
#
# Exit status: 0 rendered, 2 invalid input or output directory not empty.

import argparse
import datetime
import json
import os
import sys
import zipfile

AUDIENCES = ("internal", "external")

# unit verdicts that count as "did not pass", as in ts_report_merge.py
FAILING = ("failed", "cleanup_failed", "interrupted", "not_run")

# test-case verdicts from the executions that cover a case, worst last
CASE_RANK = {"passed": 0, "skipped": 1, "unsupported": 2, "not_run": 3, "failed": 4}

# what a case verdict says in the report
CASE_TEXT = {
    "passed": "passed",
    "failed": "failed",
    "not_run": "not run",
    "skipped": "skipped",
    "unsupported": "unsupported environment",
    "prepared_only": "preconditions verified only",
    "not_covered": "not covered by this run",
    "site": "site control, not covered by the testsuite",
    "later": "later phase, not covered by the testsuite",
}

CRITERION_TEXT = {
    "passed": "passed",
    "failed": "failed",
    "open": "open",
    "manual": "manual, verified by the customer",
}

# poll outcomes as the trace states them
OUTCOME_TEXT = {"met": "met", "timeout": "timed out", "error": "ended with an error"}


## @brief Error in the input or the output directory that makes rendering impossible
class InputError(Exception):
    pass


## @brief Read a JSON document and check its format field
# @param path the file to read
# @param kind the expected kind, e.g. merged or catalog
# @return the parsed document
def load(path, kind):
    try:
        with open(path, encoding="utf-8") as fd:
            data = json.load(fd)
    except ValueError as error:
        raise InputError("%s: not valid JSON: %s" % (path, error))
    expected = "ts-report/%s/1" % kind
    if not isinstance(data, dict) or data.get("format") != expected:
        raise InputError("%s: format is %r, expected %s" %
                         (path, data.get("format") if isinstance(data, dict) else None, expected))
    return data


## @brief Parse an ISO 8601 time stamp
# @param text the time stamp
# @return an aware datetime, or None for a missing or invalid stamp
def parse_time(text):
    try:
        return datetime.datetime.fromisoformat(text)
    except (TypeError, ValueError):
        return None


## @brief Seconds between two time stamps
# @param start the earlier time stamp
# @param end the later time stamp
# @return the difference in seconds, or None if a stamp is missing
def seconds(start, end):
    a, b = parse_time(start), parse_time(end)
    if a is None or b is None:
        return None
    return (b - a).total_seconds()


## @brief Format a duration for the report
# @param value seconds, or None
# @return e.g. "6 s", "0.4 s", "2 min 5 s", or "" for None
def duration_text(value):
    if value is None:
        return ""
    if value < 10:
        return "%.1f s" % value
    value = int(round(value))
    if value < 120:
        return "%d s" % value
    return "%d min %d s" % (value // 60, value % 60)


## @brief The wall-clock part of a time stamp
# @param text the time stamp
# @return HH:MM:SS, or eight blanks
def clock(text):
    if isinstance(text, str) and len(text) >= 19:
        return text[11:19]
    return " " * 8


## @brief The check path as the report shows it: the part below the checktree
# @param check the check path as recorded
# @return the path below the last checktree directory
def check_name(check):
    marker = "/checktree/"
    index = check.rfind(marker)
    return check[index + len(marker):] if index >= 0 else check


## @brief The page name of a unit
# @param unit the merged unit
# @return the file name below units/
def unit_file(unit):
    return "%s-L%s.md" % (check_name(unit["check"]).strip("/").replace("/", "."), unit["level"])


## @brief Escape text for a Markdown table cell
# @param text the cell text
# @return the text on one line with the pipes escaped
def cell(text):
    if text is None:
        return ""
    return " ".join(str(text).split("\n")).replace("|", "\\|")


## @brief Shorten a message to one line for a list or a table
#
# Keeps the first line, and the second one too when the first only
# introduces it (ends with a colon, or is a bare label like "TCL Error").
# @param message the message, possibly over several lines
# @param limit the maximum length
# @return the message on one line, cut at the limit
def summary(message, limit=240):
    lines = [l.strip() for l in (message or "").split("\n") if l.strip()]
    text = lines[0] if lines else ""
    if len(lines) > 1 and (text.endswith(":") or len(text) < 20):
        text += " " + lines[1]
    return text if len(text) <= limit else text[:limit - 3] + "..."


## @brief Render a Markdown table
# @param header the column titles
# @param rows the rows, each a list of cell texts (already escaped)
# @return the table lines
def table(header, rows):
    lines = ["| " + " | ".join(header) + " |", "|" + "|".join(":---" for _ in header) + "|"]
    for row in rows:
        lines.append("| " + " | ".join(row) + " |")
    return lines


## @brief Wrap lines into a fenced code block that their content cannot close
# @param lines the content lines
# @return the block lines
def fence(lines):
    width = 3
    for line in lines:
        run = 0
        for char in line:
            run = run + 1 if char == "`" else 0
            width = max(width, run + 1)
    mark = "`" * width
    return [mark + "text"] + lines + [mark]


## @brief One command, or a run of identical commands, in a trace
class CommandItem:
    ## @brief Start the item with its first command
    # @param event the command line
    def __init__(self, event):
        self.events = [event]

    ## @brief Tell whether a command repeats this one exactly
    # @param event a command line
    # @return True if host, user, command, arguments and result are the same
    def repeats(self, event):
        first = self.events[0]
        fields = ("host", "user", "root", "command", "args", "exit", "timed_out",
                  "framework", "diagnostic", "background", "interactive")
        return all(first.get(f) == event.get(f) for f in fields)


## @brief One poll context in a trace, with everything recorded inside it
class ContextItem:
    ## @brief Create the item of a root context
    # @param poll_id the id of the root context
    # @param polls the poll lines by id
    def __init__(self, poll_id, polls):
        self.poll_id = poll_id
        self.poll = polls.get(poll_id)
        self.members = []


## @brief One raised error in a trace
class ErrorItem:
    ## @brief Wrap the error line
    # @param event the error line
    def __init__(self, event):
        self.event = event


## @brief The command trace of one unit, split into sections
#
# Sections follow the structure of a check: the check setup, the level
# setup, one section per check function, the level cleanup and the check
# cleanup with the cleanup checks.
class Trace:
    ## @brief Build the trace from the events of the deciding attempt
    # @param events the unit's events, in stream order
    def __init__(self, events):
        self.polls = {e.get("id"): e for e in events if e.get("type") == "poll"}
        self.sections = []
        self.results = {}
        self.build(events)

    ## @brief The outermost poll context enclosing a context
    # @param poll_id a context id
    # @return the id of its root context
    def root(self, poll_id):
        seen = set()
        while poll_id in self.polls and self.polls[poll_id].get("parent") is not None \
                and poll_id not in seen:
            seen.add(poll_id)
            poll_id = self.polls[poll_id]["parent"]
        return poll_id

    ## @brief Assign every event to its section and collapse it into items
    # @param events the unit's events
    def build(self, events):
        items = []
        contexts = {}
        section = "Check setup"
        previous = None

        ## @brief Give the items held back after a function their section
        #
        # What runs after a function ends is held as "between" until it is
        # known whether another function follows (then it belongs to the one
        # before) or the level cleanup.
        # @param items the (section, item) pairs so far
        # @param key the section the held items belong to
        # @return the pairs with the held items settled
        def settle(items, key):
            return [(key if k == "between" else k, item) for k, item in items]

        for event in events:
            kind = event.get("type")
            if kind == "unit_start":
                section = "Level setup"
            elif kind == "function_start":
                if previous is not None:
                    items = settle(items, ("function", previous))
                previous = event.get("function", "")
                section = ("function", previous)
            elif kind == "function_end":
                self.results[("function", event.get("function", ""))] = event.get("verdict")
                section = "between"
            elif kind == "phase":
                phase = event.get("phase")
                if phase == "cleanup_level":
                    items = settle(items, "Level cleanup")
                    section = "Level cleanup"
                name = {"setup": "Check setup", "setup_level": "Level setup",
                        "cleanup_level": "Level cleanup", "cleanup": "Check cleanup"}.get(phase)
                if name:
                    self.results[name] = event.get("result")
            elif kind == "unit_end":
                items = settle(items, "Level cleanup")
                section = "Check cleanup"
            elif kind == "cleanup_check":
                self.results["Cleanup checks"] = event.get("result")

            if kind in ("command", "error", "poll"):
                # the cleanup checks run after the check cleanup, as a section of their own
                key = "Cleanup checks" if event.get("function") == "cleanup_check" else section
                poll_id = event.get("id") if kind == "poll" else event.get("poll")
                if poll_id is not None:
                    root = self.root(poll_id)
                    if root not in contexts:
                        contexts[root] = ContextItem(root, self.polls)
                        items.append((key, contexts[root]))
                    if kind != "poll" or poll_id != root:
                        contexts[root].members.append(event)
                elif kind == "command":
                    last = items[-1] if items else None
                    if last and last[0] == key and isinstance(last[1], CommandItem) \
                            and last[1].repeats(event):
                        last[1].events.append(event)
                    else:
                        items.append((key, CommandItem(event)))
                elif kind == "error":
                    items.append((key, ErrorItem(event)))
        items = settle(items, "Level cleanup")
        for key, item in items:
            if not self.sections or self.sections[-1][0] != key:
                self.sections.append((key, []))
            self.sections[-1][1].append(item)

    ## @brief The title of a section
    # @param key the section key
    # @return the heading text
    @staticmethod
    def title(key):
        return "Function `%s`" % key[1] if isinstance(key, tuple) else key

    ## @brief The items of one check function
    # @param function the function name
    # @return the items, empty if the function recorded nothing
    def function_items(self, function):
        items = []
        for key, section_items in self.sections:
            if key == ("function", function):
                items.extend(section_items)
        return items


## @brief Renders the trace items for one audience
class TraceText:
    ## @brief Remember the audience
    # @param internal True for the internal report
    def __init__(self, internal):
        self.internal = internal

    ## @brief Tell whether a command is shown
    # @param event a command line
    # @return False for framework and diagnostic commands in the external report
    def visible(self, event):
        return self.internal or not (event.get("framework") or event.get("diagnostic"))

    ## @brief The prompt line of a command
    # @param event a command line
    # @param full True to keep the full path of the command
    # @return e.g. ebablick@host-0012$ qconf -sstree
    def prompt(self, event, full):
        command = event.get("command", "")
        if not full:
            command = os.path.basename(command)
        args = (event.get("args") or "").strip()
        text = "%s@%s%s %s%s" % (event.get("user", "?"), event.get("host", "?"),
                                 "#" if event.get("root") else "$", command,
                                 " " + args if args else "")
        if event.get("background"):
            text += " &"
        if self.internal:
            tags = [t for t in ("framework", "diagnostic") if event.get(t)]
            if tags:
                text = "[%s] %s" % (", ".join(tags), text)
        return text

    ## @brief The result lines of a command: exit status and output excerpt
    # @param event a command line
    # @param indent the indentation of the lines
    # @return the lines, empty for a plain success in the external report
    def result(self, event, indent):
        lines = []
        status = event.get("exit")
        if event.get("interactive"):
            lines.append(indent + "(interactive session)")
        elif event.get("timed_out"):
            lines.append(indent + "timed out")
        elif status not in (0, None):
            lines.append(indent + "exit status %s" % status)
        output = event.get("output") or {}
        excerpt = output.get("excerpt") or ""
        failed = event.get("timed_out") or status not in (0, None)
        if excerpt and (self.internal or failed):
            for line in excerpt.rstrip("\n").split("\n"):
                lines.append(indent + "| " + line)
            if output.get("truncated"):
                lines.append(indent + "| ... (%s bytes in all, middle left out)" % output.get("bytes"))
        return lines

    ## @brief The lines of an error
    # @param event an error line
    # @param indent the indentation of continuation lines
    # @return the lines
    def error(self, event, indent):
        message = (event.get("message") or "").rstrip("\n").split("\n")
        lines = ["%s !! %s (%s): %s" % (clock(event.get("t")), event.get("level", "?"),
                                        event.get("origin", "?"), message[0])]
        lines.extend(indent + "   " + line for line in message[1:])
        return lines

    ## @brief The lines of a poll context
    # @param item the context item
    # @return the lines, empty if the context is hidden
    def context(self, item):
        poll = item.poll or {}
        commands = [e for e in item.members if e.get("type") == "command" and self.visible(e)]
        if not self.internal and poll.get("framework"):
            return []
        if not self.internal and not commands and poll.get("framework") is None \
                and any(e.get("framework") for e in item.members):
            return []
        indent = " " * 9
        if poll:
            took = seconds(poll.get("start"), poll.get("end"))
            head = "%s %s: %s: %s after %s" % (
                clock(poll.get("start")), poll.get("helper", "wait"), poll.get("condition", ""),
                OUTCOME_TEXT.get(poll.get("outcome"), poll.get("outcome")), duration_text(took))
            if poll.get("timeout") is not None:
                head += " (timeout %s s)" % poll["timeout"]
            if self.internal and poll.get("framework"):
                head = head[:8] + " [framework]" + head[8:]
        else:
            first = item.members[0] if item.members else {}
            head = "%s poll context %s: did not finish" % (clock(first.get("t")), item.poll_id)
        lines = [head]
        if self.internal:
            for event in item.members:
                kind = event.get("type")
                if kind == "command":
                    lines.append("%s   %s" % (clock(event.get("start") or event.get("t")),
                                              self.prompt(event, True)))
                    lines.extend(self.result(event, indent + "     "))
                elif kind == "poll":
                    lines.append("%s   %s: %s: %s" % (clock(event.get("end")), event.get("helper"),
                                                      event.get("condition"),
                                                      OUTCOME_TEXT.get(event.get("outcome"),
                                                                       event.get("outcome"))))
                elif kind == "error":
                    lines.extend(self.error(event, indent))
            return lines
        seen = []
        counts = {}
        for event in commands:
            text = self.prompt(event, False)
            if text not in counts:
                seen.append(text)
                counts[text] = 0
            counts[text] += 1
        for text in seen:
            lines.append(indent + "  " + text + ("  (%dx)" % counts[text] if counts[text] > 1 else ""))
        if poll.get("outcome") != "met" and commands:
            lines.extend(self.result(commands[-1], indent + "    "))
        for event in item.members:
            if event.get("type") == "error":
                lines.extend(self.error(event, indent))
        return lines

    ## @brief The lines of a list of trace items
    # @param items the items
    # @return the lines, without the fence
    def lines(self, items):
        lines = []
        indent = " " * 9
        for item in items:
            if isinstance(item, CommandItem):
                first = item.events[0]
                if not self.visible(first):
                    continue
                text = "%s %s" % (clock(first.get("start") or first.get("t")),
                                  self.prompt(first, self.internal))
                if len(item.events) > 1:
                    took = seconds(first.get("start"), item.events[-1].get("end"))
                    text += "  (repeated %dx over %s)" % (len(item.events), duration_text(took))
                lines.append(text)
                lines.extend(self.result(item.events[-1], indent + "  "))
            elif isinstance(item, ContextItem):
                lines.extend(self.context(item))
            elif isinstance(item, ErrorItem):
                lines.extend(self.error(item.event, indent))
        return lines


## @brief Tell whether a unit failed as a whole, not only through its functions
#
# A unit fails as a whole when a cleanup check found something, when it was
# interrupted, or when an error or a failed phase lies outside the check
# functions (check or level setup and cleanup). Then no function of it can be
# taken as passed.
# @param unit the merged unit
# @return True for a failure of the whole unit
def unit_wide_failure(unit):
    verdict = unit.get("verdict")
    if verdict in ("cleanup_failed", "interrupted"):
        return True
    if verdict != "failed":
        return False
    names = {f.get("function") for f in unit.get("functions", [])}
    for event in unit.get("events") or []:
        if event.get("type") == "error" and event.get("function") not in names:
            return True
        if event.get("type") == "phase" and event.get("result") == "error":
            return True
    # failed, but no function says why: count it against the whole unit
    return not any(f.get("verdict") in ("failed", "tcl_error", "interrupted")
                   for f in unit.get("functions", []))


## @brief The verdict a case gets from one function of one unit
# @param unit the merged unit
# @param function the function entry of the unit
# @return a key of CASE_RANK
def execution_verdict(unit, function):
    unit_verdict = unit.get("verdict")
    verdict = function.get("verdict")
    if unit_verdict in ("skipped", "unsupported"):
        return unit_verdict
    if verdict in ("failed", "tcl_error", "interrupted"):
        return "failed"
    if verdict == "not_run" or (unit_verdict == "not_run" and verdict is None):
        return "not_run"
    if unit_wide_failure(unit):
        return "failed"
    if verdict == "unsupported":
        return "unsupported"
    return "passed" if verdict == "passed" else "not_run"


## @brief One execution of a test case: a function of a unit that names the case
class Execution:
    ## @brief Record the execution
    # @param unit the merged unit
    # @param function the function entry
    # @param relation covers or prepares
    def __init__(self, unit, function, relation):
        self.unit = unit
        self.function = function
        self.relation = relation
        self.verdict = execution_verdict(unit, function)


## @brief Builds the report pages of one run
class Report:
    ## @brief Index the merged result and the catalog
    # @param merged the merged result
    # @param catalog the catalog, or None
    # @param internal True for the internal report
    def __init__(self, merged, catalog, internal):
        self.merged = merged
        self.catalog = catalog
        self.internal = internal
        self.text = TraceText(internal)
        self.warnings = []
        self.traces = {}
        self.executions = {}
        for unit in merged.get("units", []):
            for function in unit.get("functions", []):
                for case in function.get("test_cases") or []:
                    self.executions.setdefault(case.get("id"), []).append(
                        Execution(unit, function, case.get("relation", "covers")))
        self.cases = {}
        self.criteria = {}
        if catalog:
            self.cases = {c["id"]: c for c in catalog.get("test_cases", [])}
            self.criteria = {c["id"]: c for c in catalog.get("criteria", [])}
            for case_id, executions in sorted(self.executions.items()):
                where = ", ".join(sorted({"%s %s" % (check_name(e.unit["check"]),
                                                     e.function.get("function"))
                                          for e in executions}))
                if case_id not in self.cases:
                    self.warnings.append("test case %s named by %s is not in the catalog" %
                                         (case_id, where))
                elif self.cases[case_id].get("owner") in ("site", "later"):
                    self.warnings.append("test case %s is a %s case but covered by %s" %
                                         (case_id, self.cases[case_id]["owner"], where))

    ## @brief The trace of a unit, built once
    # @param unit the merged unit
    # @return the Trace
    def trace(self, unit):
        key = (unit["check"], unit["level"])
        if key not in self.traces:
            self.traces[key] = Trace(unit.get("events") or [])
        return self.traces[key]

    ## @brief The verdict of a test case
    # @param case_id the test ID
    # @return a key of CASE_TEXT
    def case_verdict(self, case_id):
        owner = self.cases.get(case_id, {}).get("owner")
        executions = self.executions.get(case_id, [])
        covering = [e for e in executions if e.relation == "covers"]
        if covering:
            return max((e.verdict for e in covering), key=lambda v: CASE_RANK[v])
        if owner in ("site", "later"):
            return owner
        return "prepared_only" if executions else "not_covered"

    ## @brief The overall result of the run, for criteria mapped to the run
    # @return passed or failed
    def run_verdict(self):
        units = self.merged.get("units", [])
        if units and not any(u.get("verdict") in FAILING for u in units):
            return "passed"
        return "failed"

    ## @brief The verdict of an acceptance criterion
    # @param criterion the catalog criterion
    # @return a key of CRITERION_TEXT
    def criterion_verdict(self, criterion):
        mapping = criterion.get("mapping")
        if mapping == "manual":
            return "manual"
        if mapping == "run":
            return self.run_verdict()
        verdicts = [self.case_verdict(i) for i in criterion.get("test_ids") or []]
        if not verdicts:
            return "open"
        if any(v in ("failed", "not_run") for v in verdicts):
            return "failed"
        if all(v == "passed" for v in verdicts):
            return "passed"
        return "open"

    ## @brief The reason a criterion is open
    # @param criterion the catalog criterion
    # @return the explanation, or ""
    def open_reason(self, criterion):
        if criterion.get("mapping") != "test_ids":
            return ""
        ids = criterion.get("test_ids") or []
        if not ids:
            return "no test IDs mapped yet (%s)" % criterion.get("mapped_by", "description")
        missing = [i for i in ids if self.case_verdict(i) not in ("passed", "failed", "not_run")]
        return "not decided by this run: %s" % ", ".join(missing) if missing else ""

    ## @brief Link to a case page from a page in a subdirectory
    # @param case_id the test ID
    # @return a Markdown link, or the bare ID without a catalog entry
    def case_link(self, case_id):
        if case_id in self.cases:
            return "[%s](../cases/%s.md)" % (case_id, case_id)
        return case_id

    ## @brief The header lines every page starts with
    # @param title the page title
    # @return the lines
    def page_head(self, title):
        lines = ["# %s" % title, ""]
        if self.internal:
            lines += ["> **Internal report.** Contains every attempt and the framework commands; "
                      "not for distribution.", ""]
        return lines

    ## @brief Statement about the verdicts, for the index
    # @return the lines
    def verdict_statement(self):
        if self.internal:
            return ["Each unit shows the verdict of its deciding attempt, the attempt with the "
                    "highest order, and lists every attempt of the run.", ""]
        return ["Each verdict is the result of the final execution of the test in run `%s`." %
                self.merged.get("run_id"), ""]

    ## @brief The provenance section of the index
    # @return the lines
    def provenance(self):
        invocations = self.merged.get("invocations", [])
        lines = ["## Provenance", ""]
        if not invocations:
            return lines + ["No invocation recorded.", ""]
        prov = invocations[-1].get("provenance") or {}
        build = prov.get("build") or {}
        cluster = prov.get("cluster") or {}
        rows = [["Product", cell("%s %s" % (prov.get("product", ""), prov.get("product_version", "")))],
                ["Build", cell("%s %s" % (build.get("arch", ""), build.get("type", "")))],
                ["Product root", cell(prov.get("product_root"))],
                ["Testsuite host", cell(prov.get("ts_host"))],
                ["Qmaster host", cell(cluster.get("qmaster_host"))],
                ["Execution hosts", cell(", ".join(cluster.get("execd_hosts") or []))]]
        rows = [row for row in rows if row[1].strip()]
        for source in prov.get("sources") or []:
            rows.append(["Source `%s`" % cell(source.get("repo")),
                         "`%s`%s" % (cell(source.get("commit")),
                                     " (uncommitted changes)" if source.get("dirty") else "")])
        if self.catalog:
            src = self.catalog.get("source") or {}
            rows.append(["Specification", cell("%s, version %s" % (src.get("title", ""),
                                                                  src.get("version", "")))])
        lines += table(["", ""], rows) + [""]
        distinct = {json.dumps(i.get("provenance"), sort_keys=True) for i in invocations}
        if len(distinct) > 1:
            lines += ["The invocations of this run differ in their provenance; the table shows "
                      "the last one.", ""]
        if self.internal:
            rows = [[cell(i.get("invocation_id")), cell(i.get("attempt")), cell(i.get("attempt_label")),
                     cell(i.get("start")), cell((i.get("provenance") or {}).get("ts_host"))]
                    for i in invocations]
            lines += ["### Invocations", ""] + table(
                ["Invocation", "Attempt", "Label", "Start", "Host"], rows) + [""]
        return lines

    ## @brief The index page
    # @return the page text
    def index(self):
        units = self.merged.get("units", [])
        lines = self.page_head("Test report %s" % self.merged.get("run_id"))
        if self.internal:
            attention = [u for u in units if u.get("attention")]
            lines += ["## Attention: passed only on retry after an assertion-like failure", ""]
            if attention:
                lines += ["Analyse each before a handover: explain it as a test problem or file "
                          "it as a product defect.", ""]
                for unit in attention:
                    first = next((a for a in unit.get("attempts", [])
                                  if a.get("class") == "assertion"), {})
                    message = next((e.get("message") for e in first.get("errors", [])), "")
                    lines.append("- [%s level %s](units/%s): attempt %s (%s): %s" % (
                        check_name(unit["check"]), unit["level"], unit_file(unit),
                        first.get("attempt"), first.get("attempt_label"), cell(summary(message))))
                lines.append("")
            else:
                lines += ["None.", ""]
        lines += self.verdict_statement()
        counts = {}
        for unit in units:
            counts[unit.get("verdict")] = counts.get(unit.get("verdict"), 0) + 1
        counted = ", ".join("%d %s" % (counts[v], v) for v in sorted(counts)) or "no units"
        lines += ["**Result:** %s (%s)" % ("passed" if self.run_verdict() == "passed" else "failed",
                                          counted), ""]
        if self.catalog:
            lines += ["## Milestones", ""]
            rows = []
            for milestone in self.catalog.get("milestones", []):
                criteria = [c for c in self.catalog.get("criteria", [])
                            if c.get("milestone") == milestone["id"]]
                verdicts = [self.criterion_verdict(c) for c in criteria]
                rows.append(["[%s](milestones/%s.md)" % (milestone["id"], milestone["id"]),
                             cell(milestone.get("title")), cell(milestone.get("date")),
                             ", ".join("%d %s" % (verdicts.count(v), CRITERION_TEXT[v])
                                       for v in CRITERION_TEXT if v in verdicts)])
            lines += table(["Milestone", "Title", "Date", "Acceptance criteria"], rows) + [""]
        lines += ["## Units", ""]
        rows = []
        for unit in units:
            ids = sorted({c.get("id") for f in unit.get("functions", [])
                          for c in f.get("test_cases") or []})
            links = ", ".join(self.case_link(i).replace("../", "") for i in ids)
            rows.append(["[%s](units/%s)" % (cell(check_name(unit["check"])), unit_file(unit)),
                         cell(unit["level"]), cell(unit.get("verdict")), links])
        lines += table(["Check", "Level", "Verdict", "Test cases"], rows) + [""]
        if not self.catalog and self.executions:
            lines += ["## Test cases", ""]
            rows = []
            for case_id in sorted(self.executions):
                where = ", ".join("[%s](units/%s) `%s`" % (cell(check_name(e.unit["check"])),
                                                         unit_file(e.unit), e.function.get("function"))
                                  for e in self.executions[case_id])
                rows.append([cell(case_id), CASE_TEXT[self.case_verdict(case_id)], where])
            lines += table(["Test case", "Verdict", "Executed by"], rows) + [""]
        if self.catalog:
            outside = [c for c in self.catalog.get("test_cases", [])
                       if c.get("owner") in ("site", "later")]
            if outside:
                lines += ["## Test cases outside the testsuite", ""]
                rows = [[self.case_link(c["id"]).replace("../", ""), cell(c.get("title")),
                         CASE_TEXT[c["owner"]]] for c in outside]
                lines += table(["Test case", "Title", "Reason"], rows) + [""]
        lines += self.provenance()
        if self.internal:
            warnings = list(self.merged.get("warnings", [])) + self.warnings
            lines += ["## Warnings", ""] + (["- %s" % cell(w) for w in warnings] or ["None."]) + [""]
        return "\n".join(lines)

    ## @brief The page of one unit
    # @param unit the merged unit
    # @return the page text
    def unit_page(self, unit):
        name = check_name(unit["check"])
        lines = self.page_head("%s, level %s" % (name, unit["level"]))
        rows = [["Verdict", "**%s**" % unit.get("verdict")]]
        if unit.get("description"):
            rows.append(["Description", cell(unit["description"])])
        if unit.get("categories"):
            rows.append(["Categories", cell(", ".join(unit["categories"]))])
        if self.internal:
            rows.append(["Check path", "`%s`" % cell(unit["check"])])
            deciding = unit.get("deciding") or {}
            if deciding:
                rows.append(["Deciding attempt", cell("%s (%s)" % (deciding.get("attempt"),
                                                                    deciding.get("invocation_id")))])
        lines += table(["", ""], rows) + [""]
        if unit.get("verdict") == "not_run":
            lines += ["The unit was selected but never started.", ""]
        functions = unit.get("functions", [])
        if functions:
            rows = []
            for function in functions:
                ids = ", ".join("%s (%s)" % (self.case_link(c.get("id")), c.get("relation", "covers"))
                                for c in function.get("test_cases") or [])
                rows.append(["`%s`" % cell(function.get("function")), cell(function.get("verdict")),
                             duration_text(function.get("duration")), ids])
            lines += ["## Functions", ""] + table(["Function", "Verdict", "Duration", "Test cases"],
                                                  rows) + [""]
        if self.internal and unit.get("attempts"):
            lines += ["## Attempts", ""]
            rows = []
            for attempt in unit["attempts"]:
                errors = "<br>".join(cell("%s: %s" % (e.get("function"), summary(e.get("message"))))
                                     for e in attempt.get("errors", []))
                rows.append([cell(attempt.get("attempt")), cell(attempt.get("attempt_label")),
                             cell(attempt.get("verdict")), cell(attempt.get("class")), errors])
            lines += table(["Attempt", "Label", "Verdict", "Class", "Errors"], rows) + [""]
        trace = self.trace(unit)
        if unit.get("verdict") in FAILING:
            errors = [e for e in unit.get("events") or [] if e.get("type") == "error"
                      and e.get("level") != "CONFIG"]
            if errors:
                lines += ["## Errors", ""]
                lines += ["- `%s`: %s" % (cell(e.get("function")), cell(summary(e.get("message"))))
                          for e in errors] + [""]
        if trace.sections:
            lines += ["## Trace", ""]
            shown = set()
            for key, items in trace.sections:
                text = self.text.lines(items)
                if not text:
                    continue
                shown.add(key)
                result = trace.results.get(key)
                lines += ["### %s%s" % (Trace.title(key), " (%s)" % result if result else ""), ""]
                lines += fence(text) + [""]
            if "Cleanup checks" in trace.results and "Cleanup checks" not in shown:
                lines += ["Cleanup checks: %s" % trace.results["Cleanup checks"], ""]
        return "\n".join(lines)

    ## @brief The page of one test case
    # @param case the catalog case
    # @return the page text
    def case_page(self, case):
        verdict = self.case_verdict(case["id"])
        lines = self.page_head("%s — %s" % (case["id"], case.get("title", "")))
        criteria = ", ".join("[%s](../milestones/%s.md#%s)" % (c, c.split("-")[0], c.lower())
                             for c in case.get("criteria") or []) or "none"
        rows = [["Verdict", "**%s**" % CASE_TEXT[verdict]],
                ["Section", cell("%s (%s)" % (case.get("section", ""), case.get("plan_section", "")))
                 if case.get("plan_section") else cell(case.get("section"))],
                ["Phase", cell(case.get("phase"))],
                ["Milestone", cell(case.get("milestone_text") or case.get("milestone"))],
                ["See", cell(case.get("see"))],
                ["Acceptance criteria", criteria]]
        lines += table(["", ""], rows) + [""]
        source = self.catalog.get("source") or {}
        lines += ["## Specification", "",
                  "From %s, version %s." % (source.get("title", "the specification"),
                                            source.get("version", "?")), "",
                  "**Verifies:** %s" % case.get("verifies", ""), ""]
        lines += ["%d. %s" % (n, step) for n, step in enumerate(case.get("steps") or [], 1)] + [""]
        lines += ["**Pass:** %s" % case.get("pass", ""), ""]
        for note in case.get("notes") or []:
            lines += ["**Note:** %s" % note, ""]
        executions = self.executions.get(case["id"], [])
        lines += ["## Executed by", ""]
        if not executions:
            lines += ["No test of this run names this case.", ""]
            return "\n".join(lines)
        rows = [["[%s](../units/%s)" % (cell(check_name(e.unit["check"])), unit_file(e.unit)),
                 cell(e.unit["level"]), "`%s`" % cell(e.function.get("function")), e.relation,
                 CASE_TEXT[e.verdict]] for e in executions]
        lines += table(["Check", "Level", "Function", "Relation", "Verdict"], rows) + [""]
        if any(e.relation == "prepares" for e in executions):
            lines += ["A function that *prepares* the case verifies a precondition only and does "
                      "not decide the verdict.", ""]
        for execution in executions:
            text = self.text.lines(self.trace(execution.unit).function_items(
                execution.function.get("function")))
            lines += ["### `%s` in %s, level %s" % (execution.function.get("function"),
                                                   check_name(execution.unit["check"]),
                                                   execution.unit["level"]), ""]
            lines += (fence(text) if text else ["No commands recorded."]) + [""]
            if execution.unit.get("verdict") in FAILING and execution.function.get("verdict") == "passed":
                lines += ["The function passed, but the unit is %s; see its page for the setup "
                          "and cleanup." % execution.unit["verdict"], ""]
        return "\n".join(lines)

    ## @brief The rows of a case table
    # @param ids the test IDs
    # @return the rows
    def case_rows(self, ids):
        rows = []
        for case_id in ids:
            case = self.cases.get(case_id, {})
            checks = ", ".join(sorted({"`%s`" % e.function.get("function")
                                       for e in self.executions.get(case_id, [])}))
            rows.append([self.case_link(case_id), cell(case.get("title")),
                         CASE_TEXT[self.case_verdict(case_id)], checks])
        return rows

    ## @brief The page of one milestone
    # @param milestone the catalog milestone
    # @return the page text
    def milestone_page(self, milestone):
        mid = milestone["id"]
        lines = self.page_head("Milestone %s — %s" % (mid, milestone.get("title", "")))
        lines += ["Run `%s`, due %s." % (self.merged.get("run_id"), milestone.get("date", "?")), ""]
        criteria = [c for c in self.catalog.get("criteria", []) if c.get("milestone") == mid]
        rows = []
        for criterion in criteria:
            if criterion.get("mapping") == "test_ids":
                mapped = ", ".join(self.case_link(i) for i in criterion.get("test_ids") or []) \
                    or cell(criterion.get("mapped_by", ""))
            else:
                mapped = {"run": "the whole run", "manual": "manual"}.get(criterion.get("mapping"), "")
            rows.append(["[%s](#%s)" % (criterion["id"], criterion["id"].lower()),
                         cell(criterion.get("criterion")), mapped,
                         "**%s**" % CRITERION_TEXT[self.criterion_verdict(criterion)]])
        lines += ["## Acceptance criteria", ""]
        lines += table(["AC", "Criterion", "Test cases", "Verdict"], rows) + [""]
        lines += ["An acceptance criterion passes when every mapped test case passed; a failed "
                  "or not run case fails it. It is open when a mapped case was not decided by "
                  "this run.", ""]
        for criterion in criteria:
            verdict = self.criterion_verdict(criterion)
            lines += ["## %s" % criterion["id"], "", "**%s**" % criterion.get("criterion", ""), ""]
            if criterion.get("focus"):
                lines += ["Focus: %s" % criterion["focus"], ""]
            lines += ["Verdict: **%s**" % CRITERION_TEXT[verdict], ""]
            reason = self.open_reason(criterion) if verdict == "open" else ""
            if reason:
                lines += ["Open: %s." % reason, ""]
            if criterion.get("mapping") == "run":
                lines += ["Decided by the overall result of the run: %s." % self.run_verdict(), ""]
            elif criterion.get("mapping") == "manual":
                lines += ["Verified by the customer; the testsuite gives no verdict.", ""]
            elif criterion.get("test_ids"):
                lines += table(["Test case", "Title", "Verdict", "Functions"],
                               self.case_rows(criterion["test_ids"])) + [""]
        unmapped = [i for i in self.catalog.get("unmapped", [])
                    if self.cases.get(i, {}).get("milestone") == mid]
        if unmapped:
            lines += ["## Verified, not acceptance-relevant", "",
                      "Test cases of this milestone that no acceptance criterion maps.", ""]
            lines += table(["Test case", "Title", "Verdict", "Functions"],
                           self.case_rows(unmapped)) + [""]
        return "\n".join(lines)

    ## @brief All pages of the report
    # @return a dict of relative path -> page text
    def pages(self):
        pages = {"index.md": self.index()}
        for unit in self.merged.get("units", []):
            pages["units/" + unit_file(unit)] = self.unit_page(unit)
        if self.catalog:
            for case in self.catalog.get("test_cases", []):
                pages["cases/%s.md" % case["id"]] = self.case_page(case)
            for milestone in self.catalog.get("milestones", []):
                pages["milestones/%s.md" % milestone["id"]] = self.milestone_page(milestone)
        return pages


## @brief Write the pages into an empty output directory, optionally as a zip too
# @param pages relative path -> page text
# @param out_dir the output directory; must not exist or be empty
# @param make_zip True to write <out_dir>.zip as well
# @return the path of the zip, or None
def write_pages(pages, out_dir, make_zip):
    if os.path.exists(out_dir) and (not os.path.isdir(out_dir) or os.listdir(out_dir)):
        raise InputError("%s: output directory exists and is not empty" % out_dir)
    for path, text in pages.items():
        target = os.path.join(out_dir, path)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with open(target, "w", encoding="utf-8") as fd:
            fd.write(text.rstrip("\n") + "\n")
    if not make_zip:
        return None
    archive = os.path.normpath(out_dir) + ".zip"
    top = os.path.basename(os.path.normpath(out_dir))
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(pages):
            zf.write(os.path.join(out_dir, path), os.path.join(top, path))
    return archive


## @brief Render a merged result
# @param merged_path the merged result
# @param catalog_path the catalog, or None
# @param audience internal or external
# @return the Report
def render(merged_path, catalog_path, audience):
    if audience not in AUDIENCES:
        raise InputError("audience must be one of %s" % ", ".join(AUDIENCES))
    merged = load(merged_path, "merged")
    catalog = load(catalog_path, "catalog") if catalog_path else None
    return Report(merged, catalog, audience == "internal")


## @brief Command-line entry point
# @param argv the arguments, sys.argv[1:] if None
# @return the exit status
def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Render a merged testsuite report result as Markdown (CS-2936).")
    parser.add_argument("merged", help="the merged result written by ts_report_merge.py")
    parser.add_argument("--catalog", help="the test-case catalog, e.g. written by spec_catalog.py")
    parser.add_argument("--audience", required=True, choices=AUDIENCES,
                        help="internal: every attempt and framework command; "
                             "external: final verdicts for the partner")
    parser.add_argument("-o", "--output", required=True,
                        help="the output directory; must not exist or be empty")
    parser.add_argument("--zip", action="store_true", help="also write <output>.zip")
    args = parser.parse_args(argv)
    try:
        report = render(args.merged, args.catalog, args.audience)
        pages = report.pages()
        archive = write_pages(pages, args.output, args.zip)
    except (InputError, OSError) as error:
        print("ts_report_render: %s" % error, file=sys.stderr)
        return 2
    for warning in report.warnings:
        print("warning: %s" % warning, file=sys.stderr)
    print("run %s: %d page(s) for the %s audience written to %s%s" %
          (report.merged.get("run_id"), len(pages), args.audience, args.output,
           ", zip %s" % archive if archive else ""), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
