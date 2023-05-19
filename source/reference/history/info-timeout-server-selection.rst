Unbound Timeout and Server Selection Information
================================================

Introduction
------------

Unbound sends requests upstream to the authority servers on the internet
and these requests can timeout.  These timeouts have to be handled.
Either the request has to be sent to another server, or resent.  And the
responsiveness of the destination server has to be kept track of.

The handling of timeouts is complicated by conflicting requirements.
If a server is down and not responding, continuation of sending packets
is a waste of resources.  These resources are typically the time spent
waiting, the socket and port number, and request list entry that are
used during that time.  But if the server was down briefly, and has
come up, then it is important to detect this quickly.  Especially in
cases where the timeout involves a high traffic destination (say,
the local organisation's own domain), then it is especially pressing,
and the domain must not be blocked for hours.

Unbound has several different regimes that can be distinguished.
These are described separately for explanatory purposes, in the code
the mechanisms all operate together.

Normal Operations
-----------------

In the normal case, requests and replies are flowing like they should.
Unbound has to set a timeout because UDP is an unreliable transport
mechanism and a packet may get lost once in a while.  To do this, it
keeps a roundtrip time estimate and performs exponential backoff.

The timeout is measured in milliseconds and is kept per IP-address (so,
not by host name but by host address).  This is stored in the infra-cache.
The infra-cache can be configured in the max-number of elements it
stores, and the TTL (time to live) of the elements inside the cache.
By default elements exist for 15 minutes in the infra-cache.

The fastest server (randomly picked within a so-called RTT band of 400
msec) is selected when a query has to be sent out.  The roundtrip-timeout
(``rtt``) is used for selection purposes.  This is the value of
the timer that would be set if the packet is sent out.  When this timer
expires, the packet is considered timed-out.  If nothing is known about an
IP-address a timeout of 376 msec is assumed.  This assumed timeout should
be successful for most traffic.  The 376 is chosen to fall within the 400
msec rtt band and it is also a reasonable value (many pings fall in it)
while still allowing several resends within about a single second.

When packets return successfully from the remote server, the ping-time is
used to update the estimate of the roundtrip timers.  A smoothed average
roundtrip time is kept, that can keep track of a slow change towards
a new average.  Also a smoothed variation measure is kept, that keeps
track of the jumps in the times observed.  And when a timeout happens the
exponential backoff is kept track of.  Exponential backoff means that
the roundtrip timeout is doubled for every next packet.  These values
are stored in the infra-cache and return to their defaults when the TTL
expires on the element for that IP address.

If a timeout occurs, the packet is considered lost and the cache is
updated by doubling the timeout to apply for the next packet.  Server
selection is performed again, and will likely pick another server to
send to.  If the server was very fast, then it may be picked again since
the doubled value is still very small.  But if the server gets slower,
it will no longer be preferred and traffic is sent to another server
for that domain.

If a server is selected again, the same query can be sent again to the
same server, but now with a larger timeout.  Unbound no longer listens
or wants to receive a reply to the timed-out queries at that point.
This is because listening to multiple outstanding versions of the same
query sent to a server creates a (small) birthday paradox.  And this is
avoided for cache-poison resistance reasons.

If many requests are sent to a destination server at the same time,
then a short interruption could cause many of them to timeout at about
the same moment.  This would, with exponential backoff, result in an
almost infinite backoff to be applied.  Therefore some race-condition
protection is applied.  The timeout in the infra-cache is increased to
double the original value that the query was sent out with.  Thus if
the doubling has already been applied by another failed packet, it is
not applied again. The doubling is only done if the timeout stored is
between the original value and its double.  So that if another query
has already succeeded and lowered the value in the cache then this is
left as-is, since traffic is flowing again.

In normal operations, many threads can have many packets outstanding to
an IP address, all at the same time.  The infra-cache data is shared between
threads.

Probing
-------

When a domain starts to become unresponsive, it is probed.  In this regime
only one request is allowed to probe to a particular IP.  This conserves
resources, as other requests are turned away, and do to not use up
port-numbers, sockets and requestlist elements.  Also it lowers the
traffic towards the destination (that is apparently having trouble),
which may help it get back up.

An IP address is in the probing regime if it fits the following criteria.

- The timeout (with exponential backoff applied) exceeds 12 seconds
- Two (or more) consecutive exponential backoffs have just been done on it

These conditions can not be configured.  They mean that the query has
just had two timeouts, and it is already very slow (12 seconds timeout).
If it normally has a timeout that is high, say 10 seconds, then the
timeout has to reach 40 seconds before this restricted regime applies.
If it is normally very fast, then normal operations continue for about 24
seconds (because of exponential backoff, the total time for the timeouts
in sequence).  For queries that normally take about 100 msec or so, about
6 timeouts have to happen before it hits a 12 second timeout.

In this regime, when a probe request is sent to the destination IP
address, the ``exclusion time`` until another probe can be
allowed is stored.  This is the current time plus the timeout for this
packet plus one (see below about the plus one).  Other queries are not
sent to this IP address until that time.

The exclusion time is stored in the infra-cache.  This means that it is
shared by the threads.  So normally, one request can probe at a time.
In some cases, the code can allow a small window of opportunity and
multiple probes, one per thread, happen at the same time.  This only
happens when traffic it very large towards that domain and is otherwise
harmless.

When the probe is done and is it successful - so an answer came back -
then the roundtrip estimates are updated with this new observation.
And the IP address is put back into normal operations.  Many queries
are allowed to the destination server.

When the probe is done but it was a timeout, the exponential backoff
is increased.  And the probe query tries to select a new server for that
domain to send to.  But because of the plus-one on the exclusion timer,
is now excludes itself from sending to that server again.  It may probe
another IP-address for the same DNS domain at that time, but not the
same one right away.

This self-exclusion generates some useful effects.

- If there is very little traffic towards an affected domain, then
  a single request will slowly probe the different servers (if there
  are multiple servers, otherwise, with one server only, it will give
  up quickly).
- If there is a moderate amount of traffic towards an affected domain,
  then several requests will probe, each picks up a different IP address and
  probes one time. But because they all arrive randomly the exclusions mean
  every request performs usually one probe only as the other servers are
  (being) probed by other requests when it finishes probing an IP address.
  And there is a little wait before a new query comes in to probe a new
  server, in that time an already probing query is allowed to probe this
  IP address again.  When another request comes in, probing the servers
  continues.  Thus there are some queries probing one (or some more)
  different IP addresses, but not all IP addresses are probed at the
  same time.
- If there is high traffic towards an affected domain, then requests
  are always available as soon as the exclusion ends.  Thus all the servers
  for that domain are probed at the same time, each server receives one
  query at a time.  The requestlist contains an element for every server
  to probe.

If more requests arrive at the server than can be used for probing,
these are turned away.

When a request is turned away because the servers are probed and this
request did not attain probe status, then it gets the DNS error code
SERVFAIL.  These requests do enter the requestlist, but do not use a
socket or a port number, as they get an error reply when it finds out
that no servers are available to send packets to.

Another effect is that once a query is excluded from all currently known
servers for a domain, the fallback mechanism to handle misconfigured
domains is activated.  This searches for additional servers that may
respond for this domain name.

In the probe regime, IP addresses that are becoming unresponsive are
probed by single requests and other requests are turned away.  At some
point the exponential backoff becomes too large and it seems useless to
send further traffic to that server.

Blocking
--------

In the blocking regime, the timeout reached 120 seconds and further
requests towards the server seem useless.  All requests are turned
away and receive SERVFAIL (unless another working server exists for
that domain).

Requests do enter the requestlist, briefly, but when it turns out all
servers are unresponsive, it is turned away with the error SERVFAIL.

This condition is cached in the infra-cache element for that IP address.
The elements in the infra-cache live for infra-ttl seconds (15 minutes
by default).  When this TTL (time to live) expires, then the domain is
probed again.

Performing the full probe sequence would take about 240 seconds (sequence
of exponential backoffs until it is 120 seconds).  With a 15 minute time
to live, this is a bit excessive, especially if normal operations resumes
and many resources are expended on this likely-unresponsive server.
Therefore only a single probe packet is sent if the infra-ttl has expired.
If that probe fails, then the server is blocked for another infra-ttl.

The result is that a server is probed with one packet every 15 minutes.
If it succeeds, all traffic is allowed again (normal operations),
and if it fails, the next probe is sent after blocking the server for
15 minutes.  So if a server comes back up, this is observed within
infra-ttl seconds.  If a server does not respond, it is probed every
15 minutes, but only if there are queries to send to it.

The way the code works means that if an ``expired`` infra-cache
element exists, and it says the address was blocked, then a single
probe is performed.  Such expired entries can exist until the cache runs
out of memory and flushes elements out to make space for new elements,
the infra-cache uses the LRU cache-algorithm for that.  Servers for a
domain for which very little queries are received, do not get probes
sent to them, and when finally a query arrives for it, a single probe
is done so as to not squander resources.

Control
-------

The timeout behaviour can be controlled and configured.

The configuration consists of the size of the infra-cache (please allow
sufficient elements to store information about IP addresses).  And the
infra-ttl time can be configured.  By setting the infra-ttl lower,
unbound will probe servers that are not responsive more aggressively.

The ``unbound-control`` tool can be used to interact with the
running server.  It can provide information and flush cache entries.
The ``flush_infra`` command can be used to flush all of the cache
or particular elements.  The ``lookup`` command shows status for
the servers associated with a particular domain.  The ``dump_infra``
command dumps the entire contents of the infra-cache, a snapshot of the
ping-times of the servers on the internet that unbound has contacted.

The output of a ``lookup`` command can look like this:

.. code-block:: bash

    $ unbound-control lookup nlnetlabs.nl
    The following name servers are used for lookup of nlnetlabs.nl.
    ;rrset 9911 3 1 7 3
    nlnetlabs.nl.	9911	IN	NS	omval.tednet.nl.
    nlnetlabs.nl.	9911	IN	NS	open.nlnetlabs.nl.
    nlnetlabs.nl.	9911	IN	NS	ns3.domain-registry.nl.
    nlnetlabs.nl.	9911	IN	RRSIG	NS 8 2 10200 20101129015003
    	20101101015003 42393 nlnetlabs.nl. H28rD+MVEYWYm5aceRHg
    	rf4gkLplnPhJjeYG5tKc quzyAUtQv2/IfQWDbKWz wdGGwhwFIF91Fio9ogAm
    	2UrukBtE5Z7LAp1D0ZUZ uqnbWCsXXYcpayHDO3t T3oCd73JPChm5nPlw+NU
    	VmqGWpSP8/4MoDsgPYdR 88MK2NdqZ0F8= ;{id = 42393}
    ;rrset 177 1 0 8 0
    ns3.domain-registry.nl.	177	IN	A	193.176.144.6
    ;rrset 177 1 0 8 0
    ns3.domain-registry.nl.	177	IN	AAAA	2a00:d78:0:102:193:176:144:6
    ;rrset 5399 1 1 8 3
    open.nlnetlabs.nl.	5399	IN	A	213.154.224.1
    open.nlnetlabs.nl.	5399	IN	RRSIG	A 8 3 10200 20101129015007
    	20101101015007 42393 nlnetlabs.nl. noDw4tW3WSEphAj8eXtg
    	aiqt4qNBD3KFvFjv+rss iW/QYkKjxDl7j2xPGLWY pTk1XdWa21k0xYTpgshA
    	3vh9JB69FCfwHnuxIC/o Ksy6g43TIOmOYuENaOIs OZ8MwvrHuGpLxjUo5QPq
    	rQO/yuVz5pgFFsSScJwZ ZiYQSjwfTBU= ;{id = 42393}
    ;rrset 5399 2 1 8 3
    open.nlnetlabs.nl.	5399	IN	AAAA	2001:7b8:206:1::53
    open.nlnetlabs.nl.	5399	IN	AAAA	2001:7b8:206:1::1
    open.nlnetlabs.nl.	5399	IN	RRSIG	AAAA 8 3 10200 20101129015007
    	20101101015007 42393 nlnetlabs.nl. ZXSeWEgkY4xhEwlDdTsj
    	FM12r31L/MMQYaDFeGki YTUeWJRFzGa4w3+A+FHp mibdVKuscGTuPWtsP2zE
    	29u6ClcW0NDM+KfbEV+D zUYH88f7P1qs1sZSKGJL owxzREKDVF1t5iThVLIZ
    	l49aD/mL97eNJ60Ybwov nsoFVuEt5Ao= ;{id = 42393}
    ;rrset 18042 1 0 8 3
    omval.tednet.nl.	18042	IN	A	213.154.224.17
    ;rrset 18042 2 0 8 3
    omval.tednet.nl.	18042	IN	AAAA	2001:7b8:206:1::17
    omval.tednet.nl.	18042	IN	AAAA	2001:7b8:206:1:200:39ff:fe59:b187
    Delegation with 3 names, of which 0 can be examined to query further addresses.
    It provides 8 IP addresses.
    2001:7b8:206:1:200:39ff:fe59:b187	not in infra cache.
    2001:7b8:206:1::17	not in infra cache.
    213.154.224.17  	not in infra cache.
    2001:7b8:206:1::1	rto 284 msec, ttl 860, ping 0 var 71 rtt 284, EDNS 0 probed.
    2001:7b8:206:1::53	rto 164 msec, ttl 420, ping 0 var 41 rtt 164, EDNS 0 probed.
    213.154.224.1   	rto 72 msec, ttl 130, ping 0 var 18 rtt 72, EDNS 0 probed.
    2a00:d78:0:102:193:176:144:6	not in infra cache.
    193.176.144.6   	rto 230 msec, ttl 105, ping 2 var 57 rtt 230, EDNS 0 probed.

Some servers are listed as not in the infra-cache.  For the ones in the
infra-cache, the rto (roundtrip timeout with exponential backoff applied)
is printed, and the ttl of the infra-cache element.  Also the ping-time
(the smoothed roundtrip time) is printed (in msec) and the variability
(in msec), the roundtrip timeout without exponential backoff (rtt)
is also printed (in msec).  The infra-cache also contains EDNS status
and lameness information which is also shown.  In the above example,
the ping time is very low as most servers are on the same subnet.

.. code-block:: bash

    192.0.2.1 ttl 316 ping 0 var 94 rtt 376 rto 120000 ednsknown 0 edns 0 delay 0

The ``dump_infra`` command produces similar output.  Here is
an example (only a single line from the very long output) that shows a
blocked entry.  The 120 second rto means it is blocked.  The rtt of 376
(still at the assumed default), leads us to assume it never replied.
192.0.2/24 is a netblock for documentation purposes and not deployed on
the internet, hence no replies.

Summary
-------

Unbound implements timeout management with exponential backoff and keeps
track of average and variance of the ping times.  If a server starts to
become unresponsive, a probing scheme is applied in which a few queries
are selected to probe the IP address.  If that fails, the server is
blocked for 15 minutes (infra-ttl) and re-probed with one query after
that.

Queries that failed to attain probe status, or if the server is blocked
due to timeouts, get a reply with the SERVFAIL error.  Also, if the
available IP addresses for a domain have been probed for 5 times by a
query it is also replied with SERVFAIL.  New queries must come in to
continue the probing.

The status of an IP address can be looked up and flushed.  The infra-cache
is not flushed on a reload, so the list of blocked sites and ping times
is not wiped.  If you wish to remove it the ``flush_infra``
control command can be used.
