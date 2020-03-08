.. _doc_filtering_tags_views:
.. index:: Tags, Views

Tags and Views
==============

The tags and views functionality make it possible to send specific DNS answers
based on the IP address of the client.

Tags
----

The tags functionality makes it possible to divide client source addresses
in categories (tags), and use `local-zone
<https://nlnetlabs.nl/documentation/unbound/unbound.conf/#local-zone>`_ and
`local-data
<https://nlnetlabs.nl/documentation/unbound/unbound.conf/#local-data>`_
information for these specific tags.

Before these tags can be used, you need to define them in the Unbound
configuration using *define-tags*. In this example, a tag for domains containing
malware is set, along with one for domains of gambling sites:

.. code-block:: text

  define-tags: "malware gambling"

Now that Unbound is aware of the existing tags, it is possible to start using
them. The *access-control-tag* element is used to specify the tag to use for a
client addresses. You can add multiple tags to an access-control element:

.. code-block:: text

  access-control-tag: 10.0.1.0/24 "malware"
  access-control-tag: 10.0.2.0/24 "malware"
  access-control-tag: 10.0.3.0/24 "gambling"
  access-control-tag: 10.0.4.0/24 "malware gambling"

Unbound will create an *access-control-tag* element with the “allow” type if the
IP address block in the *access-control-tag* element does not match an existing
*access-control*.

When a query comes in from an address with a tag, Unbound starts searching its
local-zone tree for the best match. The best match is the most specific
local-zone with a matching tag, or without any tag. That means that local-zones
without any tag will be used for all clients and tagged local-zones only for
clients with matching tags.

Adding tags to local-zones can be done using the *local-zone-tag* element:

.. code-block:: text

  local-zone: malwarehere.example refuse
  local-zone: somegamblingsite.example static
  local-zone: matchestwotags.example transparent
  local-zone: notags.example inform

  local-zone-tag: malwarehere.example malware
  local-zone-tag: somegamblingsite.example malware
  local-zone-tag: matchestwotags.example "malware gambling"

A local-zone can have multiple tags, as illustrated in the example above. The
tagged local-zones will be used if one or more tags match the client. So, the
matchestwotags.example local-zone will be used for all clients with at least the
malware or gambling tag. The used local-zone type will be the type specified in
the matching local-zone. It is possible to depend the local-zone type on the
client address and tag combination. Setting tag specific local-zone types can be
done using *access-control-tag-action*:

.. code-block:: text

  access-control-tag-action: 10.0.1.0/24 "malware" refuse
  access-control-tag-action: 10.0.2.0/24 "malware" deny

In addition to configuring a local-zone type for some specific client
address/tag match, it is also possible to set the used local-data RRs. This can
be done using the *access-control-tag-data* element:

.. code-block:: text

  access-control-tag-data: 10.0.4.0/24 "gambling" "A 127.0.0.1"

Sometimes you might want to override a local-zone type for a specific IP address
block, regardless the type configured for tagged and untagged local zones, and
regardless the type configured using access-control-tag action. This override
can be done using *local-zone-override*.

Views
-----

Tags make is possible to divide a large number of local-zones in
categories, and assign these categories to a large number of IP address blocks. As tags
on the IP address blocks and local-zones are stored in bitmaps, it is advised
to keep the number of tags low. If a lot of clients have their own local-zones,
without sharing these to other IP address blocks, it can result a large amount tags. In
this situation is is more convenient to give the client's IP address block its own tree
containing local-zones. Another benefit of having a separate local zone tree is
that it makes it possible to apply a local-zone action to a part of the domain
space, without having other local-zone elements of subdomains overriding this.
Configuring a client specific local-zone tree can be done using views.

A view is a named list of configuration options. The supported view
configuration options are `local-zone
<https://nlnetlabs.nl/documentation/unbound/unbound.conf/#local-zone>`_ and
`local-data
<https://nlnetlabs.nl/documentation/unbound/unbound.conf/#local-data>`_.

A view is configured using a view clause. There may be multiple view clauses,
each with a unique name. For example:

.. code-block:: text

  view:
      name: "firstview"
      local-zone: example.com inform
      local-data: 'example.com TXT "this is an example"'
      local-zone: refused.example.nl refuse

Mapping a view to a client can be done using the *access-control-view* element:

.. code-block:: text

  access-control-view: 10.0.5.0/24 firstview

By default, view configuration options override the global configuration outside
the view. When a client matches a view it will only use the view's local-zone
tree. This behaviour can be changed by setting *view-first* to yes. If
view-first is enabled, Unbound will try to use the view's local-zone tree, and
if there is no match it will search the global tree.
