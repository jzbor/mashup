#!/bin/sh

LOCAL_DIR="$(dirname $0)"
LIB_FILE_NAME="mashup-lib.sh"
LIB_FILE_LOCAL="${LOCAL_DIR}/${LIB_FILE_NAME}"
UTILS="$(find "${LOCAL_DIR}/utils/" -type f)"

PREFIX="${PREFIX:-$HOME/.local}"
LIB_FILE="${PREFIX}/lib/${LIB_FILE_NAME}"

# input variables
ALL=0
INSTALL=1
UNINSTALL=0
LIBRARY=0
STANDALONE=0
FMUTILS=0

die () {
    echo "$1" > /dev/stderr
    exit 1
}

install_all () {
    for util in $UTILS; do
        install_util "$util"
    done
}

install_fmutils () {
    for fmutil in $(find "$LOCAL_DIR/fmutils/" -executable -type f); do
        install_util "$fmutil"
    done
    for manpage in $(find "$LOCAL_DIR/fmutils/" -name *.1); do
        printf "Installing manpage: %s... " "$manpage"
        install -Dm 644 "$manpage" "$PREFIX/share/man/man1/"
        printf "Done\n"
    done
}

install_lib () {
    printf "Installing lib file %s... " "$LIB_FILE_NAME"
    install -Dm 644 "$LIB_FILE_LOCAL" "$LIB_FILE"
    printf "Done\n"
}

install_util () {
    name="$(basename "$1")"
    printf "Installing %s... " "$name"
    install -Dm 755 "$1" "$PREFIX/bin/" \
        || die "unable to install $util"
    if [ "$STANDALONE" = 1 ]; then
        sed -i -e "/__LIB_FILE__/r ${LIB_FILE_LOCAL}" -e '//d' "$PREFIX/bin/$name"
    else
        sed -i "s|__LIB_FILE__|${LIB_FILE}|g" "$PREFIX/bin/$name"
    fi
    printf "Done\n"
}

print_help () {
    echo "Install mashup utils

-a  --all           Add all (regular) utils to targets
-f  --fmutils       Add fmutils to targets
-h  --help          This help message
-i  --install       Install util(s)
-l  --library       Add library to targets
-r  --remove        Remove/uninstall util(s)
-s  --standalone    Compile library into each script "
}

uninstall_all () {
    for util in $UTILS; do
        uninstall_util "$util"
    done
}

uninstall_fmutils() {
    for fmutil in $(find "$LOCAL_DIR/fmutils/" -executable -type f); do
        uninstall_util "$fmutil"
    done
}

uninstall_lib () {
    printf "Uninstalling lib file %s... " "$LIB_FILE_NAME"
    rm -f "$LIB_FILE"
    printf "Done\n"
}

uninstall_util () {
    name="$(basename "$1")"
    printf "Uninstalling %s... " "$name"
    if ! [ -f "${PREFIX:?}/bin/$name" ]; then
        printf "Not found\n"
        return
    fi

    rm -f "${PREFIX:?}/bin/$name" \
        || die "unable to uninstall $name"
    printf "Done\n"
}



# parse arguments
while :; do
    case $1 in
        -a | --all) ALL=1; shift ;;
        -f | --fmuils) FMUTILS=1; shift ;;
        -h | --help) print_help; exit ;;
        -i | --install) INSTALL=1; UNINSTALL=0; shift ;;
        -l | --library) LIBRARY=1; shift ;;
        -r | --remove) UNINSTALL=1; INSTALL=0; shift ;;
        -s | --standalone) STANDALONE=1; shift ;;
        *) break ;;
    esac
done

if [ "$INSTALL" = 1 ]; then
    if [ "$ALL" = 1 ]; then
        install_all
        [ "$STANDALONE" = 1 ] \
            || install_lib
    else
        for util in "$@"; do
            install_util "$util"
        done
        [ "$LIBRARY" = 1 ] && install_lib
    fi
    [ "$FMUTILS" = 1 ] && install_fmutils
elif [ "$UNINSTALL" = 1 ]; then
    if [ "$ALL" = 1 ]; then
        uninstall_all
        [ "$STANDALONE" = 1 ] \
            || uninstall_lib
    else
        for util in "$@"; do
            uninstall_util "$util"
        done
        [ "$LIBRARY" = 1 ] && uninstall_lib
    fi
    [ "$FMUTILS" = 1 ] && uninstall_fmutils
else
    die "No actions specified"
fi


