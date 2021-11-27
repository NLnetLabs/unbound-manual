.. _doc_unbound_conf_manpage:

unbound.conf(5)
---------------

.. raw:: html

    <pre class="man">unbound.conf(5)                 unbound 1.13.2                 unbound.conf(5)



    <b>NAME</b>
           <b>unbound.conf</b> - Unbound configuration file.

    <b>SYNOPSIS</b>
           <b>unbound.conf</b>

    <b>DESCRIPTION</b>
           <b>unbound.conf</b>  is used to configure <a href="/manpages/unbound/"><i>unbound</i>(8)</a>.  The file format has at-
           tributes and values. Some attributes have attributes inside them.   The
           notation is: attribute: value.

           Comments  start with # and last to the end of line. Empty lines are ig-
           nored as is whitespace at the beginning of a line.

           The utility <a href="/manpages/unbound-checkconf/"><i>unbound-checkconf</i>(8)</a> can  be  used  to  check  unbound.conf
           prior to usage.

    <b>EXAMPLE</b>
           An  example  config  file is shown below. Copy this to /etc/unbound/un-
           bound.conf and start the server with:

                $ unbound -c /etc/unbound/unbound.conf

           Most settings are the defaults. Stop the server with:

                $ kill `cat /etc/unbound/unbound.pid`

           Below is a minimal config file. The source distribution contains an ex-
           tensive example.conf file with all the options.

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

    <b>FILE</b> <b>FORMAT</b>
           There must be whitespace between keywords.  Attribute keywords end with
           a colon ':'.  An attribute is followed by a value,  or  its  containing
           attributes in which case it is referred to as a clause.  Clauses can be
           repeated throughout the file (or included files)  to  group  attributes
           under the same clause.

           Files  can be included using the <b>include:</b> directive. It can appear any-
           where, it accepts a single file name as argument.  Processing continues
           as  if  the text from the included file was copied into the config file
           at that point.  If also using chroot, using full path names for the in-
           cluded  files  works, relative pathnames for the included names work if
           the directory where the daemon is started equals its chroot/working di-
           rectory  or  is  specified before the include statement with directory:
           dir.  Wildcards can be used to include multiple files, see <i>glob</i>(7).

           For a more structural include option, the  <b>include-toplevel:</b>  directive
           can  be used.  This closes whatever clause is currently active (if any)
           and forces the use of clauses in the included  files  and  right  after
           this directive.

       <b>Server</b> <b>Options</b>
           These options are part of the <b>server:</b> clause.

           <a id="verbosity"><b>verbosity:</b></a> <i>&lt;number&gt;</i>
                  The  verbosity  number, level 0 means no verbosity, only errors.
                  Level 1 gives operational information.  Level 2  gives  detailed
                  operational  information  including short information per query.
                  Level 3 gives query level information, output per query.   Level
                  4  gives algorithm level information.  Level 5 logs client iden-
                  tification for cache misses.  Default is level 1.  The verbosity
                  can also be increased from the commandline, see <a href="/manpages/unbound/"><i>unbound</i>(8)</a>.

           <a id="statistics-interval"><b>statistics-interval:</b></a> <i>&lt;seconds&gt;</i>
                  The number of seconds between printing statistics to the log for
                  every thread.  Disable with value 0 or "". Default is  disabled.
                  The  histogram  statistics are only printed if replies were sent
                  during  the  statistics  interval,  requestlist  statistics  are
                  printed  for every interval (but can be 0).  This is because the
                  median calculation requires data to be present.

           <a id="statistics-cumulative"><b>statistics-cumulative:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, statistics are cumulative  since  starting  unbound,
                  without  clearing the statistics counters after logging the sta-
                  tistics. Default is no.

           <a id="extended-statistics"><b>extended-statistics:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, extended statistics are  printed  from  <i>unbound-con-</i>
                  <i>trol</i>(8).   Default is off, because keeping track of more statis-
                  tics takes time.  The counters are listed in <a href="/manpages/unbound-control/"><i>unbound-control</i>(8)</a>.

           <a id="num-threads"><b>num-threads:</b></a> <i>&lt;number&gt;</i>
                  The number of threads to create to serve clients. Use 1  for  no
                  threading.

           <a id="port"><b>port:</b></a> <i>&lt;port</i> <i>number&gt;</i>
                  The  port  number,  default  53, on which the server responds to
                  queries.

           <a id="interface"><b>interface:</b></a> <i>&lt;ip</i> <i>address[@port]&gt;</i>
                  Interface to use to connect to the network.  This  interface  is
                  listened to for queries from clients, and answers to clients are
                  given from it.  Can be given multiple times to work  on  several
                  interfaces. If none are given the default is to listen to local-
                  host.  If an interface name is used instead of  an  ip  address,
                  the list of ip addresses on that interface are used.  The inter-
                  faces are not changed on  a  reload  (kill  -HUP)  but  only  on
                  restart.   A  port  number  can be specified with @port (without
                  spaces between interface and port number), if not specified  the
                  default port (from <b>port</b>) is used.

           <a id="ip-address"><b>ip-address:</b></a> <i>&lt;ip</i> <i>address[@port]&gt;</i>
                  Same as interface: (for ease of compatibility with nsd.conf).

           <a id="interface-automatic"><b>interface-automatic:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Listen  on all addresses on all (current and future) interfaces,
                  detect the source interface on UDP  queries  and  copy  them  to
                  replies.   This  is  a  lot like ip-transparent, but this option
                  services all interfaces whilst with ip-transparent you  can  se-
                  lect  which  (future)  interfaces  unbound  provides service on.
                  This feature is experimental, and needs support in your  OS  for
                  particular socket options.  Default value is no.

           <a id="outgoing-interface"><b>outgoing-interface:</b></a> <i>&lt;ip</i> <i>address</i> <i>or</i> <i>ip6</i> <i>netblock&gt;</i>
                  Interface  to  use  to connect to the network. This interface is
                  used to send queries to authoritative servers and receive  their
                  replies.  Can  be given multiple times to work on several inter-
                  faces. If none are given the default  (all)  is  used.  You  can
                  specify  the  same  interfaces in <b>interface:</b> and <b>outgoing-inter-</b>
                  <b>face:</b> lines, the interfaces are then  used  for  both  purposes.
                  Outgoing  queries  are  sent  via a random outgoing interface to
                  counter spoofing.

                  If an IPv6 netblock is specified instead of an  individual  IPv6
                  address,  outgoing  UDP queries will use a randomised source ad-
                  dress taken from the netblock to counter spoofing. Requires  the
                  IPv6  netblock to be routed to the host running unbound, and re-
                  quires OS support for unprivileged  non-local  binds  (currently
                  only  supported  on  Linux).  Several netblocks may be specified
                  with multiple <b>outgoing-interface:</b> options, but  do  not  specify
                  both  an  individual  IPv6  address and an IPv6 netblock, or the
                  randomisation will be compromised.  Consider combining with <b>pre-</b>
                  <b>fer-ip6:</b>  <b>yes</b> to increase the likelihood of IPv6 nameservers be-
                  ing selected for queries.  On Linux you need these two  commands
                  to  be able to use the freebind socket option to receive traffic
                  for the ip6 netblock: ip -6 addr add mynetblock/64 dev lo &amp;&amp;  ip
                  -6 route add local mynetblock/64 dev lo

           <a id="outgoing-range"><b>outgoing-range:</b></a> <i>&lt;number&gt;</i>
                  Number  of ports to open. This number of file descriptors can be
                  opened per thread. Must be at least 1. Default depends  on  com-
                  pile options. Larger numbers need extra resources from the oper-
                  ating system.  For performance a very large value is  best,  use
                  libevent to make this possible.

           <a id="outgoing-port-permit"><b>outgoing-port-permit:</b></a> <i>&lt;port</i> <i>number</i> <i>or</i> <i>range&gt;</i>
                  Permit  unbound  to  open this port or range of ports for use to
                  send queries.  A larger number of permitted outgoing  ports  in-
                  creases  resilience  against  spoofing attempts. Make sure these
                  ports are not needed by other daemons.  By  default  only  ports
                  above 1024 that have not been assigned by IANA are used.  Give a
                  port number or a range of the form "low-high", without spaces.

                  The <b>outgoing-port-permit</b> and <b>outgoing-port-avoid</b> statements  are
                  processed  in the line order of the config file, adding the per-
                  mitted ports and subtracting the avoided ports from the  set  of
                  allowed  ports.   The  processing starts with the non IANA allo-
                  cated ports above 1024 in the set of allowed ports.

           <a id="outgoing-port-avoid"><b>outgoing-port-avoid:</b></a> <i>&lt;port</i> <i>number</i> <i>or</i> <i>range&gt;</i>
                  Do not permit unbound to open this port or range  of  ports  for
                  use to send queries. Use this to make sure unbound does not grab
                  a port that another daemon needs. The port  is  avoided  on  all
                  outgoing  interfaces,  both  IP4 and IP6.  By default only ports
                  above 1024 that have not been assigned by IANA are used.  Give a
                  port number or a range of the form "low-high", without spaces.

           <a id="outgoing-num-tcp"><b>outgoing-num-tcp:</b></a> <i>&lt;number&gt;</i>
                  Number  of  outgoing TCP buffers to allocate per thread. Default
                  is 10. If set to 0, or if do-tcp is "no", no TCP queries to  au-
                  thoritative servers are done.  For larger installations increas-
                  ing this value is a good idea.

           <a id="incoming-num-tcp"><b>incoming-num-tcp:</b></a> <i>&lt;number&gt;</i>
                  Number of incoming TCP buffers to allocate per  thread.  Default
                  is  10.  If  set to 0, or if do-tcp is "no", no TCP queries from
                  clients are accepted. For larger installations  increasing  this
                  value is a good idea.

           <a id="edns-buffer-size"><b>edns-buffer-size:</b></a> <i>&lt;number&gt;</i>
                  Number  of bytes size to advertise as the EDNS reassembly buffer
                  size.  This is the value put into  datagrams  over  UDP  towards
                  peers.   The actual buffer size is determined by msg-buffer-size
                  (both for TCP and UDP).  Do not set higher than that value.  De-
                  fault  is  1232  which  is the DNS Flag Day 2020 recommendation.
                  Setting to 512 bypasses even the most stringent path  MTU  prob-
                  lems,  but  is seen as extreme, since the amount of TCP fallback
                  generated is excessive (probably also for  this  resolver,  con-
                  sider tuning the outgoing tcp number).

           <a id="max-udp-size"><b>max-udp-size:</b></a> <i>&lt;number&gt;</i>
                  Maximum  UDP response size (not applied to TCP response).  65536
                  disables the udp response size maximum, and uses the choice from
                  the  client,  always.  Suggested values are 512 to 4096. Default
                  is 4096.

           <a id="stream-wait-size"><b>stream-wait-size:</b></a> <i>&lt;number&gt;</i>
                  Number of bytes size maximum to use for waiting stream  buffers.
                  Default is 4 megabytes.  A plain number is in bytes, append 'k',
                  'm' or 'g' for  kilobytes,  megabytes  or  gigabytes  (1024*1024
                  bytes  in a megabyte).  As TCP and TLS streams queue up multiple
                  results, the amount of memory used for these  buffers  does  not
                  exceed  this  number, otherwise the responses are dropped.  This
                  manages the total memory usage of the server (under heavy  use),
                  the  number  of requests that can be queued up per connection is
                  also limited, with further requests waiting in TCP buffers.

           <a id="msg-buffer-size"><b>msg-buffer-size:</b></a> <i>&lt;number&gt;</i>
                  Number of bytes size of the message buffers.  Default  is  65552
                  bytes,  enough  for 64 Kb packets, the maximum DNS message size.
                  No message larger than this can be sent or received. Can be  re-
                  duced  to  use less memory, but some requests for DNS data, such
                  as for huge resource records, will result in a SERVFAIL reply to
                  the client.

           <a id="msg-cache-size"><b>msg-cache-size:</b></a> <i>&lt;number&gt;</i>
                  Number  of  bytes  size  of  the  message  cache.  Default  is 4
                  megabytes.  A plain number is in bytes, append 'k', 'm'  or  'g'
                  for  kilobytes,  megabytes  or  gigabytes  (1024*1024 bytes in a
                  megabyte).

           <a id="msg-cache-slabs"><b>msg-cache-slabs:</b></a> <i>&lt;number&gt;</i>
                  Number of slabs in the message cache.  Slabs  reduce  lock  con-
                  tention  by  threads.   Must  be  set  to  a power of 2. Setting
                  (close) to the number of cpus is a reasonable guess.

           <a id="num-queries-per-thread"><b>num-queries-per-thread:</b></a> <i>&lt;number&gt;</i>
                  The number of queries that every thread will service  simultane-
                  ously.   If  more  queries  arrive  that  need servicing, and no
                  queries can  be  jostled  out  (see  <i>jostle-timeout</i>),  then  the
                  queries  are  dropped.  This forces the client to resend after a
                  timeout; allowing the  server  time  to  work  on  the  existing
                  queries. Default depends on compile options, 512 or 1024.

           <a id="jostle-timeout"><b>jostle-timeout:</b></a> <i>&lt;msec&gt;</i>
                  Timeout  used when the server is very busy.  Set to a value that
                  usually results in one roundtrip to the authority  servers.   If
                  too  many queries arrive, then 50% of the queries are allowed to
                  run to completion, and the other 50% are replaced with  the  new
                  incoming  query  if  they have already spent more than their al-
                  lowed time.  This protects against denial  of  service  by  slow
                  queries or high query rates.  Default 200 milliseconds.  The ef-
                  fect is that the qps for long-lasting  queries  is  about  (num-
                  queriesperthread  /  2)  /  (average time for such long queries)
                  qps.  The qps  for  short  queries  can  be  about  (numqueries-
                  perthread  /  2)  /  (jostletimeout  in  whole  seconds) qps per
                  thread, about (1024/2)*5 = 2560 qps by default.

           <a id="delay-close"><b>delay-close:</b></a> <i>&lt;msec&gt;</i>
                  Extra delay for timeouted UDP ports before they are  closed,  in
                  msec.   Default  is 0, and that disables it.  This prevents very
                  delayed answer packets from  the  upstream  (recursive)  servers
                  from  bouncing  against closed ports and setting off all sort of
                  close-port counters, with eg. 1500 msec.  When  timeouts  happen
                  you  need extra sockets, it checks the ID and remote IP of pack-
                  ets, and unwanted packets  are  added  to  the  unwanted  packet
                  counter.

           <a id="udp-connect"><b>udp-connect:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Perform connect for UDP sockets that mitigates ICMP side channel
                  leakage.  Default is yes.

           <a id="unknown-server-time-limit"><b>unknown-server-time-limit:</b></a> <i>&lt;msec&gt;</i>
                  The wait time in msec for waiting for an unknown server  to  re-
                  ply.   Increase this if you are behind a slow satellite link, to
                  eg. 1128.  That would then avoid re-querying every initial query
                  because it times out.  Default is 376 msec.

           <a id="so-rcvbuf"><b>so-rcvbuf:</b></a> <i>&lt;number&gt;</i>
                  If  not 0, then set the SO_RCVBUF socket option to get more buf-
                  fer space on UDP port 53 incoming queries.  So that short spikes
                  on  busy  servers  do  not  drop packets (see counter in netstat
                  -su).  Default is 0 (use system value).  Otherwise,  the  number
                  of  bytes to ask for, try "4m" on a busy server.  The OS caps it
                  at a maximum, on linux unbound needs root permission  to  bypass
                  the  limit,  or  the admin can use sysctl net.core.rmem_max.  On
                  BSD change kern.ipc.maxsockbuf in /etc/sysctl.conf.  On  OpenBSD
                  change header and recompile kernel. On Solaris ndd -set /dev/udp
                  udp_max_buf 8388608.

           <a id="so-sndbuf"><b>so-sndbuf:</b></a> <i>&lt;number&gt;</i>
                  If not 0, then set the SO_SNDBUF socket option to get more  buf-
                  fer  space  on UDP port 53 outgoing queries.  This for very busy
                  servers handles spikes in answer traffic, otherwise  'send:  re-
                  source temporarily unavailable' can get logged, the buffer over-
                  run is also visible by netstat -su.  Default is  0  (use  system
                  value).   Specify  the number of bytes to ask for, try "4m" on a
                  very busy server.  The OS caps it at a maximum, on linux unbound
                  needs  root permission to bypass the limit, or the admin can use
                  sysctl net.core.wmem_max.  On BSD, Solaris changes  are  similar
                  to so-rcvbuf.

           <a id="so-reuseport"><b>so-reuseport:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  yes,  then  open  dedicated  listening  sockets for incoming
                  queries for each thread and try to set the  SO_REUSEPORT  socket
                  option  on  each  socket.   May  distribute  incoming queries to
                  threads more evenly.  Default is yes.  On Linux it is  supported
                  in  kernels  &gt;= 3.9.  On other systems, FreeBSD, OSX it may also
                  work.  You can enable it (on any platform and kernel),  it  then
                  attempts to open the port and passes the option if it was avail-
                  able at compile time, if that works it is used, if it fails,  it
                  continues  silently (unless verbosity 3) without the option.  At
                  extreme load it could be better to turn it off to distribute the
                  queries evenly, reported for Linux systems (4.4.x).

           <a id="ip-transparent"><b>ip-transparent:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  yes,  then use IP_TRANSPARENT socket option on sockets where
                  unbound is listening for incoming traffic.  Default no.   Allows
                  you  to bind to non-local interfaces.  For example for non-exis-
                  tent IP addresses that are going to exist later  on,  with  host
                  failover configuration.  This is a lot like interface-automatic,
                  but that one services all interfaces and with  this  option  you
                  can  select  which  (future) interfaces unbound provides service
                  on.  This option needs unbound to be started with  root  permis-
                  sions  on  some  systems.  The option uses IP_BINDANY on FreeBSD
                  systems and SO_BINDANY on OpenBSD systems.

           <a id="ip-freebind"><b>ip-freebind:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If yes, then use IP_FREEBIND socket option on sockets where  un-
                  bound is listening to incoming traffic.  Default no.  Allows you
                  to bind to IP addresses that are nonlocal or do not exist,  like
                  when  the  network interface or IP address is down.  Exists only
                  on Linux, where the similar ip-transparent option is also avail-
                  able.

           <a id="ip-dscp"><b>ip-dscp:</b></a> <i>&lt;number&gt;</i>
                  The value of the Differentiated Services Codepoint (DSCP) in the
                  differentiated services field (DS) of  the  outgoing  IP  packet
                  headers.   The  field replaces the outdated IPv4 Type-Of-Service
                  field and the IPV6 traffic class field.

           <a id="rrset-cache-size"><b>rrset-cache-size:</b></a> <i>&lt;number&gt;</i>
                  Number of bytes size of the RRset cache. Default is 4 megabytes.
                  A  plain  number  is  in bytes, append 'k', 'm' or 'g' for kilo-
                  bytes, megabytes or gigabytes (1024*1024 bytes in a megabyte).

           <a id="rrset-cache-slabs"><b>rrset-cache-slabs:</b></a> <i>&lt;number&gt;</i>
                  Number of slabs in the RRset cache. Slabs reduce lock contention
                  by threads.  Must be set to a power of 2.

           <a id="cache-max-ttl"><b>cache-max-ttl:</b></a> <i>&lt;seconds&gt;</i>
                  Time  to  live maximum for RRsets and messages in the cache. De-
                  fault is 86400 seconds (1 day).  When the TTL expires, the cache
                  item  has  expired.   Can  be set lower to force the resolver to
                  query for data often, and not trust  (very  large)  TTL  values.
                  Downstream clients also see the lower TTL.

           <a id="cache-min-ttl"><b>cache-min-ttl:</b></a> <i>&lt;seconds&gt;</i>
                  Time  to  live minimum for RRsets and messages in the cache. De-
                  fault is 0.  If the minimum kicks in, the  data  is  cached  for
                  longer than the domain owner intended, and thus less queries are
                  made to look up the data.  Zero makes sure the data in the cache
                  is  as the domain owner intended, higher values, especially more
                  than an hour or so, can lead to trouble as the data in the cache
                  does not match up with the actual data any more.

           <a id="cache-max-negative-ttl"><b>cache-max-negative-ttl:</b></a> <i>&lt;seconds&gt;</i>
                  Time to live maximum for negative responses, these have a SOA in
                  the authority section that is limited in time.  Default is 3600.
                  This applies to nxdomain and nodata answers.

           <a id="infra-host-ttl"><b>infra-host-ttl:</b></a> <i>&lt;seconds&gt;</i>
                  Time  to live for entries in the host cache. The host cache con-
                  tains roundtrip timing, lameness and EDNS  support  information.
                  Default is 900.

           <a id="infra-cache-slabs"><b>infra-cache-slabs:</b></a> <i>&lt;number&gt;</i>
                  Number  of  slabs in the infrastructure cache. Slabs reduce lock
                  contention by threads. Must be set to a power of 2.

           <a id="infra-cache-numhosts"><b>infra-cache-numhosts:</b></a> <i>&lt;number&gt;</i>
                  Number of hosts for which  information  is  cached.  Default  is
                  10000.

           <a id="infra-cache-min-rtt"><b>infra-cache-min-rtt:</b></a> <i>&lt;msec&gt;</i>
                  Lower limit for dynamic retransmit timeout calculation in infra-
                  structure cache. Default is 50 milliseconds. Increase this value
                  if using forwarders needing more time to do recursive name reso-
                  lution.

           <a id="infra-keep-probing"><b>infra-keep-probing:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled the server keeps probing hosts that are down, in  the
                  one  probe  at  a  time  regime.  Default is no.  Hosts that are
                  down, eg. they did not respond during the one probe  at  a  time
                  period,  are  marked as down and it may take <b>infra-host-ttl</b> time
                  to get probed again.

           <a id="define-tag"><b>define-tag:</b></a> <i>&lt;"list</i> <i>of</i> <i>tags"&gt;</i>
                  Define the tags that can be used with local-zone and access-con-
                  trol.   Enclose  the list between quotes ("") and put spaces be-
                  tween tags.

           <a id="do-ip4"><b>do-ip4:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable or disable whether ip4 queries are  answered  or  issued.
                  Default is yes.

           <a id="do-ip6"><b>do-ip6:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable  or  disable  whether ip6 queries are answered or issued.
                  Default is yes.  If disabled, queries are not answered on  IPv6,
                  and  queries  are  not sent on IPv6 to the internet nameservers.
                  With this option you can disable the ipv6 transport for  sending
                  DNS traffic, it does not impact the contents of the DNS traffic,
                  which may have ip4 and ip6 addresses in it.

           <a id="prefer-ip4"><b>prefer-ip4:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, prefer IPv4 transport for sending DNS queries to in-
                  ternet  nameservers. Default is no.  Useful if the IPv6 netblock
                  the server has, the entire /64 of that is not owned by one oper-
                  ator  and  the reputation of the netblock /64 is an issue, using
                  IPv4 then uses the IPv4 filters that the upstream servers have.

           <a id="prefer-ip6"><b>prefer-ip6:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, prefer IPv6 transport for sending DNS queries to in-
                  ternet nameservers. Default is no.

           <a id="do-udp"><b>do-udp:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable  or  disable  whether UDP queries are answered or issued.
                  Default is yes.

           <a id="do-tcp"><b>do-tcp:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable or disable whether TCP queries are  answered  or  issued.
                  Default is yes.

           <a id="tcp-mss"><b>tcp-mss:</b></a> <i>&lt;number&gt;</i>
                  Maximum segment size (MSS) of TCP socket on which the server re-
                  sponds to queries. Value lower than common MSS on Ethernet (1220
                  for  example)  will address path MTU problem.  Note that not all
                  platform supports socket option to set  MSS  (TCP_MAXSEG).   De-
                  fault  is system default MSS determined by interface MTU and ne-
                  gotiation between server and client.

           <a id="outgoing-tcp-mss"><b>outgoing-tcp-mss:</b></a> <i>&lt;number&gt;</i>
                  Maximum segment size (MSS) of TCP socket  for  outgoing  queries
                  (from  Unbound to other servers). Value lower than common MSS on
                  Ethernet (1220 for example) will address path MTU problem.  Note
                  that  not  all  platform  supports  socket  option  to  set  MSS
                  (TCP_MAXSEG).  Default is system default MSS determined  by  in-
                  terface MTU and negotiation between Unbound and other servers.

           <a id="tcp-idle-timeout"><b>tcp-idle-timeout:</b></a> <i>&lt;msec&gt;</i>
                  The  period  Unbound  will wait for a query on a TCP connection.
                  If this timeout expires Unbound closes the connection.  This op-
                  tion  defaults  to  30000 milliseconds.  When the number of free
                  incoming TCP buffers falls below 50% of the total number config-
                  ured,  the  option value used is progressively reduced, first to
                  1% of the configured value, then to 0.2% of the configured value
                  if  the number of free buffers falls below 35% of the total num-
                  ber configured, and finally to 0 if the number of  free  buffers
                  falls  below 20% of the total number configured. A minimum time-
                  out of 200 milliseconds is observed  regardless  of  the  option
                  value used.

           <a id="tcp-reuse-timeout"><b>tcp-reuse-timeout:</b></a> <i>&lt;msec&gt;</i>
                  The  period Unbound will keep TCP persistent connections open to
                  authority servers. This option defaults to 60000 milliseconds.

           <a id="max-reuse-tcp-queries"><b>max-reuse-tcp-queries:</b></a> <i>&lt;number&gt;</i>
                  The maximum number of queries that can be sent on  a  persistent
                  TCP connection.  This option defaults to 200 queries.

           <a id="tcp-auth-query-timeout"><b>tcp-auth-query-timeout:</b></a> <i>&lt;number&gt;</i>
                  Timeout  in  milliseconds for TCP queries to auth servers.  This
                  option defaults to 3000 milliseconds.

           <a id="edns-tcp-keepalive"><b>edns-tcp-keepalive:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable or disable EDNS TCP Keepalive. Default is no.

           <a id="edns-tcp-keepalive-timeout"><b>edns-tcp-keepalive-timeout:</b></a> <i>&lt;msec&gt;</i>
                  The period Unbound will wait for a query  on  a  TCP  connection
                  when  EDNS  TCP Keepalive is active. If this timeout expires Un-
                  bound closes the connection. If the client supports the EDNS TCP
                  Keepalive  option, Unbound sends the timeout value to the client
                  to encourage it to close the connection before the server  times
                  out.   This  option  defaults  to 120000 milliseconds.  When the
                  number of free incoming TCP buffers falls below 50% of the total
                  number  configured,  the advertised timeout is progressively re-
                  duced to 1% of the configured value, then to 0.2% of the config-
                  ured  value if the number of free buffers falls below 35% of the
                  total number configured, and finally to 0 if the number of  free
                  buffers falls below 20% of the total number configured.  A mini-
                  mum actual timeout of 200 milliseconds is observed regardless of
                  the advertised timeout.

           <a id="tcp-upstream"><b>tcp-upstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable  or disable whether the upstream queries use TCP only for
                  transport.  Default is no.  Useful in tunneling scenarios.

           <a id="udp-upstream-without-downstream"><b>udp-upstream-without-downstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable udp upstream even if do-udp is no.  Default  is  no,  and
                  this   does   not  change  anything.   Useful  for  TLS  service
                  providers, that want no udp downstream but use udp to fetch data
                  upstream.

           <a id="tls-upstream"><b>tls-upstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enabled or disable whether the upstream queries use TLS only for
                  transport.  Default is no.  Useful in tunneling scenarios.   The
                  TLS contains plain DNS in TCP wireformat.  The other server must
                  support this (see <b>tls-service-key</b>).  If you  enable  this,  also
                  configure  a  tls-cert-bundle  or  use  tls-win-cert  to load CA
                  certs, otherwise the connections cannot be authenticated.   This
                  option  enables  TLS for all of them, but if you do not set this
                  you can configure TLS specifically for some forward  zones  with
                  forward-tls-upstream.  And also with stub-tls-upstream.

           <a id="ssl-upstream"><b>ssl-upstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Alternate  syntax  for <b>tls-upstream</b>.  If both are present in the
                  config file the last is used.

           <a id="tls-service-key"><b>tls-service-key:</b></a> <i>&lt;file&gt;</i>
                  If enabled, the server provides DNS-over-TLS  or  DNS-over-HTTPS
                  service  on  the  TCP  ports marked implicitly or explicitly for
                  these services with tls-port or https-port. The file  must  con-
                  tain the private key for the TLS session, the public certificate
                  is in the tls-service-pem file and it must also be specified  if
                  tls-service-key  is  specified.   The default is "", turned off.
                  Enabling or disabling this service requires a restart (a  reload
                  is  not  enough), because the key is read while root permissions
                  are held and before chroot (if any).  The ports enabled  implic-
                  itly  or explicitly via <b>tls-port:</b> and <b>https-port:</b> do not provide
                  normal DNS TCP service. Unbound needs to be compiled  with  lib-
                  nghttp2 in order to provide DNS-over-HTTPS.

           <a id="ssl-service-key"><b>ssl-service-key:</b></a> <i>&lt;file&gt;</i>
                  Alternate syntax for <b>tls-service-key</b>.

           <a id="tls-service-pem"><b>tls-service-pem:</b></a> <i>&lt;file&gt;</i>
                  The  public  key  certificate pem file for the tls service.  De-
                  fault is "", turned off.

           <a id="ssl-service-pem"><b>ssl-service-pem:</b></a> <i>&lt;file&gt;</i>
                  Alternate syntax for <b>tls-service-pem</b>.

           <a id="tls-port"><b>tls-port:</b></a> <i>&lt;number&gt;</i>
                  The port number on which to provide  TCP  TLS  service,  default
                  853, only interfaces configured with that port number as @number
                  get the TLS service.

           <a id="ssl-port"><b>ssl-port:</b></a> <i>&lt;number&gt;</i>
                  Alternate syntax for <b>tls-port</b>.

           <a id="tls-cert-bundle"><b>tls-cert-bundle:</b></a> <i>&lt;file&gt;</i>
                  If null or "", no file is used.  Set it to the certificate  bun-
                  dle file, for example "/etc/pki/tls/certs/ca-bundle.crt".  These
                  certificates are used for  authenticating  connections  made  to
                  outside  peers.   For  example auth-zone urls, and also DNS over
                  TLS connections.  It is read at start up before permission  drop
                  and chroot.

           <a id="ssl-cert-bundle"><b>ssl-cert-bundle:</b></a> <i>&lt;file&gt;</i>
                  Alternate syntax for <b>tls-cert-bundle</b>.

           <a id="tls-win-cert"><b>tls-win-cert:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Add  the system certificates to the cert bundle certificates for
                  authentication.  If no cert bundle, it uses only these  certifi-
                  cates.  Default is no.  On windows this option uses the certifi-
                  cates from the cert store.  Use the  tls-cert-bundle  option  on
                  other systems.

           <a id="tls-additional-port"><b>tls-additional-port:</b></a> <i>&lt;portnr&gt;</i>
                  List portnumbers as tls-additional-port, and when interfaces are
                  defined, eg. with the @port suffix, as this  port  number,  they
                  provide  dns over TLS service.  Can list multiple, each on a new
                  statement.

           <a id="tls-session-ticket-keys"><b>tls-session-ticket-keys:</b></a> <i>&lt;file&gt;</i>
                  If not "", lists files with 80 bytes of random contents that are
                  used to perform TLS session resumption for clients using the un-
                  bound server.  These files contain the secret key  for  the  TLS
                  session  tickets.  First key use to encrypt and decrypt TLS ses-
                  sion tickets.  Other keys use to decrypt only.   With  this  you
                  can  roll  over  to new keys, by generating a new first file and
                  allowing decrypt of the old file by listing it after  the  first
                  file for some time, after the wait clients are not using the old
                  key any more and the old key can be removed.  One way to  create
                  the  file  is  dd if=/dev/random bs=1 count=80 of=ticket.dat The
                  first 16 bytes should be different from the old one if you  cre-
                  ate  a  second  key,  that is the name used to identify the key.
                  Then there is 32 bytes random data for an AES key  and  then  32
                  bytes random data for the HMAC key.

           <a id="tls-ciphers"><b>tls-ciphers:</b></a> <i>&lt;string</i> <i>with</i> <i>cipher</i> <i>list&gt;</i>
                  Set  the  list of ciphers to allow when serving TLS.  Use "" for
                  defaults, and that is the default.

           <a id="tls-ciphersuites"><b>tls-ciphersuites:</b></a> <i>&lt;string</i> <i>with</i> <i>ciphersuites</i> <i>list&gt;</i>
                  Set the list of ciphersuites to allow when serving TLS.  This is
                  for newer TLS 1.3 connections.  Use "" for defaults, and that is
                  the default.

           <a id="pad-responses"><b>pad-responses:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, TLS serviced queries that contained an EDNS  Padding
                  option  will  cause  responses padded to the closest multiple of
                  the size specified in <b>pad-responses-block-size</b>.  Default is yes.

           <a id="pad-responses-block-size"><b>pad-responses-block-size:</b></a> <i>&lt;number&gt;</i>
                  The block size with which to pad responses  serviced  over  TLS.
                  Only  responses  to  padded  queries will be padded.  Default is
                  468.

           <a id="pad-queries"><b>pad-queries:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, all queries sent over TLS upstreams will  be  padded
                  to   the   closest   multiple   of   the   size   specified   in
                  <b>pad-queries-block-size</b>.  Default is yes.

           <a id="pad-queries-block-size"><b>pad-queries-block-size:</b></a> <i>&lt;number&gt;</i>
                  The block size with which to  pad  queries  sent  over  TLS  up-
                  streams.  Default is 128.

           <a id="tls-use-sni"><b>tls-use-sni:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable  or disable sending the SNI extension on TLS connections.
                  Default is yes.  Changing the value requires a reload.

           <a id="https-port"><b>https-port:</b></a> <i>&lt;number&gt;</i>
                  The port number on which to provide DNS-over-HTTPS service,  de-
                  fault  443,  only interfaces configured with that port number as
                  @number get the HTTPS service.

           <a id="http-endpoint"><b>http-endpoint:</b></a> <i>&lt;endpoint</i> <i>string&gt;</i>
                  The HTTP endpoint to provide DNS-over-HTTPS service on.  Default
                  "/dns-query".

           <a id="http-max-streams"><b>http-max-streams:</b></a> <i>&lt;number</i> <i>of</i> <i>streams&gt;</i>
                  Number  used in the SETTINGS_MAX_CONCURRENT_STREAMS parameter in
                  the HTTP/2 SETTINGS frame for  DNS-over-HTTPS  connections.  De-
                  fault 100.

           <a id="http-query-buffer-size"><b>http-query-buffer-size:</b></a> <i>&lt;size</i> <i>in</i> <i>bytes&gt;</i>
                  Maximum  number  of bytes used for all HTTP/2 query buffers com-
                  bined. These buffers contain (partial) DNS queries  waiting  for
                  request  stream completion.  An RST_STREAM frame will be send to
                  streams exceeding this limit. Default is 4  megabytes.  A  plain
                  number  is  in  bytes,  append  'k',  'm'  or 'g' for kilobytes,
                  megabytes or gigabytes (1024*1024 bytes in a megabyte).

           <a id="http-response-buffer-size"><b>http-response-buffer-size:</b></a> <i>&lt;size</i> <i>in</i> <i>bytes&gt;</i>
                  Maximum number of bytes used for  all  HTTP/2  response  buffers
                  combined.  These  buffers  contain  DNS  responses waiting to be
                  written back to the clients.  An RST_STREAM frame will  be  send
                  to streams exceeding this limit. Default is 4 megabytes. A plain
                  number is in bytes,  append  'k',  'm'  or  'g'  for  kilobytes,
                  megabytes or gigabytes (1024*1024 bytes in a megabyte).

           <a id="http-nodelay"><b>http-nodelay:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Set  TCP_NODELAY  socket  option on sockets used to provide DNS-
                  over-HTTPS service.  Ignored if the option is not available. De-
                  fault is yes.

           <a id="http-notls-downstream"><b>http-notls-downstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Disable use of TLS for the downstream DNS-over-HTTP connections.
                  Useful for local back end servers.  Default is no.

           <a id="use-systemd"><b>use-systemd:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable or disable systemd socket activation.  Default is no.

           <a id="do-daemonize"><b>do-daemonize:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable or disable whether the  unbound  server  forks  into  the
                  background  as  a daemon.  Set the value to <i>no</i> when unbound runs
                  as systemd service.  Default is yes.

           <a id="tcp-connection-limit"><b>tcp-connection-limit:</b></a> <i>&lt;IP</i> <i>netblock&gt;</i> <i>&lt;limit&gt;</i>
                  Allow up to <i>limit</i> simultaneous TCP connections  from  the  given
                  netblock.   When  at the limit, further connections are accepted
                  but closed immediately.  This option  is  experimental  at  this
                  time.

           <a id="access-control"><b>access-control:</b></a> <i>&lt;IP</i> <i>netblock&gt;</i> <i>&lt;action&gt;</i>
                  The  netblock  is  given as an IP4 or IP6 address with /size ap-
                  pended for a classless network block. The action  can  be  <i>deny</i>,
                  <i>refuse</i>,   <i>allow</i>,  <i>allow_setrd</i>,  <i>allow_snoop</i>,  <i>deny_non_local</i>  or
                  <i>refuse_non_local</i>.  The most specific netblock match is used,  if
                  none match <i>deny</i> is used.  The order of the access-control state-
                  ments therefore does not matter.

                  The action <i>deny</i> stops queries from hosts from that netblock.

                  The action <i>refuse</i> stops queries too, but sends a DNS  rcode  RE-
                  FUSED error message back.

                  The action <i>allow</i> gives access to clients from that netblock.  It
                  gives only access for recursion clients (which  is  what  almost
                  all clients need).  Nonrecursive queries are refused.

                  The  <i>allow</i>  action does allow nonrecursive queries to access the
                  local-data that is configured.  The reason is that this does not
                  involve  the  unbound  server  recursive  lookup  algorithm, and
                  static data is served in the reply.  This supports normal opera-
                  tions  where nonrecursive queries are made for the authoritative
                  data.  For nonrecursive queries any  replies  from  the  dynamic
                  cache are refused.

                  The  <i>allow_setrd</i>  action  ignores the recursion desired (RD) bit
                  and treats all requests as if the recursion desired bit is  set.
                  Note  that  this  behavior violates RFC 1034 which states that a
                  name server should never perform recursive service unless  asked
                  via  the  RD  bit since this interferes with trouble shooting of
                  name servers and their databases. This prohibited  behavior  may
                  be  useful  if another DNS server must forward requests for spe-
                  cific zones to a resolver DNS server, but only supports stub do-
                  mains  and  sends queries to the resolver DNS server with the RD
                  bit cleared.

                  The action <i>allow_snoop</i> gives nonrecursive access too.  This give
                  both  recursive  and non recursive access.  The name <i>allow_snoop</i>
                  refers to  cache  snooping,  a  technique  to  use  nonrecursive
                  queries  to  examine  the  cache  contents (for malicious acts).
                  However, nonrecursive queries can also be a  valuable  debugging
                  tool (when you want to examine the cache contents). In that case
                  use <i>allow_snoop</i> for your administration host.

                  By default only localhost is <i>allow</i>ed, the rest is <i>refuse</i>d.   The
                  default  is  <i>refuse</i>d, because that is protocol-friendly. The DNS
                  protocol is not designed to handle dropped packets due  to  pol-
                  icy,  and  dropping  may  result in (possibly excessive) retried
                  queries.

                  The deny_non_local and refuse_non_local settings are  for  hosts
                  that are only allowed to query for the authoritative local-data,
                  they are not allowed full recursion but only  the  static  data.
                  With  deny_non_local,  messages that are disallowed are dropped,
                  with refuse_non_local they receive error code REFUSED.

           <a id="access-control-tag"><b>access-control-tag:</b></a> <i>&lt;IP</i> <i>netblock&gt;</i> <i>&lt;"list</i> <i>of</i> <i>tags"&gt;</i>
                  Assign tags to access-control elements. Clients using  this  ac-
                  cess  control element use localzones that are tagged with one of
                  these tags. Tags must be defined in <i>define-tags</i>.   Enclose  list
                  of  tags  in  quotes  ("")  and  put spaces between tags. If ac-
                  cess-control-tag is configured for a netblock that does not have
                  an  access-control,  an access-control element with action <i>allow</i>
                  is configured for this netblock.

           <a id="access-control-tag-action"><b>access-control-tag-action:</b></a> <i>&lt;IP</i> <i>netblock&gt;</i> <i>&lt;tag&gt;</i> <i>&lt;action&gt;</i>
                  Set action for particular tag for given access control  element.
                  If  you have multiple tag values, the tag used to lookup the ac-
                  tion is the first tag match between access-control-tag  and  lo-
                  cal-zone-tag  where  "first" comes from the order of the define-
                  tag values.

           <a id="access-control-tag-data"><b>access-control-tag-data:</b></a> <i>&lt;IP</i> <i>netblock&gt;</i> <i>&lt;tag&gt;</i> <i>&lt;"resource</i> <i>record</i> <i>string"&gt;</i>
                  Set redirect data for particular tag for  given  access  control
                  element.

           <a id="access-control-view"><b>access-control-view:</b></a> <i>&lt;IP</i> <i>netblock&gt;</i> <i>&lt;view</i> <i>name&gt;</i>
                  Set view for given access control element.

           <a id="chroot"><b>chroot:</b></a> <i>&lt;directory&gt;</i>
                  If  chroot  is enabled, you should pass the configfile (from the
                  commandline) as a full path from the original  root.  After  the
                  chroot  has been performed the now defunct portion of the config
                  file path is removed to be able to reread  the  config  after  a
                  reload.

                  All  other  file paths (working dir, logfile, roothints, and key
                  files) can be specified in several ways:  as  an  absolute  path
                  relative  to the new root, as a relative path to the working di-
                  rectory, or as an absolute path relative to the  original  root.
                  In  the last case the path is adjusted to remove the unused por-
                  tion.

                  The pidfile can be either a relative path to the working  direc-
                  tory,  or  an absolute path relative to the original root. It is
                  written just prior to chroot and dropping permissions. This  al-
                  lows the pidfile to be /var/run/unbound.pid and the chroot to be
                  /var/unbound, for example. Note that Unbound is not able to  re-
                  move the pidfile after termination when it is located outside of
                  the chroot directory.

                  Additionally, unbound may need to access /dev/urandom  (for  en-
                  tropy) from inside the chroot.

                  If given a chroot is done to the given directory. By default ch-
                  root is enabled and the default is "/usr/local/etc/unbound".  If
                  you give "" no chroot is performed.

           <a id="username"><b>username:</b></a> <i>&lt;name&gt;</i>
                  If  given,  after  binding  the  port  the  user  privileges are
                  dropped. Default is "unbound". If you give username: "" no  user
                  change is performed.

                  If  this  user  is  not capable of binding the port, reloads (by
                  signal HUP) will still retain the opened ports.  If  you  change
                  the port number in the config file, and that new port number re-
                  quires privileges, then a reload will fail; a restart is needed.

           <a id="directory"><b>directory:</b></a> <i>&lt;directory&gt;</i>
                  Sets the working directory for the program. Default is "/usr/lo-
                  cal/etc/unbound".  On Windows the string "%EXECUTABLE%" tries to
                  change to the directory that unbound.exe  resides  in.   If  you
                  give  a  server:  directory: dir before include: file statements
                  then those includes can be relative to the working directory.

           <a id="logfile"><b>logfile:</b></a> <i>&lt;filename&gt;</i>
                  If "" is given, logging goes to stderr, or nowhere  once  daemo-
                  nized.  The logfile is appended to, in the following format:
                  [seconds since 1970] unbound[pid:tid]: type: message.
                  If  this  option  is  given,  the use-syslog is option is set to
                  "no".  The logfile is reopened (for append) when the config file
                  is reread, on SIGHUP.

           <a id="use-syslog"><b>use-syslog:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Sets  unbound  to  send  log messages to the syslogd, using <i>sys-</i>
                  <i>log</i>(3).  The log facility LOG_DAEMON is used, with identity "un-
                  bound".   The  logfile  setting is overridden when use-syslog is
                  turned on.  The default is to log to syslog.

           <a id="log-identity"><b>log-identity:</b></a> <i>&lt;string&gt;</i>
                  If "" is given (default), then the name of the executable,  usu-
                  ally  "unbound" is used to report to the log.  Enter a string to
                  override it with that, which is useful on systems that run  more
                  than  one instance of unbound, with different configurations, so
                  that the logs can be easily distinguished against.

           <a id="log-time-ascii"><b>log-time-ascii:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Sets logfile lines to use a timestamp in UTC ascii.  Default  is
                  no,  which  prints the seconds since 1970 in brackets. No effect
                  if using syslog, in  that  case  syslog  formats  the  timestamp
                  printed into the log files.

           <a id="log-queries"><b>log-queries:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Prints one line per query to the log, with the log timestamp and
                  IP address, name, type and class.  Default is no.  Note that  it
                  takes time to print these lines which makes the server (signifi-
                  cantly) slower.  Odd  (nonprintable)  characters  in  names  are
                  printed as '?'.

           <a id="log-replies"><b>log-replies:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Prints one line per reply to the log, with the log timestamp and
                  IP address, name, type, class, return  code,  time  to  resolve,
                  from  cache  and  response  size.   Default is no.  Note that it
                  takes time to print these lines which makes the server (signifi-
                  cantly)  slower.   Odd  (nonprintable)  characters  in names are
                  printed as '?'.

           <a id="log-tag-queryreply"><b>log-tag-queryreply:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Prints  the  word  'query'  and  'reply'  with  log-queries  and
                  log-replies.   This makes filtering logs easier.  The default is
                  off (for backwards compatibility).

           <a id="log-local-actions"><b>log-local-actions:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Print log lines to inform about local zone actions.  These lines
                  are  like  the  local-zone  type inform prints out, but they are
                  also printed for the other types of local zones.

           <a id="log-servfail"><b>log-servfail:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Print log lines that say why queries return SERVFAIL to clients.
                  This  is  separate  from the verbosity debug logs, much smaller,
                  and printed at the error level, not the info level of debug info
                  from verbosity.

           <a id="pidfile"><b>pidfile:</b></a> <i>&lt;filename&gt;</i>
                  The  process  id  is  written  to the file. Default is "/usr/lo-
                  cal/etc/unbound/unbound.pid".  So,
                  kill -HUP `cat /usr/local/etc/unbound/unbound.pid`
                  triggers a reload,
                  kill -TERM `cat /usr/local/etc/unbound/unbound.pid`
                  gracefully terminates.

           <a id="root-hints"><b>root-hints:</b></a> <i>&lt;filename&gt;</i>
                  Read the root hints from this file. Default  is  nothing,  using
                  builtin  hints for the IN class. The file has the format of zone
                  files, with root nameserver names and addresses  only.  The  de-
                  fault  may become outdated, when servers change, therefore it is
                  good practice to use a root-hints file.

           <a id="hide-identity"><b>hide-identity:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled id.server and hostname.bind queries are refused.

           <a id="identity"><b>identity:</b></a> <i>&lt;string&gt;</i>
                  Set the identity to report. If set to "", the default, then  the
                  hostname of the server is returned.

           <a id="hide-version"><b>hide-version:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled version.server and version.bind queries are refused.

           <a id="version"><b>version:</b></a> <i>&lt;string&gt;</i>
                  Set  the  version to report. If set to "", the default, then the
                  package version is returned.

           <a id="hide-http-user-agent"><b>hide-http-user-agent:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled the HTTP header User-Agent is not set. Use with  cau-
                  tion  as  some webserver configurations may reject HTTP requests
                  lacking this header.  If needed, it is better to explicitly  set
                  the <b>http-user-agent</b> below.

           <a id="http-user-agent"><b>http-user-agent:</b></a> <i>&lt;string&gt;</i>
                  Set  the  HTTP  User-Agent header for outgoing HTTP requests. If
                  set to "", the default, then the package name  and  version  are
                  used.

           <b>nsid:</b> &lt;string&gt;
                  Add  the  specified  nsid to the EDNS section of the answer when
                  queried with an NSID EDNS enabled packet.  As a sequence of  hex
                  characters or with ascii_ prefix and then an ascii string.

           <a id="hide-trustanchor"><b>hide-trustanchor:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled trustanchor.unbound queries are refused.

           <a id="target-fetch-policy"><b>target-fetch-policy:</b></a> <i>&lt;"list</i> <i>of</i> <i>numbers"&gt;</i>
                  Set  the  target fetch policy used by unbound to determine if it
                  should fetch nameserver target addresses opportunistically.  The
                  policy is described per dependency depth.

                  The  number  of  values  determines the maximum dependency depth
                  that unbound will pursue in answering a query.  A  value  of  -1
                  means to fetch all targets opportunistically for that dependency
                  depth. A value of 0 means to fetch on demand  only.  A  positive
                  value fetches that many targets opportunistically.

                  Enclose the list between quotes ("") and put spaces between num-
                  bers.  The default is "3 2 1 0 0". Setting all zeroes, "0 0 0  0
                  0"  gives  behaviour closer to that of BIND 9, while setting "-1
                  -1 -1 -1 -1" gives behaviour rumoured to be closer  to  that  of
                  BIND 8.

           <a id="harden-short-bufsize"><b>harden-short-bufsize:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Very  small  EDNS buffer sizes from queries are ignored. Default
                  is on, as described in the standard.

           <a id="harden-large-queries"><b>harden-large-queries:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Very large queries are ignored. Default is off, since it is  le-
                  gal  protocol wise to send these, and could be necessary for op-
                  eration if TSIG or EDNS payload is very large.

           <a id="harden-glue"><b>harden-glue:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Will trust glue only if it is within the servers authority.  De-
                  fault is yes.

           <a id="harden-dnssec-stripped"><b>harden-dnssec-stripped:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Require  DNSSEC  data  for trust-anchored zones, if such data is
                  absent, the zone becomes bogus. If turned  off,  and  no  DNSSEC
                  data  is  received  (or the DNSKEY data fails to validate), then
                  the zone is made insecure, this behaves like there is  no  trust
                  anchor.  You  could turn this off if you are sometimes behind an
                  intrusive firewall (of some sort) that removes DNSSEC data  from
                  packets,  or  a  zone  changes  from signed to unsigned to badly
                  signed often. If turned off you run the risk of a downgrade  at-
                  tack that disables security for a zone. Default is yes.

           <a id="harden-below-nxdomain"><b>harden-below-nxdomain:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  From RFC 8020 (with title "NXDOMAIN: There Really Is Nothing Un-
                  derneath"), returns nxdomain to queries for a name below another
                  name  that is already known to be nxdomain.  DNSSEC mandates no-
                  error for empty nonterminals, hence this is possible.  Very  old
                  software might return nxdomain for empty nonterminals (that usu-
                  ally happen for reverse IP address lookups), and thus may be in-
                  compatible  with  this.  To try to avoid this only DNSSEC-secure
                  nxdomains are used, because  the  old  software  does  not  have
                  DNSSEC.   Default  is  yes.   The  nxdomain must be secure, this
                  means nsec3 with optout is insufficient.

           <a id="harden-referral-path"><b>harden-referral-path:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Harden the referral path by performing  additional  queries  for
                  infrastructure data.  Validates the replies if trust anchors are
                  configured and the zones are signed.  This enforces DNSSEC vali-
                  dation  on  nameserver NS sets and the nameserver addresses that
                  are encountered on the referral path to the answer.  Default no,
                  because  it  burdens  the  authority  servers, and it is not RFC
                  standard, and could lead to performance problems because of  the
                  extra  query  load  that is generated.  Experimental option.  If
                  you enable it  consider  adding  more  numbers  after  the  tar-
                  get-fetch-policy to increase the max depth that is checked to.

           <a id="harden-algo-downgrade"><b>harden-algo-downgrade:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Harden  against algorithm downgrade when multiple algorithms are
                  advertised in the DS record.  If no, allows  the  weakest  algo-
                  rithm  to  validate the zone.  Default is no.  Zone signers must
                  produce zones that allow this feature  to  work,  but  sometimes
                  they  do not, and turning this option off avoids that validation
                  failure.

           <a id="use-caps-for-id"><b>use-caps-for-id:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Use 0x20-encoded random bits in the  query  to  foil  spoof  at-
                  tempts.   This  perturbs  the  lowercase  and uppercase of query
                  names sent to authority servers and checks if  the  reply  still
                  has  the  correct casing.  Disabled by default.  This feature is
                  an experimental implementation of draft dns-0x20.

           <a id="caps-exempt"><b>caps-exempt:</b></a> <i>&lt;domain&gt;</i>
                  Exempt the domain so that it does not receive  caps-for-id  per-
                  turbed  queries.   For domains that do not support 0x20 and also
                  fail with fallback because they keep sending different  answers,
                  like some load balancers.  Can be given multiple times, for dif-
                  ferent domains.

           <a id="caps-whitelist"><b>caps-whitelist:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Alternate syntax for <b>caps-exempt</b>.

           <a id="qname-minimisation"><b>qname-minimisation:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Send minimum amount of information to upstream  servers  to  en-
                  hance  privacy.   Only send minimum required labels of the QNAME
                  and set QTYPE to A when possible.  Best  effort  approach;  full
                  QNAME and original QTYPE will be sent when upstream replies with
                  a RCODE other than NOERROR, except when receiving NXDOMAIN  from
                  a DNSSEC signed zone. Default is yes.

           <a id="qname-minimisation-strict"><b>qname-minimisation-strict:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  QNAME  minimisation  in strict mode. Do not fall-back to sending
                  full QNAME to potentially broken nameservers. A lot  of  domains
                  will  not be resolvable when this option in enabled. Only use if
                  you know what you are doing.  This option only has  effect  when
                  qname-minimisation is enabled. Default is no.

           <a id="aggressive-nsec"><b>aggressive-nsec:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Aggressive  NSEC  uses the DNSSEC NSEC chain to synthesize NXDO-
                  MAIN and other denials, using information  from  previous  NXDO-
                  MAINs  answers.   Default  is  no.  It helps to reduce the query
                  rate towards targets that  get  a  very  high  nonexistent  name
                  lookup rate.

           <a id="private-address"><b>private-address:</b></a> <i>&lt;IP</i> <i>address</i> <i>or</i> <i>subnet&gt;</i>
                  Give  IPv4 of IPv6 addresses or classless subnets. These are ad-
                  dresses on your private network, and are not allowed to  be  re-
                  turned  for  public  internet names.  Any occurrence of such ad-
                  dresses are removed from DNS answers. Additionally,  the  DNSSEC
                  validator  may  mark  the  answers  bogus. This protects against
                  so-called DNS Rebinding, where a user browser is turned  into  a
                  network  proxy,  allowing  remote  access through the browser to
                  other parts of your private network.  Some names can be  allowed
                  to contain your private addresses, by default all the <b>local-data</b>
                  that you configured is allowed to, and  you  can  specify  addi-
                  tional names using <b>private-domain</b>.  No private addresses are en-
                  abled by default.  We consider to enable this  for  the  RFC1918
                  private  IP  address  space  by  default in later releases. That
                  would enable  private  addresses  for  10.0.0.0/8  172.16.0.0/12
                  192.168.0.0/16  169.254.0.0/16 fd00::/8 and fe80::/10, since the
                  RFC standards say these addresses should not be visible  on  the
                  public internet.  Turning on 127.0.0.0/8 would hinder many spam-
                  blocklists  as  they  use  that.   Adding  ::ffff:0:0/96   stops
                  IPv4-mapped IPv6 addresses from bypassing the filter.

           <a id="private-domain"><b>private-domain:</b></a> <i>&lt;domain</i> <i>name&gt;</i>
                  Allow this domain, and all its subdomains to contain private ad-
                  dresses.  Give multiple times to allow multiple domain names  to
                  contain private addresses. Default is none.

           <a id="unwanted-reply-threshold"><b>unwanted-reply-threshold:</b></a> <i>&lt;number&gt;</i>
                  If  set,  a total number of unwanted replies is kept track of in
                  every thread.  When it reaches the threshold, a defensive action
                  is taken and a warning is printed to the log.  The defensive ac-
                  tion is to clear the rrset and message caches, hopefully  flush-
                  ing  away  any poison.  A value of 10 million is suggested.  De-
                  fault is 0 (turned off).

           <a id="do-not-query-address"><b>do-not-query-address:</b></a> <i>&lt;IP</i> <i>address&gt;</i>
                  Do not query the given IP address. Can be  IP4  or  IP6.  Append
                  /num  to  indicate  a classless delegation netblock, for example
                  like 10.2.3.4/24 or 2001::11/64.

           <a id="do-not-query-localhost"><b>do-not-query-localhost:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If yes, localhost is added to the do-not-query-address  entries,
                  both  IP6  ::1 and IP4 127.0.0.1/8. If no, then localhost can be
                  used to send queries to. Default is yes.

           <a id="prefetch"><b>prefetch:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If yes, message cache elements are prefetched before they expire
                  to  keep  the  cache  up to date.  Default is no.  Turning it on
                  gives about 10 percent more traffic and load on the machine, but
                  popular items do not expire from the cache.

           <a id="prefetch-key"><b>prefetch-key:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  yes,  fetch  the  DNSKEYs earlier in the validation process,
                  when a DS record is encountered.  This lowers the latency of re-
                  quests.   It  does  use a little more CPU.  Also if the cache is
                  set to 0, it is no use. Default is no.

           <a id="deny-any"><b>deny-any:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If yes, deny queries of type ANY with an  empty  response.   De-
                  fault is no.  If disabled, unbound responds with a short list of
                  resource records if some can be found in the cache and makes the
                  upstream type ANY query if there are none.

           <a id="rrset-roundrobin"><b>rrset-roundrobin:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If yes, Unbound rotates RRSet order in response (the random num-
                  ber is taken from the query ID, for speed  and  thread  safety).
                  Default is yes.

           <a id="minimal-responses"><b>minimal-responses:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  yes,  Unbound  does not insert authority/additional sections
                  into response messages when those  sections  are  not  required.
                  This  reduces  response  size  significantly,  and may avoid TCP
                  fallback for some responses.  This may cause a  slight  speedup.
                  The  default  is  yes, even though the DNS protocol RFCs mandate
                  these sections, and the additional content could be of  use  and
                  save roundtrips for clients.  Because they are not used, and the
                  saved roundtrips are easier saved with prefetch, whilst this  is
                  faster.

           <a id="disable-dnssec-lame-check"><b>disable-dnssec-lame-check:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  true,  disables  the  DNSSEC lameness check in the iterator.
                  This check sees if RRSIGs are present in the answer, when dnssec
                  is  expected,  and retries another authority if RRSIGs are unex-
                  pectedly missing.  The  validator  will  insist  in  RRSIGs  for
                  DNSSEC signed domains regardless of this setting, if a trust an-
                  chor is loaded.

           <a id="module-config"><b>module-config:</b></a> <i>&lt;"module</i> <i>names"&gt;</i>
                  Module configuration, a list of module names separated  by  spa-
                  ces,  surround  the  string with quotes (""). The modules can be
                  <i>respip</i>, <i>validator</i>, or <i>iterator</i> (and possibly more,  see  below).
                  Setting  this to just "<i>iterator</i>" will result in a non-validating
                  server.  Setting this  to  "<i>validator</i>  <i>iterator</i>"  will  turn  on
                  DNSSEC  validation.  The ordering of the modules is significant,
                  the order decides the order of processing.  You  must  also  set
                  <i>trust-anchors</i> for validation to be useful.  Adding <i>respip</i> to the
                  front will cause RPZ processing to be done on all queries.   The
                  default is "<i>validator</i> <i>iterator</i>".

                  When the server is built with EDNS client subnet support the de-
                  fault is "<i>subnetcache</i> <i>validator</i> <i>iterator</i>".   Most  modules  that
                  need to be listed here have to be listed at the beginning of the
                  line.  The subnetcachedb module has to be listed just before the
                  iterator.   The python module can be listed in different places,
                  it then processes the output of the module it  is  just  before.
                  The dynlib module can be listed pretty much anywhere, it is only
                  a very thin wrapper that allows dynamic libraries to run in  its
                  place.

           <a id="trust-anchor-file"><b>trust-anchor-file:</b></a> <i>&lt;filename&gt;</i>
                  File  with  trusted  keys for validation. Both DS and DNSKEY en-
                  tries can appear in the file. The format  of  the  file  is  the
                  standard  DNS  Zone file format.  Default is "", or no trust an-
                  chor file.

           <a id="auto-trust-anchor-file"><b>auto-trust-anchor-file:</b></a> <i>&lt;filename&gt;</i>
                  File with trust anchor for  one  zone,  which  is  tracked  with
                  RFC5011  probes.   The  probes  are run several times per month,
                  thus the machine must be online frequently.   The  initial  file
                  can be one with contents as described in <b>trust-anchor-file</b>.  The
                  file is written to when the anchor is updated,  so  the  unbound
                  user  must have write permission.  Write permission to the file,
                  but also to the directory it is in (to create a temporary  file,
                  which is necessary to deal with filesystem full events), it must
                  also be inside the chroot (if that is used).

           <a id="trust-anchor"><b>trust-anchor:</b></a> <i>&lt;"Resource</i> <i>Record"&gt;</i>
                  A DS or DNSKEY RR for a key to use for validation. Multiple  en-
                  tries can be given to specify multiple trusted keys, in addition
                  to the trust-anchor-files.  The resource record  is  entered  in
                  the same format as 'dig' or 'drill' prints them, the same format
                  as in the zone file. Has to be on a single line, with ""  around
                  it. A TTL can be specified for ease of cut and paste, but is ig-
                  nored.  A class can be specified, but class IN is default.

           <a id="trusted-keys-file"><b>trusted-keys-file:</b></a> <i>&lt;filename&gt;</i>
                  File with trusted keys for validation.  Specify  more  than  one
                  file  with  several  entries, one file per entry. Like <b>trust-an-</b>
                  <b>chor-file</b> but has a different  file  format.  Format  is  BIND-9
                  style  format, the trusted-keys { name flag proto algo "key"; };
                  clauses are read.  It is possible to  use  wildcards  with  this
                  statement, the wildcard is expanded on start and on reload.

           <a id="trust-anchor-signaling"><b>trust-anchor-signaling:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Send  RFC8145  key tag query after trust anchor priming. Default
                  is yes.

           <a id="root-key-sentinel"><b>root-key-sentinel:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Root key trust anchor sentinel. Default is yes.

           <a id="domain-insecure"><b>domain-insecure:</b></a> <i>&lt;domain</i> <i>name&gt;</i>
                  Sets domain name to be insecure, DNSSEC chain of  trust  is  ig-
                  nored  towards the domain name.  So a trust anchor above the do-
                  main name can not make the domain secure with a DS record,  such
                  a  DS  record  is  then ignored.  Can be given multiple times to
                  specify multiple domains that are treated as  if  unsigned.   If
                  you  set trust anchors for the domain they override this setting
                  (and the domain is secured).

                  This can be useful if you want to make sure a trust  anchor  for
                  external  lookups does not affect an (unsigned) internal domain.
                  A DS record externally can create validation failures  for  that
                  internal domain.

           <a id="val-override-date"><b>val-override-date:</b></a> <i>&lt;rrsig-style</i> <i>date</i> <i>spec&gt;</i>
                  Default  is "" or "0", which disables this debugging feature. If
                  enabled by giving a RRSIG style date, that date is used for ver-
                  ifying RRSIG inception and expiration dates, instead of the cur-
                  rent date. Do not set this unless you  are  debugging  signature
                  inception  and  expiration.  The value -1 ignores the date alto-
                  gether, useful for some special applications.

           <a id="val-sig-skew-min"><b>val-sig-skew-min:</b></a> <i>&lt;seconds&gt;</i>
                  Minimum number of seconds of clock skew to  apply  to  validated
                  signatures.   A  value of 10% of the signature lifetime (expira-
                  tion - inception) is used, capped by this setting.   Default  is
                  3600  (1  hour)  which  allows for daylight savings differences.
                  Lower this value for more strict checking of short lived  signa-
                  tures.

           <a id="val-sig-skew-max"><b>val-sig-skew-max:</b></a> <i>&lt;seconds&gt;</i>
                  Maximum  number  of  seconds of clock skew to apply to validated
                  signatures.  A value of 10% of the signature  lifetime  (expira-
                  tion  -  inception) is used, capped by this setting.  Default is
                  86400 (24 hours) which allows for timezone setting  problems  in
                  stable  domains.  Setting both min and max very low disables the
                  clock skew allowances.  Setting both min and max very high makes
                  the validator check the signature timestamps less strictly.

           <a id="val-max-restart"><b>val-max-restart:</b></a> <i>&lt;number&gt;</i>
                  The  maximum number the validator should restart validation with
                  another authority in case of failed validation. Default is 5.

           <a id="val-bogus-ttl"><b>val-bogus-ttl:</b></a> <i>&lt;number&gt;</i>
                  The time to live for bogus data. This is data  that  has  failed
                  validation;  due  to invalid signatures or other checks. The TTL
                  from that data cannot be trusted, and this  value  is  used  in-
                  stead.  The  value is in seconds, default 60.  The time interval
                  prevents repeated revalidation of bogus data.

           <a id="val-clean-additional"><b>val-clean-additional:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Instruct the validator to remove data from the  additional  sec-
                  tion  of  secure messages that are not signed properly. Messages
                  that are insecure, bogus, indeterminate or unchecked are not af-
                  fected.  Default  is  yes. Use this setting to protect the users
                  that rely on this validator for authentication from  potentially
                  bad data in the additional section.

           <a id="val-log-level"><b>val-log-level:</b></a> <i>&lt;number&gt;</i>
                  Have  the  validator  print validation failures to the log.  Re-
                  gardless of the verbosity setting.  Default is 0,  off.   At  1,
                  for  every  user query that fails a line is printed to the logs.
                  This way you can monitor what happens with  validation.   Use  a
                  diagnosis tool, such as dig or drill, to find out why validation
                  is failing for these queries.  At 2, not  only  the  query  that
                  failed is printed but also the reason why unbound thought it was
                  wrong and which server sent the faulty data.

           <a id="val-permissive-mode"><b>val-permissive-mode:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Instruct the validator to mark bogus messages as  indeterminate.
                  The  security  checks  are performed, but if the result is bogus
                  (failed security), the reply is not  withheld  from  the  client
                  with  SERVFAIL as usual. The client receives the bogus data. For
                  messages that are found to be  secure  the  AD  bit  is  set  in
                  replies.  Also logging is performed as for full validation.  The
                  default value is "no".

           <a id="ignore-cd-flag"><b>ignore-cd-flag:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Instruct unbound to ignore the CD flag from clients  and  refuse
                  to  return  bogus  answers to them.  Thus, the CD (Checking Dis-
                  abled) flag does not disable checking any more.  This is  useful
                  if  legacy (w2008) servers that set the CD flag but cannot vali-
                  date DNSSEC themselves are the clients, and  then  unbound  pro-
                  vides them with DNSSEC protection.  The default value is "no".

           <a id="serve-expired"><b>serve-expired:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  enabled,  unbound attempts to serve old responses from cache
                  with a TTL of <b>serve-expired-reply-ttl</b> in  the  response  without
                  waiting for the actual resolution to finish.  The actual resolu-
                  tion answer ends up in the cache later on.  Default is "no".

           <a id="serve-expired-ttl"><b>serve-expired-ttl:</b></a> <i>&lt;seconds&gt;</i>
                  Limit serving of expired responses to configured  seconds  after
                  expiration. 0 disables the limit.  This option only applies when
                  <b>serve-expired</b> is enabled.  A suggested value per RFC 8767 is be-
                  tween 86400 (1 day) and 259200 (3 days).  The default is 0.

           <a id="serve-expired-ttl-reset"><b>serve-expired-ttl-reset:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Set  the  TTL  of expired records to the <b>serve-expired-ttl</b> value
                  after a failed attempt to retrieve  the  record  from  upstream.
                  This  makes sure that the expired records will be served as long
                  as there are queries for it.  Default is "no".

           <a id="serve-expired-reply-ttl"><b>serve-expired-reply-ttl:</b></a> <i>&lt;seconds&gt;</i>
                  TTL value to use when replying with expired data.  If  <b>serve-ex-</b>
                  <b>pired-client-timeout</b>  is also used then it is RECOMMENDED to use
                  30 as the value (RFC 8767).  The default is 30.

           <a id="serve-expired-client-timeout"><b>serve-expired-client-timeout:</b></a> <i>&lt;msec&gt;</i>
                  Time in milliseconds before replying to the client with  expired
                  data.   This  essentially  enables  the  serve-stale behavior as
                  specified in RFC 8767 that first tries to resolve before immedi-
                  ately responding with expired data.  A recommended value per RFC
                  8767 is 1800.  Setting this to 0  will  disable  this  behavior.
                  Default is 0.

           <a id="serve-original-ttl"><b>serve-original-ttl:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  enabled,  unbound will always return the original TTL as re-
                  ceived from the upstream name server rather than the  decrement-
                  ing  TTL  as stored in the cache.  This feature may be useful if
                  unbound serves as a front-end to  a  hidden  authoritative  name
                  server.  Enabling  this feature does not impact cache expiry, it
                  only changes the TTL unbound embeds  in  responses  to  queries.
                  Note  that enabling this feature implicitly disables enforcement
                  of the configured minimum and maximum  TTL,  as  it  is  assumed
                  users  who enable this feature do not want unbound to change the
                  TTL obtained from an upstream server.  Thus, the values set  us-
                  ing  <b>cache-min-ttl</b>  and  <b>cache-max-ttl</b>  are ignored.  Default is
                  "no".

           <a id="val-nsec3-keysize-iterations"><b>val-nsec3-keysize-iterations:</b></a> <i>&lt;"list</i> <i>of</i> <i>values"&gt;</i>
                  List of keysize and iteration count values, separated by spaces,
                  surrounded  by  quotes. Default is "1024 150 2048 150 4096 150".
                  This determines the maximum allowed NSEC3 iteration count before
                  a  message  is  simply marked insecure instead of performing the
                  many hashing iterations. The list must be in ascending order and
                  have  at least one entry. If you set it to "1024 65535" there is
                  no restriction to NSEC3 iteration values.  This  table  must  be
                  kept short; a very long list could cause slower operation.

           <a id="zonemd-permissive-mode"><b>zonemd-permissive-mode:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  enabled the ZONEMD verification failures are only logged and
                  do not cause the zone to be blocked and  only  return  servfail.
                  Useful  for  testing  out  if  it works, or if the operator only
                  wants to be notified of a problem  without  disrupting  service.
                  Default is no.

           <a id="add-holddown"><b>add-holddown:</b></a> <i>&lt;seconds&gt;</i>
                  Instruct  the <b>auto-trust-anchor-file</b> probe mechanism for RFC5011
                  autotrust updates to add new trust anchors only after they  have
                  been visible for this time.  Default is 30 days as per the RFC.

           <a id="del-holddown"><b>del-holddown:</b></a> <i>&lt;seconds&gt;</i>
                  Instruct  the <b>auto-trust-anchor-file</b> probe mechanism for RFC5011
                  autotrust updates to remove revoked  trust  anchors  after  they
                  have been kept in the revoked list for this long.  Default is 30
                  days as per the RFC.

           <a id="keep-missing"><b>keep-missing:</b></a> <i>&lt;seconds&gt;</i>
                  Instruct the <b>auto-trust-anchor-file</b> probe mechanism for  RFC5011
                  autotrust  updates  to  remove  missing trust anchors after they
                  have been unseen for this long.  This cleans up the  state  file
                  if  the target zone does not perform trust anchor revocation, so
                  this makes the auto probe mechanism work with zones that perform
                  regular  (non-5011)  rollovers.   The  default is 366 days.  The
                  value 0 does not remove missing anchors, as per the RFC.

           <a id="permit-small-holddown"><b>permit-small-holddown:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Debug option that allows the autotrust 5011 rollover  timers  to
                  assume very small values.  Default is no.

           <a id="key-cache-size"><b>key-cache-size:</b></a> <i>&lt;number&gt;</i>
                  Number  of  bytes size of the key cache. Default is 4 megabytes.
                  A plain number is in bytes, append 'k', 'm'  or  'g'  for  kilo-
                  bytes, megabytes or gigabytes (1024*1024 bytes in a megabyte).

           <a id="key-cache-slabs"><b>key-cache-slabs:</b></a> <i>&lt;number&gt;</i>
                  Number  of  slabs in the key cache. Slabs reduce lock contention
                  by threads.  Must be set to a power of 2. Setting (close) to the
                  number of cpus is a reasonable guess.

           <a id="neg-cache-size"><b>neg-cache-size:</b></a> <i>&lt;number&gt;</i>
                  Number  of  bytes size of the aggressive negative cache. Default
                  is 1 megabyte.  A plain number is in bytes, append 'k',  'm'  or
                  'g'  for kilobytes, megabytes or gigabytes (1024*1024 bytes in a
                  megabyte).

           <a id="unblock-lan-zones"><b>unblock-lan-zones:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Default is disabled.   If  enabled,  then  for  private  address
                  space,  the reverse lookups are no longer filtered.  This allows
                  unbound when running as dns service on a host where it  provides
                  service  for  that  host,  to put out all of the queries for the
                  'lan' upstream.  When enabled, only localhost, 127.0.0.1 reverse
                  and  ::1  reverse zones are configured with default local zones.
                  Disable the option when unbound is running as a (DHCP-) DNS net-
                  work resolver for a group of machines, where such lookups should
                  be filtered (RFC compliance), this  also  stops  potential  data
                  leakage about the local network to the upstream DNS servers.

           <a id="insecure-lan-zones"><b>insecure-lan-zones:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Default  is  disabled.  If enabled, then reverse lookups in pri-
                  vate address space are not validated.  This is usually  required
                  whenever <i>unblock-lan-zones</i> is used.

           <a id="local-zone"><b>local-zone:</b></a> <i>&lt;zone&gt;</i> <i>&lt;type&gt;</i>
                  Configure  a  local zone. The type determines the answer to give
                  if there is no  match  from  local-data.  The  types  are  deny,
                  refuse,  static, transparent, redirect, nodefault, typetranspar-
                  ent, inform, inform_deny,  inform_redirect,  always_transparent,
                  always_refuse, always_nxdomain, always_null, noview, and are ex-
                  plained below. After that the default settings are  listed.  Use
                  local-data: to enter data into the local zone. Answers for local
                  zones are authoritative DNS answers. By default  the  zones  are
                  class IN.

                  If you need more complicated authoritative data, with referrals,
                  wildcards, CNAME/DNAME support, or DNSSEC authoritative service,
                  setup  a  stub-zone  for it as detailed in the stub zone section
                  below.

                <i>deny</i> Do not send an answer, drop the query.  If there is  a  match
                     from local data, the query is answered.

                <i>refuse</i>
                     Send an error message reply, with rcode REFUSED.  If there is
                     a match from local data, the query is answered.

                <i>static</i>
                     If there is a match from local data, the query  is  answered.
                     Otherwise,  the  query  is  answered with nodata or nxdomain.
                     For a negative answer a SOA is  included  in  the  answer  if
                     present as local-data for the zone apex domain.

                <i>transparent</i>
                     If  there  is a match from local data, the query is answered.
                     Otherwise if the query has a different name, the query is re-
                     solved  normally.  If the query is for a name given in local-
                     data but no such type of data is given in localdata,  then  a
                     noerror nodata answer is returned.  If no local-zone is given
                     local-data causes a transparent zone to  be  created  by  de-
                     fault.

                <i>typetransparent</i>
                     If  there  is a match from local data, the query is answered.
                     If the query is for a different name, or for  the  same  name
                     but  for  a  different  type, the query is resolved normally.
                     So, similar to transparent but types that are not  listed  in
                     local data are resolved normally, so if an A record is in the
                     local data that does  not  cause  a  nodata  reply  for  AAAA
                     queries.

                <i>redirect</i>
                     The  query is answered from the local data for the zone name.
                     There may be no local data beneath the zone name.   This  an-
                     swers  queries  for  the zone, and all subdomains of the zone
                     with the local data for the zone.  It can be used to redirect
                     a  domain  to  return  a  different address record to the end
                     user,  with  local-zone:  "example.com."  redirect  and   lo-
                     cal-data:  "example.com.  A  127.0.0.1" queries for www.exam-
                     ple.com and www.foo.example.com are redirected, so that users
                     with  web  browsers  cannot  access  sites  with suffix exam-
                     ple.com.

                <i>inform</i>
                     The query is answered normally,  same  as  transparent.   The
                     client  IP  address  (@portnumber) is printed to the logfile.
                     The log message is: timestamp,  unbound-pid,  info:  zonename
                     inform IP@port queryname type class.  This option can be used
                     for normal resolution, but machines looking up infected names
                     are logged, eg. to run antivirus on them.

                <i>inform_deny</i>
                     The query is dropped, like 'deny', and logged, like 'inform'.
                     Ie. find infected machines without answering the queries.

                <i>inform_redirect</i>
                     The query is redirected, like 'redirect',  and  logged,  like
                     'inform'.   Ie.  answer  queries with fixed data and also log
                     the machines that ask.

                <i>always_transparent</i>
                     Like transparent, but ignores local data  and  resolves  nor-
                     mally.

                <i>always_refuse</i>
                     Like refuse, but ignores local data and refuses the query.

                <i>always_nxdomain</i>
                     Like  static, but ignores local data and returns nxdomain for
                     the query.

                <i>always_nodata</i>
                     Like static, but ignores local data and  returns  nodata  for
                     the query.

                <i>always_deny</i>
                     Like deny, but ignores local data and drops the query.

                <i>always_null</i>
                     Always  returns  0.0.0.0  or  ::0 for every name in the zone.
                     Like redirect with zero data for A and AAAA.   Ignores  local
                     data in the zone.  Used for some block lists.

                <i>noview</i>
                     Breaks  out  of  that view and moves towards the global local
                     zones for answer to the query.  If  the  view  first  is  no,
                     it'll  resolve  normally.   If  view  first is enabled, it'll
                     break perform that step and check the  global  answers.   For
                     when  the  view has view specific overrides but some zone has
                     to be answered from global local zone contents.

                <i>nodefault</i>
                     Used to turn off default contents for AS112 zones. The  other
                     types also turn off default contents for the zone. The 'node-
                     fault' option has no other effect than  turning  off  default
                     contents  for  the  given zone.  Use <i>nodefault</i> if you use ex-
                     actly that zone, if you want to use a subzone, use  <i>transpar-</i>
                     <i>ent</i>.

           The  default zones are localhost, reverse 127.0.0.1 and ::1, the onion,
           test, invalid and the AS112 zones. The  AS112  zones  are  reverse  DNS
           zones  for  private use and reserved IP addresses for which the servers
           on the internet cannot provide correct answers. They are configured  by
           default to give nxdomain (no reverse information) answers. The defaults
           can be turned off by specifying your own local-zone of  that  name,  or
           using  the  'nodefault'  type. Below is a list of the default zone con-
           tents.

                <i>localhost</i>
                     The IP4 and IP6 localhost information is given.  NS  and  SOA
                     records are provided for completeness and to satisfy some DNS
                     update tools. Default content:
                     local-zone: "localhost." redirect
                     local-data: "localhost. 10800 IN NS localhost."
                     local-data: "localhost. 10800 IN
                         SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"
                     local-data: "localhost. 10800 IN A 127.0.0.1"
                     local-data: "localhost. 10800 IN AAAA ::1"

                <i>reverse</i> <i>IPv4</i> <i>loopback</i>
                     Default content:
                     local-zone: "127.in-addr.arpa." static
                     local-data: "127.in-addr.arpa. 10800 IN NS localhost."
                     local-data: "127.in-addr.arpa. 10800 IN
                         SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"
                     local-data: "1.0.0.127.in-addr.arpa. 10800 IN
                         PTR localhost."

                <i>reverse</i> <i>IPv6</i> <i>loopback</i>
                     Default content:
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

                <i>onion</i> <i>(RFC</i> <i>7686)</i>
                     Default content:
                     local-zone: "onion." static
                     local-data: "onion. 10800 IN NS localhost."
                     local-data: "onion. 10800 IN
                         SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"

                <i>test</i> <i>(RFC</i> <i>6761)</i>
                     Default content:
                     local-zone: "test." static
                     local-data: "test. 10800 IN NS localhost."
                     local-data: "test. 10800 IN
                         SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"

                <i>invalid</i> <i>(RFC</i> <i>6761)</i>
                     Default content:
                     local-zone: "invalid." static
                     local-data: "invalid. 10800 IN NS localhost."
                     local-data: "invalid. 10800 IN
                         SOA localhost. nobody.invalid. 1 3600 1200 604800 10800"

                <i>reverse</i> <i>RFC1918</i> <i>local</i> <i>use</i> <i>zones</i>
                     Reverse data for zones  10.in-addr.arpa,  16.172.in-addr.arpa
                     to   31.172.in-addr.arpa,   168.192.in-addr.arpa.    The  <b>lo-</b>
                     <b>cal-zone:</b> is set static and as <b>local-data:</b> SOA and NS records
                     are provided.

                <i>reverse</i> <i>RFC3330</i> <i>IP4</i> <i>this,</i> <i>link-local,</i> <i>testnet</i> <i>and</i> <i>broadcast</i>
                     Reverse  data for zones 0.in-addr.arpa, 254.169.in-addr.arpa,
                     2.0.192.in-addr.arpa (TEST  NET  1),  100.51.198.in-addr.arpa
                     (TEST   NET   2),   113.0.203.in-addr.arpa   (TEST   NET  3),
                     255.255.255.255.in-addr.arpa.  And  from  64.100.in-addr.arpa
                     to 127.100.in-addr.arpa (Shared Address Space).

                <i>reverse</i> <i>RFC4291</i> <i>IP6</i> <i>unspecified</i>
                     Reverse data for zone
                     0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.
                     0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa.

                <i>reverse</i> <i>RFC4193</i> <i>IPv6</i> <i>Locally</i> <i>Assigned</i> <i>Local</i> <i>Addresses</i>
                     Reverse data for zone D.F.ip6.arpa.

                <i>reverse</i> <i>RFC4291</i> <i>IPv6</i> <i>Link</i> <i>Local</i> <i>Addresses</i>
                     Reverse data for zones 8.E.F.ip6.arpa to B.E.F.ip6.arpa.

                <i>reverse</i> <i>IPv6</i> <i>Example</i> <i>Prefix</i>
                     Reverse  data for zone 8.B.D.0.1.0.0.2.ip6.arpa. This zone is
                     used for tutorials and examples. You can remove the block  on
                     this zone with:
                       local-zone: 8.B.D.0.1.0.0.2.ip6.arpa. nodefault
                     You can also selectively unblock a part of the zone by making
                     that part transparent with a local-zone statement.  This also
                     works with the other default zones.

           <a id="local-data"><b>local-data:</b></a> <i>"&lt;resource</i> <i>record</i> <i>string&gt;"</i>
                Configure  local data, which is served in reply to queries for it.
                The query has to match exactly unless you configure the local-zone
                as  redirect.  If  not matched exactly, the local-zone type deter-
                mines further processing. If local-data is configured that is  not
                a  subdomain  of a local-zone, a transparent local-zone is config-
                ured.  For record types such as TXT, use single quotes, as in  lo-
                cal-data: 'example. TXT "text"'.

                If  you  need more complicated authoritative data, with referrals,
                wildcards, CNAME/DNAME support, or DNSSEC  authoritative  service,
                setup  a stub-zone for it as detailed in the stub zone section be-
                low.

           <a id="local-data-ptr"><b>local-data-ptr:</b></a> <i>"IPaddr</i> <i>name"</i>
                Configure local data shorthand for a PTR record with the  reversed
                IPv4  or  IPv6  address and the host name.  For example "192.0.2.4
                www.example.com".  TTL can be  inserted  like  this:  "2001:DB8::4
                7200 www.example.com"

           <a id="local-zone-tag"><b>local-zone-tag:</b></a> <i>&lt;zone&gt;</i> <i>&lt;"list</i> <i>of</i> <i>tags"&gt;</i>
                Assign  tags to localzones. Tagged localzones will only be applied
                when the used access-control element has a matching tag. Tags must
                be  defined  in  <i>define-tags</i>.  Enclose list of tags in quotes ("")
                and put spaces between tags.  When  there  are  multiple  tags  it
                checks  if  the intersection of the list of tags for the query and
                local-zone-tag is non-empty.

           <a id="local-zone-override"><b>local-zone-override:</b></a> <i>&lt;zone&gt;</i> <i>&lt;IP</i> <i>netblock&gt;</i> <i>&lt;type&gt;</i>
                Override the localzone type for queries  from  addresses  matching
                netblock.  Use this localzone type, regardless the type configured
                for the local-zone (both tagged and untagged) and  regardless  the
                type configured using access-control-tag-action.

           <a id="response-ip"><b>response-ip:</b></a> <i>&lt;IP-netblock&gt;</i> <i>&lt;action&gt;</i>
                This requires use of the "respip" module.

                If  the  IP  address in an AAAA or A RR in the answer section of a
                response matches the specified IP netblock, the  specified  action
                will apply.  <i>&lt;action&gt;</i> has generally the same semantics as that for
                <i>access-control-tag-action</i>, but there are some exceptions.

                Actions for <i>response-ip</i> are different from those for <i>local-zone</i> in
                that in case of the former there is no point of such conditions as
                "the query matches it but there is no  local  data".   Because  of
                this difference, the semantics of <i>response-ip</i> actions are modified
                or simplified as follows: The <i>static,</i> <i>refuse,</i>  <i>transparent,</i>  <i>type-</i>
                <i>transparent,</i>  and  <i>nodefault</i>  actions are invalid for <i>response-ip</i>.
                Using any of these will cause the configuration to be rejected  as
                faulty. The <i>deny</i> action is non-conditional, i.e. it always results
                in dropping the corresponding query.  The resolution result before
                applying the deny action is still cached and can be used for other
                queries.

           <a id="response-ip-data"><b>response-ip-data:</b></a> <i>&lt;IP-netblock&gt;</i> <i>&lt;"resource</i> <i>record</i> <i>string"&gt;</i>
                This requires use of the "respip" module.

                This specifies the action data for <i>response-ip</i> with  action  being
                to  redirect  as specified by "<i>resource</i> <i>record</i> <i>string</i>".  "Resource
                record string" is similar to  that  of  <i>access-control-tag-action</i>,
                but  it  must be of either AAAA, A or CNAME types.  If the IP-net-
                block is an IPv6/IPV4 prefix, the record must  be  AAAA/A  respec-
                tively,  unless it is a CNAME (which can be used for both versions
                of IP netblocks).  If it is CNAME there must not be more than  one
                <i>response-ip-data</i>  for the same IP-netblock.  Also, CNAME and other
                types of records must not coexist for the same  IP-netblock,  fol-
                lowing  the  normal  rules  for CNAME records.  The textual domain
                name for the CNAME does not have to be explicitly terminated  with
                a  dot  (".");  the  root name is assumed to be the origin for the
                name.

           <a id="response-ip-tag"><b>response-ip-tag:</b></a> <i>&lt;IP-netblock&gt;</i> <i>&lt;"list</i> <i>of</i> <i>tags"&gt;</i>
                This requires use of the "respip" module.

                Assign tags to response IP-netblocks.  If the  IP  address  in  an
                AAAA or A RR in the answer section of a response matches the spec-
                ified IP-netblock, the specified tags are assigned to the  IP  ad-
                dress.   Then,  if an <i>access-control-tag</i> is defined for the client
                and it includes one of the tags for the response  IP,  the  corre-
                sponding  <i>access-control-tag-action</i> will apply.  Tag matching rule
                is the same as that for <i>access-control-tag</i> and  <i>local-zones</i>.   Un-
                like <i>local-zone-tag</i>, <i>response-ip-tag</i> can be defined for an IP-net-
                block even if no <i>response-ip</i> is defined  for  that  netblock.   If
                multiple  <i>response-ip-tag</i>  options  are specified for the same IP-
                netblock in different statements, all but the first  will  be  ig-
                nored.   However,  this will not be flagged as a configuration er-
                ror, but the result is probably not what was intended.

                Actions specified  in  an  <i>access-control-tag-action</i>  that  has  a
                matching  tag with <i>response-ip-tag</i> can be those that are "invalid"
                for <i>response-ip</i> listed above, since <i>access-control-tag-action</i>s can
                be  shared  with  local  zones.  For these actions, if they behave
                differently depending on whether local data exists or not in  case
                of  local  zones, the behavior for <i>response-ip-data</i> will generally
                result in NOERROR/NODATA instead of NXDOMAIN, since the  <i>response-</i>
                <i>ip</i>  data  are  inherently type specific, and non-existence of data
                does not indicate anything about the existence or non-existence of
                the  qname  itself.   For  example,  if the matching tag action is
                <i>static</i> but there is no data for the corresponding <i>response-ip</i> con-
                figuration, then the result will be NOERROR/NODATA.  The only case
                where NXDOMAIN is returned is when an <i>always_nxdomain</i>  action  ap-
                plies.

           <a id="ratelimit"><b>ratelimit:</b></a> <i>&lt;number</i> <i>or</i> <i>0&gt;</i>
                Enable  ratelimiting  of queries sent to nameserver for performing
                recursion.  If 0, the default, it is disabled.  This option is ex-
                perimental  at  this time.  The ratelimit is in queries per second
                that are allowed.  More queries are  turned  away  with  an  error
                (servfail).   This stops recursive floods, eg. random query names,
                but not spoofed reflection floods.  Cached responses are not rate-
                limited  by  this setting.  The zone of the query is determined by
                examining the nameservers for it, the zone name is  used  to  keep
                track  of  the rate.  For example, 1000 may be a suitable value to
                stop the server from being overloaded with random names, and keeps
                unbound from sending traffic to the nameservers for those zones.

           <a id="ratelimit-size"><b>ratelimit-size:</b></a> <i>&lt;memory</i> <i>size&gt;</i>
                Give  the  size of the data structure in which the current ongoing
                rates are kept track in.  Default 4m.  In bytes  or  use  m(mega),
                k(kilo),  g(giga).  The ratelimit structure is small, so this data
                structure likely does not need to be large.

           <a id="ratelimit-slabs"><b>ratelimit-slabs:</b></a> <i>&lt;number&gt;</i>
                Give power of 2 number of slabs, this is used to reduce lock  con-
                tention  in  the  ratelimit tracking data structure.  Close to the
                number of cpus is a fairly good setting.

           <a id="ratelimit-factor"><b>ratelimit-factor:</b></a> <i>&lt;number&gt;</i>
                Set the amount of queries to rate limit  when  the  limit  is  ex-
                ceeded.   If  set  to 0, all queries are dropped for domains where
                the limit is exceeded.  If set to another value, 1 in that  number
                is  allowed  through  to  complete.   Default is 10, allowing 1/10
                traffic to flow normally.  This can make ordinary queries complete
                (if repeatedly queried for), and enter the cache, whilst also mit-
                igating the traffic flow by the factor given.

           <a id="ratelimit-for-domain"><b>ratelimit-for-domain:</b></a> <i>&lt;domain&gt;</i> <i>&lt;number</i> <i>qps</i> <i>or</i> <i>0&gt;</i>
                Override the global ratelimit for an exact match domain name  with
                the  listed  number.   You  can give this for any number of names.
                For example, for a top-level-domain you may want to have a  higher
                limit  than  other  names.  A value of 0 will disable ratelimiting
                for that domain.

           <a id="ratelimit-below-domain"><b>ratelimit-below-domain:</b></a> <i>&lt;domain&gt;</i> <i>&lt;number</i> <i>qps</i> <i>or</i> <i>0&gt;</i>
                Override the global ratelimit for a domain name that ends in  this
                name.  You can give this multiple times, it then describes differ-
                ent settings in different parts of  the  namespace.   The  closest
                matching  suffix is used to determine the qps limit.  The rate for
                the  exact  matching  domain  name  is  not  changed,  use   rate-
                limit-for-domain to set that, you might want to use different set-
                tings for a top-level-domain and subdomains.  A value  of  0  will
                disable ratelimiting for domain names that end in this name.

           <a id="ip-ratelimit"><b>ip-ratelimit:</b></a> <i>&lt;number</i> <i>or</i> <i>0&gt;</i>
                Enable global ratelimiting of queries accepted per ip address.  If
                0, the default, it is disabled.  This option  is  experimental  at
                this  time.   The  ratelimit is in queries per second that are al-
                lowed.  More queries are completely dropped and will not receive a
                reply,  SERVFAIL  or  otherwise.   IP  ratelimiting happens before
                looking in the cache. This may be useful for mitigating amplifica-
                tion attacks.

           <a id="ip-ratelimit-size"><b>ip-ratelimit-size:</b></a> <i>&lt;memory</i> <i>size&gt;</i>
                Give  the  size of the data structure in which the current ongoing
                rates are kept track in.  Default 4m.  In bytes  or  use  m(mega),
                k(kilo),  g(giga).   The  ip ratelimit structure is small, so this
                data structure likely does not need to be large.

           <a id="ip-ratelimit-slabs"><b>ip-ratelimit-slabs:</b></a> <i>&lt;number&gt;</i>
                Give power of 2 number of slabs, this is used to reduce lock  con-
                tention in the ip ratelimit tracking data structure.  Close to the
                number of cpus is a fairly good setting.

           <a id="ip-ratelimit-factor"><b>ip-ratelimit-factor:</b></a> <i>&lt;number&gt;</i>
                Set the amount of queries to rate limit  when  the  limit  is  ex-
                ceeded.   If set to 0, all queries are dropped for addresses where
                the limit is exceeded.  If set to another value, 1 in that  number
                is  allowed  through  to  complete.   Default is 10, allowing 1/10
                traffic to flow normally.  This can make ordinary queries complete
                (if repeatedly queried for), and enter the cache, whilst also mit-
                igating the traffic flow by the factor given.

           <a id="fast-server-permil"><b>fast-server-permil:</b></a> <i>&lt;number&gt;</i>
                Specify how many times out of 1000 to pick from the set of fastest
                servers.  0 turns the feature off.  A value of 900 would pick from
                the fastest servers 90 percent of the time, and would perform nor-
                mal  exploration  of  random  servers for the remaining time. When
                prefetch is enabled (or serve-expired), such  prefetches  are  not
                sped up, because there is no one waiting for it, and it presents a
                good moment to perform server exploration. The <b>fast-server-num</b> op-
                tion  can  be used to specify the size of the fastest servers set.
                The default for fast-server-permil is 0.

           <a id="fast-server-num"><b>fast-server-num:</b></a> <i>&lt;number&gt;</i>
                Set the number of servers that should be used for fast server  se-
                lection. Only use the fastest specified number of servers with the
                fast-server-permil option, that turns this on or off. The  default
                is to use the fastest 3 servers.

           <a id="edns-client-string"><b>edns-client-string:</b></a> <i>&lt;IP</i> <i>netblock&gt;</i> <i>&lt;string&gt;</i>
                Include  an  EDNS0  option  containing  configured ascii string in
                queries with destination address matching the configured  IP  net-
                block.   This configuration option can be used multiple times. The
                most specific match will be used.

           <a id="edns-client-string-opcode"><b>edns-client-string-opcode:</b></a> <i>&lt;opcode&gt;</i>
                EDNS0 option code for the <i>edns-client-string</i>  option,  from  0  to
                65535.   A  value from the `Reserved for Local/Experimental` range
                (65001-65534) should be used.  Default is 65001.

       <b>Remote</b> <b>Control</b> <b>Options</b>
           In the <b>remote-control:</b> clause are the declarations for the remote  con-
           trol  facility.  If this is enabled, the <a href="/manpages/unbound-control/"><i>unbound-control</i>(8)</a> utility can
           be used to send commands to the running  unbound  server.   The  server
           uses these clauses to setup TLSv1 security for the connection.  The <i>un-</i>
           <i>bound-control</i>(8) utility also reads the <b>remote-control</b> section for  op-
           tions.   To  setup  the  correct  self-signed  certificates use the <i>un-</i>
           <i>bound-control-setup</i>(8) utility.

           <a id="control-enable"><b>control-enable:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                The option is used to enable remote control, default is "no".   If
                turned off, the server does not listen for control commands.

           <a id="control-interface"><b>control-interface:</b></a> <i>&lt;ip</i> <i>address</i> <i>or</i> <i>path&gt;</i>
                Give  IPv4 or IPv6 addresses or local socket path to listen on for
                control commands.  By default localhost  (127.0.0.1  and  ::1)  is
                listened to.  Use 0.0.0.0 and ::0 to listen to all interfaces.  If
                you change this  and  permissions  have  been  dropped,  you  must
                restart the server for the change to take effect.

                If  you  set  it to an absolute path, a local socket is used.  The
                local socket does not use the  certificates  and  keys,  so  those
                files  need not be present.  To restrict access, unbound sets per-
                missions on the file to the user and group that is configured, the
                access  bits are set to allow the group members to access the con-
                trol socket file.  Put users that need to access the socket in the
                that group.  To restrict access further, create a directory to put
                the control socket in and restrict access to that directory.

           <a id="control-port"><b>control-port:</b></a> <i>&lt;port</i> <i>number&gt;</i>
                The port number to listen on for IPv4 or IPv6 control  interfaces,
                default  is  8953.   If  you change this and permissions have been
                dropped, you must restart the server for the change  to  take  ef-
                fect.

           <a id="control-use-cert"><b>control-use-cert:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                For  localhost control-interface you can disable the use of TLS by
                setting this option to "no", default is "yes".  For local sockets,
                TLS is disabled and the value of this option is ignored.

           <a id="server-key-file"><b>server-key-file:</b></a> <i>&lt;private</i> <i>key</i> <i>file&gt;</i>
                Path  to  the  server  private key, by default unbound_server.key.
                This file is generated by the <i>unbound-control-setup</i> utility.  This
                file is used by the unbound server, but not by <i>unbound-control</i>.

           <a id="server-cert-file"><b>server-cert-file:</b></a> <i>&lt;certificate</i> <i>file.pem&gt;</i>
                Path  to  the  server  self  signed  certificate,  by  default un-
                bound_server.pem.  This file  is  generated  by  the  <i>unbound-con-</i>
                <i>trol-setup</i>  utility.  This file is used by the unbound server, and
                also by <i>unbound-control</i>.

           <a id="control-key-file"><b>control-key-file:</b></a> <i>&lt;private</i> <i>key</i> <i>file&gt;</i>
                Path to the control client private key,  by  default  unbound_con-
                trol.key.   This  file  is  generated by the <i>unbound-control-setup</i>
                utility.  This file is used by <i>unbound-control</i>.

           <a id="control-cert-file"><b>control-cert-file:</b></a> <i>&lt;certificate</i> <i>file.pem&gt;</i>
                Path to the control client certificate,  by  default  unbound_con-
                trol.pem.   This certificate has to be signed with the server cer-
                tificate.  This file is  generated  by  the  <i>unbound-control-setup</i>
                utility.  This file is used by <i>unbound-control</i>.

       <b>Stub</b> <b>Zone</b> <b>Options</b>
           There may be multiple <b>stub-zone:</b> clauses. Each with a name: and zero or
           more hostnames or IP addresses.  For the stub zone this list  of  name-
           servers  is used. Class IN is assumed.  The servers should be authority
           servers, not recursors; unbound performs the recursive  processing  it-
           self for stub zones.

           The stub zone can be used to configure authoritative data to be used by
           the resolver that cannot be accessed using the public internet servers.
           This  is  useful  for company-local data or private zones. Setup an au-
           thoritative server on a different host (or  different  port).  Enter  a
           config  entry  for unbound with <b>stub-addr:</b> &lt;ip address of host[@port]&gt;.
           The unbound resolver can then access the data, without referring to the
           public internet for it.

           This  setup  allows DNSSEC signed zones to be served by that authorita-
           tive server, in which case a trusted key entry with the public key  can
           be  put in config, so that unbound can validate the data and set the AD
           bit on replies for the private zone (authoritative servers do  not  set
           the AD bit).  This setup makes unbound capable of answering queries for
           the private zone, and can even set the AD bit ('authentic'), but the AA
           ('authoritative') bit is not set on these replies.

           Consider  adding  <b>server:</b>  statements  for <b>domain-insecure:</b> and for <b>lo-</b>
           <a id="cal-zone"><b>cal-zone:</b></a> <i>name</i> <i>nodefault</i> for the zone if it is a locally  served  zone.
           The insecure clause stops DNSSEC from invalidating the zone.  The local
           zone nodefault (or <i>transparent</i>) clause makes the (reverse-) zone bypass
           unbound's filtering of RFC1918 zones.

           <a id="name"><b>name:</b></a> <i>&lt;domain</i> <i>name&gt;</i>
                  Name of the stub zone.

           <a id="stub-host"><b>stub-host:</b></a> <i>&lt;domain</i> <i>name&gt;</i>
                  Name  of  stub  zone nameserver. Is itself resolved before it is
                  used.

           <a id="stub-addr"><b>stub-addr:</b></a> <i>&lt;IP</i> <i>address&gt;</i>
                  IP address of stub zone nameserver. Can be IP 4 or IP 6.  To use
                  a nondefault port for DNS communication append '@' with the port
                  number.  If tls is enabled, then you can  append  a  '#'  and  a
                  name,  then it'll check the tls authentication certificates with
                  that name.  If you combine the '@' and '#', the '@' comes first.

           <a id="stub-prime"><b>stub-prime:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  This option is by default no.  If enabled  it  performs  NS  set
                  priming,  which  is similar to root hints, where it starts using
                  the list of nameservers currently published by the zone.   Thus,
                  if  the  hint list is slightly outdated, the resolver picks up a
                  correct list online.

           <a id="stub-first"><b>stub-first:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, a query is attempted without the stub clause  if  it
                  fails.   The  data  could not be retrieved and would have caused
                  SERVFAIL because the servers  are  unreachable,  instead  it  is
                  tried without this clause.  The default is no.

           <a id="stub-tls-upstream"><b>stub-tls-upstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enabled  or disable whether the queries to this stub use TLS for
                  transport.  Default is no.

           <a id="stub-ssl-upstream"><b>stub-ssl-upstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Alternate syntax for <b>stub-tls-upstream</b>.

           <a id="stub-no-cache"><b>stub-no-cache:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Default is no.  If enabled, data inside the stub is not  cached.
                  This is useful when you want immediate changes to be visible.

       <b>Forward</b> <b>Zone</b> <b>Options</b>
           There may be multiple <b>forward-zone:</b> clauses. Each with a <b>name:</b> and zero
           or more hostnames or IP addresses.  For the forward zone this  list  of
           nameservers  is  used  to forward the queries to. The servers listed as
           <b>forward-host:</b> and <b>forward-addr:</b> have to handle  further  recursion  for
           the  query.   Thus,  those  servers  are not authority servers, but are
           (just like unbound is) recursive servers too; unbound does not  perform
           recursion itself for the forward zone, it lets the remote server do it.
           Class IN is assumed.  CNAMEs are chased by unbound itself,  asking  the
           remote  server  for every name in the indirection chain, to protect the
           local cache from illegal indirect referenced items.  A forward-zone en-
           try with name "." and a forward-addr target will forward all queries to
           that other server (unless it can answer from the cache).

           <a id="name"><b>name:</b></a> <i>&lt;domain</i> <i>name&gt;</i>
                  Name of the forward zone.

           <a id="forward-host"><b>forward-host:</b></a> <i>&lt;domain</i> <i>name&gt;</i>
                  Name of server to forward to. Is itself resolved  before  it  is
                  used.

           <a id="forward-addr"><b>forward-addr:</b></a> <i>&lt;IP</i> <i>address&gt;</i>
                  IP address of server to forward to. Can be IP 4 or IP 6.  To use
                  a nondefault port for DNS communication append '@' with the port
                  number.   If  tls  is  enabled,  then you can append a '#' and a
                  name, then it'll check the tls authentication certificates  with
                  that name.  If you combine the '@' and '#', the '@' comes first.

                  At high verbosity it logs the TLS certificate, with TLS enabled.
                  If you leave out the '#' and auth name  from  the  forward-addr,
                  any  name  is  accepted.  The cert must also match a CA from the
                  tls-cert-bundle.

           <a id="forward-first"><b>forward-first:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If a forwarded query is met with a SERVFAIL error, and this  op-
                  tion is enabled, unbound will fall back to normal recursive res-
                  olution for this query as if no query forwarding had been speci-
                  fied.  The default is "no".

           <a id="forward-tls-upstream"><b>forward-tls-upstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enabled or disable whether the queries to this forwarder use TLS
                  for transport.  Default is no.  If you enable this, also config-
                  ure a tls-cert-bundle or use tls-win-cert to load CA certs, oth-
                  erwise the connections cannot be authenticated.

           <a id="forward-ssl-upstream"><b>forward-ssl-upstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Alternate syntax for <b>forward-tls-upstream</b>.

           <a id="forward-no-cache"><b>forward-no-cache:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Default is no.  If enabled,  data  inside  the  forward  is  not
                  cached.   This  is  useful when you want immediate changes to be
                  visible.

       <b>Authority</b> <b>Zone</b> <b>Options</b>
           Authority zones are configured with <b>auth-zone:</b>, and each one must  have
           a  <b>name:</b>.   There  can  be multiple ones, by listing multiple auth-zone
           clauses, each with a different name, pertaining to  that  part  of  the
           namespace.  The authority zone with the name closest to the name looked
           up is used.  Authority zones are processed after <b>local-zones</b> and before
           cache  (<b>for-downstream:</b> <i>yes</i>), and when used in this manner make unbound
           respond like an authority server.  Authority zones are  also  processed
           after  cache, just before going to the network to fetch information for
           recursion (<b>for-upstream:</b> <i>yes</i>), and when used in this manner  provide  a
           local copy of an authority server that speeds up lookups of that data.

           Authority zones can be read from zonefile.  And can be kept updated via
           AXFR and IXFR.  After update the zonefile  is  rewritten.   The  update
           mechanism uses the SOA timer values and performs SOA UDP queries to de-
           tect zone changes.

           If the update fetch fails, the timers in the SOA  record  are  used  to
           time  another  fetch  attempt.   Until the SOA expiry timer is reached.
           Then the zone is expired.  When a zone is expired,  queries  are  SERV-
           FAIL,  and  any new serial number is accepted from the primary (even if
           older), and if fallback is enabled, the  fallback  activates  to  fetch
           from the upstream instead of the SERVFAIL.

           <a id="name"><b>name:</b></a> <i>&lt;zone</i> <i>name&gt;</i>
                  Name of the authority zone.

           <a id="primary"><b>primary:</b></a> <i>&lt;IP</i> <i>address</i> <i>or</i> <i>host</i> <i>name&gt;</i>
                  Where  to  download a copy of the zone from, with AXFR and IXFR.
                  Multiple primaries can be specified.  They are all tried if  one
                  fails.   To  use  a nondefault port for DNS communication append
                  '@' with the port number.  You can append a '#' and a name, then
                  AXFR  over  TLS  can be used and the tls authentication certifi-
                  cates will be checked with that name.  If you  combine  the  '@'
                  and  '#',  the  '@' comes first.  If you point it at another Un-
                  bound instance, it would not work because that does not  support
                  AXFR/IXFR  for  the  zone,  but if you used <b>url:</b> to download the
                  zonefile as a text file from a webserver that  would  work.   If
                  you  specify  the  hostname,  you cannot use the domain from the
                  zonefile, because it may not  have  that  when  retrieving  that
                  data,  instead use a plain IP address to avoid a circular depen-
                  dency on retrieving that IP address.

           <a id="master"><b>master:</b></a> <i>&lt;IP</i> <i>address</i> <i>or</i> <i>host</i> <i>name&gt;</i>
                  Alternate syntax for <b>primary</b>.

           <a id="url"><b>url:</b></a> <i>&lt;url</i> <i>to</i> <i>zonefile&gt;</i>
                  Where to download a zonefile for the zone.  With http or  https.
                  An   example   for   the  url  is  "http://www.example.com/exam-
                  ple.org.zone".  Multiple url statements can be given,  they  are
                  tried  in turn.  If only urls are given the SOA refresh timer is
                  used to wait for making new downloads.  If  also  primaries  are
                  listed,  the  primaries are first probed with UDP SOA queries to
                  see if the SOA serial number has changed, reducing the number of
                  downloads.   If  none  of the urls work, the primaries are tried
                  with IXFR and AXFR.  For  https,  the  <b>tls-cert-bundle</b>  and  the
                  hostname  from  the url are used to authenticate the connection.
                  If you specify a hostname in the URL, you cannot use the  domain
                  from  the zonefile, because it may not have that when retrieving
                  that data, instead use a plain IP address to  avoid  a  circular
                  dependency on retrieving that IP address.  Avoid dependencies on
                  name lookups by using a notation like "http://192.0.2.1/unbound-
                  primaries/example.com.zone", with an explicit IP address.

           <a id="allow-notify"><b>allow-notify:</b></a> <i>&lt;IP</i> <i>address</i> <i>or</i> <i>host</i> <i>name</i> <i>or</i> <i>netblockIP/prefix&gt;</i>
                  With  allow-notify  you  can specify additional sources of noti-
                  fies.  When notified, the server attempts  to  first  probe  and
                  then  zone  transfer.  If the notify is from a primary, it first
                  attempts that primary.  Otherwise other primaries are attempted.
                  If there are no primaries, but only urls, the file is downloaded
                  when notified.  The primaries from primary: statements  are  al-
                  lowed notify by default.

           <a id="fallback-enabled"><b>fallback-enabled:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Default  no.  If enabled, unbound falls back to querying the in-
                  ternet as a resolver for this zone when lookups fail.  For exam-
                  ple for DNSSEC validation failures.

           <a id="for-downstream"><b>for-downstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Default  yes.  If enabled, unbound serves authority responses to
                  downstream clients for this zone.  This option makes unbound be-
                  have,  for  the queries with names in this zone, like one of the
                  authority servers for that zone.  Turn it off if  you  want  un-
                  bound to provide recursion for the zone but have a local copy of
                  zone data.  If for-downstream is no  and  for-upstream  is  yes,
                  then  unbound  will DNSSEC validate the contents of the zone be-
                  fore serving the zone contents to clients and  store  validation
                  results in the cache.

           <a id="for-upstream"><b>for-upstream:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Default  yes.   If  enabled, unbound fetches data from this data
                  collection for answering recursion queries.  Instead of  sending
                  queries  over  the  internet  to  the authority servers for this
                  zone, it'll fetch the data directly from the zone data.  Turn it
                  on  when  you  want  unbound to provide recursion for downstream
                  clients, and use the zone data as  a  local  copy  to  speed  up
                  lookups.

           <a id="zonemd-check"><b>zonemd-check:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable  this option to check ZONEMD records in the zone. Default
                  is disabled.  The ZONEMD record is  a  checksum  over  the  zone
                  data.  This  includes  glue  in  the zone and data from the zone
                  file, and excludes comments from the zone file.  When there is a
                  DNSSEC chain of trust, DNSSEC signatures are checked too.

           <a id="zonemd-reject-absence"><b>zonemd-reject-absence:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable  this  option to reject the absence of the ZONEMD record.
                  Without it, when zonemd is not there it is not checked.   It  is
                  useful  to enable for a nonDNSSEC signed zone where the operator
                  wants to require the verification of a ZONEMD, hence  a  missing
                  ZONEMD  is  a failure.  The action upon failure is controlled by
                  the <b>zonemd-permissive-mode</b> option, for log only  or  also  block
                  the zone.  The default is no.

                  Without  the  option  absence of a ZONEMD is only a failure when
                  the zone is DNSSEC signed, and we have a trust anchor,  and  the
                  DNSSEC  verification  of  the absence of the ZONEMD fails.  With
                  the option enabled, the absence of a ZONEMD is always a failure,
                  also for nonDNSSEC signed zones.

           <a id="zonefile"><b>zonefile:</b></a> <i>&lt;filename&gt;</i>
                  The  filename  where  the  zone is stored.  If not given then no
                  zonefile is used.  If the file does not exist or is  empty,  un-
                  bound  will  attempt  to  fetch  zone data (eg. from the primary
                  servers).

       <b>View</b> <b>Options</b>
           There may be multiple <b>view:</b> clauses. Each with a <b>name:</b> and zero or more
           <b>local-zone</b>  and <b>local-data</b> elements. Views can also contain view-first,
           response-ip, response-ip-data and local-data-ptr elements.  View can be
           mapped  to  requests  by  specifying  the  view  name in an <b>access-con-</b>
           <b>trol-view</b> element. Options from matching views will override global op-
           tions.  Global  options  will  be used if no matching view is found, or
           when the matching view does not have the option specified.

           <a id="name"><b>name:</b></a> <i>&lt;view</i> <i>name&gt;</i>
                  Name of the view. Must be unique.  This  name  is  used  in  ac-
                  cess-control-view elements.

           <a id="local-zone"><b>local-zone:</b></a> <i>&lt;zone&gt;</i> <i>&lt;type&gt;</i>
                  View specific local-zone elements. Has the same types and behav-
                  iour as the global local-zone elements. When there is  at  least
                  one  local-zone  specified and view-first is no, the default lo-
                  cal-zones will be added to this view.  Defaults can be  disabled
                  using  the nodefault type. When view-first is yes or when a view
                  does not have a local-zone, the global local-zone will  be  used
                  including it's default zones.

           <a id="local-data"><b>local-data:</b></a> <i>"&lt;resource</i> <i>record</i> <i>string&gt;"</i>
                  View specific local-data elements. Has the same behaviour as the
                  global local-data elements.

           <a id="local-data-ptr"><b>local-data-ptr:</b></a> <i>"IPaddr</i> <i>name"</i>
                  View specific local-data-ptr elements. Has the same behaviour as
                  the global local-data-ptr elements.

           <a id="view-first"><b>view-first:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  enabled,  it  attempts  to use the global local-zone and lo-
                  cal-data if there is no match in the view specific options.  The
                  default is no.

       <b>Python</b> <b>Module</b> <b>Options</b>
           The  <b>python:</b> clause gives the settings for the <i>python</i>(1) script module.
           This module acts like the iterator and validator modules do, on queries
           and  answers.   To  enable the script module it has to be compiled into
           the daemon, and the word "python" has to be put in  the  <b>module-config:</b>
           option (usually first, or between the validator and iterator). Multiple
           instances of the  python  module  are  supported  by  adding  the  word
           "python" more than once.

           If the <b>chroot:</b> option is enabled, you should make sure Python's library
           directory structure is bind mounted in the new  root  environment,  see
           <i>mount</i>(8).  Also the <b>python-script:</b> path should be specified as an abso-
           lute path relative to the new root, or as a relative path to the  work-
           ing directory.

           <a id="python-script"><b>python-script:</b></a> <i>&lt;python</i> <i>file&gt;</i>
                  The  script  file  to  load. Repeat this option for every python
                  module instance added to the <b>module-config:</b> option.

       <b>Dynamic</b> <b>Library</b> <b>Module</b> <b>Options</b>
           The <b>dynlib:</b> clause gives the settings for the <i>dynlib</i> module.  This mod-
           ule  is  only  a  very  small wrapper that allows dynamic modules to be
           loaded on runtime instead of being compiled into  the  application.  To
           enable the dynlib module it has to be compiled into the daemon, and the
           word "dynlib" has to be put in the <b>module-config:</b> option. Multiple  in-
           stances  of dynamic libraries are supported by adding the word "dynlib"
           more than once.

           The <b>dynlib-file:</b> path should be specified as an absolute path  relative
           to  the  new  path  set by <b>chroot:</b> option, or as a relative path to the
           working directory.

           <a id="dynlib-file"><b>dynlib-file:</b></a> <i>&lt;dynlib</i> <i>file&gt;</i>
                  The dynamic library file to load. Repeat this option  for  every
                  dynlib module instance added to the <b>module-config:</b> option.

       <b>DNS64</b> <b>Module</b> <b>Options</b>
           The  dns64  module must be configured in the <b>module-config:</b> "dns64 val-
           idator iterator" directive and be compiled into the daemon  to  be  en-
           abled.  These settings go in the <b>server:</b> section.

           <a id="dns64-prefix"><b>dns64-prefix:</b></a> <i>&lt;IPv6</i> <i>prefix&gt;</i>
                  This  sets  the  DNS64  prefix to use to synthesize AAAA records
                  with.  It must  be  /96  or  shorter.   The  default  prefix  is
                  64:ff9b::/96.

           <a id="dns64-synthall"><b>dns64-synthall:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Debug  option,  default  no.   If  enabled,  synthesize all AAAA
                  records despite the presence of actual AAAA records.

           <a id="dns64-ignore-aaaa"><b>dns64-ignore-aaaa:</b></a> <i>&lt;name&gt;</i>
                  List domain for which the AAAA records are  ignored  and  the  A
                  record is used by dns64 processing instead.  Can be entered mul-
                  tiple times, list a new domain for which  it  applies,  one  per
                  line.  Applies also to names underneath the name given.

       <b>DNSCrypt</b> <b>Options</b>
           The  <b>dnscrypt:</b> clause gives the settings of the dnscrypt channel. While
           those options are available, they are only meaningful  if  unbound  was
           compiled with <b>--enable-dnscrypt</b>.  Currently certificate and secret/pub-
           lic keys cannot be generated by unbound.  You can use  dnscrypt-wrapper
           to  generate those: https://github.com/cofyc/dnscrypt-wrapper/blob/mas-
           ter/README.md#usage

           <a id="dnscrypt-enable"><b>dnscrypt-enable:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Whether or not the <b>dnscrypt</b> config should be  enabled.  You  may
                  define configuration but not activate it.  The default is no.

           <a id="dnscrypt-port"><b>dnscrypt-port:</b></a> <i>&lt;port</i> <i>number&gt;</i>
                  On which port should <b>dnscrypt</b> should be activated. Note that you
                  should have a matching <b>interface</b> option defined  in  the  <b>server</b>
                  section for this port.

           <a id="dnscrypt-provider"><b>dnscrypt-provider:</b></a> <i>&lt;provider</i> <i>name&gt;</i>
                  The  provider name to use to distribute certificates. This is of
                  the form: <b>2.dnscrypt-cert.example.com.</b>. The name <i>MUST</i> end with a
                  dot.

           <a id="dnscrypt-secret-key"><b>dnscrypt-secret-key:</b></a> <i>&lt;path</i> <i>to</i> <i>secret</i> <i>key</i> <i>file&gt;</i>
                  Path  to  the  time  limited secret key file. This option may be
                  specified multiple times.

           <a id="dnscrypt-provider-cert"><b>dnscrypt-provider-cert:</b></a> <i>&lt;path</i> <i>to</i> <i>cert</i> <i>file&gt;</i>
                  Path to the certificate  related  to  the  <b>dnscrypt-secret-key</b>s.
                  This option may be specified multiple times.

           <a id="dnscrypt-provider-cert-rotated"><b>dnscrypt-provider-cert-rotated:</b></a> <i>&lt;path</i> <i>to</i> <i>cert</i> <i>file&gt;</i>
                  Path  to  a certificate that we should be able to serve existing
                  connection  from   but   do   not   want   to   advertise   over
                  <b>dnscrypt-provider</b>'s  TXT  record  certs distribution.  A typical
                  use case is when rotating  certificates,  existing  clients  may
                  still  use  the  client magic from the old cert in their queries
                  until they fetch and update the new cert. Likewise, it would al-
                  low  one  to prime the new cert/key without distributing the new
                  cert yet, this can be useful when using a network of servers us-
                  ing  anycast  and on which the configuration may not get updated
                  at the exact same time. By priming the  cert,  the  servers  can
                  handle  both  old  and new certs traffic while distributing only
                  one.  This option may be specified multiple times.

           <a id="dnscrypt-shared-secret-cache-size"><b>dnscrypt-shared-secret-cache-size:</b></a> <i>&lt;memory</i> <i>size&gt;</i>
                  Give the size of the data structure in which the  shared  secret
                  keys  are  kept  in.   Default  4m.   In  bytes  or use m(mega),
                  k(kilo), g(giga).  The shared secret cache is used when  a  same
                  client  is making multiple queries using the same public key. It
                  saves a substantial amount of CPU.

           <a id="dnscrypt-shared-secret-cache-slabs"><b>dnscrypt-shared-secret-cache-slabs:</b></a> <i>&lt;number&gt;</i>
                  Give power of 2 number of slabs, this is  used  to  reduce  lock
                  contention  in  the dnscrypt shared secrets cache.  Close to the
                  number of cpus is a fairly good setting.

           <a id="dnscrypt-nonce-cache-size"><b>dnscrypt-nonce-cache-size:</b></a> <i>&lt;memory</i> <i>size&gt;</i>
                  Give the size of the data structure in which the  client  nonces
                  are  kept  in.   Default  4m.  In bytes or use m(mega), k(kilo),
                  g(giga).  The nonce cache is used to  prevent  dnscrypt  message
                  replaying.  Client nonce should be unique for any pair of client
                  pk/server sk.

           <a id="dnscrypt-nonce-cache-slabs"><b>dnscrypt-nonce-cache-slabs:</b></a> <i>&lt;number&gt;</i>
                  Give power of 2 number of slabs, this is  used  to  reduce  lock
                  contention  in the dnscrypt nonce cache.  Close to the number of
                  cpus is a fairly good setting.

       <b>EDNS</b> <b>Client</b> <b>Subnet</b> <b>Module</b> <b>Options</b>
           The ECS module must be configured in  the  <b>module-config:</b>  "subnetcache
           validator iterator" directive and be compiled into the daemon to be en-
           abled.  These settings go in the <b>server:</b> section.

           If the destination address is allowed in the configuration Unbound will
           add  the  EDNS0 option to the query containing the relevant part of the
           client's address.  When an answer contains the ECS option the  response
           and  the option are placed in a specialized cache. If the authority in-
           dicated no support, the response is stored in the regular cache.

           Additionally, when a client includes the option in its queries, Unbound
           will  forward  the  option when sending the query to addresses that are
           explicitly allowed in the configuration using  <b>send-client-subnet</b>.  The
           option  will  always be forwarded, regardless the allowed addresses, if
           <b>client-subnet-always-forward</b> is set to yes. In this case the lookup  in
           the regular cache is skipped.

           The  maximum size of the ECS cache is controlled by 'msg-cache-size' in
           the configuration file. On top of that, for each query only 100 differ-
           ent subnets are allowed to be stored for each address family. Exceeding
           that number, older entries will be purged from cache.

           <a id="send-client-subnet"><b>send-client-subnet:</b></a> <i>&lt;IP</i> <i>address&gt;</i>
                  Send client source address to this authority. Append /num to in-
                  dicate   a  classless  delegation  netblock,  for  example  like
                  10.2.3.4/24 or 2001::11/64. Can be given multiple times. Author-
                  ities  not  listed will not receive edns-subnet information, un-
                  less domain in query is specified in <b>client-subnet-zone</b>.

           <a id="client-subnet-zone"><b>client-subnet-zone:</b></a> <i>&lt;domain&gt;</i>
                  Send client source address in queries for this  domain  and  its
                  subdomains.  Can  be given multiple times. Zones not listed will
                  not receive edns-subnet information, unless hosted by  authority
                  specified in <b>send-client-subnet</b>.

           <a id="client-subnet-always-forward"><b>client-subnet-always-forward:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Specify   whether   the  ECS  address  check  (configured  using
                  <b>send-client-subnet</b>) is applied for  all  queries,  even  if  the
                  triggering query contains an ECS record, or only for queries for
                  which the ECS record is generated using the querier address (and
                  therefore  did not contain ECS data in the client query). If en-
                  abled, the address check is skipped when the client  query  con-
                  tains  an  ECS  record.  And  the lookup in the regular cache is
                  skipped.  Default is no.

           <a id="max-client-subnet-ipv6"><b>max-client-subnet-ipv6:</b></a> <i>&lt;number&gt;</i>
                  Specifies the maximum prefix length of the client source address
                  we are willing to expose to third parties for IPv6.  Defaults to
                  56.

           <a id="max-client-subnet-ipv4"><b>max-client-subnet-ipv4:</b></a> <i>&lt;number&gt;</i>
                  Specifies the maximum prefix length of the client source address
                  we  are willing to expose to third parties for IPv4. Defaults to
                  24.

           <a id="min-client-subnet-ipv6"><b>min-client-subnet-ipv6:</b></a> <i>&lt;number&gt;</i>
                  Specifies the minimum prefix length of the IPv6 source  mask  we
                  are willing to accept in queries. Shorter source masks result in
                  REFUSED answers. Source mask of 0 is always accepted. Default is
                  0.

           <a id="min-client-subnet-ipv4"><b>min-client-subnet-ipv4:</b></a> <i>&lt;number&gt;</i>
                  Specifies  the  minimum prefix length of the IPv4 source mask we
                  are willing to accept in queries. Shorter source masks result in
                  REFUSED answers. Source mask of 0 is always accepted. Default is
                  0.

           <a id="max-ecs-tree-size-ipv4"><b>max-ecs-tree-size-ipv4:</b></a> <i>&lt;number&gt;</i>
                  Specifies the maximum number of subnets ECS answers kept in  the
                  ECS radix tree.  This number applies for each qname/qclass/qtype
                  tuple. Defaults to 100.

           <a id="max-ecs-tree-size-ipv6"><b>max-ecs-tree-size-ipv6:</b></a> <i>&lt;number&gt;</i>
                  Specifies the maximum number of subnets ECS answers kept in  the
                  ECS radix tree.  This number applies for each qname/qclass/qtype
                  tuple. Defaults to 100.

       <b>Opportunistic</b> <b>IPsec</b> <b>Support</b> <b>Module</b> <b>Options</b>
           The IPsec module must be configured  in  the  <b>module-config:</b>  "ipsecmod
           validator iterator" directive and be compiled into the daemon to be en-
           abled.  These settings go in the <b>server:</b> section.

           When unbound receives an A/AAAA query that is  not  in  the  cache  and
           finds a valid answer, it will withhold returning the answer and instead
           will generate an IPSECKEY subquery for the same domain name.  If an an-
           swer  was found, unbound will call an external hook passing the follow-
           ing arguments:

                <i>QNAME</i>
                     Domain name of the A/AAAA and IPSECKEY query.  In string for-
                     mat.

                <i>IPSECKEY</i> <i>TTL</i>
                     TTL of the IPSECKEY RRset.

                <i>A/AAAA</i>
                     String  of space separated IP addresses present in the A/AAAA
                     RRset.  The IP addresses are in string format.

                <i>IPSECKEY</i>
                     String of space  separated  IPSECKEY  RDATA  present  in  the
                     IPSECKEY  RRset.   The IPSECKEY RDATA are in DNS presentation
                     format.

           The A/AAAA answer is then cached and returned to the  client.   If  the
           external  hook  was called the TTL changes to ensure it doesn't surpass
           <b>ipsecmod-max-ttl</b>.

           The same procedure is also followed when <b>prefetch:</b>  is  used,  but  the
           A/AAAA answer is given to the client before the hook is called.  <b>ipsec-</b>
           <b>mod-max-ttl</b> ensures that the A/AAAA answer given from  cache  is  still
           relevant for opportunistic IPsec.

           <a id="ipsecmod-enabled"><b>ipsecmod-enabled:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Specifies whether the IPsec module is enabled or not.  The IPsec
                  module still needs to be defined in  the  <b>module-config:</b>  direc-
                  tive.  This option facilitates turning on/off the module without
                  restarting/reloading unbound.  Defaults to yes.

           <a id="ipsecmod-hook"><b>ipsecmod-hook:</b></a> <i>&lt;filename&gt;</i>
                  Specifies the external hook that unbound  will  call  with  <i>sys-</i>
                  <i>tem</i>(3).  The file can be specified as an absolute/relative path.
                  The file needs the proper permissions to be able to be  executed
                  by the same user that runs unbound.  It must be present when the
                  IPsec module is defined in the <b>module-config:</b> directive.

           <a id="ipsecmod-strict"><b>ipsecmod-strict:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled unbound requires the external hook to return  a  suc-
                  cess value of 0.  Failing to do so unbound will reply with SERV-
                  FAIL.  The A/AAAA answer will also not be cached.   Defaults  to
                  no.

           <a id="ipsecmod-max-ttl"><b>ipsecmod-max-ttl:</b></a> <i>&lt;seconds&gt;</i>
                  Time to live maximum for A/AAAA cached records after calling the
                  external hook.  Defaults to 3600.

           <a id="ipsecmod-ignore-bogus"><b>ipsecmod-ignore-bogus:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Specifies the behaviour of unbound when the IPSECKEY  answer  is
                  bogus.   If  set  to yes, the hook will be called and the A/AAAA
                  answer will be returned to the client.  If set to no,  the  hook
                  will  not  be  called and the answer to the A/AAAA query will be
                  SERVFAIL.  Mainly used for testing.  Defaults to no.

           <a id="ipsecmod-allow"><b>ipsecmod-allow:</b></a> <i>&lt;domain&gt;</i>
                  Allow the ipsecmod functionality for the domain so that the mod-
                  ule  logic  will  be executed.  Can be given multiple times, for
                  different domains.  If the option is not specified, all  domains
                  are treated as being allowed (default).

           <a id="ipsecmod-whitelist"><b>ipsecmod-whitelist:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Alternate syntax for <b>ipsecmod-allow</b>.

       <b>Cache</b> <b>DB</b> <b>Module</b> <b>Options</b>
           The Cache DB module must be configured in the <b>module-config:</b> "validator
           cachedb iterator" directive and be compiled into the daemon with  <b>--en-</b>
           <b>able-cachedb</b>.   If this module is enabled and configured, the specified
           backend database works as a second level  cache:  When  Unbound  cannot
           find  an answer to a query in its built-in in-memory cache, it consults
           the specified backend.  If it finds a valid answer in the backend,  Un-
           bound  uses it to respond to the query without performing iterative DNS
           resolution.  If Unbound cannot even find an answer in the  backend,  it
           resolves the query as usual, and stores the answer in the backend.

           This  module  interacts with the <b>serve-expired-*</b> options and will reply
           with expired data if unbound is configured for that.  Currently the use
           of  <b>serve-expired-client-timeout:</b>  and  <b>serve-expired-reply-ttl:</b> is not
           consistent for data originating from the external cache as  these  will
           result  in  a reply with 0 TTL without trying to update the data first,
           ignoring the configured values.

           If Unbound was built with <b>--with-libhiredis</b> on a system  that  has  in-
           stalled the hiredis C client library of Redis, then the "redis" backend
           can be used.  This backend communicates with the specified Redis server
           over a TCP connection to store and retrieve cache data.  It can be used
           as a persistent and/or shared cache backend.  It should be  noted  that
           Unbound  never  removes  data  stored in the Redis server, even if some
           data have expired in terms of DNS TTL or the Redis  server  has  cached
           too  much  data;  if  necessary  the Redis server must be configured to
           limit the cache size, preferably with some kind of  least-recently-used
           eviction  policy.  Additionally, the <b>redis-expire-records</b> option can be
           used in order to set the relative DNS TTL of the message as timeout  to
           the Redis records; keep in mind that some additional memory is used per
           key and that the expire information is stored as  absolute  Unix  time-
           stamps in Redis (computer time must be stable).  This backend uses syn-
           chronous communication with the Redis server based  on  the  assumption
           that  the  communication  is  stable and sufficiently fast.  The thread
           waiting for a response from the Redis server cannot  handle  other  DNS
           queries.   Although  the  backend  has  the ability to reconnect to the
           server when the connection is closed unexpectedly and there is  a  con-
           figurable  timeout in case the server is overly slow or hangs up, these
           cases are assumed to be very rare.  If connection close or timeout hap-
           pens too often, Unbound will be effectively unusable with this backend.
           It's the administrator's responsibility to make the assumption hold.

           The <b>cachedb:</b> clause gives custom settings of the cache DB module.

           <a id="backend"><b>backend:</b></a> <i>&lt;backend</i> <i>name&gt;</i>
                  Specify the backend database name.  The default database is  the
                  in-memory  backend  named  "testframe",  which, as the name sug-
                  gests, is not of any practical use.  Depending on the build-time
                  configuration,  "redis"  backend  may  also be used as described
                  above.

           <a id="secret-seed"><b>secret-seed:</b></a> <i>&lt;"secret</i> <i>string"&gt;</i>
                  Specify a seed to calculate a hash value from query information.
                  This  value  will be used as the key of the corresponding answer
                  for the backend database and  can  be  customized  if  the  hash
                  should  not  be predictable operationally.  If the backend data-
                  base is shared by multiple Unbound instances, all instances must
                  use the same secret seed.  This option defaults to "default".

           The following <b>cachedb</b> otions are specific to the redis backend.

           <a id="redis-server-host"><b>redis-server-host:</b></a> <i>&lt;server</i> <i>address</i> <i>or</i> <i>name&gt;</i>
                  The  IP  (either  v6  or v4) address or domain name of the Redis
                  server.  In general an IP address should be specified as  other-
                  wise  Unbound  will have to resolve the name of the server every
                  time it establishes a connection to the server.  This option de-
                  faults to "127.0.0.1".

           <a id="redis-server-port"><b>redis-server-port:</b></a> <i>&lt;port</i> <i>number&gt;</i>
                  The  TCP  port number of the Redis server.  This option defaults
                  to 6379.

           <a id="redis-timeout"><b>redis-timeout:</b></a> <i>&lt;msec&gt;</i>
                  The period until when Unbound waits for a response from the  Re-
                  dis  sever.   If this timeout expires Unbound closes the connec-
                  tion, treats it as if the Redis server does  not  have  the  re-
                  quested  data,  and  will  try  to re-establish a new connection
                  later.  This option defaults to 100 milliseconds.

           <a id="redis-expire-records"><b>redis-expire-records:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If Redis record expiration is enabled.   If  yes,  unbound  sets
                  timeout for Redis records so that Redis can evict keys that have
                  expired automatically.  If unbound is configured with  <b>serve-ex-</b>
                  <b>pired</b>  and <b>serve-expired-ttl</b> is 0, this option is internally re-
                  verted to "no".  Redis SETEX support is required for this option
                  (Redis &gt;= 2.0.0).  This option defaults to no.

       <b>DNSTAP</b> <b>Logging</b> <b>Options</b>
           DNSTAP  support,  when  compiled in, is enabled in the <b>dnstap:</b> section.
           This starts an extra thread (when compiled with threading) that  writes
           the log information to the destination.  If unbound is compiled without
           threading it does not spawn a thread, but connects per-process  to  the
           destination.

           <a id="dnstap-enable"><b>dnstap-enable:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If  dnstap  is enabled.  Default no.  If yes, it connects to the
                  dnstap server and if any of the  dnstap-log-..-messages  options
                  is enabled it sends logs for those messages to the server.

           <a id="dnstap-bidirectional"><b>dnstap-bidirectional:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Use  frame streams in bidirectional mode to transfer DNSTAP mes-
                  sages. Default is yes.

           <a id="dnstap-socket-path"><b>dnstap-socket-path:</b></a> <i>&lt;file</i> <i>name&gt;</i>
                  Sets the unix socket file name for connecting to the server that
                  is listening on that socket.  Default is "".

           <a id="dnstap-ip"><b>dnstap-ip:</b></a> <i>&lt;IPaddress[@port]&gt;</i>
                  If  "", the unix socket is used, if set with an IP address (IPv4
                  or IPv6) that address is used to connect to the server.

           <a id="dnstap-tls"><b>dnstap-tls:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Set this to use TLS  to  connect  to  the  server  specified  in
                  <b>dnstap-ip</b>.   The  default  is yes.  If set to no, TCP is used to
                  connect to the server.

           <a id="dnstap-tls-server-name"><b>dnstap-tls-server-name:</b></a> <i>&lt;name</i> <i>of</i> <i>TLS</i> <i>authentication&gt;</i>
                  The TLS server name to authenticate the server with.  Used  when
                  <b>dnstap-tls</b> is enabled.  If "" it is ignored, default "".

           <a id="dnstap-tls-cert-bundle"><b>dnstap-tls-cert-bundle:</b></a> <i>&lt;file</i> <i>name</i> <i>of</i> <i>cert</i> <i>bundle&gt;</i>
                  The pem file with certs to verify the TLS server certificate. If
                  "" the server default cert bundle is used, or the  windows  cert
                  bundle on windows.  Default is "".

           <a id="dnstap-tls-client-key-file"><b>dnstap-tls-client-key-file:</b></a> <i>&lt;file</i> <i>name&gt;</i>
                  The  client key file for TLS client authentication. If "" client
                  authentication is not used.  Default is "".

           <a id="dnstap-tls-client-cert-file"><b>dnstap-tls-client-cert-file:</b></a> <i>&lt;file</i> <i>name&gt;</i>
                  The client cert file for TLS client authentication.  Default  is
                  "".

           <a id="dnstap-send-identity"><b>dnstap-send-identity:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, the server identity is included in the log messages.
                  Default is no.

           <a id="dnstap-send-version"><b>dnstap-send-version:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  If enabled, the server version if included in the log  messages.
                  Default is no.

           <a id="dnstap-identity"><b>dnstap-identity:</b></a> <i>&lt;string&gt;</i>
                  The  identity to send with messages, if "" the hostname is used.
                  Default is "".

           <a id="dnstap-version"><b>dnstap-version:</b></a> <i>&lt;string&gt;</i>
                  The version to send with messages, if "" the package version  is
                  used.  Default is "".

           <a id="dnstap-log-resolver-query-messages"><b>dnstap-log-resolver-query-messages:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable  to  log  resolver query messages.  Default is no.  These
                  are messages from unbound to upstream servers.

           <a id="dnstap-log-resolver-response-messages"><b>dnstap-log-resolver-response-messages:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable to log resolver response messages.  Default is no.  These
                  are replies from upstream servers to unbound.

           <a id="dnstap-log-client-query-messages"><b>dnstap-log-client-query-messages:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable  to log client query messages.  Default is no.  These are
                  client queries to unbound.

           <a id="dnstap-log-client-response-messages"><b>dnstap-log-client-response-messages:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable to log client response messages.  Default is  no.   These
                  are responses from unbound to clients.

           <a id="dnstap-log-forwarder-query-messages"><b>dnstap-log-forwarder-query-messages:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable to log forwarder query messages.  Default is no.

           <a id="dnstap-log-forwarder-response-messages"><b>dnstap-log-forwarder-response-messages:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Enable to log forwarder response messages.  Default is no.

       <b>Response</b> <b>Policy</b> <b>Zone</b> <b>Options</b>
           Response  Policy Zones are configured with <b>rpz:</b>, and each one must have
           a <b>name:</b>. There can be multiple ones, by listing multiple  rpz  clauses,
           each with a different name. RPZ clauses are applied in order of config-
           uration. The <b>respip</b> module needs to  be  added  to  the  <b>module-config</b>,
           e.g.: <b>module-config:</b> <b>"respip</b> <b>validator</b> <b>iterator"</b>.

           Only the QNAME and Response IP Address triggers are supported. The sup-
           ported RPZ actions are: NXDOMAIN,  NODATA,  PASSTHRU,  DROP  and  Local
           Data. RPZ QNAME triggers are applied after <b>local-zones</b> and before <b>auth-</b>
           <b>zones</b>.

           <a id="name"><b>name:</b></a> <i>&lt;zone</i> <i>name&gt;</i>
                  Name of the authority zone.

           <a id="primary"><b>primary:</b></a> <i>&lt;IP</i> <i>address</i> <i>or</i> <i>host</i> <i>name&gt;</i>
                  Where to download a copy of the zone from, with AXFR  and  IXFR.
                  Multiple  primaries can be specified.  They are all tried if one
                  fails.  To use a nondefault port for  DNS  communication  append
                  '@' with the port number.  You can append a '#' and a name, then
                  AXFR over TLS can be used and the  tls  authentication  certifi-
                  cates  will  be  checked with that name.  If you combine the '@'
                  and '#', the '@' comes first.  If you point it  at  another  Un-
                  bound  instance, it would not work because that does not support
                  AXFR/IXFR for the zone, but if you used  <b>url:</b>  to  download  the
                  zonefile  as  a  text file from a webserver that would work.  If
                  you specify the hostname, you cannot use  the  domain  from  the
                  zonefile,  because  it  may  not  have that when retrieving that
                  data, instead use a plain IP address to avoid a circular  depen-
                  dency on retrieving that IP address.

           <a id="master"><b>master:</b></a> <i>&lt;IP</i> <i>address</i> <i>or</i> <i>host</i> <i>name&gt;</i>
                  Alternate syntax for <b>primary</b>.

           <a id="url"><b>url:</b></a> <i>&lt;url</i> <i>to</i> <i>zonefile&gt;</i>
                  Where  to download a zonefile for the zone.  With http or https.
                  An  example  for  the   url   is   "http://www.example.com/exam-
                  ple.org.zone".   Multiple  url statements can be given, they are
                  tried in turn.  If only urls are given the SOA refresh timer  is
                  used  to  wait  for making new downloads.  If also primaries are
                  listed, the primaries are first probed with UDP SOA  queries  to
                  see if the SOA serial number has changed, reducing the number of
                  downloads.  If none of the urls work, the  primaries  are  tried
                  with  IXFR  and  AXFR.   For  https, the <b>tls-cert-bundle</b> and the
                  hostname from the url are used to authenticate the connection.

           <a id="allow-notify"><b>allow-notify:</b></a> <i>&lt;IP</i> <i>address</i> <i>or</i> <i>host</i> <i>name</i> <i>or</i> <i>netblockIP/prefix&gt;</i>
                  With allow-notify you can specify additional  sources  of  noti-
                  fies.   When  notified,  the  server attempts to first probe and
                  then zone transfer.  If the notify is from a primary,  it  first
                  attempts that primary.  Otherwise other primaries are attempted.
                  If there are no primaries, but only urls, the file is downloaded
                  when  notified.   The primaries from primary: statements are al-
                  lowed notify by default.

           <a id="zonefile"><b>zonefile:</b></a> <i>&lt;filename&gt;</i>
                  The filename where the zone is stored.  If  not  given  then  no
                  zonefile  is  used.  If the file does not exist or is empty, un-
                  bound will attempt to fetch zone  data  (eg.  from  the  primary
                  servers).

           <a id="rpz-action-override"><b>rpz-action-override:</b></a> <i>&lt;action&gt;</i>
                  Always use this RPZ action for matching triggers from this zone.
                  Possible action are: nxdomain, nodata, passthru, drop,  disabled
                  and cname.

           <a id="rpz-cname-override"><b>rpz-cname-override:</b></a> <i>&lt;domain&gt;</i>
                  The CNAME target domain to use if the cname action is configured
                  for <b>rpz-action-override</b>.

           <a id="rpz-log"><b>rpz-log:</b></a> <i>&lt;yes</i> <i>or</i> <i>no&gt;</i>
                  Log all applied RPZ actions for this RPZ zone. Default is no.

           <a id="rpz-log-name"><b>rpz-log-name:</b></a> <i>&lt;name&gt;</i>
                  Specify a string to be part of the log line, for easy  referenc-
                  ing.

           <a id="tags"><b>tags:</b></a> <i>&lt;list</i> <i>of</i> <i>tags&gt;</i>
                  Limit the policies from this RPZ clause to clients with a match-
                  ing tag. Tags need to be defined in <b>define-tag</b> and  can  be  as-
                  signed  to  client  addresses  using <b>access-control-tag</b>. Enclose
                  list of tags in quotes ("") and put spaces between tags.  If  no
                  tags are specified the policies from this clause will be applied
                  for all clients.

    <b>MEMORY</b> <b>CONTROL</b> <b>EXAMPLE</b>
           In the example config settings below memory usage is reduced. Some ser-
           vice  levels are lower, notable very large data and a high TCP load are
           no longer supported. Very large data and high TCP loads are exceptional
           for the DNS.  DNSSEC validation is enabled, just add trust anchors.  If
           you do not have to worry about programs using more than 3 Mb of memory,
           the below example is not for you. Use the defaults to receive full ser-
           vice, which on BSD-32bit tops out at 30-40 Mb after heavy usage.

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

    <b>FILES</b>
           <i>/usr/local/etc/unbound</i>
                  default unbound working directory.

           <i>/usr/local/etc/unbound</i>
                  default <i>chroot</i>(2) location.

           <i>/usr/local/etc/unbound/unbound.conf</i>
                  unbound configuration file.

           <i>/usr/local/etc/unbound/unbound.pid</i>
                  default unbound pidfile with process ID of the running daemon.

           <i>unbound.log</i>
                  unbound log file. default is to log to <i>syslog</i>(3).

    <b>SEE</b> <b>ALSO</b>
           <a href="/manpages/unbound/"><i>unbound</i>(8)</a>, <a href="/manpages/unbound-checkconf/"><i>unbound-checkconf</i>(8)</a>.

    <b>AUTHORS</b>
           <b>Unbound</b> was written by NLnet Labs. Please see CREDITS file in the  dis-
           tribution for further details.



    NLnet Labs                       Aug 12, 2021                  unbound.conf(5)
    </pre>