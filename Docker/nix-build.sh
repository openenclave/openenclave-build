#!/bin/bash
#/bin/bash ./nix-install.sh

. /home/$USER/.nix-profile/etc/profile.d/nix.sh 
nix-build shell.nix
