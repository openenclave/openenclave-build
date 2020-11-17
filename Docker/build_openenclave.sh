#!/bin/bash


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

# We remove the old build directory.
# nix-build has no idea of forcing a rebuild
if [ -d /output/build ]
then
    rm -rf /output/build/*
else
    mkdir -p /output/build
    chmod 777 /output/build
fi

#
# build.env specifies the commit or tag, and sha of the build. 

docker run -it ${SGX_DEVICE} -v /output:/output -v /var/run/aesmd:/var/run/aesmd --cap-add=SYS_PTRACE --env-file ./build.env openenclave-build  /home/azureuser/nix-build.sh 
set +x
