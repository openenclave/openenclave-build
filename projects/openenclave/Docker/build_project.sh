#!/bin/bash
#
#
# Builds a bootstrap verified toolchain in a container
# using minimum environment

exec >/output/stdout.log
exec 2>/output/stderr.log

# Use the buildinfo associated with this image
#/tmp/buildinfo/check_build 

# Install doxygen. 
dpkg -i /tmp/deb/libllvm6.0_1%3a6.0-1ubuntu2_amd64.deb
dpkg -i /tmp/deb/libclang1-6.0_1%3a6.0-1ubuntu2_amd64.deb
dpkg -i /tmp/deb/doxygen_1.8.13-10_amd64.deb

dpkg -i /tmp/libsgx-enclave-common+2.7.100.4-bionic_amd64.deb
dpkg -i /tmp/libsgx-enclave-common-dev+2.7.100.4-bionic_amd64.deb
dpkg -i /tmp/libsgx-dcap-ql_1.3.101.3-bionic1_amd64.deb
dpkg -i /tmp/libsgx-dcap-ql-dev_1.3.101.3-bionic1_amd64.deb

dpkg -i /tmp/az-dcap-client_1.1_amd64_18.04.deb

# Install esy
ESY_PREFIX=/usr/local/esy
ESY_TARGET_VERSION=0.5.8
ESY_SOLVE_TARGET_VERSION=0.1.10
mkdir -p /usr/local/esy
mkdir -p /usr/local/esy/lib

mkdir -p /tmp/esy-release
pushd /tmp/esy-release
tar xvf /tmp/esy-${ESY_TARGET_VERSION}.tgz
popd

mkdir -p /tmp/esy-solve-cudf-release
pushd /tmp/esy-solve-cudf-release
tar xvf /tmp/esy-solve-cudf-${ESY_SOLVE_TARGET_VERSION}.tgz
popd

cp /tmp/esy-release/package/package.json ${ESY_PREFIX}/
cp -r /tmp/esy-release/package/platform-linux/_build/default ${ESY_PREFIX}/lib/default

mkdir -p ${ESY_PREFIX}/lib/node_modules/esy-solve-cudf
cp /tmp/esy-solve-cudf-release/package/package.json ${ESY_PREFIX}/lib/node_modules/esy-solve-cudf/
cp /tmp/esy-solve-cudf-release/package/platform-linux/esySolveCudfCommand.exe ${ESY_PREFIX}/lib/node_modules/esy-solve-cudf/

chmod 0555 ${ESY_PREFIX}/lib/default/bin/esy.exe
chmod 0555 ${ESY_PREFIX}/lib/default/esy-build-package/bin/esyBuildPackageCommand.exe
chmod 0555 ${ESY_PREFIX}/lib/default/esy-build-package/bin/esyRewritePrefixCommand.exe

ln -sf ${ESY_PREFIX}/lib/default/bin/esy.exe /usr/local/bin/esy


git clone https://github.com/openenclave/openenclave /src/openenclave
pushd /src/openenclave
git checkout brcamp/secure_build
popd

mkdir -p /build/openenclave
pushd /build/openenclave
cmake -G "Unix Makefiles" /src/openenclave -DCMAKE_INSTALL_PREFIX=/opt/openenclave
make
make test # This will probably get changed depending on the build environment
cpack -G DEB
cp open-enclave*.deb /output
popd

