#!/bin/bash
#/bin/bash ./nix-install.sh

. /home/$USER/.nix-profile/etc/profile.d/nix.sh 
nix-build -I. shell.nix --substituters 'https://cache.nixos.org'
