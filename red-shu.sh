#!/usr/bin/env bash
set +e

if realpath "$0" &>/dev/null; then
    # Add framework folder to PATH
    RED_SHU=$(realpath "$0")
    RED_SHU_DIR=$(dirname "$RED_SHU")
    PATH+=":${RED_SHU_DIR}";
fi

if [[ "$1" =~ ^/ ]]; then # Already real path
    SPEC_SOURCE="$1"
else
    SPEC_SOURCE=$(realpath "$1")
fi
CMD="${SPEC_SOURCE/.spec.sh/.sh}"

source red-shu-internals.sh
source red-shu-mock.sh

redshu::setup; mock::setup
trap 'redshu::teardown; mock::teardown' EXIT

export CASE_N=0
export CASE_FAIL_COUNT=0

function log() {
    local event_type=$1
    shift
    local requirement="$*"
    redshu::log "$event_type" "${CASE_N}" "${requirement}"
}

function it() {
    CASE_N=$(( CASE_N + 1 ))
    log CASE "$*"
    mock::reset
}

function ti() {
    if redshu::has_failures; then
        CASE_FAIL_COUNT=$(( CASE_FAIL_COUNT + 1 ))
        redshu::failures log FAIL
    else
        log PASS
    fi
}

function run() {
    (source "${CMD}")
}

source <(red-shu-isolate.sh "${SPEC_SOURCE}")

[[ ${CASE_FAIL_COUNT} -eq 0 ]] # In case of success exit with zero
