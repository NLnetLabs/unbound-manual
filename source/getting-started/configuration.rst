Configuration
-------------

The configuration of Unbound can be a little tricky due to the extensive array of configurable options. Below we will go through a basic, recommended config, but feel free to add and experiment with options as you need them. Also feel free to remove lines that are commented out (using the "#"") if they are not nesecary in your setup.

For the configuration step, we will assume that your system has a Unbound installed and it is available to the entire system (so the :command:`make install` step during installation). 

The basic configuration is shown below. 

.. code:: bash

    server:
        # can be uncommented if you do not need user privilige protection
        # username: ""
        
        # can be uncommented if you do not need file access protection
        # chroot: ""
    
        # location of the trust anchor file that enables DNSSEC. note that
        # the location of this file can elsewhere
        auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"
        # auto-trust-anchor-file: "/var/lib/unbound/root.key"
    
        # send minimal amount of information to upstream servers to enhance privacy
        qname-minimisation: yes
    
        # specify the interfaces to answer queries from by ip-address.
        interface: 0.0.0.0
        # interface: ::0
    
        # addresses from the IP range that are allowed to connect to the resolver
        access-control: 192.168.0.0/16 allow
        # access-control: 2001:DB8/64 allow

By default Unbound comes with `chroot <https://wiki.archlinux.org/title/chroot>`_ enabled. This provides an extra layer of defence against remote exploits. If :command:`chroot` gives you trouble, you can enter file paths as full pathnames starting at the root of the filesystem (``/``) or disable it in the config if this feature is not required.

.. code::bash

	# disable chroot
	chroot: ""

Unbound assumes that a user named "unbound" exists. You can add this user with your favourite account management tool (:command:`useradd(8)`), or disable the feature with ``username: ""`` in the config. If it is enabled, after the setup, any other user privileges are dropped and the configured username is assumed.

Unbound comes with the :command:`unbound-checkconf` tool. This tool allows you to check a config for errors before loading. This tool is very convenient because if any errors are found it tells you where they are and it allows you to check this before loading Unbound to a network interface on your machine.


Set up Remote Control
=====================

A useful functionality to enable is the use of the :command:`unbound-control` command. Enabling this allows Unbound to be controlled by using the :command:`unbound-control` command, which makes starting, stopping, and reloading Unbound easier. To enable this functionality we need to add :option:`remote-control` to the config and enable it.

.. code:: bash

    remote-control:
        # enable remote-control
        control-enable: yes

        # location of the files created by unbound-control-setup
        #server-key-file: "/usr/local/etc/unbound/unbound_server.key"
        #server-cert-file: "/usr/local/etc/unbound/unbound_server.pem"
        #control-key-file: "/usr/local/etc/unbound/unbound_control.key"
        #control-cert-file: "/usr/local/etc/unbound/unbound_control.pem"

To set up for using the :command:`unbound-control` command, we need to invoke the :command:`unbound-control-setup` command. This creates a number of files in the default install director directory. The default install directory is ``/usr/local/etc/unbound/unbound.conf`` on most systems, but some distributions may put it in ``/etc/unbound/unbound.conf`` or ``/etc/unbound.conf``.

Apart from an extensive config file, with just about all the possible configuration options, :command:`unbound-control-setup` creates the cryptographic keys necessary for the control option. 

.. code:: bash

    unbound-control-setup

If you use a username like ``unbound`` in the config to run the daemon, you can use sudo to create the file in that user's name, so that the server is allowed to read the keys. This also works for other users if the ``/usr/local/etc/unbound/`` directory is write-protected.

.. code:: bash

	``sudo -u unbound unbound-control-setup``

When these steps succeed, you can now control Unbound using the :command:`unbound-control` command. Note that if you're not using the name ``unbound.conf`` in the default directory, the name (and possibly path) need to be provided when using the command using the :option:`-c` flag.


Set up trust anchor
===================

To enable `DNSSEC <https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions>`_, which we strongly recommend, we need to create a trust anchor as it ensures the integrity of the responses to your queries.

To help, we can use the :command:`unbound-anchor` command. :command:`unbound-anchor` performs the setup by creating a root key. The default location that :command:`unbound-anchor` creates this in the default directory ``/usr/local/etc/unbound/``. Note that using a package manager to install Unbound, on some distributions, creates the root key during installation. On Ubuntu 20.04.1 LTS for example, this location is ``/var/lib/unbound/root.key``. If you create the root key yourself (by using the :command:`unbound-anchor` command), then the location should be changed in the config to the default location.

.. code:: bash

	# enable DNSSEC
	auto-trust-anchor-file: "/var/lib/unbound/root.key"

Note that on some systems the ``/usr/local/etc/unbound/`` directory might be write-protected. If this is the case, the same trick as with :command:`unbound-control-setup` can be used for the username that will run the Unbound daemon .

.. code:: bash

	``sudo -u unbound unbound-anchor``


.. https://sizeof.cat/post/unbound-on-macos/




.. @TODO Write ACL's -> access-control








