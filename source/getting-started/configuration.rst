.. _doc_unbound_configuration:

Configuration
-------------

Unbound has a vast array of configuration options for advanced use cases, which can seem a little overwhelming at first. Luckily, all of the defaults are sensible and secure, so in a lot of environments you can run Unbound without changing any options. Below we will go through a basic, recommended config, but feel free to add and experiment with options as you need them.

.. @TODO in the future we can put a forward link to the configuration options + explanations for advanced users.

.. Note:: The instructions in this page assume that Unbound is already installed.

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

By default the Unbound config uses `chroot <https://wiki.archlinux.org/title/chroot>`_ to provide an extra layer of defence against remote exploits. If Unbound is not starting because it cannot access files due to permission errors caused by :command:`chroot`, a solution can be to enter file paths as full pathnames starting at the root of the filesystem (``/``). Otherwise, if :command:`chroot` is not required you can disable it in the config.

.. code:: bash

	# disable chroot
	chroot: ""

By default Unbound assumes that a user named "unbound" exists, which you can add this user with an account management tool available on your system. You can also disable this feature by adding ``username: ""`` in the config. If it is enabled, after the setup, any other user privileges are dropped and the configured username is assumed.

.. Important:: Unbound comes with the :command:`unbound-checkconf` tool. This tool allows you to check the config file for errors before starting Unbound. It is very convenient because if any errors are found it tells you where they are, which is particularly useful when Unbound is already running to avoid failure to restart due to a configuration error.


Set up Remote Control
=====================

A useful functionality to enable is the use of the :command:`unbound-control` command. This allows command makes starting, stopping, and reloading Unbound easier. To enable this functionality we need to add :option:`remote-control` to the config and enable it.

.. code:: bash

    remote-control:
        # enable remote-control
        control-enable: yes

        # location of the files created by unbound-control-setup
        #server-key-file: "/usr/local/etc/unbound/unbound_server.key"
        #server-cert-file: "/usr/local/etc/unbound/unbound_server.pem"
        #control-key-file: "/usr/local/etc/unbound/unbound_control.key"
        #control-cert-file: "/usr/local/etc/unbound/unbound_control.pem"

To use the :command:`unbound-control` command, we need to invoke the :command:`unbound-control-setup` command. This creates a number of files in the default install directory. The default install directory is ``/usr/local/etc/unbound/`` on most systems, but some distributions may put it in ``/etc/unbound/`` or ``/var/lib/unbound``.

Apart from an extensive config file, with just about all the possible configuration options, :command:`unbound-control-setup` creates the cryptographic keys necessary for the control option. 

.. code:: bash

    unbound-control-setup

If you use a username like ``unbound`` in the config to run the daemon (which is the default setting), you can use :command:`sudo` to create the files in that user's name, so that the user running Unbound is allowed to read the keys. 
This is also a solution if the ``/usr/local/etc/unbound/`` (or any other default direcotry) directory is write-protected, which is the case for some distributions.

.. code:: bash

	sudo -u unbound unbound-control-setup

You can now control Unbound using the :command:`unbound-control` command. Note that if your configuration file is not in the default location or not named ``unbound.conf``, the name (and possibly path) need to be provided when using the command using the :option:`-c` flag.


Set up Trust Anchor (Enable DNSSEC)
===================================

To enable `DNSSEC <https://www.sidn.nl/en/cybersecurity/dnssec-explained>`_, which we strongly recommend, we need to set up a trust anchor as it allows the verification of the integrity of the responses to the queries you send.

To help, we can use the :command:`unbound-anchor` command. :command:`unbound-anchor` performs the setup by configuring a trust anchor. The default location that :command:`unbound-anchor` creates this in is determined by your installation method. Usually the default directory is ``/usr/local/etc/unbound/``.

.. code::bash

	unbound-anchor

Note that using a package manager to install Unbound, on some distributions, creates the root key during installation. On Ubuntu 20.04.1 LTS for example, this location is ``/var/lib/unbound/root.key``. On macOS Big Sur this location is ``/opt/homebrew/etc/unbound/root.key`` If you create the root key yourself (by using the :command:`unbound-anchor` command), then the path to the anchor file in the configuration file should be changed to the correct location. To find out the default location you can use the :command:`unbound-anchor` command again with the ``-vvv`` option enabled.
To enable DNSSEC, we add ``auto-trust-anchor-file`` under the ``server`` options in the config.

.. code:: bash

	# enable DNSSEC
	auto-trust-anchor-file: "/var/lib/unbound/root.key"

Note that on some systems the ``/usr/local/etc/unbound/`` directory might be write-protected. 

If the :command:`unbound-control-setup` command fails due to the insufficient permissions, instead run the command as the correct user.

.. code:: bash

	sudo -u unbound unbound-anchor


.. https://sizeof.cat/post/unbound-on-macos/




.. @TODO Write ACL's -> access-control








