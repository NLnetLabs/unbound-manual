.. _doc_unbound_checkconf_manpage:

unbound-checkconf(8)
--------------------

.. raw:: html

    <pre class="man">unbound-checkconf(8)            unbound 1.13.2            unbound-checkconf(8)



    <b>NAME</b>
       unbound-checkconf - Check unbound configuration file for errors.

    <b>SYNOPSIS</b>
       <b>unbound-checkconf</b> [<b>-h</b>] [<b>-f</b>] [<b>-o</b> <i>option</i>] [<i>cfgfile</i>]

    <b>DESCRIPTION</b>
       <b>Unbound-checkconf</b>  checks the configuration file for the <a href="/manpages/unbound.html"><i>unbound</i>(8)</a> DNS
       resolver for syntax and other errors.  The config file  syntax  is  de-
       scribed in <a href="/manpages/unbound.conf.html"><i>unbound.conf</i>(5)</a>.

       The available options are:

       <b>-h</b>     Show the version and commandline option help.

       <b>-f</b>     Print full pathname, with chroot applied to it.  Use with the -o
              option.

       <b>-o</b> <i>option</i>
              If given, after checking the config file the value of  this  op-
              tion  is  printed to stdout.  For "" (disabled) options an empty
              line is printed.

       <i>cfgfile</i>
              The config file  to  read  with  settings  for  unbound.  It  is
              checked.  If omitted, the config file at the default location is
              checked.

    <b>EXIT</b> <b>CODE</b>
       The unbound-checkconf program exits with status code 1 on error, 0  for
       a correct config file.

    <b>FILES</b>
       <i>/usr/local/etc/unbound/unbound.conf</i>
              unbound configuration file.

    <b>SEE</b> <b>ALSO</b>
       <a href="/manpages/unbound.conf.html"><i>unbound.conf</i>(5)</a>, <a href="/manpages/unbound.html"><i>unbound</i>(8)</a>.



    NLnet Labs                       Aug 12, 2021             unbound-checkconf(8)
    </pre>