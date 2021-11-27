.. _doc_unbound_host_manpage:

unbound-host(1)
---------------

.. raw:: html

    <pre class="man">unbound-host(1)                 unbound 1.13.2                 unbound-host(1)



    <b>NAME</b>
       <b>unbound-host</b> - unbound DNS lookup utility

    <b>SYNOPSIS</b>
       <b>unbound-host</b>  [<b>-C</b>  <i>configfile</i>] [<b>-vdhr46D</b>] [<b>-c</b> <i>class</i>] [<b>-t</b> <i>type</i>] [<b>-y</b> <i>key</i>]
       [<b>-f</b> <i>keyfile</i>] [<b>-F</b> <i>namedkeyfile</i>] <i>hostname</i>

    <b>DESCRIPTION</b>
       <b>Unbound-host</b> uses the unbound validating  resolver  to  query  for  the
       hostname and display results. With the <b>-v</b> option it displays validation
       status: secure, insecure, bogus (security failure).

       By default it reads no configuration file whatsoever.  It  attempts  to
       reach  the  internet  root servers.  With <b>-C</b> an unbound config file and
       with <b>-r</b> resolv.conf can be read.

       The available options are:

       <i>hostname</i>
              This name is resolved (looked up in the DNS).  If a IPv4 or IPv6
              address is given, a reverse lookup is performed.

       <b>-h</b>     Show the version and commandline option help.

       <b>-v</b>     Enable  verbose output and it shows validation results, on every
              line.  Secure means that the NXDOMAIN (no such domain name), no-
              data  (no  such  data)  or positive data response validated cor-
              rectly with one of the keys.  Insecure means  that  that  domain
              name  has  no  security set up for it.  Bogus (security failure)
              means that the response failed one or more checks, it is  likely
              wrong, outdated, tampered with, or broken.

       <b>-d</b>     Enable  debug  output  to stderr. One -d shows what the resolver
              and validator are doing and may tell you what is going on.  More
              times,  -d -d, gives a lot of output, with every packet sent and
              received.

       <b>-c</b> <i>class</i>
              Specify the class to lookup for, the default is IN the  internet
              class.

       <b>-t</b> <i>type</i>
              Specify  the type of data to lookup. The default looks for IPv4,
              IPv6 and mail handler data, or domain name pointers for  reverse
              queries.

       <b>-y</b> <i>key</i> Specify  a  public  key to use as trust anchor. This is the base
              for a chain of trust that is built up from the trust  anchor  to
              the  response, in order to validate the response message. Can be
              given as a DS or DNSKEY record.  For example -y "example.com  DS
              31560 5 1 1CFED84787E6E19CCF9372C1187325972FE546CD".

       <b>-D</b>     Enables  DNSSEC  validation.  Reads the root anchor from the de-
              fault configured root anchor at the default  location,  <i>/usr/lo-</i>
              <i>cal/etc/unbound/root.key</i>.

       <b>-f</b> <i>keyfile</i>
              Reads keys from a file. Every line has a DS or DNSKEY record, in
              the format as for -y. The zone file format, the same as dig  and
              drill produce.

       <b>-F</b> <i>namedkeyfile</i>
              Reads   keys   from  a  BIND-style  named.conf  file.  Only  the
              trusted-key {}; entries are read.

       <b>-C</b> <i>configfile</i>
              Uses the specified unbound.conf to prime <a href="libunbound.html"><i>libunbound</i>(3)</a>.  Pass it
              as  first argument if you want to override some options from the
              config file with further arguments on the commandline.

       <b>-r</b>     Read /etc/resolv.conf, and use  the  forward  DNS  servers  from
              there  (those  could  have  been set by DHCP).  More info in <i>re-</i>
              <i>solv.conf</i>(5).  Breaks validation if those servers do not support
              DNSSEC.

       <b>-4</b>     Use solely the IPv4 network for sending packets.

       <b>-6</b>     Use solely the IPv6 network for sending packets.

    <b>EXAMPLES</b>
       Some  examples  of use. The keys shown below are fakes, thus a security
       failure is encountered.

       $ unbound-host www.example.com

       $    unbound-host    -v    -y    "example.com    DS    31560    5     1
       1CFED84787E6E19CCF9372C1187325972FE546CD" www.example.com

       $     unbound-host    -v    -y    "example.com    DS    31560    5    1
       1CFED84787E6E19CCF9372C1187325972FE546CD" 192.0.2.153

    <b>EXIT</b> <b>CODE</b>
       The unbound-host program exits with status code 1 on error, 0 on no er-
       ror.  The  data  may not be available on exit code 0, exit code 1 means
       the lookup encountered a fatal error.

    <b>SEE</b> <b>ALSO</b>
       <a href="unbound.conf.html"><i>unbound.conf</i>(5)</a>, <a href="unbound.html"><i>unbound</i>(8)</a>.



    NLnet Labs                       Aug 12, 2021                  unbound-host(1)
    </pre>