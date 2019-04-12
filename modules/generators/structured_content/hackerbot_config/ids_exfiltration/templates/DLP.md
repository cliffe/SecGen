## Introduction

This week's lab consists of problem based tasks. You should be able to complete all tasks using VMs on oVirt but may wish to use a prepared VM with OpenDPL pre-installed for task A3.

This week's lab is entirely problem-based.

## Data loss prevention (DLP)

Data loss prevention (DLP) involves monitoring network activity that indicates that sensitive information is being exfiltrated or handled incorrectly. Some DLP systems monitor local systems and data at rest (for example, HIDS), while others are focused on network traffic and data in motion (NIDS). Using DLP software can help to detect insecure processes in an organisation, such as storing sensitive data in unplanned or insecure places. It can also help to mitigate insider threat, and data exfiltration to remote attackers. A report by Bnet shows that 45 percent of employees take data when they change jobs, and data leakage and organisational doxing has become more frequent (for example, the Sony Pictures compromise).

Note that there is a variety of DLP solutions available, and the most robust enterprise solutions provide network monitoring (data in motion), file system monitoring (data at rest), and some DLP systems will also monitor local file transfers (for example, copying files to USB) to block exfiltration using local storage devices.

In order to be effective, an organisation must identify sensitive data in their organisation that should be monitored.

## Snort exfiltration detection (data in motion)

### Text-based exfiltration detection

Choose a file representing data you are going to detect and protect. For example, you may choose to use a document you previously created (such as an assignment you have completed in the past).

Write a Snort rule that detects the transfer of the contents of this file.

Transfer the file via (unencrypted) FTP, and show that your above rule detects the file transfer.

Transfer the file via (unencrypted) HTTP, and show that your above rule detects the file transfer.

Hint: you can include your sensitive data directly in a Snort rule. This is very closely related to the IDS Lab, which will be a helpful resource. Consider using the metadata:service tag in your rule.

It is fine to monitor all ports, so long as your rule(s) detect transfer via FTP and HTTP.



**Label it or save it as "DLP-A1".**

#### Hash-based exfiltration detection

Assuming the data you are protecting is sensitive, you likely don't want your Snort rules to contain direct copies of all your most sensitive data. For this reason, Snort rules can contain hashes to match against.

Write a Snort rule that detects the transfer of the contents of your file, based on hashes, so that the Snort rule does not contain any plain text of your document.

Hint: consider using the protected\_content keyword in your rule.

Transfer the file via (unencrypted) FTP, and show that your rule detects the file transfer.



**Label it or save it as "DLP-A2".**

### OpenDLP (data at rest)

[*OpenDLP*](https://code.google.com/p/opendlp/) is designed to detect sensitive data at rest. Although the project looks to be somewhat inactive, the software is functional and performs tasks similar to various commercial offerings, and is worth exploring to gain an understanding of what is available.

OpenDLP can be run as an agent (on the system you are scanning) or agentless to perform a credentialed scan over the network. Provided with credentials, it can scan Windows file shares.

It can scan directories for files containing matches to regular expressions. It comes with a number of pre-canned regexp, to detect USA social security numbers (SSN), credit card details, and so on. You can configure your own rules to scan for specific sensitive data.

Note that tools such as this can also be helpful in security audits and penetration tests, to identify potentially sensitive documents that are available on systems being scanned.

Use OpenDLP to scan a system, and show that it can be used to detect potentially sensitive data (such as your above document).

Hint: this may involve downloading and running the OpenDLP VM, generating a profile, providing credentials, then running a scan.

**Take screenshots of your use of OpenDLP to detect sensitive data, preferably your own file above, as evidence that you have completed this part of the task. **

**Label it or save it as "DLP-A3".**

### Squid Proxy SSL Bump (encrypted data in motion)

Encryption is an incredibly powerful tool for protecting confidentiality of data in transit, and is critical for enabling secure communication and individual privacy on the Internet. However, in a corporate environment it is often justified for an organisation to monitor network communications, for DLP reasons.

Many organisations configure security products to forcefully intercept and inspect secure connections. One of the most common ways of achieving this is for the organisation to create their own Certificate Authority (CA), adding that certificate to each client system (such as every desktop system in the organisation), and basically performing automated man in the middle (MITM) attacks against all those systems.

The general approach is that every client request (for example, a browser requesting access to a Website) is intercepted, and the interceptor signs its communication to the client using the organisation's CA (which the client is forced to trust, if they want to access the Internet), and forwards requests and responses to and from the actual target servers on the Internet. Thereby the organisation can inspect the traffic from the interception point.

Configure Squid to intercept and MITM all Web access so that even encrypted Websites, such as Facebook, can be monitored.

Related resources:

-   [*http://wiki.squid-cache.org/Features/MimicSslServerCert*](http://wiki.squid-cache.org/Features/MimicSslServerCert)

-   [*http://blog.davidvassallo.me/2011/03/22/squid-transparent-ssl-interception/*](http://blog.davidvassallo.me/2011/03/22/squid-transparent-ssl-interception/)

Hint: this will involve setting up Squid proxy on a VM, pointing a Web browser at Squid, checking that you can access the internet via the Squid proxy. Then setting up Squid to intercept HTTPS connections using SSL Bump/MimicSslServerCert. This won't be quick, you will need to create a new CA with Public and Private keys, then configure Squid to use these for interception. The CA public key can be imported into the Web browser to remove the untrusted connection warnings.

**Take screenshots of Squid being configured and used to intercept HTTPS, as evidence that you have completed this part of the task. **

**Label it or save it as "DLP-A4".**

Write a description of the security advantages and disadvantages to intercepting HTTPS (one page max).

**A description of the security advantages and disadvantages to intercepting HTTPS. **

**Label it or save it as "DLP-A5".**
