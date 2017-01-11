#!/usr/bin/env bash

PRODUCT="$1"

cd src

export USE_CCACHE=1

./prebuilts/misc/linux-x86/ccache/ccache -M 50G

# Kitkat needs make 3.82
mkdir -p ~/bin
ln -sf /usr/local/bin/make-3.82 ~/bin/make
export PATH=~/bin/:$PATH

# shellcheck disable=SC1091
source build/envsetup.sh

lunch "${PRODUCT}-eng"

set -eu

TOP=$(pwd)
export TOP

mmma external/protobuf
mmma external/aic/libaicd
make android_disk_vdi -j 4 2>&1 | tee build.log | ccze -A

