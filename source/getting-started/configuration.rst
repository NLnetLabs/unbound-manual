Configuration
=============

Unbound has a vast array of configuration options for advanced use cases, which
can seem a little overwhelming at first. Luckily, all of the defaults are
sensible and secure, so in a lot of environments you can run Unbound without
changing any options.
Below we will go through a basic, recommended configuration, but feel free to
add and experiment with options as you need them.

..
    @TODO in the future we can put a forward link to the configuration options
    + explanations for advanced users.

.. Note:: The instructions in this page assume that Unbound is already installed.

The basic configuration which you can use out of the box is shown below.
To use it, you need to create a file with this configuration as its content (or
copy the configuration to the default configuration file which can be found
during the installation process).

.. code-block:: bash

    server:
        # can be uncommented if you do not need user privilige protection
        # username: ""

        # can be uncommented if you do not need file access protection
        # chroot: ""

        # location of the trust anchor file that enables DNSSEC. note that
        # the location of this file can be elsewhere
        auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"
        # auto-trust-anchor-file: "/var/lib/unbound/root.key"

        # send minimal amount of information to upstream servers to enhance privacy
        qname-minimisation: yes

        # specify the interface to answer queries from by ip-address.
        interface: 0.0.0.0
        # interface: ::0

        # addresses from the IP range that are allowed to connect to the resolver
        access-control: 192.168.0.0/16 allow
        # access-control: 2001:DB8/64 allow

By default the Unbound configuration uses
`chroot <https://wiki.archlinux.org/title/chroot>`_ to provide an extra layer
of defence against remote exploits.
If Unbound is not starting because it cannot access files due to permission
errors caused by :command:`chroot`, a solution can be to enter file paths as
full pathnames starting at the root of the file system (``/``).
Otherwise, if :command:`chroot` is not required you can disable it in the
configuration file:

.. code-block:: text

    server:
	# disable chroot
	chroot: ""

By default Unbound assumes that a user named "unbound" exists.
You can add this user with an account management tool available on your system;
on Linux this is usually :command:`useradd`).
You can also disable this feature by adding ``username: ""`` in the
configuration file:

.. code-block:: text

    server:
	# disable user privilige protection
	username: ""

If it is enabled, after the setup, any other user privileges are dropped and
the configured username is assumed.
If this user needs access to files (such as the 'trust
anchor' mentioned below), these can be created by executing with ``sudo -u
unbound`` in front of it.


.. important::

    Unbound comes with the :doc:`/manpages/unbound-checkconf` tool.
    This tool allows you to check the config file for errors before starting
    Unbound. It is very convenient because if any errors are found it tells you
    where they are, which is particularly useful when Unbound is already
    running to avoid failure to restart due to a configuration error.

Testing the setup
-----------------

After running the :command:`unbound-checkconf` command to see if your config
file is correct, you can test your setup by running Unbound in "debug" mode.
This allows you to see what is happening during startup and catch any errors.
The :doc:`/manpages/unbound` manpage shows that the :option:`-d<unbound -d>`
flag will start Unbound in this mode.
The manpage also shows that we can use the :option:`-c<unbound -c>` flag to
specify the path to the configuration file, so we can use the one we created.
We also recommend increasing the verbosity of the logging to 1 or 2, to see
what's actually happening (:option:`-v<unbound -v>` or ``-vv``):

.. code-block:: bash

    unbound -d -vv -c unbound.conf

After Unbound starts normally (and you've sent it some queries) you can remove
the :option:`-v<unbound -v>` and :option:`-d<unbound -d>` and run the command
again.
Then Unbound will fork to the background and run until you either kill it or
reboot the machine.

You may run into an error where Unbound tells you it cannot bind to
``0.0.0.0`` as it's already in use. This is because the system resolver 
``systemd-resolved`` is already running on that port. You can go around this by
changing the IP address in the config to ``127.0.0.1``. This looks like:

.. code-block:: bash

    server:
        # specify the interface to answer queries from by ip-address.
        interface: 127.0.0.1

If you want to change this behaviour, on :doc:`this page</use-cases/local-stub>`
we show how to change the system resolver to be Unbound.

Set up Remote Control
---------------------

A useful functionality to enable is the :doc:`/manpages/unbound-control`
command. This makes starting, stopping, and reloading Unbound
easier.
To enable this functionality we need to add
:ref:`remote-control:<unbound.conf.remote>` to the configuration file:

.. code-block:: text

    remote-control:
        # enable remote-control
        control-enable: yes

        # location of the files created by unbound-control-setup
        # server-key-file: "/usr/local/etc/unbound/unbound_server.key"
        # server-cert-file: "/usr/local/etc/unbound/unbound_server.pem"
        # control-key-file: "/usr/local/etc/unbound/unbound_control.key"
        # control-cert-file: "/usr/local/etc/unbound/unbound_control.pem"

To use the :command:`unbound-control` command, we need to invoke the
:command:`unbound-control-setup` command. This creates a number of files in the
default install directory. The default install directory is
``/usr/local/etc/unbound/`` on most systems, but some distributions may put it
in ``/etc/unbound/`` or ``/var/lib/unbound``.

:command:`unbound-control-setup` creates the cryptographic keys necessary for the control option:

.. code-block:: bash

    unbound-control-setup

If you use a username like ``unbound`` in the configuration to run the daemon
(which is the default setting), you can use :command:`sudo` to create the files
in that user's name, so that the user running Unbound is allowed to read the
keys.
This is also a solution if the ``/usr/local/etc/unbound/`` directory (or any
other default directory) is write-protected, which is the case for some
distributions.

.. code-block:: bash

    sudo -u unbound unbound-control-setup

You can now control Unbound using the :command:`unbound-control` command. Note
that if your configuration file is not in the default location or not named
``unbound.conf``, the name (and possibly path) need to be provided when using
the command using the :option:`-c<unbound-control -c>` flag.


Set up Trust Anchor (Enable DNSSEC)
-----------------------------------

To enable `DNSSEC <https://www.sidn.nl/en/modern-internet-standards/dnssec>`_,
which we strongly recommend, we need to set up a trust anchor as it allows the
verification of the integrity of the responses to the queries you send.

To help, we can use the :doc:`/manpages/unbound-anchor` command.

:command:`unbound-anchor` performs the setup by configuring a trust anchor. This
trust anchor will only serve as the initial anchor from built-in values. To keep
this anchor up to date, Unbound must be able to read and write to this file. The
default location that :command:`unbound-anchor` creates this in is determined by
your installation method.
Usually the default directory is ``/usr/local/etc/unbound/``.

.. note::
    
    During the dynamic linking, this command could output an error about
    loading shared libraries. This is remedied by running ``ldconfig`` to reset
    the dynamic library cache.

.. code-block:: bash

    unbound-anchor

Note that using a package manager to install Unbound, on some distributions,
creates the root key during installation. On Ubuntu 22.04 LTS for example,
this location is ``/var/lib/unbound/root.key``. On macOS Big Sur this location
is ``/opt/homebrew/etc/unbound/root.key`` If you create the root key yourself
(by using the :command:`unbound-anchor` command), then the path to the anchor
file in the configuration file should be changed to the correct location. To
find out the default location you can use the :command:`unbound-anchor` command
again with the ``-vvv`` option enabled. To enable DNSSEC, we add
``auto-trust-anchor-file`` under the ``server`` clause in the configuration
file.

.. code-block:: text

    server:
        # enable DNSSEC
        auto-trust-anchor-file: "/var/lib/unbound/root.key"

Note that on some systems the ``/usr/local/etc/unbound/`` directory might be
write-protected.

If the :command:`unbound-anchor` command fails due to the insufficient
permissions, run the command as the correct user, here we use the user
``unbound`` as this is the default user.

.. code-block:: bash

    sudo -u unbound unbound-anchor

This step is also important when using the ``chroot`` jail.

.. @TODO Write ACL's -> access-control
