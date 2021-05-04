#!/bin/sh

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

check_dependency () {
    command -v "$1" > /dev/null \
        || die "Dependency $1 not installed"
}

check_optional_dependency () {
    command -v "$1" > /dev/null
}

print_header () {
    printf "$CC_BLUE=== %s ===$CC_RESET\n" "$1"
}

print_help () {
    printf "\n"
    print_header "Help: $(basename "$0")"
    printf "\n%s\n\n" "$HELPTEXT"
}
