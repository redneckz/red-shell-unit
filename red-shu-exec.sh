#!/usr/bin/env bash

export REDSHU_TEST_REPORT_TITLE=Tests
export REDSHU_COV=
export REDSHU_COV_TH=

while [[ $# -gt 0 ]]; do
    case "$1" in
        --junit)
            JUNIT="$2"
            shift 2
            ;;
        --title)
            REDSHU_TEST_REPORT_TITLE="$2"
            shift 2
            ;;
        --cov)
            REDSHU_COV=true
            shift
            ;;
        --th)
            REDSHU_COV_TH="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

function redshu::exec() {
    find . -name "*.spec.sh" | sh
}

if [[ -n "${JUNIT}" ]]; then
    redshu::exec | tee >(red-shu-2-junit.sh > "${JUNIT}")
else
    redshu::exec
fi
