#!/bin/bash

#source ~/.nix-profile/etc/profile.d/nix.sh

#
# We remove the package build.
# nix-build has no idea of forcing a rebuild
# 

set -x
if [ -d /dev/sgx ]
then 
    SGX_DEVICE="--device /dev/sgx/enclave:/dev/sgx/enclave  --device /dev/sgx/provision:/dev/sgx/provision"
elif [ -c /dev/isgx ]
then
    SGX_DEVICE="--device /dev/isgx:/dev/isgx"
else
    SGX_DEVICE="-e OE_SIMULATION=1"
fi

if [ -h  /output ]
then
    echo "link /output found" 
elif [ -d /output ]
then
    echo "directory /output found" 
else
    # ALERT: Maybe we should have an arg here to define a dir to link to rather than
    # root level directory. But this is simple and provides the /output directory
    # we need the same paths on the host and container to be able to run tests.

    echo "making directory /output"
    sudo mkdir /output
    sudo chmod 777 /output
fi

if [ -d /output/build ]
then
    rm -rf /output/build/*
else
    mkdir -p /output/build
    chmod 777 /output/build
fi

#nix-store --delete $(nix-store --dump-db | grep openenclave)
# We start with no nix store and add what we use. We do not share with others

CC=clang-7
CXX=clang++-7
LD=ld.lld
CFLAGS="-Wno-unused-command-line-argument -Wl,-I/lib64/ld-linux-x86-64.so.2"
CXXFLAGS="-Wno-unused-command-line-argument -Wl,-I/lib64/ld-linux-x86-64.so.2"
LDFLAGS="-I/lib64/ld-linux-x86-64.so.2"

#docker run -it ${SGX_DEVICE} -v /nix:/nix -v /output:/output openenclave-build # /bin/bash nix-build.sh 
docker run -it ${SGX_DEVICE} -v /output:/output --env-file ./build.env openenclave-build # /bin/bash nix-build.sh 
set +x
