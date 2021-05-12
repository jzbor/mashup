#!/bin/sh
#
# author: jzbor
#

CC_BLUE="\e[0;94m"
CC_GREEN="\e[0;92m"
CC_RED="\e[0;91m"
CC_WHITE="\e[0;97m"
CC_BLUE_BG="\e[0;104m${expand_bg}"
CC_EXPAND_BG="\e[K"
CC_GREEN_BG="\e[0;102m${expand_bg}"
CC_RED_BG="\e[0;101m${expand_bg}"
CC_BOLD="\e[1m"
CC_RESET="\e[0m"
CC_ULINE="\e[4m"

die () {
    printf "$CC_RED%s$CC_RESET\n" "$1" > /dev/stderr
    exit 1
}

check_dependencies () {
    for dep in "$@"; do
        command -v "$dep" > /dev/null \
            || die "Dependency $1 not installed"
    done
}

check_optional_dependency () {
    if ! command -v "$1" > /dev/null; then
        printf "$CC_RED%s not found.$CC_RESET\n" "$1" > /dev/stderr
        [ -n "$2" ] \
            && printf "$CC_RED%s is required for: %s$CC_RESET\n" "$1" "$2" > /dev/stderr
        return 1
    fi
    return 0
}

check_optional_dependencies_quiet () {
    for dep in "$@"; do
        command -v "$dep" > /dev/null \
            || return 1
    done
}

env_is_set () {
    env | grep "^$1=" > /dev/null
}

# for settings that default to false
env_def_false () {
    env_is_set "$1" && [ "$(eval echo "\$$1")" = "1" ]
}

# for settings that default to true
env_def_true () {
    (! env_is_set "$1") || [ "$(eval echo "\$$1")" = "1" ]
}

load_file () {
    FILE=$(readlink -f "$1" 2> /dev/null)
    FILEDIR=$(dirname "$FILE")
    FILENAME=$(basename "$FILE")
    BASENAME="${FILENAME%.*}"
}

check_file () {
    [ -n "${FILE:-$1}" ] || die "No file specified"
    [ -e "${FILE:-$1}" ] || die "File '${FILE:-$1}' not found"
    [ -f "${FILE:-$1}" ] || die "'${FILE:-$1}' is not a file"
}

print_header () {
    printf "\n$CC_BLUE=== %s ===$CC_RESET\n" "$1"
}

print_help () {
    print_header "Help: $(basename "$0")"
    printf "\n%s\n\n" "$HELPTEXT" | fmt
}
