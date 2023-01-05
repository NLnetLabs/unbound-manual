#!/bin/bash

# Manpages from and to directories
MANPAGES_DIR=manpages
MANPAGES_TARGET_DIR=../source/manpages  # Relative to MANPAGES_DIR

cd ${MANPAGES_DIR}
for f in *
do
    cp ${f} ${MANPAGES_TARGET_DIR}/
done
cd ..
