Resolver for Home Networks
==========================

To start off, let's ask the all-important question "Why would you want Unbound
as a resolver for your home network?" 

Firstly, Unbound supports DNSSEC which, through an authentication chain,
verifies that the DNS query responses you receive are unaltered, as opposed to
query responses which are not DNSSEC-signed and could be changed by anyone who
has access to the query. Secondly, by using your own resolver you stop sharing
your DNS traffic with third parties and increase your DNS privacy. While you
still send out (parts of) your queries unencrypted, you could configure Unbound
to take it a step further, which we'll talk about in an upcoming guide. Lastly,
when you run your own resolver your DNS cache will be local to your network.
Even though the first time you resolve a domain name may be slightly slower than
using your ISP’s resolver, all subsequent queries for the name will likely be
much faster.

In this tutorial we'll look at setting up Unbound as a DNS resolver; First for
your own machine, and then for your entire network.


Setting up Unbound
------------------

Unbound is a powerful validating, recursive, caching DNS resolver. It’s used by
some of the biggest tech companies in the world as well as small-office /
home-office users, who use it together with ad blockers and firewalls, or
self-hosted resolvers. Setting it up for your home network can be quite simple
as we’ll showcase below.

Setting up a caching DNS server for your entire home network requires a
recursive DNS resolver, and a dedicated machine on which the resolver runs; this
(small) system is always on and accessible to the entire network. It can be as
small as a Raspberry Pi or any other available Linux/Unix machine that is always
online and has Internet connectivity via your router.

Because of the variety of machines that Unbound can run on we cannot create a
comprehensive tutorial for all possible options. For this tutorial we will use
**Ubuntu 22.04 LTS** as a stepping stone you can adapt and apply to
other systems.

While you could download the code from GitHub and build it yourself, getting a
copy can be as simple as running:

.. code-block:: bash

    sudo apt update
    sudo apt install unbound -y

This gives you a complete and running version of Unbound which behaves as a
caching recursive DNS resolver out of the box for the system on which you
install it. You can check which version of Unbound you have installed with
``unbound -V``. The version installed will vary depending on the operating
system. If the version is installed is quite old (at the time of writing it
isn't) or you'd simply like to run the latest and greatest version you can
download the latest release tarball from our `website
<https://nlnetlabs.nl/projects/unbound/about/>`_ and build it yourself.

Do note that by default Unbound will be queriable only from the local host,
i.e. the system on which you installed Unbound.
We will change that later.

Testing the resolver locally
----------------------------

To verify that the server works correctly, it’s a good idea to test it before
committing the entire network to it. Luckily we can test this on the machine
that you installed Unbound on (locally) and from any other machine (remotely)
that will be using the resolver after we expose Unbound to the network.

The command for testing locally on the Unbound machine is:

.. code-block:: bash

    dig example.com @127.0.0.1

Here we tell the :command:`dig` tool to look up the IP address for example.com,
and to ask for this information from the resolver running at the IP address
``127.0.0.1``, which is where our Unbound machine is running by default. We can
verify that Unbound has indeed answered our query instead of the default
resolver that is present on Ubuntu by default. In the output of every
:command:`dig` command there is an ``ANSWER SECTION`` which gives the response
to the query. In the footer section of the output, the server which has answered
the query under the ``SERVER`` entry. The entry will look like:

.. code-block:: text

    ;; SERVER: 127.0.0.1#53(127.0.0.1)

In the next section we will be disabling the default Ubuntu resolver. To verify
that we do it correctly it is useful to know the address of the default resolver
as a baseline. For this baseline we also use a :command:`dig` query, but this
time without specifying an IP address (which causes dig to use the machine's
default DNS resolver).

.. code-block:: bash

    dig example.com

While the response should be the same, the ``SERVER`` entry in the response
should look like:

.. code-block:: text

    ;; SERVER: 127.0.0.53#53(127.0.0.53)

Note that the final IPv4 digit is 53 and not 1, as with our Unbound instance.

Setting up for a single machine
-------------------------------

Now that we have tested our Unbound resolver, we can tell our machine to use it
by default. The resolver your machine uses by default is defined in
:file:`/etc/systemd/resolved.conf` in the ``DNS`` entry (It uses ``127.0.0.53``
). While just changing this file will work as long as the machine doesn't
reboot, we need to make sure that this change is persistent. To do that, we need
to change the ``DNS`` entry to be equal to ``127.0.0.1`` so the machine uses
Unbound as default. To make the change persistent, we also need to set the
``DNSStubListener`` to ``no`` so that is not changed by our router (such as with
a "recommended resolver" mentioned below). We also want to enable the ``DNSSEC``
option so that we can verify the integrity the responses we get to our DNS
queries. With your favourite text editor (e.g. :command:`nano`) we can modify
the file:

.. code-block:: bash

    nano /etc/systemd/resolved.conf

Here, under the ``[Resolve]`` section we add (or rather, enable by removing the
"#") the options:

.. code-block:: text

    [Resolve]
    DNS=127.0.0.1
    #FallbackDNS=
    #Domains=
    DNSSEC=yes
    #DNSOverTLS=no
    #MulticastDNS=no
    #LLMNR=no
    #Cache=no-negative
    DNSStubListener=no
    #DNSStubListenerExtra=

To actually have the system start using Unbound, we then need to create a symlink to overwrite :file:`/etc/resolv.conf` to the one we modified.

.. code-block:: bash

    ln -fs /run/systemd/resolve/resolv.conf /etc/resolv.conf

With this file modified, we can restart using this configuration with: 

.. code-block:: bash

    systemctl restart systemd-resolved

If successful, the operating system should use our Unbound instance as default.
A quick test a :command:`dig` without specifying the address of the Unbound
server should give the same result as specifying it did above (with
``@127.0.0.1``).

.. code-block:: bash

    dig example.com

Note that the "SERVER" section in the output from :command:`dig` should also
contain the local IP address of our server.

.. code-block:: text

    ;; SERVER: 127.0.0.1#53(127.0.0.1)


Setting up for the rest of the network
--------------------------------------

While we currently have a working instance of Unbound, we need it to be
reachable from within our entire network. With that comes the headache of
dealing with (local) IP addresses. It’s likely that your home router distributed
local IP addresses to your devices. If this is the case (i.e. you didn't change
it by hand), they should be :rfc:`1918` ranges:

.. code-block:: text

    10.0.0.0 - 10.255.255.255 (10/8)
    172.16.0.0 - 172.31.255.255 (172.16/12)
    192.168.0.0 - 192.168.255.255 (192.168/16)

To find the IP address of the machine that is running Unbound, we use:

.. code-block:: bash

    hostname --all-ip-addresses

If you just have one IP address as output from the :command:`hostname` command
that will be the correct one. If you have multiple IP addresses, the easiest way
to determine which IP address to use, is to find out which connection goes to
your home router. Keep in mind that using the wrong IP address here can be a
source of connectivity errors further on. For the purpose of this tutorial we
assume that our home router has the IP address ``192.168.0.1``, as this is
typical for home routers, and our resolver machine (the machine that is running
our Unbound instance) has IP address ``192.168.0.2``, which we will get into in
the next section.

As a prerequisite for the next step, we need to configure our Unbound instance
to be reachable from devices other than only the machine on which the Unbound is
running.
Unbound is a highly capable resolver, and as such has many options which can be
set; the full example configuration file is almost 1200 lines long, but we'll
need but a fraction of these settings.
(If you are interested, all configuration options are documented in the
extensive manual page of :doc:`/manpages/unbound.conf`).

The default configuration file is found at:

.. code-block:: text

    /etc/unbound/unbound.conf

If you open this for the first time it looks very empty. It is still usable as a
resolver for one machine, as this is how the Unbound defaults are configured.
It's not, however, enough for our purposes, so we will add the minimal
configuration options needed.

The options that we add to the current configuration file to make it a "minimal
usable configuration" are as follows.
Note that the IPv6 options are commented out, but we recommend to uncomment
them if your router and network supports it.

.. code-block:: text

    server:
        # location of the trust anchor file that enables DNSSEC
        auto-trust-anchor-file: "/var/lib/unbound/root.key"
        # send minimal amount of information to upstream servers to enhance privacy
        qname-minimisation: yes
        # the interface that is used to connect to the network (this will listen to all interfaces)
        interface: 0.0.0.0
        # interface: ::0
        # addresses from the IP range that are allowed to connect to the resolver
        access-control: 192.168.0.0/16 allow
        # access-control: 2001:DB8/64 allow

    remote-control:
        # allows controling unbound using "unbound-control"
        control-enable: yes

The interface is currently configured to listen to any address on the machine,
and the access-control only allows queries from the ``192.168.0.0/16`` `IP
subnet
<https://www.ripe.net/about-us/press-centre/understanding-ip-addressing>`_
range. Note that the IP address we chose above (``192.168.0.1`` and
``192.168.0.2``) fall within the ``192.168.0.0/16`` range.

To prepare our configuration we are going to modify the existing configuration in
:file:`/etc/unbound/unbound.conf`. If you open the file for the first time, you
see that there is already an “include” in there. The "include" enables us to do
`DNSSEC <https://www.sidn.nl/en/modern-internet-standards/dnssec>`_, which allows
Unbound to verify the source of the answers that it receives, as well as QNAME
minimisation. For convenience these configuration options have already been
added in the minimal configuration.
The configuration also includes the :ref:`remote-control:<unbound.conf.remote>`
section in the configuration to enable controlling Unbound using the
:doc:`/manpages/unbound-control` command, which is useful if you want to
modify the configuration on the fly later on.

Using the text editor again, we can then add the minimal configuration shown
above, making any changes to the access control where needed.
When we've modified the configuration we check it for mistakes with the
:doc:`/manpages/unbound-checkconf` command:

.. code-block:: bash

    unbound-checkconf unbound.conf

If this command reports no errors, we need to stop the currently running Unbound
instance and restart it with our new configuration. You can stop Unbound with:

.. code-block:: bash

    sudo pkill -f unbound

And you can restart Unbound with:

.. code-block:: bash

    unbound-control start

From this point on, we can :ref:`stop<unbound-control.commands.stop>`,
:ref:`start<unbound-control.commands.start>`, and
:ref:`reload<unbound-control.commands.reload>` Unbound with
:command:`unbound-control` if you want to make changes to the configuration.

Testing the resolver from a remote machine
------------------------------------------

So now we have a DNS resolver which should be reachable from within the network.
To be able to verify that our resolver is working correctly, we want to test it
from another machine in the network. As mentioned above, this tutorial uses the
address ``192.168.0.2`` (not ``127.0.0.1`` as we saw earlier) as an example for
the machine running Unbound. Armed with the IP address we can send a query to
our DNS resolver from another machine which is within our home network. To do
this we use the same dig command, only we change the IP address where the query
is asked.

.. code-block:: bash

    dig example.com @192.168.0.2

This should give the same result as above. The ``SERVER`` entry in the footer
reflects from which server the response was received.

Where it all comes together
---------------------------

We should now have a functioning DNS resolver that is accessible to all machines
in our network (**make sure you do before you continue**).

The next step then is a little tricky as there are many options and variations
possible. We have a choice of which machines in our network will be using our
configured DNS resolver. This can range from a single machine to all the
machines that are connected. Since this tutorial cannot (and does not try to) be
comprehensive for the range of choices, we will look at some of the basic
examples which you can implement and expand on.

Most machines when they first connect to a network get a “recommended resolver”
from your router using :abbr:`DHCP (Dynamic Host Configuration Protocol)`. To
change this, we need to log into the router. Earlier in this tutorial we assume
the home router was using ``192.168.0.1``, though in reality this can differ.
If this does differ, the unbound configuration needs to be changed as well.

To find the IP address of our home router, which is likely be under the
``default gateway`` entry from:

.. code-block:: bash

    ip route

When you've found the IP address of your home router, you can copy the address
to a web browser, which should give you access to the router configuration
portal. If you can't find the portal using this method, consult the manual or
the manufacturer's website. When you have access, you should change the DHCP
configuration to advertise the IP address of the machine running Unbound as the
default gateway. In the case of our example, that would be ``192.168.0.2``.

Another possibility is a machine that does not use a resolver that is
“recommended” by your router. This machine can be running its own resolver or be
connected to a different one altogether. If you want these machines to use the
Unbound resolver you set up, you need to change the configuration of the
machine.
