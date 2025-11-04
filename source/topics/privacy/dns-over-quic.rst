.. versionadded:: 1.22.0
   Downstream DoQ was introduced. A special fork of OpenSSL (openssl+quic) was
   required to provide crypto functionality to libngtcp2.
.. versionadded:: 1.24.0
   OpenSSL 3.5.0 and later can be used instead of the openssl+quic fork.

DNS-over-QUIC
=============

DNS-over-QUIC (DoQ) uses the QUIC transport mechanism to encrypt queries and
responses. Unbound can be configured to serve to clients over DoQ. For that
the feature must be compiled in, with the support libraries that this needs.

The feature allows Unbound to support DoQ clients downstream.
The QUIC transport for DNS is from :rfc:`9250`.

Configuration
-------------

The DoQ downstream can be configured, by setting Unbound to listen on the
DoQ UDP port for traffic.

A minimal configuration that enables DoQ can be:

.. code-block:: text

    server:
        interface: 127.0.0.1@2853
        quic-port: 2853
        tls-service-key: "privatefile.key"
        tls-service-pem: "publicfile.pem"

That would make unbound listen on the port number ``2853``, for DoQ traffic.
The port number shown here is for test purposes.
The QUIC port is set using the
:ref:`quic-port<unbound.conf.quic-port>` configuration option.

It is possible to configure more interfaces with this port number, like
``::1@2853``, those interfaces are then configured to have DoQ traffic too.
If the interface receives also TCP traffic, this can be combined with DNS TCP,
or with DNS over TLS or with DNS over HTTP traffic, by setting the relevant
port numbers.

Like for DNS over TLS, Unbound needs a TLS certificate for DoQ, and this can be
configured with
:ref:`tls-service-key: "privatefile.key"<unbound.conf.tls-service-key>` and
:ref:`tls-service-pem: "publicfile.pem"<unbound.conf.tls-service-pem>` .

The resource consumption can be configured with something like
:ref:`quic-size: 8m<unbound.conf.quic-size>`.
More queries are turned away.

Libraries
---------

Unbound uses ``libngtcp2`` for DNS over QUIC.
This in turn requires OpenSSL version 3.5.0 or later for QUIC support in the
encryption for the QUIC transport.

If the system has at least ``OpenSSL 3.5.0`` and ``libngtcp2 1.13.0`` you can
build Unbound with:

.. code-block:: bash

    ./configure <other flags> --with-libngtcp2 --prefix=/path/to/unbound_install
    make

Building libraries from source
..............................

If the system lacks the minimum versions, the libraries can be built
from source.

The versions used here are the earliest working ones.

For OpenSSL, the ``3.5.0`` version tar can be downloaded from
https://openssl-library.org/source/old/index.html.

This is how to compile OpenSSL:

.. code-block:: bash

    tar -zxf openssl-3.5.0.tar.gz
    cd openssl-3.5.0
    ./config enable-tls1_3 no-shared no-docs threads --prefix=/path/to/openssl_install
    make -j && make install

Fill in a good place to put the OpenSSL install.
The example uses ``no-shared``, so that the shared library search path later
does not find the wrong dynamic library, but a shared library works too of
course.

For the ngtcp2 library, the
packages ``pkg-config autoconf automake autotools-dev libtool`` are needed
to build the configure script.
They can be installed like
``sudo apt install pkg-config autoconf automake autotools-dev libtool`` in a
Debian style system and this makes the ``autoreconf`` command available.

This is then how to compile libngtcp2:

.. code-block:: bash

    git clone --depth 1 -b v1.13.0 https://github.com/ngtcp2/ngtcp2 ngtcp2
    cd ngtcp2
    git submodule update --init --recursive
    autoreconf -i
    ./configure PKG_CONFIG_PATH=/path/to/openssl_install/lib64/pkgconfig LDFLAGS="-Wl,-rpath,/path/to/openssl_install/lib64" --prefix=/path/to/ngtcp2_install
    make -j && make install

Fill in the path to the openssl_install and path for where the libngtcp2
should be installed.
The example sets the rpath to the directory to search for the dynamic library.

.. caution::

    The output of the configure command above should include output like:

    Crypto helper libraries:
        libngtcp2_crypto_ossl:      yes

    Libs:
        OpenSSL:        yes (CFLAGS='-I/path/to/openssl_install/include' LIBS='-L/path/to/openssl_install/lib64 -lssl -lcrypto')

    If the configure output does not contain the above, i.e., libngtcp2 can't find
    the OpenSSL installation make sure you used the correct paths.
    Some systems may use ``lib`` instead of ``lib64`` for example.

Now that both libraries are built and available Unbound can be built with:

.. code-block:: bash

    ./configure <other flags> --with-ssl=/path/to/openssl_install --with-libngtcp2=/path/to/ngtcp2_install LDFLAGS="-Wl,-rpath -Wl,/path/to/ngtcp2_install/lib64" --prefix=/path/to/unbound_install
    make -j

Fill in the path to the openssl_install and ngtcp2_install.
The rpath is set so that the dynamic libraries can be found in the search path.

Unbound is now compiled with DoQ support, with the libngtcp2
library, linked against the specified OpenSSL library.
This OpenSSL library will be used for both providing encryption to the QUIC
transport of libngtcp2 and providing TLS and other crypto calls for other
functionalities in Unbound like DNSSEC.


Test
----

Unbound contains a test tool implementation.
This can be compiled from the source directory of Unbound, with:

.. code-block:: bash

    make doqclient

This creates a DoQ client test tool; you can see some options with
``./doqclient -h``.

Unbound can be started attached to the console for debug, with ``./unbound -dd -c theconfig.conf``.
Ctrl-C can exit, or send a term signal.

Send a query with ``./doqclient -s 127.0.0.1 -p 2853 www.example.com A IN``.
If the server is listening to DoQ queries on port 2853.
With ``-v`` the test tool prints more diagnostics.

It is also possible to get more information from the server.
This is done by setting configuration for a log file and verbosity 4 or more.
It also prints internal information from libngtcp2 for the DoQ transport.

Metrics
-------

The number of QUIC queries is tracked with
:ref:`num.query.quic<unbound-control.stats.num.query.quic>`
in the statistics.

The number of memory used for QUIC is tracked with
:ref:`mem.quic<unbound-control.stats.mem.quic>`
in the statistics.
