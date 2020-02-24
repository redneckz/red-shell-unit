#!/usr/bin/env bash

function mock::setup() {
    CMD_MOCKS_LOG=$(mktemp)
}

function mock::teardown() {
    rm -f "${CMD_MOCKS_LOG}"
}

function mock() {
    local cmd_name="$1"
    eval "function ${cmd_name}() { mock::log ${cmd_name} " '"$@"; }'
}

function mock::log() {
    echo mock "$@" >> "${CMD_MOCKS_LOG}"
}

function mock::reset() {
    true > "${CMD_MOCKS_LOG}"
}

function mock::called() {
    [[ $(mock::called_times "$@") -gt 0 ]]
}

function mock::called_times() {
    local cmd_with_args="$*"
    grep -c -x "mock ${cmd_with_args}" -- "${CMD_MOCKS_LOG}"
}

function mock::snapshot() {
    # Should be executed in sub-process
    CMD_SNAP_LOG="${CMD_MOCKS_LOG}"
    CMD_MOCKS_LOG=$(mktemp)
    trap 'diff -bB "${CMD_SNAP_LOG}" "${CMD_MOCKS_LOG}"; DIFF_RES=$?; rm -f "${CMD_MOCKS_LOG}"; exit $DIFF_RES' EXIT
}
