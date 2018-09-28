# registry
[![Build Status](https://travis-ci.org/puppetlabs/puppetlabs-registry.png?branch=master)](https://travis-ci.org/puppetlabs/puppetlabs-registry)

#### Table of Contents

1. [Overview - What is the registry module?](#overview)
2. [Module Description - What registry does and why it is useful](#module-description)
3. [Setup - The basics of getting started with registry](#setup)
    * [Beginning with registry](#beginning-with-registry)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference](#reference)
    * [Public Defines](#public-defines)
    * [Public Types](#public-types)
    * [Parameters](#parameters)
6. [Limitations](#limitations)
7. [Development - Guide for contributing to registry](#development)

## Overview

This module supplies the types and providers you'll need to manage the Registry on your Windows nodes.

## Module Description

The Registry is a hierarchical database built into Microsoft Windows. It stores settings and other information for the operating system and a wide range of applications. This module lets Puppet manage individual Registry keys and values, and provides a simplified way to manage Windows services.

## Setup

This module must be installed on your Puppet master. We've tested it with Puppet agents running on Windows Server 2008 R2, 2012, and 2012 R2.

### Beginning with registry

Use the `registry_key` type to manage a single registry key:

``` puppet
registry_key { 'HKLM\System\CurrentControlSet\Services\Puppet':
    ensure => present,
}
```

## Usage

The registry module works mainly through two types: `registry_key` and `registry_value`. These types combine to let you specify a Registry container and its intended contents.

### Manage a single Registry value

``` puppet
registry_value { 'HKLM\System\CurrentControlSet\Services\Puppet\Description':
  ensure => present,
  type   => string,
  data   => "The Puppet Agent service periodically manages your configuration",
}
```

### Manage a Registry value and its parent key in one declaration

``` puppet
class myapp {
  registry::value { 'puppetmaster':
  key  => 'HKLM\Software\Vendor\PuppetLabs',
  data => 'puppet.puppet.com',
  }
}
```

Puppet looks up the key 'HKLM\Software\Vendor\PuppetLabs' and makes sure it contains a value named 'puppetmaster' containing the string 'puppet.puppet.com'.

**Note:** the `registry::value` define only manages keys and values in the system-native architecture. In other words, 32-bit keys applied in a 64-bit OS aren't managed by this define; instead, you must use the types, [`registry_key`](#type-registry_key) and [`registry_value`](#type-registry_value) individually.

Within this define, you can specify multiple Registry values for one Registry key and manage them all at once.

### Set the default value for a key

``` puppet
registry::value { 'Setting0':
  key   => 'HKLM\System\CurrentControlSet\Services\Puppet',
  value => '(default)',
  data  => "Hello World!",
}
```

You can still add values in a string (or array) beyond the default, but you can only set one default value per key.


### Purge existing values

By default, if a key includes additional values besides the ones you specify through this module, Puppet leaves those extra values in place. To change that, use the `purge_values => true` parameter of the `registry_key` resource. **Enabling this feature deletes any values in the key that are not managed by Puppet.**

The `registry::purge_example` class provides a quick and easy way to see a demonstration of how this works. This example class has two modes of operation determined by the Facter fact `PURGE_EXAMPLE_MODE`: 'setup' and 'purge'.

To run the demonstration, make sure the `registry::purge_example` class is included in your node catalog, then set an environment variable in PowerShell. This sets up a Registry key that contains six values.

``` powershell
  PS C:\> $env:FACTER_PURGE_EXAMPLE_MODE = 'setup'
  PS C:\> puppet agent --test

  notice: /Stage[main]/Registry::Purge_example/Registry_key[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value3]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value2]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_key[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\SubKey]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value5]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value6]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\SubKey\Value1]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value1]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\SubKey\Value2]/ensure: created
  notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value4]/ensure: created
  notice: Finished catalog run in 0.14 seconds
```

Switching the mode to 'purge' causes the class to only manage three of the six `registry_value` resources. The other three are purged because they are not specifically declared in the manifest.
Notice how `Value4`, `Value5` and `Value6` are being removed.

``` powershell
PS C:\> $env:FACTER_PURGE_EXAMPLE_MODE = 'purge'
PS C:\> puppet agent --test

notice: /Registry_value[hklm\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value4]/ensure: removed
notice: /Registry_value[hklm\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value6]/ensure: removed
notice: /Registry_value[hklm\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value5]/ensure: removed
notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value3]/data: data changed 'key3' to 'should not be purged'
notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value2]/data: data changed '2' to '0'
notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value1]/data: data changed '1' to '0'
notice: Finished catalog run in 0.16 seconds
```

### Manage Windows services

The `registry::service` define manages entries in the Microsoft service control framework by automatically manipulating values in the key `HKLM\System\CurrentControlSet\Services\$name\`.

This is an alternative approach to using INSTSRV.EXE [1](http://support.microsoft.com/kb/137890).

``` powershell
registry::service { puppet:
  ensure       => present,
  display_name => "Puppet Agent",
  description  => "Periodically fetches and applies configurations from a Puppet master server.",
  command      => 'C:\PuppetLabs\Puppet\service\daemon.bat',
}
```

## Reference

### Public Defines
* `registry::value`: Manages the parent key for a particular value. If the parent key doesn't exist, Puppet automatically creates it.
* `registry::service`: Manages entries in the Microsoft service control framework by manipulating values in the key `HKLM\System\CurrentControlSet\Services\$name\`.

### Public Types
* `registry_key`: Manages individual Registry keys.
* `registry_value`: Manages individual Registry values.

### Parameters

#### `registry::value`:

All parameters are required unless otherwise stated.

##### `key`

Specifies a Registry key for Puppet to manage. Note that if any of the parent keys in the path do not exist, the resource raises an error. Use the `registry_key` to create the parent key prior to setting a registry value. Valid options: a string containing a Registry path.

##### `data`

Provides the contents of the specified value. Valid options: a string by default; an array if specified through the `type` parameter.

##### `type`

*Optional.* Sets the data type of the specified value. Valid options: 'string', 'array', 'dword', 'qword', 'binary' and 'expand'. Default value: 'string'.

##### `value`

*Optional.* Determines what Registry value(s) to manage within the specified key. To set a Registry value as the default value for its parent key, name the value '(default)'. Valid options: a string. Default value: the title of your declared resource.

#### `registry_key`

##### `ensure`

Tells Puppet whether the key should or shouldn't exist. Valid options: 'present' and 'absent'. Default value: 'present'.

##### `path`

Specifies a Registry key for Puppet to manage. If any of the parent keys in the path don't exist, Puppet creates them automatically. Valid options: a string containing a Registry path. For example: `HKLM\Software` or `HKEY_LOCAL_MACHINE\Software\Vendor`.

If Puppet is running on a 64-bit system, the 32-bit Registry key can be explicitly managed using a prefix. For example: `32:HKLM\Software`.

##### `purge_values`

*Optional.* Specifies whether to delete any values in the specified key that are not managed by Puppet. Valid options: `true` and `false`. Default value: `false`.

For more on this parameter, see the [Purge existing values section](#purge-existing-values) under Usage.

#### `registry_value`

##### `path`

*Optional.* Specifies a Registry value for Puppet to manage. Valid options: a string containing a Registry path. If any of the parent keys in the path don't exist, Puppet creates them automatically. For example: `HKLM\Software` or `HKEY_LOCAL_MACHINE\Software\Vendor`. Default value: the title of your declared resource.

If Puppet is running on a 64-bit system, the 32-bit Registry key can be explicitly managed using a prefix. For example: `32:HKLM\Software\Value3`.

##### `ensure`

Tells Puppet whether the value should or shouldn't exist. Valid options: 'present' and 'absent'. Default value: 'present'.

##### `type`

*Optional.* Sets the data type of the specified value. Valid options: 'string', 'array', 'dword', 'qword', 'binary' and 'expand'. Default value: 'string'.

##### `data`

Provides the contents of the specified value. Valid options: a string by default; an array if specified through the `type` parameter.

#### `registry::service`

##### `ensure`

Tells Puppet whether the service should or shouldn't exist. Valid options: 'present' and 'absent'. Default value: 'present'.

##### `display_name`

*Optional.* Provides a Display Name for the service. Valid options: a string. Default value: the title of your declared resource.

##### `description`

*Optional.* Provides a description of the service. Valid options: a string. Default value: blank.

##### `command`

Specifies the command to execute when starting the service. Valid options: a string containing the absolute path to an executable file.

##### `start`

Specifies the starting mode of the service. Valid options: 'automatic', 'manual' and 'disabled'.

Puppet's [native service resource](http://docs.puppet.com/references/latest/type.html#service) can also be used to manage this setting.

## Limitations

* Keys within `HKEY_LOCAL_MACHINE` (`hklm`), `HKEY_CLASSES_ROOT` (`hkcr`) or `HKEY_USERS` (`hku`) are supported. Other predefined root keys (e.g., `HKEY_CURRENT_USER`) are not currently supported.
* Puppet doesn't recursively delete Registry keys.

Please report any issues through our [Module Issue Tracker](https://tickets.puppet.com/browse/MODULES).

## Development

Puppet Inc modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppet.com/forge/contributing.html)

### Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-registry/graphs/contributors)
