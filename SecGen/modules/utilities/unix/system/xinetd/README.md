# xinetd
[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-xinetd.png)](https://travis-ci.org/puppetlabs/puppetlabs-xinetd)

This is the xinetd module.

## Overview

This module configures xinetd, and exposes the xinetd::service definition
for adding new services.

## Class: xinetd

Sets up the xinetd daemon. Has options for you in case you have specific
package names and service needs.

### Parameters

 * `confdir`
 * `conffile`
 * `package_name`
 * `service_name`
 * `service_restart`
 * `service_status`
 * `service_hasrestart`
 * `service_hasstatus`

Additionally, all the global defaults in the main xinetd.conf can be set. By 
default they are *not* set, allowing the internal xinetd defaults to be used:
(see `man xinetd.conf` for full descriptions)

 * `enabled`        - Takes a list of service ID's to enable.
 * `disabled`       - Takes a list of service ID's to disable.
 * `log_type`       - Determines where the service log output is sent.
 * `log_on_failure` - Determines what information is logged when a server cannot be started.
 * `log_on_success` - Determines what information is logged when a server is started and when that server exits.
 * `no_access`      - Determines the remote hosts to which the particular service is unavailable.
 * `only_from`      - Determines the remote hosts to which the particular service is available.
 * `max_load`       - Takes a floating point value as the load at which the service will stop accepting connections.
 * `instances`      - Determines the number of servers that can be simultaneously active for a service (the default is no limit).
 * `per_source`     - This specifies the maximum instances of this service per source IP address. 
 * `bind`           - Allows a service to be bound to a specific interface on the machine.
 * `mdns`           - On systems that support mdns registration of services (currently only Mac OS X), this will enable or disable registration of the service.
 * `v6only`         - Set to yes to use IPv6 only.
 * `passenv`        - The value of this attribute is a list of environment variables from xinetd's environment that will be passed to the server.
 * `env`            - The value of this attribute is a list of environment variables that will be added to the environment before starting a server.
 * `groups`         - If the groups attribute is set to "yes", then the server is executed with access to the groups that the server's effective UID has access to.
 * `umask`          - Sets the inherited umask for the service.
 * `banner`         - Takes the name of a file to be splatted at the remote host when a connection to that service is established.
 * `banner_fail`    - Takes the name of a file to be splatted at the remote host when a connection to that service is denied.
 * `banner_success` - Takes the name of a file to be splatted at the remote host when a connection to that service is granted. 

## Definition: xinetd::service

Sets up a xinetd service. All parameters match up with xinetd.conf(5) man
page.

### Parameters:

 * `server`       - required - determines the program to execute for this service
 * `port`         - optional - determines the service port (required if service is not listed in `/etc/services`)
 * `cps`          - optional
 * `flags`        - optional
 * `per_source`   - optional
 * `server_args`  - optional
 * `disable`      - optional - defaults to "no"
 * `socket_type`  - optional - defaults to "stream"
 * `protocol`     - optional - defaults to "tcp"
 * `user`         - optional - defaults to "root"
 * `group`        - optional - defaults to "root"
 * `instances`    - optional - defaults to "UNLIMITED"
 * `wait`         - optional - based on $protocol will default to "yes" for udp and "no" for tcp
 * `service_type` - optional - type setting in xinetd
 * `nice`         - optional - integer between -20 and 19, inclusive.
 * `redirect`     - optional - ip or hostname and port of the target service

### Sample Usage

```puppet
xinetd::service { 'tftp':
  port        => '69',
  server      => '/usr/sbin/in.tftpd',
  server_args => '-s /var/lib/tftp/',
  socket_type => 'dgram',
  protocol    => 'udp',
  cps         => '100 2',
  flags       => 'IPv4',
  per_source  => '11',
}
```

## Supported OSes

Supports Debian, FreeBSD, Suse, RedHat, and Amazon Linux OS Families. 



