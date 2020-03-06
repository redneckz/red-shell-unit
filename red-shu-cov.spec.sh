#!/usr/bin/env red-shu.sh

source red-shu-cov.sh

function lines() {
    printf '%s\n' "$@"
}

function cmd_src() {
    lines \
        'echo 123' \
        'if [[ -z "${REDSHU_COV_TH}" ]]; then' \
            'echo 456' \
        'fi' \
        'echo 789'
}

it cov::apply should transparently instrument supplied command
    # Arrange
    cov::setup
    # Act
    cmd=$(cov::apply <(cmd_src))
    # Assert
    diff <(eval "${cmd}") <(lines '123' '456' '789')
    # Cleanup
    cov::teardown
ti

it cov::lines should return number of covered lines
    # Arrange
    cov::setup
    cmd=$(cov::apply <(cmd_src))
    # Act
    eval "${cmd}" >/dev/null
    lines=$(cov::lines)
    # Assert
    [[ $lines -eq 5 ]]
    # Cleanup
    cov::teardown
ti

it cov::assert should exit with zero if no threshold configured
    # Arrange
    export REDSHU_COV=true
    cov::setup
    cmd=$(cov::apply <(cmd_src))
    # Act
    eval "${cmd}" >/dev/null
    # Assert
    cov::assert <(echo "${cmd}")
    # Cleanup
    cov::teardown
ti

it cov::assert should exit with 2 if coverage is lower than threshold
    # Arrange
    export REDSHU_COV=true
    export REDSHU_COV_TH=$(( 4 * 100 / 5 ))
    cov::setup
    cmd=$(cov::apply <(cmd_src))
    # Act
    eval "${cmd}" >/dev/null
    # Assert
    cov::assert <(echo "${cmd}") || exit_code=$?
    [[ $exit_code -eq 2 ]]
    # Cleanup
    cov::teardown
ti
