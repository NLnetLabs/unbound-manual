Unbound by NLnet Labs
=====================

Unbound is a validating, recursive, caching DNS resolver. It is designed to be
fast and lean and incorporates modern features based on open standards.

.. Note::  Do you love to write and know your way around DNS and Unbound?
           :doc:`Help us expand this documentation <reference/todo>` and we'll
           compensate you for your time. Contact us at docs@nlnetlabs.nl or
           find us on `Twitter <https://twitter.com/nlnetlabs>`_.

Unbound runs on FreeBSD, OpenBSD, NetBSD, MacOS, Linux and Microsoft Windows,
with packages available for most platforms. It is included in the standard
repositories of most Linux distributions. Installation and configuration is
designed to be easy. Setting up a resolver for your machine or network can be
done with only a few lines of configuration.

This documentation is an `open source project
<https://github.com/NLnetLabs/unbound-manual/>`_ and is edited via text files in
the `reStructuredText <http://www.sphinx-doc.org/en/stable/rest.html>`_ markup
language and then compiled into a static website/offline document using `Sphinx
<http://www.sphinx-doc.org>`_  and `ReadTheDocs <https://readthedocs.org/>`_.

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

.. toctree::
   :maxdepth: 2
   :caption: Core

   topics/core/proxy
   topics/core/serve-stale
   topics/core/performance
   topics/core/monitoring

.. toctree::
   :maxdepth: 2
   :caption: Privacy

   topics/privacy/aggressive-nsec
   topics/privacy/dns-over-https

.. toctree::
   :maxdepth: 2
   :caption: Filtering

   topics/filtering/tags-views
   topics/filtering/rpz

.. toctree::
   :maxdepth: 2
   :caption: Developer

   developer/libunbound-tutorial/index
   developer/python-modules
   developer/doxygen-docs

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

.. toctree::
   :maxdepth: 1
   :caption: Reference

   reference/rfc-compliance
   reference/history/index
   reference/todo
   

Index
=====

* :ref:`genindex`

.. * :ref:`search`
