#!/bin/bash

#
# We fix the user name and id or else the tar files in the deb won't match from location to location. It is possible
# that a build system requires a different user name and id. If so, then they need to ensure that those ids are 
# used consistently or the build won't be reporducible, at least at the level of the .deb.
export BUILD_USER=azureuser
export BUILD_USER_ID=1000
export BUILD_USER_HOME=/home/azureuser


docker build -f Dockerfile.nix --build-arg BUILD_USER=$BUILD_USER --build-arg BUILD_USER_ID=$BUILD_USER_ID --build-arg BUILD_USER_HOME=$BUILD_USER_HOME --no-cache . -t openenclave-build
