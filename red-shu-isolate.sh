#!/usr/bin/env bash

SPEC_SOURCE="$1"

ASSERTIONS_TRAP="trap 'redshu::assert' ERR"
IT_REGEXP='^[ ]*it[ ]?[^;]*$'
TI_REGEXP='^[ ]*ti[ ]*$'

while IFS= read -r line; do
    if [[ "${line}" =~ $IT_REGEXP ]]; then
        echo "${line}; (${ASSERTIONS_TRAP}"
    elif [[ "${line}" =~ $TI_REGEXP ]]; then
        echo "); ${line}"
    else
        echo "${line}"
    fi
done < "${SPEC_SOURCE}"
