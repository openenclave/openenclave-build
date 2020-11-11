#!/bin/bash
set -x
. /home/$USER/.nix-profile/etc/profile.d/nix.sh

if [ $OE_SIMULATION ]
then 
OE_SIM="--argstr OE_SIM OE_SIMULATION=1"
fi

if [ $(uname -m) == "aarch64" ]
then
    LD_INTERPRETER="/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1"
elif [ $(uname -m) == "x86_64" ]
then
    LD_INTERPRETER="/lib64/ld-linux-x86-64.so.2"
else
	echo "Unsupported architecture $(uname -m)"
fi

nix-build -I. shell.nix --substituters 'https://cache.nixos.org' \
	    --argstr REV $BUILD_REV \
	    --argstr SHA $BUILD_SHA \
	    --argstr LD_INTERPRETER $LD_INTERPRETER \
	    --arg DO_CHECK $DO_CHECK ${OE_SIM}
set +x
