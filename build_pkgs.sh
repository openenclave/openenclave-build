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

#IMAGE_URI="http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/ubuntu-base-18.04.3-base-amd64.tar.gz" 
IMAGE_URI="https://oedownload.blob.core.windows.net/oe-build/ubuntu-base-18.04.3-base-amd64.tar.gz?st=2019-10-25T16%3A53%3A03Z&se=2020-10-26T16%3A53%3A00Z&sp=rl&sv=2018-03-28&sr=b&sig=yOKo%2B7dnDrhc%2F%2FrUpemCeGsQNrN2GdOLmzsYiiQbm6o%3D"
SIGNATURE_URI="http://cdimage.ubuntu.com/ubuntu-base/releases/18.04/release/SHA256SUMS" 

PACKAGE_DEST=${1:-/tmp}

DIR="$( dirname "${BASH_SOURCE[0]}" )"
pushd Docker
rm ${IMAGE_FILE}
rm ${SIGNATURE_FILE}

wget ${IMAGE_URI} -O ${IMAGE_FILE} 
wget ${SIGNATURE_URI} -O ${SIGNATURE_FILE}
verify_sum

rm -rf build
mkdir -p build
cp -r ../buildinfo build
docker rm -f package_build
docker build -t package_build -f Dockerfile.pkg . 
docker run -v ${PACKAGE_DEST}:/output -it package_build /tmp/build_packages.sh
popd
