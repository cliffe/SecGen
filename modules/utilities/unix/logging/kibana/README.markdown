# Kibana Puppet Module

[![Puppet Forge Endorsed](https://img.shields.io/puppetforge/e/elastic/kibana.svg)](https://forge.puppetlabs.com/elastic/kibana)
[![Puppet Forge Version](https://img.shields.io/puppetforge/v/elastic/kibana.svg)](https://forge.puppetlabs.com/elastic/kibana)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/elastic/kibana.svg)](https://forge.puppetlabs.com/elastic/kibana)
[![Build Status](https://travis-ci.org/elastic/puppet-kibana.svg?branch=master)](https://travis-ci.org/elastic/puppet-kibana)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with Kibana](#setup)
    * [What Kibana affects](#what-kibana-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Kibana](#beginning-with-kibana)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module manages Kibana for use with Elasticsearch.

## Module Description

In addition to managing the Kibana system package and service, this module also
exposes options to control the configuration file for Kibana.
Kibana plugins are also supported via a native type and provider.

Dependencies are fairly standard (stdlib and apt for Debian-based
distributions).

## Setup

### What Kibana affects

* The `kibana` system package and service
* `/etc/kibana/kibana.yml`
* `/usr/share/kibana/plugins/*`

### Setup Requirements

In addition to basic puppet settings (such as pluginsync), ensure that the
required dependencies for the module are met (these are listed in
`metadata.json` and listed in the Puppet Forge). 

### Beginning with kibana

Quick start:

```puppet
class { 'kibana' : }
```

## Usage

In order to control Kibana's configuration file, use the `config` parameter:

```puppet
class { 'kibana':
  config => {
    'server.port' => '8080',
  }
}
```

The `kibana` class also supports additional values for the `ensure` parameter
that will be passed along to the `package` resource for Kibana.
For example, to ensure the latest version of Kibana is always installed:

```puppet
class { 'kibana': ensure => latest }
```

In order to explicitly ensure that version 5.2.0 of Kibana is installed:

```puppet
class { 'kibana': ensure => '5.2.0' }
```

Package revisions are supported too:

```puppet
class { 'kibana': ensure => '5.2.2-1' }
```

The `kibana` class also supports removal through use of `ensure => absent`:

```puppet
class { 'kibana': ensure => absent }
```

### OSS Packages and Repository Management

This module uses the [elastic/elastic_stack](https://forge.puppet.com/elastic/elastic_stack) module to manage the elastic package repositories.
In order to control which major version of package repository to manage, declare the associated repository version in the `elastic_stack::repo` class.
For example, to explicitly set the repository version to 5 instead of the default (which, at the time of this writing, is 6):

```puppet
class { 'elastic_stack::repo':
  version => 5,
}

class { 'kibana':
  ensure => latest
}
```

This module defaults to the upstream package repositories, which as of 6.3, includes X-Pack. In order to use the purely OSS (open source) package and repository, the appropriate `oss` flag must be set on the `elastic_stack::repo` and `kibana` classes:

```puppet
class { 'elastic_stack::repo':
  oss => true,
}

class { 'kibana':
  oss => true,
}
```

### Plugins

Kibana plugins can be managed by this module.

#### Kibana 5.x & 6.x

In the most basic form, official plugins (provided by Elastic) can simply be
specified by name alone:

```puppet
kibana_plugin { 'x-pack': }
```

The type also supports installing third-party plugins from a remote URL:

```puppet
kibana_plugin { 'health_metric_vis':
  url => 'https://github.com/DeanF/health_metric_vis/releases/download/v0.3.4/health_metric_vis-5.2.0.zip',
}
```

When updating plugins, it is important to specify the version of the plugin
that should be installed.
For example, the preceding block of code installed version 0.3.4 of the
`health_metric_vis` plugin. In order to update that plugin to version 0.3.5,
you could use a resource such as the following:

```puppet
kibana_plugin { 'health_metric_vis':
  url => 'https://github.com/DeanF/health_metric_vis/releases/download/v0.3.5/health_metric_vis-5.2.0.zip',
  version => '0.3.5',
}
```

Plugins can also be removed:

```puppet
kibana_plugin { 'x-pack': ensure => absent }
```

#### Kibana 4.x

Plugin operations are similar to 6.x resources, but in keeping with the
`kibana` command-line utility, an organization and version _must_ be specified:

```puppet
kibana_plugin { 'marvel':
  version => '2.4.4',
  organization => 'elasticsearch',
}
```

The `version` and `organization` parameters correspond to the same values for a
given plugin in the plugin's documentation, and the provider assembles the
correct name on the backend on your behalf.
For instance, the previous example will be translated to

```shell
kibana plugin --install elasticsearch/marvel/2.4.4
```

For you.
Removal through the use of `ensure => absent` is the same as for 5.x plugins.

## Reference

Class parameters are available in [the auto-generated documentation
pages](https://elastic.github.io/puppet-kibana/puppet_classes/kibana.html).
Autogenerated documentation for types, providers, and ruby helpers is also
available on the same documentation site.

## Limitations

This module is actively tested against the versions and distributions listed in
`metadata.json`.

## Development

See CONTRIBUTING.md with help to get started.

### Quickstart

Install gem dependencies:

```shell
$ bundle install
```

Run the test suite (without acceptance tests):

```shell
$ bundle exec rake test
```

Run acceptance tests against a platform (requires Docker):

```shell
$ bundle exec rake beaker:centos-7-x64
```
