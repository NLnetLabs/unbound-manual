Lookup from Threads
===================

This example shows how to use libunbound from a threaded program. It is a
modification of the example program from the :doc:`setup-context` section. It
creates two threads and resolves from both threads.

This example uses ``pthreads``, and assumes that libunbound was compiled with
threading enabled (which is the default, if ``pthreads`` can be found). To
compile the example pass the compiler the option ``-lpthread``.

.. code-block:: c

    #include <stdio.h>
    #include <string.h>
    #include <errno.h>
    #include <arpa/inet.h>
    #include <unbound.h>

    #include <pthread.h>

    /* The main function of the first thread */
    void* thread_one(void* threadarg)
    {
            struct ub_ctx* ctx = (struct ub_ctx*)threadarg;
            struct ub_result* result;
            int retval;
            /* query for webserver */
            retval = ub_resolve(ctx, "www.nlnetlabs.nl",
                    1 /* TYPE A (IPv4 address) */,
                    1 /* CLASS IN (internet) */, &result);
            if(retval != 0) {
                    printf("resolve error: %s\n", ub_strerror(retval));
                    return NULL;
            }

            /* show first result */
            if(result->havedata)
                    printf("Thread1: address of %s is %s\n", result->qname,
                            inet_ntoa(*(struct in_addr*)result->data[0]));

            /* exit thread */
            ub_resolve_free(result);
            return NULL;
    }

    /* The main function of the second thread */
    void* thread_two(void* threadarg)
    {
            struct ub_ctx* ctx = (struct ub_ctx*)threadarg;
            struct ub_result* result;
            int retval;
            /* query for webserver */
            retval = ub_resolve(ctx, "www.google.nl",
                    1 /* TYPE A (IPv4 address) */,
                    1 /* CLASS IN (internet) */, &result);
            if(retval != 0) {
                    printf("resolve error: %s\n", ub_strerror(retval));
                    return NULL;
            }

            /* show first result */
            if(result->havedata)
                    printf("Thread2: address of %s is %s\n", result->qname,
                            inet_ntoa(*(struct in_addr*)result->data[0]));

            /* exit thread */
            ub_resolve_free(result);
            return NULL;
    }

    int main(void)
    {
            struct ub_ctx* ctx;
            int retval;
            pthread_t t1, t2;

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

            /* start two threads, uses pthreads */
            pthread_create(&t1, NULL, thread_one, ctx);
            pthread_create(&t2, NULL, thread_two, ctx);
            /* wait for both threads to complete */
            pthread_join(t1, NULL);
            pthread_join(t2, NULL);

            ub_ctx_delete(ctx);
            return 0;
    }

Invocation of this program yields the following:

.. code-block:: text

    $ example_5
    Thread1: address of www.nlnetlabs.nl is 213.154.224.1
    Thread2: address of www.google.nl is 64.233.183.147

Sometimes, the result from thread 2 is printed first.

The example starts at the ``main`` program function. The unbound context is
created and ``resolv.conf`` and ``/etc/hosts`` are read in. Then, two threads
are started using ``pthread_create``. The main program continues with waiting
for those two threads to finish.

The first thread, ``thread_one``, starts by obtaining a pointer to the unbound
context from the thread argument. Then, www.nlnetlabs.nl is resolved, using the
regular ``ub_resolve``. The result is printed, and freed and the thread exits
with ``return NULL``.

The second thread, ``thread_two``, does the same as the first thread, but looks
up www.google.nl instead.

Using threads is easy when the context is created with ``ub_ctx_create``. In
this example, when both threads start resolving, they act as a 2-threaded
resolver, and share results, validation outcomes and data. When one of the
threads finishes its lookup, the other thread continues as a 1-threaded
resolver. When the resolver is created with ``ub_ctx_create_event`` or
``ub_ctx_create_ub_event``, with an event base, then it can only be accessed
from one thread, usually the one that is running that event loop.

This example uses blocking resolution for both threads. You can use asynchronous
resolution in threaded programs too. The function ``ub_resolve_async`` is used
to perform a background lookup. The calling thread continues executing while the
background lookup is in progress.

The application can decide if it wants the background lookup to be performed
from a (forked) process or from a (newly created) thread, by setting
``ub_ctx_async``. The default is to fork. The asynchronous resolution process or
thread is deleted when ``ub_ctx_delete`` is called.

Callbacks from asynchronous lookups are performed when ``ub_process`` is called,
just like in a single-threaded program. The thread from which the callbacks are
called is the thread from which ``ub_process`` has been called. It is the
responsibility of the application to signal other threads that lookup results
are available.

It is possible to have a thread wait for the file descriptor from ``ub_ctx_fd``
(a pipe) to become readable, and process any pending lookup results with
``ub_process``.