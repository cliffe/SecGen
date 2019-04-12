# Ruby Module

This module manages Ruby and Rubygems.

# Compatibility
Puppet >= 4.7.0 with Ruby 2.1.9 and 2.4.1 on the following platforms.

  * Debian 6
  * Debian 7
  * EL 5
  * EL 6
  * EL 7
  * FreeBSD 10
  * SLES 11 SP1
  * Arch Linux


# Dependencies

* [PuppetLabs stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)

## Ruby Class

Installs and manages the core Ruby packages.

### Parameters

* *version*: (default installed) -
 Set the version of Ruby to install

* *latest_release*: (default undefined) -
 Set this to true and the Ruby module will install new releases if they are updated in the repositories, or if a new repository is added with a newer release. Note: In Debian and Ubuntu where Ruby version is specified by package name, this parameter will effectively install the latest release of the Ruby version specified with the `version` parameter.

* *gems_version*: (default installed) -
 Set the version of Rubygems to be installed

* *rubygems_update*: (default true) -
 If set to true, the module will ensure that the rubygems package is installed but will use rubygems-update (same as gem update --system but versionable) to update Rubygems to the version defined in $gems_version.  If set to false then the rubygems package resource will be versioned from $gems_version

* *ruby_package*: (default ruby, modified for distribution and Ruby version) -
 Set the package name for Ruby

* *rubygems_package*: (default rubygems) -
 Set the package name for rubygems

* *ruby_dev_packages*: (default undefined) This sets the list of development packages passed to `ruby::dev`.

* *suppress_warnings*: (default false) This suppresses warnings when a package is not expected to be available for a specific Ruby version for specific Ubuntu\Debian distributions and releases, but when a repository is provided that supplies the unnatural packages.

* *set_system_default*: (default false) This sets the system default ruby and gem binaries to that specified by the `version` parameter. Only supported in Debian and Ubuntu.

* *system_default_bin*: (default undefined) This sets a custom ruby binary used by the `set_system_default` parameter. To be used when a custom ruby package is supplied.

* *system_default_gem*: (default undefined) This sets a custom gem binary used by the `set_system_default` parameter. To be used when a custom ruby or rubygems package is supplied.

* *gem_integration*: (default false) Install the `rubygems_integration` package for Debian/Ubuntu that provides some integration between gems and distribution packages. Only supported in Debian and Ubuntu.

* *gem_integration_package*: (default false) Specifies a custom `rubygems-integration` package.

* *switch*: This parameter is depreciated, but continued for compatibility. Has the same function as `set_system_default`.

### Usage

For a standard install using the latest Rubygems provided by rubygems-update on
CentOS or Redhat use:
```puppet
    class { '::ruby':
      gems_version => 'latest',
    }
```

On Redhat this is equivilant to

    $ yum install ruby rubygems
    $ gem update --system

#### Specify Version

To install a specific version of ruby and rubygems but *not* use
rubygems-update use:
```puppet
    class { '::ruby':
      version         => '1.8.7',
      gems_version    => '1.8.24',
      rubygems_update => false,
    }
```

On Redhat this is equivilant to

    $ yum install ruby-1.8.7 rubygems-1.8.24

#### Alternative Ruby Packages

If you need to use different packages for either ruby or rubygems you
can. This could be for different versions or custom packages. For
instance the following installs ruby 1.9 on Ubuntu 12.04.
```puppet
    class { '::ruby':
      ruby_package     => 'ruby1.9.1-full',
      rubygems_package => 'rubygems1.9.1',
      gems_version     => 'latest',
    }
```
This parameter will be particularly important if an alternative package repository is defined with [`yumrepo`](http://docs.puppetlabs.com/references/latest/type.html#yumrepo) or [`apt::source` or `apt::ppa`](https://forge.puppetlabs.com/puppetlabs/apt).

## Ruby Development Class

The `ruby::dev` class requires the base `ruby` class.

Installs and manages the installation of the Ruby development packages and tools, including [Rake](http://docs.seattlerb.org/rake/) and [Bundler](http://bundler.io/). Note that the `ruby::dev` class may not install all the dependencies required to install some gems.

There is some selection logic in the `ruby::dev` class that attempts to install the correct development libraries and tools for the Ruby version installed by the base `ruby` class. Hence the `ruby::dev` class requires the `ruby` class.

This class often installs a list of packages, so setting a package version is not available as this may behave unpredictably.

### Parameters

* *ensure*: (default is 'installed') -
 This parameter sets the `ensure` parameter for all the Ruby development packages.
* *ruby_dev_packages*: (default is depends on OS distribution) -
 This parameter replaces the list of default Ruby development packages.
* *rake_ensure*: (default is 'installed') -
 This sets the `ensure` parameter of the rake package.
* *rake_package*: (default depends on OS distribution) -
 This parameter replaces the default rake package.
* *bundler_ensure*: (default is 'installed') -
 This sets the `ensure` parameter of the bundler package.
* *bundler_package*: (default is dependent on OS distribution) -
 This parameter replaces the default bundler package.
* *bundler_provider*: (default is dependent on OS distribution) -
 This parameter specifies what package provider should be used, only `gem` or `apt` are accepted.

## Rake Resource

The `ruby::rake` resource requires the `ruby::dev` class.

This resource runs [Rake](http://docs.seattlerb.org/rake/) tasks. This resource was created to be sure that Rake tasks would only be executed once their requirements were met by the `ruby::dev` class.

As running rake under bundle is a common scenario, the `bundle` parameter will automatically wrap a rake task as a `bundle exec rake` command. This ensures that the rake command passes through the sanity checking in the `ruby::rake` resource, and meets the dependency requirements needed for both rake and bundler tasks.

### Parameters

Most of the parameters for this resource are passed through to the underlying `exec` resource that runs the Rake task. Check the Puppetlabs documentation on the [exec resource](http://docs.puppetlabs.com/references/latest/type.html#exec) for more details. Some parameters are not available.

* *task*: (this parameter is required) -
 This parameter is the Ruby task to be performed as a string with command line options. e.g. `db:setup`.
* *rails_env*: (default is `production`) -
 This parameter is used to set the `RAILS_ENV` environment variable, the default is to set it to production. This parameter is combined with the `environment` parameter to be passed to the `environment` parameter of the underlying `exec` resource that runs the rake task.
* *bundle*: (default is false) -
 If set to true, the Rake task is automatically run under a `ruby::bundler` resource.
* *creates*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *cwd*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *environment*: (default is undefined) -
 This parameter is combined with the `rails_env` parameter to be passed to the `environment` parameter of the underlying `exec` resource that runs the rake task.
* *user*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *group*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *logoutput*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *onlyif*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *path*: (default is `['/usr/bin','/bin','/usr/sbin','/sbin']`) -
 The rake executable has a minimum path requirement, if this parameter is left undefined, the default minimum path will be used. If a list of paths is provided, this list will be modified to be sure that it still meets the minimum path requirements for the rake executable. This is then passed to the underlying `exec` resource that runs the rake task.
* *refresh*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *refreshonly*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *timeout*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *tries*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *try_sleep*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the rake task.
* *unless*: (default is undefined)  -
 Passed through to the underlying `exec` resource that runs the rake task.

## Bundler Resource

The `ruby::bundle` resource requires the `ruby::dev` class.

This resource runs [Bundler](http://bundler.io/) tasks. This resource was created to be sure that Bundler tasks would only be executed once their requirements were met by the `ruby::dev` class.

### Parameters

Most of the parameters are passed through to the underlying `exec` resource that runs the bundler task. Check the Puppetlabs documentation on the [exec resource](http://docs.puppetlabs.com/references/latest/type.html#exec) for more details. Some parameters are not available.

* *command*: (default is 'install') -
This sets the command passed to the `bundler` executable. Not all bundler commands are currently supported. Only `exec`, `install` and `update` are currently supported.
* *option*: (default is undefined) -
This sets the options for the bundler command. Not all options are supported.
* *rails_env*: (default is $ruby::params::rails_env) -
 This parameter is used to set the `RAILS_ENV` environment variable, the default is to set it to production. This parameter is combined with the `environment` parameter to be passed to the `environment` parameter of the underlying `exec` resource that runs the bundler task.
* *creates*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *cwd*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *environment*: (default is undefined) -
 This parameter is combined with the `rails_env` parameter to be passed to the `environment` parameter of the underlying `exec` resource that runs the bundler task.
* *user*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *group*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *logoutput*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *onlyif*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *path*: (default is undefined) -
 The bundle executable has a minimum path requirement, if this parameter is left undefined, the default minimum path will be used. If a list of paths is provided, this list will be modified to be sure that it still meets the minimum path requirements for the bundle executable. This is then passed to the underlying `exec` resource that runs the bundle task.
* *refresh*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *refreshonly*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *timeout*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *tries*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *try_sleep*: (default is undefined) -
 Passed through to the underlying `exec` resource that runs the bundler task.
* *unless*: (default is undefined) -
 The `unless` parameter is passed through to the underlying `exec` resource that runs the bundler task if the `ruby::bundler` resource `command` parameter is `exec`. For the `install` or `update` commands `unless` will be automatically set to, or overridden with, a command that makes the `ruby::bundle` resource idempotent.

#### Supported Bundler Commands

* **exec**: For the `exec` command to work, the command to be executed is passed as the option string. If the command is a rake task, it is recommended that the `ruby::rake` resource is used with the `bundle` parameter set to true. There are currently no constraints on the option string for the `exec` command.
* **install**: The `install` command only currently supports the `--clean`,`--deployment`,`--gemfile`,`--path`, `--without`, and `--no-prune` options.
* **update**: The `update` command only currently supports the `--local` and `--source` options. This command will try and update all the gems in a directory every time puppet runs.

## Ruby Configuration Class

Ruby Enterprise Edition, Ruby versions [later than 1.9.3-preview1](http://www.rubyinside.com/ruby-1-9-3-preview-1-released-5229.html), and some patched Ruby distributions allow some tuning of the Ruby memory heap and garbage collection. These features will not work with the standard Ruby distributions prior to 1.9.3.

The `ruby::config` class sets global environment variables that tune the Ruby memory heap and it's garbage collection as [per the Ruby Enterprise Edition documentation](http://www.rubyenterpriseedition.com/documentation.html#_garbage_collector_performance_tuning). This should allow the configuration of Ruby to better suit a deployed application and reduce the memory overhead of long-running Ruby processes (e.g. the [Puppet daemon](http://www.masterzen.fr/2010/01/28/puppet-memory-usage-not-a-fatality/)). The memory overhead issue can be further reduced by upgrading Ruby to a distribution using a [bitmap marked garbage collection](http://patshaughnessy.net/2012/3/23/why-you-should-be-excited-about-garbage-collection-in-ruby-2-0) patch (e.g. as provided by [BrightBox](http://docs.brightbox.com/ruby/ubuntu/)) or to [Ruby 2.x](https://www.ruby-lang.org/en/news/2013/02/24/ruby-2-0-0-p0-is-released/).

### More References

* [Demystifying the Ruby GC](http://samsaffron.com/archive/2013/11/22/demystifying-the-ruby-gc) by Sam Saffron

### Parameters

All the parameters are not set by default, which will revert to the default values for Ruby.

* *gc_malloc_limit* : Sets `RUBY_GC_MALLOC_LIMIT`, which is the amount of memory that can be allocated without triggering garbage collection. The default is 8000000.
* *heap_free_min* : Sets `RUBY_HEAP_FREE_MIN`, which is the number of heap slots that should be available after garbage collection is run. If fewer slots are available, new heap slots will be allocated. The default is 4096.
* *heap_slots_growth_factor* : Sets `RUBY_HEAP_SLOTS_GROWTH_FACTOR`, which is the multiplier for how many new slots to be created if fewer slots than `RUBY_HEAP_FREE_MIN` remain after garbage collection. The default is 1.8.
* *heap_min_slots* : This sets `RUBY_HEAP_MIN_SLOTS`, which is initial number of heap slots. The default is 10000.
* *heap_slots_increment* : This sets `RUBY_HEAP_SLOTS_INCREMENT`, which is the number of additional slots allocated the first time additional slots are required. The default is 10000.

### Usage

It should be possible to set any number of parameters, but setting no parameters is a special case that removes any modification to the Ruby environment settings.

#### No Parameters

If `ruby::config` is given with no parameters it removes the environment settings from the system, which restores the default Ruby settings.

```puppet
include ::ruby::config
```

#### With Parameters

```puppet
class { '::ruby::config':
  heap_min_slots           => 500000,
  heap_slots_increment     => 250000,
  heap_slots_growth_factor => 1,
  gc_malloc_limit          => 50000000,
}
```

Which should result with the following environment variables set:

```
RUBY_HEAP_MIN_SLOTS=500000
RUBY_HEAP_SLOTS_INCREMENT=250000
RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
RUBY_GC_MALLOC_LIMIT=50000000
```

# Package sources

If the required Ruby version is not available for the distribution being used check the following repositories:

* For Ubuntu the [Brightbox Ruby PPA](http://www.ubuntuupdates.org/ppa/brightbox_ruby_ng_experimental) provides Ruby packages, use the following puppet code:

    ```puppet
    include ::apt

    ::apt::ppa { 'ppa:brightbox/ruby-ng-experimental': }

    class { '::ruby':
      version        => '1.9.1',
      switch         => true,
      latest_release => true,
      require        => Apt::Ppa['ppa:brightbox/ruby-ng-experimental'],
    }
    ```
