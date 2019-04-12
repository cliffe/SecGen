# puppet-filebeat

[![Build Status](https://travis-ci.org/pcfens/puppet-filebeat.svg?branch=master)](https://travis-ci.org/pcfens/puppet-filebeat)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with filebeat](#setup)
    - [What filebeat affects](#what-filebeat-affects)
    - [Setup requirements](#setup-requirements)
    - [Beginning with filebeat](#beginning-with-filebeat)
3. [Usage - Configuration options and additional functionality](#usage)
    - [Adding a prospector](#adding-a-prospector)
      - [Multiline Logs](#multiline-logs)
      - [JSON logs](#json-logs)
    - [Prospectors in hiera](#prospectors-in-hiera)
    - [Usage on Windows](#usage-on-windows)
    - [Processors](#processors)
4. [Reference](#reference)
    - [Public Classes](#public-classes)
    - [Private Classes](#private-classes)
    - [Public Defines](#public-defines)
5. [Limitations - OS compatibility, etc.](#limitations)
    - [Pre-1.9.1 Ruby](#pre-191-ruby)
    - [Using config_file](#using-config_file)
6. [Development - Guide for contributing to the module](#development)

## Description

The `filebeat` module installs and configures the [filebeat log shipper](https://www.elastic.co/products/beats/filebeat) maintained by elastic.

## Setup

### What filebeat affects

By default `filebeat` adds a software repository to your system, and installs filebeat along
with required configurations.

### Upgrading to Filebeat 6.x

To upgrade to Filebeat 6.x, simply set `$filebeat::major_version` to `6` and `$filebeat::package_ensure` to `latest` (or whichever version of 6.x you want, just not present).


### Setup Requirements

The `filebeat` module depends on [`puppetlabs/stdlib`](https://forge.puppetlabs.com/puppetlabs/stdlib), and on
[`puppetlabs/apt`](https://forge.puppetlabs.com/puppetlabs/apt) on Debian based systems.

### Beginning with filebeat

`filebeat` can be installed with `puppet module install pcfens-filebeat` (or with r10k, librarian-puppet, etc.)

The only required parameter, other than which files to ship, is the `outputs` parameter.

## Usage

All of the default values in filebeat follow the upstream defaults (at the time of writing).

To ship files to [elasticsearch](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-configuration-details.html#elasticsearch-output):
```puppet
class { 'filebeat':
  outputs => {
    'elasticsearch' => {
     'hosts' => [
       'http://localhost:9200',
       'http://anotherserver:9200'
     ],
     'loadbalance' => true,
     'index'       => 'packetbeat',
     'cas'         => [
        '/etc/pki/root/ca.pem',
     ],
    },
  },
}

```

To ship log files through [logstash](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-configuration-details.html#logstash-output):
```puppet
class { 'filebeat':
  outputs => {
    'logstash'     => {
     'hosts' => [
       'localhost:5044',
       'anotherserver:5044'
     ],
     'loadbalance' => true,
    },
  },
}

```

[Shipper](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-configuration-details.html#configuration-shipper) and
[logging](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-configuration-details.html#configuration-logging) options
can be configured the same way, and are documented on the [elastic website](https://www.elastic.co/guide/en/beats/filebeat/current/index.html).

### Adding a prospector

Prospectors are processes that ship log files to elasticsearch or logstash. They can
be defined as a hash added to the class declaration (also used for automatically creating
prospectors using hiera), or as their own defined resources.

At a minimum, the `paths` parameter must be set to an array of files or blobs that should
be shipped. `doc_type` is what logstash views as the type parameter if you'd like to
apply conditional filters.

```puppet
filebeat::prospector { 'syslogs':
  paths    => [
    '/var/log/auth.log',
    '/var/log/syslog',
  ],
  doc_type => 'syslog-beat',
}
```

#### Multiline Logs

Filebeat prospectors can handle multiline log entries. The `multiline`
parameter accepts a hash containing `pattern`, `negate`, `match`, `max_lines`, and `timeout`
as documented in the filebeat [configuration documentation](https://www.elastic.co/guide/en/beats/filebeat/current/multiline-examples.html).

#### JSON Logs

Filebeat prospectors (versions >= 5.0) can natively decode JSON objects if they are stored one per line. The `json`
parameter accepts a hash containing `message_key`, `keys_under_root`, `overwrite_keys`, and `add_error_key`
as documented in the filebeat [configuration documentation](https://www.elastic.co/guide/en/beats/filebeat/5.5/configuration-filebeat-options.html#config-json).

### Prospectors in Hiera

Prospectors can be defined in hiera using the `prospectors` parameter. By default, hiera will not merge
prospector declarations down the hiera hierarchy. That behavior can be changed by configuring the
[lookup_options](https://docs.puppet.com/puppet/latest/reference/lookup_quick.html#setting-lookupoptions-in-data)
flag.

### Usage on Windows

When installing on Windows, this module will download the windows version of Filebeat from
[elastic](https://www.elastic.co/downloads/beats/filebeat) to `C:\Temp` by default. The directory
can be overridden using the `tmp_dir` parameter. `tmp_dir` is not managed by this module,
but is expected to exist as a directory that puppet can write to.

### Processors

Filebeat 5.0 and greater includes a new libbeat feature for filtering and/or enhancing all
exported data through processors before being sent to the configured output(s). They can be
defined as a hash added to the class declaration (also used for automatically creating
processors using hiera), or as their own defined resources.

To drop the offset and input_type fields from all events:

```puppet
class{"filebeat":
  processors => {
    "drop_fields" => {
      "params" => {"fields" => ["input_type", "offset"]}
    },
  },
}
```

To drop all events that have the http response code equal to 200:

```puppet
class{"filebeat":
  processors => {
    "drop_event" => {
      "when" => {"equals" => {"http.code" => 200}}
    },
  },
}
```

Now to combine these examples into a single definition:

```puppet
class{"filebeat":
  processors => {
    "drop_fields" => {
      "params"   => {"fields" => ["input_type", "offset"]},
      "priority" => 1,
    },
    "drop_event" => {
      "when"     => {"equals" => {"http.code" => 200}},
      "priority: => 2,
    },
  },
}
```

For more information please review the documentation [here](https://www.elastic.co/guide/en/beats/filebeat/5.1/configuration-processors.html).

#### Processors in Hiera

Processors can be declared in hiera using the `processors` parameter. By default, hiera will not merge
processor declarations down the hiera hierarchy. That behavior can be changed by configuring the
[lookup_options](https://docs.puppet.com/puppet/latest/reference/lookup_quick.html#setting-lookupoptions-in-data)
flag.

## Reference
 - [**Public Classes**](#public-classes)
    - [Class: filebeat](#class-filebeat)
 - [**Private Classes**](#private-classes)
    - [Class: filebeat::config](#class-filebeatconfig)
    - [Class: filebeat::install](#class-filebeatinstall)
    - [Class: filebeat::params](#class-filebeatparams)
    - [Class: filebeat::repo](#class-filebeatrepo)
    - [Class: filebeat::service](#class-filebeatservice)
    - [Class: filebeat::install::linux](#class-filebeatinstalllinux)
    - [Class: filebeat::install::windows](#class-filebeatinstallwindows)
 - [**Public Defines**](#public-defines)
    - [Define: filebeat::prospector](#define-filebeatprospector)
    - [Define: filebeat::processors](#define-filebeatprocessor)

### Public Classes

#### Class: `filebeat`

Installs and configures filebeat.

**Parameters within `filebeat`**
- `package_ensure`: [String] The ensure parameter for the filebeat package If set to absent,
  prospectors and processors passed as parameters are ignored and everything managed by
  puppet will be removed. (default: present)
- `manage_repo`: [Boolean] Whether or not the upstream (elastic) repo should be configured or not (default: true)
- `major_version`: [Enum] The major version of Filebeat to install. Should be either `5` or `6`. The default value is `5`.
- `service_ensure`: [String] The ensure parameter on the filebeat service (default: running)
- `service_enable`: [String] The enable parameter on the filebeat service (default: true)
- `param repo_priority`: [Integer] Repository priority.  yum and apt supported (default: undef)
- `service_provider`: [String] The provider parameter on the filebeat service (default: on RedHat based systems use redhat, otherwise undefined)
- `spool_size`: [Integer] How large the spool should grow before being flushed to the network (default: 2048)
- `idle_timeout`: [String] How often the spooler should be flushed even if spool size isn't reached (default: 5s)
- `publish_async`: [Boolean] If set to true filebeat will publish while preparing the next batch of lines to transmit (defualt: false)
- `registry_file`: [String] The registry file used to store positions, must be an absolute path (default is OS dependent - see params.pp)
- `config_file`: [String] Where the configuration file managed by this module should be placed. If you think
  you might want to use this, read the [limitations](#using-config_file) first. Defaults to the location
  that filebeat expects for your operating system.
- `config_dir`: [String] The directory where prospectors should be defined (default: /etc/filebeat/conf.d)
- `config_dir_mode`: [String] The permissions mode set on the configuration directory (default: 0755)
- `config_dir_owner`: [String] The owner of the configuration directory (default: root). Linux only.
- `config_dir_group`: [String] The group of the configuration directory (default: root). Linux only.
- `config_file_mode`: [String] The permissions mode set on configuration files (default: 0644)
- `config_file_owner`: [String] The owner of the configuration files, including prospectors (default: root). Linux only.
- `config_file_group`: [String] The group of the configuration files, including prospectors (default: root). Linux only.
- `purge_conf_dir`: [Boolean] Should files in the prospector configuration directory not managed by puppet be automatically purged
- `outputs`: [Hash] Will be converted to YAML for the required outputs section of the configuration (see documentation, and above)
- `shipper`: [Hash] Will be converted to YAML to create the optional shipper section of the filebeat config (see documentation)
- `logging`: [Hash] Will be converted to YAML to create the optional logging section of the filebeat config (see documentation)
- `modules`: [Array] Will be converted to YAML to create the optional modules section of the filebeat config (see documentation)
- `conf_template`: [String] The configuration template to use to generate the main filebeat.yml config file.
- `download_url`: [String] The URL of the zip file that should be downloaded to install filebeat (windows only)
- `install_dir`: [String] Where filebeat should be installed (windows only)
- `tmp_dir`: [String] Where filebeat should be temporarily downloaded to so it can be installed (windows only)
- `shutdown_timeout`: [String] How long filebeat waits on shutdown for the publisher to finish sending events
- `beat_name`: [String] The name of the beat shipper (default: hostname)
- `tags`: [Array] A list of tags that will be included with each published transaction
- `queue_size`: [String] The internal queue size for events in the pipeline
- `max_procs`: [Number] The maximum number of CPUs that can be simultaneously used
- `fields`: [Hash] Optional fields that should be added to each event output
- `fields_under_root`: [Boolean] If set to true, custom fields are stored in the top level instead of under fields
- `disable_config_test`: [Boolean] If set to true, configuration tests won't be run on config files before writing them.
- `processors`: [Hash] Processors that should be configured.
- `prospectors`: [Hash] Prospectors that will be created. Commonly used to create prospectors using hiera
- `setup`: [Hash] Setup that will be created. Commonly used to create setup using hiera
- `xpack`: [Hash] XPack configuration to pass to filebeat

### Private Classes

#### Class: `filebeat::config`

Creates the configuration files required for filebeat (but not the prospectors)

#### Class: `filebeat::install`

Calls the correct installer class based on the kernel fact.

#### Class: `filebeat::params`

Sets default parameters for `filebeat` based on the OS and other facts.

#### Class: `filebeat::repo`

Installs the yum or apt repository for the system package manager to install filebeat.

#### Class: `filebeat::service`

Configures and manages the filebeat service.

#### Class: `filebeat::install::linux`

Install the filebeat package on Linux kernels.

#### Class: `filebeat::install::windows`

Downloads, extracts, and installs the filebeat zip file in Windows.

### Public Defines

#### Define: `filebeat::prospector`

Installs a configuration file for a prospector.

Be sure to read the [filebeat configuration details](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-configuration-details.html)
to fully understand what these parameters do.

**Parameters for `filebeat::prospector`**
  - `ensure`: The ensure parameter on the prospector configuration file. (default: present)
  - `paths`: [Array] The paths, or blobs that should be handled by the prospector. (required)
  - `exclude_files`: [Array] Files that match any regex in the list are excluded from filebeat (default: [])
  - `encoding`: [String] The file encoding. (default: plain)
  - `input_type`: [String] log or stdin - where filebeat reads the log from (default:log)
  - `fields`: [Hash] Optional fields to add information to the output (default: {})
  - `fields_under_root`: [Boolean] Should the `fields` parameter fields be stored at the top level of indexed documents.
  - `ignore_older`: [String] Files older than this field will be ignored by filebeat (default: ignore nothing)
  - `close_older`: [String] Files that haven't been modified since `close_older`, they'll be closed. New
  modifications will be read when files are scanned again according to `scan_frequency`. (default: 1h)
  - `log_type`: [String] \(Deprecated - use `doc_type`\) The document_type setting (optional - default: log)
  - `doc_type`: [String] The event type to used for published lines, used as type field in logstash
    and elasticsearch (optional - default: log)
  - `scan_frequency`: [String] How often should the prospector check for new files (default: 10s)
  - `harvester_buffer_size`: [Integer] The buffer size the harvester uses when fetching the file (default: 16384)
  - `tail_files`: [Boolean] If true, filebeat starts reading new files at the end instead of the beginning (default: false)
  - `backoff`: [String] How long filebeat should wait between scanning a file after reaching EOF (default: 1s)
  - `max_backoff`: [String] The maximum wait time to scan a file for new lines to ship (default: 10s)
  - `backoff_factor`: [Integer] `backoff` is multiplied by this parameter until `max_backoff` is reached to
    determine the actual backoff (default: 2)
  - `force_close_files`: [Boolean] Should filebeat forcibly close a file when renamed (default: false)
  - `pipeline`: [String] Filebeat can be configured for a different ingest pipeline for each prospector (default: undef)
  - `include_lines`: [Array] A list of regular expressions to match the lines that you want to include.
    Ignored if empty (default: [])
  - `exclude_lines`: [Array] A list of regular expressions to match the files that you want to exclude.
    Ignored if empty (default: [])
  - `max_bytes`: [Integer] The maximum number of bytes that a single log message can have (default: 10485760)
  - `json`: [Hash] Options that control how filebeat handles decoding of log messages in JSON format
    [See above](#json-logs). (default: {})
  - `multiline`: [Hash] Options that control how Filebeat handles log messages that span multiple lines.
    [See above](#multiline-logs). (default: {})

## Limitations
This module doesn't load the [elasticsearch index template](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html#filebeat-template) into elasticsearch (required when shipping
directly to elasticsearch).

When installing on Windows, there's an expectation that `C:\Temp` already exists, or an alternative
location specified in the `tmp_dir` parameter exists and is writable by puppet. The temp directory
is used to store the downloaded installer only.

### Generic template

By default, a generic, open ended template is used that simply converts your configuration into
a hash that is produced as YAML on the system. To use a template that is more strict, but possibly
incomplete, set `conf_template` to `filebeat/filebeat.yml.erb`.

### Registry Path

The default registry file in this module doesn't match the filebeat default, but moving the file
while the filbeat service is running can cause data duplication or data loss. If you're installing
filebeat for the first time you should consider setting `registry_file` to match the
[default](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-global-options.html#_registry_file).

Be sure to include a path or the file will be put at the root of your filesystem.

### Debian Systems

Filebeat 5.x and newer requires apt-transport-https, but this module won't install it for you.

### Using config_file
There are a few very specific use cases where you don't want this module to directly manage the filebeat
configuration file, but you still want the configuration file on the system at a different location.
Setting `config_file` will write the filebeat configuration file to an alternate location, but it will not
update the init script. If you don't also manage the correct file (/etc/filebeat/filebeat.yml on Linux,
C:/Program Files/Filebeat/filebeat.yml on Windows) then filebeat won't be able to start.

If you're copying the alternate config file location into the real location you'll need to include some
metaparameters like
```puppet
file { '/etc/filebeat/filebeat.yml':
  ensure  => file,
  source  => 'file:///etc/filebeat/filebeat.special',
  require => File['filebeat.yml'],
  notify  => Service['filebeat'],
}
```
to ensure that services are managed like you might expect.

## Development

Pull requests and bug reports are welcome. If you're sending a pull request, please consider
writing tests if applicable.
