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
import re
import sys
import zipfile

AUDIENCES = ("internal", "external")

# the format versions read; merged/2 added the verdict not_implemented
FORMAT_VERSIONS = {"merged": (1, 2), "catalog": (1,)}

# unit verdicts that count as "did not pass", as in ts_report_merge.py
FAILING = ("failed", "cleanup_failed", "interrupted", "not_run")

# the order the index lists the unit verdicts in, the critical ones first
VERDICT_ORDER = ("failed", "cleanup_failed", "interrupted", "not_run",
                 "not_implemented", "skipped", "unsupported", "passed")

# the heading of a verdict group in the index
VERDICT_HEADING = {
    "failed": "Failed",
    "cleanup_failed": "Cleanup failed",
    "interrupted": "Interrupted",
    "not_run": "Not run",
    "not_implemented": "Not implemented",
    "skipped": "Skipped",
    "unsupported": "Unsupported",
    "passed": "Passed",
}

# a verdict group with more units than this is split by area
GROUP_SPLIT = 10

# test-case verdicts from the executions that cover a case, worst last
CASE_RANK = {"passed": 0, "skipped": 1, "unsupported": 2, "not_implemented": 3,
             "not_run": 4, "failed": 5}

# what a case verdict says in the report
CASE_TEXT = {
    "passed": "passed",
    "failed": "failed",
    "not_run": "not run",
    "skipped": "skipped",
    "unsupported": "unsupported environment",
    "not_implemented": "not implemented yet",
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

# the options a module test gets to write its records (format.md, section 1.5)
REPORT_OPTIONS = re.compile(r"(^|\s)--report(-run|-attempt|-label)?=\S+")


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
    expected = ["ts-report/%s/%d" % (kind, v) for v in FORMAT_VERSIONS[kind]]
    if not isinstance(data, dict) or data.get("format") not in expected:
        raise InputError("%s: format is %r, expected %s" %
                         (path, data.get("format") if isinstance(data, dict) else None,
                          " or ".join(expected)))
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


## @brief A function or scenario name for a page, or what stands for none
# @param name the name, "" or None for an event outside the functions
# @return the Markdown text
def function_label(name):
    return "`%s`" % cell(name) if name else "outside the functions"


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
    #
    # Background commands and interactive sessions never collapse: each is a
    # process of its own, overlapping with others.
    # @param event a command line
    # @return True if host, user, command, arguments and result are the same
    def repeats(self, event):
        first = self.events[0]
        if first.get("background") or first.get("interactive"):
            return False
        fields = ("host", "user", "root", "command", "args", "exit", "timed_out",
                  "framework", "diagnostic", "background", "interactive")
        return all(first.get(f) == event.get(f) for f in fields)


## @brief One poll or step context in a trace, with everything recorded inside it
class ContextItem:
    ## @brief Create the item of a root context
    # @param context_id the id of the root context
    # @param contexts the poll and step lines by id
    def __init__(self, context_id, contexts):
        self.context_id = context_id
        self.line = contexts.get(context_id)
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
        self.contexts = {e.get("id"): e for e in events if e.get("type") in ("poll", "step")}
        self.sections = []
        self.results = {}
        self.build(events)

    ## @brief The outermost context enclosing a context
    #
    # Poll and step contexts share one id space and one chain of parents.
    # @param context_id a context id
    # @return the id of its root context
    def root(self, context_id):
        seen = set()
        while context_id in self.contexts and self.contexts[context_id].get("parent") is not None \
                and context_id not in seen:
            seen.add(context_id)
            context_id = self.contexts[context_id]["parent"]
        return context_id

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

            if kind in ("command", "error", "poll", "step"):
                # the cleanup checks run after the check cleanup, as a section of their own
                key = "Cleanup checks" if event.get("function") == "cleanup_check" else section
                if kind in ("poll", "step"):
                    context_id = event.get("id")
                else:
                    context_id = event.get("poll") if event.get("poll") is not None \
                        else event.get("step")
                if context_id is not None:
                    root = self.root(context_id)
                    if root not in contexts:
                        contexts[root] = ContextItem(root, self.contexts)
                        items.append((key, contexts[root]))
                    if kind not in ("poll", "step") or context_id != root:
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
        # a command is recorded when it ends; show the items in the order they started
        for _, section_items in self.sections:
            section_items[:] = sorted(section_items, key=self.start_key(section_items))

    ## @brief A sort key that orders trace items by their start time
    #
    # An item without a usable time stamp keeps the time of the item before it,
    # so it stays where the stream put it.
    # @param items the items of one section, in stream order
    # @return a function mapping an item to its key
    @staticmethod
    def start_key(items):
        keys = {}
        last = None
        for index, item in enumerate(items):
            if isinstance(item, CommandItem):
                stamp = item.events[0].get("start") or item.events[0].get("t")
            elif isinstance(item, ContextItem):
                first = item.members[0] if item.members else {}
                stamp = (item.line or {}).get("start") or first.get("start") or first.get("t")
            else:
                stamp = item.event.get("t")
            moment = parse_time(stamp)
            if moment is not None:
                last = moment
            keys[id(item)] = (last.timestamp() if last else 0.0, index)
        return lambda item: keys[id(item)]

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
        if not full:
            # the options that make a module test record are plumbing of the report itself
            args = REPORT_OPTIONS.sub("", args).strip()
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

    ## @brief The head line of a context
    # @param line the poll or step line
    # @return e.g. "wait_for_jobstart: job 12 running: met after 6 s (timeout 60 s)"
    #         or "shutdown_qmaster: stop qmaster on host-0012: ok after 4 s (12 commands)"
    def context_head(self, line):
        took = duration_text(seconds(line.get("start"), line.get("end")))
        if line.get("type") == "step":
            return "%s: %s: %s after %s (%s command%s)" % (
                line.get("helper", "step"), line.get("description", ""), line.get("outcome"), took,
                line.get("commands", 0), "" if line.get("commands") == 1 else "s")
        head = "%s: %s: %s after %s" % (line.get("helper", "wait"), line.get("condition", ""),
                                        OUTCOME_TEXT.get(line.get("outcome"), line.get("outcome")),
                                        took)
        if line.get("timeout") is not None:
            head += " (timeout %s s)" % line["timeout"]
        return head

    ## @brief The lines of a poll or step context
    #
    # Externally a poll shows its distinct commands with their count, a step
    # only its head line: the commands of a step are the helper's mechanics.
    # Internally every command, nested context and error is listed.
    # @param item the context item
    # @return the lines, empty if the context is hidden
    def context(self, item):
        poll = item.line or {}
        commands = [e for e in item.members if e.get("type") == "command" and self.visible(e)]
        if not self.internal and poll.get("framework"):
            return []
        if not self.internal and not commands and poll.get("framework") is None \
                and any(e.get("framework") for e in item.members):
            return []
        indent = " " * 9
        if poll:
            head = "%s %s%s" % (clock(poll.get("start")),
                                "[framework] " if self.internal and poll.get("framework") else "",
                                self.context_head(poll))
        else:
            first = item.members[0] if item.members else {}
            head = "%s context %s: did not finish" % (clock(first.get("t")), item.context_id)
        lines = [head]
        if self.internal:
            for event in item.members:
                kind = event.get("type")
                if kind == "command":
                    lines.append("%s   %s" % (clock(event.get("start") or event.get("t")),
                                              self.prompt(event, True)))
                    lines.extend(self.result(event, indent + "     "))
                elif kind in ("poll", "step"):
                    lines.append("%s   %s" % (clock(event.get("end")), self.context_head(event)))
                elif kind == "error":
                    lines.extend(self.error(event, indent))
            return lines
        if poll.get("type") == "step":
            # a step shows no commands, unless it failed: then its last one,
            # which is where it went wrong
            if commands and poll.get("outcome") != "ok":
                lines.append(indent + "  " + self.prompt(commands[-1], False))
                lines.extend(self.result(commands[-1], indent + "    "))
        else:
            seen = []
            counts = {}
            for event in commands:
                text = self.prompt(event, False)
                if text not in counts:
                    seen.append(text)
                    counts[text] = 0
                counts[text] += 1
            for text in seen:
                lines.append(indent + "  " + text +
                             ("  (%dx)" % counts[text] if counts[text] > 1 else ""))
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
    if verdict in ("unsupported", "not_implemented"):
        return verdict
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
    #
    # A run without failures that still has stubs is open: what passed is not
    # all the specification asks for.
    # @return passed, failed or open
    def run_verdict(self):
        units = self.merged.get("units", [])
        if not units or any(u.get("verdict") in FAILING for u in units):
            return "failed"
        if any(u.get("verdict") == "not_implemented" for u in units):
            return "open"
        return "passed"

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
        if criterion.get("mapping") == "run":
            return "the run has tests not implemented yet" if self.run_verdict() == "open" else ""
        if criterion.get("mapping") != "test_ids":
            return ""
        ids = criterion.get("test_ids") or []
        if not ids:
            return "no test IDs mapped yet (%s)" % criterion.get("mapped_by", "description")
        stubs = [i for i in ids if self.case_verdict(i) == "not_implemented"]
        missing = [i for i in ids if i not in stubs and
                   self.case_verdict(i) not in ("passed", "failed", "not_run")]
        reasons = []
        if stubs:
            reasons.append("not implemented: %s" % ", ".join(stubs))
        if missing:
            reasons.append("not decided by this run: %s" % ", ".join(missing))
        return "; ".join(reasons)

    ## @brief Link to a case page from a page in a subdirectory
    # @param case_id the test ID
    # @return a Markdown link, or the bare ID without a catalog entry
    def case_link(self, case_id):
        if case_id in self.cases:
            return "[%s](../cases/%s.md)" % (case_id, case_id)
        return case_id

    ## @brief The header lines every page starts with: title, link to the guide
    # @param title the page title
    # @return the lines
    # @param top True for a page in the top directory, False for one in a subdirectory
    def page_head(self, title, top=False):
        lines = ["# %s" % title, "",
                 "[How to read this report](%sguide.md)" % ("" if top else "../"), ""]
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
        # a module test's invocation knows only its host and binary, so the
        # table describes the last testsuite invocation when there is one
        own = [i for i in invocations if i.get("producer") != "module_test"] or invocations
        prov = own[-1].get("provenance") or {}
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
        distinct = {json.dumps(i.get("provenance"), sort_keys=True) for i in own}
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

    ## @brief The verdicts present in a run, in index order
    # @param counts dict verdict -> number of units
    # @return the verdicts, the known ones in VERDICT_ORDER, unknown ones after
    def verdict_order(self, counts):
        known = [v for v in VERDICT_ORDER if v in counts]
        return known + sorted(v for v in counts if v not in VERDICT_ORDER)

    ## @brief The internal list of units that passed only on retry
    # @param units the merged units
    # @return the lines
    def attention(self, units):
        attention = [u for u in units if u.get("attention")]
        lines = ["### Attention: passed only on retry after an assertion-like failure", ""]
        if not attention:
            return lines + ["None.", ""]
        lines += ["Analyse each before a handover: explain it as a test problem or file "
                  "it as a product defect.", ""]
        for unit in attention:
            first = next((a for a in unit.get("attempts", [])
                          if a.get("class") == "assertion"), {})
            message = next((e.get("message") for e in first.get("errors", [])), "")
            lines.append("- [%s level %s](units/%s): attempt %s (%s): %s" % (
                check_name(unit["check"]), unit["level"], unit_file(unit),
                first.get("attempt"), first.get("attempt_label"), cell(summary(message))))
        return lines + [""]

    ## @brief What made a unit fail, for the index
    # @param unit the merged unit
    # @return the first error of the deciding attempt, or what stands for none
    def first_error(self, unit):
        attempts = unit.get("attempts") or []
        if attempts:
            message = next((e.get("message") for e in attempts[-1].get("errors", [])
                            if e.get("message")), "")
            if message:
                return cell(summary(message, 120))
        if unit.get("verdict") == "not_run":
            return "selected, never started"
        if unit.get("verdict") == "interrupted":
            return "started, did not finish"
        return ""

    ## @brief The area of a unit: the first directory of its check path
    # @param unit the merged unit
    # @return the area; the units of module test programs, named after the
    #         program, share one
    def area(self, unit):
        name = check_name(unit["check"])
        return name.split("/")[0] if "/" in name else "module test programs"

    ## @brief The table of some units of one verdict
    #
    # The test-case column is left out when no unit of the table names a test
    # case. Stubs get the reason their functions gave.
    # @param units the units, all of one verdict
    # @param failing True for a verdict in FAILING, which gets the error columns
    # @return the lines
    def unit_table(self, units, failing):
        header = ["Check", "Level"]
        stubs = bool(units) and units[0].get("verdict") == "not_implemented"
        if failing:
            header += ["Attempts", "Error"] if self.internal else ["Error"]
        elif stubs:
            header.append("Missing")
        rows = []
        for unit in units:
            ids = sorted({c.get("id") for f in unit.get("functions", [])
                          for c in f.get("test_cases") or []})
            links = ", ".join(self.case_link(i).replace("../", "") for i in ids)
            row = ["[%s](units/%s)" % (cell(check_name(unit["check"])), unit_file(unit)),
                   cell(unit["level"])]
            if failing:
                if self.internal:
                    row.append(", ".join("%s %s" % (a.get("attempt_label"), a.get("verdict"))
                                         for a in unit.get("attempts") or []) or "none")
                row.append(self.first_error(unit))
            elif stubs:
                reasons = sorted({f.get("reason") for f in unit.get("functions", [])
                                  if f.get("reason")})
                row.append(cell(summary("; ".join(reasons), 120)))
            row.append(links)
            rows.append(row)
        # a run without test IDs gets no column that is empty in every row
        if any(row[-1] for row in rows):
            header.append("Test cases")
        else:
            rows = [row[:-1] for row in rows]
        return table(header, rows) + [""]

    ## @brief The units of the run, grouped by verdict, the critical ones first
    #
    # A group with more than GROUP_SPLIT units is split by area. The internal
    # audience gets the units that passed only on retry after the failing
    # groups, before the groups that passed or did not apply.
    # @param units the merged units
    # @return the lines
    def unit_groups(self, units):
        lines = ["## Units", ""]
        groups = {}
        for unit in units:
            groups.setdefault(unit.get("verdict"), []).append(unit)
        if not groups:
            lines += ["None.", ""]
        order = self.verdict_order(groups)
        for verdict in order:
            if self.internal and verdict not in FAILING:
                if verdict == next(v for v in order if v not in FAILING):
                    lines += self.attention(units)
            group = groups[verdict]
            failing = verdict in FAILING
            lines += ["### %s (%d)" % (VERDICT_HEADING.get(verdict, verdict), len(group)), ""]
            if len(group) <= GROUP_SPLIT:
                lines += self.unit_table(group, failing)
                continue
            areas = {}
            for unit in group:
                areas.setdefault(self.area(unit), []).append(unit)
            for area in sorted(areas):
                lines += ["#### %s (%d)" % (area, len(areas[area])), ""]
                lines += self.unit_table(areas[area], failing)
        if self.internal and all(v in FAILING for v in order):
            lines += self.attention(units)
        return lines

    ## @brief The index page
    # @return the page text
    def index(self):
        units = self.merged.get("units", [])
        lines = self.page_head("Test report %s" % self.merged.get("run_id"), True)
        lines += self.verdict_statement()
        counts = {}
        for unit in units:
            counts[unit.get("verdict")] = counts.get(unit.get("verdict"), 0) + 1
        counted = ", ".join("%d %s" % (counts[v], v) for v in self.verdict_order(counts)) \
            or "no units"
        result = {"passed": "passed", "failed": "failed",
                  "open": "open, tests not implemented yet"}[self.run_verdict()]
        lines += ["**Result:** %s (%s)" % (result, counted), ""]
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
        lines += self.unit_groups(units)
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
                verdict = cell(function.get("verdict"))
                if function.get("reason"):
                    verdict += ": %s" % cell(function.get("reason"))
                rows.append(["`%s`" % cell(function.get("function")), verdict,
                             duration_text(function.get("duration")), ids])
            lines += ["## Functions", ""] + table(["Function", "Verdict", "Duration", "Test cases"],
                                                  rows) + [""]
        checks = [e for e in unit.get("events") or [] if e.get("type") == "assertion"]
        if checks:
            rows = [[function_label(e.get("function")), "T%02d" % e.get("id", 0), cell(e.get("label")),
                     cell(e.get("result"))] for e in checks]
            lines += ["## Checks", ""] + table(["Scenario", "Check", "Asserts", "Result"], rows) + [""]
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
                lines += ["- %s: %s" % (function_label(e.get("function")), cell(summary(e.get("message"))))
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
        additional = case.get("source") == "additional"
        # an additional scenario decides acceptance only through a criterion of
        # our own milestone, the preparation (M0)
        if additional and not case.get("criteria"):
            criteria = "none, an additional test scenario"
        rows = [["Verdict", "**%s**" % CASE_TEXT[verdict]],
                ["Section", cell("%s (%s)" % (case.get("section", ""), case.get("plan_section", "")))
                 if case.get("plan_section") else cell(case.get("section"))],
                ["Phase", cell(case.get("phase"))],
                ["Milestone", cell(case.get("milestone_text") or case.get("milestone"))],
                ["See", cell(case.get("see"))],
                ["Acceptance criteria", criteria]]
        lines += table(["", ""], rows) + [""]
        source = self.catalog.get("source") or {}
        origin = "From %s, version %s." % (source.get("title", "the specification"),
                                           source.get("version", "?"))
        if additional:
            origin = ("From the additional test scenarios of %s, version %s: verified by the "
                      "testsuite, not part of the agreed test plan and no acceptance "
                      "criterion of it." % (source.get("title", "the specification"),
                                            source.get("version", "?")))
            if case.get("criteria"):
                origin += " A criterion of a milestone outside the agreed plan maps it."
        lines += ["## Specification", "", origin, "",
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
                 CASE_TEXT[e.verdict] + (": %s" % cell(e.function.get("reason"))
                                         if e.verdict == "not_implemented" and e.function.get("reason")
                                         else "")] for e in executions]
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
            checks = ", ".join(sorted({"`%s`%s" % (e.function.get("function"),
                                                   "" if e.relation == "covers" else " (prepares)")
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
                  "this run or its test is not implemented yet.", ""]
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
        # our own scenarios are listed apart: they are no part of the agreed plan
        additional = [i for i in unmapped if self.cases[i].get("source") == "additional"]
        unmapped = [i for i in unmapped if i not in additional]
        if unmapped:
            lines += ["## Verified, not acceptance-relevant", "",
                      "Test cases of this milestone that no acceptance criterion maps.", ""]
            lines += table(["Test case", "Title", "Verdict", "Functions"],
                           self.case_rows(unmapped)) + [""]
        if additional:
            lines += ["## Additional test scenarios", "",
                      "Scenarios the testsuite verifies beyond the agreed test plan: the objects "
                      "and mechanisms the acceptance test cases rely on. They are no acceptance "
                      "criteria and do not enter the verdicts above.", ""]
            lines += table(["Test case", "Title", "Verdict", "Functions"],
                           self.case_rows(additional)) + [""]
        return "\n".join(lines)

    ## @brief The guide: how to read the pages, verdicts and traces
    # @return the page text
    def guide(self):
        lines = self.page_head("How to read this report", True)
        # no link from the guide to itself
        lines = lines[:2] + lines[4:]
        lines += ["This report was generated from the records the testsuite writes while it "
                  "runs. It shows what was executed, on which hosts and as which users, and "
                  "what came out.", ""]
        lines += ["## Pages", ""]
        rows = [["[index.md](index.md)", "The run: overall result, milestones, all executed "
                 "tests (units) grouped by verdict with the failing ones first, provenance of "
                 "the software tested."],
                ["`units/`", "One page per unit: one testsuite check at one run level. It lists "
                 "the check functions, their verdicts and the commands they ran."]]
        if self.catalog:
            rows += [["`cases/`", "One page per test case of the specification: the specified "
                      "steps and pass criterion, the verdict, and the commands of the check "
                      "functions that execute it."],
                     ["`milestones/`", "One page per milestone: its acceptance criteria with "
                      "their verdicts, then the test cases grouped by criterion."]]
        lines += table(["Page", "Content"], rows) + [""]
        lines += ["## Units and check functions", "",
                  "A *check* is one testsuite test. It runs at one or more *levels* (variants); "
                  "a check at one level is a *unit*. A unit runs a setup, then its *check "
                  "functions* one after another, then a cleanup, and finally the testsuite "
                  "verifies that the cluster was left as it was found (*cleanup checks*).", ""]
        rows = [["passed", "Every check function passed and the cleanup checks found nothing."],
                ["failed", "A check function, the setup or the cleanup reported an error."],
                ["cleanup_failed", "The functions passed, but the cleanup checks found something "
                 "left behind, e.g. a job still in the cluster."],
                ["not_implemented", "The unit is a placeholder for tests not written yet: "
                 "every check function names the test cases it will execute and what is still "
                 "missing. It shows the progress against the specification."],
                ["skipped", "The setup found that the unit does not apply to this cluster."],
                ["unsupported", "The environment cannot run the unit, e.g. a missing host type."],
                ["interrupted", "The unit started but did not finish."],
                ["not_run", "The unit was selected but never started."]]
        lines += ["Unit verdicts:", ""] + table(["Verdict", "Meaning"], rows) + [""]
        lines += ["Function verdicts are `passed`, `failed`, `unsupported`, `not_implemented` (a "
                  "placeholder, with what is missing), `tcl_error` (an error in the test code "
                  "itself), `not_run` (an earlier function stopped the unit) and `interrupted`.",
                  ""]
        lines += ["## Module tests", "",
                  "A *module test* is a test program of the product's source tree that tests "
                  "one component directly, without a cluster. The testsuite runs it from a "
                  "check (`module_test_generic`), and the program reports itself as a unit of "
                  "its own, named after the program. Its *scenarios* take the place of check "
                  "functions, and each scenario runs numbered *checks* (`T01`, `T02`, ...), "
                  "listed with their result on the unit page. A check that the program runs "
                  "but its scenario does not declare, or a declared check that never runs, is "
                  "reported as an error of origin `drift`: the description of the scenario no "
                  "longer matches the code.", ""]
        if self.catalog:
            lines += ["## Test cases", "",
                      "A check function names the test cases it executes, each with a "
                      "*relation*:", ""]
            rows = [["covers", "The function performs the test case and checks its pass "
                     "criterion. Its result decides the case."],
                    ["prepares", "The function verifies only a precondition of the test case "
                     "(for example that an object can be created that the case then uses). "
                     "It is listed for reference and does not decide the case."]]
            lines += table(["Relation", "Meaning"], rows) + [""]
            rows = [[CASE_TEXT["passed"], "Every function that covers the case passed, and its "
                     "unit did not fail as a whole."],
                    [CASE_TEXT["failed"], "A covering function failed, or its unit failed as a "
                     "whole (setup, cleanup or cleanup checks). A failure of another function in "
                     "the same unit does not fail the case."],
                    [CASE_TEXT["not_run"], "A covering function did not run."],
                    [CASE_TEXT["unsupported"] + ", " + CASE_TEXT["skipped"],
                     "The covering function or its unit could not run in this environment."],
                    [CASE_TEXT["not_implemented"], "The covering function is a placeholder: "
                     "the test of the case is not written yet."],
                    [CASE_TEXT["prepared_only"], "Only functions that prepare the case ran; "
                     "the case itself was not executed."],
                    [CASE_TEXT["not_covered"], "No test of this run executes the case."],
                    [CASE_TEXT["site"], "The case verifies a control the site operates, not "
                     "the product."],
                    [CASE_TEXT["later"], "The case belongs to a later phase than the one "
                     "delivered."]]
            lines += ["Test-case verdicts:", ""] + table(["Verdict", "Meaning"], rows) + [""]
            lines += ["## Acceptance criteria", ""]
            rows = [["passed", "Every test case mapped to the criterion passed."],
                    ["failed", "A mapped test case failed or did not run."],
                    ["open", "Not decided by this run: a mapped test case was not executed or "
                     "is not implemented yet, or the criterion has no test cases mapped yet."],
                    [CRITERION_TEXT["manual"], "The criterion is verified by the customer; the "
                     "testsuite gives no verdict."]]
            lines += table(["Verdict", "Meaning"], rows) + [""]
            lines += ["A criterion mapped to *the whole run* passes when no unit of the run "
                      "failed, did not finish or did not run, and stays open while a unit is "
                      "not implemented yet.", ""]
        lines += ["## Traces", "",
                  "Each unit page shows the commands in the order they started, split into the "
                  "setup, one section per check function, the cleanup and the cleanup checks. "
                  "The heading of a section shows its result.", ""]
        rows = [["`22:09:34 user@host$ qsub ...`", "A command, its start time, the user it ran "
                 "as and the host it ran on. `#` instead of `$` means it ran as root; a trailing "
                 "`&` that it ran in the background."],
                ["`exit status 1`", "The command's exit status, shown when it is not 0. A test "
                 "often expects a non-zero status, e.g. when it verifies that a request is "
                 "refused; the verdict says whether the result was the expected one."],
                ["`\\| text`", "An excerpt of the command's output (at most 4 KiB, beginning and "
                 "end)."],
                ["`(interactive session)`", "A session the test drives itself, e.g. `qrsh`; it "
                 "has no exit status of its own."],
                ["`wait_for_jobstart: job 12 running: met after 6 s (timeout 60 s)`",
                 "The test waited for a condition, repeating the commands listed below the line "
                 "until it held or the timeout passed."],
                ["`shutdown_qmaster: stop qmaster on host-0012: ok after 4 s (9 commands)`",
                 "The test carried out one action through a testsuite helper, e.g. stopping or "
                 "starting a daemon. The commands the helper needs for it (pid files, process "
                 "lists, the stop command) are summarised in this line."],
                ["`(repeated 3x over 2 s)`", "The same command ran several times in a row."],
                ["`!! SEVERE (assertion): ...`", "An error the test raised: its level, where it "
                 "came from (`assertion`, a timeout, a connection problem, a cleanup check) and "
                 "the message."]]
        lines += table(["Line", "Meaning"], rows) + [""]
        if self.internal:
            lines += ["## Internal report", "",
                      "The internal report additionally shows every attempt of a unit with the "
                      "class of its failure (`assertion`, `infrastructure`, `load`), lists the "
                      "units that passed only on retry after an assertion-like failure first, "
                      "and shows the commands the testsuite framework ran around the test "
                      "(`[framework]`) and to explain a failure (`[diagnostic]`), with every "
                      "iteration of a wait and the full command paths.", ""]
        else:
            lines += ["The commands the testsuite framework itself runs around a test (log "
                      "mails, result markers, lookups of message texts) are not shown. Each "
                      "verdict is the result of the final execution of the test in this run.", ""]
        return "\n".join(lines)

    ## @brief All pages of the report
    # @return a dict of relative path -> page text
    def pages(self):
        pages = {"index.md": self.index(), "guide.md": self.guide()}
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
