#!/bin/bash
set -x
. /home/$USER/.nix-profile/etc/profile.d/nix.sh

if [ $OE_SIMULATION ]
then 
OE_SIM="--argstr OE_SIM OE_SIMULATION=1"
fi

nix-build -I. shell.nix --substituters 'https://cache.nixos.org' \
	    --argstr REV $BUILD_REV \
	    --argstr SHA $BUILD_SHA \
	    --arg DO_CHECK $DO_CHECK ${OE_SIM}
#
# We have built the nix environment, we need to export it 
# so we can use it in other projects. 
nix-store --dump-db >/output/oe-nix-store-$(date +%Y%j%H%M).nixdump

nix-shell -I. shell.nix --substituters 'https://cache.nixos.org' \
	    --argstr REV $BUILD_REV \
	    --argstr SHA $BUILD_SHA \
	    --argstr INTERACTIVE_SHELL 0 \
	    --arg DO_CHECK $DO_CHECK ${OE_SIM}


set +x
