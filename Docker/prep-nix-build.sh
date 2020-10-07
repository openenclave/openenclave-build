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
nix-channel --remove nixpkgs # Only get packages from our local nixpkgs via -I or NIX_PATH.
export NIX_PATH=$NIX_PKGS/..

#
# Some basic info for the log file.
#
pwd
id
pushd ./nixpkgs
git status
popd
#
# We got the derviation via nix instantiate, which calculated the tag from nixpkgs repo.
# which in turn is set to a known tag, not master, eg.
#  nix-instantiate -I. -E '(import <nixpkgs> {}).openssl'
# We are currently installing the buildinputs for openenclave as derivations 
# so we could audit the code. 
# outside this script we are configuring nix to keep-derivations so we can inspect them as 
# needed. With that, we can inspect source of all the build inputs if desired.

# We know what paths nix-instantiate will produce. We hard code them here
# to alert us if they change.
nix-instantiate -I. -E '(import <nixpkgs> {}).cmake'
nix-env -I. -i /nix/store/n7384b19nw1l0mnqzii6d7dg50jnkijd-cmake-3.18.2.drv
nix-instantiate -I. -E '(import <nixpkgs> {}).openssl'
nix-env -I. -i /nix/store/7abnxss4gz9r4ykrwiiw9paiprwcmlzn-openssl-1.1.1g.drv
nix-env -I. -i /nix/store/yg76yir7rkxkfz6p77w4vjasi3cgc0q6-gnumake-4.2.1 
nix-env -I. -i /nix/store/1kl6ms8x56iyhylb2r83lq7j3jbnix7w-binutils-2.31.1 
nix-env -I. --set-flag priority 5 binutils-2.31.1 
nix-env -I. -i /nix/store/dmxxhhl5yr92pbl17q1szvx34jcbzsy8-texinfo-6.5 
nix-env -I. -i /nix/store/g6c80c9s2hmrk7jmkp9przi83jpcs8c6-bison-3.5.4 
nix-env -I. -i /nix/store/qh2ppjlz4yq65cl0vs0m2h57x2cjlwm4-flex-2.6.4 
nix-env -I. -i /nix/store/6a6ilqysgz1gwfs0ahriw94q35vj84sy-vim-8.2.1123 
nix-env -I. -i /nix/store/z2709nq2dfbmq710dyf8ykjwsj3zk3ld-libffi-3.3 
nix-env -I. -i /nix/store/86832i5kfv4yyzj9y442ryl4l1s4wrwj-libpfm-4.10.1 
nix-env -I. -i /nix/store/fhsjz6advdlwa9lki291ra7s5aays9f9-libxml2-2.9.10 
nix-env -I. -i /nix/store/ki8k1a2pkpf862pxa0pms0j9mwjcb2xd-zlib-1.2.11-dev 
nix-instantiate -I. -E '(import <nixpkgs> {}).llvm'
nix-env -I. -i /nix/store/p93jc9z2910k2m69fgmqmlvj0w6k060g-llvm-7.1.0.drv
nix-env -I. --set-flag priority 10 llvm
nix-env -I. -i /nix/store/0iz74aawxl3gfyqkxygy43bw9zzl0jkb-musl-1.2.0-dev 
nix-instantiate -I. -E '(import <nixpkgs> {}).clang'
nix-env -I. -i /nix/store/abxsiydw99wlnaq5c800f3xxky86f45z-clang-7.1.0.drv
nix-env -I. --set-flag priority 20 clang
nix-env -I. -i  /nix/store/pvr7va4221w3fyya7lm6cxh5601fbdsa-valgrind-3.16.1-dev 
nix-env -I. -i  /nix/store/q13zmpbw9pmx32pcxjc9wr7c6qsk1nkl-valgrind-3.16.1-doc 
nix-env -I. -i  /nix/store/sn9i6iigyp58r4w7556c8p36xlm6hr2m-valgrind-3.16.1 
nix-instantiate -I. -E '(import <nixpkgs> {}).python3'
nix-env -I. -i  /nix/store/7qhg8hc7ycq5x2cs5jlg8s3fag0sbg1x-python3-3.8.5.drv
nix-instantiate -I. -E '(import <nixpkgs> {}).doxygen'
nix-env -I. -i /nix/store/rp9hgwjng1v0dks12y8bk27fndkck62b-doxygen-1.8.19.drv

#
# Make sure we don't go to cache by checking everything
nix-store -I. --verify --check-contents

set +x
