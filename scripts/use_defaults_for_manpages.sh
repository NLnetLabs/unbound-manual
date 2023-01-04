#!/bin/bash

# HTML manpages directory in readthedocs
MANPAGES_HTML_DIR=source/_build/html/manpages

# Unbound default values
UNBOUND_RUN_DIR=/usr/local/etc/unbound
UNBOUND_ROOTKEY_FILE=${UNBOUND_RUN_DIR}/root.key
UNBOUND_ROOTCERT_FILE=${UNBOUND_RUN_DIR}/icannbundle.pem
UNBOUND_CHROOT_DIR=${UNBOUND_RUN_DIR}
UNBOUND_PIDFILE=${UNBOUND_RUN_DIR}/unbound.pid
UNBOUND_USERNAME=unbound
ub_conf_file=${UNBOUND_RUN_DIR}/unbound.conf
DNSTAP_SOCKET_PATH=''



for f in ${MANPAGES_HTML_DIR}/*
do
    sed -i \
        -e 's/@UNBOUND_RUN_DIR\@/'${UNBOUND_RUN_DIR}'/' \
        -e 's/@UNBOUND_ROOTKEY_FILE\@/'${UNBOUND_ROOTKEY_FILE}'/' \
        -e 's/@UNBOUND_ROOTCERT_FILE\@/'${UNBOUND_ROOTCERT_FILE}'/' \
        -e 's/@UNBOUND_CHROOT_DIR\@/'${UNBOUND_CHROOT_DIR}'/' \
        -e 's/@UNBOUND_PIDFILE\@/'${UNBOUND_PIDFILE}'/' \
        -e 's/@UNBOUND_USERNAME\@/'${UNBOUND_USERNAME}'/' \
        -e 's/@ub_conf_file\@/'${ub_conf_file}'/' \
        -e 's/@DNSTAP_SOCKET_PATH\@/'${DNSTAP_SOCKET_PATH}'/' \
        ${f}
done
