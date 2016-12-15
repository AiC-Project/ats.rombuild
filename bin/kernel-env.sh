CROSS_COMPILE=$(realpath src/aic-kitkat/external/qemu/distrib/kernel-toolchain)/android-kernel-toolchain-
export CROSS_COMPILE
REAL_CROSS_COMPILE=$(realpath src/aic-kitkat/prebuilts/gcc/linux-x86/x86/i686-linux-android-4.7/bin)/i686-linux-android-
export REAL_CROSS_COMPILE
export ARCH=x86
export SUBARCH=x86
export LOCALVERSION=-qemu+
