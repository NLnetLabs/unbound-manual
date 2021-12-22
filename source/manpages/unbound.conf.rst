unbound.conf(5)
===============

Synopsis
--------

:command:`unbound.conf`

Description
-----------

:command:`unbound.conf` is used to configure :manpage:`unbound(8)`. The file
format has attributes and values. Some attributes have attributes inside them.
The notation is: ``attribute: value``.

Comments start with ``#`` and last to the end of line. Empty lines are ignored
as is whitespace at the beginning of a line.

The utility :manpage:`unbound-checkconf(8)` can be used to check unbound.conf
prior to usage.

Example
-------

An example config file is shown below. Copy this to
:file:`/etc/unbound/unbound.conf` and start the server with:

.. code-block:: text

    $ unbound -c /etc/unbound/unbound.conf

Most settings are the defaults. Stop the server with:

.. code-block:: text

    $ kill `cat /etc/unbound/unbound.pid`

Below is a minimal config file. The source distribution contains an extensive
:file:`example.conf` file with all the options.

.. code-block:: text

    # unbound.conf(5) config file for unbound(8).
    server:
    directory: "/etc/unbound"
    username: unbound
    # make sure unbound can access entropy from inside the chroot.
    # e.g. on linux the use these commands (on BSD, devfs(8) is used):
    #      mount --bind -n /dev/urandom /etc/unbound/dev/urandom
    # and  mount --bind -n /dev/log /etc/unbound/dev/log
    chroot: "/etc/unbound"
    # logfile: "/etc/unbound/unbound.log"  #uncomment to use logfile.
    pidfile: "/etc/unbound/unbound.pid"
    # verbosity: 1      # uncomment and increase to get more logging.
    # listen on all interfaces, answer queries from the local subnet.
    interface: 0.0.0.0
    interface: ::0
    access-control: 10.0.0.0/8 allow
    access-control: 2001:DB8::/64 allow

File Format
-----------

There must be whitespace between keywords. Attribute keywords end with a colon
``':'``. An attribute is followed by a value, or its containing attributes in
which case it is referred to as a clause. Clauses can be repeated throughout the
file (or included files) to group attributes under the same clause.

Files can be included using the **include:** directive. It can appear anywhere,
it accepts a single file name as argument. Processing continues as if the text
from the included file was copied into the config file at that point. If also
using chroot, using full path names for the included files works, relative
pathnames for the included names work if the directory where the daemon is
started equals its chroot/working directory or is specified before the include
statement with directory: dir. Wildcards can be used to include multiple files,
see *glob(7)*.

For a more structural include option, the **include-toplevel:** directive can be
used. This closes whatever clause is currently active (if any) and forces the
use of clauses in the included files and right after this directive.

Server Options
^^^^^^^^^^^^^^

These options are part of the **server:** clause.

.. glossary::

    verbosity: *<number>*
        The verbosity number, level 0 means no verbosity, only errors. Level 1 gives
        operational information. Level 2 gives detailed operational information
        including short information per query. Level 3 gives query level
        information, output per query. Level 4 gives algorithm level information.
        Level 5 logs client identification for cache misses. Default is level 1. The
        verbosity can also be increased from the commandline, see
        :manpage:`unbound(8)`.

    statistics-interval: *<seconds>*
        The number of seconds between printing statistics to the log for every
        thread. Disable with value 0 or ``""``. Default is disabled. The histogram
        statistics are only printed if replies were sent during the statistics
        interval, requestlist statistics are printed for every interval (but can be
        0). This is because the median calculation requires data to be present.

    statistics-cumulative: *<yes or no>*
        If enabled, statistics are cumulative since starting unbound, without
        clearing the statistics counters after logging the statistics. Default is
        no.

    extended-statistics: *<yes or no>*
        If enabled, extended statistics are printed from
        :manpage:`unbound-control(8)`. Default is off, because keeping track of more
        statistics takes time. The counters are listed in
        :manpage:`unbound-control(8)`.

    num-threads: *<number>*
        The number of threads to create to serve clients. Use 1 for no threading.

    port: *<port number>*
        The port number, default 53, on which the server responds to queries.

    interface: *<ip address[@port]>*
        Interface to use to connect to the network. This interface is listened to
        for queries from clients, and answers to clients are given from it. Can be
        given multiple times to work on several interfaces. If none are given the
        default is to listen to localhost. If an interface name is used instead of
        an ip address, the list of ip addresses on that interface are used. The
        interfaces are not changed on a reload (kill -HUP) but only on restart. A
        port number can be specified with @port (without spaces between interface
        and port number), if not specified the default port (from **port**) is used.

    ip-address: *<ip address[@port]>*
        Same as interface: (for ease of compatibility with :file:`nsd.conf`).

    interface-automatic: *<yes or no>*
        Listen on all addresses on all (current and future) interfaces, detect the
        source interface on UDP queries and copy them to replies. This is a lot like
        ip-transparent, but this option services all interfaces whilst with
        ip-transparent you can select which (future) interfaces unbound provides
        service on. This feature is experimental, and needs support in your OS for
        particular socket options. Default value is no.

    outgoing-interface: *<ip address or ip6 netblock>*
        Interface to use to connect to the network. This interface is used to send
        queries to authoritative servers and receive their replies. Can be given
        multiple times to work on several interfaces. If none are given the default
        (all) is used. You can specify the same interfaces in **interface:** and
        **outgoing-interface:** lines, the interfaces are then used for both
        purposes. Outgoing queries are sent via a random outgoing interface to
        counter spoofing.

        If an IPv6 netblock is specified instead of an individual IPv6 address,
        outgoing UDP queries will use a randomised source address taken from the
        netblock to counter spoofing. Requires the IPv6 netblock to be routed to the
        host running unbound, and requires OS support for unprivileged non-local
        binds (currently only supported on Linux). Several netblocks may be
        specified with multiple **outgoing-interface:** options, but do not specify
        both an individual IPv6 address and an IPv6 netblock, or the randomisation
        will be compromised. Consider combining with **prefer-ip6:** yes to increase
        the likelihood of IPv6 nameservers being selected for queries. On Linux you
        need these two commands to be able to use the freebind socket option to
        receive traffic for the ip6 netblock: ip -6 addr add mynetblock/64 dev lo &&
        ip -6 route add local mynetblock/64 dev lo

    outgoing-range: *<number>*
        Number of ports to open. This number of file descriptors can be opened per
        thread. Must be at least 1. Default depends on compile options. Larger
        numbers need extra resources from the operating system. For performance a
        very large value is best, use libevent to make this possible.

    outgoing-port-permit: *<port number or range>*
        Permit unbound to open this port or range of ports for use to send queries.
        A larger number of permitted outgoing ports increases resilience against
        spoofing attempts. Make sure these ports are not needed by other daemons. By
        default only ports above 1024 that have not been assigned by IANA are used.
        Give a port number or a range of the form "low-high", without spaces.

        The **outgoing-port-permit** and **outgoing-port-avoid** statements are
        processed in the line order of the config file, adding the permitted ports
        and subtracting the avoided ports from the set of allowed ports. The
        processing starts with the non IANA allocated ports above 1024 in the set of
        allowed ports.

    outgoing-port-avoid: *<port number or range>*
        Do not permit unbound to open this port or range of ports for use to send
        queries. Use this to make sure unbound does not grab a port that another
        daemon needs. The port is avoided on all outgoing interfaces, both IP4 and
        IP6. By default only ports above 1024 that have not been assigned by IANA
        are used. Give a port number or a range of the form "low-high", without
        spaces.

    outgoing-num-tcp: *<number>*
        Number of outgoing TCP buffers to allocate per thread. Default is 10. If set
        to 0, or if do-tcp is "no", no TCP queries to authoritative servers are
        done. For larger installations increasing this value is a good idea.

    incoming-num-tcp: *<number>*
        Number of incoming TCP buffers to allocate per thread. Default is 10. If set
        to 0, or if do-tcp is "no", no TCP queries from clients are accepted. For
        larger installations increasing this value is a good idea.

    edns-buffer-size: *<number>*
        Number of bytes size to advertise as the EDNS reassembly buffer size. This
        is the value put into datagrams over UDP towards peers. The actual buffer
        size is determined by msg-buffer-size (both for TCP and UDP). Do not set
        higher than that value. Default is 1232 which is the DNS Flag Day 2020
        recommendation. Setting to 512 bypasses even the most stringent path MTU
        problems, but is seen as extreme, since the amount of TCP fallback generated
        is excessive (probably also for this resolver, consider tuning the outgoing
        tcp number).

    max-udp-size: *<number>*
        Maximum UDP response size (not applied to TCP response). 65536 disables the
        udp response size maximum, and uses the choice from the client, always.
        Suggested values are 512 to 4096. Default is 4096.

    stream-wait-size: *<number>*
        Number of bytes size maximum to use for waiting stream buffers. Default is 4
        megabytes. A plain number is in bytes, append 'k', 'm' or 'g' for kilobytes,
        megabytes or gigabytes (1024*1024 bytes in a megabyte). As TCP and TLS
        streams queue up multiple results, the amount of memory used for these
        buffers does not exceed this number, otherwise the responses are dropped.
        This manages the total memory usage of the server (under heavy use), the
        number of requests that can be queued up per connection is also limited,
        with further requests waiting in TCP buffers.

    msg-buffer-size: *<number>*
        Number of bytes size of the message buffers. Default is 65552 bytes, enough
        for 64 Kb packets, the maximum DNS message size. No message larger than this
        can be sent or received. Can be reduced to use less memory, but some
        requests for DNS data, such as for huge resource records, will result in a
        SERVFAIL reply to the client.

    msg-cache-size: *<number>*
        Number of bytes size of the message cache. Default is 4 megabytes. A plain
        number is in bytes, append 'k', 'm' or 'g' for kilobytes, megabytes or
        gigabytes (1024*1024 bytes in a megabyte).

    msg-cache-slabs: *<number>*
        Number of slabs in the message cache. Slabs reduce lock contention by
        threads. Must be set to a power of 2. Setting (close) to the number of cpus
        is a reasonable guess.

    num-queries-per-thread: *<number>*
        The number of queries that every thread will service simultaneously. If more
        queries arrive that need servicing, and no queries can be jostled out (see
        jostle-timeout), then the queries are dropped. This forces the client to
        resend after a timeout; allowing the server time to work on the existing
        queries. Default depends on compile options, 512 or 1024.

    jostle-timeout: *<msec>*
        Timeout used when the server is very busy. Set to a value that usually
        results in one roundtrip to the authority servers. If too many queries
        arrive, then 50% of the queries are allowed to run to completion, and the
        other 50% are replaced with the new incoming query if they have already
        spent more than their allowed time. This protects against denial of service
        by slow queries or high query rates. Default 200 milliseconds. The effect is
        that the qps for long-lasting queries is about (numqueriesperthread / 2) /
        (average time for such long queries) qps. The qps for short queries can be
        about (numqueriesperthread / 2) / (jostletimeout in whole seconds) qps per
        thread, about (1024/2)*5 = 2560 qps by default.

    delay-close: *<msec>*
        Extra delay for timeouted UDP ports before they are closed, in msec. Default
        is 0, and that disables it. This prevents very delayed answer packets from
        the upstream (recursive) servers from bouncing against closed ports and
        setting off all sort of close-port counters, with eg. 1500 msec. When
        timeouts happen you need extra sockets, it checks the ID and remote IP of
        packets, and unwanted packets are added to the unwanted packet counter.

    udp-connect: *<yes or no>*
        Perform connect for UDP sockets that mitigates ICMP side channel leakage.
        Default is yes.

    unknown-server-time-limit: *<msec>*
        The wait time in msec for waiting for an unknown server to reply. Increase
        this if you are behind a slow satellite link, to eg. 1128. That would then
        avoid re-querying every initial query because it times out. Default is 376
        msec.

    so-rcvbuf: *<number>*
        If not 0, then set the SO_RCVBUF socket option to get more buffer space on
        UDP port 53 incoming queries. So that short spikes on busy servers do not
        drop packets (see counter in netstat -su). Default is 0 (use system value).
        Otherwise, the number of bytes to ask for, try "4m" on a busy server. The OS
        caps it at a maximum, on linux unbound needs root permission to bypass the
        limit, or the admin can use sysctl net.core.rmem_max. On BSD change
        kern.ipc.maxsockbuf in /etc/sysctl.conf. On OpenBSD change header and
        recompile kernel. On Solaris ndd -set /dev/udp udp_max_buf 8388608.

    so-sndbuf: *<number>*
        If not 0, then set the SO_SNDBUF socket option to get more buffer space on
        UDP port 53 outgoing queries. This for very busy servers handles spikes in
        answer traffic, otherwise 'send: resource temporarily unavailable' can get
        logged, the buffer overrun is also visible by netstat -su. Default is 0 (use
        system value). Specify the number of bytes to ask for, try "4m" on a very
        busy server. The OS caps it at a maximum, on linux unbound needs root
        permission to bypass the limit, or the admin can use sysctl
        net.core.wmem_max. On BSD, Solaris changes are similar to so-rcvbuf.

    so-reuseport: *<yes or no>*
        If yes, then open dedicated listening sockets for incoming queries for each
        thread and try to set the SO_REUSEPORT socket option on each socket. May
        distribute incoming queries to threads more evenly. Default is yes. On Linux
        it is supported in kernels >= 3.9. On other systems, FreeBSD, OSX it may
        also work. You can enable it (on any platform and kernel), it then attempts
        to open the port and passes the option if it was available at compile time,
        if that works it is used, if it fails, it continues silently (unless
        verbosity 3) without the option. At extreme load it could be better to turn
        it off to distribute the queries evenly, reported for Linux systems (4.4.x).

    ip-transparent: *<yes or no>*
        If yes, then use IP_TRANSPARENT socket option on sockets where unbound is
        listening for incoming traffic. Default no. Allows you to bind to non-local
        interfaces. For example for non-existent IP addresses that are going to
        exist later on, with host failover configuration. This is a lot like
        interface-automatic, but that one services all interfaces and with this
        option you can select which (future) interfaces unbound provides service on.
        This option needs unbound to be started with root permissions on some
        systems. The option uses IP_BINDANY on FreeBSD systems and SO_BINDANY on
        OpenBSD systems.

    ip-freebind: *<yes or no>*
        If yes, then use IP_FREEBIND socket option on sockets where unbound is
        listening to incoming traffic. Default no. Allows you to bind to IP
        addresses that are nonlocal or do not exist, like when the network interface
        or IP address is down. Exists only on Linux, where the similar
        ip-transparent option is also available.

    ip-dscp: *<number>*
        The value of the Differentiated Services Codepoint (DSCP) in the
        differentiated services field (DS) of the outgoing IP packet headers. The
        field replaces the outdated IPv4 Type-Of-Service field and the IPV6 traffic
        class field.

    rrset-cache-size: *<number>*
        Number of bytes size of the RRset cache. Default is 4 megabytes. A plain
        number is in bytes, append 'k', 'm' or 'g' for kilobytes, megabytes or
        gigabytes (1024*1024 bytes in a megabyte).

    rrset-cache-slabs: *<number>*
        Number of slabs in the RRset cache. Slabs reduce lock contention by threads.
        Must be set to a power of 2.

    cache-max-ttl: *<seconds>*
        Time to live maximum for RRsets and messages in the cache. Default is 86400
        seconds (1 day). When the TTL expires, the cache item has expired. Can be
        set lower to force the resolver to query for data often, and not trust (very
        large) TTL values. Downstream clients also see the lower TTL.

    cache-min-ttl: *<seconds>*
        Time to live minimum for RRsets and messages in the cache. Default is 0. If
        the minimum kicks in, the data is cached for longer than the domain owner
        intended, and thus less queries are made to look up the data. Zero makes
        sure the data in the cache is as the domain owner intended, higher values,
        especially more than an hour or so, can lead to trouble as the data in the
        cache does not match up with the actual data any more.

    cache-max-negative-ttl: *<seconds>*
        Time to live maximum for negative responses, these have a SOA in the
        authority section that is limited in time. Default is 3600. This applies to
        nxdomain and nodata answers.

    infra-host-ttl: *<seconds>*
        Time to live for entries in the host cache. The host cache contains
        roundtrip timing, lameness and EDNS support information. Default is 900.

    infra-cache-slabs: *<number>*
        Number of slabs in the infrastructure cache. Slabs reduce lock contention by
        threads. Must be set to a power of 2.

    infra-cache-numhosts: *<number>*
        Number of hosts for which information is cached. Default is 10000.

    infra-cache-min-rtt: *<msec>*
        Lower limit for dynamic retransmit timeout calculation in infrastructure
        cache. Default is 50 milliseconds. Increase this value if using forwarders
        needing more time to do recursive name resolution.

    infra-keep-probing: *<yes or no>*
        If enabled the server keeps probing hosts that are down, in the one probe at
        a time regime. Default is no. Hosts that are down, eg. they did not respond
        during the one probe at a time period, are marked as down and it may take
        infra-host-ttl time to get probed again.

    define-tag: *<"list of tags">*
        Define the tags that can be used with local-zone and access-control. Enclose
        the list between quotes (``""``) and put spaces between tags.

    do-ip4: *<yes or no>*
        Enable or disable whether ip4 queries are answered or issued. Default is
        yes.

    do-ip6: *<yes or no>*
        Enable or disable whether ip6 queries are answered or issued. Default is
        yes. If disabled, queries are not answered on IPv6, and queries are not sent
        on IPv6 to the internet nameservers. With this option you can disable the
        ipv6 transport for sending DNS traffic, it does not impact the contents of
        the DNS traffic, which may have ip4 and ip6 addresses in it.

    prefer-ip4: *<yes or no>*
        If enabled, prefer IPv4 transport for sending DNS queries to internet
        nameservers. Default is no. Useful if the IPv6 netblock the server has, the
        entire /64 of that is not owned by one operator and the reputation of the
        netblock /64 is an issue, using IPv4 then uses the IPv4 filters that the
        upstream servers have.

    prefer-ip6: *<yes or no>*
        If enabled, prefer IPv6 transport for sending DNS queries to internet
        nameservers. Default is no.

    do-udp: *<yes or no>*
        Enable or disable whether UDP queries are answered or issued. Default is
        yes.

    do-tcp: *<yes or no>*
        Enable or disable whether TCP queries are answered or issued. Default is
        yes.

    tcp-mss: *<number>*
        Maximum segment size (MSS) of TCP socket on which the server responds to
        queries. Value lower than common MSS on Ethernet (1220 for example) will
        address path MTU problem. Note that not all platform supports socket option
        to set MSS (TCP_MAXSEG). Default is system default MSS determined by
        interface MTU and negotiation between server and client.

    outgoing-tcp-mss: *<number>*
        Maximum segment size (MSS) of TCP socket for outgoing queries (from Unbound
        to other servers). Value lower than common MSS on Ethernet (1220 for
        example) will address path MTU problem. Note that not all platform supports
        socket option to set MSS (TCP_MAXSEG). Default is system default MSS
        determined by interface MTU and negotiation between Unbound and other
        servers.

    tcp-idle-timeout: *<msec>*
        The period Unbound will wait for a query on a TCP connection. If this
        timeout expires Unbound closes the connection. This option defaults to 30000
        milliseconds. When the number of free incoming TCP buffers falls below 50%
        of the total number configured, the option value used is progressively
        reduced, first to 1% of the configured value, then to 0.2% of the configured
        value if the number of free buffers falls below 35% of the total number
        configured, and finally to 0 if the number of free buffers falls below 20%
        of the total number configured. A minimum timeout of 200 milliseconds is
        observed regardless of the option value used.

    tcp-reuse-timeout: *<msec>*
        The period Unbound will keep TCP persistent connections open to authority
        servers. This option defaults to 60000 milliseconds.

    max-reuse-tcp-queries: *<number>*
        The maximum number of queries that can be sent on a persistent TCP
        connection. This option defaults to 200 queries.

    tcp-auth-query-timeout: *<number>*
        Timeout in milliseconds for TCP queries to auth servers. This option
        defaults to 3000 milliseconds.

    edns-tcp-keepalive: *<yes or no>*
        Enable or disable EDNS TCP Keepalive. Default is no.

    edns-tcp-keepalive-timeout: *<msec>*
        The period Unbound will wait for a query on a TCP connection when EDNS TCP
        Keepalive is active. If this timeout expires Unbound closes the connection.
        If the client supports the EDNS TCP Keepalive option, Unbound sends the
        timeout value to the client to encourage it to close the connection before
        the server times out. This option defaults to 120000 milliseconds. When the
        number of free incoming TCP buffers falls below 50% of the total number
        configured, the advertised timeout is progressively reduced to 1% of the
        configured value, then to 0.2% of the configured value if the number of free
        buffers falls below 35% of the total number configured, and finally to 0 if
        the number of free buffers falls below 20% of the total number configured. A
        minimum actual timeout of 200 milliseconds is observed regardless of the
        advertised timeout.

    tcp-upstream: *<yes or no>*
        Enable or disable whether the upstream queries use TCP only for transport.
        Default is no. Useful in tunneling scenarios. If set to no you can specify
        TCP transport only for selected forward or stub zones using
        forward-tcp-upstream or stub-tcp-upstream respectively.

    udp-upstream-without-downstream: *<yes or no>*
        Enable udp upstream even if do-udp is no. Default is no, and this does not
        change anything. Useful for TLS service providers, that want no udp
        downstream but use udp to fetch data upstream.

    tls-upstream: *<yes or no>*
        Enabled or disable whether the upstream queries use TLS only for transport.
        Default is no. Useful in tunneling scenarios. The TLS contains plain DNS in
        TCP wireformat. The other server must support this (see
        **tls-service-key**). If you enable this, also configure a tls-cert-bundle
        or use tls-win-cert to load CA certs, otherwise the connections cannot be
        authenticated. This option enables TLS for all of them, but if you do not
        set this you can configure TLS specifically for some forward zones with
        forward-tls-upstream. And also with stub-tls-upstream.

    ssl-upstream: *<yes or no>*
        Alternate syntax for **tls-upstream**. If both are present in the config
        file the last is used.

    tls-service-key: *<file>*
        If enabled, the server provides DNS-over-TLS or DNS-over-HTTPS service on
        the TCP ports marked implicitly or explicitly for these services with
        tls-port or https-port. The file must contain the private key for the TLS
        session, the public certificate is in the tls-service-pem file and it must
        also be specified if tls-service-key is specified. The default is ``""``,
        turned off. Enabling or disabling this service requires a restart (a reload
        is not enough), because the key is read while root permissions are held and
        before chroot (if any). The ports enabled implicitly or explicitly via
        **tls-port:** and **https-port:** do not provide normal DNS TCP service.
        Unbound needs to be compiled with libnghttp2 in order to provide
        DNS-over-HTTPS.

    ssl-service-key: *<file>*
        Alternate syntax for **tls-service-key**.

    tls-service-pem: *<file>*
        The public key certificate pem file for the tls service. Default is ``""``,
        turned off.

    ssl-service-pem: *<file>*
        Alternate syntax for **tls-service-pem**.

    tls-port: *<number>*
        The port number on which to provide TCP TLS service, default 853, only
        interfaces configured with that port number as @number get the TLS service.

    ssl-port: *<number>*
        Alternate syntax for **tls-port**.

    tls-cert-bundle: *<file>*
        If null or ``""``, no file is used. Set it to the certificate bundle file,
        for example "/etc/pki/tls/certs/ca-bundle.crt". These certificates are used
        for authenticating connections made to outside peers. For example auth-zone
        urls, and also DNS over TLS connections. It is read at start up before
        permission drop and chroot.

    ssl-cert-bundle: *<file>*
        Alternate syntax for **tls-cert-bundle**.

    tls-win-cert: *<yes or no>*
        Add the system certificates to the cert bundle certificates for
        authentication. If no cert bundle, it uses only these certificates. Default
        is no. On windows this option uses the certificates from the cert store. Use
        the tls-cert-bundle option on other systems.

    tls-additional-port: *<portnr>*
        List portnumbers as tls-additional-port, and when interfaces are defined,
        eg. with the @port suffix, as this port number, they provide dns over TLS
        service. Can list multiple, each on a new statement.

    tls-session-ticket-keys: *<file>*
        If not ``""``, lists files with 80 bytes of random contents that are used to
        perform TLS session resumption for clients using the unbound server. These
        files contain the secret key for the TLS session tickets. First key use to
        encrypt and decrypt TLS session tickets. Other keys use to decrypt only.
        With this you can roll over to new keys, by generating a new first file and
        allowing decrypt of the old file by listing it after the first file for some
        time, after the wait clients are not using the old key any more and the old
        key can be removed. One way to create the file is dd if=/dev/random bs=1
        count=80 of=ticket.dat The first 16 bytes should be different from the old
        one if you create a second key, that is the name used to identify the key.
        Then there is 32 bytes random data for an AES key and then 32 bytes random
        data for the HMAC key.

    tls-ciphers: *<string with cipher list>*
        Set the list of ciphers to allow when serving TLS. Use ``""`` for defaults,
        and that is the default.

    tls-ciphersuites: *<string with ciphersuites list>*
        Set the list of ciphersuites to allow when serving TLS. This is for newer
        TLS 1.3 connections. Use ``""`` for defaults, and that is the default.

    pad-responses: *<yes or no>*
        If enabled, TLS serviced queries that contained an EDNS Padding option will
        cause responses padded to the closest multiple of the size specified in
        pad-responses-block-size. Default is yes.

    pad-responses-block-size: *<number>*
        The block size with which to pad responses serviced over TLS. Only responses
        to padded queries will be padded. Default is 468.

    pad-queries: *<yes or no>*
        If enabled, all queries sent over TLS upstreams will be padded to the
        closest multiple of the size specified in **pad-queries-block-size**.
        Default is yes.

    pad-queries-block-size: *<number>*
        The block size with which to pad queries sent over TLS upstreams. Default is
        128.

    tls-use-sni: *<yes or no>*
        Enable or disable sending the SNI extension on TLS connections. Default is
        yes. Changing the value requires a reload.

    https-port: *<number>*
        The port number on which to provide DNS-over-HTTPS service, default 443,
        only interfaces configured with that port number as @number get the HTTPS
        service.

    http-endpoint: *<endpoint string>*
        The HTTP endpoint to provide DNS-over-HTTPS service on. Default
        "/dns-query".

    http-max-streams: *<number of streams>*
        Number used in the SETTINGS_MAX_CONCURRENT_STREAMS parameter in the HTTP/2
        SETTINGS frame for DNS-over-HTTPS connections. Default 100.

    http-query-buffer-size: *<size in bytes>*
        Maximum number of bytes used for all HTTP/2 query buffers combined. These
        buffers contain (partial) DNS queries waiting for request stream completion.
        An RST_STREAM frame will be send to streams exceeding this limit. Default is
        4 megabytes. A plain number is in bytes, append 'k', 'm' or 'g' for
        kilobytes, megabytes or gigabytes (1024*1024 bytes in a megabyte).

    http-response-buffer-size: *<size in bytes>*
        Maximum number of bytes used for all HTTP/2 response buffers combined. These
        buffers contain DNS responses waiting to be written back to the clients. An
        RST_STREAM frame will be send to streams exceeding this limit. Default is 4
        megabytes. A plain number is in bytes, append 'k', 'm' or 'g' for kilobytes,
        megabytes or gigabytes (1024*1024 bytes in a megabyte).

    http-nodelay: *<yes or no>*
        Set TCP_NODELAY socket option on sockets used to provide DNSover-HTTPS
        service. Ignored if the option is not available. Default is yes.

    http-notls-downstream: *<yes or no>*
        Disable use of TLS for the downstream DNS-over-HTTP connections. Useful for
        local back end servers. Default is no.

    use-systemd: *<yes or no>*
        Enable or disable systemd socket activation. Default is no.

    do-daemonize: *<yes or no>*
        Enable or disable whether the unbound server forks into the background as a
        daemon. Set the value to no when unbound runs as systemd service. Default is
        yes.

    tcp-connection-limit: *<IP netblock> <limit>*
        Allow up to limit simultaneous TCP connections from the given netblock. When
        at the limit, further connections are accepted but closed immediately. This
        option is experimental at this time.

    access-control: *<IP netblock> <action>*
        The netblock is given as an IP4 or IP6 address with /size appended for a
        classless network block. The action can be *deny, refuse, allow,
        allow_setrd, allow_snoop, deny_non_local* or *refuse_non_local*. The most
        specific netblock match is used, if none match deny is used. The order of
        the access-control statements therefore does not matter.

        The action *deny* stops queries from hosts from that netblock.

        The action *refuse* stops queries too, but sends a DNS rcode REFUSED error
        message back.

        The action *allow* gives access to clients from that netblock. It gives only
        access for recursion clients (which is what almost all clients need).
        Nonrecursive queries are refused.

        The *allow* action does allow nonrecursive queries to access the local-data
        that is configured. The reason is that this does not involve the unbound
        server recursive lookup algorithm, and static data is served in the reply.
        This supports normal operations where nonrecursive queries are made for the
        authoritative data. For nonrecursive queries any replies from the dynamic
        cache are refused.

        The *allow_setrd* action ignores the recursion desired (RD) bit and treats all
        requests as if the recursion desired bit is set. Note that this behavior
        violates RFC 1034 which states that a name server should never perform
        recursive service unless asked via the RD bit since this interferes with
        trouble shooting of name servers and their databases. This prohibited
        behavior may be useful if another DNS server must forward requests for
        specific zones to a resolver DNS server, but only supports stub domains and
        sends queries to the resolver DNS server with the RD bit cleared.

        The action *allow_snoop* gives nonrecursive access too. This give both
        recursive and non recursive access. The name *allow_snoop* refers to cache
        snooping, a technique to use nonrecursive queries to examine the cache
        contents (for malicious acts). However, nonrecursive queries can also be a
        valuable debugging tool (when you want to examine the cache contents). In
        that case use *allow_snoop* for your administration host.

        By default only localhost is *allowed*, the rest is refused. The default is
        *refused*, because that is protocol-friendly. The DNS protocol is not designed
        to handle dropped packets due to policy, and dropping may result in
        (possibly excessive) retried queries.

        The deny_non_local and refuse_non_local settings are for hosts that are only
        allowed to query for the authoritative local-data, they are not allowed full
        recursion but only the static data. With deny_non_local, messages that are
        disallowed are dropped, with refuse_non_local they receive error code
        REFUSED.

    access-control-tag: *<IP netblock> <"list of tags">*
        Assign tags to access-control elements. Clients using this access control
        element use localzones that are tagged with one of these tags. Tags must be
        defined in *define-tags*. Enclose list of tags in quotes (``""``) and put
        spaces between tags. If access-control-tag is configured for a netblock that
        does not have an access-control, an access-control element with action allow
        is configured for this netblock.

    access-control-tag-action: *<IP netblock> <tag> <action>*
        Set action for particular tag for given access control element. If you have
        multiple tag values, the tag used to lookup the action is the first tag
        match between access-control-tag and local-zone-tag where "first" comes from
        the order of the definetag values.

    access-control-tag-data: *<IP netblock> <tag> <"resource record string">*
        Set redirect data for particular tag for given access control element.

    access-control-view: *<IP netblock> <view name>*
        Set view for given access control element.

    chroot: *<directory>*
        If chroot is enabled, you should pass the configfile (from the commandline)
        as a full path from the original root. After the chroot has been performed
        the now defunct portion of the config file path is removed to be able to
        reread the config after a reload.

        All other file paths (working dir, logfile, roothints, and key files) can be
        specified in several ways: as an absolute path relative to the new root, as
        a relative path to the working directory, or as an absolute path relative to
        the original root. In the last case the path is adjusted to remove the
        unused portion.

        The pidfile can be either a relative path to the working directory, or an
        absolute path relative to the original root. It is written just prior to
        chroot and dropping permissions. This allows the pidfile to be
        :file:`/var/run/unbound.pid` and the chroot to be :file:`/var/unbound`, for
        example. Note that Unbound is not able to remove the pidfile after
        termination when it is located outside of the chroot directory.

        Additionally, unbound may need to access :file:`/dev/urandom` (for entropy)
        from inside the chroot.

        If given a chroot is done to the given directory. By default chroot is
        enabled and the default is :file:`"/usr/local/etc/unbound"`. If you give
        ``""`` no chroot is performed.

    username: *<name>*
        If given, after binding the port the user privileges are dropped. Default is
        "unbound". If you give username: ``""`` no user change is performed.

        If this user is not capable of binding the port, reloads (by signal HUP)
        will still retain the opened ports. If you change the port number in the
        config file, and that new port number requires privileges, then a reload
        will fail; a restart is needed.

    directory: *<directory>*
        Sets the working directory for the program. Default is
        :file:`"/usr/local/etc/unbound"`. On Windows the string "%EXECUTABLE%" tries
        to change to the directory that :command:`unbound.exe` resides in. If you
        give a *server:* *directory:* dir before *include:* file statements then
        those includes can be relative to the working directory.

    logfile: *<filename>*
        If ``""`` is given, logging goes to stderr, or nowhere once daemonized. The
        logfile is appended to, in the following format: 

        .. code-block:: text
            
            [seconds since 1970] unbound[pid:tid]: type: message. 
            
        If this option is given, the use-syslog is option is set to "no". The
        logfile is reopened (for append) when the config file is reread, on SIGHUP.

    use-syslog: *<yes or no>*
        Sets unbound to send log messages to the syslogd, using *syslog(3)*. The log
        facility LOG_DAEMON is used, with identity "unbound". The logfile setting is
        overridden when use-syslog is turned on. The default is to log to syslog.

    log-identity: *<string>*
        If ``""`` is given (default), then the name of the executable, usually
        "unbound" is used to report to the log. Enter a string to override it with
        that, which is useful on systems that run more than one instance of unbound,
        with different configurations, so that the logs can be easily distinguished
        against.

    log-time-ascii: *<yes or no>*
        Sets logfile lines to use a timestamp in UTC ascii. Default is no, which
        prints the seconds since 1970 in brackets. No effect if using syslog, in
        that case syslog formats the timestamp printed into the log files.

    log-queries: *<yes or no>*
        Prints one line per query to the log, with the log timestamp and IP address,
        name, type and class. Default is no. Note that it takes time to print these
        lines which makes the server (significantly) slower. Odd (nonprintable)
        characters in names are printed as ``'?'``.

    log-replies: *<yes or no>*
        Prints one line per reply to the log, with the log timestamp and IP address,
        name, type, class, return code, time to resolve, from cache and response
        size. Default is no. Note that it takes time to print these lines which
        makes the server (significantly) slower. Odd (nonprintable) characters in
        names are printed as ``'?'``.

    log-tag-queryreply: *<yes or no>*
        Prints the word 'query' and 'reply' with log-queries and log-replies. This
        makes filtering logs easier. The default is off (for backwards
        compatibility).

    log-local-actions: *<yes or no>*
        Print log lines to inform about local zone actions. These lines are like the
        local-zone type inform prints out, but they are also printed for the other
        types of local zones.

    log-servfail: *<yes or no>*
        Print log lines that say why queries return SERVFAIL to clients. This is
        separate from the verbosity debug logs, much smaller, and printed at the
        error level, not the info level of debug info from verbosity.

    pidfile: *<filename>*
        The process id is written to the file. Default is
        :file:`"/usr/local/etc/unbound/unbound.pid"`. So,

        .. code-block:: bash

            kill -HUP `cat /usr/local/etc/unbound/unbound.pid`

        triggers a reload,

        .. code-block:: bash

            kill -TERM `cat /usr/local/etc/unbound/unbound.pid`
            
        gracefully terminates.

    root-hints: *<filename>*
        Read the root hints from this file. Default is nothing, using builtin hints
        for the IN class. The file has the format of zone files, with root
        nameserver names and addresses only. The default may become outdated, when
        servers change, therefore it is good practice to use a root-hints file.

    hide-identity: *<yes or no>*
        If enabled id.server and hostname.bind queries are refused.

    identity: *<string>*
        Set the identity to report. If set to ``""``, the default, then the hostname
        of the server is returned.

    hide-version: *<yes or no>*
        If enabled version.server and version.bind queries are refused.

    version: *<string>*
        Set the version to report. If set to ``""``, the default, then the package
        version is returned.

    hide-http-user-agent: *<yes or no>*
        If enabled the HTTP header User-Agent is not set. Use with caution as some
        webserver configurations may reject HTTP requests lacking this header. If
        needed, it is better to explicitly set the http-user-agent below.

    http-user-agent: *<string>*
        Set the HTTP User-Agent header for outgoing HTTP requests. If set to ``""``,
        the default, then the package name and version are used.

    nsid: *<string>*
        Add the specified nsid to the EDNS section of the answer when queried with
        an NSID EDNS enabled packet. As a sequence of hex characters or with ascii\_
        prefix and then an ascii string.

    hide-trustanchor: *<yes or no>*
        If enabled trustanchor.unbound queries are refused.

    target-fetch-policy: *<"list of numbers">*
        Set the target fetch policy used by unbound to determine if it should fetch
        nameserver target addresses opportunistically. The policy is described per
        dependency depth.

        The number of values determines the maximum dependency depth that unbound
        will pursue in answering a query. A value of -1 means to fetch all targets
        opportunistically for that dependency depth. A value of 0 means to fetch on
        demand only. A positive value fetches that many targets opportunistically.

        Enclose the list between quotes (``""``) and put spaces between numbers. The
        default is "3 2 1 0 0". Setting all zeroes, "0 0 0 0 0" gives behaviour
        closer to that of BIND 9, while setting "-1 -1 -1 -1 -1" gives behaviour
        rumoured to be closer to that of BIND 8.

    harden-short-bufsize: *<yes or no>*
        Very small EDNS buffer sizes from queries are ignored. Default is on, as
        described in the standard.

    harden-large-queries: *<yes or no>*
        Very large queries are ignored. Default is off, since it is legal protocol
        wise to send these, and could be necessary for operation if TSIG or EDNS
        payload is very large.

    harden-glue: *<yes or no>*
        Will trust glue only if it is within the servers authority. Default is yes.

    harden-dnssec-stripped: *<yes or no>*
        Require DNSSEC data for trust-anchored zones, if such data is absent, the
        zone becomes bogus. If turned off, and no DNSSEC data is received (or the
        DNSKEY data fails to validate), then the zone is made insecure, this behaves
        like there is no trust anchor. You could turn this off if you are sometimes
        behind an intrusive firewall (of some sort) that removes DNSSEC data from
        packets, or a zone changes from signed to unsigned to badly signed often. If
        turned off you run the risk of a downgrade attack that disables security for
        a zone. Default is yes.

    harden-below-nxdomain: *<yes or no>*
        From :RFC:`8020` (with title "NXDOMAIN: There Really Is Nothing Underneath"),
        returns nxdomain to queries for a name below another name that is already
        known to be nxdomain. DNSSEC mandates noerror for empty nonterminals, hence
        this is possible. Very old software might return nxdomain for empty
        nonterminals (that usually happen for reverse IP address lookups), and thus
        may be incompatible with this. To try to avoid this only DNSSEC-secure
        nxdomains are used, because the old software does not have DNSSEC. Default
        is yes. The nxdomain must be secure, this means nsec3 with optout is
        insufficient.

    harden-referral-path: *<yes or no>*
        Harden the referral path by performing additional queries for infrastructure
        data. Validates the replies if trust anchors are configured and the zones
        are signed. This enforces DNSSEC validation on nameserver NS sets and the
        nameserver addresses that are encountered on the referral path to the
        answer. Default no, because it burdens the authority servers, and it is not
        RFC standard, and could lead to performance problems because of the extra
        query load that is generated. Experimental option. If you enable it consider
        adding more numbers after the target-fetch-policy to increase the max depth
        that is checked to.

    harden-algo-downgrade: *<yes or no>*
        Harden against algorithm downgrade when multiple algorithms are advertised
        in the DS record. If no, allows the weakest algorithm to validate the zone.
        Default is no. Zone signers must produce zones that allow this feature to
        work, but sometimes they do not, and turning this option off avoids that
        validation failure.

    use-caps-for-id: *<yes or no>*
        Use 0x20-encoded random bits in the query to foil spoof attempts. This
        perturbs the lowercase and uppercase of query names sent to authority
        servers and checks if the reply still has the correct casing. Disabled by
        default. This feature is an experimental implementation of draft dns-0x20.

    caps-exempt: *<domain>*
        Exempt the domain so that it does not receive caps-for-id perturbed queries.
        For domains that do not support 0x20 and also fail with fallback because
        they keep sending different answers, like some load balancers. Can be given
        multiple times, for different domains.

    caps-whitelist: *<yes or no>*
        Alternate syntax for **caps-exempt**.

    qname-minimisation: *<yes or no>*
        Send minimum amount of information to upstream servers to enhance privacy.
        Only send minimum required labels of the QNAME and set QTYPE to A when
        possible. Best effort approach; full QNAME and original QTYPE will be sent
        when upstream replies with a RCODE other than NOERROR, except when receiving
        NXDOMAIN from a DNSSEC signed zone. Default is yes.

    qname-minimisation-strict: *<yes or no>*
        QNAME minimisation in strict mode. Do not fall-back to sending full QNAME to
        potentially broken nameservers. A lot of domains will not be resolvable when
        this option in enabled. Only use if you know what you are doing. This option
        only has effect when qname-minimisation is enabled. Default is no.

    aggressive-nsec: *<yes or no>*
        Aggressive NSEC uses the DNSSEC NSEC chain to synthesize NXDOMAIN and other
        denials, using information from previous NXDOMAINs answers. Default is no.
        It helps to reduce the query rate towards targets that get a very high
        nonexistent name lookup rate.

    private-address: *<IP address or subnet>*
        Give IPv4 of IPv6 addresses or classless subnets. These are addresses on
        your private network, and are not allowed to be returned for public internet
        names. Any occurrence of such addresses are removed from DNS answers.
        Additionally, the DNSSEC validator may mark the answers bogus. This protects
        against so-called DNS Rebinding, where a user browser is turned into a
        network proxy, allowing remote access through the browser to other parts of
        your private network. Some names can be allowed to contain your private
        addresses, by default all the **local-data** that you configured is allowed
        to, and you can specify additional names using **private-domain**. No
        private addresses are enabled by default. We consider to enable this for the
        :RFC:`1918` private IP address space by default in later releases. That
        would enable private addresses for ``10.0.0.0/8``, ``172.16.0.0/12``,
        ``192.168.0.0/16``, ``169.254.0.0/16``, ``fd00::/8`` and ``fe80::/10``,
        since the RFC standards say these addresses should not be visible on the
        public internet. Turning on ``127.0.0.0/8`` would hinder many spamblocklists
        as they use that. Adding ``::ffff:0:0/96`` stops IPv4-mapped IPv6 addresses
        from bypassing the filter.

    private-domain: *<domain name>*
        Allow this domain, and all its subdomains to contain private addresses. Give
        multiple times to allow multiple domain names to contain private addresses.
        Default is none.

    unwanted-reply-threshold: *<number>*
        If set, a total number of unwanted replies is kept track of in every thread.
        When it reaches the threshold, a defensive action is taken and a warning is
        printed to the log. The defensive action is to clear the rrset and message
        caches, hopefully flushing away any poison. A value of 10 million is
        suggested. Default is 0 (turned off).

    do-not-query-address: *<IP address>*
        Do not query the given IP address. Can be IP4 or IP6. Append
        /num to indicate a classless delegation netblock, for example
        like ``10.2.3.4/24`` or ``2001::11/64``.

    do-not-query-localhost: *<yes or no>*
        If yes, localhost is added to the do-not-query-address entries, both IP6
        ``::1`` and IP4 ``127.0.0.1/8``. If no, then localhost can be used to send
        queries to. Default is yes.

    prefetch: *<yes or no>*
        If yes, message cache elements are prefetched before they expire to keep the
        cache up to date. Default is no. Turning it on gives about 10 percent more
        traffic and load on the machine, but popular items do not expire from the
        cache.

    prefetch-key: *<yes or no>*
        If yes, fetch the DNSKEYs earlier in the validation process, when a DS
        record is encountered. This lowers the latency of requests. It does use a
        little more CPU. Also if the cache is set to 0, it is no use. Default is no.

    deny-any: *<yes or no>*
        If yes, deny queries of type ANY with an empty response. Default is no. If
        disabled, unbound responds with a short list of resource records if some can
        be found in the cache and makes the upstream type ANY query if there are
        none.

    rrset-roundrobin: *<yes or no>*
        If yes, Unbound rotates RRSet order in response (the random number is taken
        from the query ID, for speed and thread safety). Default is yes.

    minimal-responses: *<yes or no>*
        If yes, Unbound does not insert authority/additional sections into response
        messages when those sections are not required. This reduces response size
        significantly, and may avoid TCP fallback for some responses. This may cause
        a slight speedup. The default is yes, even though the DNS protocol RFCs
        mandate these sections, and the additional content could be of use and save
        roundtrips for clients. Because they are not used, and the saved roundtrips
        are easier saved with prefetch, whilst this is faster.

    disable-dnssec-lame-check: *<yes or no>*
        If true, disables the DNSSEC lameness check in the iterator. This check sees
        if RRSIGs are present in the answer, when dnssec is expected, and retries
        another authority if RRSIGs are unexpectedly missing. The validator will
        insist in RRSIGs for DNSSEC signed domains regardless of this setting, if a
        trust anchor is loaded.

    module-config: *<"module names">*
        Module configuration, a list of module names separated by spaces, surround
        the string with quotes (``""``). The modules can be respip, validator, or
        iterator (and possibly more, see below). Setting this to just "iterator"
        will result in a non-validating server. Setting this to "validator iterator"
        will turn on DNSSEC validation. The ordering of the modules is significant,
        the order decides the order of processing. You must also set trust-anchors
        for validation to be useful. Adding respip to the front will cause RPZ
        processing to be done on all queries. The default is "validator iterator".

        When the server is built with EDNS client subnet support the default is
        "subnetcache validator iterator". Most modules that need to be listed here
        have to be listed at the beginning of the line. The subnetcachedb module has
        to be listed just before the iterator. The python module can be listed in
        different places, it then processes the output of the module it is just
        before. The dynlib module can be listed pretty much anywhere, it is only a
        very thin wrapper that allows dynamic libraries to run in its place.

    trust-anchor-file: *<filename>*
        File with trusted keys for validation. Both DS and DNSKEY entries can appear
        in the file. The format of the file is the standard DNS Zone file format.
        Default is ``""``, or no trust anchor file.

    auto-trust-anchor-file: *<filename>*
        File with trust anchor for one zone, which is tracked with :RFC:`5011`
        probes. The probes are run several times per month, thus the machine must be
        online frequently. The initial file can be one with contents as described in
        **trust-anchor-file**. The file is written to when the anchor is updated, so
        the unbound user must have write permission. Write permission to the file,
        but also to the directory it is in (to create a temporary file, which is
        necessary to deal with filesystem full events), it must also be inside the
        chroot (if that is used).

    trust-anchor: *<"Resource Record">*
        A DS or DNSKEY RR for a key to use for validation. Multiple entries can be
        given to specify multiple trusted keys, in addition to the
        trust-anchor-files. The resource record is entered in the same format as
        'dig' or 'drill' prints them, the same format as in the zone file. Has to be
        on a single line, with ``""`` around it. A TTL can be specified for ease of
        cut and paste, but is ignored. A class can be specified, but class IN is
        default.

    trusted-keys-file: *<filename>*
        File with trusted keys for validation. Specify more than one file with
        several entries, one file per entry. Like **trust-anchor-file** but has a
        different file format. Format is BIND-9 style format, the trusted-keys {
        name flag proto algo "key"; }; clauses are read. It is possible to use
        wildcards with this statement, the wildcard is expanded on start and on
        reload.

    trust-anchor-signaling: *<yes or no>*
        Send :RFC:`8145` key tag query after trust anchor priming. Default is yes.

    root-key-sentinel: *<yes or no>*
        Root key trust anchor sentinel. Default is yes.

    domain-insecure: *<domain name>*
        Sets domain name to be insecure, DNSSEC chain of trust is ignored towards
        the domain name. So a trust anchor above the domain name can not make the
        domain secure with a DS record, such a DS record is then ignored. Can be
        given multiple times to specify multiple domains that are treated as if
        unsigned. If you set trust anchors for the domain they override this setting
        (and the domain is secured).

        This can be useful if you want to make sure a trust anchor for external
        lookups does not affect an (unsigned) internal domain. A DS record
        externally can create validation failures for that internal domain.

    val-override-date: *<rrsig-style date spec>*
        Default is ``""`` or "0", which disables this debugging feature. If enabled
        by giving a RRSIG style date, that date is used for verifying RRSIG
        inception and expiration dates, instead of the current date. Do not set this
        unless you are debugging signature inception and expiration. The value -1
        ignores the date altogether, useful for some special applications.

    val-sig-skew-min: *<seconds>*
        Minimum number of seconds of clock skew to apply to validated signatures. A
        value of 10% of the signature lifetime (expiration - inception) is used,
        capped by this setting. Default is 3600 (1 hour) which allows for daylight
        savings differences. Lower this value for more strict checking of short
        lived signatures.

    val-sig-skew-max: *<seconds>*
        Maximum number of seconds of clock skew to apply to validated signatures. A
        value of 10% of the signature lifetime (expiration - inception) is used,
        capped by this setting. Default is 86400 (24 hours) which allows for
        timezone setting problems in stable domains. Setting both min and max very
        low disables the clock skew allowances. Setting both min and max very high
        makes the validator check the signature timestamps less strictly.

    val-max-restart: *<number>*
        The maximum number the validator should restart validation with another
        authority in case of failed validation. Default is 5.

    val-bogus-ttl: *<number>*
        The time to live for bogus data. This is data that has failed validation;
        due to invalid signatures or other checks. The TTL from that data cannot be
        trusted, and this value is used instead. The value is in seconds, default
        1.  The time interval prevents repeated revalidation of bogus data.

    val-clean-additional: *<yes or no>*
        Instruct the validator to remove data from the additional section of secure
        messages that are not signed properly. Messages that are insecure, bogus,
        indeterminate or unchecked are not affected. Default is yes. Use this
        setting to protect the users that rely on this validator for authentication
        from potentially bad data in the additional section.

    val-log-level: *<number>*
        Have the validator print validation failures to the log. Regardless of the
        verbosity setting. Default is 0, off. At 1, for every user query that fails
        a line is printed to the logs. This way you can monitor what happens with
        validation. Use a diagnosis tool, such as dig or drill, to find out why
        validation is failing for these queries. At 2, not only the query that
        failed is printed but also the reason why unbound thought it was wrong and
        which server sent the faulty data.

    val-permissive-mode: *<yes or no>*
        Instruct the validator to mark bogus messages as indeterminate. The security
        checks are performed, but if the result is bogus (failed security), the
        reply is not withheld from the client with SERVFAIL as usual. The client
        receives the bogus data. For messages that are found to be secure the AD bit
        is set in replies. Also logging is performed as for full validation. The
        default value is "no".

    ignore-cd-flag: *<yes or no>*
        Instruct unbound to ignore the CD flag from clients and refuse to return
        bogus answers to them. Thus, the CD (Checking Disabled) flag does not
        disable checking any more. This is useful if legacy (w2008) servers that set
        the CD flag but cannot validate DNSSEC themselves are the clients, and then
        unbound provides them with DNSSEC protection. The default value is "no".

    serve-expired: *<yes or no>*
        If enabled, unbound attempts to serve old responses from cache with a TTL of
        **serve-expired-reply-ttl** in the response without waiting for the actual
        resolution to finish. The actual resolution answer ends up in the cache
        later on. Default is "no".

    serve-expired-ttl: *<seconds>*
        Limit serving of expired responses to configured seconds after expiration. 0
        disables the limit. This option only applies when **serve-expired** is
        enabled. A suggested value per RFC 8767 is between 86400 (1 day) and 259200
        (3 days). The default is 0.

    serve-expired-ttl-reset: *<yes or no>*
        Set the TTL of expired records to the **serve-expired-ttl** value after a
        failed attempt to retrieve the record from upstream. This makes sure that
        the expired records will be served as long as there are queries for it.
        Default is "no".

    serve-expired-reply-ttl: *<seconds>*
        TTL value to use when replying with expired data. If
        **serve-expired-client-timeout** is also used then it is RECOMMENDED to use
        30 as the value (:RFC:`8767`). The default is 30.

    serve-expired-client-timeout: *<msec>*
        Time in milliseconds before replying to the client with expired data. This
        essentially enables the serve-stale behavior as specified in RFC 8767 that
        first tries to resolve before immediately responding with expired data. A
        recommended value per :RFC:`8767` is 1800. Setting this to 0 will disable
        this behavior. Default is 0.

    serve-original-ttl: *<yes or no>*
        If enabled, unbound will always return the original TTL as received from the
        upstream name server rather than the decrementing TTL as stored in the
        cache. This feature may be useful if unbound serves as a front-end to a
        hidden authoritative name server. Enabling this feature does not impact
        cache expiry, it only changes the TTL unbound embeds in responses to
        queries. Note that enabling this feature implicitly disables enforcement of
        the configured minimum and maximum TTL, as it is assumed users who enable
        this feature do not want unbound to change the TTL obtained from an upstream
        server. Thus, the values set using **cache-min-ttl** and **cache-max-ttl**
        are ignored. Default is "no".

    val-nsec3-keysize-iterations: <"list of values">
        List of keysize and iteration count values, separated by spaces, surrounded
        by quotes. Default is "1024 150 2048 150 4096 150". This determines the
        maximum allowed NSEC3 iteration count before a message is simply marked
        insecure instead of performing the many hashing iterations. The list must be
        in ascending order and have at least one entry. If you set it to "1024
        65535" there is no restriction to NSEC3 iteration values. This table must be
        kept short; a very long list could cause slower operation.

    zonemd-permissive-mode: *<yes or no>*
        If enabled the ZONEMD verification failures are only logged and do not cause
        the zone to be blocked and only return servfail. Useful for testing out if
        it works, or if the operator only wants to be notified of a problem without
        disrupting service. Default is no.

    add-holddown: *<seconds>*
        Instruct the **auto-trust-anchor-file** probe mechanism for :RFC:`5011`
        autotrust updates to add new trust anchors only after they have been visible
        for this time. Default is 30 days as per the RFC.

    del-holddown: *<seconds>*
        Instruct the **auto-trust-anchor-file** probe mechanism for :RFC:`5011`
        autotrust updates to remove revoked trust anchors after they have been kept
        in the revoked list for this long. Default is 30 days as per the RFC.

    keep-missing: *<seconds>*
        Instruct the **auto-trust-anchor-file** probe mechanism for :RFC:`5011`
        autotrust updates to remove missing trust anchors after they have been
        unseen for this long. This cleans up the state file if the target zone does
        not perform trust anchor revocation, so this makes the auto probe mechanism
        work with zones that perform regular (non-5011) rollovers. The default is
        366 days. The value 0 does not remove missing anchors, as per the RFC.

    permit-small-holddown: *<yes or no>*
        Debug option that allows the autotrust 5011 rollover timers to assume very
        small values. Default is no.

    key-cache-size: *<number>*
        Number of bytes size of the key cache. Default is 4 megabytes. A plain
        number is in bytes, append 'k', 'm' or 'g' for kilobytes, megabytes or
        gigabytes (1024*1024 bytes in a megabyte).

    key-cache-slabs: *<number>*
        Number of slabs in the key cache. Slabs reduce lock contention by threads.
        Must be set to a power of 2. Setting (close) to the number of cpus is a
        reasonable guess.

    neg-cache-size: *<number>*
        Number of bytes size of the aggressive negative cache. Default is 1
        megabyte. A plain number is in bytes, append 'k', 'm' or 'g' for kilobytes,
        megabytes or gigabytes (1024*1024 bytes in a megabyte).

    unblock-lan-zones: *<yes or no>*
        Default is disabled. If enabled, then for private address space, the reverse
        lookups are no longer filtered. This allows unbound when running as dns
        service on a host where it provides service for that host, to put out all of
        the queries for the 'lan' upstream. When enabled, only localhost,
        ``127.0.0.1`` reverse and ``::1`` reverse zones are configured with default
        local zones. Disable the option when unbound is running as a (DHCP-) DNS
        network resolver for a group of machines, where such lookups should be
        filtered (RFC compliance), this also stops potential data leakage about the
        local network to the upstream DNS servers.

    insecure-lan-zones: *<yes or no>*
        Default is disabled. If enabled, then reverse lookups in private address
        space are not validated. This is usually required whenever unblock-lan-zones
        is used.

    local-zone: *<zone>  <type>*
        Configure a local zone. The type determines the answer to give if there is
        no match from local-data. The types are deny, refuse, static, transparent,
        redirect, nodefault, typetransparent, inform, inform_deny, inform_redirect,
        always_transparent, always_refuse, always_nxdomain, always_null, noview, and
        are explained below. After that the default settings are listed. Use
        local-data: to enter data into the local zone. Answers for local zones are
        authoritative DNS answers. By default the zones are class IN.

        If you need more complicated authoritative data, with referrals,
        wildcards, CNAME/DNAME support, or DNSSEC authoritative service,
        setup a stub-zone for it as detailed in the stub zone section
        below.

        deny 
            Do not send an answer, drop the query. If there is a match from local
            data, the query is answered.

        refuse
            Send an error message reply, with rcode REFUSED. If there is a match
            from local data, the query is answered.

        static
            If there is a match from local data, the query is answered. Otherwise,
            the query is answered with nodata or nxdomain. For a negative answer a
            SOA is included in the answer if present as local-data for the zone apex
            domain.

        transparent
            If there is a match from local data, the query is answered. Otherwise if
            the query has a different name, the query is resolved normally. If the
            query is for a name given in localdata but no such type of data is given
            in localdata, then a noerror nodata answer is returned. If no local-zone
            is given local-data causes a transparent zone to be created by default.

        typetransparent
            If there is a match from local data, the query is answered. If the query
            is for a different name, or for the same name but for a different type,
            the query is resolved normally. So, similar to transparent but types
            that are not listed in local data are resolved normally, so if an A
            record is in the local data that does not cause a nodata reply for AAAA
            queries.

        redirect
            The query is answered from the local data for the zone name. There may
            be no local data beneath the zone name. This answers queries for the
            zone, and all subdomains of the zone with the local data for the zone.
            It can be used to redirect a domain to return a different address record
            to the end user, with ``local-zone: "example.com."`` redirect and
            ``local-data: "example.com. A 127.0.0.1"`` queries for
            ``www.example.com`` and ``www.foo.example.com`` are redirected, so that
            users with web browsers cannot access sites with suffix example.com.

        inform
            The query is answered normally, same as transparent. The client IP
            address (@portnumber) is printed to the logfile. The log message is:

            .. code-block:: text

                timestamp, unbound-pid, info: zonename inform IP@port queryname type class. 
                
            This option can be used for normal resolution, but machines looking up
            infected names are logged, eg. to run antivirus on them.

        inform_deny
            The query is dropped, like 'deny', and logged, like 'inform'. Ie. find
            infected machines without answering the queries.

        inform_redirect
            The query is redirected, like 'redirect', and logged, like 'inform'. Ie.
            answer queries with fixed data and also log the machines that ask.

        always_transparent
            Like transparent, but ignores local data and resolves normally.

        always_refuse
            Like refuse, but ignores local data and refuses the query.

        always_nxdomain
            Like static, but ignores local data and returns nxdomain for the query.

        always_nodata
            Like static, but ignores local data and returns nodata for the query.

        always_deny
            Like deny, but ignores local data and drops the query.

        always_null
            Always returns ``0.0.0.0`` or ``::0`` for every name in the zone. Like
            redirect with zero data for A and AAAA. Ignores local data in the zone.
            Used for some block lists.

        noview
            Breaks out of that view and moves towards the global local zones for
            answer to the query. If the view first is no, it'll resolve normally. If
            view first is enabled, it'll break perform that step and check the
            global answers. For when the view has view specific overrides but some
            zone has to be answered from global local zone contents.

        nodefault
            Used to turn off default contents for AS112 zones. The other types also
            turn off default contents for the zone. The 'nodefault' option has no
            other effect than turning off default contents for the given zone. Use
            nodefault if you use exactly that zone, if you want to use a subzone,
            use transparent.

        The default zones are localhost, reverse ``127.0.0.1`` and ``::1``, the
        home.arpa, the onion, test, invalid and the AS112 zones. The AS112 zones are
        reverse DNS zones for private use and reserved IP addresses for which the
        servers on the internet cannot provide correct answers. They are configured by
        default to give nxdomain (no reverse information) answers. The defaults can be
        turned off by specifying your own local-zone of that name, or using the
        'nodefault' type. Below is a list of the default zone contents.

    localhost
        The IP4 and IP6 localhost information is given. NS and SOA
        records are provided for completeness and to satisfy some DNS
        update tools. Default content:
        local-zone: "localhost." redirect
        local-data: "localhost. 10800 IN NS localhost."
        local-data: "localhost. 10800 IN
        SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"
        local-data: "localhost. 10800 IN A 127.0.0.1"
        local-data: "localhost. 10800 IN AAAA ::1"

    reverse IPv4 loopback
        Default content:

        .. code-block:: text

            local-zone: "127.in-addr.arpa." static
            local-data: "127.in-addr.arpa. 10800 IN NS localhost."
            local-data: "127.in-addr.arpa. 10800 IN
            SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"
            local-data: "1.0.0.127.in-addr.arpa. 10800 IN
            PTR localhost."

    reverse IPv6 loopback
        Default content:

        .. code-block:: text

            local-zone: "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
            0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa." static
            local-data: "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
            0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa. 10800 IN
            NS localhost."
            local-data: "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
            0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa. 10800 IN
            SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"
            local-data: "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
            0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa. 10800 IN
            PTR localhost."

    home.arpa (:RFC:`8375`)
        Default content:

        .. code-block:: text

            local-zone: "home.arpa." static
            local-data: "home.arpa. 10800 IN NS localhost."
            local-data: "home.arpa. 10800 IN
            SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"

    onion (:RFC:`7686`)
        Default content:

        .. code-block:: text

            local-zone: "onion." static
            local-data: "onion. 10800 IN NS localhost."
            local-data: "onion. 10800 IN
            SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"

    test (:RFC:`6761`)
        Default content:

        .. code-block:: text

            local-zone: "test." static
            local-data: "test. 10800 IN NS localhost."
            local-data: "test. 10800 IN
            SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"

    invalid (:RFC:`6761`)
        Default content:

        .. code-block:: text

            local-zone: "invalid." static
            local-data: "invalid. 10800 IN NS localhost."
            local-data: "invalid. 10800 IN
            SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"

    reverse :RFC:`1918` local use zones
        Reverse data for zones ``10.in-addr.arpa``, ``16.172.in-addr.arpa`` to
        ``31.172.in-addr.arpa``, ``168.192.in-addr.arpa``. The **local-zone:**
        is set static and as **local-data:** SOA and NS records are provided.

    reverse :RFC:`3330` IP4 this, link-local, testnet and broadcast
        Reverse data for zones ``0.in-addr.arpa``, ``254.169.in-addr.arpa``,
        ``2.0.192.in-addr.arpa`` (TEST NET 1), ``100.51.198.in-addr.arpa`` (TEST
        NET 2), ``113.0.203.in-addr.arpa`` (TEST NET 3),
        ``255.255.255.255.in-addr.arpa``. And from ``64.100.in-addr.arpa`` to
        ``127.100.in-addr.arpa`` (Shared Address Space).

    reverse :RFC:`4291` IP6 unspecified
        Reverse data for zone
        ``0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
        0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa.``

    reverse :RFC:`4193` IPv6 Locally Assigned Local Addresses
        Reverse data for zone ``D.F.ip6.arpa``.

    reverse :RFC:`4291` IPv6 Link Local Addresses
        Reverse data for zones ``8.E.F.ip6.arpa`` to ``B.E.F.ip6.arpa``.

    reverse IPv6 Example Prefix
        Reverse data for zone ``8.B.D.0.1.0.0.2.ip6.arpa``. This zone is used
        for tutorials and examples. You can remove the block on this zone with:

        .. code-block:: text

            local-zone: 8.B.D.0.1.0.0.2.ip6.arpa. nodefault

        You can also selectively unblock a part of the zone by making that part
        transparent with a local-zone statement. This also works with the other
        default zones.

.. glossary::

    local-data: *'<resource record string>'*
        Configure local data, which is served in reply to queries for it. The query
        has to match exactly unless you configure the local-zone as redirect. If not
        matched exactly, the local-zone type determines further processing. If
        local-data is configured that is not a subdomain of a local-zone, a
        transparent local-zone is configured. For record types such as TXT, use
        single quotes, as in local-data: 'example. TXT "text"'.

        If you need more complicated authoritative data, with referrals, wildcards,
        CNAME/DNAME support, or DNSSEC authoritative service, setup a stub-zone for
        it as detailed in the stub zone section below.

    local-data-ptr: *"IPaddr name"*
        Configure local data shorthand for a PTR record with the reversed IPv4 or
        IPv6 address and the host name. For example ``"192.0.2.4 www.example.com"``.
        TTL can be inserted like this: ``"2001:DB8::4 7200 www.example.com"``

    local-zone-tag: *<zone> <"list of tags">*
        Assign tags to localzones. Tagged localzones will only be applied when the
        used access-control element has a matching tag. Tags must be defined in
        *define-tags*. Enclose list of tags in quotes (``""``) and put spaces
        between tags. When there are multiple tags it checks if the intersection of
        the list of tags for the query and local-zone-tag is non-empty.

    local-zone-override: *<zone> <IP netblock> <type>*
        Override the localzone type for queries from addresses matching netblock.
        Use this localzone type, regardless the type configured for the local-zone
        (both tagged and untagged) and regardless the type configured using
        access-control-tag-action.

    response-ip: *<IP-netblock> <action>*
        This requires use of the "respip" module.

        If the IP address in an AAAA or A RR in the answer section of a response
        matches the specified IP netblock, the specified action will apply.
        *<action>* has generally the same semantics as that for
        *access-control-tag-action*, but there are some exceptions.

        Actions for *response-ip* are different from those for *local-zone* in that
        in case of the former there is no point of such conditions as "the query
        matches it but there is no local data". Because of this difference, the
        semantics of *response-ip* actions are modified or simplified as follows:
        The *static*, *refuse*, *transparent*, *typetransparent*, and *nodefault*
        actions are invalid for *response-ip*. Using any of these will cause the
        configuration to be rejected as faulty. The *deny* action is
        non-conditional, i.e. it always results in dropping the corresponding query.
        The resolution result before applying the *deny* action is still cached and
        can be used for other queries.

    response-ip-data: *<IP-netblock> <"resource record string">*
        This requires use of the "respip" module.

        This specifies the action data for response-ip with action being to redirect
        as specified by *"resource record string"*. "Resource record string" is
        similar to that of *access-control-tag-action*, but it must be of either AAAA,
        A or CNAME types. If the IP-netblock is an IPv6/IPV4 prefix, the record must
        be AAAA/A respectively, unless it is a CNAME (which can be used for both
        versions of IP netblocks). If it is CNAME there must not be more than one
        *response-ip-data* for the same IP-netblock. Also, CNAME and other types of
        records must not coexist for the same IP-netblock, following the normal
        rules for CNAME records. The textual domain name for the CNAME does not have
        to be explicitly terminated with a dot (``"."``); the root name is assumed
        to be the origin for the name.

    response-ip-tag: *<IP-netblock> <"list of tags">*
        This requires use of the "respip" module.

        Assign tags to response IP-netblocks. If the IP address in an AAAA or A RR
        in the answer section of a response matches the specified IP-netblock, the
        specified tags are assigned to the IP address. Then, if an
        *access-control-tag* is defined for the client and it includes one of the
        tags for the response IP, the corresponding *access-control-tag-action* will
        apply. Tag matching rule is the same as that for *access-control-tag* and
        *local-zones*. Unlike *local-zone-tag*, *response-ip-tag* can be defined for
        an IP-netblock even if no *response-ip* is defined for that netblock. If
        multiple *response-ip-tag* options are specified for the same IPnetblock in
        different statements, all but the first will be ignored. However, this will
        not be flagged as a configuration error, but the result is probably not what
        was intended.

        Actions specified in an *access-control-tag-action* that has a matching tag
        with *response-ip-tag* can be those that are "invalid" for *response-ip*
        listed above, since *access-control-tag-actions* can be shared with local
        zones. For these actions, if they behave differently depending on whether
        local data exists or not in case of local zones, the behavior for
        *response-ip-data* will generally result in NOERROR/NODATA instead of
        NXDOMAIN, since the *response-ip* data are inherently type specific, and
        non-existence of data does not indicate anything about the existence or
        non-existence of the qname itself. For example, if the matching tag action
        is static but there is no data for the corresponding *response-ip*
        configuration, then the result will be NOERROR/NODATA. The only case where
        NXDOMAIN is returned is when an always_nxdomain action applies.

    ratelimit: *<number or 0>*
        Enable ratelimiting of queries sent to nameserver for performing recursion.
        If 0, the default, it is disabled. This option is experimental at this time.
        The ratelimit is in queries per second that are allowed. More queries are
        turned away with an error (servfail). This stops recursive floods, eg.
        random query names, but not spoofed reflection floods. Cached responses are
        not ratelimited by this setting. The zone of the query is determined by
        examining the nameservers for it, the zone name is used to keep track of the
        rate. For example, 1000 may be a suitable value to stop the server from
        being overloaded with random names, and keeps unbound from sending traffic
        to the nameservers for those zones.

    ratelimit-size: *<memory size>*
        Give the size of the data structure in which the current ongoing rates are
        kept track in. Default 4m. In bytes or use m(mega), k(kilo), g(giga). The
        ratelimit structure is small, so this data structure likely does not need to
        be large.

    ratelimit-slabs: *<number>*
        Give power of 2 number of slabs, this is used to reduce lock contention in
        the ratelimit tracking data structure. Close to the number of cpus is a
        fairly good setting.

    ratelimit-factor: *<number>*
        Set the amount of queries to rate limit when the limit is exceeded. If set
        to 0, all queries are dropped for domains where the limit is exceeded. If
        set to another value, 1 in that number is allowed through to complete.
        Default is 10, allowing 1/10 traffic to flow normally. This can make
        ordinary queries complete (if repeatedly queried for), and enter the cache,
        whilst also mitigating the traffic flow by the factor given.

    ratelimit-for-domain: *<domain> <number qps or 0>*
        Override the global ratelimit for an exact match domain name with the listed
        number. You can give this for any number of names. For example, for a
        top-level-domain you may want to have a higher limit than other names. A
        value of 0 will disable ratelimiting for that domain.

    ratelimit-below-domain: *<domain> <number qps or 0>*
        Override the global ratelimit for a domain name that ends in this name. You
        can give this multiple times, it then describes different settings in
        different parts of the namespace. The closest matching suffix is used to
        determine the qps limit. The rate for the exact matching domain name is not
        changed, use *ratelimit-for-domain* to set that, you might want to use
        different settings for a top-level-domain and subdomains. A value of 0 will
        disable ratelimiting for domain names that end in this name.

    ip-ratelimit: *<number or 0>*
        Enable global ratelimiting of queries accepted per ip address. If 0, the
        default, it is disabled. This option is experimental at this time. The
        ratelimit is in queries per second that are allowed. More queries are
        completely dropped and will not receive a reply, SERVFAIL or otherwise. IP
        ratelimiting happens before looking in the cache. This may be useful for
        mitigating amplification attacks.

    ip-ratelimit-size: *<memory size>*
        Give the size of the data structure in which the current ongoing rates are
        kept track in. Default 4m. In bytes or use m(mega), k(kilo), g(giga). The ip
        ratelimit structure is small, so this data structure likely does not need to
        be large.

    ip-ratelimit-slabs: *<number>*
        Give power of 2 number of slabs, this is used to reduce lock contention in
        the ip ratelimit tracking data structure. Close to the number of cpus is a
        fairly good setting.

    ip-ratelimit-factor: *<number>*
        Set the amount of queries to rate limit when the limit is exceeded. If set
        to 0, all queries are dropped for addresses where the limit is exceeded. If
        set to another value, 1 in that number is allowed through to complete.
        Default is 10, allowing 1/10 traffic to flow normally. This can make
        ordinary queries complete (if repeatedly queried for), and enter the cache,
        whilst also mitigating the traffic flow by the factor given.

    outbound-msg-retry: *<number>*
        The number of retries unbound will do in case of a non positive response is
        received. If a forward nameserver is used, this is the number of retries per
        forward nameserver in case of throwaway response.

    fast-server-permil: *<number>*
        Specify how many times out of 1000 to pick from the set of fastest servers.
        0 turns the feature off. A value of 900 would pick from the fastest servers
        90 percent of the time, and would perform normal exploration of random
        servers for the remaining time. When prefetch is enabled (or serve-expired),
        such prefetches are not sped up, because there is no one waiting for it, and
        it presents a good moment to perform server exploration. The fast-server-num
        option can be used to specify the size of the fastest servers set. The
        default for fast-server-permil is 0.

    fast-server-num: *<number>*
        Set the number of servers that should be used for fast server selection.
        Only use the fastest specified number of servers with the fast-server-permil
        option, that turns this on or off. The default is to use the fastest 3
        servers.

    edns-client-string: *<IP netblock> <string>*
        Include an EDNS0 option containing configured ascii string in queries with
        destination address matching the configured IP netblock. This configuration
        option can be used multiple times. The most specific match will be used.

    edns-client-string-opcode: *<opcode>*
        EDNS0 option code for the *edns-client-string* option, from 0 to 65535. A
        value from the 'Reserved for Local/Experimental' range (65001-65534) should
        be used. Default is 65001.

Remote Control Options
^^^^^^^^^^^^^^^^^^^^^^

In the **remote-control:** clause are the declarations for the remote control
facility. If this is enabled, the  :manpage:`unbound-control(8)` utility can be
used to send commands to the running unbound server. The server uses these
clauses to setup TLSv1 security for the connection. The
:manpage:`unbound-control(8)` utility also reads the **remote-control** section
for options. To setup the correct self-signed certificates use the
:manpage:`unbound-control-setup(8)` utility.

.. glossary::

    control-enable: *<yes or no>*
        The option is used to enable remote control, default is "no". If turned off,
        the server does not listen for control commands.

    control-interface: *<ip address or path>*
        Give IPv4 or IPv6 addresses or local socket path to listen on for control
        commands. By default localhost (``127.0.0.1`` and ``::1``) is listened to.
        Use ``0.0.0.0`` and ``::0`` to listen to all interfaces. If you change this
        and permissions have been dropped, you must restart the server for the
        change to take effect.

        If you set it to an absolute path, a local socket is used. The local socket
        does not use the certificates and keys, so those files need not be present.
        To restrict access, unbound sets permissions on the file to the user and
        group that is configured, the access bits are set to allow the group members
        to access the control socket file. Put users that need to access the socket
        in the that group. To restrict access further, create a directory to put the
        control socket in and restrict access to that directory.

    control-port: *<port number>*
        The port number to listen on for IPv4 or IPv6 control interfaces, default is
        1.    If you change this and permissions have been dropped, you must restart
        the server for the change to take effect.

    control-use-cert: *<yes or no>*
        For localhost control-interface you can disable the use of TLS by setting
        this option to "no", default is "yes". For local sockets, TLS is disabled
        and the value of this option is ignored.

    server-key-file: *<private key file>*
        Path to the server private key, by default :file:`unbound_server.key`. This
        file is generated by the *unbound-control-setup* utility. This file is used
        by the unbound server, but not by *unbound-control*.

    server-cert-file: *<certificate file.pem>*
        Path to the server self signed certificate, by default
        :file:`unbound_server.pem`. This file is generated by the
        *unbound-control-setup* utility. This file is used by the unbound server,
        and also by *unbound-control*.

    control-key-file: *<private key file>*
        Path to the control client private key, by default
        :file:`unbound_control.key`. This file is generated by the
        *unbound-control-setup* utility. This file is used by *unbound-control*.

    control-cert-file: *<certificate file.pem>*
        Path to the control client certificate, by default unbound_control.pem. This
        certificate has to be signed with the server certificate. This file is
        generated by the *unbound-control-setup* utility. This file is used by
        *unbound-control*.

Stub Zone Options
^^^^^^^^^^^^^^^^^

There may be multiple **stub-zone:** clauses. Each with a name: and zero or more
hostnames or IP addresses. For the stub zone this list of nameservers is used.
Class IN is assumed. The servers should be authority servers, not recursors;
unbound performs the recursive processing itself for stub zones.

The stub zone can be used to configure authoritative data to be used by the
resolver that cannot be accessed using the public internet servers. This is
useful for company-local data or private zones. Setup an authoritative server on
a different host (or different port). Enter a config entry for unbound with
**stub-addr:** <ip address of host[@port]>. The unbound resolver can then access
the data, without referring to the public internet for it.

This setup allows DNSSEC signed zones to be served by that authoritative server,
in which case a trusted key entry with the public key can be put in config, so
that unbound can validate the data and set the AD bit on replies for the private
zone (authoritative servers do not set the AD bit). This setup makes unbound
capable of answering queries for the private zone, and can even set the AD bit
('authentic'), but the AA ('authoritative') bit is not set on these replies.

Consider adding **server:** statements for **domain-insecure:** and for
local-zone: name nodefault for the zone if it is a locally served zone. The
insecure clause stops DNSSEC from invalidating the zone. The local zone
nodefault (or *transparent*) clause makes the (reverse-) zone bypass unbound's
filtering of :RFC:`1918` zones.

.. glossary::

    name: *<domainname>*
        Name of the stub zone. This is the full domain name of the zone.

    stub-host: *<domain name>*
        Name of stub zone nameserver. Is itself resolved before it is used.

    stub-addr: *<IP address>*
        IP address of stub zone nameserver. Can be IP 4 or IP 6. To use a nondefault
        port for DNS communication append ``'@'`` with the port number. If tls is
        enabled, then you can append a ``'#'`` and a name, then it'll check the tls
        authentication certificates with that name. If you combine the ``'@'`` and
        ``'#'``, the ``'@'`` comes first.

    stub-prime: *<yes or no>*
        This option is by default no. If enabled it performs NS set priming, which
        is similar to root hints, where it starts using the list of nameservers
        currently published by the zone. Thus, if the hint list is slightly
        outdated, the resolver picks up a correct list online.

    stub-first: *<yes or no>*
        If enabled, a query is attempted without the stub clause if it fails. The
        data could not be retrieved and would have caused SERVFAIL because the
        servers are unreachable, instead it is tried without this clause. The
        default is no.

    stub-tls-upstream: *<yes or no>*
        Enabled or disable whether the queries to this stub use TLS for transport.
        Default is no.

    stub-ssl-upstream: *<yes or no>*
        Alternate syntax for **stub-tls-upstream**.

    stub-tcp-upstream: *<yes or no>*
        If it is set to "yes" then upstream queries use TCP only for transport
        regardless of global flag tcp-upstream. Default is no.

    stub-no-cache: *<yes or no>*
        Default is no. If enabled, data inside the stub is not cached. This is
        useful when you want immediate changes to be visible.

Forward Zone Options
^^^^^^^^^^^^^^^^^^^^

There may be multiple **forward-zone:** clauses. Each with a **name:** and zero
or more hostnames or IP addresses. For the forward zone this list of nameservers
is used to forward the queries to. The servers listed as **forward-host:** and
**forward-addr:** have to handle further recursion for the query. Thus, those
servers are not authority servers, but are (just like unbound is) recursive
servers too; unbound does not perform recursion itself for the forward zone, it
lets the remote server do it. Class IN is assumed. CNAMEs are chased by unbound
itself, asking the remote server for every name in the indirection chain, to
protect the local cache from illegal indirect referenced items. A forward-zone
entry with name ``"."`` and a forward-addr target will forward all queries to
that other server (unless it can answer from the cache).

.. glossary::

    name: *<domain name>*
        Name of the forward zone. This is the full domain name of the zone.

    forward-host: *<domain name>*
        Name of server to forward to. Is itself resolved before it is used.

    forward-addr: *<IP address>*
        IP address of server to forward to. Can be IP 4 or IP 6. To use a nondefault
        port for DNS communication append ``'@'`` with the port number. If tls is
        enabled, then you can append a ``'#'`` and a name, then it'll check the tls
        authentication certificates with that name. If you combine the ``'@'`` and
        ``'#'``, the ``'@'`` comes first.

        At high verbosity it logs the TLS certificate, with TLS enabled. If you
        leave out the ``'#'`` and auth name from the forward-addr, any name is
        accepted. The cert must also match a CA from the tls-cert-bundle.

    forward-first: *<yes or no>*
        If a forwarded query is met with a SERVFAIL error, and this option is
        enabled, unbound will fall back to normal recursive resolution for this
        query as if no query forwarding had been specified. The default is "no".

    forward-tls-upstream: *<yes or no>*
        Enabled or disable whether the queries to this forwarder use TLS for
        transport. Default is no. If you enable this, also configure a
        tls-cert-bundle or use tls-win-cert to load CA certs, otherwise the
        connections cannot be authenticated.

    forward-ssl-upstream: *<yes or no>*
        Alternate syntax for **forward-tls-upstream**.

    forward-tcp-upstream: *<yes or no>*
        If it is set to "yes" then upstream queries use TCP only for transport
        regardless of global flag tcp-upstream. Default is no.

    forward-no-cache: *<yes or no>*
        Default is no. If enabled, data inside the forward is not cached. This is
        useful when you want immediate changes to be visible.

Authority Zone Options
^^^^^^^^^^^^^^^^^^^^^^

Authority zones are configured with **auth-zone:**, and each one must have a
**name:**. There can be multiple ones, by listing multiple auth-zone clauses,
each with a different name, pertaining to that part of the namespace. The
authority zone with the name closest to the name looked up is used. Authority
zones are processed after local-zones and before cache (**for-downstream:**
*yes*), and when used in this manner make unbound respond like an authority
server. Authority zones are also processed after cache, just before going to the
network to fetch information for recursion (**for-upstream:** *yes*), and when
used in this manner provide a local copy of an authority server that speeds up
lookups of that data.

Authority zones can be read from zonefile. And can be kept updated via AXFR and
IXFR. After update the zonefile is rewritten. The update mechanism uses the SOA
timer values and performs SOA UDP queries to detect zone changes.

If the update fetch fails, the timers in the SOA record are used to time another
fetch attempt. Until the SOA expiry timer is reached. Then the zone is expired.
When a zone is expired, queries are SERVFAIL, and any new serial number is
accepted from the primary (even if older), and if fallback is enabled, the
fallback activates to fetch from the upstream instead of the SERVFAIL.

name: *<zone name>*
    Name of the authority zone.

.. glossary::

    primary: *<IP address or host name>*
        Where to download a copy of the zone from, with AXFR and IXFR. Multiple
        primaries can be specified. They are all tried if one fails. To use a
        nondefault port for DNS communication append ``'@'`` with the port number.
        You can append a ``'#'`` and a name, then AXFR over TLS can be used and the
        tls authentication certificates will be checked with that name. If you
        combine the ``'@'`` and ``'#'``, the ``'@'`` comes first. If you point it at
        another Unbound instance, it would not work because that does not support
        AXFR/IXFR for the zone, but if you used **url:** to download the zonefile as
        a text file from a webserver that would work. If you specify the hostname,
        you cannot use the domain from the zonefile, because it may not have that
        when retrieving that data, instead use a plain IP address to avoid a
        circular dependency on retrieving that IP address.

    master: *<IP address or host name>*
        Alternate syntax for **primary**.

    url: *<url to zone file>*
        Where to download a zonefile for the zone. With http or https. An example
        for the url is ``"http://www.example.com/example.org.zone"``. Multiple url
        statements can be given, they are tried in turn. If only urls are given the
        SOA refresh timer is used to wait for making new downloads. If also
        primaries are listed, the primaries are first probed with UDP SOA queries to
        see if the SOA serial number has changed, reducing the number of downloads.
        If none of the urls work, the primaries are tried with IXFR and AXFR. For
        https, the **tls-cert-bundle** and the hostname from the url are used to
        authenticate the connection. If you specify a hostname in the URL, you
        cannot use the domain from the zonefile, because it may not have that when
        retrieving that data, instead use a plain IP address to avoid a circular
        dependency on retrieving that IP address. Avoid dependencies on name lookups
        by using a notation like
        ``"http://192.0.2.1/unboundprimaries/example.com.zone"``, with an explicit
        IP address.

    allow-notify: *<IP address or host name or netblockIP/prefix>*
        With allow-notify you can specify additional sources of notifies. When
        notified, the server attempts to first probe and then zone transfer. If the
        notify is from a primary, it first attempts that primary. Otherwise other
        primaries are attempted. If there are no primaries, but only urls, the file
        is downloaded when notified. The primaries from primary: statements are
        allowed notify by default.

    fallback-enabled: *<yes or no>*
        Default no. If enabled, unbound falls back to querying the internet as a
        resolver for this zone when lookups fail. For example for DNSSEC validation
        failures.

    for-downstream: *<yes or no>*
        Default yes. If enabled, unbound serves authority responses to downstream
        clients for this zone. This option makes unbound behave, for the queries
        with names in this zone, like one of the authority servers for that zone.
        Turn it off if you want unbound to provide recursion for the zone but have a
        local copy of zone data. If for-downstream is no and for-upstream is yes,
        then unbound will DNSSEC validate the contents of the zone before serving
        the zone contents to clients and store validation results in the cache.

    for-upstream: *<yes or no>*
        Default yes. If enabled, unbound fetches data from this data collection for
        answering recursion queries. Instead of sending queries over the internet to
        the authority servers for this zone, it'll fetch the data directly from the
        zone data. Turn it on when you want unbound to provide recursion for
        downstream clients, and use the zone data as a local copy to speed up
        lookups.

    zonemd-check: *<yes or no>*
        Enable this option to check ZONEMD records in the zone. Default is disabled.
        The ZONEMD record is a checksum over the zone data. This includes glue in
        the zone and data from the zone file, and excludes comments from the zone
        file. When there is a DNSSEC chain of trust, DNSSEC signatures are checked
        too.

    zonemd-reject-absence: *<yes or no>*
        Enable this option to reject the absence of the ZONEMD record. Without it,
        when zonemd is not there it is not checked. It is useful to enable for a
        nonDNSSEC signed zone where the operator wants to require the verification
        of a ZONEMD, hence a missing ZONEMD is a failure. The action upon failure is
        controlled by the **zonemd-permissive-mode** option, for log only or also
        block the zone. The default is no.

        Without the option absence of a ZONEMD is only a failure when the zone is
        DNSSEC signed, and we have a trust anchor, and the DNSSEC verification of
        the absence of the ZONEMD fails. With the option enabled, the absence of a
        ZONEMD is always a failure, also for nonDNSSEC signed zones.

    zonefile: *<file name>*
        The filename where the zone is stored. If not given then no zonefile is
        used. If the file does not exist or is empty, unbound will attempt to fetch
        zone data (eg. from the primary servers).

View Options
^^^^^^^^^^^^

There may be multiple **view:** clauses. Each with a **name:** and zero or more
**local-zone** and **local-data** elements. Views can also contain view-first,
response-ip, response-ip-data and local-data-ptr elements. View can be mapped to
requests by specifying the view name in an **access-control-view** element.
Options from matching views will override global options. Global options will be
used if no matching view is found, or when the matching view does not have the
option specified.

.. glossary::

    name: *<view name>*
        Name of the view. Must be unique. This name is used in access-control-view
        elements.

    local-zone: *<zone> <type>*
        View specific local-zone elements. Has the same types and behaviour as the
        global local-zone elements. When there is at least one local-zone specified
        and view-first is no, the default local-zones will be added to this view.
        Defaults can be disabled using the nodefault type. When view-first is yes or
        when a view does not have a local-zone, the global local-zone will be used
        including it's default zones.

    local-data: *"<resource record string>"*
        View specific local-data elements. Has the same behaviour as the global
        local-data elements.

    local-data-ptr: *"IP addr name"*
        View specific local-data-ptr elements. Has the same behaviour as the global
        local-data-ptr elements.

    view-first: *<yes or no>*
        If enabled, it attempts to use the global local-zone and local-data if there
        is no match in the view specific options. The default is no.

Python Module Options
^^^^^^^^^^^^^^^^^^^^^

The **python:** clause gives the settings for the *python(1)* script module.
This module acts like the iterator and validator modules do, on queries and
answers. To enable the script module it has to be compiled into the daemon, and
the word "python" has to be put in the **module-config:** option (usually first,
or between the validator and iterator). Multiple instances of the python module
are supported by adding the word "python" more than once.

If the **chroot:** option is enabled, you should make sure Python's library
directory structure is bind mounted in the new root environment, see mount(8).
Also the **python-script:** path should be specified as an absolute path
relative to the new root, or as a relative path to the working directory.

python-script: *<python file>*
    The script file to load. Repeat this option for every python module instance
    added to the **module-config:** option.

Dynamic Library Module Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The **dynlib:** clause gives the settings for the *dynlib* module. This module
is only a very small wrapper that allows dynamic modules to be loaded on runtime
instead of being compiled into the application. To enable the dynlib module it
has to be compiled into the daemon, and the word "dynlib" has to be put in the
**module-config:** option. Multiple instances of dynamic libraries are supported
by adding the word "dynlib" more than once.

The **dynlib-file:** path should be specified as an absolute path relative
to the new path set by chroot: option, or as a relative path to the
working directory.

.. glossary::

    dynlib-file: *<dynlib file>*
        The dynamic library file to load. Repeat this option for every dynlib module
        instance added to the **module-config:** option.

DNS64 Module Options
^^^^^^^^^^^^^^^^^^^^

The dns64 module must be configured in the **module-config:** "dns64 validator
iterator" directive and be compiled into the daemon to be enabled. These
settings go in the server: section.

.. glossary::

    dns64-prefix: *<IPv6 prefix>*
        This sets the DNS64 prefix to use to synthesize AAAA records with. It must
        be /96 or shorter. The default prefix is ``64:ff9b::/96``.

    dns64-synthall: *<yes or no>*
        Debug option, default no. If enabled, synthesize all AAAA records despite
        the presence of actual AAAA records.

    dns64-ignore-aaaa: *<name>*
        List domain for which the AAAA records are ignored and the A record is used
        by dns64 processing instead. Can be entered multiple times, list a new
        domain for which it applies, one per line. Applies also to names underneath
        the name given.

DNSCrypt Options
^^^^^^^^^^^^^^^^

The **dnscrypt:** clause gives the settings of the dnscrypt channel. While those
options are available, they are only meaningful if unbound was compiled with
``--enable-dnscrypt``. Currently certificate and secret/public keys cannot be
generated by unbound. You can use dnscrypt-wrapper to generate those:
https://github.com/cofyc/dnscrypt-wrapper/blob/master/README.md#usage

.. glossary::

    dnscrypt-enable: *<yes or no>*
        Whether or not the dnscrypt config should be enabled. You may define
        configuration but not activate it. The default is no.

    dnscrypt-port: *<port number>*
        On which port should dnscrypt should be activated. Note that you should have
        a matching interface option defined in the server section for this port.

    dnscrypt-provider: *<provider name>*
        The provider name to use to distribute certificates. This is of the form:
        ``2.dnscrypt-cert.example.com.``. The name *MUST* end with a dot.

    dnscrypt-secret-key: *<path to secret key file>*
        Path to the time limited secret key file. This option may be specified
        multiple times.

    dnscrypt-provider-cert: *<path to cert file>*
        Path to the certificate related to the **dnscrypt-secret-keys**. This option
        may be specified multiple times.

    dnscrypt-provider-cert-rotated: *<path to cert file>*
        Path to a certificate that we should be able to serve existing connection
        from but do not want to advertise over **dnscrypt-provider**'s TXT record
        certs distribution. A typical use case is when rotating certificates,
        existing clients may still use the client magic from the old cert in their
        queries until they fetch and update the new cert. Likewise, it would allow
        one to prime the new cert/key without distributing the new cert yet, this
        can be useful when using a network of servers using anycast and on which the
        configuration may not get updated at the exact same time. By priming the
        cert, the servers can handle both old and new certs traffic while
        distributing only one. This option may be specified multiple times.

    dnscrypt-shared-secret-cache-size: *<memory size>*
        Give the size of the data structure in which the shared secret keys are kept
        in. Default 4m. In bytes or use m(mega), k(kilo), g(giga). The shared secret
        cache is used when a same client is making multiple queries using the same
        public key. It saves a substantial amount of CPU.

    dnscrypt-shared-secret-cache-slabs: *<number>*
        Give power of 2 number of slabs, this is used to reduce lock contention in
        the dnscrypt shared secrets cache. Close to the number of cpus is a fairly
        good setting.

    dnscrypt-nonce-cache-size: *<memory size>*
        Give the size of the data structure in which the client nonces are kept in.
        Default 4m. In bytes or use m(mega), k(kilo), g(giga). The nonce cache is
        used to prevent dnscrypt message replaying. Client nonce should be unique
        for any pair of client pk/server sk.

    dnscrypt-nonce-cache-slabs: *<number>*
        Give power of 2 number of slabs, this is used to reduce lock contention in
        the dnscrypt nonce cache. Close to the number of cpus is a fairly good
        setting.

EDNS Client Subnet Module Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ECS module must be configured in the **module-config:** "subnetcache
validator iterator" directive and be compiled into the daemon to be enabled.
These settings go in the server: section.

If the destination address is allowed in the configuration Unbound will add the
EDNS0 option to the query containing the relevant part of the client's address.
When an answer contains the ECS option the response and the option are placed in
a specialized cache. If the authority indicated no support, the response is
stored in the regular cache.

Additionally, when a client includes the option in its queries, Unbound will
forward the option when sending the query to addresses that are explicitly
allowed in the configuration using send-client-subnet. The option will always be
forwarded, regardless the allowed addresses, if **client-subnet-always-forward**
is set to yes. In this case the lookup in the regular cache is skipped.

The maximum size of the ECS cache is controlled by 'msg-cache-size' in the
configuration file. On top of that, for each query only 100 different subnets
are allowed to be stored for each address family. Exceeding that number, older
entries will be purged from cache.

.. glossary::

    send-client-subnet: *<IP address>*
        Send client source address to this authority. Append /num to indicate a
        classless delegation netblock, for example like ``10.2.3.4/24`` or ``2001::11/64``.
        Can be given multiple times. Authorities not listed will not receive
        edns-subnet information, unless domain in query is specified in
        **client-subnet-zone**.

    client-subnet-zone: *<domain>*
        Send client source address in queries for this domain and its subdomains.
        Can be given multiple times. Zones not listed will not receive edns-subnet
        information, unless hosted by authority specified in **send-client-subnet**.

    client-subnet-always-forward: *<yes or no>*
        Specify whether the ECS address check (configured using
        **send-client-subnet**) is applied for all queries, even if the triggering
        query contains an ECS record, or only for queries for which the ECS record
        is generated using the querier address (and therefore did not contain ECS
        data in the client query). If enabled, the address check is skipped when the
        client query contains an ECS record. And the lookup in the regular cache is
        skipped. Default is no.

    max-client-subnet-ipv6: *<number>*
        Specifies the maximum prefix length of the client source address we are
        willing to expose to third parties for IPv6. Defaults to 56.

    max-client-subnet-ipv4: *<number>*
        Specifies the maximum prefix length of the client source address we are
        willing to expose to third parties for IPv4. Defaults to 24.

    min-client-subnet-ipv6: *<number>*
        Specifies the minimum prefix length of the IPv6 source mask we are willing
        to accept in queries. Shorter source masks result in REFUSED answers. Source
        mask of 0 is always accepted. Default is 0.

    min-client-subnet-ipv4: *<number>*
        Specifies the minimum prefix length of the IPv4 source mask we are willing
        to accept in queries. Shorter source masks result in REFUSED answers. Source
        mask of 0 is always accepted. Default is 0.

    max-ecs-tree-size-ipv4: *<number>*
        Specifies the maximum number of subnets ECS answers kept in the ECS radix
        tree. This number applies for each qname/qclass/qtype tuple. Defaults to
        100.

    max-ecs-tree-size-ipv6: *<number>*
        Specifies the maximum number of subnets ECS answers kept in the ECS radix
        tree. This number applies for each qname/qclass/qtype tuple. Defaults to
        100.

Opportunistic IPsec Support Module Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The IPsec module must be configured in the **module-config:** "ipsecmod
validator iterator" directive and be compiled into the daemon to be enabled.
These settings go in the **server:** section.

When unbound receives an A/AAAA query that is not in the cache and finds a valid
answer, it will withhold returning the answer and instead will generate an
IPSECKEY subquery for the same domain name. If an answer was found, unbound will
call an external hook passing the following arguments:

QNAME
    Domain name of the A/AAAA and IPSECKEY query. In string format.

IPSECKEY TTL
    TTL of the IPSECKEY RRset.

A/AAAA
    String of space separated IP addresses present in the A/AAAA RRset. The IP
    addresses are in string format.

IPSECKEY
    String of space separated IPSECKEY RDATA present in the IPSECKEY RRset. The
    IPSECKEY RDATA are in DNS presentation format.

The A/AAAA answer is then cached and returned to the client. If the external
hook was called the TTL changes to ensure it doesn't surpass
**ipsecmod-max-ttl**.

The same procedure is also followed when prefetch: is used, but the A/AAAA
answer is given to the client before the hook is called. **ipsecmod-max-ttl**
ensures that the A/AAAA answer given from cache is still relevant for
opportunistic IPsec.

.. glossary::

    ipsecmod-enabled: *<yes or no>*
        Specifies whether the IPsec module is enabled or not. The IPsec module still
        needs to be defined in the **module-config:** directive. This option
        facilitates turning on/off the module without restarting/reloading unbound.
        Defaults to yes.

    ipsecmod-hook: *<filename>*
        Specifies the external hook that unbound will call with *system(3)*. The
        file can be specified as an absolute/relative path. The file needs the
        proper permissions to be able to be executed by the same user that runs
        unbound. It must be present when the IPsec module is defined in the
        **module-config:** directive.

    ipsecmod-strict: *<yes or no>*
        If enabled unbound requires the external hook to return a success value of
        1. Failing to do so unbound will reply with SERVFAIL. The A/AAAA answer will
        also not be cached. Defaults to no.

    ipsecmod-max-ttl: *<seconds>*
        Time to live maximum for A/AAAA cached records after calling the external
        hook. Defaults to 3600.

    ipsecmod-ignore-bogus: *<yes or no>*
        Specifies the behaviour of unbound when the IPSECKEY answer is bogus. If set
        to yes, the hook will be called and the A/AAAA answer will be returned to
        the client. If set to no, the hook will not be called and the answer to the
        A/AAAA query will be SERVFAIL. Mainly used for testing. Defaults to no.

    ipsecmod-allow: *<domain>*
        Allow the ipsecmod functionality for the domain so that the module logic
        will be executed. Can be given multiple times, for different domains. If the
        option is not specified, all domains are treated as being allowed (default).

    ipsecmod-whitelist: *<yes or no>*
        Alternate syntax for **ipsecmod-allow**.

Cache DB Module Options
^^^^^^^^^^^^^^^^^^^^^^^

The Cache DB module must be configured in the **module-config:** "validator
cachedb iterator" directive and be compiled into the daemon with
``--enable-cachedb``. If this module is enabled and configured, the specified
backend database works as a second level cache: When Unbound cannot find an
answer to a query in its built-in in-memory cache, it consults the specified
backend. If it finds a valid answer in the backend, Unbound uses it to respond
to the query without performing iterative DNS resolution. If Unbound cannot even
find an answer in the backend, it resolves the query as usual, and stores the
answer in the backend.

This module interacts with the **serve-expired-\*** options and will reply with
expired data if unbound is configured for that. Currently the use of
**serve-expired-client-timeout:** and **serve-expired-reply-ttl:** is not
consistent for data originating from the external cache as these will result in
a reply with 0 TTL without trying to update the data first, ignoring the
configured values.

If Unbound was built with ``--with-libhiredis`` on a system that has installed
the hiredis C client library of Redis, then the "redis" backend can be used.
This backend communicates with the specified Redis server over a TCP connection
to store and retrieve cache data. It can be used as a persistent and/or shared
cache backend. It should be noted that Unbound never removes data stored in the
Redis server, even if some data have expired in terms of DNS TTL or the Redis
server has cached too much data; if necessary the Redis server must be
configured to limit the cache size, preferably with some kind of
least-recently-used eviction policy. Additionally, the **redis-expire-records**
option can be used in order to set the relative DNS TTL of the message as
timeout to the Redis records; keep in mind that some additional memory is used
per key and that the expire information is stored as absolute Unix timestamps in
Redis (computer time must be stable). This backend uses synchronous
communication with the Redis server based on the assumption that the
communication is stable and sufficiently fast. The thread waiting for a response
from the Redis server cannot handle other DNS queries. Although the backend has
the ability to reconnect to the server when the connection is closed
unexpectedly and there is a configurable timeout in case the server is overly
slow or hangs up, these cases are assumed to be very rare. If connection close
or timeout happens too often, Unbound will be effectively unusable with this
backend. It's the administrator's responsibility to make the assumption hold.

The **cachedb:** clause gives custom settings of the cache DB module.

.. glossary::

    backend: *<backend name>*
        Specify the backend database name. The default database is the in-memory
        backend named "testframe", which, as the name suggests, is not of any
        practical use. Depending on the build-time configuration, "redis" backend
        may also be used as described above.

    secret-seed: *<"secret string">*
        Specify a seed to calculate a hash value from query information. This value
        will be used as the key of the corresponding answer for the backend database
        and can be customized if the hash should not be predictable operationally.
        If the backend database is shared by multiple Unbound instances, all
        instances must use the same secret seed. This option defaults to "default".

The following **cachedb** options are specific to the redis backend.

.. glossary::

    redis-server-host: *<server address or name>*
        The IP (either v6 or v4) address or domain name of the Redis server. In
        general an IP address should be specified as otherwise Unbound will have to
        resolve the name of the server every time it establishes a connection to the
        server. This option defaults to ``"127.0.0.1"``.

    redis-server-port: *<port number>*
        The TCP port number of the Redis server. This option defaults
        to 6379.

    redis-timeout: *<msec>*
        The period until when Unbound waits for a response from the Redis sever. If
        this timeout expires Unbound closes the connection, treats it as if the
        Redis server does not have the requested data, and will try to re-establish
        a new connection later. This option defaults to 100 milliseconds.

    redis-expire-records: *<yes or no>*
        If Redis record expiration is enabled. If yes, unbound sets timeout for
        Redis records so that Redis can evict keys that have expired automatically.
        If unbound is configured with serve-expired and **serve-expired-ttl** is 0,
        this option is internally reverted to "no". Redis SETEX support is required
        for this option (Redis >= 2.0.0). This option defaults to no.

DNSTAP Logging Options
^^^^^^^^^^^^^^^^^^^^^^

DNSTAP support, when compiled in, is enabled in the **dnstap:** section. This
starts an extra thread (when compiled with threading) that writes the log
information to the destination. If unbound is compiled without threading it does
not spawn a thread, but connects per-process to the destination.

.. glossary::

    dnstap-enable: *<yes or no>*
        If dnstap is enabled. Default no. If yes, it connects to the dnstap server
        and if any of the dnstap-log-..-messages options is enabled it sends
        logs for those messages to the server.

    dnstap-bidirectional: *<yes or no>*
        Use frame streams in bidirectional mode to transfer DNSTAP messages. Default
        is yes.

    dnstap-socket-path: *<file name>*
        Sets the unix socket file name for connecting to the server that is
        listening on that socket. Default is ``""``.

    dnstap-ip: *<IPaddress[@port]>*
        If ``""``, the unix socket is used, if set with an IP address (IPv4 or IPv6)
        that address is used to connect to the server.

    dnstap-tls: *<yes or no>*
        Set this to use TLS to connect to the server specified in dnstap-ip. The
        default is yes. If set to no, TCP is used to connect to the server.

    dnstap-tls-server-name: *<name of TLS authentication>*
        The TLS server name to authenticate the server with. Used when dnstap-tls is
        enabled. If ``""`` it is ignored, default ``""``.

    dnstap-tls-cert-bundle: *<file name of cert bundle>*
        The pem file with certs to verify the TLS server certificate. If ``""`` the
        server default cert bundle is used, or the windows cert bundle on windows.
        Default is ``""``.

    dnstap-tls-client-key-file: *<file name>*
        The client key file for TLS client authentication. If ``""`` client
        authentication is not used. Default is ``""``.

    dnstap-tls-client-cert-file: *<file name>*
        The client cert file for TLS client authentication. Default is ``""``.

    dnstap-send-identity: *<yes or no>*
        If enabled, the server identity is included in the log messages. Default is
        no.

    dnstap-send-version: *<yes or no>*
        If enabled, the server version if included in the log messages. Default is
        no.

    dnstap-identity: *<string>*
        The identity to send with messages, if ``""`` the hostname is used. Default
        is ``""``.

    dnstap-version: *<string>*
        The version to send with messages, if ``""`` the package version is used.
        Default is ``""``.

    dnstap-log-resolver-query-messages: *<yes or no>*
        Enable to log resolver query messages. Default is no. These are messages
        from unbound to upstream servers.

    dnstap-log-resolver-response-messages: *<yes or no>*
        Enable to log resolver response messages. Default is no. These are replies
        from upstream servers to unbound.

    dnstap-log-client-query-messages: *<yes or no>*
        Enable to log client query messages. Default is no. These are client queries
        to unbound.

    dnstap-log-client-response-messages: *<yes or no>*
        Enable to log client response messages. Default is no. These are responses
        from unbound to clients.

    dnstap-log-forwarder-query-messages: *<yes or no>*
        Enable to log forwarder query messages. Default is no.

    dnstap-log-forwarder-response-messages: *<yes or no>*
        Enable to log forwarder response messages. Default is no.

Response Policy Zone Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Response Policy Zones are configured with **rpz:**, and each one must have a
**name:**. There can be multiple ones, by listing multiple rpz clauses, each
with a different name. RPZ clauses are applied in order of configuration. The
respip module needs to be added to the **module-config**, e.g.: ``module-config:
"respip validator iterator"``.

QNAME, Response IP Address, nsdname, nsip and clientip triggers are supported.
Supported actions are: NXDOMAIN, NODATA, PASSTHRU, DROP, Local Data, tcp-only
and drop. RPZ QNAME triggers are applied after **local-zones** and before
*auth-zones*.

The rpz zone is formatted with a SOA start record as usual. The items in the
zone are entries, that specify what to act on (the trigger) and what to do (the
action). The trigger to act on is recorded in the name, the action to do is
recorded as the resource record. The names all end in the zone name, so you
could type the trigger names without a trailing dot in the zonefile.

An example RPZ record, that answers ``example.com`` with ``NXDOMAIN example.com
CNAME .``

The triggers are encoded in the name on the left

.. code-block:: text

    name                          query name
    netblock.rpz-client-ip        client IP address
    netblock.rpz-ip               response IP address in the answer
    name.rpz-nsdname              nameserver name
    netblock.rpz-nsip             nameserver IP address
    
The netblock is written as ``<netblocklen>.<ip address in reverse>``. For IPv6
use ``'zz'`` for ``'::'``. Specify individual addresses with scope length of 32
or 128.  For example, ``24.10.100.51.198.rpz-ip`` is ``198.51.100.10/24`` and
``32.10.zz.db8.2001.rpz-ip`` is ``2001:db8:0:0:0:0:0:10/32``.

The actions are specified with the record on the right

.. code-block:: text

    CNAME .                      nxdomain reply
    CNAME *.                     nodata reply
    CNAME rpz-passthru.          do nothing, allow to continue
    CNAME rpz-drop.              the query is dropped
    CNAME rpz-tcp-only.          answer over TCP
    A 192.0.2.1                  answer with this IP address

Other records like AAAA, TXT and other CNAMEs (not rpz-..) can also be used to
answer queries with that content.

The RPZ zones can be configured in the config file with these settings in the
**rpz:** block.

.. glossary::

    name: *<zone name>*
        Name of the authority zone.

    primary: *<IP address or hostname>*
        Where to download a copy of the zone from, with AXFR and IXFR. Multiple
        primaries can be specified. They are all tried if one fails. To use a
        nondefault port for DNS communication append ``'@'`` with the port number.
        You can append a ``'#'`` and a name, then AXFR over TLS can be used and the
        tls authentication certificates will be checked with that name. If you
        combine the ``'@'`` and ``'#'``, the ``'@'`` comes first. If you point it at
        another Unbound instance, it would not work because that does not support
        AXFR/IXFR for the zone, but if you used **url:** to download the zonefile as
        a text file from a webserver that would work. If you specify the hostname,
        you cannot use the domain from the zonefile, because it may not have that
        when retrieving that data, instead use a plain IP address to avoid a
        circular dependency on retrieving that IP address.

    master: *<IP address or hostname>*
        Alternate syntax for **primary**.

    url: *<url to zonefile>*
        Where to download a zonefile for the zone. With http or https. An example
        for the url is ``"http://www.example.com/example.org.zone"``. Multiple url
        statements can be given, they are tried in turn. If only urls are given the
        SOA refresh timer is used to wait for making new downloads. If also
        primaries are listed, the primaries are first probed with UDP SOA queries to
        see if the SOA serial number has changed, reducing the number of downloads.
        If none of the urls work, the primaries are tried with IXFR and AXFR. For
        https, the **tls-cert-bundle** and the hostname from the url are used to
        authenticate the connection.

    allow-notify: *<IP address or host name or netblockIP / prefix>*
        With allow-notify you can specify additional sources of notifies. When
        notified, the server attempts to first probe and then zone transfer. If the
        notify is from a primary, it first attempts that primary. Otherwise other
        primaries are attempted. If there are no primaries, but only urls, the file
        is downloaded when notified. The primaries from primary: statements are
        allowed notify by default.

    zonefile: *<filename>*
        The filename where the zone is stored. If not given then no zonefile is
        used. If the file does not exist or is empty, unbound will attempt to fetch
        zone data (eg. from the primary servers).

    rpz-action-override: *<action>*
        Always use this RPZ action for matching triggers from this zone. Possible
        action are: nxdomain, nodata, passthru, drop, disabled and cname.

    rpz-cname-override: *<domain>*
        The CNAME target domain to use if the cname action is configured for
        **rpz-action-override**.

    rpz-log: *<yes or no>*
        Log all applied RPZ actions for this RPZ zone. Default is no.

    rpz-log-name: *<name>*
        Specify a string to be part of the log line, for easy referencing.

    tags: *<list of tags>*
        Limit the policies from this RPZ clause to clients with a matching tag. Tags
        need to be defined in **define-tag** and can be assigned to client addresses
        using **access-control-tag**. Enclose list of tags in quotes (``""``) and
        put spaces between tags. If no tags are specified the policies from this
        clause will be applied for all clients.

Memory Control Example
----------------------

In the example config settings below memory usage is reduced. Some service
levels are lower, notable very large data and a high TCP load are no longer
supported. Very large data and high TCP loads are exceptional for the DNS.
DNSSEC validation is enabled, just add trust anchors. If you do not have to
worry about programs using more than 3 Mb of memory, the below example is not
for you. Use the defaults to receive full service, which on BSD-32bit tops out
at 30-40 Mb after heavy usage.

.. code-block:: text

        # example settings that reduce memory usage
        server:
        num-threads: 1
        outgoing-num-tcp: 1 # this limits TCP service, uses less buffers.
        incoming-num-tcp: 1
        outgoing-range: 60  # uses less memory, but less performance.
        msg-buffer-size: 8192   # note this limits service, 'no huge stuff'.
        msg-cache-size: 100k
        msg-cache-slabs: 1
        rrset-cache-size: 100k
        rrset-cache-slabs: 1
        infra-cache-numhosts: 200
        infra-cache-slabs: 1
        key-cache-size: 100k
        key-cache-slabs: 1
        neg-cache-size: 10k
        num-queries-per-thread: 30
        target-fetch-policy: "2 1 0 0 0 0"
        harden-large-queries: "yes"
        harden-short-bufsize: "yes"

Files
-----

/usr/local/etc/unbound
    default unbound working directory.

/usr/local/etc/unbound
    default *chroot(2)* location.

/usr/local/etc/unbound/unbound.conf
    unbound configuration file.

/usr/local/etc/unbound/unbound.pid
    default unbound pidfile with process ID of the running daemon.

unbound.log
    unbound log file. default is to log to *syslog(3)*.

See Also
--------

:manpage:`unbound(8)`, :manpage:`unbound-checkconf(8)`.
