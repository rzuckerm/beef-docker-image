#!/bin/bash
echo Starting build.sh

PATH=/usr/local/bin:$PATH:$HOME/bin
SCRIPTPATH=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
ROOTPATH="$(dirname "$SCRIPTPATH")"
echo Building from $SCRIPTPATH
cd $SCRIPTPATH

if [[ $1 == "clean" ]]; then
    rm -rf ../jbuild
fi

USE_NINJA="-GNinja"

# exit when any command fails
set -e

### Dependencies ###

if [ ! -f ../BeefySysLib/third_party/libffi/Makefile ]; then
    echo Building libffi...
    cd ../BeefySysLib/third_party/libffi
    ./configure
    make
    cd $SCRIPTPATH
fi

if [ ! -f ../extern/llvm_linux_rel_13_0_1/_Done.txt ]; then
    echo Building LLVM...
    cd ../extern
    ./llvm_build.sh
    cd $SCRIPTPATH
fi

### LIBS ###

cd ..
mkdir jbuild
cd jbuild
cmake $USE_NINJA -DCMAKE_BUILD_TYPE=Release ../
cmake --build .

cd ../IDE/dist

if [[ "$OSTYPE" == "darwin"* ]]; then
    LIBEXT=dylib
    LINKOPTS="-Wl,-no_compact_unwind -Wl,-rpath -Wl,@executable_path"
else
    LIBEXT=so
    LINKOPTS="-ldl -lpthread -Wl,-rpath -Wl,\$ORIGIN"
fi

ln -s -f $ROOTPATH/jbuild/Release/bin/libBeefRT.a libBeefRT.a
ln -s -f $ROOTPATH/jbuild/Release/bin/libBeefySysLib.$LIBEXT libBeefySysLib.$LIBEXT
ln -s -f $ROOTPATH/jbuild/Release/bin/libIDEHelper.$LIBEXT libIDEHelper.$LIBEXT

ln -s -f $ROOTPATH/jbuild/Release/bin/libBeefRT.a ../../BeefLibs/Beefy2D/dist/libBeefRT.a
ln -s -f $ROOTPATH/jbuild/Release/bin/libBeefySysLib.$LIBEXT ../../BeefLibs/Beefy2D/dist/libBeefySysLib.$LIBEXT
ln -s -f $ROOTPATH/jbuild/Release/bin/libIDEHelper.$LIBEXT ../../BeefLibs/Beefy2D/dist/libIDEHelper.$LIBEXT

### RELEASE ###

echo Building BeefBuild_boot
../../jbuild/Release/bin/BeefBoot --out="BeefBuild_boot" --src=../src --src=../../BeefBuild/src --src=../../BeefLibs/corlib/src --src=../../BeefLibs/Beefy2D/src --define=CLI --startup=BeefBuild.Program --linkparams="./libBeefRT.a ./libIDEHelper.$LIBEXT ./libBeefySysLib.$LIBEXT $(< ../../IDE/dist/IDEHelper_libs.txt) $LINKOPTS"
echo Building BeefBuild
./BeefBuild_boot -clean -proddir=../../BeefBuild -config=Release
echo Testing IDEHelper/Tests in BeefBuild
./BeefBuild -proddir=../../IDEHelper/Tests -test
