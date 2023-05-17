Examine the Results
===================

In the third example, the results returned are examined in detail. In addition,
the program is modified to accept an argument, the name to look up. It is a
modification of the example program from the :doc:`setup-context` section.

.. code-block:: c

    #include <stdio.h>
    #include <string.h>
    #include <errno.h>
    #include <arpa/inet.h>
    #include <unbound.h>

    /* examine the result structure in detail */
    void examine_result(char* query, struct ub_result* result)
    {
            int i;
            int num;

            printf("The query is for: %s\n", query);
            printf("The result has:\n");
            printf("qname: %s\n", result->qname);
            printf("qtype: %d\n", result->qtype);
            printf("qclass: %d\n", result->qclass);
            if(result->canonname)
                    printf("canonical name: %s\n",
                            result->canonname);
            else    printf("canonical name: <none>\n");

            if(result->havedata)
                    printf("has data\n");
            else    printf("has no data\n");

            if(result->nxdomain)
                    printf("nxdomain (name does not exist)\n");
            else    printf("not an nxdomain (name exists)\n");

            if(result->secure)
                    printf("validated to be secure\n");
            else    printf("not validated as secure\n");

            if(result->bogus)
                    printf("a security failure! (bogus)\n");
            else    printf("not a security failure (not bogus)\n");

            printf("DNS rcode: %d\n", result->rcode);
            printf("\n");

            num = 0;
            for(i=0; result->data[i]; i++) {
                    printf("result data element %d has length %d\n",
                            i, result->len[i]);
                    printf("result data element %d is: %s\n",
                            i, inet_ntoa(*(struct in_addr*)result->data[i]));
                    num++;
            }
            printf("result has %d data element(s)\n", num);
    }

    int main(int argc, char** argv)
    {
            struct ub_ctx* ctx;
            struct ub_result* result;
            int retval;

            if(argc != 2) {
                    printf("usage: <hostname>\n");
                    return 1;
            }

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

            /* query for webserver */
            retval = ub_resolve(ctx, argv[1],
                    1 /* TYPE A (IPv4 address) */,
                    1 /* CLASS IN (internet) */, &result);
            if(retval != 0) {
                    printf("resolve error: %s\n", ub_strerror(retval));
                    return 1;
            }
            examine_result(argv[1], result);

            ub_resolve_free(result);
            ub_ctx_delete(ctx);
            return 0;
    }

Invocation of this program yields the following:

.. code-block:: text

    $ example_3 www.nlnetlabs.nl
    The query is for: www.nlnetlabs.nl
    The result has:
    qname: www.nlnetlabs.nl
    qtype: 1
    qclass: 1
    canonical name: <none>
    has data
    not an nxdomain (name exists)
    not validated as secure
    not a security failure (not bogus)
    DNS rcode: 0

    result data element 0 has length 4
    result data element 0 is: 213.154.224.1
    result has 1 data element(s)

This example add the option to specify the name too lookup from the commandline,
and this name is found in ``argv[1]``. The name is looked up and
``examine_result`` is called to printout a detailed account of the results.

The ``qname``, ``qtype`` and ``qclass`` fields show the question that was asked to
``ub_resolve``.

The canonical name may be set if you query for an alias, in that case the
alternate name for the host is set here.

The boolean value ``hasdata`` is true when at least one data element is
available.

The boolean value ``nxdomain`` is true, when no data is available because the
name queried for does not exist.

The boolean value ``secure`` is true when public key signatures on the answer
are are valid. It is also possible for responses without data to be secure.

The boolean value ``bogus`` is true when security checks failed. The
authenticity of the content, and the absence or presence of it, failed security
checks. This happens when, for example, you use the wrong public keys for
validation, or if the data was altered in transit.

If both ``secure`` and ``bogus`` are false this indicates there was no security
information for that domain name.

The ``rcode`` value indicates the exact DNS error code. If there is no data, it
may explain why (the servers encountered errors). If there is no data and the
name does not exist (so ``nxdomain`` is true), the ``rcode`` value is 3
(NXDOMAIN). If there is no data, and the name does exist (it does not have this
type of data) the ``rcode`` is 0 (NOERROR). Other error codes indicate some sort
of failure, mostly a failure at the DNS server.

The example prints all the data elements and their length.

Here are some other results that you can get. The first is an alias, with
several addresses, and the second is a nonexistent name:

.. code-block:: text

    $ example_3 www.google.nl
    The query is for: www.google.nl
    The result has:
    qname: www.google.nl
    qtype: 1
    qclass: 1
    canonical name: www.l.google.com.
    has data
    not an nxdomain (name exists)
    not validated as secure
    not a security failure (not bogus)
    DNS rcode: 0

    result data element 0 has length 4
    result data element 0 is: 64.233.183.99
    result data element 1 has length 4
    result data element 1 is: 64.233.183.104
    result data element 2 has length 4
    result data element 2 is: 64.233.183.147
    result has 3 data element(s)

    $ example_3 bla.bla.nl
    The query is for: bla.bla.nl
    The result has:
    qname: bla.bla.nl
    qtype: 1
    qclass: 1
    canonical name: <none>
    has no data
    nxdomain (name does not exist)
    not validated as secure
    not a security failure (not bogus)
    DNS rcode: 3

    result has 0 data element(s)
