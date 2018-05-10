#!/bin/sh

ARCHIVE_BINUTILS="binutils-2.30.tar.xz"
ARCHIVE_GCC="gcc-8.1.0.tar.xz"
ARCHIVE_GMP="gmp-6.1.2.tar.xz"
ARCHIVE_MPFR="mpfr-4.0.1.tar.xz"
ARCHIVE_MPC="mpc-1.1.0.tar.gz"
ARCHIVE_BC="bc-1.07.1.tar.gz"
ARCHIVE_ISL="isl-0.19.tar.xz"
ARCHIVE_CLOOG="cloog-0.18.4.tar.gz"

URL_BINUTILS="https://ftp.gnu.org/gnu/binutils/$ARCHIVE_BINUTILS"
URL_GCC="https://ftp.gnu.org/gnu/gcc/$(echo ${ARCHIVE_GCC} | sed 's/\.tar\.xz//')/$ARCHIVE_GCC"
URL_GMP="https://ftp.gnu.org/gnu/gmp/$ARCHIVE_GMP"
URL_MPFR="https://ftp.gnu.org/gnu/mpfr/$ARCHIVE_MPFR"
URL_MPC="https://ftp.gnu.org/gnu/mpc/$ARCHIVE_MPC"
URL_BC="https://ftp.gnu.org/gnu/bc/$ARCHIVE_BC"
URL_ISL="http://isl.gforge.inria.fr/$ARCHIVE_ISL"
URL_CLOOG="https://www.bastoul.net/cloog/pages/download/count.php3?url=./$ARCHIVE_CLOOG"

INSTALL_PREFIX="$1"

if [ -z "$1" ]; then
    echo "Usage: $0 install_prefix"
    echo "This builds a cross-compilation kernel toolchain for the Pixel C."
    exit 1
fi

MAKE_JOBS="$2"
if [ -z "MAKE_JOBS" ]; then
    MAKE_JOBS=1
fi
if [ -z "$(echo $MAKE_JOBS | egrep '^[0-9]+$')" ]; then
    echo "Invalid number of make jobs, exitting..."
    exit 1
fi

if [ ! -d "$INSTALL_PREFIX" ]; then
    echo "Install prefix not found, exitting..."
    exit 1
fi

if [ ! -w "$INSTALL_PREFIX" ]; then
    echo "Install prefix is not writable, exitting..."
    exit 1
fi

if [ ! -x "$(command -v wget)" ]; then
    echo "Wget is not installed, exitting..."
    exit 1
fi

export PATH="${INSTALL_PREFIX}/bin:${PATH}"

echo "Downloading..."

download_thing() {
    if [ -f "$2" ]; then
        echo "$2 already downloaded, skipping..."
    else
        echo "Downloading $2..."
        wget "$1" -O "$2"
        if [ $? -ne 0 ]; then
            echo "Wget failed, exitting..."
            rm -f "$2"
            exit 1
        fi
    fi
}

mkdir -p archives
cd archives
download_thing "$URL_BINUTILS" "$ARCHIVE_BINUTILS"
download_thing "$URL_GCC" "$ARCHIVE_GCC"
download_thing "$URL_GMP" "$ARCHIVE_GMP"
download_thing "$URL_MPFR" "$ARCHIVE_MPFR"
download_thing "$URL_MPC" "$ARCHIVE_MPC"
download_thing "$URL_BC" "$ARCHIVE_BC"
download_thing "$URL_ISL" "$ARCHIVE_ISL"
download_thing "$URL_CLOOG" "$ARCHIVE_CLOOG"
cd ..

echo "Done downloading..."

echo "Unpacking..."

unpack_thing() {
    ARN="$1"
    DIRN="$2"
    if [ -d "$DIRN" ]; then
        echo "$DIRN already unpacked, skipping..."
    else
        echo "Unpacking $ARN..."
        TEMPD="$(mktemp -d $DIRN-XXXXXXXX)"
        cd "$TEMPD"
        tar xvf "../../archives/$ARN"
        if [ $? -ne 0 ]; then
            echo "Tar failed, exitting..."
            cd ..
            rm -rf "$TEMPD"
            exit 1
        fi
        mv * "../$DIRN"
        cd ..
        rm -rf "$TEMPD"
    fi
}

mkdir -p sources
cd sources
unpack_thing "$ARCHIVE_BINUTILS" binutils
unpack_thing "$ARCHIVE_GCC" gcc
unpack_thing "$ARCHIVE_GMP" gmp
unpack_thing "$ARCHIVE_MPFR" mpfr
unpack_thing "$ARCHIVE_MPC" mpc
unpack_thing "$ARCHIVE_BC" bc
unpack_thing "$ARCHIVE_ISL" isl
unpack_thing "$ARCHIVE_CLOOG" cloog

cd gcc
if [ ! -d mpfr ]; then
    ln -s ../mpfr mpfr
fi
if [ ! -d gmp ]; then
    ln -s ../gmp gmp
fi
if [ ! -d mpc ]; then
    ln -s ../mpc mpc
fi
if [ ! -d isl ]; then
    ln -s ../isl isl
fi
if [ ! -d cloog ]; then
    ln -s ../cloog cloog
fi
cd ../..

echo "Done unpacking..."

build_thing() {
    TARGET="$1"
    shift
    cd "sources/$TARGET"
    if [ $? -ne 0 ]; then
        echo "Target $TARGET does not exist, exitting..."
        exit 1
    fi
    echo "Building $TARGET..."
    BDIR="$(mktemp -d build-XXXXXXXX)"
    cd "$BDIR"
    if [ $? -ne 0 ]; then
        echo "Failed switching to build directory, exitting..."
        exit 1
    fi
    ../configure --prefix="$INSTALL_PREFIX" "$@"
    if [ $? -ne 0 ]; then
        echo "Configure failed for '$1', exitting..."
        cd ..
        rm -rf "$BDIR"
        exit 1
    fi
    gmake "-j$MAKE_JOBS" $MAKE_TARGET
    if [ $? -ne 0 ]; then
        echo "Build failed for '$1', exitting..."
        cd ..
        rm -rf "$BDIR"
        exit 1
    fi
    gmake install$MAKE_INSTALL_TARGET
    if [ $? -ne 0 ]; then
        echo "Installation failed for '$1', exitting..."
        cd ..
        rm -rf "$BDIR"
        exit 1
    fi
    cd ..
    rm -rf "$BDIR"
    cd ../..
}

if [ -z "$SKIP_BC" ]; then
    build_thing bc
fi

if [ -z "$SKIP_BINUTILS" ]; then
    build_thing binutils --target=aarch64-linux-gnu --disable-multilib
fi

if [ -z "$SKIP_GCC" ]; then
    MAKE_TARGET=all-gcc MAKE_INSTALL_TARGET=-gcc build_thing gcc \
        --target=aarch64-linux-gnu --disable-multilib --disable-threads \
        --enable-languages=c
fi
