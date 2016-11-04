# Chocolatey Package Provider for Puppet

### Chocolatey for Business Now Available!

We're excited for you to learn more about what's available in the [Business editions](https://chocolatey.org/compare)!

## Build Status

Travis | AppVeyor
------------- | -------------
[![Build Status](https://travis-ci.org/chocolatey/puppet-chocolatey.png?branch=master)](https://travis-ci.org/chocolatey/puppet-chocolatey) | [![Build status](https://ci.appveyor.com/api/projects/status/8lo0ypk2m931okus/branch/master?svg=true)](https://ci.appveyor.com/project/ferventcoder/puppet-chocolatey/branch/master)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
    * [Why Chocolatey](#why-chocolatey)
3. [Setup - The basics of getting started with chocolatey](#setup)
    * [What Chocolatey affects](#what-chocolatey-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Chocolatey provider](#beginning-with-chocolatey-provider)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference](#reference)
    * [Classes](#public-classes)
    * [Facts](#facts)
    * [Types/Providers](#typesproviders)
    * [Package provider: Chocolatey](#package-provider-chocolatey)
    * [Class: chocolatey](#class-chocolatey)
6. [Limitations - OS compatibility, etc.](#limitations)
    * [Known Issues](#known-issues)
7. [Development - Guide for contributing to the module](#development)
8. [Attributions](#attributions)

## Overview

This is a [Puppet](http://docs.puppetlabs.com/) package provider for
[chocolatey](https://github.com/chocolatey/chocolatey), which is
like apt-get, but for Windows. This should be compatible with a wide
range of Puppet versions.

## Module Description

This is the official module for working with the [Chocolatey](https://chocolatey.org/about)
package manager.

This module supports all editions of Chocolatey, including FOSS, [Professional](https://chocolatey.org/compare) and [Chocolatey for Business](https://chocolatey.org/compare).

This module will ultimately be able to

* install Chocolatey
* work with custom location installations
* configure Chocolatey
* use Chocolatey as a package provider

### Why Chocolatey

Chocolatey is a nicer abstraction because it nearly mimics how package managers
on other operating systems work. If you can imagine the built in provider for
Windows versus Chocolatey, let's take a look at the use case of installing git:

~~~puppet
# Using built-in provider
package { "Git version 1.8.4-preview20130916":
  ensure    => installed,
  source    => 'C:\temp\Git-1.8.4-preview20130916.exe',
  install_options => ['/VERYSILENT']
}
~~~

~~~puppet
# Using Chocolatey (set as default for Windows)
package { 'git':
  ensure   => latest,
}
~~~

The built-in provider has the following needs:
 * Package name must match ***exactly*** the name from installed programs. See [package name must be DisplayName](https://docs.puppetlabs.com/puppet/latest/reference/resources_package_windows.html#package-name-must-be-the-displayname)
 * Package name has issues with unicode characters
 * Source must point to the location of the executable installer. See [source is required](https://docs.puppetlabs.com/puppet/latest/reference/resources_package_windows.html#the-source-attribute-is-required).
 * No `ensure => latest` - see [handling versions and upgrades](https://docs.puppetlabs.com/puppet/latest/reference/resources_package_windows.html#handling-versions-and-upgrades)

Chocolatey's provider on the other hand:
 * Package name only has to match the name of the package, which can be whatever you choose.
 * The package is a nice abstraction
 * Package knows how to install the software silently
 * Package knows where to get the executable installer
 * Source is free to specify different Chocolatey feeds
 * Chocolatey makes `package` more platform agnostic since it looks exactly like other platforms.


For reference, let's take a look at the [provider features available](https://docs.puppetlabs.com/references/latest/type.html#package-provider-features) as compared to the built-in provider and some other package managers:

<table>
  <thead>
    <tr>
      <th>Provider</th>
      <th>holdable</th>
      <th>install options</th>
      <th>installable</th>
      <th>package settings</th>
      <th>purgeable</th>
      <th>reinstallable</th>
      <th>uninstall options</th>
      <th>uninstallable</th>
      <th>upgradeable</th>
      <th>versionable</th>
      <th>virtual packages</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>windows</td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td> </td>
    </tr>
    <tr>
      <td>chocolatey</td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
    </tr>
    <tr>
      <td>apt</td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
    </tr>
    <tr>
      <td>yum</td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td> </td>
      <td> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
      <td><em>X</em> </td>
    </tr>
  </tbody>
</table>

## Setup

### What Chocolatey affects

Chocolatey affects your system and what software is installed on it, ranging
from tools and portable software to natively installed applications.

### Setup Requirements

Chocolatey requires the following components
 * Powershell v2+
   * intalled on most systems by default
 * .NET Framework v4+

### Beginning with Chocolatey provider

Install this module via any of these approaches:

* [puppet forge](http://forge.puppetlabs.com/chocolatey/chocolatey)
* git-submodule ([tutorial](http://goo.gl/e9aXh))
* [librarian-puppet](https://github.com/rodjek/librarian-puppet)
* [r10k](https://github.com/puppetlabs/r10k)

## Usage

Ensure Chocolatey is install and configured:

~~~puppet
include chocolatey
~~~

### Override default Chocolatey install location

~~~puppet
class {'chocolatey':
  choco_install_location => 'D:\secured\choco',
}
~~~

### Use an internal chocolatey.nupkg for Chocolatey installation

~~~puppet
class {'chocolatey':
  chocolatey_download_url         => 'https://internalurl/to/chocolatey.nupkg',
  use_7zip                        => false,
  choco_install_timeout_seconds   => 2700,
}
~~~

###  Use a file chocolatey.0.9.9.9.nupkg for installation

~~~puppet
class {'chocolatey':
  chocolatey_download_url         => 'file:///c:/location/of/chocolatey.0.9.9.9.nupkg',
  use_7zip                        => false,
  choco_install_timeout_seconds   => 2700,
}
~~~

### Specify the version of chocolatey by class parameters

~~~puppet
class {'chocolatey':
  chocolatey_download_url         => 'file:///c:/location/of/chocolatey.0.9.9.9.nupkg',
  use_7zip                        => false,
  choco_install_timeout_seconds   => 2700,
  chocolatey_version              => '0.9.9.9',
}
~~~


### Log chocolatey bootstrap installer script output

~~~puppet
class {'chocolatey':
  log_output              => true,
}
~~~

### Set Chocolatey as Default Windows Provider

If you want to set this provider as the site-wide default,
add to your `site.pp`:

~~~puppet
if $::kernel == 'windows' {
  Package { provider => chocolatey, }
}

# OR

case $operatingsystem {
  'windows': {
    Package { provider => chocolatey, }
  }
}
~~~

### With All Options

~~~puppet
package { 'notepadplusplus':
  ensure            => installed|latest|'1.0.0'|absent,
  provider          => 'chocolatey',
  install_options   => ['-pre','-params','"','param1','param2','"'],
  uninstall_options => ['-r'],
  source            => 'https://myfeed.example.com/api/v2',
}
~~~

* supports `installable` and `uninstallable`
* supports `versionable` so `ensure =>  '1.0'` works
* supports `upgradeable`
* supports `latest` (checks upstream), `absent` (uninstall)
* supports `install_options` for pre-release, other cli
* supports `uninstall_options` for pre-release, other cli
* supports `holdable`, requires choco 0.9.9+

### Simple install

~~~puppet
package { 'notepadplusplus':
  ensure   => installed,
  provider => 'chocolatey',
}
~~~

### Ensure always the newest version available

~~~puppet
package { 'notepadplusplus':
  ensure   => latest,
  provider => 'chocolatey',
}
~~~

### Ensure specific version

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
}
~~~

### Specify custom source

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
  source   => 'C:\local\folder\packages',
}
~~~

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
  source   => '\\unc\source\packages',
}
~~~

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
  source   => 'https://custom.nuget.odata.feed/api/v2/',
}
~~~

~~~puppet
package { 'notepadplusplus':
  ensure   => '6.7.5',
  provider => 'chocolatey',
  source   => 'C:\local\folder\packages;https://chocolatey.org/api/v2/',
}
~~~

### Install options with spaces

Spaces in arguments **must always** be covered with a separation. The example
below covers `-installArgs "/VERYSILENT /NORESTART"`.

~~~puppet
package {'launchy':
  ensure          => installed,
  provider        => 'chocolatey',
  install_options => ['-override', '-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
}
~~~

### Install options with quotes / spaces
The underlying installer may need quotes passed to it. This is possible, but not
as intuitive.  The example below covers passing
`/INSTALLDIR="C:\Program Files\somewhere"`.

For this to be passed through with Chocolatey, you will need a set of double
quotes surrounding the argument and two sets of double quotes surrounding the
item that must be quoted (see [how to pass/options/switches](https://github.com/chocolatey/choco/wiki/CommandsReference#how-to-pass-options--switches)). This makes the
string look like `-installArgs "/INSTALLDIR=""C:\Program Files\somewhere"""` for
proper use with Chocolatey.

Then for Puppet to handle that appropriately, we must split on ***every*** space.
Yes, on **every** space we must split the string or the result will come out
incorrectly. So this means it will look like the following:

~~~puppet
install_options => ['-installArgs',
  '"/INSTALLDIR=""C:\Program', 'Files\somewhere"""']
~~~

Make sure you have all of the right quotes - start it off with a single double
quote, then two double quotes, then close it all by closing the two double
quotes and then the single double quote or a possible three double quotes at
the end.

~~~puppet
package {'mysql':
  ensure          => latest,
  provider        => 'chocolatey',
  install_options => ['-override', '-installArgs',
    '"/INSTALLDIR=""C:\Program', 'Files\somewhere"""'],
}
~~~

You can split it up a bit for readability if it suits you:

~~~puppet
package {'mysql':
  ensure          => latest,
  provider        => 'chocolatey',
  install_options => ['-override', '-installArgs', '"'
    '/INSTALLDIR=""C:\Program', 'Files\somewhere""',
    '"'],
}
~~~

**Note:** The above is for Chocolatey v0.9.9+. You may need to look for an
alternative method to pass args if you have 0.9.8.x and below.

## Reference

### Classes
#### Public classes
* [`chocolatey`](#class-chocolatey)

#### Private classes
* `chocolatey::install.pp`: Ensures Chocolatey is installed.
* `chocolatey::config.pp`: Ensures Chocolatey is configured.

### Facts
* `chocolateyversion` - The version of the installed choco client (could also be provided by class parameter `chocolatey_version`).
* `choco_install_path` - The location of the installed choco client (could also be provided by class parameter `choco_install_location`).

### Types/Providers
* [Chocolatey provider](#package-provider-chocolatey)

### Package Provider: Chocolatey
Chocolatey implements a [package type](http://docs.puppetlabs.com/references/latest/type.html#package) with a resource provider, which is built into Puppet.

This provider supports the `install_options` and `uninstall_options` attributes,
which allow command-line options to be passed to the choco command. These options
should be specified as documented below.

 * Required binaries: `choco.exe`, usually found in `C:\Program Data\chocolatey\bin\choco.exe`.
   * The binary is searched for using the Environment Variable `ChocolateyInstall`, then by two known locations (`C:\Chocolatey\bin\choco.exe` and `C:\ProgramData\chocolatey\bin\choco.exe`).
   * On Windows 2003 you should install Chocolatey to `C:\Chocolatey` or somewhere besides the default. **NOTE**: the root of `C:\` is not a secure location by default, so you may want to update the security on the folder.
 * Supported features: `install_options`, `installable`, `uninstall_options`,
`uninstallable`, `upgradeable`, `versionable`.

#### Properties/Parameters

##### `ensure`
(**Property**: This attribute represents concrete state on the target system.)

What state the package should be in. You can choose which package to retrieve by
specifying a version number or `latest` as the ensure value. This defaults to
`installed`.

Valid options: `present` (also called `installed`), `absent`, `latest` or a version
number.

##### `install_options`
An array of additional options to pass when installing a package. These options are
package-specific, and should be documented by the software vendor. One commonly
implemented option is `INSTALLDIR`:

~~~puppet
package {'launchy':
  ensure          => installed,
  provider        => 'chocolatey',
  install_options => ['-installArgs', '"', '/VERYSILENT', '/NORESTART', '"'],
}
~~~

The above method of single quotes in an array is the only method you should use
in passing `install_options` with the Chocolatey provider. There are other ways
to do it, but they are passed through to Chocolatey in ways that may not be
sufficient.

This is the **only** place in Puppet where backslash separators should be used.
Note that backslashes in double-quoted strings *must* be double-escaped and
backslashes in single-quoted strings *may* be double-escaped.

##### `name`
(**Namevar**: If ommitted, this attribute's value will default to the resource's
title.)

The package name. This is the name that the packaging system uses internally.

##### `provider`
The specific backend to use for the `package` resource. Chocolatey is not the
default provider for Windows so it must be specified (or by using a resource
default, shown in Usage). Valid options for this provider are `'chocolatey'`.

##### `source`
Where to find the package file. Chocolatey maintains default sources in its
configuration file that it will use by default. Use this to override the default
source(s).

Chocolatey accepts different values for source, including accept paths to local
files/folders stored on the target system, URLs (to OData feeds), and network
drive paths. Puppet will not automatically retrieve source files for you, and
usually just passes the value of source to the package installation command.

You can use a `file` resource if you need to manually copy package files to the
target system.

##### `uninstall_options`
An array of additional options to pass when uninstalling a package. These options
are package-specific, and should be documented by the software vendor.

~~~puppet
package {'launchy':
  ensure          => absent,
  provider        => 'chocolatey',
  uninstall_options => ['-uninstallargs', '"', '/VERYSILENT', '/NORESTART', '"'],
}
~~~

The above method of single quotes in an array is the only method you should use
in passing `uninstall_options` with the Chocolatey provider. There are other ways
to do it, but they are passed through to Chocolatey in ways that may not be
sufficient.

This is the **only** place in Puppet where backslash separators should be used.
Note that backslashes in double-quoted strings *must* be double-escaped and
backslashes in single-quoted strings *may* be double-escaped.

### Class: chocolatey

Used for managing installation and configuration of Chocolatey itself.

#### Parameters

##### `choco_install_location`

Where Chocolatey install should be located. This needs to be an absolute path starting with a drive letter e.g. `c:\`. Defaults to the currently detected install location based on the `ChocolateyInstall` environment variable, falls back to `'C:\ProgramData\chocolatey'`.

##### `use_7zip`

Whether to use built-in shell or allow installer to download 7zip to extract `chocolatey.nupkg` during installation. Defaults to `true`.

##### `choco_install_timeout_seconds`

How long in seconds should be allowed for the install of Chocolatey (including .NET Framework 4 if necessary). Defaults to `1500` (25 minutes).

##### `chocolatey_download_url`

A url that will return `chocolatey.nupkg`. This must be a url, but not necessarily an OData feed. Any old url location will work. Defaults to `'https://chocolatey.org/api/v2/package/chocolatey/'`.

##### `enable_autouninstaller`

Should auto uninstaller be turned on? Auto uninstaller is what allows Chocolatey to automatically manage the uninstall of software from Programs and Features without necessarily requiring a `chocolateyUninstall.ps1` file in the package. Defaults to `true`.

##### `log_output`

Log output from the installer. Defaults to `false`.

## Limitations

1. Works with Windows only.
2. If you override an existing install location of Chocolatey using `choco_install_location =>` in the Chocolatey class, it does not bring any of the existing packages with it. You will need to handle that through some other means.

### Known Issues

1. This module doesn't support side by side scenarios. This is ticketed as [#74](https://github.com/chocolatey/puppet-chocolatey/issues/74).
2. This module may have issues upgrading Chocolatey itself using the package resource. See [#65](https://github.com/chocolatey/puppet-chocolatey/issues/65) and [#60](https://github.com/chocolatey/puppet-chocolatey/issues/60)
3. Other known issues/enhancements can be found on the [issues list](https://github.com/chocolatey/puppet-chocolatey/issues).
4. If .NET 4.0 is not installed, it may have trouble installing Chocolatey. Choco version 0.9.9.9+ help alleviate this issue.
5. If there is an error in the installer (`InstallChocolatey.ps1.erb`), it may not show as an error. This may be an issue with the PowerShell provider and is still under investigation.

## Development

See [CONTRIBUTING.md](https://github.com/chocolatey/puppet-chocolatey/blob/master/CONTRIBUTING.md)

## Attributions

A special thanks goes out to [Rich Siegel](https://github.com/rismoney) who wrote the original
provider and continues to contribute to the development of this provider.
