Installation
============

To install your own copy of Unbound you have two options: Using the version provided by your package manager, or downloading the source and building it yourself.

Installing via the package manager is the easiest option, and on most systems even trivial. The downside is the distributed version can be outdated for some systems or not have all the compile-time options included that you want.
Building and compiling Unbound yourself ensures that you have the latest version and all the compile-time options you want. 


.. Link to Compiling, Setup and Remote Control Setup (page index?)

Building from source/Compiling
==============================

To compile Unbound on any system you need to have ``openssl`` and ``expat``, and their header files. To include the header files we need the development version, usually called ``libssl-dev`` and ``libexpat1-dev`` respectively.

Ubuntu 20.04.1 LTS
------------------

First of all, we need our copy of the Unbound code, so we download the tarball of the latest version and untar it.

.. code-block:: bash
    wget https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz
    tar xzf unbound-latest.tar.gz


We'll need some tools, such as a compiler and the :command:`make` program.

.. code-block:: bash

    sudo apt update
    sudo apt install -y build-essential


The library components Unbounds needs are: ``libssl`` ``libexpat``, of which we need the "dev" version. Unbound also uses ``libldns``, but this is included in the tarball.

.. code-block:: bash

    sudo apt install -y libssl-dev
    sudo apt install -y libexpat1-dev


We'll also need the tools to build the actual program. For this, Unbound uses :command:``make`` and internally it uses ``flex`` and ``yacc``, which we need to download as well.

.. code-block:: bash

    sudo apt-get install -y bison
    sudo apt-get install -y flex


With all the requirements met, we can now start compiling in the Unbound directory. The first step here is configuring. With :option:`./configure -h` you can look at the extensive list of configurables for Unbound. A nice feature is that ``./configure`` will tell you what it's missing during configuration. A common error is for the paths to the two libraries we just installed, which can be manually specified with :option:`--with-ssl=` and :option:`--with-libexpat=`).

.. code-block:: bash

    ./configure


When :command`configure` gives no errors, we can continue to actually compiling Unbound. For this Unbound uses :command:`make`. Be warned that compiling might take a while

.. code-block:: bash

    make


When we have a succesful compilation, we can install the programs to have them available for the entire machine.

.. code-block:: bash

    sudo make install

We now have fully compiled and installed version of Unbound, and can now move to configuring it.

.. Link to configuring block

macOS Big Sur
-------------

Get brew (website link: https://brew.sh/) give this a read if you've never used brew before

.. code-block:: bash

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

use brew to install wget

.. code-block:: bash

    brew install wget


get Unbound from repo

.. code-block:: bash

    wget https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz
    tar xzf unbound-latest.tar.gz


.. MENTION XCODE

get libs (with brew)

.. code-block:: bash

    


optionally fix pathing issue

.. code-block:: bash

    


configure (with our without path to libs)

.. code-block:: bash

    

no errors? make

.. code-block:: bash

    make

no errors? make install

.. code-block:: bash

    sudo make install


We now have fully compiled and installed version of Unbound, and can now move to configuring it.

.. Link to configuring block

Installing with a package manager
=================================


Ubuntu 20.04.1 LTS
------------------

Installing Unbound with the built-in package manager should be as easy as:

.. code-block:: bash

    sudo apt install unbound

This gives you a compiled and running version of Unbound ready to be configured. In addition to the Unbound program you can find a 


macOS Big Sur
-------------

Get brew (website link: https://brew.sh/) give this a read if you've never used brew before

.. code-block:: bash

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


Then use brew to install Unbound.

.. code-block:: bash

    brew install unbound






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
layer of defence against remote exploits. Enter file paths as full pathnames
starting at the root of the filesystem (``/``). If chroot gives
you trouble, you can disable it with ``chroot: ""`` in the config.

Also the server assumes the username ``unbound`` to drop privileges. You can add
this user with your favourite account management tool (``useradd(8)``), or
disable the feature with ``username: ""`` in the config.

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
