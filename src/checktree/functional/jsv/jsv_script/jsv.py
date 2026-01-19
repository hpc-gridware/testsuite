#!/usr/bin/env python3
from __future__ import annotations

from typing import Optional

# Adjust path to import JSV module
from os import getenv
import sys
basepath = "%s/util/resources/jsv" % getenv("SGE_ROOT")
sys.path.append(basepath)
from JSV import JSV

jsv = JSV(logging_enabled=True)


def _to_int(s: str) -> Optional[int]:
    try:
        return int(s)
    except Exception:
        return None


def on_start() -> None:
    jsv.send("SEND ENV")


def on_verify() -> None:
    do_correct: bool = False
    do_wait: bool = False

    # Reject binary jobs: if -b y
    if jsv.get_param("b") == "y":
        jsv.reject("Binary job is rejected.")
        return

    # If parallel env set, enforce multiple of 16 slots
    if jsv.get_param("pe_name") != "":
        slots_s: str = jsv.get_param("pe_slots")
        slots: Optional[int] = _to_int(slots_s)

        if slots is None:
            jsv.reject("Parallel job has non-numeric pe_slots slot request")
            return

        if (slots % 16) > 0:
            jsv.reject("Parallel job does not request a multiple of 16 slots")
            return

    # l_hard: delete h_vmem => reject_wait, delete h_data => correct
    if jsv.is_param("l_hard"):
        context: str = jsv.get_param("CONTEXT")
        has_h_vmem: bool = jsv.sub_is_param("l_hard", "h_vmem")
        has_h_data: bool = jsv.sub_is_param("l_hard", "h_data")

        if has_h_vmem:
            jsv.sub_del_param("l_hard", "h_vmem")
            do_wait = True
            if context == "client":
                jsv.log_info("h_vmem as hard resource requirement has been deleted")

        if has_h_data:
            jsv.sub_del_param("l_hard", "h_data")
            do_correct = True
            if context == "client":
                jsv.log_info("h_data as hard resource requirement has been deleted")

    # ac: increment a, delete b, add c
    if jsv.is_param("ac"):
        context: str = jsv.get_param("CONTEXT")
        has_ac_a: bool = jsv.sub_is_param("ac", "a")
        has_ac_b: bool = jsv.sub_is_param("ac", "b")

        if has_ac_a:
            ac_a_value_s: str = jsv.sub_get_param("ac", "a")
            ac_a_value: Optional[int] = _to_int(ac_a_value_s)
            if ac_a_value is None:
                # Tcl expr would error; choose deterministic safe fallback
                ac_a_value = 0
            new_value: int = ac_a_value + 1
            jsv.sub_add_param("ac", "a", str(new_value))
        else:
            jsv.sub_add_param("ac", "a", "1")

        if has_ac_b:
            jsv.sub_del_param("ac", "b")

        # Tcl: jsv_sub_add_param "ac" "c"  (no value)
        jsv.sub_add_param("ac", "c", "")

        if context == "client":
            jsv.log_info("ac updated (a incremented, b removed, c added)")

        do_correct = True

    # ENV tests: X/Y/Z
    x: str = jsv.get_env("X")
    enter: str = "a\\tb\\nc\\td"
    if x == enter:
        jsv.add_env("ENV_RESULT", "TRUE")

    y: str = jsv.get_env("Y")
    if y == "1":
        jsv.mod_env("ENV_RESULT", "TRUE")

    z: str = jsv.get_env("Z")
    if z == "1":
        jsv.del_env("Z")

    # final decision
    if do_wait:
        jsv.reject_wait("Job is rejected. It might be submitted later.")
    elif do_correct:
        jsv.correct("Job was modified before it was accepted")
    else:
        jsv.accept("Job is accepted")


jsv.on_start = on_start
jsv.on_verify = on_verify

if __name__ == "__main__":
    jsv.main()
