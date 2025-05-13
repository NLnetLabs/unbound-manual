.. versionadded:: 1.22.0

DNS-over-QUIC
=============

DNS-over-QUIC (DoQ) uses the QUIC transport mechanism to encrypt queries and
responses. Unbound can be configured to serve to clients over doq. For that
the feature must be compiled in, with the support libraries that this needs.

The feature allows unbound to support doq clients downstream. The doq
transport for DNS is from
:rfc:`9250` .

Configuration
-------------

The DOQ downstream can be configured, by setting Unbound to listen on the
doq UDP port for traffic.

With this in unbound.conf, in the ``server:`` section:

.. code-block:: text

    interface: 127.0.0.1@2853
    quic-port: 2853

That would make unbound listen on the port number 2853, for doq traffic.
The port number shown here is for test purposes.
The quic port is set using the
:ref:`quic-port:<unbound.conf.quic-port>` configuration option.

It is possible to configure more interfaces with this port number, like
``::1@2853``, those interfaces are then configured to have doq traffic too.
If the interface receives also TCP traffic, this can be combined with DNS TCP,
or with DNS over TLS or with DNS over HTTP traffic, by setting the port
numbers.

Like for DNS over TLS, Unbound needs a TLS certificate for doq, and this can be
configured with ``tls-service-key: "privatefile.key"`` and ``tls-service-pem: "publicfile.pem"``,
:ref:`tls-service-key:<unbound.conf.tls-service-key>` and 
:ref:`tls-service-pem:<unbound.conf.tls-service-pem>` .

The resource consumption can be configured with ``quic-size: 8m``. More
queries are turned away,
:ref:`quic-size:<unbound.conf.quic-size>` .

Libraries
---------

Unbound uses libngtcp2 for DNS over QUIC. This in turn requires a modified
openssl library for quic support in the encryption for the quic transport.
The modified openssl library is called openssl+quic. It is available for
openssl versions 1.1.1 and 3.2.0, and so on.

The modified openssl library is available from the openssl+quic repository, 
`quictls <https://github.com/quictls/openssl>`__ . The libngtcp2 library
is available from `ngtcp2 <https://github.com/ngtcp2/ngtcp2>`__ .

The online documentation for libngtcp2 is available, `ngtcp2 <https://nghttp2.org/ngtcp2/>`__ . The ngtcp2-0.19.1 version tarball can be downloaded `ngtcp2-0.19.1 release <https://github.com/ngtcp2/ngtcp2/releases/tag/v0.19.1>`__ , instead
of using the git checkout.

For the openssl+quic also tarball downloads are available for releases,
like for 3.0.10+quic, `openssl-3.0.10-quic1 release <https://github.com/quictls/openssl/releases/tag/openssl-3.0.10-quic1>`__ .

For example unbound can be compiled with version ngtcp2-0.19.1, and with
OpenSSL_1_1_1o+quic and openssl-3.0.10-quic1 .

This is how to compile openssl+quic:

.. code-block:: bash

    git clone --depth 1 -b OpenSSL_1_1_1o+quic https://github.com/quictls/openssl openssl+quic
    cd openssl+quic
    git submodule update --init --recursive
    ./config enable-tls1_3 no-shared threads --prefix=/path/to/openssl+quic_install
    make
    make install

Fill in a good place to put the quic install. The example uses no-shared,
so that the shared library search path later does not find the wrong dynamic
library, but a shared library works too of course.

For the ngtcp2 library, the
packages ``pkg-config autoconf automake autotools-dev libtool`` are needed
to build the configure script. They can be installed
like ``sudo apt install pkg-config autoconf automake autotools-dev libtool``
and this makes the autoreconf command available.

The ngtcp2 library can be compiled like this:

.. code-block:: bash

    git clone --depth 1 -b v0.19.1 https://github.com/ngtcp2/ngtcp2 ngtcp2
    cd ngtcp2
    git submodule update --init --recursive
    autoreconf -i
    ./configure PKG_CONFIG_PATH=/path/to/openssl+quic_install/lib/pkgconfig LDFLAGS="-Wl,-rpath,/path/to/openssl+quic_install/lib" --prefix=/path/to/ngtcp2_install
    make
    make install

Fill in the path to the openssl+quic install and path for where the libngtcp2
install is created. The example sets the rpath to the directory to search for
the dynamic library.

The unbound server can be compiled with doq support, with the libngtcp2
library, and the modified openssl library for quic support to libngtcp2, and
this openssl library is then also used for TLS and other crypto calls, like
for DNSSEC.

Compile unbound then like this:

.. code-block:: bash

    ./configure <other flags> --with-ssl=/path/to/openssl+quic_install --with-libngtcp2=/path/to/ngtcp2_install LDFLAGS="-Wl,-rpath -Wl,/path/to/ngtcp2_install/lib" --prefix=/path/to/unbound_install
    make

Fill in the path to the openssl+quic install and libngtcp2 install.
The rpath is set so that the dynamic libraries can be found in the search path.
This then results in an unbound server that supports doq.

Test
----

Unbound contains a test tool implementation. This can be compiled from the
source directory of unbound, with:

.. code-block:: bash

    make doqclient

This creates a test tool, see some options with ``./doqclient -h``.

Unbound can be started attached to the console for debug, with ``./unbound -d -c theconfig.conf``. With ``-dd`` it prints logs to the terminal as well. Ctrl-C can exit, or send a term signal.

Send a query with ``./doqclient -s 127.0.0.1 -p 2853 www.example.com A IN``.
If the server is listening to doq queries on port 2853.
With ``-v`` the test tool prints more diagnostics.

It is also possible to get more information from the server. This is done
by setting configuration for a log file and verbosity 4 or more. It also
prints internal information from libngtcp2 for the doq transport.

Metrics
-------

The number of quic queries is output in
:ref:`num.query.quic<unbound-control.stats.num.query.quic>`
in the statistics. The
:ref:`mem.quic<unbound-control.stats.mem.quic>`
statistic outputs memory used.
