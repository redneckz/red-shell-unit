#!/usr/bin/env bash

function redshu::setup() {
    CASE_FAILURES_TEMP=$(mktemp)
}

function redshu::teardown() {
    rm -f "${CASE_FAILURES_TEMP}"
}

function redshu::has_failures() {
    [[ -s ${CASE_FAILURES_TEMP} ]]
}

function redshu::failures() {
    while read -r failure; do "$@" "${failure}"; done < "${CASE_FAILURES_TEMP}"
    true > "${CASE_FAILURES_TEMP}"
}

function redshu::assert() {
    local exit_code=$?
    local last_cmd="${BASH_COMMAND}"
    if [[ $exit_code -ne 0 ]]; then
        echo "${last_cmd}" >> "${CASE_FAILURES_TEMP}"
    fi
}

function redshu::isolate_test_cases() {
    local assertions_trap="trap 'redshu::assert' ERR"
    local it_regexp='^[ ]*it[ ]?[^;]*$'
    local ti_regexp='^[ ]*ti[ ]*$'

    while IFS= read -r line; do
        if [[ "${line}" =~ $it_regexp ]]; then
            echo "${line}; (${assertions_trap}"
        elif [[ "${line}" =~ $ti_regexp ]]; then
            echo "); ${line}"
        else
            echo "${line}"
        fi
    done < "$1"
}
