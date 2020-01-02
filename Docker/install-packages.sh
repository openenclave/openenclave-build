#!/bin/bash
#
# Install packages - install packages from a directory using a package list 
#
#  install-packages.sh <package-list-file> <package-dir>
#

PACKAGE_LIST_FILE=$1
PACKAGE_DIR=$2

cat ${PACKAGE_LIST_FILE} | while read i 
do
    dpkg -i ${PACKAGE_DIR}/$i
done
   
