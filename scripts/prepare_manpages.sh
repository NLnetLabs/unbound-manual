#!/bin/bash
# Inputs:
#       $1
#               optional, if given points to a local unbound repository
#
#       UNBOUND_DEFAULT_VALUES (env)
#               optional, if defined it will replace placeholders with default
#               values for the online documentation (also for the local html
#               'localhtml' Sphinx build.

# If there is no first argument to this script (local unbound code repo),
# use the current directory to get the manpages linking to the Unbound git
# submodule.
UNBOUND_CODE_REPO="$1"

# Manpages from and to directories
if test -z "${UNBOUND_CODE_REPO}"
then
    # Man pages that link to the submodule
    MANPAGES_DIR="$(pwd)/manpages"
else
    # Man pages from the given Unbound code repository
    MANPAGES_DIR="${UNBOUND_CODE_REPO}/doc"
fi
MANPAGES_TARGET_DIR="$(pwd)/source/manpages"

# Unbound default values
UNBOUND_RUN_DIR=/usr/local/etc/unbound
UNBOUND_ROOTKEY_FILE=${UNBOUND_RUN_DIR}/root.key
UNBOUND_ROOTCERT_FILE=${UNBOUND_RUN_DIR}/icannbundle.pem
UNBOUND_CHROOT_DIR=${UNBOUND_RUN_DIR}
UNBOUND_PIDFILE=${UNBOUND_RUN_DIR}/unbound.pid
UNBOUND_USERNAME=unbound
ub_conf_file=${UNBOUND_RUN_DIR}/unbound.conf
DNSTAP_SOCKET_PATH=''

# The upcoming sed usage here is complicated and try to go around
# Sphinx/restructuredText limitation of providing arbitrary hover links.
# Hover links are very useful for the online documentation in order to
# share links to specific arbitrary options/segments/anything that uses
# this convention.
#
# Other in-built solutions from Sphinx/restructuredText are either ugly, don't
# give the desired result and/or generate non-deterministic links for options
# with the same name (not shareable as the link target could change between
# documentation builds. One such option is confval but currently (Sphinx 7.4)
# does not work properly for troff output and doesn't reliably work with
# options that share the same name.
#
# Anyway.
#
# The seds expect to see:
#
#               ^__before__@@UAHL@pre.text@target@@__after__
# matchgroups:       \1              \2     \3        \4
#
# UAHL stands for Unbound Arbitrary Hover Link
# __before__ keeps track of any needed identation
#
# That line will be replaced with (skipping identation for clarity):
#
#       .. _pre.text.target:
#
#       .. |pre.text.target| raw:: html
#
#           <a class="headerlink" href="pre-text-target" title="Link to this heading"></a>
#
#       target__after__ |pre.text.target|
#
# Note that for the href we need to translate dots ('.') to dashes ('-') as per
# Sphinx behavior.
#
# Since all this genearated text only makes sense for HTML, it has no
# influence on the troff man page output.
#
SED_MATCH_1='^\(.*\)'
SED_MATCH_2='\([^@]\+\)'
SED_MATCH_3='\([^@]\+\)'
SED_MATCH_4='\(.*\)'
SED_GEN_TARGET='\1.. _\2.\3:\n\n'
SED_GEN_SUBSTITUTE='\1.. |\2.\3| raw:: html\n\n'
SED_GEN_RAW_HTML='\1    <a class="headerlink" href="#\2.\3" title="Link to this heading"></a>\n\n'
SED_GEN_TEXT='\1\3\4 |\2.\3|'
SED_SCRIPT="s?\
${SED_MATCH_1}@@UAHL@${SED_MATCH_2}@${SED_MATCH_3}@@${SED_MATCH_4}?\
${SED_GEN_TARGET}${SED_GEN_SUBSTITUTE}${SED_GEN_RAW_HTML}${SED_GEN_TEXT}?"

for f in \
    ${MANPAGES_DIR}/libunbound.rst \
    ${MANPAGES_DIR}/unbound.rst \
    ${MANPAGES_DIR}/unbound-anchor.rst \
    ${MANPAGES_DIR}/unbound-checkconf.rst \
    ${MANPAGES_DIR}/unbound-control.rst \
    ${MANPAGES_DIR}/unbound-host.rst \
    ${MANPAGES_DIR}/unbound.conf.rst
do
    # Create the hover links.
    sed -e "${SED_SCRIPT}" ${f} \
    | sed '/headerlink" href="/ y/./-/' > ${MANPAGES_TARGET_DIR}/$(basename $f)

    # Fill in the default values.
    if test -n "${UNBOUND_DEFAULT_VALUES+x}"
    then
        sed \
            -e 's#@UNBOUND_RUN_DIR\@#'${UNBOUND_RUN_DIR}'#g' \
            -e 's#@UNBOUND_ROOTKEY_FILE\@#'${UNBOUND_ROOTKEY_FILE}'#g' \
            -e 's#@UNBOUND_ROOTCERT_FILE\@#'${UNBOUND_ROOTCERT_FILE}'#g' \
            -e 's#@UNBOUND_CHROOT_DIR\@#'${UNBOUND_CHROOT_DIR}'#g' \
            -e 's#@UNBOUND_PIDFILE\@#'${UNBOUND_PIDFILE}'#g' \
            -e 's#@UNBOUND_USERNAME\@#'${UNBOUND_USERNAME}'#g' \
            -e 's#@ub_conf_file\@#'${ub_conf_file}'#g' \
            -e 's#@DNSTAP_SOCKET_PATH\@#'${DNSTAP_SOCKET_PATH}'#g' \
            -i ${MANPAGES_TARGET_DIR}/$(basename $f)
    fi
done
