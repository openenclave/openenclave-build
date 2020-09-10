#!/bin/bash

LIBSGX_PKG_DIR=
#
#  Break apart .deb files for libsgx-enclave -common and libsgx-enclave-common-dev
#  perform whatever operations are required to use in openenclave build.
#  bypasses dpkg dependency checking and assumes an openenclave build.
#  This should be temporary until either nix packages for libsgx are available,
#  or openenclave doesn't need the packages to build.
#  
# usage: 
#    install-sgx-dependencies

