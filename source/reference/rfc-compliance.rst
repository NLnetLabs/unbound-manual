RFC Compliance
==============

Unbound strives to be a reference implementation for emerging standards in the
Internet Engineering Task Force (IETF). The aim is to implement well-established
Internet Drafts as a compile option and drafts in the final stage of open
community review as an optional feature, that is disabled by default. Accepted
RFCs are implemented in Unbound according to the described standard.

The following table provides an extensive overview of all the RFC standards and
Internet drafts that have been implemented in Unbound.

============== ====
:rfc:`1034`    Domain Names – Concepts and Facilities
:rfc:`1035`    Domain Names – Implementation and Specification
:rfc:`1101`    DNS Encoding of Network Names and Other Types
:rfc:`1123`    Requirements for Internet Hosts -- Application and Support
:rfc:`1183`    New DNS RR Definitions
:rfc:`1337`    TIME-WAIT Assassination Hazards in TCP
:rfc:`1521`    MIME (Multipurpose Internet Mail Extensions) Part One: Mechanisms for Specifying and Describing the Format of Internet Message Bodies
:rfc:`1706`    DNS NSAP Resource Records
:rfc:`1712`    DNS Encoding of Geographical Location
:rfc:`1876`    A Means for Expressing Location Information in the Domain Name System
:rfc:`1982`    Serial Number Arithmetic
:rfc:`1995`    Incremental Zone Transfer in DNS
:rfc:`1996`    A Mechanism for Prompt Notification of Zone Changes (DNS NOTIFY)
:rfc:`2163`    Using the Internet DNS to Distribute MIXER Conformant Global Address Mapping (MCGAM)
:rfc:`2181`    Clarifications to the DNS Specification
:rfc:`2182`    Selection and Operation of Secondary DNS Servers
:rfc:`2230`    Key Exchange Delegation Record for the DNS
:rfc:`2253`    Lightweight Directory Access Protocol (v3): UTF-8 String Representation of Distinguished Names
:rfc:`2308`    Negative Caching of DNS Queries (DNS NCACHE)
:rfc:`2535`    Domain Name System Security Extensions
:rfc:`2536`    DSA KEYs and SIGs in the Domain Name System (DNS)
:rfc:`2537`    RSA/MD5 KEYs and SIGs in the Domain Name System (DNS)
:rfc:`2538`    Storing Certificates in the Domain Name System (DNS)
:rfc:`2539`    Storage of Diffie-Hellman Keys in the Domain Name System (DNS)
:rfc:`2606`    Reserved Top Level DNS Names
:rfc:`2671`    Extension Mechanisms for DNS (EDNS0)
:rfc:`2672`    Non-Terminal DNS Name Redirection
:rfc:`2673`    Binary Labels in the Domain Name System
:rfc:`2782`    A DNS RR for specifying the location of services (DNS SRV)
:rfc:`2874`    DNS Extensions to Support IPv6 Address Aggregation and Renumbering
:rfc:`2915`    The Naming Authority Pointer (NAPTR) DNS Resource Record
:rfc:`2930`    Secret Key Establishment for DNS (TKEY RR)
:rfc:`3110`    RSA/SHA-1 SIGs and RSA KEYs in the Domain Name System (DNS)
:rfc:`3123`    A DNS RR Type for Lists of Address Prefixes (APL RR)
:rfc:`3225`    Indicating Resolver Support of DNSSEC
:rfc:`3526`    More Modular Exponential (MODP) Diffie-Hellman groups for Internet Key Exchange (IKE)
:rfc:`3597`    Handling of Unknown DNS Resource Record (RR) Types
:rfc:`3779`    X.509 Extensions for IP Addresses and AS Identifiers
:rfc:`4007`    IPv6 Scoped Address Architecture
:rfc:`4025`    A Method for Storing IPsec Keying Material in DNS
:rfc:`4033`    DNS Security Introduction and Requirements
:rfc:`4034`    Resource Records for the DNS Security Extensions
:rfc:`4035`    Protocol Modifications for the DNS Security Extensions
:rfc:`4255`    Using DNS to Securely Publish Secure Shell (SSH) Key Fingerprints
:rfc:`4343`    Domain Name System (DNS) Case Insensitivity Clarification
:rfc:`4398`    Storing Certificates in the Domain Name System (DNS)
:rfc:`4431`    The DNSSEC Lookaside Validation (DLV) DNS Resource Record
:rfc:`4509`    Use of SHA-256 in DNSSEC Delegation Signer (DS) Resource Records (RRs)
:rfc:`4592`    The Role of Wildcards in the Domain Name System
:rfc:`4597`    Conferencing Scenarios
:rfc:`4697`    Observed DNS Resolution Misbehavior
:rfc:`4701`    A DNS Resource Record (RR) for Encoding Dynamic Host Configuration Protocol (DHCP) Information (DHCID RR)
:rfc:`5001`    DNS Name Server Identifier (NSID) Option
:rfc:`5011`    Automated Updates of DNS Security (DNSSEC) Trust Anchors
:rfc:`5114`    Additional Diffie-Hellman Groups for Use with IETF Standards
:rfc:`5155`    DNS Security (DNSSEC) Hashed Authenticated Denial of Existence
:rfc:`5205`    Host Identity Protocol (HIP) Domain Name System (DNS) Extension
:rfc:`5358`    Preventing Use of Recursive Nameservers in Reflector Attacks
:rfc:`5452`    Measures for Making DNS More Resilient against Forged Answers
:rfc:`5702`    Use of SHA-2 Algorithms with RSA in DNSKEY and RRSIG Resource Records for DNSSEC
:rfc:`5933`    Use of GOST Signature Algorithms in DNSKEY and RRSIG Resource Records for DNSSEC
:rfc:`6147`    DNS64: DNS Extensions for Network Address Translation from IPv6 Clients to IPv4 Servers
:rfc:`6234`    US Secure Hash Algorithms (SHA and SHA-based HMAC and HKDF)
:rfc:`6303`    Locally Served DNS Zones
:rfc:`6598`    IANA-Reserved IPv4 Prefix for Shared Address Space
:rfc:`6604`    xNAME RCODE and Status Bits Clarification
:rfc:`6605`    Elliptic Curve Digital Signature Algorithm (DSA) for DNSSEC
:rfc:`6672`    DNAME Redirection in the DNS
:rfc:`6698`    The DNS-Based Authentication of Named Entities (DANE) Transport Layer Security (TLS) Protocol: TLSA
:rfc:`6725`    DNS Security (DNSSEC) DNSKEY Algorithm IANA Registry Updates
:rfc:`6742`    DNS Resource Records for the Identifier-Locator Network Protocol (ILNP)
:rfc:`6761`    Special-Use Domain Names
:rfc:`6840`    Clarifications and Implementation Notes for DNS Security (DNSSEC)
:rfc:`6844`    DNS Certification Authority Authorization (CAA) Resource Record
:rfc:`6891`    Extension Mechanisms for DNS (EDNS(0))
:rfc:`6975`    Signaling Cryptographic Algorithm Understanding in DNS Security Extensions (DNSSEC)
:rfc:`7043`    Resource Records for EUI-48 and EUI-64 Addresses in the DNS
:rfc:`7344`    Automating DNSSEC Delegation Trust Maintenance
:rfc:`7413`    TCP Fast Open
:rfc:`7477`    Child-to-Parent Synchronization in DNS
:rfc:`7553`    The Uniform Resource Identifier (URI) DNS Resource Record
:rfc:`7646`    Definition and Use of DNSSEC Negative Trust Anchors
:rfc:`7686`    The ".onion" Special-Use Domain Name
:rfc:`7706`    Decreasing Access Time to Root Servers by Running One on Loopback
:rfc:`7830`    The EDNS(0) Padding Option
:rfc:`7858`    Specification for DNS over Transport Layer Security (TLS)
:rfc:`7871`    Client Subnet in DNS Queries
:rfc:`7929`    DNS-Based Authentication of Named Entities (DANE) Bindings for OpenPGP
:rfc:`7958`    DNSSEC Trust Anchor Publication for the Root Zone
:rfc:`8020`    NXDOMAIN: There Really Is Nothing Underneath
:rfc:`8080`    Edwards-Curve Digital Security Algorithm (EdDSA) for DNSSEC
:rfc:`8145`    Signaling Trust Anchor Knowledge in DNS Security Extensions (DNSSEC)
:rfc:`8162`    Using Secure DNS to Associate Certificates with Domain Names for S/MIME
:rfc:`8198`    Aggressive Use of DNSSEC-Validated Cache
:rfc:`8310`    Usage Profiles for DNS over TLS and DNS over DTLS
:rfc:`8375`    Special-Use Domain 'home.arpa.'
:rfc:`8467`    Padding Policies for Extension Mechanisms for DNS (EDNS(0))
:rfc:`8482`    Providing Minimal-Sized Responses to DNS Queries That Have QTYPE=ANY
:rfc:`8484`    DNS Queries over HTTPS (DoH)
:rfc:`8509`    A Root Key Trust Anchor Sentinel for DNSSEC
:rfc:`8624`    Algorithm Implementation Requirements and Usage Guidance for DNSSEC
:rfc:`8767`    Serving Stale Data to Improve DNS Resiliency
:rfc:`8806`    Running a Root Server Local to a Resolver
:rfc:`8914`    Extended DNS Errors
:rfc:`8976`    Message Digest for DNS Zones
:rfc:`9156`    DNS Query Name Minimisation to Improve Privacy
============== ====
