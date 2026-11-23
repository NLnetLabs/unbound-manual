Unbound documentation
=====================

Unbound is an open-source, validating, recursive DNS resolver developed by
NLnet Labs. It resolves DNS queries, verifies DNSSEC signatures and caches
answers for subsequent requests. It runs in environments ranging from home
routers and network appliances to enterprise networks and large-scale cloud
infrastructure.

This manual explains how to install, configure and operate Unbound, and how to
use its resolution capabilities in your own applications. For an overview of
its capabilities, read `About Unbound
<https://nlnetlabs.nl/projects/unbound/about/>`__. For the engineering behind
its performance, resilience and operational controls, see `Unbound in depth
<https://nlnetlabs.nl/projects/unbound/in-depth/>`__.

Get started
-----------

Start with :doc:`installation <getting-started/installation>`, then follow the
:doc:`configuration guide <getting-started/configuration>`. Unbound provides
sensible defaults, but listening interfaces, client access and DNSSEC trust
anchors still need to suit your deployment.

For worked examples, see how to run a resolver for
:doc:`a single machine <use-cases/local-stub>` or
:doc:`a home network <use-cases/home-resolver>`.

Configure and operate
---------------------

Use the topic guides to adapt Unbound to your workload and policies:

- **Performance and availability:** :doc:`tune resource use
  <topics/core/performance>` and :doc:`serve stale data when fresh answers
  cannot be retrieved <topics/core/serve-stale>`.
- **Monitoring:** :doc:`collect statistics <topics/core/monitoring>` and use
  :doc:`unbound-control <manpages/unbound-control>` to inspect and manage a
  running resolver.
- **Local policy:** organise clients and local data with
  :doc:`tags and views <topics/filtering/tags-views>`, or apply
  :doc:`Response Policy Zones <topics/filtering/rpz>`.
- **Encrypted DNS:** configure :doc:`DNS over HTTPS
  <topics/privacy/dns-over-https>` or :doc:`DNS over QUIC
  <topics/privacy/dns-over-quic>`.

Look up an option or command
----------------------------

The :doc:`unbound.conf reference <manpages/unbound.conf>` describes
configuration options and their defaults. Use
:doc:`unbound-checkconf <manpages/unbound-checkconf>` to check a configuration
file before applying it. The manual pages in the navigation cover the daemon,
command-line tools and library interfaces; the :ref:`genindex` provides
another way to find individual entries.

See :doc:`RFC compliance <reference/rfc-compliance>` for supported standards.

Develop with Unbound
--------------------

Use :doc:`libunbound <developer/libunbound-tutorial/index>` to add validating
DNS resolution to an application, or explore
:doc:`Python modules <developer/python-modules>` to extend resolver behaviour.
The :doc:`source-code documentation <developer/doxygen-docs>` describes
Unbound's internals.

Get help and contribute
-----------------------

Ask operational questions and discuss deployments on the `NLnet Labs community
forum <https://community.nlnetlabs.nl/>`__. Organisations that need assistance
from the development team and service-level commitments can obtain
`professional support and consultancy
<https://nlnetlabs.nl/services/contracts/>`__.

Report software bugs in the `Unbound issue tracker
<https://github.com/NLnetLabs/unbound/issues>`__. For suspected security
vulnerabilities, use the `security reporting instructions
<https://nlnetlabs.nl/security-report/>`__.

Corrections and improvements to this manual are welcome through issues and
pull requests in the `documentation repository
<https://github.com/NLnetLabs/unbound-manual/>`__. The documentation is licensed
under `Creative Commons Attribution 3.0
<https://creativecommons.org/licenses/by/3.0/>`__, with attribution to
NLnet Labs.


.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Getting Started

   getting-started/installation
   getting-started/configuration

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Use Cases

   use-cases/home-resolver
   use-cases/local-stub

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Core

   topics/core/proxy
   topics/core/serve-stale
   topics/core/performance
   topics/core/monitoring

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Privacy

   topics/privacy/aggressive-nsec
   topics/privacy/dns-over-https
   topics/privacy/dns-over-quic

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Filtering

   topics/filtering/tags-views
   topics/filtering/rpz

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Developer

   developer/libunbound-tutorial/index
   developer/python-modules
   developer/doxygen-docs

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Manual Pages

   manpages/unbound
   manpages/unbound-checkconf
   manpages/unbound.conf
   manpages/unbound-host
   manpages/libunbound
   manpages/unbound-control
   manpages/unbound-anchor

.. toctree::
   :hidden:
   :maxdepth: 1
   :caption: Reference

   reference/rfc-compliance
   reference/history/index
   reference/todo
