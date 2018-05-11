#!/bin/sh

. build_tool.sh

get_repo "https://github.com/pixelc-linux/mkbootimg.git" mkbootimg
build mkbootimg "$@"
install mkbootimg mkbootimg "$INSTALL_PREFIX"
install mkbootimg unpackbootimg "$INSTALL_PREFIX"
