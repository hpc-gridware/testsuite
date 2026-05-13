#!/usr/bin/env tclsh
# TS interactive-surface inventory generator.
#
# Walks testsuite + ocs-testsuite source trees, finds every
# wait_for_enter / expect_user / get_user_input / ask_user_yes_or_no /
# gets stdin call site, classifies each by surrounding-context
# heuristics, emits markdown to stdout.
#
# Run from the repo root (the dir containing testsuite/ and
# ocs-testsuite/):
#
#   tclsh testsuite/doc/inventory_interactive.tcl \
#       > testsuite/doc/interactive-surface.md

set ROOTS {
    testsuite/src/check.exp
    testsuite/src/tcl_files
    testsuite/src/checktree
    testsuite/src/checktree_arco
    testsuite/src/checktree_drmaaj
    testsuite/src/checktree_mpi
    ocs-testsuite
}

# main search pattern (Henry-Spencer ARE syntax; \y is word boundary)
set PATTERN {\y(wait_for_enter|expect_user|get_user_input|ask_user_yes_or_no|gets\s+stdin)\y}
set PROC_RE {^\s*proc\s+(\S+)\s*\{}

# Heuristic classifiers, ordered: first match wins.
# (?i) makes the rest of the pattern case-insensitive.
set CLASSIFIERS [list \
    {password   {(?i)passwd|password|root pwd|root password}} \
    {decision   {(?i)\(\s*y\s*/\s*n\s*\)|yes/no|\(y\)es|should i|retry\?|save\?|restore\?|change\?|do you want|correct\?|continue\?|delete\?|abort\?}} \
    {text-input {(?i)enter (the|a|new|hostname|host name|name of|path|number|value|filename|file name|user|directory)|specify (the|a|name|hostname|value)|please enter}} \
    {pause      {(?i)press\s+(enter|return)|press\s+any|press\s+\^c}} \
]

# Procs that only run in interactive (menu) mode.
set MENU_ONLY_RE {^(menu$|.*_menu$|do_eval_loop$|change_dir$|select_runlevel$|set_command_line_options$|menu_item_install_cluster$|print_menu_header$|hooks_menu$|modify_setup2$|edit_setup$|config_choose_value$|host_config_hostlist|host_config_display|host_config_get_host_parameters$|host_config_hostlist_add_host$|host_config_hostlist_edit_host$|host_config_hostlist_delete_host$|host_config_add_newhost$|add_proc_error$|print_errors$)}

proc classify {context_blob call_line} {
    global CLASSIFIERS
    foreach pair $CLASSIFIERS {
        lassign $pair label re
        if {[regexp -- $re $context_blob]} {
            return $label
        }
    }
    # No nearby vocabulary matched: classify from the call shape itself.
    if {[regexp {set\s+\S+\s+\[\s*wait_for_enter} $call_line]} {
        return "text-input"
    }
    if {[string match "*wait_for_enter 1*" $call_line] \
            || [string match "*wait_for_enter  1*" $call_line]} {
        return "pause"
    }
    if {[regexp {\ywait_for_enter\y} $call_line]} {
        return "pause"
    }
    if {[string match "*expect_user*" $call_line]} {
        return "decision"
    }
    if {[string match "*get_user_input*" $call_line]} {
        return "text-input"
    }
    if {[string match "*ask_user_yes_or_no*" $call_line]} {
        return "decision"
    }
    return "pause"
}

proc find_enclosing_proc {lines idx} {
    global PROC_RE
    for {set i $idx} {$i >= 0} {incr i -1} {
        set line [lindex $lines $i]
        if {[regexp -- $PROC_RE $line -> name]} {
            return $name
        }
    }
    return "<top-level>"
}

proc reachable_from_batch {proc_name file_path} {
    global MENU_ONLY_RE
    if {[regexp -- $MENU_ONLY_RE $proc_name]} {
        return "menu-only"
    }
    return "Y"
}

proc suggested_fix {kind reach} {
    switch -- $kind {
        pause {
            if {$reach eq "menu-only"} { return "extract-to-menu-only" }
            return "gate-on-check_is_interactive"
        }
        password {
            return "use-get_pw_command"
        }
        decision -
        text-input {
            if {$reach eq "menu-only"} { return "extract-to-menu-only" }
            return "config-driven-default-or-error-out"
        }
    }
    return "unknown"
}

proc walk_files {roots} {
    set out {}
    foreach root $roots {
        if {[file isfile $root]} {
            lappend out $root
            continue
        }
        if {![file isdirectory $root]} {
            continue
        }
        set stack [list $root]
        while {[llength $stack] > 0} {
            set d [lindex $stack 0]
            set stack [lrange $stack 1 end]
            foreach pat {*.tcl *.exp} {
                foreach f [glob -nocomplain -directory $d -types f -- $pat] {
                    lappend out $f
                }
            }
            foreach sub [glob -nocomplain -directory $d -types d -- *] {
                lappend stack $sub
            }
        }
    }
    return $out
}

proc compare_rows {a b} {
    set cmp [string compare [lindex $a 0] [lindex $b 0]]
    if {$cmp != 0} { return $cmp }
    set al [lindex $a 1]
    set bl [lindex $b 1]
    if {$al < $bl} { return -1 }
    if {$al > $bl} { return 1 }
    return 0
}

proc scan_corpus {} {
    global ROOTS PATTERN
    set rows {}
    foreach path [walk_files $ROOTS] {
        if {[catch {
            set fh [open $path r]
            set data [read $fh]
            close $fh
        }]} {
            continue
        }
        set lines [split $data \n]
        set n [llength $lines]
        for {set i 0} {$i < $n} {incr i} {
            set line [lindex $lines $i]
            if {![regexp -- $PATTERN $line]} {
                continue
            }
            # skip comment lines (Tcl '#' at first non-space column)
            set stripped [string trimleft $line]
            if {[string index $stripped 0] eq "#"} {
                continue
            }
            # gather context: 3 before + this + 3 after
            set ctx_start [expr {$i - 3}]
            if {$ctx_start < 0} { set ctx_start 0 }
            set ctx_end [expr {$i + 3}]
            if {$ctx_end >= $n} { set ctx_end [expr {$n - 1}] }
            set ctx_blob [join [lrange $lines $ctx_start $ctx_end] "\n"]
            set kind  [classify $ctx_blob $line]
            set pname [find_enclosing_proc $lines $i]
            set reach [reachable_from_batch $pname $path]
            set fix   [suggested_fix $kind $reach]
            set snippet [string range [string trimright $line] 0 119]
            lappend rows [list $path [expr {$i + 1}] $pname $kind $reach $fix $snippet]
        }
    }
    return [lsort -command compare_rows $rows]
}

proc emit_markdown {rows} {
    array set type_counts {pause 0 decision 0 text-input 0 password 0}
    array set file_counts {}
    array set fix_counts {}
    foreach r $rows {
        lassign $r f line pname kind reach fix snippet
        incr type_counts($kind)
        if {![info exists file_counts($f)]}   { set file_counts($f)   0 }
        if {![info exists fix_counts($fix)]}  { set fix_counts($fix)  0 }
        incr file_counts($f)
        incr fix_counts($fix)
    }

    puts "# TS interactive-surface inventory"
    puts ""
    puts "Inventory of every TTY-blocking call site in the testsuite"
    puts "framework.  Drives tasks 14–18 of the TS Framework Cleanup"
    puts "project."
    puts ""
    puts "**How to regenerate:**"
    puts ""
    puts "```"
    puts "cd <repo root>   # the dir containing testsuite/ and ocs-testsuite/"
    puts "tclsh testsuite/doc/inventory_interactive.tcl \\"
    puts "    > testsuite/doc/interactive-surface.md"
    puts "```"
    puts ""
    puts "**Patterns searched:** `wait_for_enter`, `expect_user`, `get_user_input`, `ask_user_yes_or_no`, `gets stdin`."
    puts ""
    puts "**Caveat:** classification is heuristic — context patterns"
    puts "(\"press enter\", \"(y/n)\", \"password\", \"enter the …\") drive"
    puts "the type assignment.  False positives exist, especially for"
    puts "calls in long procs where unrelated nearby text matches a"
    puts "classifier.  Treat the Type column as a triage hint, not a"
    puts "spec; verify each row by reading the surrounding code before"
    puts "acting on it."
    puts ""
    puts "**Total call sites:** [llength $rows]"
    puts ""

    puts "## Summary by type"
    puts ""
    puts "| Type | Count |"
    puts "|---|---|"
    foreach t {pause decision text-input password} {
        puts "| `$t` | $type_counts($t) |"
    }
    puts "| **total** | **[llength $rows]** |"
    puts ""

    puts "## Summary by suggested fix"
    puts ""
    puts "| Fix | Count |"
    puts "|---|---|"
    set fix_list {}
    foreach k [array names fix_counts] {
        lappend fix_list [list $k $fix_counts($k)]
    }
    foreach pair [lsort -index 1 -integer -decreasing $fix_list] {
        lassign $pair k v
        puts "| `$k` | $v |"
    }
    puts ""

    puts "## Hottest files"
    puts ""
    puts "| File | Calls |"
    puts "|---|---|"
    set file_list {}
    foreach k [array names file_counts] {
        lappend file_list [list $k $file_counts($k)]
    }
    set shown 0
    foreach pair [lsort -index 1 -integer -decreasing $file_list] {
        if {$shown >= 15} break
        lassign $pair k v
        puts "| `$k` | $v |"
        incr shown
    }
    puts ""

    puts "## Classification key"
    puts ""
    puts "- **`pause`** — cosmetic \"press enter to continue\", no decision.  Fix: gate on `check_is_interactive`."
    puts "- **`decision`** — Y/N or choice that determines control flow.  Fix: provide config-driven default, or error-out in strict-batch."
    puts "- **`text-input`** — free-form value entry (hostname, path, name).  Fix: source from config, or error-out in strict-batch."
    puts "- **`password`** — credential prompt.  Fix: route through `get_pw_command`."
    puts ""
    puts "- **`reach = Y`** — call is reachable from at least one batch flag (`install`, `start`, `all`, …) or runs during normal startup."
    puts "- **`reach = menu-only`** — call is inside menu / edit procs that only run in interactive mode.  Lower priority."
    puts ""

    puts "## Full table"
    puts ""
    puts "| File:Line | Proc | Type | Reach | Suggested fix | Snippet |"
    puts "|---|---|---|---|---|---|"
    foreach r $rows {
        lassign $r f line pname kind reach fix snippet
        set snippet [string map {"|" "\\|"} $snippet]
        puts "| `$f:$line` | `$pname` | `$kind` | $reach | `$fix` | `$snippet` |"
    }
}

emit_markdown [scan_corpus]
