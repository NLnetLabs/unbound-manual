.. |br| raw:: html

   <br />

Resolver for Home Networks
==========================

To start off, let's ask the all-important question "Why would you want Unbound as a resolver for your home network?" |br|
First off, Unbound supports DNSSEC which, through an authentication chain, verifies that the DNS queries you send get a response from the appropriate server as opposed to anyone who has access to the query.
Secondly, by using your own resolver you can increase your DNS privacy. Because you're not sending out queries to parties who do the resolving for you (your ISP, Google, Cloudflare, Quad9, etc.), you bypass this middle man. While you still send out (parts of) your query unencrypted, you could configure Unbound to take it a step further, which we'll talk about in an upcoming guide.
Lastly, when you run your own resolver your DNS cache will be locally in your network. Even though the first time you resolve a domain name may be slightly slower than using your ISP’s resolver, all subsequent queries will likely be much faster.

In this tutorial we'll look at setting up Unbound as a DNS resolver; Firstly for your own machine, and then for your entire network.


Setting up Unbound
------------------

Unbound is a powerful validating, recursive, caching DNS resolver. It’s used by some of the biggest tech companies in the world as well as home users, who use it together with ad blockers and firewalls, or self-run resolvers. Setting it up for your home network can be quite simple as we’ll showcase below.

Setting up your own DNS resolver for your entire home network requires a couple of things. Namely, a recursive DNS resolver (who knew!), and a dedicated machine where the resolver runs, which is always on and accessible to the entire network. This can be as simple as a Raspberry Pi, or any other machine that is always online, connected to your home router.

Because of the variety of machines that Unbound can run on we cannot create a comprehensive tutorial for all possible options. For the extent of this tutorial we will use :command:`Ubuntu 20.04.1 LTS` as a stepping stone which you could use and adapt for other machines.

While you could download the code from Github and build it yourself, getting a copy can be as simple as running:

.. code-block:: bash

	sudo apt-get update
	sudo apt install unbound -y

This gives you a full, compiled, and running version of Unbound which behaves as a caching recursive DNS resolver out of the box for the local machine. 

.. after it has been written, link to the local-stub to show how to compile and build.

Do note that the current setup is only reachable on this machine.

Testing the server locally
--------------------------

To verify that the server works correctly it’s a good idea to test it before committing the entire network to it. Luckily we can test this on the machine that you installed Unbound on (locally) and from any other machine (remotely) that will be using the resolver after we expose Unbound to the network.

The command for local testing is:

.. code-block:: bash

	dig example.com @127.0.0.1

Here we tell the :command:`dig` tool to look up the IP address for example.com, and to ask this information to the server running at the IP address ``127.0.0.1``, which is where our Unbound machine is running by default.
We can verify that Unbound has indeed answered our query instead of the default resolver that is present on Ubuntu by default. In the output of every :command:`dig` command there is ``ANSWER SECTION`` which specifies the server which has answer the query under ``SERVER`` entry. The entry should be:

.. code-block:: bash

	;; SERVER: 127.0.0.1#53(127.0.0.1)

In the next section we will be disabling the default Ubuntu resolver. To verify that we do it correctly there it is useful to know the address of the default resolver as a baseline. For this baseline, we also use a :command:`dig` query but time without specifying an IP address which the uses the machines default DNS resolver.

.. code-block:: bash

	dig example.com

While the response should be the same, the ``SERVER`` in the response should look like:

.. code-block:: bash

	;; SERVER: 127.0.0.53#53(127.0.0.53)

Note that the final IPv4 digit is 53 and not 1, as with our Unbound instance.

Setting up for a single machine
-------------------------------

Now that we have configured and tested our Unbound server, we can tell our machine to use it by default. The nameserver (i.e. resolver) your machine uses by default is defined in :file:`/etc/resolv.conf`.
While just changing this file will work as long as the machine doesn't reboot, the more permanent and better solution is to replace the file with our own. The reason for this is that the :file:`resolv.conf` file is a `symbolic link`. We will remove the link and create a new file ourselves.

.. code-block:: bash

	rm /etc/resolv.conf

With your favourite text editor (if you don't have a favourite you could use :command:`nano`), we can then create a new file with the same name and fill it with the IP address that our Unbound instance is running at, and we include the :option:`edns0` option as this enables header extensions used in DNSSEC and is an overall standard used in DNS nowadays. |br|
So with :file:`nano /etc/resolv.conf` we create the new file and enter:

.. code-block:: bash

	nameserver 127.0.0.1
	options edns0

We then need to stop and disable the currently running pre-installed resolver. Note that you cannot go to new websites until the next step after this, as you have no DNS resolver assigned for the system.

.. code-block:: bash

	sudo systemctl disable systemd-resolved.service
	sudo systemctl stop systemd-resolved

Now the operating system should use our Unbound instance as default. A quick test a :command:`dig` without specifying the address of the Unbound server should give the same result as specifying it did above (with ``@127.0.0.1``).

.. code-block:: bash

	dig example.com

Note that the "SERVER" section in the output from :command:`dig` should also contain the local IP address of our server.

.. code-block:: bash

	;; SERVER: 127.0.0.1#53(127.0.0.1)

Setting up for the rest of the network
--------------------------------------

While we currently have a working instance of Unbound, we need it to be reachable from within our entire network. With that comes the headache of dealing with (local) IP addresses. It’s likely that your home router distributed local IP addresses to your devices. If this is the case (i.e. you didn’t change it by hand), they should be :rfc:`1918` ranges:

.. code-block:: bash

	10.0.0.0 - 10.255.255.255 (10/8)
	172.16.0.0 - 172.31.255.255 (172.16/12)
	192.168.0.0 - 192.168.255.255 (192.168/16)

To find the IP address of the machine that is running Unbound, we use:

.. code-block:: bash

	hostname --all-ip-addresses

If you just have one IP address as output from the :command:`hostname` command that will be the correct one. If you have multiple IP addresses the easiest way which IP address to use, is to find out which connection goes to your home router. Keep in mind that finding the wrong IP address here this can be a source of connectivity errors further on. For purpose of this tutorial we imagine that our home router has ``10.0.0.1`` as IP address, and our resolver machine (the machine that is running our Unbound instance) has ``10.0.0.2``, which we will get into in the next section.

As prerequisite for the next step we need to configure our Unbound instance to be reachable from other devices than only the machine on which the instance is running. The full example config is almost 1200 lines long, as the capabilities of Unbound are considerable, but we won’t need nearly as much. (If you are interested, any and all configurables can be found in the extensive manual page with :manpage:`unbound.conf`.

The example config is found at:

.. code-block:: bash

	/etc/unbound/unbound.conf

If you open this for the first time it looks very empty. It is still usable for one machine, as this is how the Unbound defaults are configured. It's not, however, enough for our purposes, so we will add the minimal configuration options needed.

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

The access-control is currently configured to listen to any address on the machine, and only allow queries from the ``10.0.0.0/8`` `IP subnet <https://www.ripe.net/about-us/press-centre/understanding-ip-addressing>`_ range. Note that the IP addresses we chose (``10.0.0.1`` and ``10.0.0.2``) fall within the ``10.0.0.0/8`` range.

To prepare our config we are going to modify the existing config in :file:`/etc/unbound/unbound.conf`.
If you open the file we see that there is already an “include” in there. This include enables us to do `DNSSEC <https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions>`_, which allows Unbound to verify the source of the answers that it receives, which we want to keep in. If you don't have the files that the include links to, they can be created using the :command:`unbound-anchor` command.

Using the text editor again, we can then add the minimal config as shown above, making any changes to the access control where needed. Do note that we strongly recommend keeping the :command:`include` that is already in the file. We also add the :command:`remote-control` in the config to enable controlling Unbound using :command:`unbound-control` command which is useful if you want to modify the config later on. When you are happy with your config, we first need to stop the currently running Unbound server and restart it with our new configuration. You can stop the currently running instance with:

.. code-block:: bash

	pkill -f unbound

And you can restart Unbound with:

.. code-block:: bash

	unbound -c /etc/unbound.conf

From this point on, we can stop, start, and reload the instance with :command:`unbound-control` if you want to make changes to the configuration.

Testing the resolver from a remote machine
------------------------------------------

So now we have a DNS resolver which should be reachable from within the network. To verify this we need to find the IP address of the resolver machine which can be found on the machine itself. For this tutorial we will use the address ``10.0.0.2`` (not ``127.0.0.1`` as we saw earlier) as an example. Armed with the IP address we can send a query to our DNS resolver from another machine which is within our home network. To do this we use the same dig command, only we change the IP address where the query is asked.

.. code-block:: bash

	dig example.com @10.0.0.2

This should give the same result, including the ``SERVER`` entry, as the query from the local test above.

Where it all comes together
---------------------------

We should now have a functioning DNS resolver that is accessible to all machines in our network (make sure you do before you continue). 

The next step then becomes a little tricky as there are many options and variations possible. We have a choice of which machines in our network will be using our configured DNS resolver. This can range from a single machine to all the machines that are connected. Since this tutorial cannot (and does not try to) be comprehensive for the range of choices, we will look at some of the basic examples which you can implement and expand on.

Most machines when they first connect to a network get a “recommended resolver” from your router using DHCP (Dynamic Host Configuration Protocol). To change this, we need to log into the router. To find the IP address of our home router we use which is likely be under :option:`default gateway`:

.. code-block:: bash

	ip route

When you've found the IP address of your home router, you can copy the address to a web browser, which should give you access to the router configuration portal. If you can't find the portal using this method, we suggest to consulting the manual or the manufacturer's website. When you have access, you should change the default gateway to the IP address of the machine running Unbound. In the case of our example, that would be 10.0.0.2.

Another possibility is a machine that does not use a resolver that is “recommended” by your router. This machine can be running its own resolver or be connected to a different one altogether. If you want these machines to use the Unbound resolver you set up, you need to change to configuration of the machine.



