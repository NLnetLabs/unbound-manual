Unbound Library Tutorial
========================

This is the tutorial for the :doc:`unbound library</manpages/libunbound>`.
Unbound can run as a server, as a daemon in the background, answering DNS
queries from the network. Alternatively, it can link to an application as a
library ``-lunbound``, and answer DNS queries for the application. This tutorial
explains how to use the library API.

.. toctree::
   :maxdepth: 2
   :caption: Contents

   resolve-a-name
   setup-context
   examine-results
   async-lookup
   lookup-threads
   dnssec-validate