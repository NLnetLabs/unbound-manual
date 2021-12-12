.. _doc_rfc:

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
:RFC:`1034`    Domain Names – Concepts and Facilities
:RFC:`1035`    Domain Names – Implementation and Specifciation
:RFC:`1101`    DNS Encoding of Network Names and Other Types
:RFC:`1123`    Requirements for Internet Hosts -- Application and Support
:RFC:`1183`    New DNS RR Definitions
:RFC:`1337`    TIME-WAIT Assassination Hazards in TCP
:RFC:`1521`    MIME (Multipurpose Internet Mail Extensions) Part One: Mechanisms for Specifying and Describing the Format of Internet Message Bodies
:RFC:`1706`    DNS NSAP Resource Records
:RFC:`1712`    DNS Encoding of Geographical Location
:RFC:`1876`    A Means for Expressing Location Information in the Domain Name System
:RFC:`1982`    Serial Number Arithmetic
:RFC:`1995`    Incremental Zone Transfer in DNS
:RFC:`1996`    A Mechanism for Prompt Notification of Zone Changes (DNS NOTIFY)
:RFC:`2163`    Using the Internet DNS to Distribute MIXER Conformant Global Address Mapping (MCGAM)
:RFC:`2181`    Clarifications to the DNS Specification
:RFC:`2182`    Selection and Operation of Secondary DNS Servers
:RFC:`2230`    Key Exchange Delegation Record for the DNS
:RFC:`2253`    Lightweight Directory Access Protocol (v3): UTF-8 String Representation of Distinguished Names
:RFC:`2308`    Negative Caching of DNS Queries (DNS NCACHE)
:RFC:`2535`    Domain Name System Security Extensions
:RFC:`2536`    DSA KEYs and SIGs in the Domain Name System (DNS)
:RFC:`2537`    RSA/MD5 KEYs and SIGs in the Domain Name System (DNS)
:RFC:`2538`    Storing Certificates in the Domain Name System (DNS)
:RFC:`2539`    Storage of Diffie-Hellman Keys in the Domain Name System (DNS)
:RFC:`2606`    Reserved Top Level DNS Names
:RFC:`2671`    Extension Mechanisms for DNS (EDNS0)
:RFC:`2672`    Non-Terminal DNS Name Redirection
:RFC:`2673`    Binary Labels in the Domain Name System
:RFC:`2782`    A DNS RR for specifying the location of services (DNS SRV)
:RFC:`2874`    DNS Extensions to Support IPv6 Address Aggregation and Renumbering
:RFC:`2915`    The Naming Authority Pointer (NAPTR) DNS Resource Record
:RFC:`2930`    Secret Key Establishment for DNS (TKEY RR)
:RFC:`3110`    RSA/SHA-1 SIGs and RSA KEYs in the Domain Name System (DNS)
:RFC:`3123`    A DNS RR Type for Lists of Address Prefixes (APL RR)
:RFC:`3225`    Indicating Resolver Support of DNSSEC
:RFC:`3526`    More Modular Exponential (MODP) Diffie-Hellman groups for Internet Key Exchange (IKE)
:RFC:`3597`    Handling of Unknown DNS Resource Record (RR) Types
:RFC:`3779`    X.509 Extensions for IP Addresses and AS Identifiers
:RFC:`4007`    IPv6 Scoped Address Architecture
:RFC:`4025`    A Method for Storing IPsec Keying Material in DNS
:RFC:`4033`    DNS Security Introduction and Requirements
:RFC:`4034`    Resource Records for the DNS Security Extensions
:RFC:`4035`    Protocol Modifications for the DNS Security Extensions
:RFC:`4255`    Using DNS to Securely Publish Secure Shell (SSH) Key Fingerprints
:RFC:`4343`    Domain Name System (DNS) Case Insensitivity Clarification
:RFC:`4398`    Storing Certificates in the Domain Name System (DNS)
:RFC:`4431`    The DNSSEC Lookaside Validation (DLV) DNS Resource Record
:RFC:`4509`    Use of SHA-256 in DNSSEC Delegation Signer (DS) Resource Records (RRs)
:RFC:`4592`    The Role of Wildcards in the Domain Name System
:RFC:`4597`    Conferencing Scenarios
:RFC:`4697`    Observed DNS Resolution Misbehavior
:RFC:`4701`    A DNS Resource Record (RR) for Encoding Dynamic Host Configuration Protocol (DHCP) Information (DHCID RR)
:RFC:`5001`    DNS Name Server Identifier (NSID) Option
:RFC:`5011`    Automated Updates of DNS Security (DNSSEC) Trust Anchors
:RFC:`5114`    Additional Diffie-Hellman Groups for Use with IETF Standards
:RFC:`5155`    DNS Security (DNSSEC) Hashed Authenticated Denial of Existence
:RFC:`5205`    Host Identity Protocol (HIP) Domain Name System (DNS) Extension
:RFC:`5358`    Preventing Use of Recursive Nameservers in Reflector Attacks
:RFC:`5452`    Measures for Making DNS More Resilient against Forged Answers
:RFC:`5702`    Use of SHA-2 Algorithms with RSA in DNSKEY and RRSIG Resource Records for DNSSEC
:RFC:`5933`    Use of GOST Signature Algorithms in DNSKEY and RRSIG Resource Records for DNSSEC
:RFC:`6147`    DNS64: DNS Extensions for Network Address Translation from IPv6 Clients to IPv4 Servers
:RFC:`6234`    US Secure Hash Algorithms (SHA and SHA-based HMAC and HKDF)
:RFC:`6303`    Locally Served DNS Zones
:RFC:`6598`    IANA-Reserved IPv4 Prefix for Shared Address Space
:RFC:`6604`    xNAME RCODE and Status Bits Clarification
:RFC:`6605`    Elliptic Curve Digital Signature Algorithm (DSA) for DNSSEC
:RFC:`6672`    DNAME Redirection in the DNS
:RFC:`6698`    The DNS-Based Authentication of Named Entities (DANE) Transport Layer Security (TLS) Protocol: TLSA
:RFC:`6725`    DNS Security (DNSSEC) DNSKEY Algorithm IANA Registry Updates
:RFC:`6742`    DNS Resource Records for the Identifier-Locator Network Protocol (ILNP)
:RFC:`6761`    Special-Use Domain Names
:RFC:`6840`    Clarifications and Implementation Notes for DNS Security (DNSSEC)
:RFC:`6844`    DNS Certification Authority Authorization (CAA) Resource Record
:RFC:`6891`    Extension Mechanisms for DNS (EDNS(0))
:RFC:`6975`    Signaling Cryptographic Algorithm Understanding in DNS Security Extensions (DNSSEC)
:RFC:`7043`    Resource Records for EUI-48 and EUI-64 Addresses in the DNS
:RFC:`7344`    Automating DNSSEC Delegation Trust Maintenance
:RFC:`7413`    TCP Fast Open
:RFC:`7477`    Child-to-Parent Synchronization in DNS
:RFC:`7553`    The Uniform Resource Identifier (URI) DNS Resource Record
:RFC:`7646`    Definition and Use of DNSSEC Negative Trust Anchors
:RFC:`7686`    The ".onion" Special-Use Domain Name
:RFC:`7706`    Decreasing Access Time to Root Servers by Running One on Loopback
:RFC:`7816`    DNS Query Name Minimisation to Improve Privacy
:RFC:`7830`    The EDNS(0) Padding Option
:RFC:`7858`    Specification for DNS over Transport Layer Security (TLS)
:RFC:`7871`    Client Subnet in DNS Queries
:RFC:`7929`    DNS-Based Authentication of Named Entities (DANE) Bindings for OpenPGP
:RFC:`7958`    DNSSEC Trust Anchor Publication for the Root Zone
:RFC:`8020`    NXDOMAIN: There Really Is Nothing Underneath
:RFC:`8080`    Edwards-Curve Digital Security Algorithm (EdDSA) for DNSSEC
:RFC:`8145`    Signaling Trust Anchor Knowledge in DNS Security Extensions (DNSSEC)
:RFC:`8162`    Using Secure DNS to Associate Certificates with Domain Names for S/MIME
:RFC:`8198`    Aggressive Use of DNSSEC-Validated Cache
:RFC:`8310`    Usage Profiles for DNS over TLS and DNS over DTLS
:RFC:`8375`    Special-Use Domain 'home.arpa.'
:RFC:`8467`    Padding Policies for Extension Mechanisms for DNS (EDNS(0))
:RFC:`8482`    Providing Minimal-Sized Responses to DNS Queries That Have QTYPE=ANY
:RFC:`8484`    DNS Queries over HTTPS (DoH)
:RFC:`8509`    A Root Key Trust Anchor Sentinel for DNSSEC
:RFC:`8624`    Algorithm Implementation Requirements and Usage Guidance for DNSSEC
:RFC:`8767`    Serving Stale Data to Improve DNS Resiliency
:RFC:`8806`    Running a Root Server Local to a Resolver
:RFC:`8976`    Message Digest for DNS Zones
============== ====
