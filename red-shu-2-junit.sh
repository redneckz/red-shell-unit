#!/usr/bin/env bash

# https://github.com/junit-team/junit5/blob/master/platform-tests/src/test/resources/jenkins-junit.xsd

source red-shu-parser.sh
source sh-xml.sh

REDSHU_TEST_REPORT_TITLE=${REDSHU_TEST_REPORT_TITLE:-Tests}

declare -A test_suites
declare -A test_suites_timestamp
declare -A test_suites_time
declare -A test_cases
declare -A test_cases_failure

function junit::handleCASE() {
    local suite_name="$2"
    local case_n="$3"
    local tests=${test_suites[$suite_name]}
    test_suites[$suite_name]=$(( tests + 1 ))
    test_cases[$suite_name$case_n]="${*:4}"
    junit::register_timestamp "$@"
}

function junit::handlePASS() {
    junit::register_time "$@"
}

function junit::handleFAIL() {
    local suite_name="$2"
    local case_n="$3"
    test_cases_failure[$suite_name$case_n]="${*:4}"
    junit::register_time "$@"
}

function junit::register_timestamp() {
    local timestamp=$1
    local suite_name=$2
    if [[ -z "${test_suites_timestamp[$suite_name]}" ]]; then
        test_suites_timestamp[$suite_name]="${timestamp}"
    fi
}

function junit::register_time() {
    local timestamp="$1"
    local suite_name="$2"
    local start
    start=$(date -d "${test_suites_timestamp[$suite_name]}" +%s)
    local end
    end=$(date -d "${timestamp}" +%s)
    test_suites_time[$suite_name]="$(( end - start ))"
}

function junit::render_report() {
    xml::tag testsuites name "${REDSHU_TEST_REPORT_TITLE}" < <(
        for suite_name in "${!test_suites[@]}"; do
            junit::render_test_suite "$suite_name"
        done
    )
}

function junit::render_test_suite() {
    local suite_name="$1"
    xml::tag testsuite \
        name "$suite_name" \
        tests "${test_suites[$suite_name]}" \
        timestamp "${test_suites_timestamp[$suite_name]}" \
        "time" "${test_suites_time[$suite_name]}" \
        < <(
            junit::render_test_suite_cases "$suite_name"
        )
}

function junit::render_test_suite_cases() {
    local suite_name="$1"
    local tests="${test_suites[$suite_name]}"
    for (( case_n = 1; case_n <= tests; case_n++ )); do
        junit::render_test_case "$suite_name" "$case_n"
    done
}

function junit::render_test_case() {
    local suite_name="$1"
    local case_n="$2"
    local key="$suite_name$case_n"
    local failure="${test_cases_failure[$key]}"
    xml::tag testcase \
        name "$suite_name ${test_cases[$key]}" \
        < <(
            if [[ -n "$failure" ]]; then
                xml::tag failure message "$failure" < <(xml::_)
            fi
        )
}

redshu::parser::trap junit::handleCASE CASE
redshu::parser::trap junit::handlePASS PASS
redshu::parser::trap junit::handleFAIL FAIL

redshu::parser::parse
junit::render_report
