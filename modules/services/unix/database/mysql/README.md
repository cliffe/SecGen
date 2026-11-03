# mysql

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with mysql](#setup)
    * [Beginning with mysql](#beginning-with-mysql)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Customize server options](#customize-server-options)
    * [Create a database](#create-a-database)
    * [Customize configuration](#customize-configuration)
    * [Work with an existing server](#work-with-an-existing-server)
    * [Specify passwords](#specify-passwords)
    * [Install Percona server on CentOS](#install-percona-server-on-centos)
    * [Install MariaDB on Ubuntu](#install-mariadb-on-ubuntu)
    * [Install Plugins](#install-plugins)
4. [Reference - An under-the-hood peek at what the module is doing and how](REFERENCE.md)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module Description

The mysql module installs, configures, and manages the MySQL service.

This module manages both the installation and configuration of MySQL, as well as extending Puppet to allow management of MySQL resources, such as databases, users, and grants.

## Setup

### Beginning with mysql

To install a server with the default options:

`include '::mysql::server'`.

To customize options, such as the root password or `/etc/my.cnf` settings, you must also pass in an override hash:

```puppet
class { '::mysql::server':
  root_password           => 'strongpassword',
  remove_default_accounts => true,
  override_options        => $override_options
}
```

See [**Customize Server Options**](#customize-server-options) below for examples of the hash structure for $override_options.

## Usage

All interaction for the server is done via `mysql::server`. To install the client, use `mysql::client`. To install bindings, use `mysql::bindings`.

### Customize server options

To define server options, structure a hash structure of overrides in `mysql::server`. This hash resembles a hash in the my.cnf file:

```puppet
$override_options = {
  'section' => {
    'item' => 'thing',
  }
}
```

For options that you would traditionally represent in this format:

```
[section]
thing = X
```

Entries can be created as `thing => true`, `thing => value`, or `thing => ""` in the hash. Alternatively, you can pass an array as `thing => ['value', 'value2']` or list each `thing => value` separately on individual lines.

You can pass a variable in the hash without setting a value for it; the variable would then use MySQL's default settings. To exclude an option from the `my.cnf` file --- for example, when using `override_options` to revert to a default value --- pass `thing => undef`.

If an option needs multiple instances, pass an array. For example,

```puppet
$override_options = {
  'mysqld' => {
    'replicate-do-db' => ['base1', 'base2'],
  }
}
```

produces

```puppet
[mysqld]
replicate-do-db = base1
replicate-do-db = base2
```

To implement version specific parameters, specify the version, such as [mysqld-5.5]. This allows one config for different versions of MySQL.

### Create a database

To create a database with a user and some assigned privileges:

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
```

To use a different resource name with exported resources:

```puppet
 @@mysql::db { "mydb_${fqdn}":
  user     => 'myuser',
  password => 'mypass',
  dbname   => 'mydb',
  host     => ${fqdn},
  grant    => ['SELECT', 'UPDATE'],
  tag      => $domain,
}
```

Then you can collect it on the remote DB server:

```puppet
Mysql::Db <<| tag == $domain |>>
```

If you set the sql parameter to a file when creating a database, the file is imported into the new database.

For large sql files, increase the `import_timeout` parameter, which defaults to 300 seconds.

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
  sql      => '/path/to/sqlfile.gz',
  import_cat_cmd => 'zcat',
  import_timeout => 900,
}
```

### Customize configuration

To add custom MySQL configuration, place additional files into `includedir`. This allows you to override settings or add additional ones, which is helpful if you don't use `override_options` in `mysql::server`. The `includedir` location is by default set to `/etc/mysql/conf.d`.

### Work with an existing server

To instantiate databases and users on an existing MySQL server, you need a `.my.cnf` file in `root`'s home directory. This file must specify the remote server address and credentials. For example:

```puppet
[client]
user=root
host=localhost
password=secret
```

This module uses the `mysqld_version` fact to discover the server version being used.  By default, this is set to the output of `mysqld -V`.  If you're working with a remote MySQL server, you may need to set a custom fact for `mysqld_version` to ensure correct behaviour.

When working with a remote server, do *not* use the `mysql::server` class in your Puppet manifests.

### Specify passwords

In addition to passing passwords as plain text, you can input them as hashes. For example:

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
```

If required, the password can also be an empty string to allow connections without an password.

### Install Percona server on CentOS

This example shows how to do a minimal installation of a Percona server on a
CentOS system. This sets up the Percona server, client, and bindings (including Perl and Python bindings). You can customize this usage and update the version as needed.

This usage has been tested on Puppet 4.4 / CentOS 7 / Percona Server 5.7.

**Note:** The installation of the yum repository is not part of this package
and is here only to show a full example of how you can install.

```puppet
yumrepo { 'percona':
  descr    => 'CentOS $releasever - Percona',
  baseurl  => 'http://repo.percona.com/centos/$releasever/os/$basearch/',
  gpgkey   => 'http://www.percona.com/downloads/percona-release/RPM-GPG-KEY-percona',
  enabled  => 1,
  gpgcheck => 1,
}

class {'mysql::server':
  package_name     => 'Percona-Server-server-57',
  package_ensure   => '5.7.11-4.1.el7',
  service_name     => 'mysql',
  config_file      => '/etc/my.cnf',
  includedir       => '/etc/my.cnf.d',
  root_password    => 'PutYourOwnPwdHere',
  override_options => {
    mysqld => {
      log-error => '/var/log/mysqld.log',
      pid-file  => '/var/run/mysqld/mysqld.pid',
    },
    mysqld_safe => {
      log-error => '/var/log/mysqld.log',
    },
  }
}

# Note: Installing Percona-Server-server-57 also installs Percona-Server-client-57.
# This shows how to install the Percona MySQL client on its own
class {'mysql::client':
  package_name   => 'Percona-Server-client-57',
  package_ensure => '5.7.11-4.1.el7',
}

# These packages are normally installed along with Percona-Server-server-57
# If you needed to install the bindings, however, you could do so with this code
class { 'mysql::bindings':
  client_dev_package_name   => 'Percona-Server-shared-57',
  client_dev_package_ensure => '5.7.11-4.1.el7',
  client_dev                => true,
  daemon_dev_package_name   => 'Percona-Server-devel-57',
  daemon_dev_package_ensure => '5.7.11-4.1.el7',
  daemon_dev                => true,
  perl_enable               => true,
  perl_package_name         => 'perl-DBD-MySQL',
  python_enable             => true,
  python_package_name       => 'MySQL-python',
}

# Dependencies definition
Yumrepo['percona']->
Class['mysql::server']

Yumrepo['percona']->
Class['mysql::client']

Yumrepo['percona']->
Class['mysql::bindings']
```

### Install MariaDB on Ubuntu

#### Optional: Install the MariaDB official repo

In this example, we'll use the latest stable (currently 10.1) from the official MariaDB repository, not the one from the distro repository. You could instead use the package from the Ubuntu repository. Make sure you use the repository corresponding to the version you want.

**Note:** `sfo1.mirrors.digitalocean.com` is one of many mirrors available. You can use any official mirror.

```puppet
include apt

apt::source { 'mariadb':
  location => 'http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu',
  release  => $::lsbdistcodename,
  repos    => 'main',
  key      => {
    id     => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
    server => 'hkp://keyserver.ubuntu.com:80',
  },
  include => {
    src   => false,
    deb   => true,
  },
}
```

#### Install the MariaDB server

This example shows MariaDB server installation on Ubuntu Trusty. Adjust the version and the parameters of `my.cnf` as needed. All parameters of the `my.cnf` can be defined using the `override_options` parameter.

The folders `/var/log/mysql` and `/var/run/mysqld` are created automatically, but if you are using other custom folders, they should exist as prerequisites for this code.

All the values set here are an example of a working minimal configuration.

Specify the version of the package you want with the `package_ensure` parameter.

```puppet
class {'::mysql::server':
  package_name     => 'mariadb-server',
  package_ensure   => '10.1.14+maria-1~trusty',
  service_name     => 'mysql',
  root_password    => 'AVeryStrongPasswordUShouldEncrypt!',
  override_options => {
    mysqld => {
      'log-error' => '/var/log/mysql/mariadb.log',
      'pid-file'  => '/var/run/mysqld/mysqld.pid',
    },
    mysqld_safe => {
      'log-error' => '/var/log/mysql/mariadb.log',
    },
  }
}

# Dependency management. Only use that part if you are installing the repository
# as shown in the Preliminary step of this example.
Apt::Source['mariadb'] ~>
Class['apt::update'] ->
Class['::mysql::server']

```

#### Install the MariaDB client

This example shows how to install the MariaDB client and all of the bindings at once. You can do this installation separately from the server installation.

Specify the version of the package you want with the `package_ensure` parameter.

```puppet
class {'::mysql::client':
  package_name    => 'mariadb-client',
  package_ensure  => '10.1.14+maria-1~trusty',
  bindings_enable => true,
}

# Dependency management. Only use that part if you are installing the repository as shown in the Preliminary step of this example.
Apt::Source['mariadb'] ~>
Class['apt::update'] ->
Class['::mysql::client']
```

### Install MySQL Community server on CentOS

You can install MySQL Community Server on CentOS using the mysql module and Hiera. This example was tested with the following versions:

* MySQL Community Server 5.6
* Centos 7.3
* Puppet 3.8.7 using Hiera
* puppetlabs-mysql module v3.9.0

In Puppet:

```puppet
include ::mysql::server

create_resources(yumrepo, hiera('yumrepo', {}))

Yumrepo['repo.mysql.com'] -> Anchor['mysql::server::start']
Yumrepo['repo.mysql.com'] -> Package['mysql_client']

create_resources(mysql::db, hiera('mysql::server::db', {}))
```

In Hiera:

```yaml
---

# Centos 7.3
yumrepo:
  'repo.mysql.com':
    baseurl: "http://repo.mysql.com/yum/mysql-5.6-community/el/%{::operatingsystemmajrelease}/$basearch/"
    descr: 'repo.mysql.com'
    enabled: 1
    gpgcheck: true
    gpgkey: 'http://repo.mysql.com/RPM-GPG-KEY-mysql'

mysql::client::package_name: "mysql-community-client" # required for proper MySQL installation
mysql::server::package_name: "mysql-community-server" # required for proper MySQL installation
mysql::server::package_ensure: 'installed' # do not specify version here, unfortunately yum fails with error that package is already installed
mysql::server::root_password: "change_me_i_am_insecure"
mysql::server::manage_config_file: true
mysql::server::service_name: 'mysqld' # required for puppet module
mysql::server::override_options:
  'mysqld':
    'bind-address': '127.0.0.1'
    'log-error': '/var/log/mysqld.log' # required for proper MySQL installation
  'mysqld_safe':
    'log-error': '/var/log/mysqld.log'  # required for proper MySQL installation

# create database + account with access, passwords are not encrypted
mysql::server::db:
  "dev":
    user: "dev"
    password: "devpass"
    host: "127.0.0.1"
    grant:
      - "ALL"

```

### Install Plugins

Plugins can be installed by using the `mysql_plugin` defined type. See `examples/mysql_plugin.pp` for futher examples.

```puppet
class { 'mysql::server':
  root_password => 'password'
}

mysql_plugin { 'auth_pam':
  ensure => present,
  soname => 'auth_pam.so',
}

```

### Tasks

The MySQL module has an example task that allows a user to execute arbitary SQL against a database. Please refer to to the [PE documentation](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html) or [Bolt documentation](https://puppet.com/docs/bolt/latest/bolt.html) on how to execute a task.

## Limitations

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-tomcat/blob/master/metadata.json)

**Note:** The mysqlbackup.sh does not work and is not supported on MySQL 5.7 and greater.

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

Check out our the complete [module contribution guide](https://docs.puppetlabs.com/forge/contributing.html).

### Authors

This module is based on work by David Schmitt. The following contributors have contributed to this module (beyond Puppet Labs):

* Larry Ludwig
* Christian G. Warden
* Daniel Black
* Justin Ellison
* Lowe Schmidt
* Matthias Pigulla
* William Van Hevelingen
* Michael Arnold
* Chris Weyl
* Daniël van Eeden
* Jan-Otto Kröpke
* Timothy Sven Nelson
