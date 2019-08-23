#!/bin/bash
#
# Build a trusted toolchain into the bootstrap build container. 
#

function build_install_toolchain() {
    pushd .
    # cmake
    cd ${CMAKE_SRC_DIR}
    rm CMakeCache.txt
    ./bootstrap
    make
    make install
    popd
    pushd .
    mkdir -p ${CMAKE_BUILD_DIR}
    cd ${CMAKE_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" ${CMAKE_SRC_DIR}
    make
    
    # llvm tools
    mkdir -p ${LLVM_BUILD_DIR}
    cd ${LLVM_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="X86"  ${CMAKE_FLAGS}  ${LLVM_SRC_DIR}
    make
    make install
    
    # llvm linker
    mkdir -p ${LLD_BUILD_DIR}
    cd ${LLD_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" ${CMAKE_FLAGS}  ${LLD_SRC_DIR}
    make
    make install
    
    # clang compiler
    mkdir -p ${CLANG_BUILD_DIR}
    cd ${CLANG_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" -DLLVM_CXX_STD="c++17" ${CMAKE_FLAGS}  ${CLANG_SRC_DIR}
    make
    make install
    
    # clang runtime
    mkdir -p /build/compiler-rt-7.1.0.src
    cd /build/compiler-rt-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"  -DLLVM_CXX_STD="c++17"  ${CMAKE_FLAGS} /src/compiler-rt-7.1.0.src 
    make
    make install
    
    # libc++
    mkdir -p /build/libcxx-7.1.0.src
    cd /build/libcxx-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"   -DLLVM_CXX_STD="c++17"  ${CMAKE_FLAGS} /src/libcxx-7.1.0.src
    make
    make install
    
    # libunwind
    mkdir -p /build/libunwind-7.1.0.src
    cd /build/libunwind-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"  -DLLVM_CXX_STD="c++17" ${CMAKE_FLAGS} /src/libunwind-7.1.0.src
    make
    make install
    
    popd
}


# Builds additional tools: ninja, ocaml, git
# Though we have these components installed already, but we want to make sure we build them from
#  source using the trusted toolchain. 
#
# The bootstrapping sequence of events is :
#
#  1. Bring up the bootstrap environment (docker build -f ./Dockerfile.bootstrap)
#  2. Compile the toolchain from known source (validate the source)
#  3. Install the verified toolchain, built from the bootastrap toolchain.
#  4. Compile the toolchain again using the verified toolchain. 
#  5. Install the now verified toolchain, built from the verified toolchain.
#  5. Compile the toolchain again using the verified toolchain. 
#  6. Check the expected sha256sums. They should be identical.
#  7. Build additional tools using the trusted toolchain
#  8. Install the additional tools 
#  9. Build additional tools (again) using the trusted toolchain
# 10. Check the tools against the previous build. They should be identical
#
#  Once the  bootstrap environment is established, we can docker export to a tar file, and 
#  escrow the tar file and (separately) a sha256sum of the tar file.  Then we can docker build Dockerfile.build
#  which will pull the tar file from escrow and load it into the image after checking the sum. 
#
#

function build_tools() {

cd /src
pushd .
# first build python
cd cpython
./configure --enable-optimizations
make
make install

cd ninja
./bootstrap.py
ninja
ninja -t install
ninja -t clean
./bootstrap.py
ninja
sha256sum ninja /usr/local/bin/ninja
popd
# ocaml 
pushd .
cd ocaml
./configure 
make world.opt
make install
make clean
./configure 
make world.opt
}


function build_check_toolchain() {
    pushd .
    
    # llvm tools
    mkdir -p ${LLVM_BUILD_DIR}
    cd ${LLVM_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="X86"  ${CMAKE_FLAGS}  ${LLVM_SRC_DIR}
    make
   # CHECK make install
    
    # llvm linker
    mkdir -p ${LLD_BUILD_DIR}
    cd ${LLD_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" ${CMAKE_FLAGS}  ${LLD_SRC_DIR}
    make
    make install
    
    # clang compiler
    mkdir -p ${CLANG_BUILD_DIR}
    cd ${CLANG_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" -DLLVM_CXX_STD="c++17" ${CMAKE_FLAGS}  ${CLANG_SRC_DIR}
    make
    
    # clang runtime
    mkdir -p /build/compiler-rt-7.1.0.src
    cd /build/compiler-rt-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"  -DLLVM_CXX_STD="c++17"  ${CMAKE_FLAGS} /src/compiler-rt-7.1.0.src 
    make
    
    # libc++
    mkdir -p /build/libcxx-7.1.0.src
    cd /build/libcxx-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"   -DLLVM_CXX_STD="c++17"  ${CMAKE_FLAGS} /src/libcxx-7.1.0.src
    make
    
    # libunwind
    mkdir -p /build/libunwind-7.1.0.src
    cd /build/libunwind-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"  -DLLVM_CXX_STD="c++17" ${CMAKE_FLAGS} /src/libunwind-7.1.0.src
    make
    
    popd
}


SRC=/src
# Builds and installs tool chain. Initally we use an untrusted bootstrap compiler, then replace the 
# untrusted compiler with one built from trusted sources, then rebuild again and check the sha256sum of 
# the output against the original. If they don't match, eitherthe sources are bogus, or the compiler is 
# bogus, or both. But either way, the build would not pass. 
#
# Though the original bootstrap compiler is untrusted, it should be the result of the trusted build
# process from the previous iteration.


CMAKE_SRC_DIR=/src/cmake-3.15.1
CMAKE_BUILD_DIR=/build/cmake-3.15.1
export CMAKE_SRC_DIR
export CMAKE_BUILD_DIR

LLVM_SRC_DIR=/src/llvm-7.1.0.src
LLVM_BUILD_DIR=/build/llvm-7.1.0.src
export LLVM_SRC_DIR
export LLVM_BUILD_DIR

LLD_SRC_DIR=/src/lld-7.1.0.src
LLD_BUILD_DIR=/build/lld-7.1.0.src
export LLD_SRC_DIR
export LLD_BUILD_DIR

CLANG_SRC_DIR=/src/cfe-7.1.0.src
CLANG_BUILD_DIR=/build/cfe-7.1.0.src
export CLANG_SRC_DIR
export CLANG_BUILD_DIR


# we only want to build the current arch, not cross compile
LLVM_TARGET_ARCH="host"
export LLVM_TARGET_ARCH

#build_install_toolchain

# We built the toolchain with the default installed tools. We do not trust this toolchain
# and it will not reproduce if it was built with gcc, which embeds time and data stamps etc.
# So, we use this toolchain, built with known sources, to build the same toolchain and install it.
# We can then build it again using the new semi-trusted toolchain and compare to a third build

if [ -f /usr/local/bin/clang ];
then
    CC=/usr/local/bin/clang
    CXX=/usr/local/bin/clang++
    LD=/usr/local/bin/ld.lld
    CFLAGS="-fPIC -fuse-ld=/usr/local/bin/ld.lld"
    CXXFLAGS="-std=c++17 -stdlib=libstdc++ -fPIC -fuse-ld=/usr/local/bin/ld.lld "

    CMAKE_FLAGS=" -DLLVM_TARGET_ARCH="host" -DLLVM_ENABLE_LLD=1 "
    export CC
    export CXX
    export LD
    export CFLAGS
    export CXXFLAGS
    export CMAKE_FLAGS
else
    echo "Did not successfully build toolchain: Clang is not built"
    exit 3
fi

# this will overwrite the gcc built toolchain
build_install_toolchain

build_tools

#
# build_compare_toolchain
