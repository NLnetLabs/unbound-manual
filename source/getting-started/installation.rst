Installation
============

Compiling
---------

If your distribution package manager has a package for unbound you can
skip this step, just install the package with your package manager.

To compile the software you need to have ``openssl``, and its include files
(from a package often called ``openssl-devel``).
Run ``./configure [options]; make; make install``

If you do not have the ``libldns`` library installed, a version is included
with the unbound source tarball, which is automatically used.

Options for configure.  You can customize the default config locations for
various files and directories, as well as the install location for the
program with ``--prefix=/usr/local``.  You can specify
``--with-ldns=dir`` or ``--with-libevent=dir`` or
``--with-ssl=dir`` to link with the library at that location.
Unless you want to tweak things, no options are needed for ``./configure``.

On some BSD systems you have to use gmake instead of make.

You can install with ``make install``, uninstall with ``make uninstall``.
The uninstall does not remove the config file.

In the contrib directory in the unbound source are sample rc.d scripts
for unbound (for BSD and Linux type systems).

Setup
-----

The config file is copied into ``/usr/local/etc/unbound/unbound.conf``
but some distributions may put it in ``/etc/unbound/unbound.conf``
or ``/etc/unbound.conf``.
The config file is fully annotated, you can go through it and select the
options you like.  Or you can use the below, a quick set of common options
to serve the local subnet.

A common setup for DNS service for an IPv4 subnet and IPv6 localhost is below.
You can change the IPv4 subnet to match the subnet that you use. And add
your IPv6 subnet if you have one.

.. code:: bash

    # unbound.conf for a local subnet.
    server:
        interface: 0.0.0.0
        interface: ::0
        access-control: 192.168.0.0/16 allow
        access-control: ::1 allow
        verbosity: 1

By default the software comes with chroot enabled. This provides an extra
layer of defense against remote exploits. Enter file paths as full pathnames
starting at the root of the filesystem (``/``). If chroot gives
you trouble, you can disable it with ``chroot: ""`` in the config.

Also the server assumes the username ``unbound`` to drop privileges.
You can add this user with your favorite account management tool (``useradd(8)``),
or disable the feature with ``username: ""`` in the config.

Start the server using the rc.d script (if you or the package manager
installed one) as ``/etc/rc.d/init.d/unbound start``.
Or ``unbound -c <config>`` as root.

Setup Remote Control
--------------------

If you want to you can setup remote control using ``unbound-control``.
First run ``unbound-control-setup`` to generate the necessary
TLS key files (they are put in the default install directory).
If you use a username of ``unbound`` to run the daemon from use
``sudo -u unbound unbound-control-setup`` to generate the keys, so
that the server is allowed to read the keys.
Then add the following at the end of the config file.

.. code:: bash

    # enable remote-control
    remote-control:
        control-enable: yes

You can now use ``unbound-control`` to send commands to the daemon.
It needs to read the key files, so you may need to ``sudo unbound-control``.
Only connections from localhost are allowed by default.
