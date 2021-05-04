#!/bin/sh

PREFIX="${PREFIX:-$HOME/.local}"
LIB_FILE_LOCAL="mashup-lib.sh"
LIB_FILE="${PREFIX}/lib/${LIB_FILE_LOCAL}"

# input variables
ALL=0
INSTALL=1
UNINSTALL=0
LIBRARY=0

die () {
    echo "$1" > /dev/stderr
    exit 1
}

install_all () {
    for util in $utils; do
        install_util "$util"
    done
}

install_lib () {
    printf "Installing lib file %s... " "$LIB_FILE_LOCAL"
    install -Dm 555 "$LIB_FILE_LOCAL" "$LIB_FILE"
    printf "Done\n"
}

install_util () {
    name="$(basename "$1")"
    printf "Installing %s... " "$name"
    install -Dm 755 "$1" "$PREFIX/bin/" \
        || die "unable to install $util"
    sed -i "s|__LIB_FILE__|${LIB_FILE}|g" "$PREFIX/bin/$name"
    printf "Done\n"
}

print_help () {
    echo "Install mashup utils

-a  --all       Add all utils to targets
-i  --install   Install util(s)
-r  --remove    Remove/uninstall util(s)
-l  --library   Add library to targets"
}

uninstall_all () {
    for util in $utils; do
        uninstall_util "$util"
    done
}

uninstall_lib () {
    printf "Uninstalling lib file %s... " "$LIB_FILE_LOCAL"
    rm -f "$LIB_FILE"
    printf "Done\n"
}

uninstall_util () {
    name="$(basename "$1")"
    printf "Uninstalling %s... " "$name"
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
        -h | --help) print_help; exit ;;
        -i | --install) INSTALL=1; shift ;;
        -l | --library) LIBRARY=1; shift ;;
        -r | --remove) UNINSTALL=1; shift ;;
        *) break ;;
    esac
done

if [ "$INSTALL" = 1 ]; then
    if [ "$ALL" = 1 ]; then
        install_all
        install_lib
    else
        for util in "$@"; do
            install_util "$util"
        done
        [ "$LIBRARY" = 1 ] && install_lib
    fi
elif [ "$UNINSTALL" = 1 ]; then
    if [ "$ALL" = 1 ]; then
        uninstall_all
        uninstall_lib
    else
        for util in "$@"; do
            uninstall_util "$util"
        done
        [ "$LIBRARY" = 1 ] && uninstall_lib
    fi
else
    die "No actions specified"
fi


