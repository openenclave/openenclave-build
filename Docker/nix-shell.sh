#!/bin/bash
set -x
. /home/$USER/.nix-profile/etc/profile.d/nix.sh
nix-shell -I. shell.nix --substituters 'https://cache.nixos.org' --argstr REV $BUILD_REV --argstr SHA $BUILD_SHA --arg DO_CHECK $DO_CHECK
set +x
