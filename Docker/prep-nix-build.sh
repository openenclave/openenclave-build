#!/bin/bash

#
# Setup a host for docker builds using nix. This assumes nix has been installed
# Setting up the nix build on the host as opposed to completely restricting the build
# infrastructure means we don't need to set up libsgx infrastructure in the container
# and can instead run tests separately. This is desirable as many build machines don't support
# SGX, or at least don't have it enabled. 
#
# prep-nix-build.sh $nixpkgs_dest
#
#
# First clone the nixpkgs repo. With a little discipline we can 
# keep all package accesses on this machine.
#
export NIX_PKGS_REPO=https://github.com/yakman2020/nixpkgs.git

export NIX_PKGS=$1
#export NIX_PKGS=/home/azureuser/nixpkgs

export NIX_PKGS_BRANCH=release-20.09

if [ -d ${NIX_PKGS} ]
then
    # We should checkout a specific tag here
    pushd ${NIX_PKGS} ; git pull ; git checkout ${NIX_PKGS_BRANCH} ; popd
else
    git clone https://github.com/yakman2020/nixpkgs.git ${NIX_PKGS}
    pushd ${NIX_PKGS} ; git pull ; git checkout ${NIX_PKGS_BRANCH} ; popd
fi

# Install the packages 

set -x
source /home/azureuser/.nix-profile/etc/profile.d/nix.sh 
nix-channel --remove nixpkgs # Only get packages from nixstore
export NIX_PATH=$NIX_PKGS/..
nix-env -f ${NIX_PKGS} -i /nix/store/70y1dj79fq7f6486y8clrgngrcfr303q-cmake-3.18.2
nix-env -f ${NIX_PKGS} -i /nix/store/aqafh2kgahm2hv3nkihmgnvsg7y4ihcj-openssl-1.1.1g
nix-env -f ${NIX_PKGS} -i /nix/store/yg76yir7rkxkfz6p77w4vjasi3cgc0q6-gnumake-4.2.1 
nix-env -f ${NIX_PKGS} -i /nix/store/1kl6ms8x56iyhylb2r83lq7j3jbnix7w-binutils-2.31.1 
nix-env -f ${NIX_PKGS} --set-flag priority 10 binutils-2.31.1 
nix-env -f ${NIX_PKGS} -i /nix/store/dmxxhhl5yr92pbl17q1szvx34jcbzsy8-texinfo-6.5 
nix-env -f ${NIX_PKGS} -i /nix/store/g6c80c9s2hmrk7jmkp9przi83jpcs8c6-bison-3.5.4 
nix-env -f ${NIX_PKGS} -i /nix/store/qh2ppjlz4yq65cl0vs0m2h57x2cjlwm4-flex-2.6.4 
nix-env -f ${NIX_PKGS} -i /nix/store/6a6ilqysgz1gwfs0ahriw94q35vj84sy-vim-8.2.1123 
nix-env -f ${NIX_PKGS} -i /nix/store/z2709nq2dfbmq710dyf8ykjwsj3zk3ld-libffi-3.3 
nix-env -f ${NIX_PKGS} -i /nix/store/86832i5kfv4yyzj9y442ryl4l1s4wrwj-libpfm-4.10.1 
nix-env -f ${NIX_PKGS} -i /nix/store/fhsjz6advdlwa9lki291ra7s5aays9f9-libxml2-2.9.10 
nix-env -f ${NIX_PKGS} -i /nix/store/ki8k1a2pkpf862pxa0pms0j9mwjcb2xd-zlib-1.2.11-dev 
nix-env -f ${NIX_PKGS} -i /nix/store/rcn31jcz3ppnv28hjyq7m2hwy4dqc2jb-clang-7.1.0-lib 
nix-env -f ${NIX_PKGS} -i /nix/store/sc35z1gh4y58n2p0rz9psi33scwh4nv2-llvm-7.1.0 
nix-env -f ${NIX_PKGS} --set-flag priority 10 llvm-7.1.0  
nix-env -f ${NIX_PKGS} -i /nix/store/8inh7bv9hnyjdmrviimmwcw4vr8c6pji-llvm-binutils-7.1.0 
nix-env -f ${NIX_PKGS} -i /nix/store/0iz74aawxl3gfyqkxygy43bw9zzl0jkb-musl-1.2.0-dev 
nix-env -f ${NIX_PKGS} -i /nix/store/jzgz21bgily2g8j8nnx04zv5y69rld6f-clang-7.1.0 
nix-env -f ${NIX_PKGS} -i  /nix/store/pvr7va4221w3fyya7lm6cxh5601fbdsa-valgrind-3.16.1-dev 
nix-env -f ${NIX_PKGS} -i  /nix/store/q13zmpbw9pmx32pcxjc9wr7c6qsk1nkl-valgrind-3.16.1-doc 
nix-env -f ${NIX_PKGS} -i  /nix/store/sn9i6iigyp58r4w7556c8p36xlm6hr2m-valgrind-3.16.1 
nix-env -f ${NIX_PKGS} -i  /nix/store/g4ihsbcnxgsdy4h05s7iiwxcjjydpsyj-python3-3.9.0b5 
nix-env -f ${NIX_PKGS} -i /nix/store/spah9k7ald89hwhngg3zmvx6kqlbq218-doxygen-1.8.19

#
# Make sure we don't go to cache by checking everything
nix-store -f ${NIX_PKGS} --verify

set +x
