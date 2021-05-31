.. |br| raw:: html

   <br />

Resolver for Home Networks
==========================

To start off, let's ask the all-important question "Why would you want Unbound as a resolver for your home network?" |br|
Firstly, Unbound supports DNSSEC which, through an authentication chain, verifies that the DNS query responses you receive are unaltered, as opposed to query responses which do not have a DNSSEC record and could be changed by anyone who has access to the query.
Secondly, by using your own resolver you stop sharing your DNS traffic with third parties (your ISP, Google, Cloudflare, Quad9, etc.) and increase your DNS privacy. While you still send out (parts of) your query unencrypted, you could configure Unbound to take it a step further, which we'll talk about in an upcoming guide.
Lastly, when you run your own resolver your DNS cache will be locally in your network. Even though the first time you resolve a domain name may be slightly slower than using your ISP’s resolver, all subsequent queries will likely be much faster.

In this tutorial we'll look at setting up Unbound as a DNS resolver; Firstly for your own machine, and then for your entire network.


Setting up Unbound
------------------

Unbound is a powerful validating, recursive, caching DNS resolver. It’s used by some of the biggest tech companies in the world as well as home users, who use it together with ad blockers and firewalls, or self-hosted resolvers. Setting it up for your home network can be quite simple as we’ll showcase below.

Setting up your own DNS resolver for your entire home network requires a couple of things. Namely, a recursive DNS resolver (who knew!), and a dedicated machine where the resolver runs, which is always on and accessible to the entire network. This can be as simple as a Raspberry Pi, or any other machine that is always online, connected to your home router.

Because of the variety of machines that Unbound can run on we cannot create a comprehensive tutorial for all possible options. For this tutorial we will use :command:`Ubuntu 20.04.1 LTS` as a stepping stone which you could use and adapt for other machines.

While you could download the code from GitHub and build it yourself, getting a copy can be as simple as running:

.. code-block:: bash

	sudo apt update
	sudo apt install unbound -y

This gives you a full, compiled, and running version of Unbound which behaves as a caching recursive DNS resolver out of the box for the local machine. You can check which version of Unbound you have installed with :option:`unbound -V`. The version installed will vary depending on the operating system. If the version is installed is quite old (at the time of writing it isn't) or you'd simply like to run the latest and greatest version you can download the latest release tarball from our `website <https://nlnetlabs.nl/projects/unbound/about/>`_ and build it yourself.

Do note that the current setup is only reachable on this machine.

Testing the resolver locally
----------------------------

To verify that the server works correctly, it’s a good idea to test it before committing the entire network to it. Luckily we can test this on the machine that you installed Unbound on (locally) and from any other machine (remotely) that will be using the resolver after we expose Unbound to the network.

The command for testing locally on the Unbound machine is:

.. code-block:: bash

	dig example.com @127.0.0.1

Here we tell the :command:`dig` tool to look up the IP address for example.com, and to ask for this information from the server running at the IP address ``127.0.0.1``, which is where our Unbound machine is running by default.
We can verify that Unbound has indeed answered our query instead of the default resolver that is present on Ubuntu by default. In the output of every :command:`dig` command there is an ``ANSWER SECTION`` which specifies the server which has answered the query under the ``SERVER`` entry. The entry should be:

.. code-block:: bash

	;; SERVER: 127.0.0.1#53(127.0.0.1)

In the next section we will be disabling the default Ubuntu resolver. To verify that we do it correctly it is useful to know the address of the default resolver as a baseline. For this baseline we also use a :command:`dig` query, but this time without specifying an IP address (which causes dig to use the machine's default DNS resolver).

.. code-block:: bash

	dig example.com

While the response should be the same, the ``SERVER`` entry in the response should look like:

.. code-block:: bash

	;; SERVER: 127.0.0.53#53(127.0.0.53)

Note that the final IPv4 digit is 53 and not 1, as with our Unbound instance.

Setting up for a single machine
-------------------------------

Now that we have configured and tested our Unbound server, we can tell our machine to use it by default. The nameserver (i.e. resolver) your machine uses by default is defined in :file:`/etc/resolv.conf`.
While just changing this file will work as long as the machine doesn't reboot, the more permanent and better solution is to replace the file with our own. The reason for this is that the :file:`resolv.conf` file is a `symbolic link`, which gets overwritten on reboot. We will remove the link and create a new file ourselves.

.. code-block:: bash

	rm /etc/resolv.conf

With your favourite text editor (e.g. :command:`nano`), create a new file with the same name and specify the IP address that our Unbound instance is running at in the file. We also include the :option:`edns0` option as this enables header extensions used in DNSSEC and is an overall standard used in DNS nowadays. |br|
So with :file:`nano /etc/resolv.conf` we create the new file and enter:

.. code-block:: bash

	nameserver 127.0.0.1
	options edns0
	

We then need to stop and disable the currently running pre-installed resolver. Note that you cannot visit new websites until the next step after this, as you have no DNS resolver assigned for the system.

.. code-block:: bash

	sudo systemctl disable systemd-resolved.service
	sudo systemctl stop systemd-resolved

Now the operating system should use our Unbound instance as default. A quick test a :command:`dig` without specifying the address of the Unbound server should give the same result as specifying it did above (with ``@127.0.0.1``).

.. code-block:: bash

	dig example.com

Note that the "SERVER" section in the output from :command:`dig` should also contain the local IP address of our server.

.. code-block:: bash

	;; SERVER: 127.0.0.1#53(127.0.0.1)
	
In order to prevent Network Manager from overwriting :file:`/etc/resolv.conf` upon reboot, we will add :option:`dns=none` option in :file:`/etc/NetworkManager/NetworkManager.conf` under the :option:`[main]` section

So we open :file:`nano /etc/NetworkManager/NetworkManager.conf` and add the option. The final content of the file should look something like this, 

.. code-block:: bash
	
	[main]
	plugins=ifupdown,keyfile
	dns=none

	[ifupdown]
	managed=false

	[device]
	wifi.scan-rand-mac-address=no

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

If you just have one IP address as output from the :command:`hostname` command that will be the correct one. If you have multiple IP addresses, the easiest way to determine which IP address to use, is to find out which connection goes to your home router. Keep in mind that finding the wrong IP address here can be a source of connectivity errors further on. For the purpose of this tutorial we assume that our home router has the IP address ``10.0.0.1``, and our resolver machine (the machine that is running our Unbound instance) has IP address ``10.0.0.2``, which we will get into in the next section.

As a prerequisite for the next step, we need to configure our Unbound instance to be reachable from devices other than only the machine on which the Unbound is running. The full example config is almost 1200 lines long, as the capabilities of Unbound are considerable, but we won’t need nearly as much. (If you are interested, any and all configurables can be found in the extensive manual page of :manpage:`unbound.conf`).

The default config is found at:

.. code-block:: bash

	/etc/unbound/unbound.conf

If you open this for the first time it looks very empty. It is still usable as a resolver for one machine, as this is how the Unbound defaults are configured. It's not, however, enough for our purposes, so we will add the minimal configuration options needed.

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
			# allows controling unbound using "unbound-control"
			control-enable: yes

The interface is currently configured to listen to any address on the machine, and the access-control only allows queries from the ``10.0.0.0/8`` `IP subnet <https://www.ripe.net/about-us/press-centre/understanding-ip-addressing>`_ range. Note that the IP address we chose above (``10.0.0.1`` and ``10.0.0.2``) fall within the ``10.0.0.0/8`` range.

To prepare our config we are going to modify the existing config in :file:`/etc/unbound/unbound.conf`.
If you open the file we see that there is already an “include” in there. This include enables us to do `DNSSEC <https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions>`_, which allows Unbound to verify the source of the answers that it receives, which we want to keep in. If you don't have the file that the include links to (:file:`root.key`), it can be created using the :command:`unbound-anchor` command. |br|
If you don't have the :file:`unbound_control.key` and :file:`unbound_control.pem` files, when you're building Unbound from source for example, the command to create these is: :command:`unbound-control-setup`.

Using the text editor again, we can then add the minimal config as shown above, making any changes to the access control where needed. Do note that we strongly recommend keeping the :command:`include` that is already in the file (such as in the above config). We also add the :command:`remote-control` in the config to enable controlling Unbound using :command:`unbound-control` command which is useful if you want to modify the config later on. When you are happy with your config, we can check it for mistakes with the :command:`unbound-checkconf` command:

.. code-block:: bash

	unbound-checkconf unbound.conf

If this command reports no errors, we need to stop the currently running Unbound instance and restart it with our new configuration. You can stop Unbound with:

.. code-block:: bash

	sudo pkill -f unbound

And you can restart Unbound with:

.. code-block:: bash

	unbound-control start

From this point on, we can :command:`stop`, :command:`start`, and :command:`reload` Unbound with :command:`unbound-control` if you want to make changes to the configuration.

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

Most machines when they first connect to a network get a “recommended resolver” from your router using :abbr:`DHCP (Dynamic Host Configuration Protocol)`. To change this, we need to log into the router. To find the IP address of our home router which is likely be under :option:`default gateway`:

.. code-block:: bash

	ip route

When you've found the IP address of your home router, you can copy the address to a web browser, which should give you access to the router configuration portal. If you can't find the portal using this method, consult the manual or the manufacturer's website. When you have access, you should change the DHCP configuration to advertise the IP address of the machine running Unbound as the default gateway. In the case of our example, that would be 10.0.0.2.

Another possibility is a machine that does not use a resolver that is “recommended” by your router. This machine can be running its own resolver or be connected to a different one altogether. If you want these machines to use the Unbound resolver you set up, you need to change the configuration of the machine.



