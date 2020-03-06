#!/usr/bin/env bash

function redshu::parser::noop() { return 0; }

declare -A REDSHU_PARSER_TRAPS
REDSHU_PARSER_TRAPS[CASE]=redshu::parser::noop
REDSHU_PARSER_TRAPS[PASS]=redshu::parser::noop
REDSHU_PARSER_TRAPS[FAIL]=redshu::parser::noop
REDSHU_PARSER_TRAPS[COV]=redshu::parser::noop
REDSHU_PARSER_TRAPS[COV_FAIL]=redshu::parser::noop

export REDSHU_PARSER_TRAPS

function redshu::parser::trap() {
    REDSHU_PARSER_TRAPS["$2"]="$1"
}

function redshu::parser::parse() {
    while read -r -a fields; do
        if [[ "${fields[0]}" != "REDSHU" ]]; then continue; fi
        local event_type="${fields[1]}"
        "${REDSHU_PARSER_TRAPS["${event_type}"]}" "${fields[@]:2}"
    done
}
