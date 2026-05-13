# TS interactive-surface inventory

Inventory of every TTY-blocking call site in the testsuite
framework.  Drives tasks 14–18 of the TS Framework Cleanup
project.

**How to regenerate:**

```
cd <repo root>   # the dir containing testsuite/ and ocs-testsuite/
tclsh testsuite/doc/inventory_interactive.tcl \
    > testsuite/doc/interactive-surface.md
```

**Patterns searched:** `wait_for_enter`, `expect_user`, `get_user_input`, `ask_user_yes_or_no`, `gets stdin`.

**Caveat:** classification is heuristic — context patterns
("press enter", "(y/n)", "password", "enter the …") drive
the type assignment.  False positives exist, especially for
calls in long procs where unrelated nearby text matches a
classifier.  Treat the Type column as a triage hint, not a
spec; verify each row by reading the surrounding code before
acting on it.

**Total call sites:** 507

## Summary by type

| Type | Count |
|---|---|
| `pause` | 364 |
| `decision` | 61 |
| `text-input` | 75 |
| `password` | 7 |
| **total** | **507** |

## Summary by suggested fix

| Fix | Count |
|---|---|
| `gate-on-check_is_interactive` | 303 |
| `config-driven-default-or-error-out` | 108 |
| `extract-to-menu-only` | 89 |
| `use-get_pw_command` | 7 |

## Hottest files

| File | Calls |
|---|---|
| `testsuite/src/check.exp` | 131 |
| `testsuite/src/tcl_files/config_host.tcl` | 82 |
| `testsuite/src/tcl_files/ocs_installer.tcl` | 61 |
| `testsuite/src/tcl_files/config_database.tcl` | 57 |
| `testsuite/src/tcl_files/config_filesystem.tcl` | 34 |
| `testsuite/src/tcl_files/config_user.tcl` | 31 |
| `testsuite/src/tcl_files/config.tcl` | 20 |
| `testsuite/src/checktree_mpi/config.tcl` | 19 |
| `testsuite/src/checktree/bugs/issuezilla/1451/check.exp` | 7 |
| `testsuite/src/checktree/functional/inst_submit_host/check.exp` | 6 |
| `testsuite/src/checktree/functional/copy_certs/check.exp` | 6 |
| `testsuite/src/tcl_files/compile.tcl` | 4 |
| `testsuite/src/checktree/functional/manual_tests/manual_util.tcl` | 4 |
| `testsuite/src/tcl_files/sge_sharetree.tcl` | 4 |
| `testsuite/src/tcl_files/sge_procedures.tcl` | 4 |

## Classification key

- **`pause`** — cosmetic "press enter to continue", no decision.  Fix: gate on `check_is_interactive`.
- **`decision`** — Y/N or choice that determines control flow.  Fix: provide config-driven default, or error-out in strict-batch.
- **`text-input`** — free-form value entry (hostname, path, name).  Fix: source from config, or error-out in strict-batch.
- **`password`** — credential prompt.  Fix: route through `get_pw_command`.

- **`reach = Y`** — call is reachable from at least one batch flag (`install`, `start`, `all`, …) or runs during normal startup.
- **`reach = menu-only`** — call is inside menu / edit procs that only run in interactive mode.  Lower priority.

## Full table

| File:Line | Proc | Type | Reach | Suggested fix | Snippet |
|---|---|---|---|---|---|
| `ocs-testsuite/checktree_gcs/checktree/component/qstat/check.exp:81` | `qstat_fmt_test_cleanup` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `ocs-testsuite/checktree_gcs/checktree/object/config/config_port_range_builtin/check.exp:246` | `config_pr_builtin_run_interactive` | `decision` | Y | `config-driven-default-or-error-out` | `         expect_user {` |
| `ocs-testsuite/checktree_gcs/checktree/object/pe/allocation_rule/check.exp:275` | `pe_allocation_rule_check_interactive_job` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/check.exp:894` | `set_root_passwd` | `password` | Y | `use-get_pw_command` | `      wait_for_enter` |
| `testsuite/src/check.exp:1147` | `query_passwd` | `password` | Y | `use-get_pw_command` | `      set passwd [wait_for_enter 1 0 1]` |
| `testsuite/src/check.exp:1598` | `check_executable_files` | `decision` | Y | `config-driven-default-or-error-out` | `         set answer [wait_for_enter 1]` |
| `testsuite/src/check.exp:1770` | `show_setup_information` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/check.exp:1788` | `show_setup_information` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/check.exp:1796` | `show_setup_information` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/check.exp:1825` | `save_host_configuration` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:1862` | `save_user_configuration` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:1903` | `save_db_configuration` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:1943` | `save_fs_configuration` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2001` | `save_configuration` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2170` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2177` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2184` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2191` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2198` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2205` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2212` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2219` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2226` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2233` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2240` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2247` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2254` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2261` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2268` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2275` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2282` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2289` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2296` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2303` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2310` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2317` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2324` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2331` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2338` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2346` | `update_ts_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:2482` | `setup2` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/check.exp:2500` | `setup2` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/check.exp:2506` | `setup2` | `pause` | Y | `gate-on-check_is_interactive` | `         set answer [wait_for_enter 1]` |
| `testsuite/src/check.exp:2510` | `setup2` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/check.exp:2516` | `setup2` | `decision` | Y | `config-driven-default-or-error-out` | `               set answer [wait_for_enter 1]` |
| `testsuite/src/check.exp:2520` | `setup2` | `decision` | Y | `config-driven-default-or-error-out` | `                  set answer [ wait_for_enter 1 ]` |
| `testsuite/src/check.exp:2530` | `setup2` | `decision` | Y | `config-driven-default-or-error-out` | `                  set answer [ wait_for_enter 1 ]` |
| `testsuite/src/check.exp:2550` | `setup2` | `decision` | Y | `config-driven-default-or-error-out` | `            set answer [ wait_for_enter 1 ]` |
| `testsuite/src/check.exp:2578` | `setup2` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter 1` |
| `testsuite/src/check.exp:2786` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `                  wait_for_enter` |
| `testsuite/src/check.exp:2800` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/check.exp:2815` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/check.exp:2828` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `                  wait_for_enter` |
| `testsuite/src/check.exp:2832` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/check.exp:2842` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `                  wait_for_enter` |
| `testsuite/src/check.exp:2847` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `                  wait_for_enter` |
| `testsuite/src/check.exp:2857` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `                        wait_for_enter` |
| `testsuite/src/check.exp:2864` | `build_checktree` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/check.exp:3691` | `print_results` | `pause` | Y | `gate-on-check_is_interactive` | `            set pressed [wait_for_enter 1]` |
| `testsuite/src/check.exp:5465` | `select_runlevel` | `text-input` | menu-only | `extract-to-menu-only` | `        set data [wait_for_enter 1]` |
| `testsuite/src/check.exp:5556` | `set_command_line_options` | `text-input` | menu-only | `extract-to-menu-only` | `        set data [wait_for_enter 1]` |
| `testsuite/src/check.exp:5566` | `set_command_line_options` | `text-input` | menu-only | `extract-to-menu-only` | `                    set CHECK_DISPLAY_OUTPUT [wait_for_enter 1]` |
| `testsuite/src/check.exp:5570` | `set_command_line_options` | `pause` | menu-only | `extract-to-menu-only` | `                       wait_for_enter` |
| `testsuite/src/check.exp:5581` | `set_command_line_options` | `text-input` | menu-only | `extract-to-menu-only` | `              set ocs_debug_display [wait_for_enter 1]` |
| `testsuite/src/check.exp:5585` | `set_command_line_options` | `text-input` | menu-only | `extract-to-menu-only` | `               set CHECK_SGE_DEBUG_LEVEL [wait_for_enter 1]` |
| `testsuite/src/check.exp:5589` | `set_command_line_options` | `text-input` | menu-only | `extract-to-menu-only` | `               set ocs_debug_thread_pattern [wait_for_enter 1]` |
| `testsuite/src/check.exp:5600` | `set_command_line_options` | `text-input` | menu-only | `extract-to-menu-only` | `              set ocs_debug_terminal_application [wait_for_enter 1]` |
| `testsuite/src/check.exp:5690` | `show_tests` | `pause` | Y | `gate-on-check_is_interactive` | `     wait_for_enter` |
| `testsuite/src/check.exp:5803` | `change_dir` | `text-input` | menu-only | `extract-to-menu-only` | `     set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:5810` | `change_dir` | `pause` | menu-only | `extract-to-menu-only` | `  wait_for_enter` |
| `testsuite/src/check.exp:6104` | `wait_for_enter` | `pause` | Y | `gate-on-check_is_interactive` | `proc wait_for_enter {{no_text 0} {atimeout 0} {hide_output 0}} {` |
| `testsuite/src/check.exp:6119` | `wait_for_enter` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/check.exp:6228` | `run_all_at_starttime` | `decision` | Y | `config-driven-default-or-error-out` | `   if {[ask_user_yes_or_no " Do you want to enter a special starttime (y/N) ? "]} {` |
| `testsuite/src/check.exp:6230` | `run_all_at_starttime` | `decision` | Y | `config-driven-default-or-error-out` | `      set start_time [get_user_input "    Please enter start time : "]` |
| `testsuite/src/check.exp:6236` | `run_all_at_starttime` | `decision` | Y | `config-driven-default-or-error-out` | `   if {[ask_user_yes_or_no "\n\n Should the testsuite update, compile and install before testing (y/N) ? "]} {` |
| `testsuite/src/check.exp:6243` | `run_all_at_starttime` | `decision` | Y | `config-driven-default-or-error-out` | `   if {[ask_user_yes_or_no "\n\n Are this settings correct (y/N) ? "] == 0} {` |
| `testsuite/src/check.exp:6276` | `run_all_at_starttime` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/check.exp:6304` | `get_user_input` | `text-input` | Y | `config-driven-default-or-error-out` | `proc get_user_input { what } {` |
| `testsuite/src/check.exp:6307` | `get_user_input` | `text-input` | Y | `config-driven-default-or-error-out` | `   set myinput [wait_for_enter 1]` |
| `testsuite/src/check.exp:6341` | `ask_user_yes_or_no` | `decision` | Y | `config-driven-default-or-error-out` | `proc ask_user_yes_or_no { question } {` |
| `testsuite/src/check.exp:6345` | `ask_user_yes_or_no` | `text-input` | Y | `config-driven-default-or-error-out` | `   set myinput [wait_for_enter 1]` |
| `testsuite/src/check.exp:6428` | `menu` | `text-input` | menu-only | `extract-to-menu-only` | `      set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:6460` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `                wait_for_enter` |
| `testsuite/src/check.exp:6470` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `                wait_for_enter` |
| `testsuite/src/check.exp:6476` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/check.exp:6507` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `                wait_for_enter` |
| `testsuite/src/check.exp:6515` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `               wait_for_enter` |
| `testsuite/src/check.exp:6562` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/check.exp:6566` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/check.exp:6573` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/check.exp:6583` | `menu` | `password` | menu-only | `use-get_pw_command` | `            wait_for_enter` |
| `testsuite/src/check.exp:6594` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/check.exp:6619` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/check.exp:6637` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/check.exp:6656` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `               wait_for_enter` |
| `testsuite/src/check.exp:6660` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `               wait_for_enter` |
| `testsuite/src/check.exp:6672` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `               wait_for_enter` |
| `testsuite/src/check.exp:6676` | `menu` | `pause` | menu-only | `extract-to-menu-only` | `               wait_for_enter` |
| `testsuite/src/check.exp:6709` | `run_other_tests_menu` | `text-input` | menu-only | `extract-to-menu-only` | `   set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:6714` | `run_other_tests_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6719` | `run_other_tests_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6724` | `run_other_tests_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6743` | `reset_test_lists_menu` | `text-input` | menu-only | `extract-to-menu-only` | `   set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:6748` | `reset_test_lists_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6753` | `reset_test_lists_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6758` | `reset_test_lists_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6763` | `reset_test_lists_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6781` | `show_test_infos_menu` | `text-input` | menu-only | `extract-to-menu-only` | `   set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:6787` | `show_test_infos_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6793` | `show_test_infos_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6799` | `show_test_infos_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6805` | `show_test_infos_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6825` | `show_test_infos_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6840` | `cluster_checks_menu` | `text-input` | menu-only | `extract-to-menu-only` | `   set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:6846` | `cluster_checks_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6851` | `cluster_checks_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6856` | `cluster_checks_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6861` | `cluster_checks_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6873` | `cluster_cleanups_menu` | `text-input` | menu-only | `extract-to-menu-only` | `   set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:6882` | `cluster_cleanups_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6896` | `testsuite_cleanups_menu` | `text-input` | menu-only | `extract-to-menu-only` | `   set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:6920` | `testsuite_cleanups_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6925` | `testsuite_cleanups_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6930` | `testsuite_cleanups_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6939` | `testsuite_cleanups_menu` | `password` | menu-only | `use-get_pw_command` | `         wait_for_enter` |
| `testsuite/src/check.exp:6955` | `hooks_menu` | `text-input` | menu-only | `extract-to-menu-only` | `   set input [wait_for_enter 1]` |
| `testsuite/src/check.exp:6970` | `hooks_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:6979` | `hooks_menu` | `password` | menu-only | `use-get_pw_command` | `         wait_for_enter` |
| `testsuite/src/check.exp:6988` | `hooks_menu` | `password` | menu-only | `use-get_pw_command` | `         wait_for_enter` |
| `testsuite/src/check.exp:7000` | `hooks_menu` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/check.exp:7023` | `run_not_completed_tests_at_time` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/check.exp:7080` | `do_eval_loop` | `text-input` | menu-only | `extract-to-menu-only` | `      set expr [wait_for_enter 1]` |
| `testsuite/src/check.exp:8711` | `get_mail_subject` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/check.exp:8953` | `ctrlc` | `text-input` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/bugs/issuezilla/1451/check.exp:164` | `issue_1451_uninstall_execd` | `pause` | Y | `gate-on-check_is_interactive` | `          set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/1451/check.exp:182` | `issue_1451_uninstall_execd` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/1451/check.exp:192` | `issue_1451_uninstall_execd` | `pause` | Y | `gate-on-check_is_interactive` | `                 set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/1451/check.exp:202` | `issue_1451_uninstall_execd` | `pause` | Y | `gate-on-check_is_interactive` | `                 set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/1451/check.exp:213` | `issue_1451_uninstall_execd` | `pause` | Y | `gate-on-check_is_interactive` | `                 set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/1451/check.exp:224` | `issue_1451_uninstall_execd` | `pause` | Y | `gate-on-check_is_interactive` | `                 set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/1451/check.exp:235` | `issue_1451_uninstall_execd` | `pause` | Y | `gate-on-check_is_interactive` | `                 set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/1848/check.exp:175` | `issue_1848_run` | `decision` | Y | `config-driven-default-or-error-out` | `      expect_user {` |
| `testsuite/src/checktree/bugs/issuezilla/2755/check.exp:127` | `test_uninst` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/2755/check.exp:147` | `test_uninst` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/bugs/issuezilla/3017/check.exp:143` | `issue_3017_test` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/bugs/jira_cs/1505/check.exp:135` | `cs_1505_parallel` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/checktree/functional/copy_certs/check.exp:101` | `copy_certs_setup` | `pause` | Y | `gate-on-check_is_interactive` | `                  set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/copy_certs/check.exp:117` | `copy_certs_setup` | `pause` | Y | `gate-on-check_is_interactive` | `                  set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/copy_certs/check.exp:138` | `copy_certs_setup` | `pause` | Y | `gate-on-check_is_interactive` | `                  set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/copy_certs/check.exp:147` | `copy_certs_setup` | `pause` | Y | `gate-on-check_is_interactive` | `                  set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/copy_certs/check.exp:156` | `copy_certs_setup` | `pause` | Y | `gate-on-check_is_interactive` | `                  set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/copy_certs/check.exp:172` | `copy_certs_setup` | `pause` | Y | `gate-on-check_is_interactive` | `                  set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/event_client/max_dyn_ec/check.exp:294` | `max_dyn_ec_massive_qsub_sync` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/functional/event_client/max_dyn_ec/check.exp:426` | `max_dyn_ec_out_of_ids` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/functional/inst_submit_host/check.exp:87` | `inst_submit_host_setup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/inst_submit_host/check.exp:103` | `inst_submit_host_setup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/inst_submit_host/check.exp:124` | `inst_submit_host_setup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/inst_submit_host/check.exp:133` | `inst_submit_host_setup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/inst_submit_host/check.exp:142` | `inst_submit_host_setup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/inst_submit_host/check.exp:158` | `inst_submit_host_setup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/job_environment/job_environment_basic/check.exp:906` | `job_environment_TERM_test` | `decision` | Y | `config-driven-default-or-error-out` | `      expect_user {` |
| `testsuite/src/checktree/functional/manual_tests/manual_util.tcl:81` | `manual_select_hosts` | `decision` | Y | `config-driven-default-or-error-out` | `         set result [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/manual_tests/manual_util.tcl:375` | `sge_man` | `decision` | Y | `config-driven-default-or-error-out` | `      set result [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/manual_tests/manual_util.tcl:872` | `sge_qmon` | `decision` | Y | `config-driven-default-or-error-out` | `      set result [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/manual_tests/manual_util.tcl:1456` | `sge_qmaster_log` | `decision` | Y | `config-driven-default-or-error-out` | `         set result [wait_for_enter 1]` |
| `testsuite/src/checktree/functional/tight_integration/x_forks_slaves/check.exp:204` | `x_forks_slaves_check_qrsh_inherit` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/install_core_system/init_cluster.tcl:1277` | `install_send_answer` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/checktree/install_core_system/interactive/execd.tcl:249` | `install_execd` | `pause` | Y | `gate-on-check_is_interactive` | `             set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/install_core_system/interactive/qmaster.tcl:213` | `install_qmaster` | `pause` | Y | `gate-on-check_is_interactive` | `         set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/install_core_system/interactive/shadowd.tcl:137` | `install_shadowd` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree/performance/large_cluster/loadsensor.tcl:60` | `<top-level>` | `pause` | Y | `gate-on-check_is_interactive` | `while { [gets stdin line] >= 0 } {` |
| `testsuite/src/checktree/performance/throughput/check.exp:1172` | `run_throughput_test` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/performance/throughput/check.exp:1347` | `run_throughput_test` | `decision` | Y | `config-driven-default-or-error-out` | `   } ;# expect_user` |
| `testsuite/src/checktree/performance/throughput/check.exp:1404` | `run_throughput_test` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/system_tests/clients/qlogin/check.exp:100` | `qlogin_send_expect` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/system_tests/clients/qmake/check.exp:161` | `qmake_submit` | `decision` | Y | `config-driven-default-or-error-out` | `      expect_user {` |
| `testsuite/src/checktree/system_tests/clients/qmake/check.exp:216` | `qmake_monitor` | `decision` | Y | `config-driven-default-or-error-out` | `      expect_user {` |
| `testsuite/src/checktree/system_tests/clients/qrsh/check.exp:2053` | `qrsh_massive_output` | `decision` | Y | `config-driven-default-or-error-out` | `         expect_user {` |
| `testsuite/src/checktree/system_tests/clients/qsub/qsub_w/check.exp:179` | `qsub_option_w_e_3132` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/checktree/system_tests/qmaster/monitoring/check.exp:156` | `qmaster_monitoring_monitor` | `decision` | Y | `config-driven-default-or-error-out` | `      expect_user {` |
| `testsuite/src/checktree/system_tests/qmaster/profiling/check.exp:113` | `qmaster_profiling_monitor` | `decision` | Y | `config-driven-default-or-error-out` | `      expect_user {` |
| `testsuite/src/checktree_arco/checktree.tcl:473` | `startup_dbwriter` | `pause` | Y | `gate-on-check_is_interactive` | `           wait_for_enter` |
| `testsuite/src/checktree_arco/checktree/install/dbwriter/check.exp:105` | `arco_dbwriter_install` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree_arco/config.tcl:93` | `arco_save_configuration` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/checktree_arco/sql_util.tcl:86` | `send_to_spawn_id` | `pause` | Y | `gate-on-check_is_interactive` | `      set anykey [wait_for_enter 1]` |
| `testsuite/src/checktree_drmaaj/config.tcl:54` | `drmaaj_save_configuration` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:54` | `mpi_save_configuration` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:205` | `config_mpi_list` | `text-input` | Y | `config-driven-default-or-error-out` | `         set input [wait_for_enter 1]` |
| `testsuite/src/checktree_mpi/config.tcl:210` | `config_mpi_list` | `pause` | Y | `gate-on-check_is_interactive` | `                  wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:216` | `config_mpi_list` | `pause` | Y | `gate-on-check_is_interactive` | `                  wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:222` | `config_mpi_list` | `pause` | Y | `gate-on-check_is_interactive` | `                  wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:319` | `config_mpi_add_installation` | `text-input` | Y | `config-driven-default-or-error-out` | `   set new_mpi [wait_for_enter 1]` |
| `testsuite/src/checktree_mpi/config.tcl:370` | `config_mpi_edit_installation` | `text-input` | Y | `config-driven-default-or-error-out` | `         set mpi [wait_for_enter 1]` |
| `testsuite/src/checktree_mpi/config.tcl:388` | `config_mpi_edit_installation` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:396` | `config_mpi_edit_installation` | `text-input` | Y | `config-driven-default-or-error-out` | `      set input [wait_for_enter 1]` |
| `testsuite/src/checktree_mpi/config.tcl:404` | `config_mpi_edit_installation` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:410` | `config_mpi_edit_installation` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:434` | `config_mpi_edit_installation` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:446` | `config_mpi_edit_installation` | `text-input` | Y | `config-driven-default-or-error-out` | `            wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:463` | `config_mpi_edit_installation` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:477` | `config_mpi_edit_installation` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:505` | `mpi_config_delete_installation` | `text-input` | Y | `config-driven-default-or-error-out` | `      set mpi [wait_for_enter 1]` |
| `testsuite/src/checktree_mpi/config.tcl:518` | `mpi_config_delete_installation` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/checktree_mpi/config.tcl:525` | `mpi_config_delete_installation` | `decision` | Y | `config-driven-default-or-error-out` | `      set input [wait_for_enter 1]` |
| `testsuite/src/checktree_mpi/config.tcl:536` | `mpi_config_delete_installation` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/compile.tcl:1132` | `compile_source_cmake_execute` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/tcl_files/compile.tcl:2159` | `prepare_packages` | `text-input` | Y | `config-driven-default-or-error-out` | `               set user_key [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/compile.tcl:2578` | `build_distribution` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/tcl_files/compile.tcl:2689` | `install_binaries` | `decision` | Y | `config-driven-default-or-error-out` | `      expect_user {` |
| `testsuite/src/tcl_files/config.tcl:132` | `verify_config2` | `pause` | Y | `gate-on-check_is_interactive` | `               if { $only_check == 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config.tcl:155` | `verify_config2` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config.tcl:169` | `verify_config2` | `pause` | Y | `gate-on-check_is_interactive` | `               if { $only_check == 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config.tcl:183` | `verify_config2` | `text-input` | Y | `config-driven-default-or-error-out` | `                  set value [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config.tcl:299` | `edit_setup` | `pause` | menu-only | `extract-to-menu-only` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config.tcl:340` | `edit_setup` | `text-input` | menu-only | `extract-to-menu-only` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config.tcl:348` | `edit_setup` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config.tcl:351` | `edit_setup` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config.tcl:425` | `edit_setup` | `decision` | menu-only | `extract-to-menu-only` | `         set input [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config.tcl:467` | `edit_setup` | `pause` | menu-only | `extract-to-menu-only` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config.tcl:650` | `modify_setup2` | `text-input` | menu-only | `extract-to-menu-only` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config.tcl:695` | `modify_setup2` | `pause` | menu-only | `extract-to-menu-only` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config.tcl:940` | `config_generic` | `text-input` | Y | `config-driven-default-or-error-out` | `               set new_value [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config.tcl:961` | `config_generic` | `text-input` | Y | `config-driven-default-or-error-out` | `            set val [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config.tcl:1185` | `config_choose_value` | `text-input` | menu-only | `extract-to-menu-only` | `   set output [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config.tcl:1306` | `config_assign_indexes` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config.tcl:1565` | `config_verify_filename` | `decision` | Y | `config-driven-default-or-error-out` | `         if { [ wait_for_enter 1 ] == "y" } {` |
| `testsuite/src/tcl_files/config.tcl:1580` | `config_verify_host` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config.tcl:3827` | `config_enable_error_mails` | `decision` | Y | `config-driven-default-or-error-out` | `         set input [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config.tcl:3909` | `config_l10n_test_locale` | `pause` | Y | `gate-on-check_is_interactive` | `                     wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:108` | `db_config_dbtypelist` | `text-input` | Y | `config-driven-default-or-error-out` | `         set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:112` | `db_config_dbtypelist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:116` | `db_config_dbtypelist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:120` | `db_config_dbtypelist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:261` | `db_config_dbtypelist_add_dbtype` | `text-input` | Y | `config-driven-default-or-error-out` | `      set new_dbtype [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:321` | `db_config_dbtypelist_edit_dbtype` | `text-input` | Y | `config-driven-default-or-error-out` | `         set dbtype [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:337` | `db_config_dbtypelist_edit_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:345` | `db_config_dbtypelist_edit_dbtype` | `text-input` | Y | `config-driven-default-or-error-out` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:353` | `db_config_dbtypelist_edit_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:359` | `db_config_dbtypelist_edit_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:372` | `db_config_dbtypelist_edit_dbtype` | `text-input` | Y | `config-driven-default-or-error-out` | `         set value [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config_database.tcl:380` | `db_config_dbtypelist_edit_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:386` | `db_config_dbtypelist_edit_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:396` | `db_config_dbtypelist_edit_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `         if { $value != -1 } { set config($dbtype,$input) $value } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:407` | `db_config_dbtypelist_edit_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `         if { $value != -1 } { set config($dbtype,$input) $value } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:445` | `db_config_dbtypelist_delete_dbtype` | `text-input` | Y | `config-driven-default-or-error-out` | `      set dbtype [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:456` | `db_config_dbtypelist_delete_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:471` | `db_config_dbtypelist_delete_dbtype` | `decision` | Y | `config-driven-default-or-error-out` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:479` | `db_config_dbtypelist_delete_dbtype` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:531` | `db_config_databaselist` | `text-input` | Y | `config-driven-default-or-error-out` | `         set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:535` | `db_config_databaselist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:539` | `db_config_databaselist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:543` | `db_config_databaselist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:654` | `db_config_databaselist_add_database` | `text-input` | Y | `config-driven-default-or-error-out` | `      set new_database [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:717` | `db_config_databaselist_edit_database` | `text-input` | Y | `config-driven-default-or-error-out` | `         set database [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:733` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:741` | `db_config_databaselist_edit_database` | `text-input` | Y | `config-driven-default-or-error-out` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:749` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:755` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:774` | `db_config_databaselist_edit_database` | `text-input` | Y | `config-driven-default-or-error-out` | `         set value [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config_database.tcl:791` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:798` | `db_config_databaselist_edit_database` | `text-input` | Y | `config-driven-default-or-error-out` | `         if { $value != -1 } { set config($database,$input) $value } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:811` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:821` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:830` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:839` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:848` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:857` | `db_config_databaselist_edit_database` | `pause` | Y | `gate-on-check_is_interactive` | `         } else { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:895` | `db_config_databaselist_delete_database` | `text-input` | Y | `config-driven-default-or-error-out` | `      set database [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:906` | `db_config_databaselist_delete_database` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:913` | `db_config_databaselist_delete_database` | `decision` | Y | `config-driven-default-or-error-out` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:924` | `db_config_databaselist_delete_database` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:971` | `db_config_add_newdatabase` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:1067` | `verify_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `               if { $only_check == 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:1086` | `verify_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:1101` | `verify_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `               if { $only_check == 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_database.tcl:1117` | `verify_db_config` | `text-input` | Y | `config-driven-default-or-error-out` | `                     set value [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:1137` | `verify_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:1170` | `setup_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:1188` | `setup_db_config` | `decision` | Y | `config-driven-default-or-error-out` | `                  set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:1191` | `setup_db_config` | `decision` | Y | `config-driven-default-or-error-out` | `                     set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_database.tcl:1195` | `setup_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `                           wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:1204` | `setup_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:1212` | `setup_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:1221` | `setup_db_config` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter 1` |
| `testsuite/src/tcl_files/config_database.tcl:1275` | `update_ts_db_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_database.tcl:1278` | `update_ts_db_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:135` | `fs_config_fsname_list` | `text-input` | Y | `config-driven-default-or-error-out` | `         set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:139` | `fs_config_fsname_list` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_filesystem.tcl:143` | `fs_config_fsname_list` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_filesystem.tcl:147` | `fs_config_fsname_list` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_filesystem.tcl:255` | `fs_config_filesystemlist_add_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `      set new_filesystem [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:283` | `fs_config_filesystemlist_add_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `                  set new_servername [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:298` | `fs_config_filesystemlist_add_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `                  set new_fstype [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:317` | `fs_config_filesystemlist_add_filesystem` | `decision` | Y | `config-driven-default-or-error-out` | `                  set new_fssuwrite [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:333` | `fs_config_filesystemlist_add_filesystem` | `decision` | Y | `config-driven-default-or-error-out` | `                  set new_fssulogin [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:383` | `fs_config_filesystemlist_edit_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `         set filesystem [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:399` | `fs_config_filesystemlist_edit_filesystem` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:407` | `fs_config_filesystemlist_edit_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:415` | `fs_config_filesystemlist_edit_filesystem` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:421` | `fs_config_filesystemlist_edit_filesystem` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:436` | `fs_config_filesystemlist_edit_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `         set value [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:444` | `fs_config_filesystemlist_edit_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `            set new_servername [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:459` | `fs_config_filesystemlist_edit_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `            set new_fstype [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:476` | `fs_config_filesystemlist_edit_filesystem` | `decision` | Y | `config-driven-default-or-error-out` | `            set new_fssuwrite [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:490` | `fs_config_filesystemlist_edit_filesystem` | `decision` | Y | `config-driven-default-or-error-out` | `            set new_fssulogin [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:533` | `fs_config_filesystemlist_delete_filesystem` | `text-input` | Y | `config-driven-default-or-error-out` | `      set filesystem [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:544` | `fs_config_filesystemlist_delete_filesystem` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:551` | `fs_config_filesystemlist_delete_filesystem` | `decision` | Y | `config-driven-default-or-error-out` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:562` | `fs_config_filesystemlist_delete_filesystem` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:676` | `verify_fs_config` | `pause` | Y | `gate-on-check_is_interactive` | `               if { $only_check == 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_filesystem.tcl:695` | `verify_fs_config` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:710` | `verify_fs_config` | `pause` | Y | `gate-on-check_is_interactive` | `               if { $only_check == 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_filesystem.tcl:726` | `verify_fs_config` | `text-input` | Y | `config-driven-default-or-error-out` | `                     set value [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:746` | `verify_fs_config` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:795` | `setup_fs_config` | `decision` | Y | `config-driven-default-or-error-out` | `                  set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:798` | `setup_fs_config` | `decision` | Y | `config-driven-default-or-error-out` | `                     set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_filesystem.tcl:802` | `setup_fs_config` | `pause` | Y | `gate-on-check_is_interactive` | `                           wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:811` | `setup_fs_config` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:819` | `setup_fs_config` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/tcl_files/config_filesystem.tcl:828` | `setup_fs_config` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter 1` |
| `testsuite/src/tcl_files/config_host.tcl:118` | `host_config_hostlist` | `text-input` | menu-only | `extract-to-menu-only` | `         set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:122` | `host_config_hostlist` | `pause` | menu-only | `extract-to-menu-only` | `               if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_host.tcl:126` | `host_config_hostlist` | `pause` | menu-only | `extract-to-menu-only` | `               if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_host.tcl:130` | `host_config_hostlist` | `pause` | menu-only | `extract-to-menu-only` | `               if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_host.tcl:164` | `host_config_hostlist` | `pause` | menu-only | `extract-to-menu-only` | `               wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:720` | `host_config_hostlist_add_host` | `text-input` | menu-only | `extract-to-menu-only` | `      set new_host [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:738` | `host_config_hostlist_add_host` | `text-input` | menu-only | `extract-to-menu-only` | `         set result [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config_host.tcl:790` | `host_config_hostlist_add_host` | `pause` | menu-only | `extract-to-menu-only` | `   wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:831` | `host_config_hostlist_edit_host` | `text-input` | menu-only | `extract-to-menu-only` | `         set host [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:847` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:855` | `host_config_hostlist_edit_host` | `text-input` | menu-only | `extract-to-menu-only` | `      set input [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:929` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:934` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:943` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `                     wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:952` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:963` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:983` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:987` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:999` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `                  wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1009` | `host_config_hostlist_edit_host` | `pause` | menu-only | `extract-to-menu-only` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1045` | `host_config_hostlist_delete_host` | `text-input` | menu-only | `extract-to-menu-only` | `      set host [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:1056` | `host_config_hostlist_delete_host` | `pause` | menu-only | `extract-to-menu-only` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1063` | `host_config_hostlist_delete_host` | `decision` | menu-only | `extract-to-menu-only` | `      set input [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:1126` | `host_config_add_newhost` | `pause` | menu-only | `extract-to-menu-only` | `   wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1220` | `verify_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `               if {$only_check == 0} { wait_for_enter }` |
| `testsuite/src/tcl_files/config_host.tcl:1240` | `verify_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1256` | `verify_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `               if {$only_check == 0} {wait_for_enter}` |
| `testsuite/src/tcl_files/config_host.tcl:1272` | `verify_host_config` | `text-input` | Y | `config-driven-default-or-error-out` | `                     set value [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:1292` | `verify_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1331` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1334` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1348` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1351` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1365` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1368` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1382` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1385` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1433` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1436` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1468` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1471` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1498` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1501` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1518` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1521` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1536` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1539` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1565` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1568` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1599` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1602` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1632` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1635` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1655` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1658` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1678` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1681` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1703` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1706` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1724` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1727` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1748` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1751` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1772` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1775` | `update_ts_host_config_version` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1858` | `setup_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1867` | `setup_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `         set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:1875` | `setup_host_config` | `decision` | Y | `config-driven-default-or-error-out` | `               set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:1878` | `setup_host_config` | `decision` | Y | `config-driven-default-or-error-out` | `                  set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_host.tcl:1882` | `setup_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `                        wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1891` | `setup_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1898` | `setup_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:1905` | `setup_host_config` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter 1` |
| `testsuite/src/tcl_files/config_host.tcl:3442` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:3445` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:3448` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:3453` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:3456` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:3459` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:3462` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:3466` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_host.tcl:3470` | `private_test_host_conf_get_suited_host` | `pause` | Y | `gate-on-check_is_interactive` | `   puts "-> $hosts" ; wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:373` | `user_config_userlist` | `text-input` | Y | `config-driven-default-or-error-out` | `          set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:377` | `user_config_userlist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_user.tcl:381` | `user_config_userlist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_user.tcl:385` | `user_config_userlist` | `pause` | Y | `gate-on-check_is_interactive` | `                if { $result != 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_user.tcl:574` | `user_config_userlist_add_user` | `text-input` | Y | `config-driven-default-or-error-out` | `      set new_user [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:630` | `user_config_userlist_edit_user` | `text-input` | Y | `config-driven-default-or-error-out` | `         set user [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:646` | `user_config_userlist_edit_user` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:656` | `user_config_userlist_edit_user` | `text-input` | Y | `config-driven-default-or-error-out` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:664` | `user_config_userlist_edit_user` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:670` | `user_config_userlist_edit_user` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:682` | `user_config_userlist_edit_user` | `text-input` | Y | `config-driven-default-or-error-out` | `         set value [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config_user.tcl:687` | `user_config_userlist_edit_user` | `text-input` | Y | `config-driven-default-or-error-out` | `         set value [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config_user.tcl:690` | `user_config_userlist_edit_user` | `pause` | Y | `gate-on-check_is_interactive` | `            wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:699` | `user_config_userlist_edit_user` | `text-input` | Y | `config-driven-default-or-error-out` | `         set value [ wait_for_enter 1 ]` |
| `testsuite/src/tcl_files/config_user.tcl:705` | `user_config_userlist_edit_user` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:863` | `user_config_userlist_delete_user` | `text-input` | Y | `config-driven-default-or-error-out` | `      set user [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:874` | `user_config_userlist_delete_user` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:888` | `user_config_userlist_delete_user` | `decision` | Y | `config-driven-default-or-error-out` | `      set input [ wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:900` | `user_config_userlist_delete_user` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:992` | `verify_user_config` | `pause` | Y | `gate-on-check_is_interactive` | `               if { $only_check == 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_user.tcl:1012` | `verify_user_config` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:1028` | `verify_user_config` | `pause` | Y | `gate-on-check_is_interactive` | `               if { $only_check == 0 } { wait_for_enter }` |
| `testsuite/src/tcl_files/config_user.tcl:1044` | `verify_user_config` | `text-input` | Y | `config-driven-default-or-error-out` | `                     set value [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:1064` | `verify_user_config` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:1113` | `setup_user_config` | `decision` | Y | `config-driven-default-or-error-out` | `                  set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:1116` | `setup_user_config` | `decision` | Y | `config-driven-default-or-error-out` | `                     set answer [wait_for_enter 1]` |
| `testsuite/src/tcl_files/config_user.tcl:1120` | `setup_user_config` | `pause` | Y | `gate-on-check_is_interactive` | `                           wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:1134` | `setup_user_config` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:1142` | `setup_user_config` | `pause` | Y | `gate-on-check_is_interactive` | `               wait_for_enter` |
| `testsuite/src/tcl_files/config_user.tcl:1151` | `setup_user_config` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter 1` |
| `testsuite/src/tcl_files/config_user.tcl:1265` | `user_config_add_newport` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/tcl_files/file_procedures.tcl:2073` | `create_shell_script` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/logging.tcl:1009` | `ts_private_do_log` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/ocs_installer.tcl:415` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            gets stdin anykey` |
| `testsuite/src/tcl_files/ocs_installer.tcl:430` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            gets stdin anykey` |
| `testsuite/src/tcl_files/ocs_installer.tcl:443` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:455` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:467` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:479` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:491` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:503` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:515` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:526` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:538` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:550` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:562` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:574` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:587` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:599` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:618` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:630` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:642` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:656` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:673` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:686` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:698` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:710` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:724` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:737` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:749` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:761` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:776` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:783` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `               set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:807` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:820` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:833` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:850` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:858` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:876` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:884` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:902` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:911` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:929` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:938` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:956` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:973` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:985` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:998` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1010` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1023` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1036` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1049` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `           set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1062` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `                 set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1069` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `                 set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1082` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1094` | `installer_do_upgrade_from_backup` | `password` | Y | `use-get_pw_command` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1107` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `              set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1119` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1131` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1143` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1155` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1167` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1179` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/ocs_installer.tcl:1196` | `installer_do_upgrade_from_backup` | `pause` | Y | `gate-on-check_is_interactive` | `            set anykey [wait_for_enter 1]` |
| `testsuite/src/tcl_files/remote_procedures.tcl:661` | `start_remote_prog` | `pause` | Y | `gate-on-check_is_interactive` | `         wait_for_enter` |
| `testsuite/src/tcl_files/remote_procedures.tcl:827` | `start_remote_prog` | `pause` | Y | `gate-on-check_is_interactive` | `      wait_for_enter` |
| `testsuite/src/tcl_files/sge_job.tcl:106` | `tight_integration_monitor` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/tcl_files/sge_procedures.tcl:563` | `seek_and_destroy_sge_processes` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/tcl_files/sge_procedures.tcl:6254` | `get_qacct_multi` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/tcl_files/sge_procedures.tcl:8746` | `submit_with_method_read_startup_messages` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/tcl_files/sge_procedures.tcl:8796` | `submit_with_method_wait_for_shell_response` | `decision` | Y | `config-driven-default-or-error-out` | `   expect_user {` |
| `testsuite/src/tcl_files/sge_sharetree.tcl:930` | `test_stree_buffer` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/tcl_files/sge_sharetree.tcl:936` | `test_stree_buffer` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/tcl_files/sge_sharetree.tcl:957` | `test_stree_buffer` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
| `testsuite/src/tcl_files/sge_sharetree.tcl:974` | `test_stree_buffer` | `pause` | Y | `gate-on-check_is_interactive` | `   wait_for_enter` |
