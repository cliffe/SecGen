#ntp

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with ntp](#setup)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

The ntp module installs, configures, and manages the NTP service.

##Module Description

The ntp module handles installing, configuring, and running NTP across a range of operating systems and distributions.

##Setup

###Beginning with ntp

`include '::ntp'` is enough to get you up and running.  If you wish to pass in parameters specifying which servers to use, then:

```puppet
class { '::ntp':
  servers => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
}
```

##Usage

All interaction with the ntp module can be done through the main ntp class. This means you can simply toggle the options in `::ntp` to have full functionality of the module.

###I just want NTP, what's the minimum I need?

```puppet
include '::ntp'
```

###I just want to tweak the servers, nothing else.

```puppet
class { '::ntp':
  servers => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
}
```

###I'd like to make sure I restrict who can connect as well.

```puppet
class { '::ntp':
  servers  => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict => ['127.0.0.1'],
}
```

###I just want to install a client that can't be queried

```puppet
class { '::ntp':
  servers   => ['ntp1.corp.com', 'ntp2.corp.com'],
  restrict  => [
    'default ignore',
    '-6 default ignore',
    '127.0.0.1',
    '-6 ::1',
    'ntp1.corp.com nomodify notrap nopeer noquery',
    'ntp1.corp.com nomodify notrap nopeer noquery'
  ],
}
```

###I only want to listen on specific interfaces, not on 0.0.0.0

Restricting ntp to a specific interface is especially useful on Openstack nodes which may have numerous virtual interfaces.

```puppet
class { '::ntp':
  servers  => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  interfaces => ['127.0.0.1', '1.2.3.4']
}
```

###I'd like to opt out of having the service controlled; we use another tool for that.

```puppet
class { '::ntp':
  servers        => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict       => ['127.0.0.1'],
  service_manage => false,
}
```

###I'd like to configure and run ntp, but I don't need to install it.

```puppet
class { '::ntp':
  package_manage => false,
}
```

###Looks great!  But I'd like a different template; we need to do something unique here.

```puppet
class { '::ntp':
  servers         => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict        => ['127.0.0.1'],
  service_manage  => false,
  config_template => 'different/module/custom.template.erb',
}
```

##Reference

###Classes

####Public Classes

* ntp: Main class, includes all other classes.

####Private Classes

* ntp::install: Handles the packages.
* ntp::config: Handles the configuration file.
* ntp::service: Handles the service.

###Parameters

The following parameters are available in the `::ntp` class:

####`autoupdate`

**Deprecated; replaced by the `package_ensure` parameter**. Tells Puppet whether to keep the ntp module updated to the latest version available. Valid options: true or false. Default value: false

####`broadcastclient`

Enable reception of broadcast server messages to any local interface.

####`config`

Specifies a file for ntp's configuration info. Valid options: string containing an absolute path. Default value: '/etc/ntp.conf' (or '/etc/inet/ntp.conf' on Solaris)


####`config_dir`

Specifies a directory for the ntp configuration files. Valid options: string containing an absolute path. Default value: undef

####`config_file_mode`

Specifies a file mode for the ntp configuration file. Valid options: string containing file mode. Default value: '0664'

####`config_template`

Specifies a file to act as a template for the config file. Valid options: string containing a path (absolute, or relative to the module path). Default value: 'ntp/ntp.conf.erb'

####`disable_auth`

Do  not  require cryptographic authentication for broadcast client, multicast 
client and symmetric passive associations.

####`disable_auth`

Disables kernel time discipline.

####`disable_dhclient`

Disables `ntp-servers` in `dhclient.conf` to avoid Dhclient from managing the NTP configuration.

####`disable_monitor`

Disables the monitoring facility in NTP. Valid options: true or false. Default value: true

####`driftfile`

Specifies an NTP driftfile. Valid options: string containing an absolute path. Default value: '/var/lib/ntp/drift' (except on AIX and Solaris)

#### `fudge`

Used to provide additional information for individual clock drivers. Valid options: array containing strings that follow the `fudge` command. Default value: [ ]

####`iburst_enable`

Specifies whether to enable the iburst option for every NTP peer. Valid options: true or false. Default value: false (except on AIX and Debian)

####`interfaces`

Specifies one or more network interfaces for NTP to listen on. Valid options: array. Default value: [ ]

####`interfaces_ignore`

Specifies one or more ignore pattern for the NTP listener configuration (e.g. all, wildcard, ipv6, ...). Valid options: array. Default value: [ ]

#### `keys`

Distributes keys to keys file. Valid options: array of keys. Default value: [ ]

####`keys_controlkey`

Specifies the key identifier to use with the ntpq utility. Valid options: value in the range of 1 to 65,534 inclusive. Default value: ' '

####`keys_enable`

Tells Puppet whether to enable key-based authentication. Valid options: true or false. Default value: false

####`keys_file`

Specifies the complete path and location of the MD5 key file containing the keys and key identifiers used by ntpd, ntpq and ntpdc when operating with symmetric key cryptography. Valid options: string containing an absolute path. Default value: `/etc/ntp.keys` (except on RedHat and Amazon, where it is `/etc/ntp/keys`).

####`keys_requestkey`

Specifies the key identifier to use with the ntpdc utility program. Valid options: value in the range of 1 to 65,534 inclusive. Default value: ' '

#### `keys_trusted`:
Provides one or more keys to be trusted by NTP. Valid options: array of keys. Default value: [ ]

#### `leapfile`

Specifies a leap second file for NTP to use. Valid options: string containing an absolute path. Default value: ' '

#### `logfile`

Specifies a log file for NTP to use instead of syslog. Valid options: string containing an absolute path. Default value: ' '

####`minpoll`

Tells Puppet to use non-standard minimal poll interval of upstream servers. Valid options: 3 to 16. Default option: undef.

####`maxpoll`

Tells Puppet to use non-standard maximal poll interval of upstream servers. Valid options: 3 to 16. Default option: undef, except FreeBSD (on FreeBSD `maxpoll` set 9 by default).

####`ntpsigndsocket`

Tells NTP to sign packets using the socket in the ntpsigndsocket path. NTP must be configured to sign sockets for this to work.
Valid option: a path to the socket directory; for example, for Samba it would be: 

~~~~
ntpsigndsocket = usr/local/samba/var/lib/ntp_signd/ 
~~~~

Default value: undef.

####`package_ensure`

Tells Puppet whether the NTP package should be installed, and what version. Valid options: 'present', 'latest', or a specific version number. Default value: 'present'

####`package_manage`

Tells Puppet whether to manage the NTP package. Valid options: true or false. Default value: true

####`package_name`

Tells Puppet what NTP package to manage. Valid options: string. Default value: 'ntp' (except on AIX and Solaris)

####`panic`

Specifies whether NTP should "panic" in the event of a very large clock skew. Applies only if `tinker` option set to "true" or in case your environment is in virtual machine. Valid options: unsigned shortint digit. Default value: 0 if environment is virtual, undef in all other cases.

####`peers`

List of ntp servers which the local clock can be synchronised against, or which can synchronise against the local clock.

####`preferred_servers`

Specifies one or more preferred peers. Puppet will append 'prefer' to each matching item in the `servers` array. Valid options: array. Default value: [ ]

####`restrict`

Specifies one or more `restrict` options for the NTP configuration. Puppet will prefix each item with 'restrict', so you only need to list the content of the restriction. Valid options: array. Default value for most operating systems:

~~~~
[
  'default kod nomodify notrap nopeer noquery',
  '-6 default kod nomodify notrap nopeer noquery',
  '127.0.0.1',
  '-6 ::1',
]
~~~~

Default value for AIX systems:

~~~~
[
  'default nomodify notrap nopeer noquery',
  '127.0.0.1',
]
~~~~

####`servers`

Specifies one or more servers to be used as NTP peers. Valid options: array. Default value: varies by operating system

####`service_enable`

Tells Puppet whether to enable the NTP service at boot. Valid options: true or false. Default value: true

####`service_ensure`

Tells Puppet whether the NTP service should be running. Valid options: 'running' or 'stopped'. Default value: 'running'

####`service_manage`

Tells Puppet whether to manage the NTP service. Valid options: true or false. Default value: true

####`service_name`

Tells Puppet what NTP service to manage. Valid options: string. Default value: varies by operating system

####`service_provider`

Tells Puppet which service provider to use for NTP. Valid options: string. Default value: 'undef'

####`stepout`

Tells puppet to change stepout. Applies only if `tinker` value is true. Valid options: unsigned shortint digit. Default value: undef.

####`tos`

Tells Puppet to enable tos options. Valid options: true of false. Default value: false

####`tos_minclock`

Specifies the minclock tos option. Valid options: numeric. Default value: 3

####`tos_minsane`

Specifies the minsane tos option. Valid options: numeric. Default value: 1

####`tos_floor`

Specifies the floor tos option. Valid options: numeric. Default value: 1

####`tos_ceiling`

Specifies the ceiling tos option. Valid options: numeric. Default value: 15

####`tos_cohort`

Specifies the cohort tos option. Valid options: '0' or '1'. Default value: 0

####`tinker`

Tells Puppet to enable tinker options. Valid options: true of false. Default value: false

####`udlc`

Specifies whether to configure ntp to use the undisciplined local clock as a time source. Valid options: true or false. Default value: false

####`udlc_stratum`

Specifies the stratum the server should operate at when using the undisciplined local clock as the time source. It is strongly suggested that this value be set to no less than 10 where ntpd may be accessible outside your immediate, controlled network. Default value: 10

##Limitations

This module has been tested on [all PE-supported platforms](https://forge.puppetlabs.com/supported#compat-matrix), and no issues have been identified. Additionally, it is tested (but not supported) on Solaris 10 and Fedora 20-22.

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

###Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-ntp/graphs/contributors)
