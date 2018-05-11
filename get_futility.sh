#!/bin/sh

. build_tool.sh

get_repo "https://github.com/pixelc-linux/futility.git" futility
build futility "$@"
install futility futility "$INSTALL_PREFIX"
