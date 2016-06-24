#!/usr/bin/env bash

set -e
set -o pipefail

./autogen.sh --disable-webkit
make
