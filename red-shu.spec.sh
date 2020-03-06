#!/usr/bin/env red-shu.sh

function spec() {
    output=$(run <(cat "$@"))
    exit_code=$?
}

it should accept path to specification as the only argument
    # Act
    spec <<EOF
# No cases
EOF
    # Assert
    [[ $exit_code -eq 0 ]]
ti

it should fail if specification exits with assertion errors
    # Act
    spec <<EOF
it should fail
    [[ ABC == abc ]]
ti
EOF
    # Assert
    [[ $exit_code -eq 1 ]]
ti

it should output parsable lines REDSHU CASE for each requirement
    # Act
    spec <<EOF
it should be first
    # Arrange, Act, Assert
ti
it should be second
    # Arrange, Act, Assert
ti
it should be third
    # Arrange, Act, Assert
ti
EOF
    # Assert
    [[ $(echo "${output}" | grep -cx 'REDSHU CASE .*') -eq 3 ]]
ti

it should output parsable lines REDSHU PASS for each passed requirement
    # Act
    spec <<EOF
it should be successful
    # Arrange, Act, Assert
ti
EOF
    # Assert
    echo "${output}" | grep -x 'REDSHU PASS .*' >/dev/null
ti

it should output parsable lines REDSHU FAIL for each failed requirement
    # Act
    spec <<EOF
it should fail
    false
ti
EOF
    # Assert
    echo "${output}" | grep -x 'REDSHU FAIL .*' >/dev/null
ti
