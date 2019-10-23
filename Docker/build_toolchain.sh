#!/bin/bash
#
# Build a trusted toolchain into the bootstrap build container. 
#

function verify_signatures() {

    declare -a source_tar_sigs=( \
        "/tmp/cfe-7.1.0.src.tar.xz.sig" \
        "/tmp/clang-tools-extra-7.1.0.src.tar.xz.sig" \
        "/tmp/compiler-rt-7.1.0.src.tar.xz.sig" \
        "/tmp/libcxx-7.1.0.src.tar.xz.sig" \
        "/tmp/libunwind-7.1.0.src.tar.xz.sig" \
        "/tmp/lld-7.1.0.src.tar.xz.sig" \
        "/tmp/llvm-7.1.0.src.tar.xz.sig" )

    gpg --import /tmp/tstellar-gpg-key.asc

    for this_sig in "${source_tar_sigs[@]}"
    do
        rslt=`(gpg --status-fd 1 --verify ${this_sig} 2>/dev/null | grep VALIDSIG)`
        if (echo $rslt | grep -q VALIDSIG) ; then
            echo "verified signature " ${this_sig} >&2
        else
            echo "could not verify signature " ${this_sig} >&2
            return 0
        fi
    done

    return 1
}


function build_install_toolchain() {
    pushd .
    rm ${CMAKE_SRC_DIR}/CMakeCache.txt
    rm ${CMAKE_BUILD_DIR}/CMakeCache.txt
    if [ ! -f /usr/local/bin/cmake ];
    then
        # cmake
        cd ${CMAKE_SRC_DIR}
        ./bootstrap
        if [ $? -ne 0 ]
        then
            echo "cmake cmake failed" >&2
            return $?
        fi
        make -j 8
        make install
        popd
    fi
    pushd .
    mkdir -p ${CMAKE_BUILD_DIR}
    cd  ${CMAKE_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" ${CMAKE_SRC_DIR}
    if [ $? -ne 0 ]
    then
    echo "cmake cmake failed" >&2
        return $?
    fi

    make -j 8
    if [ $? -ne 0 ]
    then
    echo "cmake make failed" >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
    echo "cmake make install failed" >&2
        return $?
    fi
    popd
    
    pushd .
    # llvm tools
    mkdir -p ${LLVM_BUILD_DIR}
    cd ${LLVM_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="X86"  ${CMAKE_FLAGS}  ${LLVM_SRC_DIR}
    if [ $? -ne 0 ]
    then
        echo "llvm cmake failed" >&2
        return $?
    fi

    make -j 8
    if [ $? -ne 0 ]
    then
        echo "llvm make failed" >&2
        return $?
    fi

    # We have to strip the following files in order to get a reproducible result
    bin/llvm-strip -strip-all bin/llvm-config
    cp bin/llvm-config /usr/local/bin/llvm-config
    if [ $? -ne 0 ]
    then
        echo "llvm strip failed" >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
        echo "llvm make install failed" >&2
        return $?
    fi

    popd
    
    # llvm linker
    pushd .
    mkdir -p ${LLD_BUILD_DIR}
    cd ${LLD_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" ${CMAKE_FLAGS}  ${LLD_SRC_DIR}
    if [ $? -ne 0 ]
    then
        echo "lld cmake failed" >&2
        return $?
    fi

    make -j 8
    if [ $? -ne 0 ]
    then
        echo "lld make failed" >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
        echo "lld make install failed" >&2
        return $?
    fi

    popd
    
    # clang compiler
    pushd .
    mkdir -p ${CLANG_BUILD_DIR}
    cd ${CLANG_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" -DLLVM_CXX_STD="c++17" ${CMAKE_FLAGS}  ${CLANG_SRC_DIR}
    if [ $? -ne 0 ]
    then
        echo "clang cmake failed" >&2
        return $?
    fi

    make -j 8
    if [ $? -ne 0 ]
    then
        echo "clang make failed" >&2 >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
        echo "clang make install failed" >&2
        return $?
    fi

    popd
    
    # clang runtime
    pushd .
    mkdir -p /build/compiler-rt-7.1.0.src
    cd /build/compiler-rt-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"  -DLLVM_CXX_STD="c++17"  ${CMAKE_FLAGS} /src/compiler-rt-7.1.0.src 
    if [ $? -ne 0 ]
    then
        echo "clang-rt cmake failed" >&2
        return $?
    fi

    make -j 8
    if [ $? -ne 0 ]
    then
        echo "clang-rt make failed" >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
        echo "clang-rt make install failed" >&2
        return $?
    fi
    #
    # Python needs stuff in a slightly different location
    #
    mkdir -p /usr/local/lib/clang/7.1.0/lib
    cp -r lib/linux /usr/local/lib/clang/7.1.0/lib

    popd
    
    # libc++
    pushd .
    mkdir -p /build/libcxx-7.1.0.src
    cd /build/libcxx-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"   -DLLVM_CXX_STD="c++17"  ${CMAKE_FLAGS} /src/libcxx-7.1.0.src
    if [ $? -ne 0 ]
    then
        echo "libcxx cmake failed" >&2
        return $?
    fi

    make -j 8
    if [ $? -ne 0 ]
    then
        echo "libcxx make failed" >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
        echo "libcxx make install failed" >&2
        return $?
    fi

    popd
    
    # libunwind
    pushd .
    mkdir -p /build/libunwind-7.1.0.src
    cd /build/libunwind-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"  -DLLVM_CXX_STD="c++17" ${CMAKE_FLAGS} /src/libunwind-7.1.0.src
    if [ $? -ne 0 ]
    then
        echo "libunwind cmake failed" >&2
        return $?
    fi

    make -j 8
    if [ $? -ne 0 ]
    then
        echo "libunwind make failed" >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
        echo "libunwind make install failed" >&2
        return $?
    fi

    popd
    return 0
}


# Builds additional tools: ninja, ocaml, git
# Though we have these components installed already, but we want to make sure we build them from
#  source using the trusted toolchain. 
#
# The bootstrapping sequence of events is :
#
#  1. Bring up the bootstrap environment (docker build -f ./Dockerfile.bootstrap)
#  2. Compile the toolchain from known source (validate the source)
#  3. Install the verified toolchain, built from the bootastrap toolchain.
#  4. Compile the toolchain again using the verified toolchain. 
#  5. Install the now verified toolchain, built from the verified toolchain.
#  5. Compile the toolchain again using the verified toolchain. 
#  6. Check the expected sha256sums. They should be identical.
#  7. Build additional tools using the trusted toolchain
#  8. Install the additional tools 
#  9. Build additional tools (again) using the trusted toolchain
# 10. Check the tools against the previous build. They should be identical
#
#  Once the  bootstrap environment is established, we can docker export to a tar file, and 
#  escrow the tar file and (separately) a sha256sum of the tar file.  Then we can docker build Dockerfile.build
#  which will pull the tar file from escrow and load it into the image after checking the sum. 
#
#
function build_tools() {

    cd /src
    pushd .
    # first build python
    cd cpython
    ./configure --enable-optimizations
    make -j 8
    if [ $? -ne 0 ]
    then
        echo "cpython make failed" >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
        echo "cpython make install failed" >&2
        return $?
    fi
    if [ ! -f /usr/local/bin/python ] 
    then
        ln -s /usr/local/bin/python3 /usr/local/bin/python
    fi

    popd
    
    # ninja
    pushd .
    cd ninja
    ./bootstrap.py
    ninja
    if [ $? -ne 0 ]
    then
        echo "ninja build failed" >&2
        return $?
    fi

    ninja -t install
    if [ $? -ne 0 ]
    then
        echo "ninja install failed" >&2
        return $?
    fi

    popd

    # ocaml 
    pushd .
    cd ocaml
    ./configure 
    make world.opt
    if [ $? -ne 0 ]
    then
        echo "ocaml build failed" >&2
        return $?
    fi

    make install
    if [ $? -ne 0 ]
    then
        echo "ocaml install failed" >&2
        return $?
    fi

    popd
}


#
# clear and rebuild the toolchain, then check the sha256sums agains each binary 
#
function build_check_toolchain() {
    pushd .
    
    # llvm tools
    mkdir -p ${LLVM_BUILD_DIR}
    cd ${LLVM_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" -DLLVM_TARGETS_TO_BUILD="X86"  ${CMAKE_FLAGS}  ${LLVM_SRC_DIR}
    make -j 8
   # CHECK make install
    
    
    # llvm linker
    mkdir -p ${LLD_BUILD_DIR}
    cd ${LLD_BUILD_DIR}
    rm -rf ./*
    CMAKE_CXX_FLAGS="-std=c++17"  cmake -G "Unix Makefiles" ${CMAKE_FLAGS}  ${LLD_SRC_DIR}
    make -j 8
    make install
    
    # clang compiler
    mkdir -p ${CLANG_BUILD_DIR}
    cd ${CLANG_BUILD_DIR}
    rm -rf ./*
    cmake -G "Unix Makefiles" -DLLVM_CXX_STD="c++17" ${CMAKE_FLAGS}  ${CLANG_SRC_DIR}
    make -j 8
    
    # clang runtime
    mkdir -p /build/compiler-rt-7.1.0.src
    cd /build/compiler-rt-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"  -DLLVM_CXX_STD="c++17"  ${CMAKE_FLAGS} /src/compiler-rt-7.1.0.src 
    make -j 8
    
    # libc++
    mkdir -p /build/libcxx-7.1.0.src
    cd /build/libcxx-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"   -DLLVM_CXX_STD="c++17"  ${CMAKE_FLAGS} /src/libcxx-7.1.0.src
    make -j 8
    
    # libunwind
    mkdir -p /build/libunwind-7.1.0.src
    cd /build/libunwind-7.1.0.src
    rm -rf ./*
    cmake -G "Unix Makefiles"  -DLLVM_CXX_STD="c++17" ${CMAKE_FLAGS} /src/libunwind-7.1.0.src
    make -j 8
    
    popd

}


SRC=/src
# Builds and installs tool chain. Initally we use an untrusted bootstrap compiler, then replace the 
# untrusted compiler with one built from trusted sources, then rebuild again and check the sha256sum of 
# the output against the original. If they don't match, eitherthe sources are bogus, or the compiler is 
# bogus, or both. But either way, the build would not pass. 
#
# Though the original bootstrap compiler is untrusted, it should be the result of the trusted build
# process from the previous iteration.


CMAKE_SRC_DIR=/src/cmake-3.15.1
CMAKE_BUILD_DIR=/build/cmake-3.15.1
export CMAKE_SRC_DIR
export CMAKE_BUILD_DIR

LLVM_SRC_DIR=/src/llvm-7.1.0.src
LLVM_BUILD_DIR=/build/llvm-7.1.0.src
export LLVM_SRC_DIR
export LLVM_BUILD_DIR

LLD_SRC_DIR=/src/lld-7.1.0.src
LLD_BUILD_DIR=/build/lld-7.1.0.src
export LLD_SRC_DIR
export LLD_BUILD_DIR

CLANG_SRC_DIR=/src/cfe-7.1.0.src
CLANG_BUILD_DIR=/build/cfe-7.1.0.src
export CLANG_SRC_DIR
export CLANG_BUILD_DIR


# we only want to build the current arch, not cross compile
LLVM_TARGET_ARCH="host"
export LLVM_TARGET_ARCH

#verify_signatures

build_install_toolchain
if [ $? -ne 0 ]
then
   echo "build install toolchain with gcc failed" >&2
   exit 1
fi

# We built the toolchain with the default installed tools. We do not trust this toolchain
# and it will not reproduce if it was built with gcc, which embeds time and data stamps etc.
# So, we use this toolchain, built with known sources, to build the same toolchain and install it.
# We can then build it again using the new semi-trusted toolchain and compare to a third build

if [ -f /usr/local/bin/clang ];
then
    CC=/usr/local/bin/clang
    CXX=/usr/local/bin/clang++
    LD=/usr/local/bin/ld.lld
    CFLAGS="-fPIC -fuse-ld=/usr/local/bin/ld.lld"
    CXXFLAGS="-std=c++17 -stdlib=libstdc++ -fPIC -fuse-ld=/usr/local/bin/ld.lld "

    CMAKE_FLAGS=" -DLLVM_TARGET_ARCH="host" -DLLVM_ENABLE_LLD=1 -DCMAKE_BUILD_TYPE=Release"
    export CC
    export CXX
    export LD
    export CFLAGS
    export CXXFLAGS
    export CMAKE_FLAGS
fi
#
# this will overwrite the gcc built toolchain
build_install_toolchain
if [ $? -ne 0 ]
then
   echo "build install toolchain with clang failed" >&2
   exit 1
fi

# First build of the tools, with clang as compiler
build_tools

#
/tmp/buildinfo/build_buildinfo

#  we compare the results of the new build against the buildinfo. If there are differences we complain and 
# fail
#  
build_install_toolchain

# Second build of the tools, with clang as compiler should be same sums
build_tools

/tmp/buildinfo/check_build
