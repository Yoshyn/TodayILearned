# DnsMap

----
## What is DnsMap?
see [Github (kind of Fork)](https://github.com/resurrecting-open-source-projects/dnsmap)

> dnsmap is mainly meant to be used by pentesters during the information gathering/enumeration phase of infrastructure security assessments. During the enumeration stage, the security consultant would typically discover the target company's IP netblocks, domain names, phone numbers, etc.

Basically, it help you to find subdomain.

----
## usage

    kali ❯❯❯ dnsmap example.com
    dnsmap 0.30 - DNS Network Mapper by pagvac (gnucitizen.org)

    [+] searching (sub)domains for example.com using built-in wordlist
    [+] using maximum random delay of 10 millisecond(s) between requests

    blog.example.com
    IPv6 address #1: ::ffff:104.196.168.XX

    blog.example.com
    IP address #1: 104.196.168.XX

    download.example.com
    IPv6 address #1: ::ffff:13.249.11.XX
    IPv6 address #2: ::ffff:13.249.11.XXX
    ...

----
## Sources
* [kali.org](https://tools.kali.org/information-gathering/dnsmap)
* [google code](https://code.google.com/archive/p/dnsmap/)
