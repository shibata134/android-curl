#!/bin/bash
export ANDROID_NDK_ROOT=$HOME/sdk/AndroidNDK.app/Contents/NDK
export HOST_TAG=darwin-x86_64
export MIN_SDK_VERSION=23

PRJ_DIR=$(dirname $(cd $(dirname $0); pwd))
BLD_DIR=$PRJ_DIR/build/curl
mkdir -p $BLD_DIR
cd $PRJ_DIR/external/curl

export TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$HOST_TAG

autoreconf -fi

function build() {
  echo
  echo "**** Build $1 ****"
  export TARGET_HOST=$2
  export ANDROID_ARCH=$3
  export AR=$TOOLCHAIN/bin/llvm-ar
  export CC=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang
  export AS=$CC
  export CXX=$TOOLCHAIN/bin/$TARGET_HOST$MIN_SDK_VERSION-clang++
  export LD=$TOOLCHAIN/bin/ld
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip

  export SSL_DIR=$PRJ_DIR/build/openssl/$ANDROID_ARCH

  ./configure --host=$TARGET_HOST \
    --target=$TARGET_HOST \
    --prefix=$PWD/build/$ANDROID_ARCH \
    --with-openssl=$SSL_DIR \
    --with-pic \
    --disable-shared

  make -j8
  make install
  make clean
  mkdir -p $BLD_DIR/$ANDROID_ARCH
  cp -R $PWD/build/$ANDROID_ARCH $BLD_DIR/
  echo "**** Completed building $1! ****"
}
# arm
build arm armv7a-linux-androideabi armeabi-v7a
# arm64
build arm64 aarch64-linux-android arm64-v8a
# x86
build x86 i686-linux-android x86
# x86_64
build x86_64 x86_64-linux-android x86_64
