#!/bin/sh

if [ -n "$2" ]; then
    RPM_ARCH="$2"
    if [ "$RPM_ARCH" = "i386" ]; then
        PKG_ARCH="i686"
        PKG_REPO="fedora-secondary"
    else
        PKG_ARCH="$RPM_ARCH"
        RPM_REPO="fedora"
    fi
else
    if [ "$(uname -m)" = "amd64" ]; then
        RPM_ARCH="x86_64"
        PKG_ARCH="x86_64"
        RPM_REPO="fedora"
    else
        RPM_ARCH="i386"
        PKG_ARCH="i686"
        RPM_REPO="fedora-secondary"
    fi
fi

RPM_URL="https://www.rpmfind.net/linux/${RPM_REPO}/linux/releases/26/Everything/${RPM_ARCH}/os/Packages/v/vboot-utils-20170302-1.gita1c5f7c.fc26.${PKG_ARCH}.rpm"

INSTALL_PREFIX="$HOME/bin"
if [ -n "$1" ]; then
    INSTALL_PREFIX="$1"
fi

if [ ! -x "$(command -v wget)" ]; then
    echo "Wget is not installed, exitting..."
    exit 1
fi

RPM_DIR="$(mktemp -d unpack-XXXXXXXX)"
cd "$RPM_DIR"

echo "Downloading vboot-utils..."
wget "$RPM_URL" -O "vboot-utils.rpm"
if [ $? -ne 0 ]; then
    echo "Wget failed, exitting..."
    cd ..
    rm -rf "$RPM_DIR"
    exit 1
fi

echo "Unpacking vboot-utils..."
tar xf "vboot-utils.rpm"
if [ $? -ne 0 ]; then
    echo "Package unpack failed, exitting..."
    cd ..
    rm -rf "$RPM_DIR"
    exit 1
fi

echo "Installing futility..."
cp usr/bin/futility "$INSTALL_PREFIX"
if [ $? -ne 0 ]; then
    echo "Installation failed, exitting..."
    cd ..
    rm -rf "$RPM_DIR"
    exit 1
fi

echo "Cleaning up..."
cd ..
rm -rf "$RPM_DIR"

echo "Done, futility installed in '$INSTALL_PREFIX'."
