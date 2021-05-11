Resolver for Home Networks
==========================

To start off, let's ask the all-important question "Why would you want Unbound for your home network?".

First off, Unbound supports DNSSEC which, through an authenication chain, verifies that the DNS queries you send get a response from the appropriate server as opposed to anyone who has access to the query.
Secondly, by using your own resolver you can increase your DNS privacy. Because you're not sending out queries to parties who do the resolving for you (your ISP, Google, Cloudflare, Quad9, etc.), you bypass this middle man. While you still send out (parts of) your query unencrypted, you could configure Unbound to take it a step further. [LINK maximum privacy resolver].
Lastly, in some cases running your own resolver could increase the speed of the resolving DNS queries and therefore decrease the time it takes for your web page to load.

In this tutorial we'll look at setting up unbound; Firstly for your own machine, and then for your entire network.


Setting up Unbound
------------------

Unbound is a powerful validating, recursive, caching DNS resolver. It’s used by some of the biggest tech companies in the world and also by home users who use it for ad blockers and firewalls, or self-run resolvers. Setting it up for your home network can be quite simple as we’ll showcase below.

Setting up your own DNS resolver for your entire home network requires a couple of things. Namely, a recursive DNS resolver (who knew!), and a dedicated machine where the resolver runs, which is always on and accessible to the entire network. This can be as simple as a Raspberry Pi connected to your home router or any other machine that is always online.

Because of the variety of machines that Unbound can run on we cannot create a comprehensive tutorial for all possible options. For the extent of this tutorial we will use Ubuntu as a stepping stone which you could use for other machines. For this tutorial ``Ubuntu 20.04.1 LTS`` was used.

While you could download the code from Github and build it yourself, getting a copy can be as simple as running:

.. code-block:: bash

	apt install unbound -y

This gives you a full, compiled, and running version of Unbound which behaves as a caching recursive DNS resolver out of the box for the local machine. 
.. after it has been written, link to the local-stub to show how to compile and build.

Do note that the current setup is only reachable on this machine.

Testing the server locally
--------------------------

To verify that the server works correctly it’s a good idea to test it before committing the entire network to it. Luckily we can test this on the machine that you installed Unbound on (local) and from any other machine (remote) that will be using the resolver after we expose Unbound to the network.

The command for local testing is:

.. code-block:: bash

	dig example.com @127.0.0.1

Here we tell the dig tool to look up the IP address for example.com, and to ask this information to the server running at the IP address ``127.0.0.1``, which is where our Unbound machine is running.
Note on the output from ``dig`` there is a "SERVER" entry in the Answer section where, hopefully, we can verify that the server has indeed answered our query. It should look like ``;; SERVER: 127.0.0.1#53(127.0.0.1)``.

To make checking later easier we can also do a ``dig`` query without specifying an IP address which the uses the machines default DNS resolver.

.. code-block:: bash

	dig example.com

Here the SERVER in the response should look like ``;; SERVER: 127.0.0.53#53(127.0.0.53)``.

Setting up for a single machine
-------------------------------

Now that we have configured and tested our Unbound server, we can tell our machine to use it by default. We do this at ``/etc/systemd/resolved.conf``. In ``resolved.conf`` we change the current entry under ``[Resolve]`` to use our own instance running at ``127.0.0.1 ``. This is done by adding/subsituting the following.

.. code-block:: bash

	DNS=127.0.0.1

We then need to stop the currently running pre-installed resolver. Note taht you lose connectivity to the web untill the next step.

.. code-block:: bash

	sudo systemctl disable systemd-resolved.service
	sudo systemctl stop systemd-resolved

Now we can start the network manager again, and start using our new configuration.

.. code-block:: bash

	sudo systemctl restart NetworkManager.service

And as a quick test a ``dig`` without specifying our Unbound server should give the same result as specifying it (with the ``@127.0.0.1`` like we did above).

.. code-block:: bash

	dig example.com

Note that the "SERVER" section in the output from ``dig`` should also contain the local IP address of our server.

.. code-block:: bash

	;; SERVER: 127.0.0.1#53(127.0.0.1)

Setting up for the rest of the network
--------------------------------------

While we currently have a working instance of Unbound, we need it to be reachable from within our entire network. With that comes the headache of dealing with IP addresses. It’s likely that your home router distributed local IP addresses to your devices. If this is the case (i.e. you didn’t change it by hand), the ranges should be between [:rfc:`1918`]:

.. code-block:: bash

	10.0.0.0 - 10.255.255.255 (10/8)
	172.16.0.0 - 172.31.255.255 (172.16/12)
	192.168.0.0 - 192.168.255.255 (192.168/16)

The Unbound example config uses the ``10.0.0.0/8``, so that’s what we use in this example, but note that this can be a source of connectivity errors further on.

Let’s look at a snippet of the example config file. The full example config is almost 1200 lines long, as the capabilities of Unbound are considerable, but we won’t need nearly as much. (If you are interested, any and all configurables can be found in the extensive manual page with ``man unbound.conf``)

The example config is found at:

.. code-block:: bash

	/etc/unbound/unbound.conf

if you open this for the first time it looks very empty. It is still usable for one machine, as this is how all the Unbound defaults are configured. It's not, however, enough for our purposes so we will add the minimal configuration options.

The options that we add to the current config file to make it a "minimal usable config" are as follows. Note that the IPv6 options are commented out, but we recommend to uncomment them if your router and network supports it.

.. code-block:: bash

	server:
			# location of the trust anchor file that enables DNSSEC
			auto-trust-anchor-file: "/var/lib/unbound/root.key"
            # the interface that is used to connect to the network, this means on this machine
            interface: 0.0.0.0
            # interface: ::0
            # addresses from the IP range that are allowed to connect to the resolver
            access-control: 10.0.0.0/8 allow
            # access-control: 2001:DB8.. code-block:: bash/64 allow
    remote-control:
    		control-enable: yes

The access-control is currently configured to listen to any address on the machine, and only allow queries from the ``10.0.0.0/8`` IP range.

To prepare our config we are going to modify the existing config in ``/etc/unbound/unbound.conf``. 
If you open the file we see that there is already an “include” in there. This include enables us to do DNSSEC, which allows Unbound to verify the source of the answers that it receives [LINK ?], so we want to keep this. If you don't have the files that the unclude links to, they can be created using the ``unbound-anchor`` command.

With your favourite text editor then add the minimal config as shown above, making any changes to the access control where needed. Do note that we strongly recommend to keep the ``include`` that is already in the file. We also add the ``remote-control`` in the config to enable controlling Unbound using ``unbound-control``. When you are happy with your config, we first need to kill the currently running Unbound server and restart it with our new configuration.


you can stop the currently running instance with 

.. code-block:: bash

	pkill -f unbound

And you can restart Unbound with:

.. code-block:: bash

	unbound -c /etc/unbound.conf

From this point on, we can stop, start, and reload the instance with ``unbound-control`` if you want to make changes to the configuration.

Testing the resolver from a remote machine
------------------------------------------

So now we have a DNS resolver which should be reachable from within the network. To verify this we need to find the IP address of the resolver machine which can be found on the machine itself. For this tutorial we will use the address ``10.10.10.10`` (not ``127.0.0.1`` as we saw earlier) as an example. Armed with the IP address we can send a query to our DNS resolver from another machine which is within our home network. To do this we use the same dig command, only we change the IP address where the query is asked.

.. code-block:: bash

	dig example.com @10.10.10.10

This should give the same result as the query from the local test.


Where it all comes together
---------------------------

We should now have a functioning DNS resolver that is accessible to all machines in our network. 

The next step then becomes a little tricky as there are many options and variations possible. We have a choice of which machines in our network will be using our configured DNS resolver. This can range from a single machine to all the machines that are connected. Since this tutorial cannot (and does not try to) be comprehensive for the range of choices, we wil look at some of the basic examples which you can implement and expand on.

Most machines when they first connect to a network get a “recommended resolver” from your router using DHCP (Dynamic Host Configuration Protocol). To change this, we need to log into the router. To do this we use:

.. code-block:: bash

	ip route

There is a good change you will find either ``192.168.1.1`` or ``192.168.0.1``, which when copied to a web browser should give you access to the router configuration portal. If you can't find the portal using this method, we suggest to consulting the manual or the manifacturers website.

Another possibility is a machine that does not use a resolver that is “recommended” by your router. This machine can be running its own resolver or be connected to a different one altogether. If you want these machines to use the Unbound resolver you set up, you need to change to configuration of the machine.



