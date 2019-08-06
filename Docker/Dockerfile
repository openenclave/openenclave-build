FROM scratch

# The way to get a trusted build is to start with a trusted build. If we don't have one,
# we need to use untrusted components to perform the build, then rebuild with the provisionally trusted components, 
# then compare. If we get different contents, we don't know where the problem is, but we would know there is a problem.

# this can't come from a URL because it won't get unpacked. 
# We need a tight secure CDN to hold golden images. 
ADD ubuntu-base-18.04.2-base-amd64.tar.gz  /
#
# 2do: Check the signature.

#
# Rewrite sources.list to only get from CDN. We would like to trust ubu, but don't
# 2Do: setup CDN and build dummy 

RUN DEBIAN_FRONTEND=noninteractive apt update
RUN DEBIAN_FRONTEND=noninteractive apt -y dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install musl musl-dev ninja-build python3 xz-utils libxml2 libgcc-7-dev clang-7 make


# Now cmake. 
# 2do: Cmake should be coming from our CDN. Even if using the debian package was a good idea, the
# cmake package version is 3.10.  We require 3.13 minimum.
ADD https://github.com/Kitware/CMake/releases/download/v3.15.1/cmake-3.15.1.tar.gz  /tmp/cmake-3.15.1.tar.gz

#
COPY build_toolchain.sh /tmp
COPY install_toolchain.sh /tmp
COPY check_toolchain.sh /tmp

RUN rm -rf /usr/local ; mkdir -p /usr/local

#
#Unpack the golden cmake
WORKDIR /tmp
#RUN tar xvfz cmake-3.15.1-Linux-x86_64.tar.gz
#RUN /bin/bash -c "\
#    pushd . ;\
#    cd cmake-3.15.1-Linux-x86_64 ; \
#    cp -Rf * /usr/local/ ; \
#    popd \
#    "
ENV PATH=/usr/local/bin:/bin:/sbin:/usr/bin

#
# 2do: Get this file from CDN and check signature
ADD http://releases.llvm.org/7.0.1/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz /tmp
ADD http://releases.llvm.org/7.0.1/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz.sig /tmp

# compiler
ADD http://releases.llvm.org/7.0.1/cfe-7.0.1.src.tar.xz /tmp
ADD http://releases.llvm.org/7.0.1/cfe-7.0.1.src.tar.xz.sig /tmp

# compiler run time
ADD http://releases.llvm.org/7.0.1/compiler-rt-7.0.1.src.tar.xz  /tmp
ADD http://releases.llvm.org/7.0.1/compiler-rt-7.0.1.src.tar.xz.sig  /tmp

# libc++
ADD http://releases.llvm.org/7.0.1/libcxx-7.0.1.src.tar.xz /tmp
ADD http://releases.llvm.org/7.0.1/libcxx-7.0.1.src.tar.xz.sig /tmp

# libunwind
ADD http://releases.llvm.org/7.0.1/libunwind-7.0.1.src.tar.xz /tmp
ADD http://releases.llvm.org/7.0.1/libunwind-7.0.1.src.tar.xz.sig /tmp

# tools extra
ADD http://releases.llvm.org/7.0.1/clang-tools-extra-7.0.1.src.tar.xz  /tmp
ADD http://releases.llvm.org/7.0.1/clang-tools-extra-7.0.1.src.tar.xz.sig  /tmp

#
# We bootstrap with a prebuilt compiler, but then build the toolchain and check the signatures against the 
# prebuilt. If the signatures don't match we have a security issue.
# 2do: build and tar a private build to be served from the CDN
ADD http://releases.llvm.org/7.0.1/llvm-7.0.1.src.tar.xz /tmp
ADD http://releases.llvm.org/7.0.1/llvm-7.0.1.src.tar.xz.sig /tmp

RUN tar xvfJ /tmp/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04.tar.xz 
RUN /bin/bash -c "\
    pushd . ;\
    cd clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-18.04 ; \
    cp -Rf * /usr/local/ ; \
    ldconfig /usr/local/lib ; \
    popd \
    "
RUN mkdir -p /src
RUN mkdir -p /build

WORKDIR /src

# Check the signature, build then check the sha256 hash of the binaries
RUN tar xvfz /tmp/cmake-3.15.1.tar.gz
RUN tar xvfJ /tmp/llvm-7.0.1.src.tar.xz
RUN tar xvfJ /tmp/cfe-7.0.1.src.tar.xz
RUN tar xvfJ /tmp/compiler-rt-7.0.1.src.tar.xz 
RUN tar xvfJ /tmp/libcxx-7.0.1.src.tar.xz
RUN tar xvfJ /tmp/libunwind-7.0.1.src.tar.xz

RUN /bin/bash -c "\
    pushd . ; \
    cd /src/cmake-3.15.1 ;\
    ./bootstrap ; \
    make  ; \
    make install ; \
    popd ; \
    "

WORKDIR /build
RUN bash -c 'chmod a+x /tmp/build_toolchain.sh'
RUN bash -c 'chmod a+x /tmp/install_toolchain.sh'
RUN bash -c 'chmod a+x /tmp/check_toolchain.sh'
#RUN bash -c '/tmp/build_install_toolchain.sh'


CMD ["/bin/bash"]

