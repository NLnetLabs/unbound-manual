#!/bin/bash

# Manpages from and to directories
MANPAGES_DIR="$(pwd)/build/man"
MANPAGES_TARGET_DIR="$1/doc"

for f in \
    ${MANPAGES_DIR}/libunbound.3 \
    ${MANPAGES_DIR}/unbound.8 \
    ${MANPAGES_DIR}/unbound-anchor.8 \
    ${MANPAGES_DIR}/unbound-checkconf.8 \
    ${MANPAGES_DIR}/unbound-control.8 \
    ${MANPAGES_DIR}/unbound-host.1 \
    ${MANPAGES_DIR}/unbound.conf.5
do
    cp ${f} ${MANPAGES_TARGET_DIR}/$(basename $f).in
done
