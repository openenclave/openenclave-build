#!/bin/bash
#
#
# Builds a bootstrap verified toolchain in a container
# using minimum environment

DIR="$( dirname "${BASH_SOURCE[0]}" )"
pushd Docker
rm ubuntu-base-18.04.3-base-amd64.tar.gz
wget  http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.3-base-amd64.tar.gz  
mkdir -p build
cp -r ../buildinfo build
docker build -f Dockerfile.bootstrap .
popd
