# red-shell-unit

Simple TDD framework for Shell "with dominoes and bears"

[![Build Status][build-image]][build-url]
[![Release][release-image]][release-url]

## Core Principles

* Tiny
* _No_ separate API for assertions

Requires Bash v4

## Features

* Isolation of test cases from each other
* Mock API
* Parsable output
* JUnit report format
* Coverage (experimental)

## Setup

```sh
# Framework folder
mkdir "${DIR_OF_YOUR_CHOICE}"
# Download particular version and extract
curl -sL https://github.com/redneckz/red-shell-unit/tarball/"${TAG}" | tar -xzv --strip-components=1 -C "${DIR_OF_YOUR_CHOICE}"
# Add to PATH (or permanently update /etc/environment)
PATH+=:"${DIR_OF_YOUR_CHOICE}"
```

## Usage

add.sh
```sh
#!/usr/bin/env bash

echo $(( $1 + $2 ))
```

add.spec.sh
```sh
#!/usr/bin/env red-shu.sh

it 'should add two numbers'
    # Act
    result=$(run 2 2)
    # Assert
    [[ $result -eq 4 ]]
ti
```

Output
```
$ add.spec.sh
REDSHU CASE 2020-02-24T12:39:01+0300 add.sh 1 should add two numbers
REDSHU PASS 2020-02-24T12:39:02+0300 add.sh 1
```

JUnit
```
$ add.spec.sh | red-shu-2-junit.sh
<testsuites name="CI Tests"><testsuite name="add.sh" tests="1" timestamp="2020-02-24T12:39:43+0300" time="0"><testcase name="add.sh should add two numbers"></testcase></testsuite></testsuites>
```

Run all tests in folder
```sh
$ red-shu-exec.sh --junit ./junit.xml
```

Compute coverage
```sh
$ red-shu-exec.sh --cov
# REDSHU COV 2020-03-05T23:13:22+0300 red-shu-cov.sh 5/5
```

Fail if line coverage level is lower than 70%
```sh
$ red-shu-exec.sh --cov --th 70
# REDSHU COV_FAIL 2020-03-05T23:13:22+0300 red-shu-cov.sh 2/5
```

## Assertions

You can use any commands and bash instructions as assertions for example `grep`, `test` or `diff`.
All commands with exit code different from zero are treated as assertion errors.

Assertion examples:
```sh
# Result equals to expected string
[[ "${result}" == 'expected_string' ]]
# Last command exit code is ok
exit_code=$?
[[ $exit_code -eq 0 ]]
# File exists
[[ -e ./file.txt ]]
# Output contains the expected line
echo "${output}" | grep -x 'expected_line' >/dev/null
# File consists of the expected lines
diff ./file.txt <(printf '%s\n' 'first line' 'second line' 'third line')
```

## Mocks

Default mock:
```sh
mock yarn
```

Mock with custom implementation:
```sh
function yarn() {
    mock::log yarn "$@"
    if [[ "$1" == version ]]; then echo 123; fi
}
```

Example:
```sh
mock yarn # Mock yarn command

yarn version # Execute mocked command
yarn install # Execute it second time

# Assertions
mock::called yarn version # Assert that command was called with particular args
mock::called yarn '.*' # Assert that command was called with any args (RegExp)
[[ $(mock::called_times yarn '.*') -eq 2 ]] # How many times it was called

# Snapshot testing is also available
(mock::snapshot
    yarn version
    yarn install
)
```

### Mock stdin

```
mock::stdin wc
# Act
run
# Assert
mock::consumed wc "some line"
```

[build-image]: https://cloud.drone.io/api/badges/redneckz/red-shell-unit/status.svg
[build-url]: https://cloud.drone.io/redneckz/red-shell-unit
[release-image]: https://img.shields.io/github/v/tag/redneckz/red-shell-unit
[release-url]: https://github.com/redneckz/red-shell-unit/releases
