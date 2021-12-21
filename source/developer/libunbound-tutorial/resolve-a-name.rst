Resolve a Name
==============

First, obtain `ldns <https://www.nlnetlabs.nl/projects/ldns/about/>`_ and
:doc:`Unbound </getting-started/installation>`, compile and install them. To
compile a program with its library use this command, assuming unbound was
installed in ``/usr/local``:

.. code-block:: bash

    gcc -o program program.c -I/usr/local/include -L/usr/local/lib -lunbound 
    
First a basic example that shows how to create a context and resolve a host
address.

.. code-block:: c

    #include <stdio.h>      /* for printf */
    #include <arpa/inet.h>  /* for inet_ntoa */
    #include <unbound.h>    /* unbound API */

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

    $ example_1
    The address is 213.154.224.1

The code starts by including system header files and unbound.h. Then, the main
routine creates the context using the ``ub_ctx_create()`` function. If this
returns NULL, the program prints an error and exits.

Then, the domain name ``www.nlnetlabs.nl`` is resolved using the function
``ub_resolve()``. The ``ub_resolve`` invocation takes as arguments the context
that was just created, the domain name string and the type and class to lookup.
Results are returned in the ``ub_result`` structure, unless an error occurs. If
an error occurs, retval contains an error code and ``ub_strerror`` converts the
error code into a readable string, that is printed and the program exits.

If the resolve succeeds, then the results are printed. In this example, the
results are not examined in detail, but only if there is data, the first element
of data is printed. The ``result->havedata`` boolean indicates whether the
resolver found data, and ``result->data[0]`` is a pointer to the first element
of data. The standard C library routine ``inet_ntoa`` is used to print out the
IPv4 address.

Note that this example program neglects to examine ``result->len[0]`` for
simplicity. For security, such untrusted data from the internet should be
checked. That value should have been 4 (bytes), the length of IPv4 addresses.

At the end of the main routine, the results are freed with
``ub_resolve_free(result)`` and the context is deleted with ``ub_ctx_delete``.
If you perform multiple lookups, it is good to keep the context around, it
performs caching and that will speed up your responses.