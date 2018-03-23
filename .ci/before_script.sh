#!/usr/bin/env bash

set -e
set -o pipefail

# TODO: move into a build_deps script within .ci/common/build.sh
git clone https://github.com/geoffjay/libcld.git
cd libcld
meson _build
meson configure -Dprefix=/usr
ninja -C _build
sudo ninja -C _build install
cd ..
