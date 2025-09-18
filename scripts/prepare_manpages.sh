#!/bin/bash
# Inputs:
#       $1
#               optional, if given points to a local unbound repository
#
#       UNBOUND_DEFAULT_VALUES (env)
#               optional, if defined it will replace placeholders with default
#               values for the online documentation (also for the local html
#               'localhtml' Sphinx build.
#
# For debugging this script you can have a look at the generated
# source/manpages/*.rst files when running 'make html' or 'make localhtml'.
# There you can spot what happens with all the UAHL sed expansions below.

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
#               ^__before__@@UAHL@pre.text@target-with space.dot@@__after__
# matchgroups:       \1              \2             \3               \4
#
# Notes:
#     o UAHL stands for Unbound Arbitrary Hover Link
#     o (^ is the line start, not the character)
#     o __before__ keeps track of any needed identation
#     o target allows for letters,digits,dashes,dots,underscores,spaces
#
# That line will be replaced with (skipping identation for clarity):
#
#  1.|     .. _pre.text.target-with space.dot:
#  2.|
#  3.|     .. |pre.text.target-with space.dot| raw:: html
#  4.|
#  5.|         <a class="headerlink" href="pre-text-target-with-space-dot" title="Link to this heading"></a>
#  6.|
#  7.|     target__after__ |pre.text.target-with space.dot|
#
#  Explanation:
#       o line 1, an RST link to that part of the document
#       o line 3, RST substitution definition to inline the raw html
#       o line 5, the raw html to create the hover link
#       o line 7, the text to render followed by the RST substitution
#
# Note that for the href we need to translate dots ('.'), underscores ('_') and
# spaces (' ') to dashes ('-') and use only lower case characters as per Sphinx
# behavior.
#
# Since all this generated text only makes sense for HTML, it has no
# influence on the troff man page output.
#
SED_MATCH_1='^\(.*\)'    # Group anything from the start of the line
SED_MATCH_2='\([^@]\+\)' # Group something that is not '@'
SED_MATCH_3='\([^@]\+\)' # Group something that is not '@'
SED_MATCH_4='\(.*\)'     # Group anything
SED_GEN_TARGET='\1.. _\2.\3:\n\n'
SED_GEN_SUBSTITUTE='\1.. |\2.\3| raw:: html\n\n'
SED_GEN_RAW_HTML='\1    <a class="headerlink" href="#\2.\3" title="Link to this heading"></a>\n\n'
SED_GEN_TEXT='\1\3\4 |\2.\3|'
SED_EXPAND_COMMAND="s?\
${SED_MATCH_1}@@UAHL@${SED_MATCH_2}@${SED_MATCH_3}@@${SED_MATCH_4}?\
${SED_GEN_TARGET}${SED_GEN_SUBSTITUTE}${SED_GEN_RAW_HTML}${SED_GEN_TEXT}?"

# Lowercase whatever is in our generated hrefs. It uses \L which is a GNU extension
SED_LOWERCASE_COMMAND='s/headerlink" href=\("[^"]*"\)/headerlink" href=\L\1/g'

# Replaces spaces, underscores and dots inside our generated href, with dashes
# Some explanation:
#     o :<letter> , sets a label
#     o ;         , combines commands in a single line
#     o t<letter> , tests if something was modified by the previous command and
#                   if it did, jumps to the label
SED_REPLACE_COMMON_MATCH='headerlink" href="\([^" ]*\)'
SED_REPLACE_COMMON_RESULT='headerlink" href="\1-'
SED_REPLACE_SPACE_IN_HREF_COMMAND="\
:a; s/${SED_REPLACE_COMMON_MATCH} /${SED_REPLACE_COMMON_RESULT}/;  ta;\
:b; s/${SED_REPLACE_COMMON_MATCH}_/${SED_REPLACE_COMMON_RESULT}/;  tb;\
:c; s/${SED_REPLACE_COMMON_MATCH}\./${SED_REPLACE_COMMON_RESULT}/; tc;"


for f in \
    ${MANPAGES_DIR}/libunbound.rst \
    ${MANPAGES_DIR}/unbound.rst \
    ${MANPAGES_DIR}/unbound-anchor.rst \
    ${MANPAGES_DIR}/unbound-checkconf.rst \
    ${MANPAGES_DIR}/unbound-control.rst \
    ${MANPAGES_DIR}/unbound-host.rst \
    ${MANPAGES_DIR}/unbound.conf.rst
do
    # 1. Create the hover links
    # 2. Lowercase the hrefs
    # 3. Replace dots, underscores, spaces with dashes
    sed \
        -e "${SED_EXPAND_COMMAND}" \
        -e "${SED_LOWERCASE_COMMAND}" \
        ${f} | \
        sed -e "${SED_REPLACE_SPACE_IN_HREF_COMMAND}" \
        > ${MANPAGES_TARGET_DIR}/$(basename $f)

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
