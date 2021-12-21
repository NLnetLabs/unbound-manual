unbound(8)
==========

Synopsis
--------

:command:`unbound` [:option:`-h`] [:option:`-d`] [:option:`-p`] [:option:`-v`]
[:option:`-c` ``cfgfile``]

Description
-----------

:command:`Unbound` is a caching DNS resolver.

It uses a built in list of authoritative nameservers for the root zone (``.``),
the so called root hints. On receiving a DNS query it will ask the root
nameservers for an answer and will in almost all cases receive a delegation to a
top level domain (TLD) authoritative nameserver. It will then ask that
nameserver for an answer. It will recursively continue until an answer is found
or no answer is available (NXDOMAIN). For performance and efficiency reasons
that answer is cached for a certain time (the answer's time-to-live or TTL). A
second query for the same name will then be answered from the cache. Unbound can
also do DNSSEC validation.

To use a locally running :command:`Unbound` for resolving put

.. code-block:: text

   nameserver 127.0.0.1

into :manpage:`resolv.conf(5)`.

If authoritative DNS is needed as well using *nsd(8)*, careful setup is required
because authoritative nameservers and resolvers are using the same port number
(53).

The available options are:

.. option:: -h 

 Show the version number and commandline option help, and exit.

.. option:: -c cfgfile

   Set the config file with settings for unbound to read instead of reading the
   file at the default location, :file:`/usr/local/etc/unbound/unbound.conf`.
   The syntax is described in :manpage:`unbound.conf(5)`.

.. option:: -d

   Debug flag: do not fork into the background, but stay attached to the
   console. This flag will also delay writing to the log file until the
   thread-spawn time, so that most config and setup errors appear on stderr. If
   given twice or more, logging does not switch to the log file or to syslog,
   but the log messages are printed to stderr all the time.

.. option:: -p  
   
   Don't use a pidfile. This argument should only be used by supervision systems
   which can ensure that only one instance of unbound will run concurrently.

.. option:: -v  
   
   Increase verbosity. If given multiple times, more information is logged. This
   is in addition to the verbosity (if any) from the config file.

.. option:: -V  
   
   Show the version number and build options, and exit.

See Also
--------

:manpage:`unbound.conf(5)`, :manpage:`unbound-checkconf(8)`, *nsd(8)*.