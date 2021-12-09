.. Unbound User Manual master file

.. Warning:: This project has the goal to replace the `existing documentation
             <https://www.nlnetlabs.nl/documentation/unbound/>`_ with an
             open source community project. **This is a work in progress.**
             A skeleton and table of contents is in place but not every page
             has been written.
             
             Do you love to write and know your way around DNS and Unbound? 
             Help us expand unbound.readthedocs.io and we'll compensate you 
             for your time. Contact us at docs@nlnetlabs.nl to apply.

Unbound by NLnet Labs
=====================

Welcome to the Unbound documentation. Unbound is a validating, recursive,
caching DNS resolver. It is designed to be fast and lean and incorporates modern
features based on open standards.

Unbound runs on FreeBSD, OpenBSD, NetBSD, MacOS, Linux and Microsoft Windows,
with packages available for most platforms. It is included in the base-system of
FreeBSD and OpenBSD and in the standard repositories of most Linux
distributions. Installation and configuration is designed to be easy. Setting up
a resolver for your machine or network can be done with only a few lines of
configuration.

This documentation is an open source project maintained by NLnet Labs. is edited
via text files in the `reStructuredText
<http://www.sphinx-doc.org/en/stable/rest.html>`_ markup language and then
compiled into a static website/offline document using the open source `Sphinx
<http://www.sphinx-doc.org>`_  and `ReadTheDocs <https://readthedocs.org/>`_
tools.

We always appreciate your feedback and improvements. You can submit an issue or
pull request on the `GitHub repository
<https://github.com/NLnetLabs/unbound-manual/issues>`_, or post a message on the
`Unbound users <https://lists.nlnetlabs.nl/mailman/listinfo/unbound-users>`_
mailing list. All the contents are under the permissive Creative Commons
Attribution 3.0 (`CC-BY 3.0 <https://creativecommons.org/licenses/by/3.0/>`_)
license, with attribution to NLnet Labs.


.. toctree::
   :maxdepth: 2
   :caption: Getting Started

   getting-started/installation
   getting-started/configuration

.. toctree::
   :maxdepth: 2
   :caption: Use Cases

   use-cases/home-resolver
   use-cases/local-stub
..
   use-cases/enterprise-resolver
   use-cases/isp-resolver
   use-cases/privacy-aware-resolver

..
   .. toctree::
      :maxdepth: 2
      :caption: Topics

      topics/privacy/index
      topics/performance
      topics/filtering/index
      topics/monitoring
      topics/ecs
      topics/resiliency

.. toctree::
      :maxdepth: 2
      :caption: Topics

      topics/privacy/aggressive-nsec
      topics/filtering/tags-views
      topics/filtering/rpz

..
   .. toctree::
      :maxdepth: 2
      :caption: Internals

      internals/server-selection
      internals/compliance
      internals/architecture
      internals/code-structure
      internals/python-modules
      internals/trust-anchors

.. toctree::
   :maxdepth: 2
   :caption: Unbound Library Tutorial

   libunbound-tutorial/resolve-a-name
   libunbound-tutorial/setup-context
   libunbound-tutorial/examine-results
   libunbound-tutorial/async-lookup
   libunbound-tutorial/lookup-threads
   libunbound-tutorial/dnssec-validate

.. toctree::
   :maxdepth: 2
   :caption: Manual Pages

   manpages/unbound
   manpages/unbound-checkconf
   manpages/unbound.conf
   manpages/unbound-host
   manpages/libunbound
   manpages/unbound-control
   manpages/unbound-anchor
..
   .. toctree::
      :maxdepth: 2
      :caption: Reference

      reference/libunbound
   

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
