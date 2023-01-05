#!/bin/bash

# Manpages from and to directories
MANPAGES_DIR=manpages
MANPAGES_TARGET_DIR=../source/manpages  # Relative to MANPAGES_DIR

# Unbound default values
UNBOUND_RUN_DIR=/usr/local/etc/unbound
UNBOUND_ROOTKEY_FILE=${UNBOUND_RUN_DIR}/root.key
UNBOUND_ROOTCERT_FILE=${UNBOUND_RUN_DIR}/icannbundle.pem
UNBOUND_CHROOT_DIR=${UNBOUND_RUN_DIR}
UNBOUND_PIDFILE=${UNBOUND_RUN_DIR}/unbound.pid
UNBOUND_USERNAME=unbound
ub_conf_file=${UNBOUND_RUN_DIR}/unbound.conf
DNSTAP_SOCKET_PATH=''

cd ${MANPAGES_DIR}
for f in *
do
    sed \
        -e 's#@UNBOUND_RUN_DIR\@#'${UNBOUND_RUN_DIR}'#g' \
        -e 's#@UNBOUND_ROOTKEY_FILE\@#'${UNBOUND_ROOTKEY_FILE}'#g' \
        -e 's#@UNBOUND_ROOTCERT_FILE\@#'${UNBOUND_ROOTCERT_FILE}'#g' \
        -e 's#@UNBOUND_CHROOT_DIR\@#'${UNBOUND_CHROOT_DIR}'#g' \
        -e 's#@UNBOUND_PIDFILE\@#'${UNBOUND_PIDFILE}'#g' \
        -e 's#@UNBOUND_USERNAME\@#'${UNBOUND_USERNAME}'#g' \
        -e 's#@ub_conf_file\@#'${ub_conf_file}'#g' \
        -e 's#@DNSTAP_SOCKET_PATH\@#'${DNSTAP_SOCKET_PATH}'#g' \
        ${f} > ${MANPAGES_TARGET_DIR}/${f}
done
cd ..
