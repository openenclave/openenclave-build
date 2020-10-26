#!/bin/bash

#source ~/.nix-profile/etc/profile.d/nix.sh

#
# We remove the package build.
# nix-build has no idea of forcing a rebuild
# 

if [ -d /dev/sgx ]
then 
    SGX_DEVICE="--device /dev/sgx/enclave:/dev/sgx/enclave  --device /dev/sgx/provision:/dev/sgx/provision"
elif [ -c /dev/isgx ]
then
    SGX_DEVICE="--device /dev/isgx:/dev/isgx"
else
    SGX_DEVICE="-e OE_SIMULATION=1"
fi

#nix-store --delete $(nix-store --dump-db | grep openenclave)
# We start with no nix store and add what we use. We do not share with others

CC=clang-7
CXX=clang++-7
LD=ld.lld
CFLAGS="-Wno-unused-command-line-argument -Wl,-I/lib64/ld-linux-x86-64.so.2"
CXXFLAGS="-Wno-unused-command-line-argument -Wl,-I/lib64/ld-linux-x86-64.so.2"
LDFLAGS="-I/lib64/ld-linux-x86-64.so.2"

docker run -it ${SGX_DEVICE} -v /output:/output openenclave-test # /bin/bash nix-build.sh 
