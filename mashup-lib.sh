#!/bin/sh

die () {
    echo "$1" > /dev/stderr
    exit 1
}

check_dependency () {
    command -v "$1" > /dev/null \
        || die "Dependency $1 not installed"
}

check_optional_dependency () {
    command -v "$1" > /dev/null
}

