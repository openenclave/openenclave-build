#!/bin/bash

SRC=/src
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

CC=/usr/local/bin/clang
CXX=/usr/local/bin/clang++
LD=/usr/local/bin/ld.lld
CFLAGS="-fPIC -fuse-ld="
CXXFLAGS="-fPIC -fuse-ld="
export CC
export CXX
export LD
export CFLAGS
export CXXFLAGS

#
cd /src
pushd .
# first build python
cd cpython
./configure
make

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

# Check sums
