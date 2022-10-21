.. index:: Tags, Views

Tags and Views
==============

The tags and views functionality make it possible to send specific DNS answers
based on the IP address of the client.

Tags
----

The tags functionality makes it possible to divide incoming client queries in
categories (tags), and use :ref:`local-zone:<unbound.conf.local-zone>` and
:ref:`local-data:<unbound.conf.local-data>` information for these specific tags.

Before these tags can be used, you need to define them in the Unbound
configuration using
:ref:`define-tag:<unbound.conf.define-tag>`.
In this example, a tag for domains containing malware is set, along with one
for domains of gambling sites:

.. code-block:: text

  define-tag: "malware gambling"

Now that Unbound is aware of the existing tags, it is possible to start using
them.

The :ref:`access-control-tag:<unbound.conf.access-control-tag>` element is used
to specify the tag to use for client source address.
Alternatively, the :ref:`interface-tag:<unbound.conf.interface-tag>` element is
used to specify the tag to use for clients on a specific listening interface.
You can add multiple tags to these elements:

.. code-block:: text

  # Per client IP ...
  access-control-tag: 10.0.1.0/24 "malware"
  access-control-tag: 10.0.2.0/24 "malware"
  access-control-tag: 10.0.3.0/24 "gambling"
  access-control-tag: 10.0.4.0/24 "malware gambling"

  # ... and/or per listening interface
  interface-tag: eth0 "malware"
  interface-tag: 10.0.0.1 "malware gambling"

.. note::

  Any ``access-control*:`` setting overrides all ``interface-*:`` settings
  for targeted clients.

Unbound will create a ``*-tag`` element with the “allow” type if the IP
address block / listening interface in the ``*-tag`` element does not match an
existing access control rule.

When a query comes in that is marked with a tag, Unbound starts searching its
local-zone tree for the best match.
The best match is the most specific local-zone with a matching tag, or without
any tag.
That means that local-zones without any tag will be used for all queries and
tagged local-zones only for queries with matching tags.

Adding tags to local-zones can be done using the
:ref:`local-zone-tag:<unbound.conf.local-zone-tag>` element:

.. code-block:: text

  local-zone: malwarehere.example refuse
  local-zone: somegamblingsite.example static
  local-zone: matchestwotags.example transparent
  local-zone: notags.example inform

  local-zone-tag: malwarehere.example malware
  local-zone-tag: somegamblingsite.example malware
  local-zone-tag: matchestwotags.example "malware gambling"

A local-zone can have multiple tags, as illustrated in the example above.
The tagged local-zones will be used if one or more tags match the query.
So, the matchestwotags.example local-zone will be used for all queries with at
least the malware or gambling tag.
The used local-zone type will be the type specified in the matching local-zone.
It is possible to depend the local-zone type on the client and tag combination.
Setting tag specific local-zone types can be done using
:ref:`access-control-tag-action:<unbound.conf.access-control-tag-action>` and/or
:ref:`interface-tag-action:<unbound.conf.interface-tag-action>`:

.. code-block:: text

  # Per client IP ...
  access-control-tag-action: 10.0.1.0/24 "malware" refuse
  access-control-tag-action: 10.0.2.0/24 "malware" deny

  # ... and/or per listening interface
  interface-tag-action: eth0 "malware" refuse
  interface-tag-action: 10.0.0.1 "malware" deny

In addition to configuring a local-zone type for specific clients/tag match, it
is also possible to set the used local-data RRs.
This can be done using the
:ref:`access-control-tag-data:<unbound.conf.access-control-tag-data>` and/or
:ref:`interface-tag-data:<unbound.conf.interface-tag-data>` elements:

.. code-block:: text

  # Per client IP ...
  access-control-tag-data: 10.0.4.0/24 "gambling" "A 127.0.0.1"

  # ... and/or per listening interface
  interface-tag-data: 10.0.0.1 "gambling" "A 127.0.0.1"

Sometimes you might want to override a local-zone type for a specific IP prefix
or interface, regardless the type configured for tagged and untagged local
zones, and regardless the type configured using
:ref:`access-control-tag-action:<unbound.conf.access-control-tag-action>` and/or
:ref:`interface-tag-action:<unbound.conf.interface-tag-action>`.
This override can be done using
:ref:`local-zone-override:<unbound.conf.local-zone-override>`.

Views
-----

Tags make is possible to divide a large number of local-zones in categories,
and assign these categories to a large number of IP address blocks.
As tags on the clients and local-zones are stored in bitmaps, it is advised to
keep the number of tags low.
Specifically for client prefixes (i.e., ``access-control-tag*:``), if a lot of
clients have their own local-zones, without sharing these to other IP prefixes,
it can result in a large amount tags.
In this situation it is more convenient to give the clients' IP prefix its own
tree containing local-zones.
Another benefit of having a separate local zone tree is that it makes it
possible to apply a local-zone action to a part of the domain space, without
having other local-zone elements of subdomains overriding this.
Configuring a client specific local-zone tree can be done using views.

A view is a named list of configuration options.
The supported view configuration options are
:ref:`local-zone:<unbound.conf.view.local-zone>` and
:ref:`local-data:<unbound.conf.view.local-data>`.

A view is configured using a **view:** clause.
There may be multiple view clauses, each with a unique name. For example:

.. code-block:: text

  view:
      name: "firstview"
      local-zone: example.com inform
      local-data: 'example.com TXT "this is an example"'
      local-zone: refused.example.nl refuse

Mapping a view to a client can be done using the
:ref:`access-control-view:<unbound.conf.access-control-view>` element:

.. code-block:: text

  access-control-view: 10.0.5.0/24 firstview

Alternatively, mapping a view to clients in a specific interface can be done
using the :ref:`interface-view:<unbound.conf.interface-view>` element:

.. code-block:: text

  interface-view: eth0 firstview

By default, view configuration options override the global configuration
outside the view.
When a client matches a view it will only use the view's local-zone tree.
This behaviour can be changed by setting
:ref:`view-first:<unbound.conf.view.view-first>` to yes.
If view-first is enabled, Unbound will try to use the view's local-zone tree,
and if there is no match it will search the global tree.

.. seealso::
    :ref:`manpages/unbound.conf:View Options` in the
    :doc:`/manpages/unbound.conf` manpage.
