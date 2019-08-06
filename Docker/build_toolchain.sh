#!/bin/bash

SRC=/src
# Builds and installs tool chain. Initally we use an untrusted bootstrap compiler, then replace the 
# untrusted compiler with one built from trusted sources, then rebuild again and check the sha256sum of 
# the output against the original. If they don't match, eitherthe sources are bogus, or the compiler is 
# bogus, or both. But either way, the build would not pass. 
#
# Though the original bootstrap compiler is untrusted, it should be the result of the trusted build
# process from the previous iteration.

pushd .
# cmake
mkdir -p /build/cmake-3.15.1
cd /build/cmake-3.15.1
cmake -G Ninja /src/cmake-3.15.1
ninja

# llvm tools
mkdir -p /build/llvm-7.0.1.src
cd /build/llvm-7.0.1.src
cmake -G Ninja /src//llvm-7.0.1.src
ninja
# clang compiler
mkdir -p /build/cfe-7.0.1.src
cd /build/cfe-7.0.1.src
cmake -G Ninja /src/cfe-7.0.1.src
ninja

# clang runtime
mkdir -p /build/compiler-rt-7.0.1.src
cd /build/compiler-rt-7.0.1.src
cmake -G Ninja /src/compiler-rt-7.0.1.src
ninja
# libc++
mkdir -p /build/libcxx-7.0.1.src
cd /build/libcxx-7.0.1.src
cmake -G Ninja /src/libcxx-7.0.1.src
ninja

# libunwind
mkdir -p /build/libunwind-7.0.1.src
cd /build/libunwind-7.0.1.src
cmake -G Ninja /src/libunwind-7.0.1.src
ninja

popd


