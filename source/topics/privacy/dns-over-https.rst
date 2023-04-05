.. versionadded:: 1.12.0

DNS-over-HTTPS
==============

DNS-over-TLS (DoT) makes it possible to encrypt DNS messages and gives a DNS
client the possibility to authenticate a resolver. As implied by the name, this
is done by sending DNS messages over TLS. Unbound can handle TLS encrypted DNS
messages since `2011
<https://github.com/NLnetLabs/unbound/commit/aa0536dcb5846206d016a03d8d66ad4279247d9e>`__,
long before the IETF DPRIVE working group started its work on the
`DoT specification <https://tools.ietf.org/html/rfc7858>`__.

There are, however, DNS clients that do not support DoT but are able to use
DNS-over-HTTPS (DoH) instead. Where DoT sends a DNS message directly over TLS,
DoH has an HTTP layer in between. Where DoT uses its own TCP port (853), DoH
uses the standard HTTPS port (443).

By adding downstream DoH support to Unbound we hope to increase the ratio of
encrypted DNS traffic and increase the number of resolvers that offer encrypted
services in home networks, enterprise networks, ISPs, and public resolvers.

Implementation Details
----------------------

The DoH implementation in Unbound requires TLS, and only works over HTTP/2. The
query pipelining and out-of-order processing functionality that is provided by
HTTP/2 streams is needed to be able to provide performance that is on par with
DoT. The HTTP/2 capability is negotiated using Application-Layer Protocol
Negotiation (ALPN) TLS extension, which is supported in OpenSSL from version
1.0.2 onward.

Unbound uses the `nghttp2 <https://nghttp2.org/>`__ library to handle the HTTP/2
framing layer. This library does not take care of any I/O handling, which makes
it possible to easily integrate it in the existing Unbound event loop and TCP
handling. Adding HTTP/2 on top of the existing TCP code makes it possible to
also use the existing TCP configuration options for the DoH connections. These
existing options include the number of allowed incoming TCP connections, the TCP
timeout settings, and the limits on TCP connections per client IP address or
netblock.

The use of HTTP makes it possible to change the DNS message format by using new
media types.
Unbound currently only supports the ``application/dns-message`` media type, as
this is the only format standardised in the IETF standards track, and the only
supported format by popular DNS clients.
We are keeping an eye on the new possibilities here, such as using the
``application/oblivious-dns-message`` media type.

The use of the HTTP layer also makes it possible to return more detailed
information to a client in case of malformed requests. This can be done by using
a non-successful HTTP status code, or by closing an individual stream by sending
an RST_STREAM frame. The HTTP status codes that can be returned by Unbound are:

200 OK
    Unbound is able to process the query, and return an answer. This could
    be a negative answer or an error like SERVFAIL or FORMERR.

404 Not Found
    The request is directed to a path other than the configured endpoint in
    http-endpoint (default ``/dns-query``).

413 Payload Too Large
    The payload received in the POST request is too large. Payloads cannot be
    larger than the content-length communicated in the request header. The
    payload length is limited to 512 bytes if
    :ref:`harden-large-queries:<unbound.conf.harden-large-queries>` is enabled,
    and otherwise limited to the value configured in
    :ref:`msg-buffer-size:<unbound.conf.msg-buffer-size>` (default
    65552 bytes). To prevent the allocation of overly large buffers, the maximum
    size is limited to the size of the first DATA frame if no content-length is
    received in the request.

414 URI Too Long
    The base64url encoded DNS query in the GET request is too large. The DNS
    query length is limited to 512 bytes if
    :ref:`harden-large-queries:<unbound.conf.harden-large-queries>` is enabled,
    and limited to :ref:`msg-buffer-size:<unbound.conf.msg-buffer-size>`
    otherwise.

415 Unsupported Media Type
    The media type of the request is not supported. This happens if the request
    contains a content-type header that is set to anything but
    ``application/dns-message``.
    Requests without content-type will be treated as ``application/dns-message``.

400 Bad Request
    No valid query received, not matched by any of the above 4xx status
    codes.

501 Not Implemented
    The method used in the request is not GET or POST.

Using DoH
---------

As mentioned above, the `nghttp2 <https://nghttp2.org/>`__ library is required to use Unbound’s DoH
functionality. Compiling and installing Unbound with libnghttp2 can be done
using:

.. code-block:: bash

    ./configure --with-libnghttp2
    make && make install

Enabling DoH in Unbound is as simple as configuring the TLS certificate and the
corresponding private key that will be used for the connection, and configuring
Unbound to listen on the HTTPS port:

.. code-block:: text

    server:
        interface: 127.0.0.1@443
        tls-service-key: "key.pem"
        tls-service-pem: "cert.pem"

The port that Unbound will use for incoming DoH traffic is by default set to
443 and can be changed using the
:ref:`https-port:<unbound.conf.https-port>` configuration option.

``dohclient``, an Unbound test utility which can be built with
``make dohclient`` in Unbound's source tree, shows that Unbound is now ready to
handle DoH queries on the default HTTP endpoint, which is ``/dns-query``:

.. code-block:: text

    $ ./dohclient -s 127.0.0.1 nlnetlabs.nl AAAA IN
    Request headers
    :method: GET
    :path: /dns-query?dns=AAABAAABAAAAAAABCW5sbmV0bGFicwJubAAAHAABAAApEAAAAIAAAAA
    :scheme: https
    :authority: 127.0.0.1
    content-type: application/dns-message
    :status 200
    content-type application/dns-message
    ;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 0
    ;; flags: qr rd ra ad ; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
    ;; QUESTION SECTION:
    nlnetlabs.nl. IN AAAA

    ;; ANSWER SECTION:
    nlnetlabs.nl. 10200 IN AAAA 2a04:b900::1:0:0:10
    nlnetlabs.nl. 10200 IN RRSIG AAAA 8 2 10200 20200723194739 20200625194739 42393 nlnetlabs.nl. ML5NkbykTetqBPyA0xG5fuq1t/0ojsMUixgEhcewG93jZpF+vz8WhVo6czzdRMo/qq2kAmh3aFmU94wVWn+AULEEz6a/7B1Sxz9O+bXivZiWVitUopheSya68CNHO/zCl7j23QirecLGoXozbVqMIbinqG0LS32bHS+WOsJgQCQ= ;{id = 42393}

    ;; AUTHORITY SECTION:

    ;; ADDITIONAL SECTION:
    ; EDNS: version: 0; flags: do ; udp: 4096
    ;; MSG SIZE  rcvd: 241

Queries to other paths will be answered with a ``404`` status code. The
endpoint can be changed using the
:ref:`http-endpoint:<unbound.conf.http-endpoint>` configuration option.

The maximum number of concurrent HTTP/2 streams can be configured using the
:ref:`http-max-streams:<unbound.conf.http-max-streams>` configuration option.
The default for this option is 100, as per HTTP/2 RFC recommended minimum.
This value will be in the ``SETTINGS`` frame sent to the client, and enforced by
Unbound.

Because requests can be spread out over multiple HTTP/2 frames, which can be
interleaved between frames of different streams, we have to create buffers
containing partial queries. A new counter is added to Unbound to limit the total
memory consumed by all query buffers. The limit can be configured using the
:ref:`http-query-buffer-size:<unbound.conf.http-query-buffer-size>` option.
New streams will be closed by sending an ``RST_STREAM`` frame when this limit is
exceeded.

After Unbound is done resolving a request the DNS response will be stored in a
buffer, waiting until Unbound is ready to sent them back to the client using
HTTP. These buffers also have a maximum amount of memory they are allowed to
consume. This maximum is configurable using the
:ref:`http-response-buffer-size:<unbound.conf.http-response-buffer-size>`
configuration option.

Metrics
-------

Three DoH related metrics are available in Unbound;
:ref:`num.query.https<unbound-control.stats.num.query.https>` counts
the number of queries that have been serviced using DoH.
The :ref:`mem.http.query_buffer<unbound-control.stats.mem.http.query_buffer>`,
and
:ref:`mem.http.response_buffer<unbound-control.stats.mem.http.response_buffer>`
counters keep track of the memory used for the DoH query and response buffers.
