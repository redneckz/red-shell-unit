#!/usr/bin/env bash

SHORT_CMD=$(basename "${CMD}")

function redshu::setup() {
    CASE_FAILURES_TEMP=$(mktemp)
}

function redshu::teardown() {
    rm -f "${CASE_FAILURES_TEMP}"
}

function redshu::log() {
    local event_type=$1
    shift
    local rest="$@"
    local timestamp
    timestamp=$(date +%Y-%m-%dT%H:%M:%S%z)
    echo REDSHU "$event_type" "${timestamp}" "${SHORT_CMD}" "$@"
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
