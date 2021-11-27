.. _doc_unbound_manpage:

unbound(8)
----------

.. raw:: html

    <pre class="man">unbound(8)                      unbound 1.13.2                      unbound(8)



    <b>NAME</b>
       <b>unbound</b> - Unbound DNS validating resolver 1.13.2.

    <b>SYNOPSIS</b>
       <b>unbound</b> [<b>-h</b>] [<b>-d</b>] [<b>-p</b>] [<b>-v</b>] [<b>-c</b> <i>cfgfile</i>]

    <b>DESCRIPTION</b>
       <b>Unbound</b> is a caching DNS resolver.

       It  uses a built in list of authoritative nameservers for the root zone
       (.), the so called root hints.  On receiving a DNS query  it  will  ask
       the root nameservers for an answer and will in almost all cases receive
       a delegation to a top level domain (TLD) authoritative nameserver.   It
       will  then ask that nameserver for an answer.  It will recursively con-
       tinue until an answer is found or no answer  is  available  (NXDOMAIN).
       For performance and efficiency reasons that answer is cached for a cer-
       tain time (the answer's time-to-live or TTL).  A second query  for  the
       same  name  will  then be answered from the cache.  Unbound can also do
       DNSSEC validation.

       To use a locally running <b>Unbound</b> for resolving put

             nameserver 127.0.0.1

       into <i>resolv.conf</i>(5).

       If authoritative DNS is needed as well using <i>nsd</i>(8), careful  setup  is
       required  because authoritative nameservers and resolvers are using the
       same port number (53).

       The available options are:

       <b>-h</b>     Show the version number and commandline option help, and exit.

       <b>-c</b> <i>cfgfile</i>
              Set the config file with settings for unbound to read instead of
              reading  the  file  at  the default location, /usr/local/etc/un-
              bound/unbound.conf. The syntax is described in <a href="/manpages/unbound.conf/"><i>unbound.conf</i>(5)</a>.

       <b>-d</b>     Debug flag: do not fork into the background, but  stay  attached
              to  the  console.   This flag will also delay writing to the log
              file until the thread-spawn time, so that most config and  setup
              errors  appear  on  stderr. If given twice or more, logging does
              not switch to the log file or to syslog, but  the  log  messages
              are printed to stderr all the time.

       <b>-p</b>     Don't  use  a pidfile.  This argument should only be used by su-
              pervision systems which can ensure that only one instance of un-
              bound will run concurrently.

       <b>-v</b>     Increase verbosity. If given multiple times, more information is
              logged.  This is in addition to the verbosity (if any) from  the
              config file.

       <b>-V</b>     Show the version number and build options, and exit.

    <b>SEE</b> <b>ALSO</b>
       <a href="/manpages/unbound.conf/"><i>unbound.conf</i>(5)</a>, <a href="/manpages/unbound-checkconf/"><i>unbound-checkconf</i>(8)</a>, <i>nsd</i>(8).

    <b>AUTHORS</b>
       <b>Unbound</b>  developers  are mentioned in the CREDITS file in the distribu-
       tion.



    NLnet Labs                       Aug 12, 2021                       unbound(8)
    </pre>