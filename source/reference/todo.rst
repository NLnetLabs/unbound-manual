Docs To-Do List
===============

Since the first release in 2007, the documentation of Unbound has been
maintained with a heavy focus on :doc:`manual pages</manpages/unbound>`. As
the resolver has become more versatile and feature-rich over the years, the
NLnet Labs team decided to add this documentation, providing installation guides
for different platforms, practical use cases, and background information. 

The to-do list below provides an overview if the the topics we still have to
cover. If you feel something is missing, please `open an issue on GitHub
<https://github.com/NLnetLabs/unbound-manual/issues>`_ to let us know. 

.. Note:: If you would like to write one or more of these pages, we're happy to
          compensate you for your time. Contact us at docs@nlnetlabs.nl or find
          us on `Twitter <https://twitter.com/nlnetlabs>`_.

Use Cases
---------

- Resolver setup for enterprise networks
- Resolver setup for ISPs
- Maximum privacy resolver

Topics
------

- Resiliency (e.g. Rate Limiting, ACLs)
- EDNS Client Subnet

Filtering and Manipulating Data
-------------------------------

- Local Zones and Local Data
- Expansion to all RPZ triggers and actions

Privacy
-------

- Auth Zone
- Encryption
- QNAME Minimisation

Internals
---------

- Architecture
- Code structure
- Server selection
- DNSSEC Trust Anchor Management (unbound-anchor and :rfc:`5011`)
- Python modules
