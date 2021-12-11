Trust anchor retrieval less then 30 days before the KSK rollover
================================================================

There is an issue for new installations less then 30 days before the rollover
with Unbound versions prior to 1.6.5 (1.6.4 or older). The KSK2017 will be added
in the ADDPEND state for 30 days (RFC 5011) and will not be in the VALID state
during the key rollover. All is fine for trust anchor files created more then 30
days before the KSK rollover or after the KSK rollover, in any Unbound version.

Solution for installations less then 30 days prior to KSK rollover
------------------------------------------------------------------

You can either update to Unbound 1.6.5 (or later) or download the trust anchor
file from this website.

Update to Unbound 1.6.5 or later
++++++++++++++++++++++++++++++++

Delete the root.key file with ``rm root.key``, then run ``unbound-anchor``
(1.6.5 or later) to create the root.key file again. You can verify that worked
by checking that both keys have the string VALID in the newly created root.key
file.

Download the trust anchor file from the Unbound website
+++++++++++++++++++++++++++++++++++++++++++++++++++++++

If updating to Unbound 1.6.5 or later is not possible, you can `download a trust
anchor file <https://nlnetlabs.nl/downloads/unbound/root-11sep-11oct.key>`_
containing the two VALID keys.