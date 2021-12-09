.. _doc_unbound_control_manpage:

unbound-control(8)
------------------

.. raw:: html

    <pre class="man">unbound-control(8)              unbound 1.14.0              unbound-control(8)



    <b>NAME</b>
       <b>unbound-control,</b>  <b>unbound-control-setup</b> - Unbound remote server control
       utility.

    <b>SYNOPSIS</b>
       <b>unbound-control</b> [<b>-hq</b>] [<b>-c</b> <i>cfgfile</i>] [<b>-s</b> <i>server</i>] <i>command</i>

    <b>DESCRIPTION</b>
       <b>Unbound-control</b> performs remote administration on  the  <a href="unbound.html"><i>unbound</i>(8)</a>  DNS
       server.   It  reads the configuration file, contacts the unbound server
       over SSL sends the command and displays the result.

       The available options are:

       <b>-h</b>     Show the version and commandline option help.

       <b>-c</b> <i>cfgfile</i>
              The config file to read with settings.  If not given the default
              config file /usr/local/etc/unbound/unbound.conf is used.

       <b>-s</b> <i>server[@port]</i>
              IPv4  or  IPv6  address of the server to contact.  If not given,
              the address is read from the config file.

       <b>-q</b>     quiet, if the option is given it does not print anything  if  it
              works ok.

    <b>COMMANDS</b>
       There are several commands that the server understands.

       <b>start</b>  Start  the  server.  Simply  execs <a href="unbound.html"><i>unbound</i>(8)</a>.  The unbound exe-
              cutable is searched for in the <b>PATH</b> set in the environment.   It
              is  started  with  the config file specified using <i>-c</i> or the de-
              fault config file.

       <b>stop</b>   Stop the server. The server daemon exits.

       <b>reload</b> Reload the server. This flushes the cache and reads  the  config
              file fresh.

       <b>verbosity</b> <i>number</i>
              Change  verbosity  value  for  logging. Same values as <b>verbosity</b>
              keyword in <a href="unbound.conf.html"><i>unbound.conf</i>(5)</a>.  This new setting  lasts  until  the
              server is issued a reload (taken from config file again), or the
              next verbosity control command.

       <b>log</b><i>_</i><b>reopen</b>
              Reopen the logfile, close and open it.  Useful  for  logrotation
              to  make  the  daemon release the file it is logging to.  If you
              are using syslog it will attempt to close and  open  the  syslog
              (which may not work if chrooted).

       <b>stats</b>  Print statistics. Resets the internal counters to zero, this can
              be controlled using the <b>statistics-cumulative</b> config  statement.
              Statistics are printed with one [name]: [value] per line.

       <b>stats</b><i>_</i><b>noreset</b>
              Peek at statistics. Prints them like the <b>stats</b> command does, but
              does not reset the internal counters to zero.

       <b>status</b> Display server status. Exit code 3 if not running  (the  connec-
              tion to the port is refused), 1 on error, 0 if running.

       <b>local</b><i>_</i><b>zone</b> <i>name</i> <i>type</i>
              Add  new  local  zone with name and type. Like <b>local-zone</b> config
              statement.  If the zone already exists, the type is  changed  to
              the given argument.

       <b>local</b><i>_</i><b>zone</b><i>_</i><b>remove</b> <i>name</i>
              Remove  the  local  zone with the given name.  Removes all local
              data inside it.  If the zone does not exist,  the  command  suc-
              ceeds.

       <b>local</b><i>_</i><b>data</b> <i>RR</i> <i>data...</i>
              Add  new  local data, the given resource record. Like <b>local-data</b>
              config statement, except for when no covering zone  exists.   In
              that case this remote control command creates a transparent zone
              with the same name as this record.

       <b>local</b><i>_</i><b>data</b><i>_</i><b>remove</b> <i>name</i>
              Remove all RR data from local name.  If the name already has  no
              items,  nothing happens.  Often results in NXDOMAIN for the name
              (in a static zone), but if the name has become an empty  nonter-
              minal  (there  is  still  data in domain names below the removed
              name), NOERROR nodata answers are the result for that name.

       <b>local</b><i>_</i><b>zones</b>
              Add local zones read from stdin  of  unbound-control.  Input  is
              read  per  line,  with name space type on a line. For bulk addi-
              tions.

       <b>local</b><i>_</i><b>zones</b><i>_</i><b>remove</b>
              Remove local zones read from stdin of unbound-control. Input  is
              one name per line. For bulk removals.

       <b>local</b><i>_</i><b>datas</b>
              Add  local data RRs read from stdin of unbound-control. Input is
              one RR per line. For bulk additions.

       <b>local</b><i>_</i><b>datas</b><i>_</i><b>remove</b>
              Remove local data RRs read from stdin of unbound-control.  Input
              is one name per line. For bulk removals.

       <b>dump</b><i>_</i><b>cache</b>
              The contents of the cache is printed in a text format to stdout.
              You can redirect it to a file to store the cache in a file.

       <b>load</b><i>_</i><b>cache</b>
              The contents of the cache is loaded from stdin.  Uses  the  same
              format as dump_cache uses.  Loading the cache with old, or wrong
              data can result in old or wrong data returned to clients.  Load-
              ing data into the cache in this way is supported in order to aid
              with debugging.

       <b>lookup</b> <i>name</i>
              Print to stdout the name servers that would be used to  look  up
              the name specified.

       <b>flush</b> <i>name</i>
              Remove  the  name from the cache. Removes the types A, AAAA, NS,
              SOA, CNAME, DNAME, MX, PTR, SRV and NAPTR.  Because that is fast
              to  do.  Other  record  types can be removed using <b>flush</b><i>_</i><b>type</b> or
              <b>flush</b><i>_</i><b>zone</b>.

       <b>flush</b><i>_</i><b>type</b> <i>name</i> <i>type</i>
              Remove the name, type information from the cache.

       <b>flush</b><i>_</i><b>zone</b> <i>name</i>
              Remove all information at or below the name from the cache.  The
              rrsets  and  key entries are removed so that new lookups will be
              performed.  This needs to walk and inspect the entire cache, and
              is  a slow operation.  The entries are set to expired in the im-
              plementation of this command (so,  with  serve-expired  enabled,
              it'll serve that information but schedule a prefetch for new in-
              formation).

       <b>flush</b><i>_</i><b>bogus</b>
              Remove all bogus data from the cache.

       <b>flush</b><i>_</i><b>negative</b>
              Remove all negative data from the cache.  This is  nxdomain  an-
              swers,  nodata  answers  and servfail answers.  Also removes bad
              key entries (which could be due  to  failed  lookups)  from  the
              dnssec  key cache, and iterator last-resort lookup failures from
              the rrset cache.

       <b>flush</b><i>_</i><b>stats</b>
              Reset statistics to zero.

       <b>flush</b><i>_</i><b>requestlist</b>
              Drop the queries that are  worked  on.   Stops  working  on  the
              queries  that  the server is working on now.  The cache is unaf-
              fected.  No reply is sent for  those  queries,  probably  making
              those  users  request  again  later.   Useful to make the server
              restart working on queries with new settings, such as  a  higher
              verbosity level.

       <b>dump</b><i>_</i><b>requestlist</b>
              Show  what  is worked on.  Prints all queries that the server is
              currently working on.  Prints the  time  that  users  have  been
              waiting.   For  internal requests, no time is printed.  And then
              prints out the module status.  This prints the queries from  the
              first thread, and not queries that are being serviced from other
              threads.

       <b>flush</b><i>_</i><b>infra</b> <i>all|IP</i>
              If all then entire infra cache is emptied.  If a specific IP ad-
              dress, the entry for that address is removed from the cache.  It
              contains EDNS, ping and lameness data.

       <b>dump</b><i>_</i><b>infra</b>
              Show the contents of the infra cache.

       <b>set</b><i>_</i><b>option</b> <i>opt:</i> <i>val</i>
              Set the option to the given value without a reload.   The  cache
              is  therefore  not  flushed.  The option must end with a ':' and
              whitespace must be between the option and the value.  Some  val-
              ues  may  not have an effect if set this way, the new values are
              not written to the config file, not all options  are  supported.
              This  is different from the set_option call in libunbound, where
              all values work because unbound has not been initialized.

              The values that work are: statistics-interval,  statistics-cumu-
              lative,       do-not-query-localhost,      harden-short-bufsize,
              harden-large-queries,    harden-glue,    harden-dnssec-stripped,
              harden-below-nxdomain,      harden-referral-path,      prefetch,
              prefetch-key, log-queries,  hide-identity,  hide-version,  iden-
              tity,  version,  val-log-level, val-log-squelch, ignore-cd-flag,
              add-holddown, del-holddown, keep-missing, tcp-upstream,  ssl-up-
              stream,  max-udp-size,  ratelimit,  ip-ratelimit, cache-max-ttl,
              cache-min-ttl, cache-max-negative-ttl.

       <b>get</b><i>_</i><b>option</b> <i>opt</i>
              Get the value of the option.  Give the  option  name  without  a
              trailing  ':'.  The value is printed.  If the value is "", noth-
              ing is printed and the connection closes.  On error 'error  ...'
              is  printed  (it  gives  a syntax error on unknown option).  For
              some options a list of values, one on  each  line,  is  printed.
              The  options  are  shown  from  the config file as modified with
              set_option.  For some options an override may  have  been  taken
              that  does  not show up with this command, not results from e.g.
              the verbosity and forward control  commands.   Not  all  options
              work,   see   list_stubs,  list_forwards,  list_local_zones  and
              list_local_data for those.

       <b>list</b><i>_</i><b>stubs</b>
              List the stub zones in use.  These are printed one by one to the
              output.  This includes the root hints in use.

       <b>list</b><i>_</i><b>forwards</b>
              List  the  forward zones in use.  These are printed zone by zone
              to the output.

       <b>list</b><i>_</i><b>insecure</b>
              List the zones with domain-insecure.

       <b>list</b><i>_</i><b>local</b><i>_</i><b>zones</b>
              List the local zones in use.  These are  printed  one  per  line
              with zone type.

       <b>list</b><i>_</i><b>local</b><i>_</i><b>data</b>
              List  the  local  data  RRs  in  use.   The resource records are
              printed.

       <b>insecure</b><i>_</i><b>add</b> <i>zone</i>
              Add a <b>domain-insecure</b> for the given zone, like the statement  in
              unbound.conf.  Adds to the running unbound without affecting the
              cache contents (which may still be bogus, use <b>flush</b><i>_</i><b>zone</b> to  re-
              move it), does not affect the config file.

       <b>insecure</b><i>_</i><b>remove</b> <i>zone</i>
              Removes domain-insecure for the given zone.

       <b>forward</b><i>_</i><b>add</b> [<i>+i</i>] <i>zone</i> <i>addr</i> <i>...</i>
              Add  a new forward zone to running unbound.  With +i option also
              adds a <i>domain-insecure</i> for the zone (so  it  can  resolve  inse-
              curely  if  you  have  a DNSSEC root trust anchor configured for
              other names).  The addr can be IP4,  IP6  or  nameserver  names,
              like <i>forward-zone</i> config in unbound.conf.

       <b>forward</b><i>_</i><b>remove</b> [<i>+i</i>] <i>zone</i>
              Remove a forward zone from running unbound.  The +i also removes
              a <i>domain-insecure</i> for the zone.

       <b>stub</b><i>_</i><b>add</b> [<i>+ip</i>] <i>zone</i> <i>addr</i> <i>...</i>
              Add a new stub zone to running unbound.   With  +i  option  also
              adds  a  <i>domain-insecure</i> for the zone.  With +p the stub zone is
              set to prime, without it it is set to notprime.  The addr can be
              IP4,  IP6  or nameserver names, like the <i>stub-zone</i> config in un-
              bound.conf.

       <b>stub</b><i>_</i><b>remove</b> [<i>+i</i>] <i>zone</i>
              Remove a stub zone from running unbound.  The +i also removes  a
              <i>domain-insecure</i> for the zone.

       <b>forward</b> [<i>off</i> | <i>addr</i> <i>...</i> ]
              Setup  forwarding  mode.   Configures  if  the server should ask
              other upstream nameservers, should go to the internet root name-
              servers  itself, or show the current config.  You could pass the
              nameservers after a DHCP update.

              Without arguments the current list of addresses used to  forward
              all  queries  to  is  printed.  On startup this is from the for-
              ward-zone "." configuration.  Afterwards it  shows  the  status.
              It prints off when no forwarding is used.

              If  <i>off</i>  is  passed,  forwarding  is disabled and the root name-
              servers are used.  This can be used to avoid to avoid  buggy  or
              non-DNSSEC  supporting  nameservers returned from DHCP.  But may
              not work in hotels or hotspots.

              If one or more IPv4 or IPv6 addresses are given, those are  then
              used  to  forward  queries  to.  The addresses must be separated
              with spaces.  With '@port' the port number can be set explicitly
              (default port is 53 (DNS)).

              By  default  the  forwarder information from the config file for
              the root "." is used.  The config file is not changed, so  after
              a  reload  these changes are gone.  Other forward zones from the
              config file are not affected by this command.

       <b>ratelimit</b><i>_</i><b>list</b> [<i>+a</i>]
              List the domains that are ratelimited.   Printed  one  per  line
              with  current  estimated qps and qps limit from config.  With +a
              it prints all domains, not just the  ratelimited  domains,  with
              their  estimated  qps.   The ratelimited domains return an error
              for uncached (new) queries, but cached queries work as normal.

       <b>ip</b><i>_</i><b>ratelimit</b><i>_</i><b>list</b> [<i>+a</i>]
              List the ip addresses that are  ratelimited.   Printed  one  per
              line with current estimated qps and qps limit from config.  With
              +a it prints all ips, not just the ratelimited ips,  with  their
              estimated  qps.  The ratelimited ips are dropped before checking
              the cache.

       <b>list</b><i>_</i><b>auth</b><i>_</i><b>zones</b>
              List the auth zones that are configured.  Printed one  per  line
              with a status, indicating if the zone is expired and current se-
              rial number.

       <b>auth</b><i>_</i><b>zone</b><i>_</i><b>reload</b> <i>zone</i>
              Reload the auth zone from zonefile.  The  zonefile  is  read  in
              overwriting  the  current  contents of the zone in memory.  This
              changes the auth zone contents itself, not the  cache  contents.
              Such  cache  contents exists if you set unbound to validate with
              for-upstream yes and that can be cleared with <b>flush</b><i>_</i><b>zone</b> <i>zone</i>.

       <b>auth</b><i>_</i><b>zone</b><i>_</i><b>transfer</b> <i>zone</i>
              Transfer the auth zone from master.  The  auth  zone  probe  se-
              quence  is  started, where the masters are probed to see if they
              have an updated zone (with the SOA serial check).  And then  the
              zone is transferred for a newer zone version.

       <b>rpz</b><i>_</i><b>enable</b> <i>zone</i>
              Enable the RPZ zone if it had previously been disabled.

       <b>rpz</b><i>_</i><b>disable</b> <i>zone</i>
              Disable the RPZ zone.

       <b>view</b><i>_</i><b>list</b><i>_</i><b>local</b><i>_</i><b>zones</b> <i>view</i>
              <i>list_local_zones</i> for given view.

       <b>view</b><i>_</i><b>local</b><i>_</i><b>zone</b> <i>view</i> <i>name</i> <i>type</i>
              <i>local_zone</i> for given view.

       <b>view</b><i>_</i><b>local</b><i>_</i><b>zone</b><i>_</i><b>remove</b> <i>view</i> <i>name</i>
              <i>local_zone_remove</i> for given view.

       <b>view</b><i>_</i><b>list</b><i>_</i><b>local</b><i>_</i><b>data</b> <i>view</i>
              <i>list_local_data</i> for given view.

       <b>view</b><i>_</i><b>local</b><i>_</i><b>data</b> <i>view</i> <i>RR</i> <i>data...</i>
              <i>local_data</i> for given view.

       <b>view</b><i>_</i><b>local</b><i>_</i><b>data</b><i>_</i><b>remove</b> <i>view</i> <i>name</i>
              <i>local_data_remove</i> for given view.

       <b>view</b><i>_</i><b>local</b><i>_</i><b>datas</b><i>_</i><b>remove</b> <i>view</i>
              Remove  a list of <i>local_data</i> for given view from stdin. Like lo-
              cal_datas_remove.

       <b>view</b><i>_</i><b>local</b><i>_</i><b>datas</b> <i>view</i>
              Add a list of <i>local_data</i> for given view from  stdin.   Like  lo-
              cal_datas.

    <b>EXIT</b> <b>CODE</b>
       The  unbound-control  program  exits  with status code 1 on error, 0 on
       success.

    <b>SET</b> <b>UP</b>
       The setup requires a self-signed certificate and private keys for  both
       the  server  and  client.   The  script <i>unbound-control-setup</i> generates
       these in the default run directory, or with -d  in  another  directory.
       If  you  change the access control permissions on the key files you can
       decide who can use unbound-control, by default owner and group but  not
       all  users.  Run the script under the same username as you have config-
       ured in unbound.conf or as root, so that the  daemon  is  permitted  to
       read the files, for example with:
           sudo -u unbound unbound-control-setup
       If  you  have  not configured a username in unbound.conf, the keys need
       read permission for the user credentials  under  which  the  daemon  is
       started.   The  script preserves private keys present in the directory.
       After running the  script  as  root,  turn  on  <b>control-enable</b>  in  <i>un-</i>
       <i>bound.conf</i>.

    <b>STATISTIC</b> <b>COUNTERS</b>
       The <i>stats</i> command shows a number of statistic counters.

       <i>threadX.num.queries</i>
              number of queries received by thread

       <i>threadX.num.queries_ip_ratelimited</i>
              number of queries rate limited by thread

       <i>threadX.num.cachehits</i>
              number  of queries that were successfully answered using a cache
              lookup

       <i>threadX.num.cachemiss</i>
              number of queries that needed recursive processing

       <i>threadX.num.dnscrypt.crypted</i>
              number of queries that were encrypted and successfully  decapsu-
              lated by dnscrypt.

       <i>threadX.num.dnscrypt.cert</i>
              number of queries that were requesting dnscrypt certificates.

       <i>threadX.num.dnscrypt.cleartext</i>
              number  of queries received on dnscrypt port that were cleartext
              and not a request for certificates.

       <i>threadX.num.dnscrypt.malformed</i>
              number  of  request  that  were  neither  cleartext,  not  valid
              dnscrypt messages.

       <i>threadX.num.prefetch</i>
              number  of  cache prefetches performed.  This number is included
              in cachehits, as the original query had the unprefetched  answer
              from  cache, and resulted in recursive processing, taking a slot
              in the requestlist.  Not part of the  recursivereplies  (or  the
              histogram thereof) or cachemiss, as a cache response was sent.

       <i>threadX.num.expired</i>
              number of replies that served an expired cache entry.

       <i>threadX.num.recursivereplies</i>
              The number of replies sent to queries that needed recursive pro-
              cessing. Could be smaller than threadX.num.cachemiss if  due  to
              timeouts no replies were sent for some queries.

       <i>threadX.requestlist.avg</i>
              The  average  number  of requests in the internal recursive pro-
              cessing request list on insert of a new incoming recursive  pro-
              cessing query.

       <i>threadX.requestlist.max</i>
              Maximum  size  attained by the internal recursive processing re-
              quest list.

       <i>threadX.requestlist.overwritten</i>
              Number of requests in the request list that were overwritten  by
              newer  entries. This happens if there is a flood of queries that
              recursive processing and the server has a hard time.

       <i>threadX.requestlist.exceeded</i>
              Queries that were dropped because the  request  list  was  full.
              This  happens  if  a flood of queries need recursive processing,
              and the server can not keep up.

       <i>threadX.requestlist.current.all</i>
              Current size of the request list, includes internally  generated
              queries (such as priming queries and glue lookups).

       <i>threadX.requestlist.current.user</i>
              Current  size of the request list, only the requests from client
              queries.

       <i>threadX.recursion.time.avg</i>
              Average time it took to answer  queries  that  needed  recursive
              processing.  Note that queries that were answered from the cache
              are not in this average.

       <i>threadX.recursion.time.median</i>
              The median of the time it took to answer queries that needed re-
              cursive  processing.   The  median  means  that  50% of the user
              queries were answered in less than this time.   Because  of  big
              outliers  (usually queries to non responsive servers), the aver-
              age can be bigger than the median.  This median has been  calcu-
              lated by interpolation from a histogram.

       <i>threadX.tcpusage</i>
              The currently held tcp buffers for incoming connections.  A spot
              value on the time of the request.  This helps you  spot  if  the
              incoming-num-tcp buffers are full.

       <i>total.num.queries</i>
              summed over threads.

       <i>total.num.cachehits</i>
              summed over threads.

       <i>total.num.cachemiss</i>
              summed over threads.

       <i>total.num.dnscrypt.crypted</i>
              summed over threads.

       <i>total.num.dnscrypt.cert</i>
              summed over threads.

       <i>total.num.dnscrypt.cleartext</i>
              summed over threads.

       <i>total.num.dnscrypt.malformed</i>
              summed over threads.

       <i>total.num.prefetch</i>
              summed over threads.

       <i>total.num.expired</i>
              summed over threads.

       <i>total.num.recursivereplies</i>
              summed over threads.

       <i>total.requestlist.avg</i>
              averaged over threads.

       <i>total.requestlist.max</i>
              the maximum of the thread requestlist.max values.

       <i>total.requestlist.overwritten</i>
              summed over threads.

       <i>total.requestlist.exceeded</i>
              summed over threads.

       <i>total.requestlist.current.all</i>
              summed over threads.

       <i>total.recursion.time.median</i>
              averaged over threads.

       <i>total.tcpusage</i>
              summed over threads.

       <i>time.now</i>
              current time in seconds since 1970.

       <i>time.up</i>
              uptime since server boot in seconds.

       <i>time.elapsed</i>
              time since last statistics printout, in seconds.

    <b>EXTENDED</b> <b>STATISTICS</b>
       <i>mem.cache.rrset</i>
              Memory in bytes in use by the RRset cache.

       <i>mem.cache.message</i>
              Memory in bytes in use by the message cache.

       <i>mem.cache.dnscrypt_shared_secret</i>
              Memory in bytes in use by the dnscrypt shared secrets cache.

       <i>mem.cache.dnscrypt_nonce</i>
              Memory in bytes in use by the dnscrypt nonce cache.

       <i>mem.mod.iterator</i>
              Memory in bytes in use by the iterator module.

       <i>mem.mod.validator</i>
              Memory in bytes in use by the validator module. Includes the key
              cache and negative cache.

       <i>mem.streamwait</i>
              Memory in bytes in used by the TCP and TLS stream wait  buffers.
              These are answers waiting to be written back to the clients.

       <i>mem.http.query_buffer</i>
              Memory  in  bytes  used  by the HTTP/2 query buffers. Containing
              (partial) DNS queries waiting for request stream completion.

       <i>mem.http.response_buffer</i>
              Memory in bytes used by the HTTP/2 response buffers.  Containing
              DNS responses waiting to be written back to the clients.

       <i>histogram.&lt;sec&gt;.&lt;usec&gt;.to.&lt;sec&gt;.&lt;usec&gt;</i>
              Shows a histogram, summed over all threads. Every element counts
              the recursive queries whose reply time fit between the lower and
              upper  bound.   Times  larger  or  equal  to the lowerbound, and
              smaller than the upper bound.  There are 40 buckets, with bucket
              sizes doubling.

       <i>num.query.type.A</i>
              The  total number of queries over all threads with query type A.
              Printed for the other query types as  well,  but  only  for  the
              types for which queries were received, thus =0 entries are omit-
              ted for brevity.

       <i>num.query.type.other</i>
              Number of queries with query types 256-65535.

       <i>num.query.class.IN</i>
              The total number of queries over all threads with query class IN
              (internet).   Also printed for other classes (such as CH (CHAOS)
              sometimes used for debugging), or NONE, ANY, used by dynamic up-
              date.  num.query.class.other is printed for classes 256-65535.

       <i>num.query.opcode.QUERY</i>
              The  total  number of queries over all threads with query opcode
              QUERY.  Also printed for other opcodes, UPDATE, ...

       <i>num.query.tcp</i>
              Number of queries that were made using TCP towards  the  unbound
              server.

       <i>num.query.tcpout</i>
              Number  of queries that the unbound server made using TCP outgo-
              ing towards other servers.

       <i>num.query.tls</i>
              Number of queries that were made using TLS towards  the  unbound
              server.   These  are  also counted in num.query.tcp, because TLS
              uses TCP.

       <i>num.query.tls.resume</i>
              Number of TLS session resumptions, these are  queries  over  TLS
              towards  the  unbound  server  where the client negotiated a TLS
              session resumption key.

       <i>num.query.https</i>
              Number of queries that were made using HTTPS towards the unbound
              server.    These   are   also   counted   in  num.query.tcp  and
              num.query.tls, because HTTPS uses TLS and TCP.

       <i>num.query.ipv6</i>
              Number of queries that were made using IPv6 towards the  unbound
              server.

       <i>num.query.flags.RD</i>
              The  number  of  queries that had the RD flag set in the header.
              Also printed for flags QR, AA, TC, RA, Z,  AD,  CD.   Note  that
              queries  with  flags QR, AA or TC may have been rejected because
              of that.

       <i>num.query.edns.present</i>
              number of queries that had an EDNS OPT record present.

       <i>num.query.edns.DO</i>
              number of queries that had  an  EDNS  OPT  record  with  the  DO
              (DNSSEC  OK)  bit  set.   These queries are also included in the
              num.query.edns.present number.

       <i>num.query.ratelimited</i>
              The number of queries that are turned away from  being  send  to
              nameserver due to ratelimiting.

       <i>num.query.dnscrypt.shared_secret.cachemiss</i>
              The number of dnscrypt queries that did not find a shared secret
              in the cache.  The can be use to compute the shared  secret  hi-
              trate.

       <i>num.query.dnscrypt.replay</i>
              The  number  of  dnscrypt  queries that found a nonce hit in the
              nonce cache and hence are considered a query replay.

       <i>num.answer.rcode.NXDOMAIN</i>
              The number of answers to queries, from cache or from  recursion,
              that  had  the  return code NXDOMAIN. Also printed for the other
              return codes.

       <i>num.answer.rcode.nodata</i>
              The number of answers to queries that had the pseudo return code
              nodata.   This means the actual return code was NOERROR, but ad-
              ditionally, no data was carried in the answer  (making  what  is
              called  a  NOERROR/NODATA  answer).   These queries are also in-
              cluded in the num.answer.rcode.NOERROR number.  Common for  AAAA
              lookups when an A record exists, and no AAAA.

       <i>num.answer.secure</i>
              Number  of  answers that were secure.  The answer validated cor-
              rectly.  The AD bit might have been set in  some  of  these  an-
              swers,  where  the  client  signalled  (with DO or AD bit in the
              query) that they were ready to accept the AD bit in the answer.

       <i>num.answer.bogus</i>
              Number of answers that were bogus.  These  answers  resulted  in
              SERVFAIL to the client because the answer failed validation.

       <i>num.rrset.bogus</i>
              The  number  of rrsets marked bogus by the validator.  Increased
              for every RRset inspection that fails.

       <i>unwanted.queries</i>
              Number of queries that were  refused  or  dropped  because  they
              failed the access control settings.

       <i>unwanted.replies</i>
              Replies that were unwanted or unsolicited.  Could have been ran-
              dom traffic, delayed duplicates, very late answers, or could  be
              spoofing  attempts.   Some low level of late answers and delayed
              duplicates are to be expected with the UDP protocol.  Very  high
              values could indicate a threat (spoofing).

       <i>msg.cache.count</i>
              The number of items (DNS replies) in the message cache.

       <i>rrset.cache.count</i>
              The  number  of RRsets in the rrset cache.  This includes rrsets
              used by the messages in the message cache, but  also  delegation
              information.

       <i>infra.cache.count</i>
              The  number of items in the infra cache.  These are IP addresses
              with their timing and protocol support information.

       <i>key.cache.count</i>
              The number of items in the key cache.  These  are  DNSSEC  keys,
              one item per delegation point, and their validation status.

       <i>dnscrypt_shared_secret.cache.count</i>
              The  number  of items in the shared secret cache. These are pre-
              computed shared secrets for a given client public key/server se-
              cret  key  pair. Shared secrets are CPU intensive and this cache
              allows unbound to avoid recomputing the shared secret when  mul-
              tiple dnscrypt queries are sent from the same client.

       <i>dnscrypt_nonce.cache.count</i>
              The  number  of  items  in the client nonce cache. This cache is
              used to prevent dnscrypt queries replay. The client  nonce  must
              be  unique  for  each  client public key/server secret key pair.
              This cache should be able to host QPS * `replay window` interval
              keys  to  prevent  replay of a query during `replay window` sec-
              onds.

       <i>num.query.authzone.up</i>
              The number of queries answered  from  auth-zone  data,  upstream
              queries.   These  queries  would  otherwise have been sent (with
              fallback enabled) to the internet, but are now answered from the
              auth zone.

       <i>num.query.authzone.down</i>
              The  number  of  queries  for downstream answered from auth-zone
              data.  These queries are from downstream clients, and  have  had
              an answer from the data in the auth zone.

       <i>num.query.aggressive.NOERROR</i>
              The  number  of  queries answered using cached NSEC records with
              NODATA RCODE.  These queries would otherwise have been  sent  to
              the internet, but are now answered using cached data.

       <i>num.query.aggressive.NXDOMAIN</i>
              The  number  of  queries answered using cached NSEC records with
              NXDOMAIN RCODE.  These queries would otherwise have been sent to
              the internet, but are now answered using cached data.

       <i>num.query.subnet</i>
              Number  of queries that got an answer that contained EDNS client
              subnet data.

       <i>num.query.subnet_cache</i>
              Number of queries answered from the edns  client  subnet  cache.
              These are counted as cachemiss by the main counters, but hit the
              client subnet specific cache, after  getting  processed  by  the
              edns client subnet module.

       <i>num.rpz.action.&lt;rpz_action&gt;</i>
              Number  of queries answered using configured RPZ policy, per RPZ
              action type.  Possible actions are: nxdomain, nodata,  passthru,
              drop, local_data, disabled, and cname_override.

    <b>FILES</b>
       <i>/usr/local/etc/unbound/unbound.conf</i>
              unbound configuration file.

       <i>/usr/local/etc/unbound</i>
              directory with private keys (unbound_server.key and unbound_con-
              trol.key) and self-signed certificates  (unbound_server.pem  and
              unbound_control.pem).

    <b>SEE</b> <b>ALSO</b>
       <a href="unbound.conf.html"><i>unbound.conf</i>(5)</a>, <a href="unbound.html"><i>unbound</i>(8)</a>.



    NLnet Labs                       Aug 12, 2021               unbound-control(8)
    </pre>