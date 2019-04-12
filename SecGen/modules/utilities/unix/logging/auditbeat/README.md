# auditbeat


#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with auditbeat](#setup)
    * [What auditbeat affects](#what-auditbeat-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with auditbeat](#beginning-with-auditbeat)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module installs and configures the [Auditbeat shipper](https://www.elastic.co/guide/en/beats/auditbeat/current/auditbeat-overview.html) by Elastic. It has been tested on Puppet 5.x and on the following OSes: Debian 9.1, CentOS 7.3, Ubuntu 16.04

## Setup

### What auditbeat affects

`auditbeat` configures the package repository to fetch the software, it installs it, it configures both the application (`/etc/auditbeat/auditbeat.yml`) and the service (`systemd` by default, but it is possible to manually switch to `init`) and it takes care that it is running and enabled.

### Setup Requirements

`auditbeat` needs `puppetlabs/stdlib`, `puppetlabs/apt` (for Debian and derivatives), `puppet/yum` (for RedHat or RedHat-like systems), `darin-zypprepo` (on SuSE based system)

### Beginning with auditbeat

The module can be installed manually, typing `puppet module install noris-auditbeat`, or by means of an environment manager (r10k, librarian-puppet, ...).

`auditbeat` requires at least the `outputs` and `modules` sections in order to start. Please refer to the software documentation to find out the [available modules] (https://www.elastic.co/guide/en/beats/auditbeat/current/auditbeat-modules.html) and the [supported outputs] (https://www.elastic.co/guide/en/beats/auditbeat/current/configuring-output.html). On the other hand, the sections [logging] (https://www.elastic.co/guide/en/beats/auditbeat/current/configuration-logging.html) and [queue] (https://www.elastic.co/guide/en/beats/auditbeat/current/configuring-internal-queue.html) already contains meaningful default values.

A basic setup configuring the `file_integrity` module to check some paths and writing the results directly in Elasticsearch.

```puppet
class{'auditbeat':
    modules => [
      {
        'module' => 'file_integrity',
        'enabled' => true,
        'paths' => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/etc'],
      },
    ],
    outputs => {
      'elasticsearch' => {
        'hosts' => ['http://localhost:9200'],
        'index' => 'auditbeat-%{+YYYY.MM.dd}',
      },
    },
```

The same example using Hiera:

```
classes:
  include:
    - 'auditbeat'

auditbeat::modules:
  - module: 'file_integrity'
    enabled: true
    paths:
      - '/bin'
      - '/usr/bin'
      - '/sbin'
      - '/usr/sbin'
      - '/etc'

auditbeat::outputs:
  elasticsearch:
    hosts:
      - 'http://localhost:9200'
    index: "auditbeat-%%{}{+YYYY.MM.dd}"
```

## Usage

The configuration is written to the configuration file `/etc/auditbeat/auditbeat.yml` in yaml format. The default values follow the upstream (as of the time of writing).

Send data to two Redis servers, loadbalancing between the instances.

```puppet
class{'auditbeat':
    modules => [
      {
        'module' => 'file_integrity',
        'enabled' => true,
        'paths' => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/etc'],
      },
    ],
    outputs => {
      'redis' => {
        'hosts' => ['localhost:6379', 'other_redis:6379'],
        'key' => 'auditbeat',
      },
    },
```
or, using Hiera

```
classes:
  include:
    - 'auditbeat'

auditbeat::modules:
  - module: 'file_integrity'
    enabled: true
    paths:
      - '/bin'
      - '/usr/bin'
      - '/sbin'
      - '/usr/sbin'
      - '/etc'

auditbeat::outputs:
  elasticsearch:
    hosts:
      - 'localhost:6379'
      - 'itger:redis:6379'
    index: 'auditbeat'
```
Add the `auditd` module to the configuration, specifying a rule to detect 32 bit system calls. Output to Elasticsearch.

```puppet
class{'auditbeat':
    modules => [
      {
        'module' => 'file_integrity',
        'enabled' => true,
        'paths' => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/etc'],
      },
      {
        'module' => 'auditd',
        'enabled' => true,
        'audit_rules' => '-a always,exit -F arch=b32 -S all -F key=32bit-abi',
      },
    ],
    outputs => {
      'elasticsearch' => {
        'hosts' => ['http://localhost:9200'],
        'index' => 'auditbeat-%{+YYYY.MM.dd}',
      },
    },
```
In Hiera format it would look like:

```
classes:
  include:
    - 'auditbeat'

auditbeat::modules:
  - module: 'file_integrity'
    enabled: true
    paths:
      - '/bin'
      - '/usr/bin'
      - '/sbin'
      - '/usr/sbin'
      - '/etc'
  - module: 'auditd'
    enabled: true
    audit_rules: |
      -a always,exit -F arch=b32 -S all -F key=32bit-abi

auditbeat::outputs:
  elasticsearch:
    hosts:
      - 'http://localhost:9200'
    index: "auditbeat-%%{}{+YYYY.MM.dd}"
```


## Reference

* [Public Classes](#public-classes)
	* [Class: auditbeat](#class-auditbeat)
* [Private Classes](#private-classes)
	* [Class: auditbeat::repo](#class-auditbeat-repo)
	* [Class: auditbeat::install](#class-auditbeat-install)
	* [Class: auditbeat::config](#class-auditbeat-config)
	* [Class: auditbeat::service](#class-auditbeat-service)


### Public Classes

#### Class: `auditbeat`

Installation and configuration.

**Parameters**:

* `beat_name`: [String] the name of the shipper (default: the *hostname*).
* `fields_under_root`: [Boolean] whether to add the custom fields to the root of the document (default is *false*).
* `queue`: [Hash] auditbeat's internal queue, before the events publication (default is *4096* events in *memory* with immediate flush).
* `logging`: [Hash] the auditbeat's logfile configuration (default: writes to `/var/log/auditbeat/auditbeat`, maximum 7 files, rotated when bigger than 10 MB).
* `outputs`: [Hash] the options of the mandatory [outputs] (https://www.elastic.co/guide/en/beats/auditbeat/current/configuring-output.html) section of the configuration file (default: undef).
* `major_version`: [Enum] the major version of the package to install (default: '6', the only accepted value. Implemented for future reference).
* `ensure`: [Enum 'present', 'absent']: whether Puppet should manage `auditbeat` or not (default: 'present').
* `service_provider`: [Enum 'systemd', 'init', 'debian', 'redhat', 'upstart', undef] which boot framework to use to install and manage the service (default: undef).
* `service_ensure`: [Enum 'enabled', 'running', 'disabled', 'unmanaged'] the status of the audit service (default 'enabled'). In more details:
	* *enabled*: service is running and started at every boot;
	* *running*: service is running but not started at boot time;
	* *disabled*: service is not running and not started at boot time;
	* *unamanged*: Puppet does not manage the service.
* `package_ensure`: [String] the package version to install. It could be 'latest' (for the newest release) or a specific version number, in the format *x.y.z*, i.e., *6.2.0* (default: latest).
* `manage_repo`: [Boolean] whether to add the elastic upstream repo to the package manager (default: true).
* `config_file_mode`: [String] the octal file mode of the configuration file `/etc/auditbeat/auditbeat.yml` (default: 0644).
* `disable_configtest`: [Boolean] whether to check if the configuration file is valid before attempting to run the service (default: true).
* `tags`: [Array[Strings]]: the tags to add to each document (default: undef).
* `fields`: [Hash] the fields to add to each document (default: undef).
* `xpack`: [Hash] the configuration to export internal metrics to an Elasticsearch monitoring instance  (default: undef).
* `modules`: [Array[Hash]] the required [modules] (https://www.elastic.co/guide/en/beats/auditbeat/current/auditbeat-modules.html) to load (default: undef).
* `processors`: [Array[Hash]] the optional [processors] (https://www.elastic.co/guide/en/beats/auditbeat/current/defining-processors.html) for event enhancement (default: undef).

### Private Classes

#### Class: `auditbeat::repo`
Configuration of the package repository to fetch auditbeat.

#### Class: `auditbeat::install`
Installation of the auditbeat package.

#### Class: `auditbeat::config`
Configuration of the auditbeat daemon.

#### Class: `auditbeat::service`
Management of the auditbeat service.


## Limitations

This module does not load the index template in Elasticsearch nor the auditbeat example dashboards in Kibana. These two tasks should be carried out manually. Please follow the documentation to [manually load the index template in Elasticsearch] (https://www.elastic.co/guide/en/beats/auditbeat/current/auditbeat-template.html#load-template-manually-alternate) and to [import the auditbeat dashboards in Kibana] (https://www.elastic.co/guide/en/beats/devguide/6.2/import-dashboards.html).

The option `manage_repo` does not remove the repo file, even if set to *false*. Please delete it manually.

The module allows to set up the
[x-pack section] (https://www.elastic.co/guide/en/beats/auditbeat/current/monitoring.html)
of the configuration file, in order to set the internal statistics of packetbeat to an Elasticsearch cluster.
In order to do that the parameter `package_ensure` should be set to:

* `latest`
* `6.1.0` or a higher version

Unfortunately when `package_ensure` is equal to `installed` or `present`, the `x-pack` section is removed,
beacuse there is no way to know which version of the package is going to be handled (unless a specific fact is
added).


## Development

Please feel free to report bugs and to open pull requests for new features or to fix a problem.
