Setup the Context
=================

In the second example we set additional useful options on the context, to
enhance performance and utility. It is a modification of the example program
from the :doc:`resolve-a-name` section.

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

            ub_resolve_free(result);
            ub_ctx_delete(ctx);
            return 0;
    }

Invocation of this program yields the following:

.. code-block:: bash

    $ example_2
    The address is 213.154.224.1

As said, the code is a modification of the :doc:`first
example<resolve-a-name>`. The context is set up, a single name is
looked up, and the results and context are freed. The difference is that local
settings are applied.

The local DNS server settings (acquired from DHCP perhaps) are read from
``/etc/resolv.conf`` with ``ub_ctx_resolvconf``. Without reading this, Unbound
will use built-in root hints, this is a lot slower than using the DNS servers
from ``resolv.conf``. It makes a large difference, for me ``time example1``
takes about 0.25 seconds, and ``time example2`` takes about 0.05 seconds.

The difference is caused because the DNS proxy in ``resolv.conf`` has a cache of
often used data, and thus can resolve queries much faster. If you perform many
queries (and keep the unbound context around between calls to resolve) the time
difference will grow smaller over time, since a cache of data is kept inside the
context as well.

When you use ``ub_ctx_resolvconf`` libunbound becomes a stub resolver, not going
to the internet itself, but relying on the servers listed. Without the call, by
default, libunbound contacts the servers on the internet itself. A reason to not
use the servers from resolv.conf is because you do not trust them, or because
they lack support for DNSSEC, and you want to use DNSSEC validation.

.. Note:: Some people have complained about DNSSEC validation changing between
          secure and bogus, randomly. Often these are because they read a 
          ``resolv.conf`` that contains nameservers where some support DNSSEC 
          and some do not. If unbound detects that signatures are stripped from 
          the answer, it returns bogus.
    
The function ``ub_ctx_set_fwd(ctx, "192.168.0.1")`` (not shown in the example
program) can be used to set an explicit IPv4 or IPv6 address for the DNS server
to use. You can use this function to set DNS caching proxy server addresses that
are not listed in ``/etc/resolv.conf``.

If you wish to provide your own root-hints file, to override the built-in
values, you can use the power-user interface ``ub_ctx_set_option(ctx,
"root-hints:", "my-hints.root")``, and the file ``my-hints.root`` is read in
before the first name resolution.

The function ``ub_ctx_hosts`` is used to read ``/etc/hosts``. This allows
unbound to (very quickly) return addresses for hosts that are configured in
``/etc/hosts``. If you do not trust the ``/etc/hosts`` file, you can avoid
loading it. The addresses listed in the hosts file lack DNSSEC signatures, which
may affect their validation status later on. The hosts file is a very useful
configuration file to load, as it allows users to list addresses that are often
used, or addresses for hosts on their local network.

If you do not want your program to fail if ``/etc/resolv.conf`` or
``/etc/hosts`` do not exist at all, you can check if ``errno == ENOENT`` when
the reading functions fail, and act accordingly.