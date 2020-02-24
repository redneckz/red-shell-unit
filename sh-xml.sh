#!/usr/bin/env bash

function xml::escape() {
    local result="${*//\"/&quot;}"
    result="${result//\</&lt;}"
    result="${result//\>/&gt;}"
    echo "${result}"
}

function xml::tag() {
    local tag="$1"
    shift
    local attrs=()
    local attr_name
    local attr_val
    while [[ $# -gt 0 ]]; do
        attr_name="$1"
        attr_val=$(xml::escape "$2")
        attrs+=("${attr_name}=\"${attr_val}\"")
        shift 2
    done
    local body
    body=$(cat -)
    echo "<${tag} ${attrs[*]}>${body}</${tag}>"
}

function xml::_() { return 0; }
