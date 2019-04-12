# puppet-python [![Build Status](https://travis-ci.org/stankevich/puppet-python.svg?branch=master)](https://travis-ci.org/stankevich/puppet-python)

Puppet module for installing and managing python, pip, virtualenvs and Gunicorn virtual hosts.

===

# Compatibility #

See `.travis.yml` for compatibility matrix.

* Puppet v3 (with the future parser)
* Puppet v4

## Ruby versions

* 1.8.7 - Puppet 3
* 1.9.3 - Puppet 3
* 2.0.0 - Puppet 3
* 2.1.9 - Puppet 3 & 4

## OS Distributions ##

This module has been tested to work on the following systems.

* Debian 6
* Debian 7
* Debian 8
* Debian 9
* EL 5
* EL 6
* EL 7
* Gentoo (and Sabayon)
* Suse 11
* Ubuntu 10.04
* Ubuntu 12.04
* Ubuntu 14.04
* Ubuntu 16.04

===

## Installation

```shell
git submodule add https://github.com/stankevich/puppet-python.git /path/to/python
```
OR

``` shell
puppet module install stankevich-python
```

## Usage

### python

Installs and manages python, python-pip, python-dev, python-virtualenv and Gunicorn.

**ensure** - Desired installation state for the Python package. Options are absent, present and latest. Default: present

**version** - Python version to install. Default: system

**pip** - Desired installation state for the python-pip package. Options are absent, present and latest. Default: present

**dev** - Desired installation state for the python-dev package. Options are absent, present and latest. Default: absent

**virtualenv** - Desired installation state for the virtualenv package. Options are absent, present and latest. Default: absent

**gunicorn** - Desired installation state for Gunicorn. Options are absent, present and latest. Default: absent

**manage_gunicorn** - Allow Installation / Removal of Gunicorn. Default: true

**use_epel** - Boolean to determine if the epel class is used. Default: true on RHEL like systems, false otherwise

```puppet
  class { 'python' :
    version    => 'system',
    pip        => 'present',
    dev        => 'absent',
    virtualenv => 'absent',
    gunicorn   => 'absent',
  }
```

### python::pip

Installs and manages packages from pip.

**pkgname** - the name of the package to install. Required.

**ensure** - present/latest/absent. You can also specify the version. Default: present

**virtualenv** - virtualenv to run pip in. Default: system (no virtualenv)

**url** - URL to install from. Default: none

**owner** - The owner of the virtualenv to ensure that packages are installed with the correct permissions (must be specified). Default: root

**proxy** - Proxy server to use for outbound connections. Default: none

**environment** - Additional environment variables required to install the packages. Default: none

**egg** - The egg name to use. Default: `$name` of the class, e.g. cx_Oracle

**install_args** - String of additional flags to pass to pip during installaton. Default: none

**uninstall_args** - String of additional flags to pass to pip during uninstall. Default: none

**timeout** - Timeout for the pip install command. Defaults to 1800.
```puppet
  python::pip { 'cx_Oracle' :
    pkgname       => 'cx_Oracle',
    ensure        => '5.1.2',
    virtualenv    => '/var/www/project1',
    owner         => 'appuser',
    proxy         => 'http://proxy.domain.com:3128',
    environment   => 'ORACLE_HOME=/usr/lib/oracle/11.2/client64',
    install_args  => '-e',
    timeout       => 1800,
   }
```

### python::requirements

Installs and manages Python packages from requirements file.

**virtualenv** - virtualenv to run pip in. Default: system-wide

**proxy** - Proxy server to use for outbound connections. Default: none

**owner** - The owner of the virtualenv to ensure that packages are installed with the correct permissions (must be specified). Default: root

**src** - The `--src` parameter to `pip`, used to specify where to install `--editable` resources; by default no `--src` parameter is passed to `pip`.

**group** - The group that was used to create the virtualenv.  This is used to create the requirements file with correct permissions if it's not present already.

**manage_requirements** - Create the requirements file if it doesn't exist. Default: true

```puppet
  python::requirements { '/var/www/project1/requirements.txt' :
    virtualenv => '/var/www/project1',
    proxy      => 'http://proxy.domain.com:3128',
    owner      => 'appuser',
    group      => 'apps',
  }
```

### python::virtualenv

Creates Python virtualenv.

**ensure** - present/absent. Default: present

**version** - Python version to use. Default: system default

**requirements** - Path to pip requirements.txt file. Default: none

**proxy** - Proxy server to use for outbound connections. Default: none

**systempkgs** - Copy system site-packages into virtualenv. Default: don't

**distribute** - Include distribute in the virtualenv. Default: true

**venv_dir** - The location of the virtualenv if resource path not specified. Must be absolute path. Default: resource name

**owner** - Specify the owner of this virtualenv

**group** - Specify the group for this virtualenv

**index** - Base URL of Python package index. Default: none

**cwd** - The directory from which to run the "pip install" command. Default: undef

**timeout** - The maximum time in seconds the "pip install" command should take. Default: 1800

```puppet
  python::virtualenv { '/var/www/project1' :
    ensure       => present,
    version      => 'system',
    requirements => '/var/www/project1/requirements.txt',
    proxy        => 'http://proxy.domain.com:3128',
    systempkgs   => true,
    distribute   => false,
    venv_dir     => '/home/appuser/virtualenvs',
    owner        => 'appuser',
    group        => 'apps',
    cwd          => '/var/www/project1',
    timeout      => 0,
  }
```

### python::pyvenv

Creates Python3 virtualenv.

**ensure** - present/absent. Default: present

**version** - Python version to use. Default: system default

**systempkgs** - Copy system site-packages into virtualenv. Default: don't

**venv_dir** - The location of the virtualenv if resource path not specified. Must be absolute path. Default: resource name

**owner** - Specify the owner of this virtualenv

**group** - Specify the group for this virtualenv

**path** - Specifies the PATH variable that contains `pyvenv` executable. Default: [ '/bin', '/usr/bin', '/usr/sbin' ]

**environment** - Specify any environment variables to use when creating pyvenv

```puppet
  python::pyvenv { '/var/www/project1' :
    ensure       => present,
    version      => 'system',
    systempkgs   => true,
    venv_dir     => '/home/appuser/virtualenvs',
    owner        => 'appuser',
    group        => 'apps',
  }
```

### python::gunicorn

Manages Gunicorn virtual hosts.

**ensure** - present/absent. Default: present

**virtualenv** - Run in virtualenv, specify directory. Default: disabled

**mode** - Gunicorn mode. wsgi/django. Default: wsgi

**dir** - Application directory.

**bind** - Bind on: 'HOST', 'HOST:PORT', 'unix:PATH'. Default: `unix:/tmp/gunicorn-$name.socket` or `unix:${virtualenv}/${name}.socket`

**environment** - Set ENVIRONMENT variable. Default: none

**appmodule** - Set the application module name for gunicorn to load when not using Django. Default: `app:app`

**osenv** - Allows setting environment variables for the gunicorn service. Accepts a hash of 'key': 'value' pairs. Default: false

**timeout** - Allows setting the gunicorn idle worker process time before being killed. The unit of time is seconds. Default: 30

**template** - Which ERB template to use. Default: python/gunicorn.erb

```puppet
  python::gunicorn { 'vhost' :
    ensure      => present,
    virtualenv  => '/var/www/project1',
    mode        => 'wsgi',
    dir         => '/var/www/project1/current',
    bind        => 'unix:/tmp/gunicorn.socket',
    environment => 'prod',
    appmodule   => 'app:app',
    osenv       => { 'DBHOST' => 'dbserver.example.com' },
    timeout     => 30,
    template    => 'python/gunicorn.erb',
  }
```

### python::dotfile

Manages arbitrary python dotiles with a simple config hash.

**ensure** - present/absent. Default: present

**filename** - Default: $title

**mode** - Default: 0644

**owner** - Default: root

**group** - Default: root

**config** Config hash. This will be expanded to an ini-file. Default: {}

```puppet
python::dotfile { '/var/lib/jenkins/.pip/pip.conf':
  ensure => present,
  owner  => 'jenkins',
  group  => 'jenkins',
  config => {
    'global' => {
      'index-url       => 'https://mypypi.acme.com/simple/'
      'extra-index-url => https://pypi.risedev.at/simple/
    }
  }
}
```

### hiera configuration

This module supports configuration through hiera. The following example
creates two python3 virtualenvs. The configuration also pip installs a
package into each environment.

```yaml
python::python_pyvenvs:
  "/opt/env1":
    version: "system"
  "/opt/env2":
    version: "system"
python::python_pips:
  "nose":
    virtualenv: "/opt/env1"
  "coverage":
    virtualenv: "/opt/env2"
python::python_dotfiles:
  "/var/lib/jenkins/.pip/pip.conf":
    config:
      global:
        index-url: "https://mypypi.acme.com/simple/"
        extra-index-url: "https://pypi.risedev.at/simple/"
```

### Using SCL packages from RedHat or CentOS

To use this module with Linux distributions in the Red Hat family and python distributions
from softwarecollections.org, set python::provider to 'rhscl' and python::version to the name 
of the collection you want to use (e.g., 'python27', 'python33', or 'rh-python34').

## Release Notes

**Version 1.9.8 Notes**
The `pip`, `virtualenv` and `gunicorn` parameters of `Class['python']` have changed. These parameters now accept `absent`, `present` and `latest` rather than `true` and `false`. The boolean values are still supported and are equivalent to `present` and `absent` respectively. Support for these boolean parameters is deprecated and will be removed in a later release.

**Version 1.7.10 Notes**

Installation of python-pip previously defaulted to `false` and was not installed. This default is now `true` and python-pip is installed. To prevent the installation of python-pip specify `pip => false` as a parameter when instantiating the `python` puppet class.

**Version 1.1.x Notes**

Version `1.1.x` makes several fundamental changes to the core of this module, adding some additional features, improving performance and making operations more robust in general.

Please note that several changes have been made in `v1.1.x` which make manifests incompatible with the previous version.  However, modifying your manifests to suit is trivial.  Please see the notes below.

Currently, the changes you need to make are as follows:

* All pip definitions MUST include the owner field which specifies which user owns the virtualenv that packages will be installed in.  Adding this greatly improves performance and efficiency of this module.
* You must explicitly specify pip => true in the python class if you want pip installed.  As such, the pip package is now independent of the dev package and so one can exist without the other.

## Authors

[Sergey Stankevich](https://github.com/stankevich) | [Shiva Poudel](https://github.com/shivapoudel) | [Peter Souter](https://github.com/petems) | [Garrett Honeycutt](http://learnpuppet.com)
