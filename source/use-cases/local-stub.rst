Local DNS (Stub) Resolver for a Single Machine
----------------------------------------------

..
    @TODO rename to something more easy to understand instead of the strictly
    correct name

Unbound is a powerful validating, recursive, caching DNS resolver. It’s used by
some of the biggest tech companies in the world as well as home users, who use
it together with ad blockers and firewalls, or self-run resolvers. Setting it up
as a caching resolver for your own machine can be quite simple as we’ll showcase
below.

We strongly recommend setting up
`DNSSEC <https://www.sidn.nl/en/modern-internet-standards/dnssec>`_
during the Unbound configuration step, as it allows the verification of the
integrity of the responses to the queries you send.

If you need to install Unbound first visit the
:doc:`/getting-started/installation` page.

Configuring the Local Stub resolver
===================================

For configuring Unbound we need to make sure we have Unbound installed. An easy
test is by asking the version number.

.. code-block:: bash

    unbound -V

Once we have a working version of Unbound installed we need to configure it to
be a recursive caching resolver (information about recursive resolvers can be
found `here <https://www.cloudflare.com/en-gb/learning/dns/dns-server-types/>`_,
but is not necessary for our purposes here). Luckily for us Unbound already
behaves as such by default, so for basic purposes we can use the configuration
from the :doc:`/getting-started/configuration` page. We always recommend
:doc:`enabling DNSSEC </getting-started/configuration#set-up-trust-anchor-enable-dnssec>`.

Once we have a configuration we are happy with, we need to tell our machine to use 
Unbound by default instead of what it is currently using. This works differently 
on different operating systems. Below we will go through this for a selection of OSes.

.. note::

    Make sure your Unbound can run with the configuration we create. Steps for
    this can be found :doc:`on the configuration page</getting-started/configuration>`.

Ubuntu 22.04 LTS
******************

The resolver your machine uses by default is defined in
:file:`/etc/systemd/resolved.conf` in the ``DNS`` entry and uses the IP address ``127.0.0.53``.

We can test this by using :command:`dig` to "example.com" and looking at the
output.

.. code-block:: bash

    dig example.com

Near the bottom of the output we can see ``127.0.0.53`` IP address.

.. code-block:: text

    ;; SERVER: 127.0.0.53#53(127.0.0.53)

To change this, we are going to change the :file:`resolved.conf`.
While just changing this file will work as long as the machine doesn't
reboot, we need to make sure that this change is *persistent*. To do that, we
need to change the ``DNS`` entry to be equal to ``127.0.0.1`` (or whatever IP address Unbound is bound to in your configuration) so the machine uses Unbound
as default. So the interface would look like this in the Unbound config:

.. code-block:: bash

    server:
        # specify the interface to answer queries from by ip-address.
        interface: 127.0.0.1

To test that Unbound is running, we can tell :command:`dig` to use a specific
server with the ``@``.

.. code-block:: bash

    dig example.com @127.0.0.1

If Unbound is running, the output should contain the address that we specified 
in the config:

.. code-block:: text

    ;; SERVER: 127.0.0.1#53(127.0.0.1)

If we changed :file:`resolved.conf` now, the default resolver would be persistent
until the router wants to update it. To make sure it doesn't do that we also need to set the ``DNSStubListener`` to ``no`` so that is not changed by our
router (such as with a "recommended resolver" mentioned below). We also want to
enable the ``DNSSEC`` option so that we can verify the integrity the responses
we get to our DNS queries. With your favourite text editor (e.g. :command:`nano`
) we can modify the file:

.. code-block:: bash

    nano /etc/systemd/resolved.conf

Here, under there ``[Resolve]`` header we add/substitute our changes to the
options:

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

To actually have the system start using our changed config, we then need to create a symlink to overwrite :file:`/etc/resolv.conf` to the one we modified.

.. code-block:: bash

    ln -fs /run/systemd/resolve/resolv.conf /etc/resolv.conf

.. note::

    Make sure your Unbound is running at at the IP address from the modified 
    resolv.conf before the next step, otherwise you might break your internet
    connection.

With the resolv.conf file modified, we can restart systemd using the new resolver
configuration with:

.. code-block:: bash

    systemctl restart systemd-resolved

If successful, the operating system should use our Unbound instance as default.
A quick test a :command:`dig` without specifying the address of the Unbound
server should give the same result as specifying it did above (with
``@127.0.0.1``).

.. code-block:: bash

    dig example.com

Here we tell the :command:`dig` tool to look up the IP address for
``example.com``. We did not specify where :command:`dig` should ask this, so it
goes to the default resolver of the machine.

.. code-block:: text

    dig example.com

It should look the same as with 
the ``127.0.0.1`` IP specified as we did earlier.

.. code-block:: text

    ;; SERVER: 127.0.0.1#53(127.0.0.1)

.. note::

    Unbound is not persistent at this point, and will not start up when your 
    system does (and possibly "breaking" your internet). This is fixed by
    restarting your Unbound upon reboot.

Package manager
^^^^^^^^^^^^^^^

To make Unbound persistent between restarts, we need to add it to the systemd
service manager, for which we'll need a service file. If you installed Unbound
via the package manager, this service file is already created for you and the
only thing that is missing, is it executing our own configuration file.

To make sure we execute Unbound with our own configuration, we copy our config
file to the default location of the config file:
:file:`/etc/unbound/unbound.conf`. Make sure Unbound starts using the copied
configuration (this can be done with the :option:`-c<unbound -c>` flag to
specify the config location).

Before you proceed to the next step, make sure to stop the Unbound that may 
still be running. Now we can start our Unbound with systemd, which will restart
automatically when the system is rebooted.

.. code-block:: text

    systemctl start unbound

To check that everything is correct, you can see the status (which should be 
"active"):

.. code-block:: text

    systemctl status unbound

We can now :command:`dig` a final time, to verify that this works.


Compilation
^^^^^^^^^^^

The steps for making Unbound persistent are almost exactly the same as if you
installed it via the package manager, except that the service file that is 
needed by systemd does not exist yet. So instead of changing it, we create it 
and call it ``unbound.service``, and copy the minimally modified service file 
supplied by the package manager. It should be located at: 
``/lib/systemd/system/unbound.service``.

So using your favorite text editor open the file:

.. code-block:: bash

    nano /lib/systemd/system/unbound.service

and copy the file contents below:

.. code-block:: text

    [Unit]
    Description=Unbound DNS server
    Documentation=man:unbound(8)
    After=network.target
    Before=nss-lookup.target
    Wants=nss-lookup.target

    [Service]
    Type=simple
    Restart=on-failure
    EnvironmentFile=-/usr/local/etc/unbound
    ExecStart=/usr/local/sbin/unbound -d -p $DAEMON_OPTS
    ExecReload=+/bin/kill -HUP $MAINPID

    [Install]
    WantedBy=multi-user.target

Note that in this file ``systemctl`` uses the default config location. This 
location is different depending on the installation method used. In this case the 
default config file is located at :file:`/usr/local/etc/unbound`. We need to copy
the config that we are going to use here.

Once you have your config copied in the right location, we need to make sure the 
system can find it. 

Because we change the service file on disk (we created it), systemctl needs to 
be reloaded:

.. code-block:: text

    systemctl daemon-reload

We then need to enable Unbound as a systemctl service:

.. code-block:: text

    systemctl enable unbound

If all steps went correctly, we can start Unbound now using systemctl. Note that 
any previous Unbound instances with the same config (specifically the same 
ip-address) needs to be stopped.

.. code-block:: text
    
    systemctl start unbound

We can then look at the status, which should be "active".

.. code-block:: text
    
    systemctl status unbound


If you succeeded Unbound should now be the default resolver on your machine and
it will start when your machine boots.

macOS Big Sur
*************

To find out which resolver your machine uses, we have two options: Look at the
DNS tab under the Network tab in the System Preferences app, or we can use the
:command:`scutil` command in the terminal. The :command:`scutil` command can be
used to manage and give information about the system configuration parameters.
When used for DNS, it will show you all the configured resolvers though we are
only interested in the first.

.. code-block:: bash

    scutil --dns

The output will show all the resolvers configured, but we are interested in the
first entry. Before configuring Unbound to be our resolver, the first entry is
(likely) the resolver recommended by your router.

The simplest method of changing the resolver of your Mac is by using the System
Preferences Window (the option of doing this step via the command line terminal
also exists if you want to script this step). The steps go as follows:

1. Open the Network tab in System Preferences.

#. Click on the Advanced button.

#. Go to the DNS Tab.

#. Click "+" icon

#. Add IP address of Unbound instance (here we use ``127.0.0.1``)


..
    XXX DO WE NEED TO ADD PICTURES HERE? 

Once the IP address is added we can test our Unbound instance (assuming it's running)  with :command:`dig`. Note that the Unbound instance cannot be reached before it has been added in the DNS tab in System Preferences.

.. code-block:: bash

    dig example.com @127.0.0.1

.. attention::
    If you restart your Mac at this stage in the process, you will not have
    access to the internet anymore. This is because Unbound does not
    automatically restart if your machine restarts. To make remedy this, we
    need to add Unbound to the startup routine on your Mac.

Depending on your installation method, either via ``Homebrew`` or compiling
Unbound yourself, the method of making Unbound persistent differs slightly.
For both methods we use :command:`launchctl` to start Unbound on the startup of
your machine.

Homebrew
^^^^^^^^

If you installed Unbound using Homebrew, the XML file required by
:command:`launchctl` is already supplied during installation. The file can be
found at ``/Library/LaunchDaemons/homebrew.mxcl.unbound.plist``. To load this
file we invoke the following command.

.. code-block:: bash

    sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.unbound.plist

Now every time you restart your machine, Unbound should restart too.

Compilation
^^^^^^^^^^^

If you installed Unbound by compiling it yourself, we need to create an XML file
for :command:`launchctl`. Conveniently we've created one for you:

..
    zet XML in unbound/contrib (contributed code)

.. code-block:: xml

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

The main components that interest us, are the items in the ``<array>`` which
execute the command. Firstly, we invoke Unbound from the location that it has
been installed (for example using ``make install``).
Secondly, we add the :option:`-c<unbound -c>` option to supply a configuration
file.
Lastly, we add the location of the default configuration file.
The location in the XML can be changed to another location if this is
convenient.

Using the text editor of choice, we then create the file
``/Library/LaunchDaemons/nl.nlnetlabs.unbound.plist`` and insert the above
supplied XML code. To be able to use the file, we need to change the permissions
of the file using :command:`chmod`

.. code-block:: bash

    sudo chmod 644 /Library/LaunchDaemons/nl.nlnetlabs.unbound.plist

We can then load the file with the following command.

.. code-block:: bash

    sudo launchctl load /Library/LaunchDaemons/nl.nlnetlabs.unbound.plist

Now every time you restart your machine, Unbound should restart too.
