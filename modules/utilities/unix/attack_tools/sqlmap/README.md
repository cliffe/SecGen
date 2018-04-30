# sqlmap

#### Table of Contents

1. [Overview](#overview)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Install the [sqlmap](http://sqlmap.org/) SQL injection tool from its
[Github repo](https://github.com/sqlmapproject/sqlmap) into the system
path, ready for use.

## Usage

This is a simple module. In its most basic form, to accept defaults simply do:

```puppet
include sqlmap
```

For extra control, you can set these parameters.

* `installdir` is the path to clone the git repo on local filesystem
* `source` is the URL of the git repo that contains the sqlmap project
* `path` is the bin path where the script will be symlinked
* `revision` is the version of code to clone. Defaults to `HEAD` but you can specify a tag or commit. See
  [vsrepo docs](https://forge.puppetlabs.com/puppetlabs/vcsrepo#git) for full info

This example shows the default value of the parameters.

```puppet
class { 'sqlmap':
  installdir => '/usr/share/sqlmap',
  source     => 'https://github.com/sqlmapproject/sqlmap.git',
  path       => '/usr/local/bin',
  revision   => 'HEAD',
}
```

## Limitations

Should work on pretty much any Linux/Unix system that supports git. Obviously
it will need an internet connection to clone the repo (but you can fork the
sqlmap project in a local repo and set `$source` to point at that)

## Development

Pull requests welcome to add features or fix bugs.
