Asynchronous Lookup
===================

This example performs the name lookup in the background. The original program
keeps running, while the name is resolved. It is a modification of the example
program from the :doc:`resolve-a-name` section.

.. code-block:: c

    #include <stdio.h>
    #include <arpa/inet.h>
    #include <unistd.h>
    #include <unbound.h>

    /* This is called when resolution is completed */
    void mycallback(void* mydata, int err, struct ub_result* result)
    {
            int* done = (int*)mydata;
            *done = 1;
            if(err != 0) {
                    printf("resolve error: %s\n", ub_strerror(err));
                    return;
            }
            /* show first result */
            if(result->havedata)
                    printf("The address of %s is %s\n", result->qname,
                            inet_ntoa(*(struct in_addr*)result->data[0]));

            ub_resolve_free(result);
    }

    int main(void)
    {
            struct ub_ctx* ctx;
            volatile int done = 0;
            int retval;
            int i = 0;

            /* create context */
            ctx = ub_ctx_create();
            if(!ctx) {
                    printf("error: could not create unbound context\n");
                    return 1;
            }

            /* asynchronous query for webserver */
            retval = ub_resolve_async(ctx, "www.nlnetlabs.nl",
                    1 /* TYPE A (IPv4 address) */,
                    1 /* CLASS IN (internet) */,
                    (void*)&done, mycallback, NULL);
            if(retval != 0) {
                    printf("resolve error: %s\n", ub_strerror(retval));
                    return 1;
            }

            /* we keep running, lets do something while waiting */
            while(!done) {
                    usleep(100000); /* wait 1/10 of a second */
                    printf("time passed (%d) ..\n", i++);
                    retval = ub_process(ctx);
                    if(retval != 0) {
                            printf("resolve error: %s\n", ub_strerror(retval));
                            return 1;
                    }
            }
            printf("done\n");

            ub_ctx_delete(ctx);
            return 0;
    }

Invocation of this program yields the following:

.. code-block:: text

    $ example_4
    time passed (0) ..
    time passed (1) ..
    time passed (2) ..
    The address of www.nlnetlabs.nl is 213.154.224.1
    done

If resolution takes longer or shorter, the output can vary.

The context is created. Then an asynchronous resolve is performed. This performs
the name resolution work in the background, allowing your application to
continue to perform tasks (like showing a GUI to the user).

The function to start a background, asynchronous, resolve is
``ub_resolve_async``. It takes the usual context, name, type and class as
arguments. Additionally it takes a user argument, callback function and an id as
arguments. In the example, the user argument is a reference to the variable
done. It can be any pointer you like, or NULL if you don't care. The callback
function is a pointer to a function, like ``mycallback`` in the example, that is
invoked when the lookup is done.

The optional id argument is omitted in the example by passing NULL. If you pass
an int*, an identifier is returned to you, that allows subsequent cancellation
of the outstanding resolve request. The function ``ub_cancel`` can be used while
the asynchronous lookup has not completed yet to cancel it (not shown in the
example).

After requesting the lookup the main function continues with a while loop, that
prints time increments. Every time increment ``ub_process`` is called. This
function processes pending lookup results and an application has to call
``ub_process`` somewhere to be able to receive results from asynchronous
queries. The function ``ub_process`` does not block. The callback function is
called from within ``ub_process``.

The callback is called after some time, in the example it is called
``mycallback``. This function receives as its first argument the same value you
passed as user argument to ``ub_resolve_async``. It also receives the error code
and a result structure. If the error code is not 0 (an error happened), the
result is NULL. The result structure contains the lookup information.

The example callback uses its first argument to set done to true, to signal the
main function that lookup has completed. It then checks if an error happened,
and prints it if so. If there was no error it prints the first data element of
the result. (It doesn't check the result very closely, this is only an example).

When the main function sees that after a call to ``ub_process`` the variable
done is true, it exits the waiting loop, and deletes the context. The delete of
the context also stops the background resolution process and removes the cached
data from memory.

You do not have to call ``ub_process`` all the time. The function ``ub_poll``
(not shown in example) returns true when new data is available (without calling
any callbacks). The function ``ub_fd`` (not shown in example) returns a file
descriptor that becomes readable when new data is available (for use with
``select()`` or similar system calls).

The function ``ub_wait`` (not shown in example) can be used to wait for the
asynchronous lookups to complete. For example, when the main program continues
to set up a user GUI after starting the lookup, then if it runs out of work
before the result arrives, it can use ``ub_wait`` to block until data arrives.
