#!/bin/bash

# 01. Download toolchains:
# # https://github.com/ravindu644/Android-Kernel-Tutorials/releases/download/toolchains/clang-r383902.tar.gz
# https://github.com/ravindu644/Android-Kernel-Tutorials/releases/download/toolchains/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz

# 02. install requirements:
# https://github.com/ravindu644/Android-Kernel-Tutorials#-install-required-dependencies-for-compiling-kernels

echo -e "\n[INFO]: BUILD STARTED..!\n"

#init submodules
git submodule init && git submodule update

export KERNEL_ROOT="$(pwd)"
export ARCH=arm64
export KBUILD_BUILD_USER="@ravindu644"
export PLATFORM_VERSION=13

# Create necessary directories
mkdir -p "${KERNEL_ROOT}/build" "${HOME}/toolchains"

# Export toolchain paths
export PATH="${HOME}/toolchains/clang-r383902/bin:${PATH}"
export LD_LIBRARY_PATH="${HOME}/toolchains/clang-r383902/lib64:${HOME}/toolchains/clang-r383902/lib:${LD_LIBRARY_PATH}"

# Set cross-compile environment variables
export BUILD_CROSS_COMPILE="${HOME}/toolchains/gcc/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-"
export BUILD_CC="${HOME}/toolchains/clang-r383902/bin/clang"

# Build options for the kernel
export BUILD_OPTIONS="
-j$(nproc) \
ARCH=arm64 \
CROSS_COMPILE=${BUILD_CROSS_COMPILE} \
CC=${BUILD_CC} \
CLANG_TRIPLE=aarch64-linux-gnu- \
"

build_kernel(){
    # Make default configuration.
    # Replace 'your_defconfig' with the name of your kernel's defconfig
    make ${BUILD_OPTIONS} exynos850-a13xx_defconfig custom.config

    # Configure the kernel (GUI)
    make ${BUILD_OPTIONS} menuconfig

    # Build the kernel
    make ${BUILD_OPTIONS} Image || exit 1

    # Copy the built kernel to the build directory
    cp "${KERNEL_ROOT}/arch/arm64/boot/Image" "${KERNEL_ROOT}/build"

    echo -e "\n[INFO]: BUILD FINISHED..!"
}
build_kernel
