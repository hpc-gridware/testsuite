# expect script
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

# sge_json.tcl
#
# Reusable helpers for testing qconf -fmt json output AND input alongside the
# plain (ASCII) format, plus JSON-Schema validation via ajv. Used by the
# object <obj>_attributes tests (see checktree_gcs/.../object/<obj>/<obj>_attributes).
#
# The object-attribute engine (ts_attr_io / ts_attr_json_in / ts_attr_roundtrip /
# ts_attr_negative) drives a single attribute through the plain and json formats so
# that both stay covered and consistent. The engine works on a "cfg" array that
# describes the object under test:
#   cfg(obj_type)  - schema type, e.g. "pe"
#   cfg(name)      - object name, e.g. the test PE name
#   cfg(get_proc)  - plain getter proc, e.g. "get_pe"  (name out_var host user)
#   cfg(mod_proc)  - plain modify proc, e.g. "mod_pe"  (name chg_arr fast host user ?raise?)
#   cfg(show_opt)  - qconf show option incl. name, e.g. "-sp mype"
#   cfg(mod_opt)   - qconf modify option, e.g. "-Mp"
#   cfg(host)      - admin host to run on
#   cfg(user)      - user to run as
#
# The list engine (ts_list_json / ts_list_plain / ts_list_consistency) drives a
# list-show switch (-secl, -s*l, -stl) that produces an enveloped JSON array of
# uniform records. It works on a "lcfg" array that describes the list:
#   lcfg(obj_type)   - schema type for ajv, e.g. "event_clients"
#   lcfg(show_opt)   - qconf show option, e.g. "-secl"
#   lcfg(envelope)   - top-level json array key, e.g. "event_clients"
#   lcfg(fields)     - list of {json_key kind} pairs, e.g. {{id int} {name scalar} {host scalar}}
#   lcfg(key_field)  - json key uniquely identifying a record, e.g. "id"
#   lcfg(min_rows)   - minimum number of records expected (e.g. 1 for the scheduler)
#   lcfg(plain_proc) - proc that runs the plain show and returns a list of records,
#                      each a dict keyed by the json_keys (args: host user)
#   lcfg(host)       - admin host to run on
#   lcfg(user)       - user to run as
#
# The name-list engine (ts_namelist_json / ts_namelist_plain /
# ts_namelist_consistency) drives a name-list switch (-scall, -spl, -sckptl, ...)
# that produces an enveloped JSON array of bare name strings. It works on a "ncfg"
# array:
#   ncfg(obj_type) - schema type for ajv, e.g. "calendar-list" -> ocs-qconf-calendar-list.schema.json
#   ncfg(show_opt) - qconf show option, e.g. "-scall"
#   ncfg(envelope) - top-level json array key (lowercased object type), e.g. "calendar"
#   ncfg(min_rows) - minimum number of names expected (e.g. 1 for the test object)
#   ncfg(host)     - admin host to run on
#   ncfg(user)     - user to run as

## @brief is the ajv JSON-Schema validator available on a host?
#
# Object-attribute test setups should call this and, if it returns 0,
# ts_log_config "..." followed by "return 99" (TS configuration issue, not a
# test error).
#
# @param[in] host - host to check; defaults to the master host
# @return 1 if "ajv" can be executed on the host, 0 otherwise
#
proc ts_json_ajv_available {{host ""}} {
   global ts_config CHECK_USER prg_exit_state
   if {$host == ""} {
      set host $ts_config(master_host)
   }
   # "ajv help" exits 0 when ajv is installed (ajv has no --version switch).
   # run without sourcing settings / file check, do not raise on failure.
   start_remote_prog $host $CHECK_USER "ajv" "help" prg_exit_state 30 0 "" "" 0 0 0 0
   return [expr {$prg_exit_state == 0}]
}

## @brief write a JSON document to a tmp file on a host
#
# @param[in] host - host the file must be readable on (by qconf/ajv)
# @param[in] text - the JSON document text
# @return the path of the written tmp file
#
proc ts_json_write_tmpfile {host text} {
   global CHECK_USER

   set lines [split $text "\n"]
   set i 1
   foreach l $lines {
      set data($i) $l
      incr i
   }
   set data(0) [expr {$i - 1}]

   set tmpfile [get_tmp_file_name $host "json" "json" 1]
   if {$host == [gethostname]} {
      save_file $tmpfile data
   } else {
      write_remote_file $host $CHECK_USER $tmpfile data
   }
   return $tmpfile
}

## @brief validate a JSON document against its qconf object schema using ajv
#
# @param[in] json_text - the JSON document text
# @param[in] obj_type  - the schema type, e.g. "pe" -> ocs-qconf-pe.schema.json
# @param[in] host      - host to run ajv on; defaults to the master host
# @return 1 if the document validates, 0 otherwise (logs ts_log_severe on failure)
#
proc ts_json_validate {json_text obj_type {host ""}} {
   global ts_config CHECK_USER prg_exit_state
   if {$host == ""} {
      set host $ts_config(master_host)
   }
   set sdir "$ts_config(product_root)/util/resources/json-schemas/v9.2"
   set schema "$sdir/ocs-qconf-${obj_type}.schema.json"
   set common "$sdir/ocs-qconf-common.schema.json"

   set tmpfile [ts_json_write_tmpfile $host $json_text]
   set args "validate -c ajv-formats --spec=draft2020 -s $schema -r $common -d $tmpfile"
   set out [start_remote_prog $host $CHECK_USER "ajv" $args prg_exit_state 60 0 "" "" 0 0 0 0]
   if {$prg_exit_state == 0} {
      return 1
   }
   ts_log_severe "ajv schema validation failed for type \"$obj_type\":\n$out"
   return 0
}

## @brief read a qconf object as JSON into a dict
#
# Runs "qconf -fmt json [-fmtval ...] <show_opt>", parses the result with
# ::json::json2dict and removes the "$schema"/"$id" envelope members.
#
# @param[in]  show_opt    qconf show option incl. name, e.g. "-sp mype"
# @param[out] dict_var    name of a variable that receives the parsed dict
# @param[out] json_var    optional name of a variable that receives the raw JSON text
# @param[in]  fmtval      optional -fmtval value (compact|numeric)
# @param[in]  host        admin host to run on; defaults to a suited admin host
# @param[in]  as_user     user to run as; defaults to CHECK_USER
# @param[in]  raise_error 1 to report errors via ts_log_severe (default)
# @return 0 on success, 1 on error
#
proc get_object_json {show_opt dict_var {json_var ""} {fmtval ""} {host ""} {as_user ""} {raise_error 1}} {
   global ts_config CHECK_USER prg_exit_state
   if {$host == ""} {
      set host [config_get_best_suited_admin_host]
   }
   if {$as_user == ""} {
      set as_user $CHECK_USER
   }
   upvar $dict_var out_dict
   if {$json_var != ""} {
      upvar $json_var out_json
   }

   set opt "-fmt json"
   if {$fmtval != ""} {
      append opt " -fmtval $fmtval"
   }
   append opt " $show_opt"

   set result [start_sge_bin "qconf" $opt $host $as_user]
   if {$prg_exit_state != 0} {
      if {$raise_error} {
         ts_log_severe "qconf $opt failed (exit $prg_exit_state):\n$result"
      }
      return 1
   }
   set out_json $result
   if {[catch {set d [::json::json2dict $result]} err]} {
      if {$raise_error} {
         ts_log_severe "could not parse JSON from \"qconf $opt\": $err\n$result"
      }
      return 1
   }
   set out_dict [dict remove $d "\$schema" "\$id"]
   return 0
}

## @brief modify a qconf object from a JSON document
#
# Writes the document to a tmp file and runs "qconf -fmt json <mod_opt> <file>".
#
# @param[in] mod_opt     qconf modify option, e.g. "-Mp" / "-Mq" / "-Msconf"
# @param[in] json_text   the full JSON document for the object
# @param[in] host        admin host to run on; defaults to a suited admin host
# @param[in] as_user     user to run as; defaults to CHECK_USER
# @param[in] raise_error 1 to report errors via ts_log_severe (default)
# @return 0 on success, 1 on error
#
proc set_object_json {mod_opt json_text {host ""} {as_user ""} {raise_error 1}} {
   global CHECK_USER prg_exit_state
   if {$host == ""} {
      set host [config_get_best_suited_admin_host]
   }
   if {$as_user == ""} {
      set as_user $CHECK_USER
   }
   set tmpfile [ts_json_write_tmpfile $host $json_text]
   set result [start_sge_bin "qconf" "-fmt json $mod_opt $tmpfile" $host $as_user]
   if {$prg_exit_state != 0} {
      if {$raise_error} {
         ts_log_severe "qconf -fmt json $mod_opt failed (exit $prg_exit_state):\n$result"
      }
      return 1
   }
   return 0
}

## @brief canonicalize a plain or json attribute value for comparison
#
# Brings a value produced by the plain parser and a value produced by
# ::json::json2dict into the same form so the two can be compared.
#
# @param[in] kind  - value kind: bool | int | number | list | scalar
# @param[in] value - the value (plain string or json2dict result)
# @return the canonical form of the value
#
proc ts_json_canon {kind value} {
   switch -exact -- $kind {
      bool {
         return [string tolower $value]
      }
      int -
      number {
         return [string trim $value]
      }
      list {
         if {$value eq "" || [string toupper $value] eq "NONE"} {
            return {}
         }
         return [lsort [split $value " ,"]]
      }
      default {
         if {[string toupper $value] eq "NONE"} {
            return ""
         }
         return $value
      }
   }
}

## @brief render a value as a typed JSON literal
#
# @param[in] kind  - value kind: bool | int | number | list | scalar
# @param[in] value - the value to render
# @return the value as a JSON literal (bare number/bool, quoted string, or array)
#
proc ts_json_field_literal {kind value} {
   switch -exact -- $kind {
      bool {
         return [string tolower $value]
      }
      int -
      number {
         return $value
      }
      list {
         if {$value eq "" || [string toupper $value] eq "NONE"} {
            return "\[\]"
         }
         set items {}
         foreach it [split $value " ,"] {
            lappend items "\"$it\""
         }
         return "\[[join $items {, }]\]"
      }
      default {
         return "\"$value\""
      }
   }
}

## @brief set a top-level field in a JSON document
#
# Operates on the pretty-printed qconf JSON, replacing the value of a top-level
# "key": <value> entry. For scalar kinds the value runs up to the next comma or
# newline; for the list kind a (possibly multi-line) [ ... ] array is replaced.
# The regex is brace-quoted and the key spliced in via string map to keep the
# escaping readable.
#
# @param[in] json_text - the JSON document text
# @param[in] key       - the top-level json key whose value is replaced
# @param[in] kind      - value kind (controls the JSON literal type and the match)
# @param[in] value     - the new value
# @return the modified JSON document text
#
proc ts_json_set_field {json_text key kind value} {
   set lit [ts_json_field_literal $kind $value]
   if {$kind eq "list"} {
      # a (possibly multi-line) JSON array: KEY : [ ... ]
      set pat {(KEY[ \t]*:[ \t]*)\[[^\]]*\]}
   } else {
      # a scalar value up to the next comma or newline
      set pat {(KEY[ \t]*:[ \t]*)[^,\n]*}
   }
   set pat [string map [list KEY "\"$key\""] $pat]
   regsub -- $pat $json_text "\\1$lit" json_text
   return $json_text
}

## @brief assert that a top-level json field has the expected JSON type
#
# Checks the raw (pretty-printed) JSON text, not the parsed dict, because
# ::json::json2dict is lossy on types (it cannot tell 5 from "5", true from
# "true"). The type is derived from the attribute kind:
#   int|number -> a bare number              (e.g. 5, not "5")
#   bool       -> a bare true|false          (e.g. true, not "true")
#   list       -> a JSON array               (starts with [ )
#   scalar     -> a primitive (string or number), i.e. not [ and not {
#
# @param[in] json_text - the JSON document text
# @param[in] key       - the top-level json key to inspect
# @param[in] kind      - value kind: int | number | bool | list | scalar
# @param[in] ctx       - optional context string for the failure message
# @return nothing (a wrong type is reported via ts_log_severe)
#
proc ts_json_assert_type {json_text key kind {ctx ""}} {
   set pat {"KEY"[ \t]*:[ \t]*([^\n]*)}
   set pat [string map [list KEY $key] $pat]
   if {![regexp -- $pat $json_text -> rest]} {
      ts_log_severe "json type check $ctx: key \"$key\" not found"
      return
   }
   # the raw value token: trim whitespace and a trailing comma
   set tok [string trim [string trimright [string trim $rest] ","]]
   if {![ts_json_token_kind_ok $tok $kind]} {
      ts_log_severe "json type check $ctx: \"$key\" should be [ts_json_kind_name $kind] but is: $tok"
   }
}

## @brief human-readable name of a value kind (for messages)
#
# @param[in] kind - value kind: int | number | bool | list | scalar
# @return a noun describing the JSON type
#
proc ts_json_kind_name {kind} {
   switch -exact -- $kind {
      int - number { return "a number" }
      bool         { return "a boolean" }
      list         { return "an array" }
      default      { return "a scalar" }
   }
}

## @brief does a raw JSON value token match the expected kind?
#
# The token is the text after "key": up to end of line (whitespace and a
# trailing comma already trimmed). json2dict is lossy on types, so the kind is
# checked against the raw text:
#   int|number -> a bare number              (e.g. 5, not "5")
#   bool       -> a bare true|false          (e.g. true, not "true")
#   list       -> a JSON array               (starts with [ )
#   scalar     -> a primitive, i.e. not [ and not {
#
# @param[in] tok  - the raw value token
# @param[in] kind - value kind: int | number | bool | list | scalar
# @return 1 if the token has the expected JSON type, 0 otherwise
#
proc ts_json_token_kind_ok {tok kind} {
   switch -exact -- $kind {
      int -
      number {
         return [regexp {^-?[0-9][0-9.eE+-]*$} $tok]
      }
      bool {
         return [expr {$tok eq "true" || $tok eq "false"}]
      }
      list {
         return [expr {[string index $tok 0] eq "\["}]
      }
      default {
         # scalar: a primitive (quoted string or bare number), never an array/object
         set c [string index $tok 0]
         return [expr {$c ne "\[" && $c ne "\{"}]
      }
   }
}

## @brief assert that every occurrence of a set of fields is well-typed
#
# Scans the raw JSON text for every "<key>": <token> occurrence of each field
# and asserts the token has the expected kind. Used for the uniform records of
# a JSON array, where each field name repeats once per element.
#
# @param[in] json_text - the JSON document text
# @param[in] fields    - list of {json_key kind} pairs
# @param[in] ctx       - optional context string for failure messages
# @return nothing (wrong types are reported via ts_log_severe)
#
proc ts_json_assert_list_field_types {json_text fields {ctx ""}} {
   foreach fk $fields {
      lassign $fk key kind
      set pat {"KEY"[ \t]*:[ \t]*([^\n]*)}
      set pat [string map [list KEY $key] $pat]
      foreach {full tok} [regexp -all -inline -- $pat $json_text] {
         set tok [string trim [string trimright [string trim $tok] ","]]
         if {![ts_json_token_kind_ok $tok $kind]} {
            ts_log_severe "json type check $ctx: element \"$key\" should be [ts_json_kind_name $kind] but is: $tok"
         }
      }
   }
}

# ============================================================================
# Object attribute engine
# ============================================================================

## @brief set an attribute via the plain format and verify plain + json output
#
# Steps (repeated for every sample value):
#   1. plain modify: set <plain_name>=<value> via cfg(mod_proc) (qconf -M<obj>)
#   2. plain read:   cfg(get_proc), assert the value matches the sample
#   3. json read:    qconf -fmt json -s<obj>, validate against the object schema
#   4. json type:    assert the json value has the expected JSON type (kind)
#   5. compare:      the json value equals the plain value (canonicalized)
#
# @param[in] cfg_var    name of the object config array (see file header)
# @param[in] plain_name attribute name in the plain format / change array
# @param[in] json_key   attribute key in the json output
# @param[in] kind       value kind: int | bool | scalar | list
# @param[in] samples    list of valid values to test
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_attr_io {cfg_var plain_name json_key kind samples} {
   upvar $cfg_var cfg

   foreach value $samples {
      set want [ts_json_canon $kind $value]

      # 1. set via plain
      catch {unset chg}
      set chg($plain_name) $value
      if {[$cfg(mod_proc) $cfg(name) chg 1 $cfg(host) $cfg(user)] != 0} {
         ts_log_severe "plain modify of $cfg(obj_type) attr $plain_name=$value failed"
         continue
      }

      # 2. read via plain
      catch {unset parr}
      $cfg(get_proc) $cfg(name) parr $cfg(host) $cfg(user)
      if {[ts_json_canon $kind $parr($plain_name)] ne $want} {
         ts_log_severe "plain $cfg(obj_type) $plain_name: set \"$value\" but got \"$parr($plain_name)\""
      }

      # 3. read via json + schema validation
      if {[get_object_json $cfg(show_opt) jdict jtext "" $cfg(host) $cfg(user)] != 0} {
         continue
      }
      ts_json_validate $jtext $cfg(obj_type) $cfg(host)

      # 4. the json value has the expected JSON type
      ts_json_assert_type $jtext $json_key $kind "$cfg(obj_type)/$json_key"

      # 5. json value equals plain value
      if {![dict exists $jdict $json_key]} {
         ts_log_severe "json $cfg(obj_type) output is missing key \"$json_key\""
         continue
      }
      if {[ts_json_canon $kind [dict get $jdict $json_key]] ne $want} {
         ts_log_severe "json $cfg(obj_type) $json_key: expected \"$want\" got \"[dict get $jdict $json_key]\""
      }
   }
}

## @brief set an attribute via the json format and verify json + plain output
#
# Steps (repeated for every sample value):
#   1. read current object as json (qconf -fmt json -s<obj>)
#   2. inject the value into the json (ts_json_set_field) and write it back
#      (qconf -fmt json -M<obj>)
#   3. json read-back: assert the value AND the expected JSON type
#   4. plain read-back: assert the value matches (json input == plain view)
#
# Works for scalar, int, bool and list kinds (ts_json_set_field injects the
# typed value, including a JSON array for the list kind).
#
# @param[in] cfg_var    name of the object config array
# @param[in] plain_name attribute name in the plain format
# @param[in] json_key   attribute key in the json output
# @param[in] kind       value kind: int | bool | scalar
# @param[in] samples    list of valid values to test
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_attr_json_in {cfg_var plain_name json_key kind samples} {
   upvar $cfg_var cfg

   foreach value $samples {
      set want [ts_json_canon $kind $value]

      # 1. current object as json
      if {[get_object_json $cfg(show_opt) jdict jtext "" $cfg(host) $cfg(user)] != 0} {
         continue
      }

      # 2. inject value and write back via json
      set newtext [ts_json_set_field $jtext $json_key $kind $value]
      if {[set_object_json $cfg(mod_opt) $newtext $cfg(host) $cfg(user)] != 0} {
         continue
      }

      # 3. json read-back: value and type
      if {[get_object_json $cfg(show_opt) jdict2 jtext2 "" $cfg(host) $cfg(user)] != 0} {
         continue
      }
      ts_json_assert_type $jtext2 $json_key $kind "$cfg(obj_type)/$json_key"
      if {[ts_json_canon $kind [dict get $jdict2 $json_key]] ne $want} {
         ts_log_severe "json-input $cfg(obj_type) $json_key: set \"$value\" but json shows \"[dict get $jdict2 $json_key]\""
      }

      # 4. plain read-back (cross-format consistency of json input)
      catch {unset parr}
      $cfg(get_proc) $cfg(name) parr $cfg(host) $cfg(user)
      if {[ts_json_canon $kind $parr($plain_name)] ne $want} {
         ts_log_severe "json-input $cfg(obj_type) $plain_name: set \"$value\" but plain shows \"$parr($plain_name)\""
      }
   }
}

## @brief verify that the json representation round-trips without change
#
# Steps:
#   1. read the object as json (qconf -fmt json -s<obj>)
#   2. feed exactly that json back in (qconf -fmt json -M<obj>)
#   3. read it again and assert the parsed dict is identical (idempotent input)
#
# @param[in] cfg_var name of the object config array
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_attr_roundtrip {cfg_var} {
   upvar $cfg_var cfg

   if {[get_object_json $cfg(show_opt) d1 t1 "" $cfg(host) $cfg(user)] != 0} {
      return
   }
   if {[set_object_json $cfg(mod_opt) $t1 $cfg(host) $cfg(user)] != 0} {
      return
   }
   if {[get_object_json $cfg(show_opt) d2 t2 "" $cfg(host) $cfg(user)] != 0} {
      return
   }
   if {$d1 ne $d2} {
      ts_log_severe "json round-trip of $cfg(obj_type) \"$cfg(name)\" is not idempotent:\nbefore: $d1\nafter:  $d2"
   }
}

## @brief verify that invalid values are rejected in both formats
#
# Steps (repeated for every invalid value):
#   1. plain modify with the invalid value -> must fail (rejected)
#   2. inject the invalid value into the json and write it back -> must fail
#
# @param[in] cfg_var    name of the object config array
# @param[in] plain_name attribute name in the plain format
# @param[in] json_key   attribute key in the json output
# @param[in] kind       value kind
# @param[in] invalids   list of invalid values that must be rejected
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_attr_negative {cfg_var plain_name json_key kind invalids} {
   upvar $cfg_var cfg

   foreach value $invalids {
      # 1. plain: must be rejected (raise_error 0 so we can inspect the result)
      catch {unset chg}
      set chg($plain_name) $value
      if {[$cfg(mod_proc) $cfg(name) chg 1 $cfg(host) $cfg(user) 0] == 0} {
         ts_log_severe "plain $cfg(obj_type) $plain_name: invalid value \"$value\" was accepted"
      }

      # 2. json: inject and write back, must be rejected
      if {[get_object_json $cfg(show_opt) jdict jtext "" $cfg(host) $cfg(user)] != 0} {
         continue
      }
      set newtext [ts_json_set_field $jtext $json_key $kind $value]
      if {[set_object_json $cfg(mod_opt) $newtext $cfg(host) $cfg(user) 0] == 0} {
         ts_log_severe "json $cfg(obj_type) $json_key: invalid value \"$value\" was accepted"
      }
   }
}

# ============================================================================
# List engine (enveloped JSON arrays: -secl, -s*l, -stl)
# ============================================================================

## @brief validate the JSON output of a list-show switch
#
# Steps:
#   1. read the list as json (qconf -fmt json <show_opt>)
#   2. validate against the object schema (ajv)
#   3. assert the envelope key holds a JSON array
#   4. assert every record field has the expected JSON type
#   5. assert at least lcfg(min_rows) records are present
#
# @param[in] cfg_var name of the list config array (see file header)
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_list_json {cfg_var} {
   upvar $cfg_var cfg

   # 1. read the list as json
   if {[get_object_json $cfg(show_opt) jdict jtext "" $cfg(host) $cfg(user)] != 0} {
      return
   }

   # 2. schema validation
   ts_json_validate $jtext $cfg(obj_type) $cfg(host)

   # 3. the envelope key must be a JSON array
   ts_json_assert_type $jtext $cfg(envelope) list "$cfg(obj_type)/$cfg(envelope)"

   # 4. every record field has the expected JSON type
   ts_json_assert_list_field_types $jtext $cfg(fields) "$cfg(obj_type)"

   # 5. at least min_rows records present
   if {![dict exists $jdict $cfg(envelope)]} {
      ts_log_severe "json $cfg(obj_type): missing envelope key \"$cfg(envelope)\""
      return
   }
   set n [llength [dict get $jdict $cfg(envelope)]]
   if {$n < $cfg(min_rows)} {
      ts_log_severe "json $cfg(obj_type): expected at least $cfg(min_rows) record(s) in \"$cfg(envelope)\" but found $n"
   }
}

## @brief verify the plain (ASCII) list output parses and has the expected rows
#
# Steps:
#   1. run the plain show and parse it via lcfg(plain_proc)
#   2. assert at least lcfg(min_rows) rows were parsed
#
# @param[in] cfg_var name of the list config array
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_list_plain {cfg_var} {
   upvar $cfg_var cfg

   set rows [$cfg(plain_proc) $cfg(host) $cfg(user)]
   if {[llength $rows] < $cfg(min_rows)} {
      ts_log_severe "plain $cfg(obj_type): expected at least $cfg(min_rows) row(s) but parsed [llength $rows]"
   }
}

## @brief cross-check the plain and json list for consistent records
#
# Matches records by lcfg(key_field) and compares every field of the records
# present in BOTH outputs. Matching by key (rather than position or count)
# tolerates transient list members (e.g. a dynamic event client that connects
# or disconnects between the two reads).
#
# Steps:
#   1. read the list as json and as plain text
#   2. index the plain rows by the key field
#   3. for each json record also present in plain, compare every field value
#   4. assert at least lcfg(min_rows) records were matched in both
#
# @param[in] cfg_var name of the list config array
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_list_consistency {cfg_var} {
   upvar $cfg_var cfg
   set keyf $cfg(key_field)

   # 1. json + plain
   if {[get_object_json $cfg(show_opt) jdict jtext "" $cfg(host) $cfg(user)] != 0} {
      return
   }
   set jrows [dict get $jdict $cfg(envelope)]
   set prows [$cfg(plain_proc) $cfg(host) $cfg(user)]

   # 2. index plain rows by key field
   catch {unset pmap}
   array set pmap {}
   foreach pr $prows {
      set pmap([dict get $pr $keyf]) $pr
   }

   # 3. compare every json record that is also present in plain
   set compared 0
   foreach jr $jrows {
      set k [dict get $jr $keyf]
      if {![info exists pmap($k)]} {
         continue
      }
      set pr $pmap($k)
      foreach fk $cfg(fields) {
         lassign $fk key kind
         set jv [dict get $jr $key]
         set pv [dict get $pr $key]
         if {[ts_json_canon $kind $jv] ne [ts_json_canon $kind $pv]} {
            ts_log_severe "list $cfg(obj_type) $keyf=$k field \"$key\": json \"$jv\" vs plain \"$pv\""
         }
      }
      incr compared
   }

   # 4. at least min_rows records matched in both formats
   if {$compared < $cfg(min_rows)} {
      ts_log_severe "list $cfg(obj_type): only $compared record(s) present in both plain and json (expected >= $cfg(min_rows))"
   }
}

# ============================================================================
# Name-list engine (enveloped JSON arrays of bare names: -scall, -spl, ...)
# ============================================================================

## @brief run a name-list show switch in plain format and return the names
#
# The plain output of a name-list switch is simply one name per line (no header).
# Comment lines (starting with '#') are skipped, matching the ASCII shower.
#
# @param[in] cfg_var name of the name-list config array
# @return a list of names (possibly empty)
#
proc ts_namelist_plain_get {cfg_var} {
   upvar $cfg_var cfg
   global CHECK_USER prg_exit_state
   set host $cfg(host)
   if {$host == ""} {
      set host [config_get_best_suited_admin_host]
   }
   set user $cfg(user)
   if {$user == ""} {
      set user $CHECK_USER
   }

   set out [start_sge_bin "qconf" $cfg(show_opt) $host $user]
   if {$prg_exit_state != 0} {
      ts_log_severe "qconf $cfg(show_opt) failed (exit $prg_exit_state):\n$out"
      return {}
   }
   set names {}
   foreach line [split $out "\n"] {
      set line [string trim $line]
      if {$line eq "" || [string index $line 0] eq "#"} {
         continue
      }
      lappend names $line
   }
   return $names
}

## @brief validate the JSON output of a name-list switch
#
# Steps:
#   1. read the list as json (qconf -fmt json <show_opt>)
#   2. validate against the name-list schema (ajv enforces the array-of-strings)
#   3. assert the envelope key holds a JSON array
#   4. assert at least ncfg(min_rows) names are present
#
# @param[in] cfg_var name of the name-list config array (see file header)
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_namelist_json {cfg_var} {
   upvar $cfg_var cfg

   # 1. read the list as json
   if {[get_object_json $cfg(show_opt) jdict jtext "" $cfg(host) $cfg(user)] != 0} {
      return
   }

   # 2. schema validation (the schema's nameList $ref enforces string elements)
   ts_json_validate $jtext $cfg(obj_type) $cfg(host)

   # 3. the envelope key must be a JSON array
   ts_json_assert_type $jtext $cfg(envelope) list "$cfg(obj_type)/$cfg(envelope)"

   # 4. at least min_rows names present
   if {![dict exists $jdict $cfg(envelope)]} {
      ts_log_severe "json $cfg(obj_type): missing envelope key \"$cfg(envelope)\""
      return
   }
   set n [llength [dict get $jdict $cfg(envelope)]]
   if {$n < $cfg(min_rows)} {
      ts_log_severe "json $cfg(obj_type): expected at least $cfg(min_rows) name(s) in \"$cfg(envelope)\" but found $n"
   }
}

## @brief verify the plain (ASCII) name-list output has the expected names
#
# Steps:
#   1. run the plain show and parse the names (one per line)
#   2. assert at least ncfg(min_rows) names were parsed
#
# @param[in] cfg_var name of the name-list config array
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_namelist_plain {cfg_var} {
   upvar $cfg_var cfg

   set names [ts_namelist_plain_get cfg]
   if {[llength $names] < $cfg(min_rows)} {
      ts_log_severe "plain $cfg(obj_type): expected at least $cfg(min_rows) name(s) but parsed [llength $names]"
   }
}

## @brief cross-check that the plain and json name lists are identical (as sets)
#
# Steps:
#   1. read the list as json and as plain text
#   2. assert the two name sets are equal (order-independent)
#
# @param[in] cfg_var name of the name-list config array
# @return nothing (failures are reported via ts_log_severe)
#
proc ts_namelist_consistency {cfg_var} {
   upvar $cfg_var cfg

   if {[get_object_json $cfg(show_opt) jdict jtext "" $cfg(host) $cfg(user)] != 0} {
      return
   }
   set jn [lsort [dict get $jdict $cfg(envelope)]]
   set pn [lsort [ts_namelist_plain_get cfg]]
   if {$jn ne $pn} {
      ts_log_severe "namelist $cfg(obj_type): plain and json differ:\nplain: $pn\njson:  $jn"
   }
}
