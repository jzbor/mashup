#!/bin/sh

PREFIX="${PREFIX:-$HOME/.local}"

# input variables
ALL=0
INSTALL=0
UNINSTALL=0

die () {
    echo "$1" > /dev/stderr
    exit 1
}

install_all () {
    for util in $utils; do
        install_util "$util"
    done
}

install_util () {
    printf "Installing %s... " "$1"
    install -Dm 755 "$1" "$PREFIX/bin/" \
        || die "unable to install $util"
    printf "Done\n"
}

uninstall_all () {
    for util in $utils; do
        uninstall_util "$util"
    done
}

uninstall_util () {
    printf "Uninstalling %s... " "$1"

    if ! [ -f "${PREFIX:?}/bin/$1" ]; then
        printf "Not found\n"
        return
    fi

    rm -f "${PREFIX:?}/bin/$1" \
        || die "unable to uninstall $util"
    printf "Done\n"
}


# set right working directory
cd "$(dirname "$0")" || die "Unable to cd into directory"
utils="$(find utils/* -type f)"

# parse arguments
while :; do
    case $1 in
        -a | --all) ALL=1; shift ;;
        -i | --install) INSTALL=1; shift ;;
        -r | --remove) UNINSTALL=1; shift ;;
        *) break ;;
    esac
done

if [ "$INSTALL" = 1 ]; then
    if [ "$ALL" = 1 ]; then
        install_all
    else
        for util in "$@"; do
            install_util "$util"
        done
    fi
elif [ "$UNINSTALL" = 1 ]; then
    if [ "$ALL" = 1 ]; then
        uninstall_all
    else
        for util in "$@"; do
            uninstall_util "$util"
        done
    fi
else
    die "No actions specified"
fi


