Performance Tuning
==================

Most users will probably not have a need to tune and optimise their Unbound
installation, but it could be useful for large resolver installations. This page
contains recommendations based on user feedback. If you have different
experiences or have recommendations, please share them on the `Unbound users
mailing list <https://lists.nlnetlabs.nl/mailman/listinfo/unbound-users>`_.

Configuration
-------------

Set :ref:`num-threads:<unbound.conf.num-threads>` equal to the number of CPU
cores on the system.
For example, for 4 CPUs with 2 cores each, use 8.

On Linux, set :ref:`so-reuseport: yes<unbound.conf.so-reuseport>`, that will
significantly improve UDP performance (on kernels that support it, otherwise it
is inactive, the :doc:`/manpages/unbound-control` status command shows if it is
active).

Set ``*-slabs`` to a power of 2 close to the ``num-threads`` value.
Do this for
:ref:`msg-cache-slabs:<unbound.conf.msg-cache-slabs>`,
:ref:`rrset-cache-slabs:<unbound.conf.rrset-cache-slabs>`,
:ref:`infra-cache-slabs:<unbound.conf.infra-cache-slabs>` and
:ref:`key-cache-slabs:<unbound.conf.key-cache-slabs>`.
This reduces lock contention.

Increase the memory size of the cache.
Use roughly twice as much rrset cache memory as you use msg cache memory.
For example, :ref:`rrset-cache-size: 100m<unbound.conf.rrset-cache-size>` and
:ref:`msg-cache-size: 50m<unbound.conf.msg-cache-size>`.
Due to malloc overhead, the total memory usage is likely to rise to double (or
2.5x) the total cache memory that is entered into the configuration.

Set the :ref:`outgoing-range:<unbound.conf.outgoing-range>` to as large a value
as possible, see the sections below on how to overcome the limit of 1024 in
total.
This services more clients at a time.
With 1 core, try 950.
With 2 cores, try 450.
With 4 cores try 200.
The :ref:`num-queries-per-thread:<unbound.conf.num-queries-per-thread>` is best
set at half the number of the ``outgoing-range``, but you would like a whole
lot to be able to soak up a spike in queries.
Because of the limit on ``outgoing-range`` thus also limits
``num-queries-per-thread``, it is better to compile with ``libevent`` (see the
section below), so that there is no more 1024 limit on ``outgoing-range``.

Set :ref:`so-rcvbuf:<unbound.conf.so-rcvbuf>` to a larger value (4m or 8m) for a
busy server.
This sets the kernel buffer larger so that no messages are lost in spikes in
the traffic.
Adds extra 9s to the reply-reliability percentage.
The OS caps it at a maximum, on Linux, Unbound needs root permission to bypass
the limit, or the admin can use ``sysctl net.core.rmem_max``.
On BSD change ``kern.ipc.maxsockbuf in /etc/sysctl.conf``.

On OpenBSD change header and recompile kernel.
On Solaris ``ndd -set /dev/udp udp_max_buf 8388608``.

Also set :ref:`so-sndbuf:<unbound.conf.so-sndbuf>` to a larger value (4m or 8m)
for a busy server.
Same as ``so-rcvbuf``, but now for spikes in replies, and it is
``net.core.wmem_max``.
Might need a smaller value, as spikes are less common in replies, you can see
rcv and snd buffer overruns with ``netstat -su``, ``RcvbufErrors`` and
``SndbufErrors``, and similar reports on BSD.

For the TCP listen backlog on Linux, it is possible to tweak the kernel
parameters to allow larger values. Unbound attempts to increase this to enable
it to handle spikes in incoming TCP or TLS connections. The number that unbound
attempts is defined in ``TCP_BACKLOG`` in ``services/listen_dnsport.c``, it does
not need to be changed if the current value, about 256, is sufficient for you.
However, the Linux kernel limits this value silently to a maximum configured
into the kernel settings. The kernel can be tweaked to enable a higher number
with ``net.core.somaxconn = 256`` and ``net.ipv4.tcp_max_syn_backlog = 256``.

Here is a short summary of optimisation config:

.. code-block:: text

    # some optimisation options.
    server:
        # use all CPUs
        num-threads: <number of cores>

        # power of 2 close to num-threads
        msg-cache-slabs: <same>
        rrset-cache-slabs: <same>
        infra-cache-slabs: <same>
        key-cache-slabs: <same>

        # more cache memory, rrset=msg*2
        rrset-cache-size: 100m
        msg-cache-size: 50m

        # more outgoing connections
        # depends on number of cores: 1024/cores - 50
        outgoing-range: 950

        # Larger socket buffer.  OS may need config.
        so-rcvbuf: 4m
        so-sndbuf: 4m

        # Faster UDP with multithreading (only on Linux).
        so-reuseport: yes

The default setup works fine, but when a large number of users have to be
served, the limits of the system are reached. Most pressing is the number of
file descriptors, the default has a limit of 1024. To use more than 1024 file
descriptors, use libevent or the forked operation method. These are described in
sections below.

Using Libevent
--------------

Libevent is a BSD licensed cross platform wrapper around platform specific event
notification system calls. Unbound can use it to efficiently use more than 1024
file descriptors. Install ``libevent`` (and ``libevent-devel``, if it exists)
with your favorite package manager. Before compiling unbound run:

.. code-block:: bash

    ./configure --with-libevent

Now you can give any number you like for
:ref:`outgoing-range:<unbound.conf.outgoing-range>`.
Also increase the
:ref:`num-queries-per-thread:<unbound.conf.num-queries-per-thread>` value.

.. code-block:: text

    # with libevent
    outgoing-range: 8192
    num-queries-per-thread: 4096

Users report that libevent-1.4.8-stable works well. Users have confirmed it
works well on Linux and FreeBSD with 4096 or 8192 as values.
Double the :ref:`num-queries-per-thread:<unbound.conf.num-queries-per-thread>`
and use that as :ref:`outgoing-range:<unbound.conf.outgoing-range>`.

Stable(old) distributions can package older versions (such as libevent-1.1), for
which there are crash reports, thus you may need to upgrade your libevent. In
unbound 1.2.0 a race condition in the libevent calls was fixed.

Unbound can compile from the libevent or libev build directory to make this
easy; e.g.,

.. code-block:: bash

    configure --with-libevent=/home/user/libevent-1.4.8-stable

or

.. code-block:: bash

    configure --with-libevent=/home/user/libev-3.52

.. note::
   If you experience crashes anyway, then you can try the following.  Update
   libevent. If the problem persists, libevent can be made to use different
   system-call back-ends by setting environment variables.  Unbound reports the
   back-end in use when verbosity is at level 4. By setting ``EVENT_NOKQUEUE``,
   ``EVENT_NODEVPOLL``, ``EVENT_NOPOLL``, ``EVENT_NOSELECT``, ``EVENT_NOEPOLL``
   or ``EVENT_NOEVPORT`` to yes in the shell before you start unbound, some
   back-ends can be excluded from use. The *poll(2)* backend is reliable, but
   slow.

Forked Operation
----------------

Unbound has a unique mode where it can operate without threading. This can be
useful if libevent fails on the platform, for extra performance, or for creating
walls between the cores so that one cannot poison another.

To compile for forked operation, before compilation use:

.. code-block:: bash

    ./configure --without-pthreads --without-solaris-threads

This disables threads and enable forked operation.
Because no locking has to be done, the code speeds up (about 10 to 20%).

In the configuration file, :ref:`num-threads:<unbound.conf.num-threads>` still
specifies the number of cores you want to use (even though it uses processes
and not threads).
And note that the :ref:`outgoing-range:<unbound.conf.outgoing-range>` and cache
memory values are all per thread.
This means that much more memory is used, as every core uses its own cache.
Because every core has its own cache, if one gets cache poisoned, the others
are not affected.

.. code-block:: text

    # with forked operation
    server:
        # use all CPUs
        num-threads: <number of cores>

        msg-cache-slabs: 1
        rrset-cache-slabs: 1
        infra-cache-slabs: 1
        key-cache-slabs: 1

        # more cache memory, rrset=msg*2
        # total usage is 150m*cores
        rrset-cache-size: 100m
        msg-cache-size: 50m

        # does not depend on number of cores
        outgoing-range: 950
        num-queries-per-thread: 512

        # Larger socket buffer.  OS may need config.
        so-rcvbuf: 4m

Because every process is using at most 1024 file descriptors now, the effective
maximum is the number of cores * 1024. The configuration above uses 950 per process,
for 4 processes gives a respectable 3800 sockets. The number of queries per
thread is half the number of sockets, to guarantee that every query can get a
socket, and some to spare for queries-for-nameservers.

Using forked operation together with libevent is also possible. It may be useful
to force the OS to service the file descriptors for different processes, instead
of threads. This may have (radically) different performance if the underlying
network stack uses (slow) lookup structures per-process.
