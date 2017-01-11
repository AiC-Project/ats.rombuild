#!/usr/bin/env bash

PRODUCT="$1"

cd src

export USE_CCACHE=1

./prebuilts/misc/linux-x86/ccache/ccache -M 50G

# shellcheck disable=SC1091
source build/envsetup.sh

lunch "${PRODUCT}-eng"

set -eu

TOP=$(pwd)
export TOP

make android_disk_vdi -j 4 2>&1 | tee build.log | ccze -A

