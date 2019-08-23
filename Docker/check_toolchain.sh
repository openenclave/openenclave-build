#!/bin/bash

set -x
# Check the sums of the new toolchain against the old one. We do this to ensure that
# the sources reflect the code and vice versa.  In order to be undetectably hacked we
# would have to have 2 corrupted inputs rather than one.
#
cd /build;

for i in */bin
do
   pushd .
   cd $i
   for p in *
   do
      f=`basename ${p}`
      if [ -x /usr/local/bin/${f} ]; then
          sumout=(`sha256sum ${f} /usr/local/bin/${f} `)

          if [ ${sumout[0]} != ${sumout[2]} ]; then
              printf "%s is not consistent checksum %s != %s\n" ${sumout[1]} ${sumout[0]} ${sumout[2]}
          fi
      fi
   done
   popd
done
set +x
