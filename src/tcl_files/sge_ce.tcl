#___INFO__MARK_BEGIN_NEW__
#___INFO__MARK_END_NEW__

proc ce_add {{change_array_name ""} {fast 1} {on_host ""} {as_user ""} {raise_error 1}} {
    upvar $change_array_name change_array
    ce_get_messages messages "add" "$change_array(name)" $on_host $as_user

    # prepare command and options
    if {$fast == 1} {
        set option "-Ace"
    } else {
        set option "-ace $change_array(name)"
    }
    if {$fast == 1} {
        # set defaults and overwrite some with values given by caller
        ce_set_defaults ce_array
        update_change_array ce_array change_array

        # create a temp-file with the centry
        set tmp_file [dump_array_to_tmpfile ce_array]

        # trigger the change
        set result [start_sge_bin "qconf" "${option} ${tmp_file}" $on_host $as_user]
    } else {
        set vi_commands [build_vi_command change_array]
        set result [start_vi_edit "qconf" $option $vi_commands messages $on_host $as_user]
    }

    # evaluate message and return
    return [handle_sge_errors "ce_add" "qconf $option" $result messages $raise_error ""]
}

proc ce_del {ce_name {on_host ""} {as_user ""} {raise_error 1}} {
    ce_get_messages messages "del" $ce_name $on_host $as_user

    # trigger command
    set output [start_sge_bin "qconf" "-dce $ce_name" $on_host $as_user]

    # evaluate message and return
    return [handle_sge_errors "ce_del" "qconf -dce $ce_name" $output messages $raise_error "" {}]
}

proc ce_exists {ce_name} {
    ce_get_list ce_list

    set ret [lsearch $ce_list $ce_name]
    if {$ret == -1} {
        return 0
    } else {
        return 1
    }
}

proc ce_get {ce_name {output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
    upvar $output_var out
    ce_get_messages messages "get" "$ce_name" $on_host $as_user

    # evaluate message and return
    return [get_qconf_object "ce_get" "-sce $ce_name" out messages 0 $on_host $as_user $raise_error]
}

proc ce_get_list {{output_var result} {on_host ""} {as_user ""} {raise_error 1}} {
    upvar $output_var out
    ce_get_messages messages "list" "" $on_host $as_user

    return [get_qconf_object "ce_get_list" "-scel" out messages 1 $on_host $as_user $raise_error]
}

proc ce_get_messages {msg_var action obj_name {on_host ""} {as_user ""}} {
   upvar $msg_var messages
   unset -nocomplain messages

   sge_client_messages messages $action "CE attr" $obj_name $on_host $as_user

   add_message_to_container messages 1 [translate_macro MSG_SGETEXT_ADDEDTOLIST_SSSS "*" "*" "*" "*"]
   add_message_to_container messages 2 [translate_macro MSG_SGETEXT_MODIFIEDINLIST_SSSS "*" "*" "*" "*"]
   add_message_to_container messages 3 [translate_macro MSG_SGETEXT_REMOVEDFROMLIST_SSSS "*" "*" "*" "*"]
   add_message_to_container messages 4 [translate_macro MSG_CENTRY_NOTCHANGED]

   add_message_to_container messages -1 [translate_macro MSG_CENTRYREFINHOST_SS "*" "*"]
   add_message_to_container messages -2 [translate_macro MSG_CENTRYREFINQUEUE_SS "*" "*"]
   add_message_to_container messages -3 [translate_macro MSG_CENTRYREFINRQS_SS "*" "*"]
   add_message_to_container messages -4 [translate_macro MSG_CENTRYREFINSCONF_S "*"]
   add_message_to_container messages -5 [translate_macro MSG_CENTRY_NULL_URGENCY]
   add_message_to_container messages -6 [translate_macro MSG_INVALID_CENTRY_DEFAULT_S "*"]
}

proc ce_mod {ce_array_name {fast 1} {on_host ""} {as_user ""} {raise_error 1}} {
    upvar $ce_array_name ce_array
    ce_get_messages messages "mod" "$ce_array(name)" $on_host $as_user

    # prepare command and options
    if {$fast} {
        set option "-Mce"
    } else {
        set option "-mce"
    }

    if {$fast} {
        # set defaults and overwrite some with values given by caller
        ce_get "$ce_array(name)" old_ce_array "" "" 0
        if {![info exists old_ce_array]} {
            ce_set_defaults old_ce_array
        }
        update_change_array old_ce_array ce_array

        # create a temp-file with the centry
        set tmp_file [dump_array_to_tmpfile old_ce_array]

        # trigger the change
        set result [start_sge_bin "qconf" "$option $tmp_file" $on_host $as_user]
    } else {
        # trigger the change
        set vi_commands [build_vi_command ce_array]
        set result [start_vi_edit "qconf" "$option $ce_array(name)" $vi_commands messages $on_host $as_user]
    }

    # evaluate message and return
    set ret [handle_sge_errors "ce_mod" "qconf $option $ce_array(name)" $result messages $raise_error ""]
    return $ret
}

proc ce_set_defaults {array_name} {
    get_current_cluster_config_array ts_config
    upvar $array_name ce_array

    set ce_array(name)        "temp"
    set ce_array(shortcut)    "temp_shortcut"
    set ce_array(type)        "RESTRING"
    set ce_array(relop)       "=="
    set ce_array(requestable) "YES"
    set ce_array(consumable)  "NO"
    set ce_array(default)     "NONE"
    set ce_array(urgency)     "0"
}

