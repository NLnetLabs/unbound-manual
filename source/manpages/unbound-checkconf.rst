unbound-checkconf(8)
====================

Synopsis
--------

:command:`unbound-checkconf` [:option:`-h`] [:option:`-f`] [:option:`-o`
``option``] cfgfile

Description
-----------

:command:`Unbound-checkconf` checks the configuration file for the
:doc:`/manpages/unbound` DNS resolver for syntax and other errors. The config file
syntax is described in :doc:`/manpages/unbound.conf`.

The available options are:

.. option:: -h

    Show the version and commandline option help.

.. option:: -f
    
    Print full pathname, with chroot applied to it. Use with the :option:`-o`
    option.

.. option:: -o option

    If given, after checking the config file the value of this option is printed
    to stdout. For ``""`` (disabled) options an empty line is printed.

.. option:: cfgfile

    The config file to read with settings for unbound. It is checked. If
    omitted, the config file at the default location is checked.

Exit Code
---------

The :command:`unbound-checkconf` program exits with status code 1 on error, 0
for a correct config file.

Files
-----

/usr/local/etc/unbound/unbound.conf
    unbound configuration file.

See Also
--------

:doc:`/manpages/unbound.conf`, :doc:`/manpages/unbound`.
