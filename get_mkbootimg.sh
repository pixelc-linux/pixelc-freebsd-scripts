#!/bin/sh

REPO_PATH="https://github.com/pixelc-linux/mkbootimg.git"
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

if [ ! -d "mkbootimg" ]; then
    if [ ! -x "$(command -v git)" ]; then
        echo "git not found, exitting..."
        exit 1
    fi
    echo "Getting the sources..."
    git clone "$REPO_PATH" mkbootimg
    if [ $? -ne 0 ]; then
        echo "git failed, exitting..."
        exit 1
    fi
fi

cd mkbootimg
"$MAKE" clean
"$MAKE" "$@"
if [ $? -ne 0 ]; then
    echo "$MAKE failed, exitting..."
fi

cp mkbootimg "$INSTALL_PREFIX"
if [ $? -eq 0 ]; then
    cp unpackbootimg "$INSTALL_PREFIX"
fi
if [ $? -ne 0 ]; then
    echo "Installation failed, exitting..."
    "$MAKE" clean
    exit 1
fi

echo "Cleaning up..."
"$MAKE" clean

echo "Done, mkbootimg and unpackbootimg installed in '$INSTALL_PREFIX'."
