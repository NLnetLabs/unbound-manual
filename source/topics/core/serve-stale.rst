.. versionadded:: 1.6.0
.. versionchanged:: 1.11.0
    :rfc:`8767` behavior is introduced

Serving Stale Data
==================

Unbound supports serving stale data from its cache, as described in :rfc:`8767`.
Serving stale data would normally break the contract between an authoritative
name server and a caching resolver on the amount of time a record is permitted
to be cached. However, the TTL definition of :rfc:`8767#section-4` states that:

    "If the data is unable to be authoritatively refreshed when the TTL
    expires, the record MAY be used as though it is unexpired."

Serving expired records is not a novel idea and it was already present in
various forms (e.g., increased cache-hit ratio, fallback when upstream is not
reachable) in various resolvers.
Unbound’s own form is called :ref:`serve-expired:<unbound.conf.serve-expired>`
and its main purpose was to increase the cache-hit ratio.

As the RFC landed in the standards track, Unbound gained support for it but
still kept the original serve-expired logic. Certain aspects of the RFC, such as
timers, were already present in Unbound and their functionality is shared by
both modes of operation.

The following sections try to clarify the differences between serve-expired and
:rfc:`8767` (serve-stale) and give some insight into when one may be preferable
over the other. I will refrain from using the RFC term serve-stale in order to
avoid any confusion between the terms and the configuration options later on.

serve-expired
-------------

Since version 1.6.0, Unbound has the ability to answer with expired records.
Before trying to resolve, Unbound will also consider expired cached records as
possible answers. If such a record is found it is immediately returned to the
client (cache response speed!). But contrary to normal cache replies, Unbound
continues resolving and hopefully updating the cached record.

The immediate downside is obvious: the expired answers rely heavily on the
cache state.
Unbound already has the tools to try and tip the scales in its favor with the
:ref:`prefetch:<unbound.conf.prefetch>` and
:ref:`serve-expired-ttl:<unbound.conf.serve-expired-ttl>` options.

With prefetch, Unbound tries to update a cached record (after first replying to
the client) when the current TTL is within 10% of the original TTL value. The
logic is similar to serve-expired: if a cached record is found and the record is
within 10% of the TTL, it is returned to the client but Unbound continues
resolving in order to update the record. Although prefetching comes with a small
penalty of ~10% in traffic and load from the extra upstream queries, the cache
is kept up-to-date, at least for popular queries.

Rare queries have the inescapable fate of having their records expired past any
meaningful time.
The option :ref:`serve-expired-ttl:<unbound.conf.serve-expired-ttl>` limits the
amount of time an expired record is supposed to be served.
:rfc:`8767#section-5-11` suggests a value between one and three days.

.. note::

    A note on the expired reply’s TTL value: prior to the RFC, Unbound was
    using TTL 0 in order to signal that the expired record is only meant to be
    used for this DNS transaction and not to be cached by the client. The RFC
    now RECOMMENDS a value of 30 to be returned to the client.

A simple configuration for the primal serve-expired behavior could then be:

.. code-block:: text

    server:
        prefetch: yes 
        serve-expired: yes 
        serve-expired-ttl: 86400  # one day, in seconds

This will allow Unbound to:

- prioritize (expired) cached replies,
- keep the cache fairly up-to-date, and
- in the likelihood that an expired record needs to be served (e.g., rare
  query, issue with upstream resolving), make sure that the record is not older
  than the specified limit.

RFC 8767
--------

Starting with version 1.11.0, Unbound supports serving expired records
following the RFC guidelines.
The RFC behavior is mainly focused on returning expired answers as fallback for
normal resolution.
The option to control that is
:ref:`serve-expired-client-timeout:<unbound.conf.serve-expired-client-timeout>`
and setting it to a value greater than 0 enables the RFC behavior.

With the value set, Unbound has a limit on how much time it can spend resolving
a client query. When that limit is passed, Unbound pauses resolution and checks
if there are any expired records in the cache that can answer the initial query.
If that is the case, Unbound answers with the expired record before resuming
resolution. The result of the resolution will be used to update the cache if
possible.

Similar to the client timeout, Unbound will also try and use expired answers
instead of returning SERVFAIL to the client where possible.

A simple configuration for the RFC behavior could then be:

.. code-block:: text

    server:
        serve-expired: yes
        serve-expired-ttl: 86400            # one day, in seconds
        serve-expired-client-timeout: 1800  # 1.8 seconds, in milliseconds


This will allow Unbound to use expired answers only as fallback from normal
resolving:

- when 1.8 seconds have passed since the client made the query,
- instead of returning SERVFAIL, or
- in the likelihood that an expired record needs to be served (e.g., issue with
  upstream resolving), make sure that the record is not older than the
  specified limit.

Conclusion
----------

Unbound offers two distinct modes for serving expired records. The safest
approach is to use the RFC behavior where expired records are used as a fallback
to availability, network or configuration errors. This will serve expired
records as a last resort instead of returning SERVFAIL or the client giving up.

If more client-side performance is required, the default original serve-expired
behavior can keep the cache-hit ratio higher. Using it together with the
prefetch option is highly recommended in order to try and keep an updated cache.

In all cases make sure to consult the :doc:`/manpages/unbound.conf` manpage of
your installed Unbound for defaults and suggested values. And always remember
that serving expired records should be approached with caution; you may be
directing your clients to places long gone.

.. seealso::
    :ref:`serve-expired<unbound.conf.serve-expired>`,
    :ref:`serve-expired-ttl<unbound.conf.serve-expired-ttl>`,
    :ref:`serve-expired-ttl-reset<unbound.conf.serve-expired-ttl-reset>`,
    :ref:`serve-expired-reply-ttl<unbound.conf.serve-expired-reply-ttl>` and
    :ref:`serve-expired-client-timeout<unbound.conf.serve-expired-client-timeout>`
    in the :doc:`/manpages/unbound.conf` manpage.
