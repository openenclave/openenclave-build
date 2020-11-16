#!/bin/bash
. /home/$USER/.nix-profile/etc/profile.d/nix.sh

if [ $OE_SIMULATION ]
then 
OE_SIM="--argstr OE_SIM OE_SIMULATION=1"
fi

nix-shell -I. shell.nix --substituters 'https://cache.nixos.org' \
	    --argstr REV $BUILD_REV \
	    --argstr SHA $BUILD_SHA \
	    --argstr INTERACTIVE_SHELL 1 \
	    --arg DO_CHECK $DO_CHECK ${OE_SIM}
