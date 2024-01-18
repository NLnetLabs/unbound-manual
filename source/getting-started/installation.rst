Installation
============

To install your own copy of Unbound you have two options: Use the version
provided by your package manager, or download the source and building it
yourself.

Installing via the package manager is the easiest option, and on most systems
even trivial. The downside is the distributed version can be outdated for some
distributions or not have all the compile-time options included that you want.
Building and compiling Unbound yourself ensures that you have the latest version
and all the compile-time options you desire.

If you're a first-time user we recommend installing via a package manager.

Installing with a Package Manager
---------------------------------

Most package managers maintain a version of Unbound, although this version can
be outdated if this package has not been updated recently. If you like to
upgrade to the latest version, we recommend :ref:`compiling Unbound
yourself<getting-started/installation:Building from source/Compiling>`.

Ubuntu 22.04 LTS
^^^^^^^^^^^^^^^^

Installing Unbound with the built-in package manager should be as easy as:

.. code-block:: bash

    sudo apt update
    sudo apt install unbound

This gives you a compiled and running version of Unbound ready to :doc:`be
configured<configuration>`.

macOS Big Sur
^^^^^^^^^^^^^

In this tutorial we make use of the Brew package installer for MacOS. Install
``brew`` and, if you've never used ``brew`` before, give `their website
<https://brew.sh/>`_ a read.

.. code-block:: bash

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then use brew to install Unbound.

.. code-block:: bash

    brew install unbound

This gives you a compiled and running version of Unbound ready to :doc:`be
configured<configuration>`.

Building from source/Compiling
------------------------------

To compile Unbound on any system you need to have the ``openssl`` and ``expat``
libraries, and their header files. To include the header files we need to get
the development version, usually called ``libssl-dev`` and ``libexpat1-dev``
respectively.

Ubuntu 22.04 LTS
^^^^^^^^^^^^^^^^

First of all, we need our copy of the Unbound code, so we download the tarball
of the latest version and untar it.

.. code-block:: bash

    wget https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz
    tar xzf unbound-latest.tar.gz


We'll need some tools, such as a compiler and the :command:`make` program.

.. note::
    During installations with the package manager, a screen will come up asking
    which services need to be restarted. Using the defaults for this is fine.

.. code-block:: bash

    sudo apt update
    sudo apt install -y build-essential

The library components Unbound needs are: ``libssl`` ``libexpat``, of which we
need the "dev" version. Unbound also uses ``libldns``, but this is included in
the tarball we've already downloaded.

.. code-block:: bash

    sudo apt install -y libssl-dev
    sudo apt install -y libexpat1-dev

We'll also need the tools to build the actual program. For this, Unbound uses
:command:`make` and internally it uses ``flex`` and ``yacc``, which we need to
download as well.

.. code-block:: bash

    sudo apt-get install -y bison
    sudo apt-get install -y flex

With all the requirements met, we can now start the compilation process in the
Unbound directory. The first step here is configuring. With ``./configure
-h`` you can look at the extensive list of configuration options for Unbound.
A nice feature is that ``configure`` will tell you what it's missing during
configuration.
A common error is for the paths to the two libraries we just installed, which
can be manually specified with ``--with-ssl=`` and ``--with-libexpat=``.

.. code-block:: bash

    ./configure

When :command:`configure` gives no errors, we can continue to actually compiling
Unbound. For this Unbound uses :command:`make`. Be warned that compiling might
take a while.

.. code-block:: bash

    make

When we have a successful compilation, we can install Unbound to make available
for the machine.

.. code-block:: bash

    sudo make install

We now have fully compiled and installed version of Unbound, and :ref:`continue
to testing it<getting-started/installation:Testing>`.

Please note that the default configuration file is located at
:file:`/usr/local/etc/unbound/unbound.conf` and created during the
:command:`make` step. This file contains all possible configuration options for
Unbound.

macOS Big Sur
^^^^^^^^^^^^^

In this tutorial we make use of the :command:`brew` package installer for MacOS.
Install :command:`brew` and give `their website <https://brew.sh/>`_ a read if
you've never used brew before.

.. code-block:: bash

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


Then we use :command:`brew` to install :command:`wget`.

.. code-block:: bash

    brew install wget


We can the use :command:`wget` to download the latest version of Unbound from
repository and unpack it.

.. code-block:: bash

    wget https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz
    tar xzf unbound-latest.tar.gz

To compile Unbound on MacOS (or anything really), we need to install the Mac
specific development tools called "Xcode". This is available on the app store
and requires ~12 GB space on the hard disk. Alternatively, if you don't want
multiple Gigabytes of largely unused space on your hard disk a slimmed down
version also exists called the "Command Line Tools". This includes all the tools
to compile on a Mac can also be installed via the terminal.

.. code-block:: bash

    xcode-select --install

This command will open a window where the selection can be made of what to
install. If you just want the Command Line Tools select this option.

To verify that Xcode is installed correctly we check that we have the
:command:`gcc` compiler by asking for the version.

.. code-block:: bash

    gcc --version

..
    stackoverflow answer for skipping entire Xcode: 
    https://stackoverflow.com/questions/31043217/how-to-enable-unbound-dnssec-dns-resolver-on-mac-os-x-10-10-3-yosemite

Next we install the required libraries using :command:`brew`. Note that when
installing these :command:`brew` will tell you the path to where it has
installed the library. The default is the ``/opt/homebrew/Cellar/`` directory,
which can become important in the :command:`configure` step.

.. code-block:: bash

    brew install openssl@1.1
    brew install expat

With all the requirements met, we can now start the compilation process in the
Unbound directory. The first step here is configuring. With ``./configure
-h`` you can look at the extensive list of configuration options for Unbound.
A nice feature is that :command:`configure` will tell you what it's missing
during configuration.
A common error is for the paths to the two libraries we just installed, which
can be manually specified with ``--with-ssl=`` and ``--with-libexpat=``.

.. code-block:: bash

    ./configure 

Or alternatively, when :command:`configure` cannot find ``libssl`` and
``libexpat`` and :command:`brew` installed them at the default directory (make
sure you fill in the correct version, at the time of writing the latest version
of openssl is ``1.1.1k`` and of libexapt is ``2.3.0``).

.. code-block:: bash

    ./configure --with-ssl=/opt/homebrew/Cellar/openssl@1.1/1.1.1k/ \
                --with-libexpat=/opt/homebrew/Cellar/expat/2.3.0

When :command:`configure` gives no errors, we can continue to actually compiling
Unbound. For this Unbound uses :command:`make`. Be warned that compiling might
take a while.

.. code-block:: bash

    make

When we have a successful compilation, we can install Unbound to make available
for the machine.

.. code-block:: bash

    sudo make install

We now have fully compiled and installed version of Unbound, and can
:ref:`continue to testing it<getting-started/installation:Testing>`.

Testing
-------

A simple test to determine if the installation was successful is to invoke the
:command:`unbound` command with the :option:`-V<unbound -V>` option, which is
the "version" option.
This shows the version and build options used, as well as proving that the
install was successful.
You may have to use ``sudo`` to run this, depending on the installation.

.. code-block:: bash

    unbound -V

If all the previous steps were successful we can continue to configuring our
Unbound instance.

Another handy trick you can use during testing is to run Unbound in the
foreground using the :option:`-d<unbound -d>` option and increase the verbosity
level using the :option:`-v<unbound -v>` option multiple times.
This allows you to see steps Unbound takes and also where it fails.
Another useful, more detailed trick in combination with the foreground is to
make Unbound log on the foreground.
To do this, the following line needs to be added to the configuration file.

.. code-block:: bash

    server:
        use-syslog: no

Now that Unbound is installed we can
:doc:`continue to configuring it<configuration>`.
