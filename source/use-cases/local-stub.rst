.. _doc_unbound_local_stub:

Local DNS (Stub) Resolver of for Single Machine
-----------------------------------------------

.. @TODO rename to something more easy to understand instead of the strictly correct name

Unbound is a powerful validating, recursive, caching DNS resolver. It’s used by some of the biggest tech companies in the world as well as home users, who use it together with ad blockers and firewalls, or self-run resolvers. Setting it up as a caching resolver for your own machine can be quite simple as we’ll showcase below.

We strongly recommend setting up `DNSSEC <https://www.sidn.nl/en/cybersecurity/dnssec-explained>`_ during the Unbound configuration step, as it allows the verification of the integrity of the responses to the queries you send.

If you need to install Unbound first visit the :ref:`installation page<doc_unbound_installation>`.

Configuring the Local Stub resolver
===================================

For configuring Unbound we need to make sure we have Unbound installed. An easy test is by asking the verison number.

.. code-block:: bash

	unbound -V

Once we have a working version of Unbound installed we need to configure it to be a recursive cacheing resolver (information about recursive resolvers can be found
`here <https://www.cloudflare.com/en-gb/learning/dns/dns-server-types/>`_, but is not necessary for our purposes here).
Luckily for us Unbound already behaves as such by default, so for basic purposes we can use the configuration from the :ref:`configuration page<doc_unbound_configuration>`. We always recommend enabling `DNSSEC <https://www.sidn.nl/en/cybersecurity/dnssec-explained>`_, for which the setup can also be found in the configuration page.

Once we have a installed, configured and running Unbound instance, we need tell our machine to use this instance by default instead of what it is currently using. This works differently on different operating systems, below we will go through this for a selection of OS'es.


Ubuntu 20.04.1 LTS
******************

The resolver your machine uses by default is defined in :file:`/etc/systemd/resolved.conf` in the :option:`DNS` entry (It uses ``127.0.0.53`` ).
While just changing this file will work as long as the machine doesn't reboot, we need to make sure that this change is persistent. To do that, we need to change the :option:`DNS` entry to be equal to ``127.0.0.1`` (or whatever IP address Unbound is bound to) so the machine uses Unbound as default.
To make the change persistent, we also need to set the :option:`DNSStubListener` to :option:`no` so that is not changed by our router (such as with a "recommended resolver" mentioned below). We also want to enable the :option:`DNSSEC` option so that we can verify the integrity the responses we get to our DNS queries. With your favourite text editor (e.g. :command:`nano`) we can modify the file:

.. code-block:: bash

	nano /etc/systemd/resolved.conf

Here, under there ``[Resolve]`` header we add (or rather, enable by removing the "#") the options:

.. code-block:: bash

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

With this file modified, we can restart using this configuration with: 

.. code-block:: bash

	systemctl restart systemd-resolved

If successful, the operating system should use our Unbound instance as default. A quick test a :command:`dig` without specifying the address of the Unbound server should give the same result as specifying it did above (with ``@127.0.0.1``).

.. code-block:: bash

	dig example.com


Here we tell the :command:`dig` tool to look up the IP address for ``example.com``. We did not specify where :command:`dig` should ask this, so it goes to the default resolver of the machine. To verify the default is indeed our running Unbound instance we look at the footer section of the output of the command. There we can see a server IP address under the ``SERVER`` entry. If the default is correctly set to be Unbound, the entry will be the IP address of the Unbound instance you configured (in this case ``127.0.0.1``):

.. code-block:: bash

	;; SERVER: 127.0.0.1#53(127.0.0.1)

Note that the "SERVER" section in the output from :command:`dig` should also contain the local IP address of our server.

.. code-block:: bash

	;; SERVER: 127.0.0.1#53(127.0.0.1)

.. IS UNBOUND PERSISTENT HERE?!

macOS Big Sur
*************

To find out which resolver your machine uses, we have two options: Look at the DNS tab under the Network tab in the System Preferences app, or we can use the :command:`scutil` command in the terminal. The :command:`scutil` command can be used to manage and give information about the system configuration parameters. When used for DNS, it will show you all the configured resolvers though we are only interested in the first.

.. code-block:: bash

	scutil --dns

The output will show all the resolvers configured, but we are interested in the first entry. Before configuring Unbound to be our resolver, the first entry is 
(likely) the resolver recommended by your router.

The simplest method of changing the resolver of your Mac is by using the System Preferences Window (the option of doing this step via the command line terminal also exists if you want to script this step).
The steps go as follows:

1. Open the Network tab in System Preferences.

#. Click on the Advanced button.

#. Go to the DNS Tab.

#. Click "+" icon

#. Add IP address of Unbound instance (here we use ``127.0.0.1``)


.. DO WE NEED TO ADD PICTURES HERE? 

Once the IP address is added we can test our Unbound instance (assuming it's running)  with :command:`dig`. Note that the Unbound instance cannot be reached before it has been added in the DNS tab in System Preferences.

.. code:: bash

	dig example.com @127.0.0.1

.. Attention:: if you restart your mac at this stage in the process, you will not have access to the internet anymore. This is because Unbound does not automatically restart if your machine restarts. To make remedy this, we need to add Unbound to the startup routine on your Mac.

Depending on your installation method, either via Homebrew or compiling Unbound yourself, the method of making Unbound persistant differs slightly. For both methods we use :command:`launchctl` to start Unbound on the startup of your machine.

Homebrew
^^^^^^^^

If you installed Unbound using Homebrew, the XML file required by :command:`launchctl` is already supplied during installation. The file can be found at ``/Library/LaunchDaemons/homebrew.mxcl.unbound.plist``. To load this file we invoke the following command.

.. code:: bash

	sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.unbound.plist

Now everytime you restart your machine, Unbound should restart too.

Compilation
^^^^^^^^^^^

If you installed Unbound by compiling it yourself, we need to create an XML file for :command:`launchctl`. Conveniently we've created one for you:

.. zet XML in unbound/contrib (contributed code)

.. code:: bash

	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	  <dict>
	    <key>Label</key>
	    <string>nl.nlnetlabs.unbound</string>
	    <key>KeepAlive</key>
	    <true/>
	    <key>RunAtLoad</key>
	    <true/>
	    <key>ProgramArguments</key>
	    <array>
	      <string>/usr/local/sbin/unbound</string>
	      <string>-c</string>
	      <string>/usr/local/etc/unbound/unbound.conf</string>
	    </array>
	    <key>UserName</key>
	    <string>root</string>
	    <key>StandardErrorPath</key>
	    <string>/dev/null</string>
	    <key>StandardOutPath</key>
	    <string>/dev/null</string>
	  </dict>
	</plist>

The main components that interest us, are the items in the ``<array>`` which execute the command. Firstly, we invoke Unbound from the location that it has been installed (for example using ``make install``). Secondly, we add the :option:`-c` option to supply a config file. Lastly, we add the location of the default configuration file. The location in the XML can be changed to another location if this is convienient.

Using the text editor of choice, we then create the file ``/Library/LaunchDaemons/nl.nlnetlabs.unbound.plist`` and insert the above supplied XML code. To be able to use the file, we need to change the permissions of the file using :command:`chmod`

.. code:: bash

	sudo chmod 644 /Library/LaunchDaemons/nl.nlnetlabs.unbound.plist

We can then load the file with the following command.

.. code:: bash

	sudo launchctl load /Library/LaunchDaemons/nl.nlnetlabs.unbound.plist

Now everytime you restart your machine, Unbound should restart too.









