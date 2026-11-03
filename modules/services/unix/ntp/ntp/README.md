# ntp

#### Table of Contents


1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with ntp](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

<a id="module-description"></a>
## Module description

The ntp module installs, configures, and manages the NTP service across a range of operating systems and distributions.

<a id="setup"></a>
## Setup

### Beginning with ntp

`include ntp` is enough to get you up and running. To pass in parameters specifying which servers to use:

```puppet
class { 'ntp':
  servers => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
}
```

<a id="usage"></a>
## Usage

All parameters for the ntp module are contained within the main `ntp` class, so for any function of the module, set the options you want. See the common usages below for examples.

### Install and enable NTP

```puppet
include ntp
```

### Change NTP servers

```puppet
class { 'ntp':
  servers => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
}
```

### Restrict who can connect

```puppet
class { 'ntp':
  servers  => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict => ['127.0.0.1'],
}
```

### Install a client that can't be queried

```puppet
class { 'ntp':
  servers   => ['ntp1.corp.com', 'ntp2.corp.com'],
  restrict  => [
    'default ignore',
    '-6 default ignore',
    '127.0.0.1',
    '-6 ::1',
    'ntp1.corp.com nomodify notrap nopeer noquery',
    'ntp2.corp.com nomodify notrap nopeer noquery'
  ],
}
```

### Listen on specific interfaces

Restricting NTP to a specific interface is especially useful on Openstack node, which may have numerous virtual interfaces.

```puppet
class { 'ntp':
  servers  => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  interfaces => ['127.0.0.1', '1.2.3.4']
}
```

### Opt out of Puppet controlling the service

```puppet
class { 'ntp':
  servers        => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict       => ['127.0.0.1'],
  service_manage => false,
}
```

### Configure and run ntp without installing

```puppet
class { 'ntp':
  package_manage => false,
}
```

### Pass in a custom template

```puppet
class { 'ntp':
  servers         => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  restrict        => ['127.0.0.1'],
  service_manage  => false,
  config_epp      => 'different/module/custom.template.epp',
}
```

### Connect to an NTP server with the burst option enabled

```puppet
class { 'ntp':
  servers => [ 'ntp1.corp.com', 'ntp2.corp.com' ],
  burst  => true,
}
```

<a id="reference"></a>
## Reference

See [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-ntp/blob/main/REFERENCE.md)

<a id="limitations"></a>
## Limitations

This module has been tested on [all PE-supported platforms](https://forge.puppetlabs.com/supported#compat-matrix). Additionally, it is tested (but not supported) on Solaris 10 and Fedora 20-22.

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-ntp/blob/main/metadata.json)

<a id="development"></a> 
## Development

We are experimenting with a new tool for running acceptance tests. It's name is [puppet_litmus](https://github.com/puppetlabs/puppet_litmus) this replaces beaker as the test runner. To run the acceptance tests follow the instructions [here](https://github.com/puppetlabs/puppet_litmus/wiki/Tutorial:-use-Litmus-to-execute-acceptance-tests-with-a-sample-module-(MoTD)#install-the-necessary-gems-for-the-module).

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. Please follow our guidelines when contributing changes.

For more information, see our [module contribution guide.](https://puppet.com/docs/puppet/latest/contributing.html)

### Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-ntp/graphs/contributors)
