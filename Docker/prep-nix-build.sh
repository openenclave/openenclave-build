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
#export NIX_PKGS_BRANCH=acc-test

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
nix-instantiate -I. -E '(import <nixpkgs> {}).gnumake'
nix-env -I. -i /nix/store/jg96nngpqyd6ajcqm5jfjz6gv3gfcdq2-gnumake-4.3.drv
nix-instantiate -I. -E '(import <nixpkgs> {}).binutils'
nix-env -I. -i /nix/store/ixj2lbxy9mhjw9l554cczl36m4k7af0v-binutils-wrapper-2.31.1.drv
nix-env -I. --set-flag priority 5 binutils-2.31.1 
nix-instantiate -I. -E '(import <nixpkgs> {}).llvm'
nix-env -I. -i /nix/store/p93jc9z2910k2m69fgmqmlvj0w6k060g-llvm-7.1.0.drv
nix-env -I. --set-flag priority 10 llvm
nix-instantiate -I. -E '(import <nixpkgs> {}).clang'
nix-env -I. -i /nix/store/abxsiydw99wlnaq5c800f3xxky86f45z-clang-7.1.0.drv
nix-env -I. --set-flag priority 20 clang
nix-instantiate -I. -E '(import <nixpkgs> {}).python3'
nix-env -I. -i  /nix/store/7qhg8hc7ycq5x2cs5jlg8s3fag0sbg1x-python3-3.8.5.drv
nix-instantiate -I. -E '(import <nixpkgs> {}).doxygen'
nix-env -I. -i /nix/store/rp9hgwjng1v0dks12y8bk27fndkck62b-doxygen-1.8.19.drv
nix-instantiate -I. -E '(import <nixpkgs> {}).dpkg'
nix-env -I. -i /nix/store/yk7v269xb05hvybw75c66jpfqvlfy3b8-dpkg-1.20.5.drv
# for debug only
nix-env -I. -i /nix/store/6a6ilqysgz1gwfs0ahriw94q35vj84sy-vim-8.2.1123 

#
# Make sure we don't go to cache by checking everything
nix-store -I. --verify --check-contents

set +x
