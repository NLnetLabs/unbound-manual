.. versionadded:: 1.17.0

Downstream Proxy Support
========================

Since version 1.17.0, Unbound can play nicely in environments where supported
DNS reverse-proxying is in place.
It is able to use the proxied client information as the "real" client address
for all functions, except in the actual network communication, where a client
address is used, such as access control, logging, DNSTAP, RPZ and IP
rate limiting.

The currently supported environment is PROXY protocol version 2 (PROXYv2).

PROXYv2
-------

.. versionadded:: 1.17.0

Unbound supports PROXYv2 for downstream connections; that is clients (read
proxies) talking to Unbound.

The PROXY protocol is protocol agnostic and can work with any layer 7 protocol
even when encrypted.
It works on both UDP and TCP based transports and in a nutshell it prepends the
client information in the application's payload.
This is done once at the start of a TCP stream, or in every UDP packet.
The caveat is that both the proxy and the upstream server (i.e., Unbound) need
to understand the PROXY protocol.

Configuration
.............

Configuring Unbound for PROXYv2 is pretty straight forward.
The following minimal configuration allows Unbound to listen for incoming
queries on port 53 (the default) and marks the same port as a PROXYv2 port:

.. code-block:: text

    server:
            interface: eth0
            proxy-protocol-port: 53
            interface-action: eth0 allow

This means that Unbound **expects** PROXYv2 information on that port.

.. warning::

    In absence of a valid PROXYv2 header Unbound will terminate/drop the
    connection/packet.

The port configuration can be used alongside plain UDP and plain TCP ports (as
in the example above), but also together with DNS over TLS ports.

.. note::

    The coexistence of PROXYv2 together with either DNSCrypt or DNS over HTTP
    is not supported.

.. seealso::
    :ref:`proxy-protocol-port<unbound.conf.proxy-protocol-port>` in the
    :doc:`/manpages/unbound.conf` manpage.
