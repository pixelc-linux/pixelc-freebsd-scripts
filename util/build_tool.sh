#!/bin/sh

MAKE="gmake"

INSTALL_PREFIX="$HOME/bin"
if [ -n "$1" ]; then
    INSTALL_PREFIX="$1"
fi
shift

if [ ! -d "$INSTALL_PREFIX" ]; then
    echo "Install prefix not found, exitting..."
    exit 1
fi

if [ ! -x "$(command -v $MAKE)" ]; then
    echo "$MAKE not found, exitting..."
    exit 1
fi

get_repo() {
    URL="$1"
    DIR="$2"
    if [ ! -d "$DIR" ]; then
        if [ ! -x "$(command -v git)" ]; then
            echo "git not found, exitting..."
            exit 1
        fi
        echo "Getting the sources for ${DIR}..."
        git clone "$URL" "$DIR"
        if [ $? -ne 0 ]; then
            echo "git failed, exitting..."
            exit 1
        fi
    fi
}

build() {
    DIR="$1"
    shift
    cd "$DIR"
    echo "Building ${DIR}..."
    "$MAKE" clean
    "$MAKE" "$@"
    if [ $? -ne 0 ]; then
        echo "$MAKE failed, exitting..."
        "$MAKE" clean
        exit 1
    fi
    cd ..
}

install() {
    DIR="$1"
    BIN="$2"
    PREFIX="$3"
    echo "Installing ${DIR}/${BIN} into ${PREFIX}..."
    cp "${DIR}/${BIN}" "$PREFIX"
    if [ $? -ne 0 ]; then
        echo "Installation failed, exitting..."
        "$MAKE" clean
        exit 1
    fi
    echo "Installed."
}
