#!/bin/bash

# 
#  Install the toolchain built from the sources and bootstrap toolchain into the container.
#
cd /build;

for i in *
do
   pushd .
   cd $i
   make install
   popd
done
