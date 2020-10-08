# Copyright (c) Open Enclave SDK contributors.
# Licensed under the MIT License.
# 
ARG BASE_IMAGE="ubuntu@sha256:31dfb10d52ce76c5ca0aa19d10b3e6424b830729e32a89a7c6eee2cda2be67a5"
FROM $BASE_IMAGE

#
# Build container to produce reproducible nix derivation and .deb package of the OpenEnclave SDK
# 
# Uses nix package manager to wrap the standard build process.
#
# 
#
RUN apt-get update \
        && apt-get install -y curl python3 perl git vim dpkg \
        && mkdir -p /nix /etc/nix \
        && chmod a+rwx /nix \
        && echo 'sandbox = false\nkeep-derivations = true\nkeep-env-derivations = true' > /etc/nix/nix.conf \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /output
RUN mkdir -p /output/build
RUN chmod -R 777 /output
RUN mkdir -p /opt/openenclave
RUN chmod -R 777 /opt/openenclave

#
# We alklow overriding these settings, but if one does, the build user and id must match or else the .deb tars won't have 
# a reproducible signature, since tar entries include user and group ownerships.
ARG BUILD_USER=azureuser
ARG BUILD_USER_ID=1000
ARG BUILD_USER_HOME=/home/azureuser

# This will exclude oegdb, samples, and report 
ARG TEST_EXCLUSIONS="-E samples\|oegdb-test\|report"

#add a user for Nix
RUN echo "adduser $BUILD_USER --uid $BUILD_USER_ID --home $BUILD_USER_HOME"
RUN adduser $BUILD_USER --uid $BUILD_USER_ID --home $BUILD_USER_HOME --disabled-password --gecos "" --shell /bin/bash
RUN addgroup nixbld 
RUN adduser $BUILD_USER  nixbld
ENV USER=$BUILD_USER
USER $BUILD_USER
CMD /bin/bash -l
WORKDIR /home/$BUILD_USER
# 
#create the shell config
RUN echo "{ pkgs ? import <nixpkgs> {} }:  \n\
\n\
with pkgs; \n\
\tstdenvNoCC.mkDerivation {  \n\
\t\tname = \"openenclave-sdk\";  \n\
\t\tbuildInputs = with pkgs;  [  \n\
\t\t	pkgs.openssl \n\
\t\t	pkgs.cmake \n\
\t\t	pkgs.llvm \n\
\t\t	pkgs.clang \n\
\t\t    pkgs.python3 \n\
\t\t    pkgs.doxygen \n\
\t\t    pkgs.dpkg \n\
\t\t];  \n\
\t\tsrc = fetchFromGitHub { \n\
\t\t              owner = \"openenclave\";\n\
\t\t              repo = \"openenclave\";\n\
\t\t              rev  = \"0acfb9ad86709b861da42b55fee670e3f4dd661c\"; \n\
\t\t              sha256 = \"0xhq0lvhjrdss3p2kbdx3gg8m4a6rd16d75x30c8gjrs8l02g033\"; \n\
\t\t              fetchSubmodules = true; \n\
\t\t        }; \n\
\t\t    CC = \"clang\";\n\
\t\t    CXX = \"clang++\";\n\
\t\t    LD = \"ld.lld\";\n\
\t\t    CFLAGS=\"-Wno-unused-command-line-argument -Wl,-I/lib64/ld-linux-x86-64.so.2\" ;\n\
\t\t    CXXFLAGS=\"-Wno-unused-command-line-argument -Wl,-I/lib64/ld-linux-x86-64.so.2\";\n\
\t\t    LDFLAGS=\"-I/lib64/ld-linux-x86-64.so.2\" ;\n\
\t\t    NIX_ENFORCE_PURITY="0"; \n\
\t\t    doCheck = true; \
\t\t configurePhase = '' \n\
\t\t        chmod -R a+rw \$src \n\
\t\t        mkdir -p \$out \n\
\t\t        cd \$out \n\
\t\t        cmake -G \"Unix Makefiles\" \$src -DCMAKE_BUILD_TYPE=RelWithDebInfo  \n\
\t\t    ''; \n\
\t\t     \n\
\t\t buildPhase = '' \n\
\t\t        make VERBOSE=1 \n\
\t\t        cpack -G DEB \n\
\t\t        pkgname=\$(ls open-enclave*.deb) \n\
\t\t        echo \$pkgname\n\
\t\t        $BUILD_USER_HOME/sort_deb_sum.sh \$pkgname \n\
\t\t        mv \$pkgname.sorted \$pkgname \n\
\t\t    ''; \n\
\t\t checkPhase = '' \n\
\t\t        echo \"ctest $TEST_EXCLUSIONS\" \n\
\t\t        ctest $TEST_EXCLUSIONS \n\
\t\t    ''; \n\
\n\
\t\t installPhase = '' \n\
\t\t       cp -r \$out/* /output/build \n\
\t\t    ''; \n\
\t\t\n\
\t\t fixupPhase = '' \n\
\t\t    ''; \n\
\t\t\n\
\t\t     shellHook = '' \n\
\t\t          echo \"Shell Hook\" \n\
\t\t     #rm -rf /output/build \n\
\t\t     #rm -rf /output/srcdir\n\
\t\t     #mkdir /output/srcdir \n\
\t\t     #cd /output/srcdir \n\
\t\t   #  git clone --recurse-submodules https://github.com/openenclave/openenclave.git \n\
\t\t     #mkdir /output/build \n\
\t\t     #cd /output/build \n\
\t\t    # cmake -G \"Unix Makefiles\" /output/srcdir/openenclave -DCMAKE_BUILD_TYPE=RelWithDebInfo  \n\
\t\t    ''; \n\
}  \n\
" > /home/$BUILD_USER/shell.nix



RUN echo "User is $USER "
#install the required software
#RUN touch .bash_profile \
#
# We add the nix install and packages into the container rather than waiting for run time.
# The packages are then located in the nix store until the next push of the container
RUN curl https://nixos.org/releases/nix/nix-2.3.7/install | /bin/bash
ADD ./prep-nix-build.sh /home/$BUILD_USER
RUN /bin/bash ./prep-nix-build.sh /home/$BUILD_USER/nixpkgs

ADD ./sort_deb_sum.sh /home/$BUILD_USER
ADD ./nix-build.sh /home/$BUILD_USER
ADD libsgx_enclave_common.so /usr/lib/x86_64-linux-gnu
ADD libsgx_enclave_common.so.1 /usr/lib/x86_64-linux-gnu

#config nix-shell
#CMD . /home/$BUILD_USER/.nix-profile/etc/profile.d/nix.sh \
#&& nix-shell shell.nix
