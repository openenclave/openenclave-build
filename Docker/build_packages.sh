#!/bin/bash
#
# 2do:
# Check the signature.

# 2do: 
# Rewrite sources.list to only get from CDN. We would like to trust ubu, but don't
#
# Replace apt with downloaded and verified deb using dpkg -i
#
DEBIAN_FRONTEND=noninteractive apt -y update --fix-missing
DEBIAN_FRONTEND=noninteractive apt -y dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y install musl musl-dev ninja-build python3 xz-utils libxml2 libgcc-7-dev make git zlib1g zlib1g-dev libreadline-dev libsqlite3-dev libbz2-dev libffi-dev liblzma-dev python-openssl gcc-7 g++-7 gpg libssl1.1 libssl-dev dpkg-dev libcurl4 libprotobuf10 doxygen gdb pkg-config


cd /var/cache/apt/archives
tar cvfz /tmp/secure-build.pkgs.tar.gz .

cd /tmp
sha256sum /tmp/secure-build.pkgs.tar.gz >/tmp/secure-build.pkgs.tar.gz.sha256sum
cp /tmp/secure-build.pkgs.tar.gz /output
cp /tmp/secure-build.pkgs.tar.gz.sha256sum /output

