Resolver for Home Networks
==========================


Setting up Unbound
------------------

Unbound is a powerful validating, recursive, caching DNS resolver. It’s used by some of the biggest tech companies in the world and also by home users who use it for Pi-hole or self-run resolvers. Setting it up for your home network can be quite simple as we’ll showcase below!

Setting up your own DNS resolver for your entire home network requires a couple of things. Namely, a recursive DNS resolver (who knew!), and a dedicated machine where the resolver runs, which is always on and accessible to the entire network. This can be as simple as a Raspberry Pi connected to your home router or any other machine that you is always online!

Because of the variaty of machines that Unbound can run on we cannot create a comprehensive tutorial for all possible options. For the extent of this tutorial we will Ubuntu as a stepping stone which you could use for other machines. For this tutorial Ubuntu 20.04.1 LTS was used.

While you could download the code and build it yourself if wou wanted, it can be as simple as running:
::
	apt install unbound

This gives you a full, compiled, and running version of Unbound which behaves as a caching recursive DNS resolver out of the box for the local machine.

Do note that the current setup is only reachable on this machine.

Testing the server locally
--------------------------

To verify that the server works correctly it’s a good idea to test it before committing the entire network to it. Luckily we can test this on the machine that you installed Unbound on (local) and from any other machine (remote)  that will be using the resolver after we expose Unbound to the network.

The command for local testing is:
::
	dig example.com @127.0.0.1

So we tell the dig tool to look up the IP address for example.com, and to ask this information to the server running at the ip address 127.0.0.1, which is where our Unbound machine is running.


Setting up for a single machine
-------------------------------

Now that we have configured and tested our Unbound server, we can tell our machine to use by default. We do this at:
::
	sudo nano /etc/systemd/resolved.conf
Here we change the entries under [Resolve] to use our own instance running at 127.0.0.1 
::
	sudo systemctl restart systemd-resolved

We then need to stop the currently running pre-installed resolver:
::
	sudo systemctl disable systemd-resolved.service
	sudo systemctl stop systemd-resolved

And now we can then start using our new configuration:
::
	  sudo service network-manager restart

And as a quick test a *dig* without specifying our Unbound server should give the same result as specifying it (with the *@127.0.0.1*)!
::
	dig example.com

Setting up for the rest of the network
--------------------------------------

While we current have a working instance of unbound, we need it to be reachable from within our entire network. With that comes the headache of dealing with IP addresses. It’s likely that your home router distributed local IP addresses to your devices. If this is the case (i.e. you didn’t change it by hand), the ranges should be between[`RFC1918<http://tools.ietf.org/html/rfc1918>`]:
::
	10.0.0.0 - 10.255.255.255 (10/8)
	172.16.0.0 - 172.31.255.255 (172.16/12)
	192.168.0.0 - 192.168.255.255 (192.168/16)

The Unbound example config uses the 10.0.0.0/8, so that’s what we use in this example, but note that this can be a sources of connectivity errors further on.

Let’s look at a snippet of the example config file. The full example config is almost 1200 lines long, as the capabilities of Unbound are considerable, but we won’t need nearly as much. (If you are interested, any and all configurables can be found in the extensive manual page with *man unbound*)

The example config is found at:
::
	/etc/unbound/unbound.conf

if you open this for the first time it looks very empty. It is still usable for one machine, as this is how all the Unbound defaults are configured. It's not, however, enough for what our purposes so we will add the minimal configuration options.

The options that we add to the current config file to make it a "minimal usable config" are:
::
	server:
            # the interface that is used to connect to the network, this means on this machine
            interface: 0.0.0.0
            interface: ::0
            # addresses from the IP range that are allowed to connect to the resolver
            access-control: 10.0.0.0/8 allow
            access-control: 2001:DB8::/64 allow

The access-control is currently configured to listen to any address on the machine, and only allow queries from the 10.0.0.0/8 IP range.

To prepare our config we are going to modify the existing config in /etc/unbound/unbound.conf. 
If you open the file we see that there is already an “include” in there. This include enables us to do DNSSEC, which allows Unbound to verify the source of the answers that it receives [LINK ?], so we want to keep this. If you don't have the files they can be created using the *unbound-anchor* command.

With your favourite text editor then add the minimal config as shown above, making any changes to the access control where needed. Do note that we strongly recommend to keep the *include* that is already in the file. When you are happy with our config, we first need to kill the currently running unbound server and restart it with our new configuration.

you can kill the current version with 
::
	pkill -f unbound

And you can restart Unbound with:
::
	unbound -c /etc/unbound.conf

Testing the resolver from a remote machine
------------------------------------------

So now we have a DNS resolver which should be reachable from within the network. To verify this we need to find the IP address of the resolver machine which can be found on the machine itself. For this tutorial we will use the address “10.10.10.10” (not 127.0.0.1 as we saw earlier) as an example. Armed with the IP address we can send a query to our DNS resolver from another machine which is within our home network. To do this we use the same dig command, only we change the IP address where the query is asked.
::
	dig example.com @10.10.10.10

This should give the same result as the query from the local test.


Where it all comes together
---------------------------

We should now have a functioning DNS resolver that is accessible to all machines in our network. 

The next step then becomes a little tricky. We have a choice of which machines in our network will be using our configured DNS resolver. This can range from a single machine to all the machines that are connected. 

Since this tutorial cannot (and does not try to) be comprehensive, we wil look at some of the basic examples on which you can expand.

While not all, some machines use the resolver “recommended” by your router. To change this, we need to log into the router and configure it to use the DNS resolver that we just set up. This configuration step varies greatly from vendor to vendor, but the rule of thumb is that your router is accessible on either 192.168.1.1 or 192.168.0.1.

Another possibility is a machine does not use a resolver that is “recommended” by your router. This can be its own resolver, such as is the case on Ubuntu, or another. On Ubuntu this can be can be changed by changing the “nameserver” to IP address of our DNS resolver in:

::
	cat /etc/resolv.conf




