#!/usr/bin/env bash

function cov::setup() {
    COV_TEMP=$(mktemp)
}

function cov::teardown() {
    rm -f "${COV_TEMP}"
}

function cov::apply() {
    local cmd="$1"
    while IFS= read -r line; do
        echo '(echo "${LINENO}" >> "${COV_TEMP}");' "${line}"
    done < "${cmd}"
}

function cov::lines() {
    sort "${COV_TEMP}" | uniq | wc -l
}

function cov::assert() {
    local cmd="$1"
    if [[ -z "${REDSHU_COV}" ]]; then return 0; fi
    local covered_lines
    covered_lines=$(cov::lines)
    local total_lines
    total_lines=$(wc -l < "${cmd}")
    if [[ -z "${REDSHU_COV_TH}" || $(( covered_lines * 100 )) -gt $(( REDSHU_COV_TH * total_lines )) ]]; then
        redshu::log COV "${covered_lines}/${total_lines}"
        return 0
    else
        redshu::log COV_FAIL "${covered_lines}/${total_lines}"
        return 2 # Coverage threshold error code
    fi
}
