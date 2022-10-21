Unbound 1.0.2 Patch Announcement
================================

Summary
-------

Unbound version 1.0 was released with port randomization features. The
same features that have been made available in the various patches by other
vendors the CERT alert last month.

Now Dan Kaminsky disclosed more details during the the august 2008
Blackhat Conference in Las Vegas we release additional counter measures. 
These
counter measures were previously withheld in order to minimize the risk of
disclosing details about several variations of the attack through reverse
engineering.

With the current set of counter measures added, Unbound offers state of the art
protection against the attacks described by Kaminsky. However, state of the
art counter measures will not provide full protection, not in Unbound nor
in other software. Although DNSSEC is hardly deployed, it is currently the only
mechanism known to deal with spoofing and other kinds of attacks on the DNS.

More details in the ways that Unbound protects against spoofing are below.

What is Cache Poisoning
-----------------------

Poisoning a DNS resolver refers to the act of inserting fake, often
malicious data into the resolvers cache.  This can cause website visitors
to be redirected from the site (e.g. their banking site) they thought
to visit to a different web site, for example a phishing site.

The basic approach of poisoning DNS queries is to send fake replies that
pretend to come from the authority servers to the caching resolver.
Every DNS query carries a random query Identifier (16 bit number).
Only replies that contain the same number are accepted. In order for
the resolver to accept the fake replies, the Identifier in the incoming
packet needs to match that of the outstanding question.  That is, the
attacker has to guess a number of 16 bits in length.

One can calculate the time how long it takes to guess the 16 bits Identifier.
a detailed calculation can be found online (`draft-ietf-dnsext-forgery-resilience
<http://tools.ietf.org/html/draft-ietf-dnsext-forgery-resilience-06>`_).
The document contains formulas with all the variables involved.  
The example given in the draft has a 4 Mb/s attack rate to get a 50% chance 
to inject the fake data.

It comes down to this: it takes a certain time, on average, to guess the
right random sequence.  The example in the reference argues that the 
Kaminsky exploit takes about 10 seconds to guess the 16 bit value in the
identifier.  This is confirmed by implementations of the exploit as well
as various calculations on public mailinglists.

In order to extend the time by which a packet can be succesfully replaced we
need more than the 16 bits of random number that the query Identifier provides
us. That can be done by putting random numbers in other parts of the query, 
and checking if the server puts the same number in a reply, 
without changing the protocol.  It is hard to add these extra random
numbers without breaking interoperability, because the reply is only 
defined to contain a copy of the 16 bit
ID value.  Once an extra random number is copied into the reply, a fake
reply must guess that number.  Every extra bit that needs to be guessed,
increases the time by a factor of 2.  The goal is to add enough extra
bits that the chance of poisoning becomes very low (on average).

Unbound implements a number of methods to add random bits.  The most
important means to add randomness is to vary the port numbers from which
the question is asked, another means is to use a hack that randomizes
unused bits in the query name. Unbound implements even more methods.
In addition, Unbound is careful in what to accept as information that
can be cached. These techniques are explained in more detail below.

Note however that the increase in the amount of bits does improve your 
chances to safely cross the road but a bad packet may still hit you.

Real protection, where you are not subject to the whims of chance, is
achieved by using DNSSEC.  DNSSEC uses digital signatures to protect
the data.  With DNSSEC there is no chance of poisoning, independent of
the number of random bits used.

Unbound Security
----------------

Unbound implements the DNSSEC standard as specified in :rfc:`4034` and
:rfc:`4035`. This means that it can act as a validator and can thus check the
digital signatures attached in replies.  Of course, the domain name owner must
have inserted these digital signatures in the first place. 

In the absence of DNSSEC, unbound attempts to provide very good security.
Without digital signatures, randomisation and filtering are currently the only
options.  Below, a technical categorisation is made of the methods employed by
unbound to protect unsigned data.

Filtering
---------

Unbound contains a component we call a 'scrubber'.  This component 
takes care of certain checks, disallowing (removing) possibly malicious content.

- Only in-bailiwick data is accepted
- RFC 2181 trust is employed.  This means that data from the additional
  section receives an additional section trust.  And data from the answer
  section receives answer section trust.  Data with additional section trust
  is not used to answer queries from clients.  Thus putting a record in
  the additional section cannot make this record appear to clients.
- The records in the authority and additional section are filtered 
  for relevance to the query in question.  If the data is irrelevant, it 
  is removed.
- The answer section is filtered for relevance.  Only answers to the query
  that unbound wants to ask are allowed.
- CNAME chains are cut off, only the first CNAME is kept as answer.  The 
  remaining CNAMEs or answer records are not kept, but looked up instead.
- For DNAME records, the CNAME is synthesized by unbound itself, it does
  not trust the server to do so.
- DNAME records are not taken from the cache to perform the redirection,
  even if they seem to match.  Only for validated DNAME records (where the 
  digital signature was correct) is redirection performed from cache, this
  requires the use of DNSSEC.

Randomisation
-------------

By adding more random data, a spoofed reply has to guess more data to 
get through, lowering the chances of a successful poison attempt.

- Strong random number generator.  Unbound uses a cryptographic strength
  random number generator.  The arc4random() generator from OpenBSD is used.
  This means that predicting the random numbers generated by unbound is
  equivalent to cracking an encryption cipher.
- The random number generator is seeded with entropy.  Real entropy from the
  system /dev/random is used to seed the random number generator.  Thus, the
  starting values of the random number generator cannot easily be predicted.
- Query ID bits.  Unbound uses all 16 bits in the ID.  
- Port randomisation.  Unbound uses 16 bits for the port randomisation.
  To be precise, about 60000 random ports, avoiding ports below 1024 and 
  avoiding IANA allocated UDP ports to avoid system instability of the server.
  The port randomisation uses the same random number generator as the ID.
  Unbound takes care that a randomly drawn port is used for one query.  Thus
  every query gets a freshly random port number.
- Destination address randomisation.  Unbound performs RTT banding, a method
  to select the destination server that provides additional randomness.
  This provides between 1 and 4 bits of randomness.  Perhaps 2 on average.
  Arguments that choosing the fastest destination reduces the attack time
  window are no longer relevant given the recent full disclosure at the
  Blackhat conference. Additional time windows are easily achieved.
- Source address randomisation.  If configured with multiple public IP 
  addresses, unbound can perform a random choice of interface.  This needs
  operator configuration, but by adding 4 outgoing-interface statements in
  the config file, an additional 2 bits of randomness are achieved.
- Transport protocol randomisation.  If IPv6 is available (yes, yes, not
  very common), then unbound will obtain another random bit by choosing the
  IPv4 or IPv6 transport protocol randomly.
- Query aggregation.  This prevents identical outstanding queries to the 
  same server.  It prevents birthday-paradox attacks.
- Query name strict matching.  This prevents an answer from matching a query
  for which it is not meant.  If an answer can match multiple queries, you
  get the birthday paradox attack again (from the previous item).
- Capitalisation randomisation.  Also called dns-0x20.  This is an 
  experimental resilience method that uses upper and lower case letters in the
  question name to obtain randomness.  On average about 7 or 8 bits.  This
  method currently has to be turned on by the operator manually, as it may
  result in maybe 0.4% of domains getting no answers due to no support on the
  authoritative server side.

Additional security measures
----------------------------

These measures are mostly to prevent remote execution exploits.

- Heap function pointer protection
- chroot() by default
- user privileges are dropped by default
- access control list for clients that are allowed recursion
- No detection of attacks underway. Unbound assumes it is always under attack
- can config the version.bind or hostname.bind answer to return, or block the queries

Randomness Calculation
----------------------

So the default setup has a randomness of::

    16 bits ID
    16 bits port
    2 bits destination address (estimated average).

For a total of 34 bits of randomness.
Other implementations provide 16 bits (or less) unpatched, 
26 bits for patches utilizing only 1024 ports and 32 bits for patches using
the fully available port range (around 60k). Unbound has been utilizing the
full port range of about 60.000 ports since the release of version 1.0.

With a careful setup, enabling capitalisation and source address randomisation
Unbound provides::

    16 bits ID
    16 bits port
    2 bits destination address (estimated average)
    2 bits source address (estimated average)
    8 bits capitalisation (estimated average).

in total 44 bits of randomness.

Sample config file items to enable this amount of randomness:

.. code-block:: bash

    server:
        # configures 4 static public IP addresses.
        # you can also enter IPv6 if you have it.
        # this is an example, you must enter your addresses.
        outgoing-interface: 192.0.2.1
        outgoing-interface: 192.0.2.2
        outgoing-interface: 192.0.2.3
        outgoing-interface: 192.0.2.4
        # enable dns-0x20.
        use-caps-for-id: yes

Time to infection
-----------------

We take 10 seconds to infect an unpatched server with 50% chance
as a baseline. The table below shows the time until a poison attempt
is successful.  The numbers are subject to being guesstimates.  Better
numbers may become available, either from the Blackhat presentation,
or other sources.  The bottom line is that adding randomness is a short
term fix.

==== ========== =========== =====
Bits 50% chance 5% chance   Aka
==== ========== =========== =====
16   10 seconds 1 second    unpatched server, random ID
26   2.8 hours  17 minutes  patched, using only 1024 ports
34   28 days    2.8 days    unbound using defaults
44   28444 days 2844.4 days unbound with capitalisation and source addresses configured \*
==== ========== =========== =====

    *\* : These are not enabled by default. The capitalisation has not been
    standardised, and could result in a small number of cases in slow or no
    answer. The source addresses need the operator to configure multiple addresses
    for the computer.*

In the table above, the Bits column shows the number of random bits that
are echoed in replies. The 50% chance column shows the length of time needed
before an attack has a 50% chance of success (guessing the random numbers). 
The 5% chance column shows how long it takes before an attack has a 5% chance
of inserting fake data.

Note: 60000 sockets not 65536 sockets used randomly for unbound is assumed
in the table entries for unbound. Unbound avoids some port numbers for
compatibility.

Also note that the table above assumes a fairly low bandwidth usage.
If a large network capacity is available, say a botnet, and it can use
1000x more resources, then perhaps also the attack can be conducted
1000x faster.

In the meeting of the IETF dnsext working group successful poisoning attacks
against an unpatched server in as little as 1/10 of a second were demonstrated
easily (`demo results
<http://www.ops.ietf.org/lists/namedroppers/namedroppers.2008/msg01193.html>`_),
showing that much smarter things can be done than the dumb attack assumed for
the numbers here.  Calculations by members of the working group showed a near
perfect chance for 6-8 seconds.  This could move the figures to be less
optimistic.

Keep in mind that the thousands of days shown for unbound with capitalisation
and source addresses configured should not be taken as strong security.  It is
likely that some measures can be outsmarted. Or that these numbers are overly
optimistic (see text above).  And the 44 bits is an average.  If an attacker can
work out how to attack domains or queries with less protection, the the benefits
may be partially lost. Thus, the large time listed for 44 bits should be taken
as an indication that it is pretty good, but not invulnerable.

As stated earlier, the real solution is to use DNSSEC.  DNSSEC makes this time
table a non problem, because in all these cases DNSSEC can detect the forgery.
Especially users in Brazil, Bulgaria, Puerto Rico and Sweden or people using
these zones regularly, should consider turning on DNSSEC because the TLD zone is
DNSSEC secured.  Do consider using the DNSSEC capabilities in Unbound.
