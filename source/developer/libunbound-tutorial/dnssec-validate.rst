DNSSEC Validate
===============

This example program performs DNSSEC validation of a lookup. It is a
modification of the example program from the :doc:`setup-context` section.

.. code-block:: c

    #include <stdio.h>
    #include <string.h>
    #include <errno.h>
    #include <arpa/inet.h>
    #include <unbound.h>

    int main(void)
    {
            struct ub_ctx* ctx;
            struct ub_result* result;
            int retval;

            /* create context */
            ctx = ub_ctx_create();
            if(!ctx) {
                    printf("error: could not create unbound context\n");
                    return 1;
            }
            /* read /etc/resolv.conf for DNS proxy settings (from DHCP) */
            if( (retval=ub_ctx_resolvconf(ctx, "/etc/resolv.conf")) != 0) {
                    printf("error reading resolv.conf: %s. errno says: %s\n",
                            ub_strerror(retval), strerror(errno));
                    return 1;
            }
            /* read /etc/hosts for locally supplied host addresses */
            if( (retval=ub_ctx_hosts(ctx, "/etc/hosts")) != 0) {
                    printf("error reading hosts: %s. errno says: %s\n",
                            ub_strerror(retval), strerror(errno));
                    return 1;
            }

            /* read public keys for DNSSEC verification */
            if( (retval=ub_ctx_add_ta_file(ctx, "keys")) != 0) {
                    printf("error adding keys: %s\n", ub_strerror(retval));
                    return 1;
            }

            /* query for webserver */
            retval = ub_resolve(ctx, "www.nlnetlabs.nl",
                    1 /* TYPE A (IPv4 address) */,
                    1 /* CLASS IN (internet) */, &result);
            if(retval != 0) {
                    printf("resolve error: %s\n", ub_strerror(retval));
                    return 1;
            }

            /* show first result */
            if(result->havedata)
                    printf("The address is %s\n",
                            inet_ntoa(*(struct in_addr*)result->data[0]));
            /* show security status */
            if(result->secure)
                    printf("Result is secure\n");
            else if(result->bogus)
                    printf("Result is bogus: %s\n", result->why_bogus);
            else    printf("Result is insecure\n");

            ub_resolve_free(result);
            ub_ctx_delete(ctx);
            return 0;
    }

Invocation of this program yields the following:

.. code-block:: text

    First testrun
        $ touch keys
        $ example_6
        The address is 213.154.224.1
        Result is insecure

The first testrun uses an empty keyfile, and since there is no security
configured for nlnetlabs.nl, the result is insecure. For a secure result, DNSSEC
security must be configured on both the server and the client, and in this
example run, the nlnetlabs.nl server has security configured, but the key file
is empty on the client.

.. code-block:: text

    Second testrun
        $ dig nlnetlabs.nl DNSKEY > keys
        $ example_6
        The address is 213.154.224.1
        Result is secure

The second testrun obtains the current DNSKEY information for ``nlnetlabs.nl``
using ``dig`` (from the ``named`` utilities).

.. Note:: This is not a secure method to obtain keys, check keys carefully 
          before you trust them and enter them into your application (for 
          example RIPE distributes key files with added PGP signatures).

But it is very easy, and useful for this tutorial. The lookup result is secure,
because it is signed with the correct keys.

.. code-block:: text

    Third testrun
        $ echo 'nlnetlabs.nl. 3528 IN DNSKEY ( 256 3 5
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAA== )' > keys
        $ example_6
        The address is 213.154.224.1
        Result is bogus: validation failure <www.nlnetlabs.nl. A IN>:
        signatures from unknown keys from 213.154.224.254 for trust anchor
        nlnetlabs.nl. while building chain of trust

The third example puts a key into the keyfile that is not going to match any
signatures. The ``echo`` command is wrapped onto multiple lines on this page for
presentation, put the text onto one line. Because the key and the signatures on
the data do not match, verification fails and the result is bogus.

The program starts like in the :doc:`setup-context` section of the tutorial,
creates the unbound context and reads in ``/etc/resolv.conf`` and
``/etc/hosts``. Then it adds the contents of the keys file from the current
directory as trusted keys. It continues to resolve www.nlnetlabs.nl and prints
the result. It also prints the security status of the result.

The function ``ub_ctx_add_ta_file`` adds trusted keys. The keys file contains text
in the zone file format (output from ``dig`` or ``drill`` tools, or a copy and paste
from the DNS zone file). It can contain DNSKEY and DS entries, for any number of
domain names. If any of the keys matches the signatures on lookup results, the
``result->secure`` is set true.

The function ``ub_ctx_add_ta`` (not shown in example) can be used to add a trusted
key from a string. A single DNSKEY or DS key entry, on a single line, is
expected. Multiple keys can be given with multiple calls to ``ub_ctx_add_ta``. For
example:

.. code-block:: c

    if( (retval=ub_ctx_add_ta(ctx, "jelte.nlnetlabs.nl. DS 31560 "
        "5 1 1CFED84787E6E19CCF9372C1187325972FE546CD")) != 0)
    { /* print error */ }

It is also possible to read in named (BIND-style) key config files. These files
contain ``trusted-key{}`` clauses. The function ``ub_ctx_trustedkeys`` (not
shown in example) adds the keys from a bind-style config file.
``ub_ctx_set_option(ctx, "auto-trust-anchor-file:", "keys")`` (not shown in
example) can be used to use auto-updated keys (with RFC5011), the file is read
from and written to when the keys change. The probes have to be frequent enough
to not lose track, about every 15 days.

It is worth noting that with DNSSEC it is possible to verify nonexistence of
data. So, if the example above is modified to query for ``foobar.nlnetlabs.nl``
and with correct keys in the keys file, the output is no data, but the result is
secure.

DNSSEC has complicated verification procedures. The result is distilled into two
booleans, secure and bogus. Either the result is secure, the result is bogus, or
the result is neither of the two, called insecure. Insecure happens when no
DNSSEC security is configured for the domain name (or you simply forgot to add
the trusted key). Secure means that one of the trusted keys verifies the
signatures on the data. Bogus (security failed) can have many reasons, DNSSEC
protects against alteration of the data in transit, signatures can expire, the
trusted keys can be rolled over to fresh trusted keys, and many others. The
functions ``ub_ctx_debugout`` (sets a stream to log to) and
``ub_ctx_debuglevel`` (try level 2) can give more information about a security
failure. The ``why_bogus`` string as printed in the example above attempts to
give a detailed reason for the failure. An e-commerce application can simply
look at ``result->secure`` for its shopping server, and only continue if the
result is secure.