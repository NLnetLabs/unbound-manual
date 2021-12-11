Unbound Operation Explained in Book
===================================

*Authored December 2008.*

We received a complimentary book by `Jan-Piet Mens <https://jpmens.net/>`_
today, titled `Alternative DNS Servers
<https://jpmens.net/2010/10/29/alternative-dns-servers-the-book-as-pdf/>`_. It
covers a whole host of DNS servers, including NSD and Unbound.

The book describes how to set up DNS servers and how to operate them. I found
the section on Unbound to be fine (also NSD is fine).  I cannot comment on the
other products.

One section stood out as it has a performance comparison of the servers. The
book has more details, below is one line of results.  Here 10 queryperf machines
query a DNS cache, and the average queryperf performance is noted. So the cache
is doing 10x the number noted.  The figures show similar results to what we find
for performance comparisons in the NLnet Labs testlab. The results below have
been found independently, and compare a greater number of products.

================= ==
Server            Queries/sec (10 clients)
================= ==
MaraDNS           3 068
BIND              3 003
dnscache          2 928
PowerDNS Recursor 2 074
Unbound           8 276
================= ==

The book reviews unbound version 1.0, and the config and operation is the same
as 1.1 which was recently released. `Unbound 1.1
</projects/unbound/download/#unbound-1-1-0>`_ has DLV support and improved
statistics, which may be of interest.
