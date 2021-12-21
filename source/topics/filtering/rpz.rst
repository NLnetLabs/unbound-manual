.. index:: RPZ, Response Policy Zones

.. versionadded:: 1.10.0
    Intial release with QNAME and Response IP Address triggers
.. versionchanged:: 1.14.0
    Full set of RPZ triggers and actions are supported

Response Policy Zones
=====================

Response Policy Zones (RPZ) is a mechanism that makes it possible to define your
local policies in a standardised way and load your policies from external
sources.

.. Seealso:: :ref:`manpages/unbound.conf:Response Policy Zone Options` in 
             the :doc:`/manpages/unbound.conf` manpage.

Introduction
------------

Unbound has support for `local-zones
<https://nlnetlabs.nl/documentation/unbound/unbound.conf/#local-zone>`_ and
`local-data
<https://nlnetlabs.nl/documentation/unbound/unbound.conf/#local-data>`_. This
makes it possible to give a custom answer back for certain domain names. It also
contains the ``respip`` module which makes it possible to rewrite answers
containing certain IP addresses. Although these options are heavily used, they
are Unbound specific. If you operate resolvers from multiple vendors you have to
maintain your policies for multiple configurations, which all will have their
own syntax. Using the Unbound specific configuration also makes it challenging
to consume policies from external sources. You will have to fetch the external
policies in the offered format, and reformat it in such a way that Unbound will
understand it. You then have to keep this list up-to-date, for example using
`unbound-control
<https://nlnetlabs.nl/documentation/unbound/unbound-control/>`_.

There is, however, a policy format that will work on different resolver
implementations, and that has capabilities to be directly transferred and loaded
from external sources: Response Policy Zones (RPZ).

.. index:: RPZ policies

RPZ Policies
------------

RPZ policies are formatted in DNS zone files. This makes it possible to easily
consume and keep them to up-to-date by using DNS zone transfers. Something that
Unbound is already capable of doing for its `auth-zone
<https://nlnetlabs.nl/documentation/unbound/unbound.conf/#master>`_ feature.

Each policy in the policy zone consists of a trigger and an action. The trigger
describes when the policy should be applied. The action describes what action
should be taken if the policy needs to be applied. Each trigger and action
combination is defined as a Resource Record (RR) in the policy zone. The owner
of the RR states the trigger, the type and RDATA state the action.

The latest `RPZ draft
<https://tools.ietf.org/html/draft-vixie-dnsop-dns-rpz-00>`_ describes five
different policy triggers of which Unbound supports two: the QNAME trigger and
the Response IP Address trigger.

.. index:: QNAME Trigger

QNAME Trigger
-------------

A policy with the *QNAME* trigger will be applied when the target domain name in
the query (the query name, or QNAME) matches the trigger name. The trigger name
is the part of the *owner* of the record before the origin of the zone. For
example, if there is this record in the ``rpz.nlnetlabs.nl`` zone:

.. code-block:: text

  $ORIGIN rpz.nlnetlabs.nl.
  example.com.rpz.nlnetlabs.nl.    TXT  "trigger for example.com"

then Unbound will add a policy for queries for ``example.com``. Only exact
matches for ``example.com`` will be triggered. If a policy for ``example.com``
is desired that includes all of its subdomains, this is possible by adding a
wildcard record:

.. code-block:: text

  $ORIGIN rpz.nlnetlabs.nl.
  example.com.rpz.nlnetlabs.nl.    TXT  "trigger for example.com"
  *.example.com.rpz.nlnetlabs.nl.  TXT  "trigger for *.example.com"

.. index:: RPZ actions

RPZ Actions
-----------

The action that will be applied for above example is the *Local Data* action.
This means that queries for ``example.com`` for the *TXT* type will be answered
with the newly created record. Queries for types that do not exist in the policy
zones will result in a NODATA answer.

.. code-block:: text

  $ drill txt example.com
  ;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 14642
  ;; flags: qr aa rd ra ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
  ;; QUESTION SECTION:
  ;; example.com. IN TXT

  ;; ANSWER SECTION:
  example.com. 3600 IN TXT "trigger for example.com"

  $ drill aaaa example.com @127.0.0.54
  ;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 4713
  ;; flags: qr aa rd ra ; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 0
  ;; QUESTION SECTION:
  ;; example.com. IN AAAA

  ;; ANSWER SECTION:

Other RPZ actions that are supported by Unbound are the *NXDOMAIN*, *NODATA*,
*PASSTHRU*, and *DROP* actions. All of these actions are defined by having a
CNAME to a specific name. A policy for the NXDOMAIN action is created by having
a CNAME to the root:

.. code-block:: text

  $ORIGIN rpz.nlnetlabs.nl.
  example.com.rpz.nlnetlabs.nl.    CNAME .

The NXDOMAIN action will, as the name suggest, answer with an NXDOMAIN when
triggered:

.. code-block:: text

  $ drill aaaa example.com
  ;; ->>HEADER<<- opcode: QUERY, rcode: NXDOMAIN, id: 14754
  ;; flags: qr aa rd ra ; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 0
  ;; QUESTION SECTION:
  ;; example.com. IN AAAA
  ;; ANSWER SECTION:

The CNAME targets for the other RPZ actions are:

+--------------+-------------------------+
|    Action    |    RR type and RDATA    |
+==============+=========================+
| ``NXDOMAIN`` | ``CNAME .``             |
+--------------+-------------------------+
| ``NODATA``   | ``CNAME *.``            |
+--------------+-------------------------+
| ``PASSTHRU`` | ``CNAME rpz-passthru.`` |
+--------------+-------------------------+
| ``DROP``     | ``CNAME rpz-drop.``     |
+--------------+-------------------------+

The NODATA action is self-explanatory. The DROP action will simply ignore (drop)
the query. The PASSTHRU action makes it possible to exclude a domain, or IP
address, from your policies. If the PASSTHRU action is triggered no other policy
from any of the available policy zones will be applied:

.. code-block:: text

  $ORIGIN rpz.nlnetlabs.nl.
  *.example.com.rpz.nlnetlabs.nl.   TXT "local data policy"
  www.example.com.rpz.nlnetlabs.nl. CNAME rpz-passthru.

Queries for all subdomains of ``example.com`` will now be answered with an
NXDOMAIN, except for queries for ``www.example.com``, these will be resolved
normally.

.. code-block:: text

  $ drill txt withpolicy.example.com
  ;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 62993
  ;; flags: qr aa rd ra ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
  ;; QUESTION SECTION:
  ;; withpolicy.example.com. IN TXT

  ;; ANSWER SECTION:
  withpolicy.example.com. 3600 IN TXT "local data policy"

  $ drill txt www.example.com
  ;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 42053
  ;; flags: qr rd ra ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
  ;; QUESTION SECTION:
  ;; www.example.com. IN TXT

  ;; ANSWER SECTION:
  www.example.com. 86400 IN TXT "v=spf1 -all"

.. index:: Response IP trigger

Response IP Address Trigger
---------------------------

The other RPZ trigger supported by Unbound is the *Response IP Address* trigger.
This trigger makes it possible to apply the same RPZ actions as mentioned above,
but triggered based on the IPv4 or IPv6 address in the answer section of the
answer. The IP address to trigger on is again part of the owner of the policy
records. The IP address is encoded in reverse form and prepended with the prefix
length to use. This all is prepended to the ``rpz-ip`` label, which will be
placed right under the apex of the zone. So, a trigger for addresses in the
192.0.2.0/24 block will be encoded as:

.. code-block:: text

  $ORIGIN rpz.nlnetlabs.nl.
  24.0.2.0.192.rpz-ip.rpz.nlnetlabs.nl. [...]

IPv6 addresses can also be used in RPZ policies. In that case the ``zz`` label
can be used to replace the longest set of zeros. A trigger for addresses in the
2001:DB8::/32 block will be encoded as:

.. code-block:: text

  $ORIGIN rpz.nlnetlabs.nl.
  32.zz.db8.2001.rpz-ip.rpz.nlnetlabs.nl. [...]

It is possible to replace an address by applying one specified in a policy
containing a Local Data action. For example, the IPv4 address for
``example.com`` is currently ``93.184.216.34``, and can be changed to
``192.0.2.1`` like this:

.. code-block:: text

  $ORIGIN rpz.nlnetlabs.nl.
  32.34.216.184.93.rpz-ip.rpz.nlnetlabs.nl. A 192.0.2.1

  ---

  $ drill example.com
  ;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 13670
  ;; flags: qr rd ra ; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
  ;; QUESTION SECTION:
  ;; example.com. IN A
  ;; ANSWER SECTION:

  example.com. 3600 IN A 192.0.2.1

Implementation
--------------

The RPZ implementation in Unbound depends on the ``respip`` module, this module
needs to be loaded using ``module-config``. Each policy zone is configured in
Unbound using the ``rpz`` clause. A minimal configuration with a single policy
zone can look like:

.. code-block:: text

  server:
    module-config: "respip validator iterator"
  rpz:
    name: rpz.nlnetlabs.nl
    zonefile: rpz.nlnetlabs.nl

In above example the policy zone will be loaded from file. It is also possible
to load the zone using DNS zone transfers. Both AXFR and IXFR is supported, all
additions and deletion in the zone will be picked up by Unbound and reflected in
the local policies. Transferring the policy using a DNS zone transfer is as easy
as specifying the server to get the zone from:

.. code-block:: text

  server:
    module-config: "respip validator iterator"
  rpz:
    name: rpz.nlnetlabs.nl
    master: <ip address of server to transfer from>
    zonefile: rpz.nlnetlabs.nl

The zone will now be transferred from the configured address and saved to a
zonefile on disk. It is possible to have more than one policy zone in Unbound.
Having multiple policy zones is as simple as having multiple ``rpz`` clauses:

.. code-block:: text

  server:
    module-config: "respip validator iterator"
  rpz:
    name: rpz.nlnetlabs.nl
    zonefile: rpz.nlnetlabs.nl
  rpz:
    name: rpz2.nlnetlabs.nl
    zonefile: rpz2.nlnetlabs.nl

The policy zones will be applied in the configured order. In the example,
Unbound will only look at the ``rpz2.nlnetlabs.nl`` policies if there is no
match in the ``rpz.nlnetlabs.nl`` zone. If there is no match in any of the
configured zones Unbound will continue to resolve the domain by sending upstream
queries. Note that a PASSTHRU action is considered a match, having that action
in the first zone will therefore stop Unbound from looking further at other
policy zones.

Unbound has the possibility to override the actions that will be used for
policies in a zone that matches the zone’s triggers. This can be done using the
``rpz-action-override`` configuration option. The possible values for the option
are: ``nxdomain``, ``nodata``, ``passthru``, ``drop``, ``disabled``, and
``cname``. The first four options of this list will do the same as the RPZ
actions with the same name.

The ``cname`` override option will make it possible to apply a local data action
using a CNAME for all matching triggers in the policy zone. The CNAME to use in
the answer can be configured using the ``rpz-cname-override`` configuration
option. Using these overrides are nice if you use an external feed to get a list
of triggers, but would like to redirect all your users to your own domain:

.. code-block:: text

  RPZ zone (rpz.nlnetlabs.nl):
  $ORIGIN rpz.nlnetlabs.nl.
  drop.example.com.rpz.nlnetlabs.nl. CNAME rpz-drop.
  32.34.216.184.93.rpz-ip.rpz.nlnetlabs.nl. A 192.0.2.1

  ---

  Unbound config:
  server:
    module-config: "respip validator iterator"

  rpz:
    name: rpz.nlnetlabs.nl
    zonefile: rpz.nlnetlabs.nl
    rpz-action-override: cname
    rpz-cname-override: "example.nl."

  ---

  Example queries:
  $ drill drop.example.com
  ;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 14547
  ;; flags: qr aa rd ra ; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0
  ;; QUESTION SECTION:
  ;; drop.example.com. IN A

  ;; ANSWER SECTION:
  drop.example.com. 3600 IN CNAME example.nl.
  example.nl. 3600 IN A 94.198.159.35

  $ drill example.com
  ;; ->>HEADER<<- opcode: QUERY, rcode: NOERROR, id: 31187
  ;; flags: qr rd ra ; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0
  ;; QUESTION SECTION:
  ;; example.com. IN A

  ;; ANSWER SECTION:
  example.com. 3600 IN CNAME example.nl.
  example.nl. 3568 IN A 94.198.159.35

The ``disabled`` option will stop Unbound from applying any of the actions in
the zone. This, combined with the ``rpz-log`` option, is a nice way to test what
would happen to your traffic when a policy will be enabled, without directly
impacting your users. The difference between ``disabled`` and ``passthru`` is
that disabled is not considered to be a valid match and will therefore not stop
Unbound from looking at the next configured policy zone.

When ``rpz-log`` is set to yes, Unbound will log all applied actions for a
policy zone. With ``rpz-log`` enabled you can specify a name for the log using
``rpz-log-name``, this way you can easily find all matches for a specific zone.
It is also possible to get statistics per applied RPZ action using
``unbound-control stats``. This requires the ``extended-statistics`` to be
enabled.

Unbound’s RPZ implementation works together with the tags functionality. This
makes is possible to enable (some of) the policy zones only for a set of the
users. To do this the tags need to be defined using ``define-tag``, the correct
tags need to be matched with the client IP addresses using
``access-control-tag``, and the tags need to be specified for the policy zones
for which they apply.

.. code-block:: text

  server:
    module-config: "respip validator iterator"
    define-tag: "malware social"
    access-control-tag 127.0.0.10/32 "social"
    access-control-tag 127.0.0.20/32 "social malware"
    access-control-tag 127.0.0.30/32 "malware"
  rpz:
    name: malware.rpz.example.com
    zonefile: malware.rpz.example.com
    tags: "malware"
  rpz:
    name: social.rpz.example.com
    zonefile: social.rpz.example.com
    tags: "social"

Queries from 127.0.0.1 will not be filtered. For queries coming from 127.0.0.10
only the policies from the social.rpz.example.com zone will be used, for
127.0.0.30 only the policies from the malware.rpz.example.com zone will be used,
and queries originated from 127.0.0.20 will be subjected to the policies from
both zones.
