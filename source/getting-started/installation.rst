Installation
------------

To install your own copy of Unbound you have two options: Use the version provided by your package manager, or download the source and building it yourself.

Installing via the package manager is the easiest option, and on most systems even trivial. The downside is the distributed version can be outdated for some distributions or not have all the compile-time options included that you want.
Building and compiling Unbound yourself ensures that you have the latest version and all the compile-time options you desire.


.. Ref to Compiling, Setup and Remote Control Setup (page index?)


Installing with a package manager
=================================

Most package managers maintain a version of Unbound, although this version can be outdated if this package has not been updated recently. If you like to upgrade to the latest version, we recommend :ref:`building Unbound yourself<compiling>`.

.. FIX REF


Ubuntu 20.04.1 LTS
******************

Installing Unbound with the built-in package manager should be as easy as:

.. code-block:: bash

    sudo apt update
    sudo apt install unbound

This gives you a compiled and running version of Unbound ready to be configured.

.. Link to configuring block

macOS Big Sur
*************

In this tutorial we make use of the Brew package installer for MacOS. Install ``brew`` and, if you've never used ``brew`` before, give `their website <https://brew.sh/>`_ a read.

.. code-block:: bash

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


Then use brew to install Unbound.

.. code-block:: bash

    brew install unbound

This gives you a compiled and running version of Unbound ready to be configured.

.. Link to configuring block


.. sudo chmod -R 666 *


.. LOOK INTO THIS:

.. sudo brew services start unbound
.. ==> Tapping homebrew/services
.. Cloning into '/opt/homebrew/Library/Taps/homebrew/homebrew-services'...
.. remote: Enumerating objects: 1352, done.
.. remote: Counting objects: 100% (231/231), done.
.. remote: Compressing objects: 100% (166/166), done.
.. remote: Total 1352 (delta 86), reused 190 (delta 61), pack-reused 1121
.. Receiving objects: 100% (1352/1352), 401.78 KiB | 3.94 MiB/s, done.
.. Resolving deltas: 100% (562/562), done.
.. Tapped 1 command (28 files, 496KB).
.. Warning: Taking root:admin ownership of some unbound paths:
..   /opt/homebrew/Cellar/unbound/1.13.1/sbin
..   /opt/homebrew/Cellar/unbound/1.13.1/sbin/unbound
..   /opt/homebrew/opt/unbound
..   /opt/homebrew/opt/unbound/sbin
..   /opt/homebrew/var/homebrew/linked/unbound
.. This will require manual removal of these paths using `sudo rm` on
.. brew upgrade/reinstall/uninstall.


Building from source/Compiling
==============================

.. :ref:`compiling`

To compile Unbound on any system you need to have the ``openssl`` and ``expat`` libraries, and their header files. To include the header files we need to get the development version, usually called ``libssl-dev`` and ``libexpat1-dev`` respectively.

Ubuntu 20.04.1 LTS
******************

First of all, we need our copy of the Unbound code, so we download the tarball of the latest version and untar it.

.. code-block:: bash

    wget https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz
    tar xzf unbound-latest.tar.gz


We'll need some tools, such as a compiler and the :command:`make` program.

.. code-block:: bash

    sudo apt update
    sudo apt install -y build-essential


The library components Unbounds needs are: ``libssl`` ``libexpat``, of which we need the "dev" version. Unbound also uses ``libldns``, but this is included in the tarball we've already downloaded.

.. code-block:: bash

    sudo apt install -y libssl-dev
    sudo apt install -y libexpat1-dev


We'll also need the tools to build the actual program. For this, Unbound uses :command:``make`` and internally it uses ``flex`` and ``yacc``, which we need to download as well.

.. code-block:: bash

    sudo apt-get install -y bison
    sudo apt-get install -y flex


With all the requirements met, we can now start the compilation process in the Unbound directory. 
The first step here is configuring. With :option:`./configure -h` you can look at the extensive list of configurables for Unbound. A nice feature is that :command:`configure` will tell you what it's missing during configuration. A common error is for the paths to the two libraries we just installed, which can be manually specified with :option:`--with-ssl=` and :option:`--with-libexpat=`.

.. code-block:: bash

    ./configure


When :command:`configure` gives no errors, we can continue to actually compiling Unbound. For this Unbound uses :command:`make`. Be warned that compiling might take a while.

.. code-block:: bash

    make


When we have a successful compilation, we can install Unbound to make available for the entire machine.

.. code-block:: bash

    sudo make install

We now have fully compiled and installed version of Unbound, and can continue to testing it.

.. Ref to testing

macOS Big Sur
*************

In this tutorial we make use of the :command:`brew` package installer for MacOS. Install :command:`brew` and give `their website <https://brew.sh/>`_ a read if you've never used brew before.

.. code-block:: bash

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


Then we use :command:`brew` to install :command:`wget`.

.. code-block:: bash

    brew install wget


We can the use :command:`wget` to download the latest version of Unbound from repository and unpack it.

.. code-block:: bash

    wget https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz
    tar xzf unbound-latest.tar.gz


To compile Unbound on MacOS (or anything really), we need to install the Mac specific development tools called "Xcode". This is available on the app store and requires ~12 GB space on the hard disk. To verify that Xcode is installed correctly we check that we have the :command:`gcc` compiler by asking for the version.

.. code-block:: bash

    gcc --version

.. DO WE WANT TO INCLDUE THIS ALTERNATIVE? Pro: it's smaller and probably quicker. Con: it's not technically the official way and maybe more error prone.
.. stackoverflow answer for skipping entire Xcode: https://stackoverflow.com/questions/31043217/how-to-enable-unbound-dnssec-dns-resolver-on-mac-os-x-10-10-3-yosemite

.. If you want to avoid installing the multi-gigabyte XCode,
.. Run this command inside Terminal: xcode-select --install and a new window will appear. In it, select only "Command Line Tools" (CLT) option/portion, even though it suggests that you install full XCode.
.. Then verify CLT installation: so in Terminal, run: xcode-select -p
.. If it displays: /Library/Developer/CommandLineTools
.. then CLT installation succeeded.
.. Mac OS X Yosemite allows you to install only the CLT portion. Some previous Mac OS X versions did not allow CLT without XCode.

.. Also check if gcc tool is now present or not: in Terminal, run: gcc --version



Next we install the required libraries using :command:`brew`. Note that when installing these :command:`brew` will tell you the path to where it has installed the library. The default is the ``/opt/homebrew/Cellar/`` directory, which can become important in the :command:`configure` step.


.. code-block:: bash

    brew install openssl@1.1
    brew install expat

With all the requirements met, we can now start the compilation process in the Unbound directory. The first step here is configuring. With :option:`./configure -h` you can look at the extensive list of configurables for Unbound. A nice feature is that :command:`configure` will tell you what it's missing during configuration. A common error is for the paths to the two libraries we just installed, which can be manually specified with :option:`--with-ssl=` and :option:`--with-libexpat=`.


.. code-block:: bash

    ./configure 


Or alternatively, when :command:`configure` cannot find ``libssl`` and ``libexpat`` and :command:`brew` installed them at the default directory (make sure you fill in the correct version, at the time of writing the latest version of openssl is ``1.1.1k`` and of libexapt is ``2.3.0``).

.. code-block:: bash

    ./configure --with-ssl=/opt/homebrew/Cellar/openssl@1.1/1.1.1k/ --with-libexpat=/opt/homebrew/Cellar/expat/2.3.0

When :command:`configure` gives no errors, we can continue to actually compiling Unbound. For this Unbound uses :command:`make`. Be warned that compiling might take a while.

.. code-block:: bash

    make

When we have a successful compilation, we can install Unbound to make available for the entire machine.

.. code-block:: bash

    sudo make install


We now have fully compiled and installed version of Unbound, and can continue to testing it.

.. Ref to testing

Testing
=======

A simple test to determine if the installation was successful is to invoke the :command:`unbound` command with the :option:`-V` option, which is the "version" option. This shows the version and build options used, as well as proving that the install was successful.

.. code-block:: bash

    unbound -V

If all the previous steps were successful we can continue to configuring our Unbound instance. 

Another handy trick you can use during testing is to run Unbound in the foreground using the :option:`-d` option and increase the verbosity level using the :option:`-vvv` option. This allows you to see steps Unbound takes and also where it fails.



.. Ref to configuring block




..
    The default install directory is ``/usr/local/etc/unbound/unbound.conf``
    but some distributions may put it in ``/etc/unbound/unbound.conf``
    or ``/etc/unbound.conf``.
    The config file is fully annotated, you can go through it and select the
    options you like.  Or you can use the below, a quick set of common options
    to serve the local subnet.

    A basic setup for DNS service for an IPv4 subnet and IPv6 localhost is below.
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
    layer of defence against remote exploits. Enter file paths as full pathnames
    starting at the root of the filesystem (``/``). If chroot gives
    you trouble, you can disable it with ``chroot: ""`` in the config.

    Also the server assumes the username ``unbound`` to drop privileges. You can add
    this user with your favourite account management tool (:command:`useradd(8)`), or
    disable the feature with ``username: ""`` in the config.

    Start the server using the rc.d script (if you or the package manager
    installed one) as ``/etc/rc.d/init.d/unbound start``.
    Or ``unbound -c <config>`` as root.

    Set up Remote Control
    ---------------------

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
