#!/bin/bash
#
#
# Builds a bootstrap verified toolchain in a container
# using minimum environment

SIGNATURE_FILE="SHA256SUMS"
IMAGE_FILE="ubuntu-base-18.04.3-base-amd64.tar.gz" 

function verify_sum() {
    rslt=$(grep ${IMAGE_FILE} ${SIGNATURE_FILE})
    read -r -a reference_args <<< $rslt

    rslt=$(sha256sum ${IMAGE_FILE})
    read -r -a target_args <<< $rslt

    if [ "${reference_args}" == "${target_args}" ]
    then 
       echo "verified signature " ${IMAGE_FILE}
    else
       echo "could not verify signature " ${IMAGE_FILE}
       exit 0
    fi
}

IMAGE_URI="http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.3-base-amd64.tar.gz" 
SIGNATURE_URI="http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/SHA256SUMS" 


DIR="$( dirname "${BASH_SOURCE[0]}" )"
pushd Docker
rm ubuntu-base-18.04.3-base-amd64.tar.gz
rm ${IMAGE_FILE}
rm ${SIGNATURE_FILE}

wget ${IMAGE_URI}
wget ${SIGNATURE_URI}
verify_sum

rm -rf build
mkdir -p build
cp -r ../buildinfo build
docker build -f Dockerfile.bootstrap .
popd
