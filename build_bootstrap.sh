#!/bin/bash
#
#
# invokation:
#   sudo ./build_bootstrap.sh [outputdir]
#
# where outputdir is the option destination directory of the resulting image
#
# Builds a bootstrap verified toolchain in a container
# using minimum environment
set -x

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


DATA_CONTAINER_SAS="?st=2020-01-15T01%3A43%3A28Z&se=2021-01-16T01%3A43%3A00Z&sp=rl&sv=2018-03-28&sr=c&sig=%2BtY2XTRwc9V1aEc%2BPlxfhjpP8uuMjiJCq0JNJnyxBOY%3D"
SIG_CONTAINER_SAS="?st=2020-01-15T01%3A46%3A48Z&se=2021-01-16T01%3A46%3A00Z&sp=rl&sv=2018-03-28&sr=c&sig=nAKshh5LJcMRXbf2F186I0dBty2w%2BZn%2FsdwqzN%2BkQvQ%3D"

#IMAGE_URI="http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.3-base-amd64.tar.gz" 
IMAGE_URI="https://oedownload.blob.core.windows.net/oe-build/ubuntu-base-18.04.3-base-amd64.tar.gz$DATA_CONTAINER_SAS"
SIGNATURE_URI="http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/SHA256SUMS$SIG_CONTAINER_SAS" 

BOOTSTRAP_DST=${1:-/tmp}


DIR="$( dirname "${BASH_SOURCE[0]}" )"
pushd Docker
rm ${IMAGE_FILE}
rm ${SIGNATURE_FILE}

wget ${IMAGE_URI} -O ${IMAGE_FILE} --no-check-certificate
wget ${SIGNATURE_URI} -O ${SIGNATURE_FILE} --no-check-certificate
verify_sum

rm -rf build
mkdir -p build
cp -r ../buildinfo build
docker rm -f container_build
docker build -t candidate -f Dockerfile.bootstrap . 
docker run --name container_build -m 24G --memory-swap=-1 -v ${BOOTSTRAP_DST}:/output -it candidate /tmp/build_toolchain.sh
docker commit container_build candidate
popd
