.. _doc_privacy_aggressive_nsec:

Aggressive NSEC
===============

Unbound has implemented the aggressive use of the DNSSEC-Validated cache, also
known as *Aggressive NSEC*, based on :RFC:`8198`.

Introduction
------------

DNS relies heavily on caching. A lot of performance can be gained by storing
answers to previous queries close to the client. If an authoritative name server
would have to be queried for every single request, performance would be severely
impacted.

In addition to caching the positive answer to queries, negative answers are also
cached. These negative answers are an acknowledgement from the name server that
a name does not exist (an answer with the response code set to NXDOMAIN) or that
the type in the query does not exist for the name in the query. The latter is
known as an answer with the NODATA pseudo response code, as specified in section
1 of :RFC:`2308`.

Generating NODATA Answers
-------------------------

The traditional Unbound cache implementation is based on exactly matching cached
messages to the query name, query type and query class. If a client asks for a
*TXT* record for ``example.net``, the resolver will search the cache and if that
fails go and look up the answer at the authoritative name server. This query to
the authoritative name server will result in a response containing the existing
*TXT* record. If the resolver now receives a query for the same name but for the
*TLSA* type, the resolver will check its cache, in this case can not find a
matching record in the cache and will, as a result, send a query to the
authoritative name server. That name server will now reply with a NODATA answer,
indicating that the ``example.net`` name does exist, but there is no record for
that name with the TLSA record. A third query for the same name for another
non-existing type, for example *SRV*, will once again not result in a cache hit
and will generate yet another query with again a NODATA answer as result.

In this example the ``example.net`` zone is DNSSEC signed. This means the
absence of these records need to be proven using NSEC (next secure) records.
NSEC records indicate which types exist for a name and which names exist in a
zone. NSEC records have a cryptographic signature which make them tamper proof.
By knowing the existing record and types in a zone, a DNSSEC validator can prove
that the combination of query name and query type indeed does not exist.

The NODATA answer for the ``example.net`` name with the *TLSA* query type could
for example contain this NSEC record:

.. code-block:: text

  example.net. 3600 IN NSEC !.example.net. A NS SOA MX TXT AAAA NAPTR RRSIG NSEC DNSKEY

This record proves which types exist for ``example.net`` (*A, NS, SOA* etc.)
and thereby proves that the *TLSA* record indeed does not exist. The NODATA
response to the third query in above example (the *SRV* query for
``example.net``) will contain exactly the same NSEC record to prove the absence
of the *SRV* record. Because this NSEC record was already cached after the
lookup for the TLSA record we could have used that already obtained NSEC record
to generate a DNSSEC secure answer, without the need to send another query to
the authoritative name server.

The feature to use already cached NSEC records to generate responses can be
enabled in Unbound using the *aggressive-nsec* option in unbound.conf:

.. code-block:: text

  aggressive-nsec: yes

Generating NXDOMAIN Answers
---------------------------

An answer with the NXDOMAIN response code indicates that a name does not exist
at all, which is also proven using an NSEC record. If ``example.net`` would
contain these alphabetically sorted records (some simplification ahead):

.. code-block:: text

  example.net.           IN SOA [..]
                         IN NS alfa.example.net.
  alfa.example.net.      IN A 198.51.100.52
  sierra.example.net.    IN A 198.51.100.98

then DNSSEC would make sure these NSEC records are inserted and signed:

.. code-block:: text

  example.net.         IN NSEC alfa.example.net.   NS SOA DNSKEY
  alfa.example.net.    IN NSEC sierra.example.net. A
  sierra.example.net.  IN NSEC example.net.        A

They attest that no name exists between ``alfa.example.net`` and
``sierra.example.net``. So if you query for ``lima.example.net``, you
will get back the NXDOMAIN from the authoritative name server, as well as the
NSEC record for ``alfa.example.net`` — ``sierra.example.net`` as proof
that the query name does not exist and the NSEC record for ``example.net`` —
``alfa.example.net`` as proof that the ``*.example.net`` wildcard record
does not exist.

If the user now queries for for ``delta.example.net``, resolvers would normally
ask the authoritative server again because there is no message cached for that
name. But because the NSEC records for ``alfa.example.net`` —
``sierra.example.net`` and ``example.net`` — ``alfa.example.net`` are already
cached, the implementation of :RFC:`8198` will allow Unbound to deduce that it
doesn’t need to send a new query. It is already able to prove that the name
doesn’t exist and immediately, or *aggressively* if you will, returns an
NXDOMAIN answer.

Generating Wildcard Answers
---------------------------

There is one more type of message that can be generated using cached NSEC
records, namely wildcard answers. A DNSSEC validator only accepts a wildcard
answer when there is proof that there is no record for the query name. When we
have this zone containing a wildcard record:

.. code-block:: text

  example.net.          IN SOA [..]
                        IN NS alfa.example.net.
  *.example.net.        IN TXT "A wildcard record"
  alfa.example.net.     IN A 198.51.100.52
  sierra.example.net.   IN A 198.51.100.98

then a TXT query for ``delta.example.net`` will be answered with the following
records, indicating that there is no direct match for the query name but that
there is a matching wildcard record:

.. code-block:: text

  ;; ANSWER SECTION:
  delta.example.net.    IN TXT "A wildcard record"
  delta.example.net.    IN RRSIG TXT 8 2 [..]

  ;; AUTHORITY SECTION:

  alfa.example.net.     IN NSEC sierra.example.net.   A

The ``alfa.example.net`` — ``sierra.example.net`` NSEC record indicates that
there is no ``delta.example.net`` record. The labels field in the signature
indicates that the returned TXT record is expanded using the ``*.example.net``
record.

Unbound uses this knowledge to store the wildcard RRset also under the original
owner name, containing the wildcard record, when aggressive use of NSEC is
enabled. After receiving a query for ``echo.example.net`` Unbound finds the
NSEC record proving the absence in its cache. Unbound will then look in the
cache for a ``*.example.net`` *TXT* record, which also exists. These records
are then used to generate an answer without sending a query to the name server.

.. Note:: Aggressive NSEC can result in a reduction of traffic on all levels of
          the DNS hierarchy but it will be most noticeable at the root, as
          typically more than half of all responses are NXDOMAIN.

          Another benefit of a wide deployment of aggressive NSEC is the
          incentive to DNSSEC sign your zone. If you don’t want to have a large
          amount of queries for non-existing records at your name server,
          signing your zone will prevent this.
