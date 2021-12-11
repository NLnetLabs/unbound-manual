DNSSEC Algorithms with Unbound
==============================


Unbound validates DNSSEC signatures and in the case that there are
multiple signature algorithms in use, it checks that a valid chain of
trust exists for each algorithm separately.  Thus the algorithms that are
in use must all be subverted before validation can be misdirected.

Algorithms in the Chain of Trust
--------------------------------

The algorithms that are checked are signalled via the DS RRset.  This
means that zones do not receive these checks until they publish multiple
algorithms into their DS set.  Thus the set of algorithms present in
the DS RRset must have DNSKEYs and signatures on every data element.

The RFCs already mandate that for algorithms signalled to be in use for a
domain you must have DNSKEYs and signatures on every data element, because
a validator is allowed to continue the chain of trust if it supports one
algorithm but not the others.  These validators that support one of the
algorithms must find that the algorithm signalled to be present has keys
and signatures, and if these are missing, will conclude that signatures
have been 'stripped' away.  The extra checks that unbound performs thus
must succeed if the domain is properly signed and all signatures are
present.

There is some leeway when signing a domain, and this leeway is useful when
changes are phased in.  The DNSKEY may contain more algorithms, perhaps as
part of a rollover.  The data may be signed with other algorithms as well.
It is possible to have DS records for which no key exists, as long as
another DS record for that algorithm has a key.  It is possible to have
DNSKEY records that do not sign any or only part of the data (as long
as signatures are available via other DNSKEYs).

Change in algorithms is possible by introducing keys in the DNSKEY set,
and signing with them, and once complete, introducing the DS record.
The reverse, first with the takeown of the old algorithm DS records, for
removal of a signing algorithm.  Older versions of unbound did not allow
introduction of a new algorithm key in the DNSKEY set if the signatures
on the data were not already present, but newer (since 1.4.8) versions
allow this (and rely on the algorithms signalled in the DS RRset).

Protection
----------

The check for multiple algorithms protects against not-known-today
algorithmic weaknesses in one algorithm by using the other algorithm.
This assumes the (mathematical) properties of the algorithms
are dissimilar and that any deficiencies are not discovered
simultaneously.

So, for example, RSASHA1 and RSASHA1_NSEC3 is a poor choice in this
regard, as the algorithms are identical (the algorithm identifier is used
to signal NSEC3 support here, which was useful during the introduction
of NSEC3).  Also the use of multiple keys only protects like the largest
one.

Trust Anchors
=============

Trust anchors can provide multiple algorithms, if a trust anchor
contains multiple algorithms, a valid chain of trust is checked for them.
Similar, if a RFC5011 automated key state contains VALID (or MISSING)
keys with multiple algorithms, these algorithms are checked. For RFC5011,
key revocation is checked and performed before the other checks in the
RFC5011 state table when processing a DNSKEY probe, to make algorithm
rollover possible (specifically the removal of the last key for the old
algorithm).
