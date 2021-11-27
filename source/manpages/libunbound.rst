.. _doc_libunbound_manpage:

libunbound(3)
-------------

.. raw:: html

    <pre class="man">libunbound(3)                   unbound 1.13.2                   libunbound(3)



    <b>NAME</b>
       <b>libunbound,</b> <b>unbound.h,</b> <b>ub</b><i>_</i><b>ctx,</b> <b>ub</b><i>_</i><b>result,</b> <b>ub</b><i>_</i><b>callback</b><i>_</i><b>type,</b> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>cre-</b>
       <b>ate,</b> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>delete,</b> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>option,</b>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>get</b><i>_</i><b>option,</b>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>con-</b>
       <b>fig,</b>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>fwd,</b>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>stub,</b>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>tls,</b> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>resolv-</b>
       <b>conf,</b>      <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>hosts,</b>       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta,</b>       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta</b><i>_</i><b>autr,</b>
       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta</b><i>_</i><b>file,</b>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>trustedkeys,</b>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>debugout,</b> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>debu-</b>
       <b>glevel,</b> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>async,</b> <b>ub</b><i>_</i><b>poll,</b> <b>ub</b><i>_</i><b>wait,</b> <b>ub</b><i>_</i><b>fd,</b> <b>ub</b><i>_</i><b>process,</b>  <b>ub</b><i>_</i><b>resolve,</b>
       <b>ub</b><i>_</i><b>resolve</b><i>_</i><b>async,</b>      <b>ub</b><i>_</i><b>cancel,</b>     <b>ub</b><i>_</i><b>resolve</b><i>_</i><b>free,</b>     <b>ub</b><i>_</i><b>strerror,</b>
       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>print</b><i>_</i><b>local</b><i>_</i><b>zones,</b>     <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>zone</b><i>_</i><b>add,</b>      <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>zone</b><i>_</i><b>remove,</b>
       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>data</b><i>_</i><b>add,</b>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>data</b><i>_</i><b>remove</b>  - Unbound DNS validating resolver
       1.13.2 functions.

    <b>SYNOPSIS</b>
       <b>#include</b> <b>&lt;unbound.h&gt;</b>

       <i>struct</i> <i>ub_ctx</i> <i>*</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>create</b>(<i>void</i>);

       <i>void</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>delete</b>(<i>struct</i> <i>ub_ctx*</i> ctx);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>option</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> opt, <i>char*</i> val);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>get</b><i>_</i><b>option</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> opt, <i>char**</i> val);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>config</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> fname);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>fwd</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> addr);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>stub</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> zone, <i>char*</i> addr,
                 <i>int</i> isprime);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>tls</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>int</i> tls);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>resolvconf</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> fname);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>hosts</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> fname);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> ta);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta</b><i>_</i><b>autr</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> fname);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta</b><i>_</i><b>file</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> fname);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>trustedkeys</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> fname);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>debugout</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>FILE*</i> out);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>debuglevel</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>int</i> d);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>async</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>int</i> dothread);

       <i>int</i> <b>ub</b><i>_</i><b>poll</b>(<i>struct</i> <i>ub_ctx*</i> ctx);

       <i>int</i> <b>ub</b><i>_</i><b>wait</b>(<i>struct</i> <i>ub_ctx*</i> ctx);

       <i>int</i> <b>ub</b><i>_</i><b>fd</b>(<i>struct</i> <i>ub_ctx*</i> ctx);

       <i>int</i> <b>ub</b><i>_</i><b>process</b>(<i>struct</i> <i>ub_ctx*</i> ctx);

       <i>int</i> <b>ub</b><i>_</i><b>resolve</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> name,
                  <i>int</i> rrtype, <i>int</i> rrclass, <i>struct</i> <i>ub_result**</i> result);

       <i>int</i> <b>ub</b><i>_</i><b>resolve</b><i>_</i><b>async</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> name,
                        <i>int</i> rrtype, <i>int</i> rrclass, <i>void*</i> mydata,
                        <i>ub_callback_type</i> callback, <i>int*</i> async_id);

       <i>int</i> <b>ub</b><i>_</i><b>cancel</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>int</i> async_id);

       <i>void</i> <b>ub</b><i>_</i><b>resolve</b><i>_</i><b>free</b>(<i>struct</i> <i>ub_result*</i> result);

       <i>const</i> <i>char</i> <i>*</i> <b>ub</b><i>_</i><b>strerror</b>(<i>int</i> err);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>print</b><i>_</i><b>local</b><i>_</i><b>zones</b>(<i>struct</i> <i>ub_ctx*</i> ctx);

       <i>int</i>  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>zone</b><i>_</i><b>add</b>(<i>struct</i>  <i>ub_ctx*</i>  ctx,   <i>char*</i>   zone_name,   <i>char*</i>
       zone_type);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>zone</b><i>_</i><b>remove</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> zone_name);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>data</b><i>_</i><b>add</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> data);

       <i>int</i> <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>data</b><i>_</i><b>remove</b>(<i>struct</i> <i>ub_ctx*</i> ctx, <i>char*</i> data);

    <b>DESCRIPTION</b>
       <b>Unbound</b>  is  an implementation of a DNS resolver, that does caching and
       DNSSEC validation. This is the library API, for using the -lunbound li-
       brary.   The  server  daemon  is  described in <a href="unbound.html"><i>unbound</i>(8)</a>.  The library
       works independent from a running unbound server, and  can  be  used  to
       convert  hostnames to ip addresses, and back, and obtain other informa-
       tion from the DNS. The library performs public-key  validation  of  re-
       sults with DNSSEC.

       The  library  uses a variable of type <i>struct</i> <i>ub_ctx</i> to keep context be-
       tween calls. The user must maintain it, creating it with  <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>create</b>
       and  deleting  it with <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>delete</b>.  It can be created and deleted at
       any time. Creating it anew removes any previous configuration (such  as
       trusted keys) and clears any cached results.

       The  functions are thread-safe, and a context can be used in a threaded
       (as well as in a non-threaded) environment. Also resolution (and  vali-
       dation)  can  be performed blocking and non-blocking (also called asyn-
       chronous).  The async method returns from the call immediately, so that
       processing can go on, while the results become available later.

       The functions are discussed in turn below.

    <b>FUNCTIONS</b>
       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>create</b>
              Create  a  new context, initialised with defaults.  The informa-
              tion from /etc/resolv.conf and /etc/hosts is not utilised by de-
              fault. Use <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>resolvconf</b> and <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>hosts</b> to read them.  Be-
              fore   you   call    this,    use    the    openssl    functions
              CRYPTO_set_id_callback and CRYPTO_set_locking_callback to set up
              asynchronous operation if you use lib openssl  (the  application
              calls  these  functions once for initialisation).  Openssl 1.0.0
              or later uses the CRYPTO_THREADID_set_callback function.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>delete</b>
              Delete validation context and free associated  resources.   Out-
              standing  async  queries are killed and callbacks are not called
              for them.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>option</b>
              A power-user interface that lets you specify one of the  options
              from  the  config  file format, see <a href="unbound.conf.html"><i>unbound.conf</i>(5)</a>. Not all op-
              tions are relevant. For some specific options,  such  as  adding
              trust anchors, special routines exist. Pass the option name with
              the trailing ':'.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>get</b><i>_</i><b>option</b>
              A power-user interface that gets an option value.  Some  options
              cannot  be  gotten,  and others return a newline separated list.
              Pass the option name without trailing ':'.  The  returned  value
              must be free(2)d by the caller.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>config</b>
              A  power-user  interface that lets you specify an unbound config
              file, see <a href="unbound.conf.html"><i>unbound.conf</i>(5)</a>, which is read for configuration.  Not
              all  options  are  relevant.  For some specific options, such as
              adding trust anchors, special routines exist.  This function  is
              thread-safe  only  if a single instance of ub_ctx* exists in the
              application.  If several instances exist the application has  to
              ensure  that ub_ctx_config is not called in parallel by the dif-
              ferent instances.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>fwd</b>
              Set machine to forward DNS queries to, the caching  resolver  to
              use.   IP4 or IP6 address. Forwards all DNS requests to that ma-
              chine, which is expected to run a  recursive  resolver.  If  the
              proxy  is not DNSSEC capable, validation may fail. Can be called
              several times, in that case the addresses  are  used  as  backup
              servers.   At this time it is only possible to set configuration
              before the first resolve is done.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>stub</b>
              Set a stub zone, authoritative dns servers to use for a particu-
              lar  zone.  IP4 or IP6 address.  If the address is NULL the stub
              entry is removed.  Set isprime true if you configure root  hints
              with it.  Otherwise similar to the stub zone item from unbound's
              config file.  Can be called several times, for different  zones,
              or  to  add  multiple  addresses for a particular zone.  At this
              time it is only possible to set configuration before  the  first
              resolve is done.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>tls</b>
              Enable  DNS over TLS (DoT) for machines set with <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>set</b><i>_</i><b>fwd.</b>
              At this time it is only possible to set configuration before the
              first resolve is done.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>resolvconf</b>
              By  default  the root servers are queried and full resolver mode
              is used, but you can use this call to read  the  list  of  name-
              servers  to  use  from  the  filename  given.  Usually "/etc/re-
              solv.conf". Uses those nameservers as caching proxies.  If  they
              do  not  support  DNSSEC, validation may fail.  Only nameservers
              are picked up, the searchdomain, ndots and other  settings  from
              <i>resolv.conf</i>(5)  are ignored.  If fname NULL is passed, "/etc/re-
              solv.conf" is used (if on Windows,  the  system-wide  configured
              nameserver is picked instead).  At this time it is only possible
              to set configuration before the first resolve is done.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>hosts</b>
              Read  list  of  hosts  from   the   filename   given.    Usually
              "/etc/hosts".  When  queried for, these addresses are not marked
              DNSSEC secure. If fname NULL is passed, "/etc/hosts" is used (if
              on  Windows,  etc/hosts from WINDIR is picked instead).  At this
              time it is only possible to set configuration before  the  first
              resolve is done.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta</b>
              Add  a  trust  anchor  to the given context.  At this time it is
              only possible to add trusted keys before the  first  resolve  is
              done.   The format is a string, similar to the zone-file format,
              [domainname] [type] [rdata contents]. Both DS and DNSKEY records
              are accepted.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta</b><i>_</i><b>autr</b>
              Add  filename  with  automatically  tracked  trust anchor to the
              given context.  Pass name of a file with the managed  trust  an-
              chor.   You  can create this file with <i>unbound-anchor</i>(8) for the
              root anchor.  You can also create it with an initial  file  with
              one  line  with a DNSKEY or DS record.  If the file is writable,
              it is updated when the trust anchor changes.  At this time it is
              only  possible  to  add trusted keys before the first resolve is
              done.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>add</b><i>_</i><b>ta</b><i>_</i><b>file</b>
              Add trust anchors to the given context.  Pass  name  of  a  file
              with DS and DNSKEY records in zone file format.  At this time it
              is only possible to add trusted keys before the first resolve is
              done.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>trustedkeys</b>
              Add  trust  anchors  to  the  given context.  Pass the name of a
              bind-style config file with trusted-keys{}.  At this time it  is
              only  possible  to  add trusted keys before the first resolve is
              done.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>debugout</b>
              Set debug and error log output to the given stream. Pass NULL to
              disable  output.  Default  is stderr. File-names or using syslog
              can be enabled using config options, this routine is  for  using
              your own stream.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>debuglevel</b>
              Set  debug  verbosity  for  the  context.  Output is directed to
              stderr.  Higher debug level gives more output.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>async</b>
              Set a context behaviour for  asynchronous  action.   if  set  to
              true, enables threading and a call to <b>ub</b><i>_</i><b>resolve</b><i>_</i><b>async</b> creates a
              thread to handle work in the background.  If false, a process is
              forked  to  handle work in the background.  Changes to this set-
              ting after <b>ub</b><i>_</i><b>resolve</b><i>_</i><b>async</b> calls have been made have no  effect
              (delete and re-create the context to change).

       <b>ub</b><i>_</i><b>poll</b>
              Poll a context to see if it has any new results.  Do not poll in
              a loop, instead extract the fd below to poll for readiness,  and
              then  check, or wait using the wait routine.  Returns 0 if noth-
              ing to read, or nonzero if a result is available.   If  nonzero,
              call <b>ub</b><i>_</i><b>process</b> to do callbacks.

       <b>ub</b><i>_</i><b>wait</b>
              Wait  for a context to finish with results. Calls <b>ub</b><i>_</i><b>process</b> af-
              ter the wait for you. After the wait, there  are  no  more  out-
              standing asynchronous queries.

       <b>ub</b><i>_</i><b>fd</b>  Get  file  descriptor.  Wait  for it to become readable, at this
              point answers are returned from the asynchronous validating  re-
              solver.  Then call the <b>ub</b><i>_</i><b>process</b> to continue processing.

       <b>ub</b><i>_</i><b>process</b>
              Call  this routine to continue processing results from the vali-
              dating resolver (when the fd becomes  readable).   Will  perform
              necessary callbacks.

       <b>ub</b><i>_</i><b>resolve</b>
              Perform  resolution and validation of the target name.  The name
              is a domain name in a zero terminated text string.   The  rrtype
              and  rrclass are DNS type and class codes.  The result structure
              is newly allocated with the resulting data.

       <b>ub</b><i>_</i><b>resolve</b><i>_</i><b>async</b>
              Perform asynchronous resolution and  validation  of  the  target
              name.   Arguments mean the same as for <b>ub</b><i>_</i><b>resolve</b> except no data
              is returned immediately, instead a  callback  is  called  later.
              The callback receives a copy of the mydata pointer, that you can
              use to pass information to the callback. The callback type is  a
              function pointer to a function declared as

              void my_callback_function(void* my_arg, int err,
                                struct ub_result* result);

              The  async_id  is returned so you can (at your option) decide to
              track it and cancel the request if needed.  If you pass  a  NULL
              pointer the async_id is not returned.

       <b>ub</b><i>_</i><b>cancel</b>
              Cancel  an async query in progress.  This may return an error if
              the query does not exist, or the query is already  being  deliv-
              ered, in that case you may still get a callback for the query.

       <b>ub</b><i>_</i><b>resolve</b><i>_</i><b>free</b>
              Free struct ub_result contents after use.

       <b>ub</b><i>_</i><b>strerror</b>
              Convert error value from one of the unbound library functions to
              a human readable string.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>print</b><i>_</i><b>local</b><i>_</i><b>zones</b>
              Debug printout the local authority information to debug output.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>zone</b><i>_</i><b>add</b>
              Add new zone  to  local  authority  info,  like  local-zone  <i>un-</i>
              <i>bound.conf</i>(5) statement.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>zone</b><i>_</i><b>remove</b>
              Delete zone from local authority info.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>data</b><i>_</i><b>add</b>
              Add  resource  record  data  to  local  authority info, like lo-
              cal-data <a href="unbound.conf.html"><i>unbound.conf</i>(5)</a> statement.

       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>data</b><i>_</i><b>remove</b>
              Delete local authority data from the name given.

    <b>RESULT</b> <b>DATA</b> <b>STRUCTURE</b>
       The result of the DNS resolution and validation is returned  as  <i>struct</i>
       <i>ub_result</i>. The result structure contains the following entries.

            struct ub_result {
                 char* qname; /* text string, original question */
                 int qtype;   /* type code asked for */
                 int qclass;  /* class code asked for */
                 char** data; /* array of rdata items, NULL terminated*/
                 int* len;    /* array with lengths of rdata items */
                 char* canonname; /* canonical name of result */
                 int rcode;   /* additional error code in case of no data */
                 void* answer_packet; /* full network format answer packet */
                 int answer_len;  /* length of packet in octets */
                 int havedata; /* true if there is data */
                 int nxdomain; /* true if nodata because name does not exist */
                 int secure;   /* true if result is secure */
                 int bogus;    /* true if a security failure happened */
                 char* why_bogus; /* string with error if bogus */
                 int was_ratelimited; /* true if the query was ratelimited (SERVFAIL) by unbound */
                 int ttl;     /* number of seconds the result is valid */
            };

       If  both  secure  and bogus are false, security was not enabled for the
       domain of the query.  Else, they are not both  true,  one  of  them  is
       true.

    <b>RETURN</b> <b>VALUES</b>
       Many routines return an error code. The value 0 (zero) denotes no error
       happened. Other values can be passed to <b>ub</b><i>_</i><b>strerror</b> to obtain  a  read-
       able  error  string.   <b>ub</b><i>_</i><b>strerror</b>  returns  a  zero terminated string.
       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>create</b> returns NULL on an error (a malloc failure).  <b>ub</b><i>_</i><b>poll</b> re-
       turns  true  if  some  information  may  be available, false otherwise.
       <b>ub</b><i>_</i><b>fd</b> returns a file descriptor or  -1  on  error.   <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>config</b>  and
       <b>ub</b><i>_</i><b>ctx</b><i>_</i><b>resolvconf</b>  attempt to leave errno informative on a function re-
       turn with file read failure.

    <b>SEE</b> <b>ALSO</b>
       <a href="unbound.conf.html"><i>unbound.conf</i>(5)</a>, <a href="unbound.html"><i>unbound</i>(8)</a>.

    <b>AUTHORS</b>
       <b>Unbound</b> developers are mentioned in the CREDITS file in  the  distribu-
       tion.



    NLnet Labs                       Aug 12, 2021                    libunbound(3)
    </pre>