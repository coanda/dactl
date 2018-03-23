#!/usr/bin/env bash

set -e
set -o pipefail

meson _build
ninja -C _build
ninja -C _build test
