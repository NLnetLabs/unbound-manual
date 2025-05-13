#!/bin/bash

# Manpages from and to directories
MANPAGES_DIR="$1/doc"
MANPAGES_TARGET_DIR="$(pwd)/source/manpages"

for f in \
    ${MANPAGES_DIR}/libunbound.rst \
    ${MANPAGES_DIR}/unbound.rst \
    ${MANPAGES_DIR}/unbound-anchor.rst \
    ${MANPAGES_DIR}/unbound-checkconf.rst \
    ${MANPAGES_DIR}/unbound-control.rst \
    ${MANPAGES_DIR}/unbound-host.rst \
    ${MANPAGES_DIR}/unbound.conf.rst
do
    cp ${f} ${MANPAGES_TARGET_DIR}/
done
