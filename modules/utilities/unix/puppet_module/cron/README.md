# Puppet Cron Module

[![License](https://img.shields.io/github/license/voxpupuli/puppet-cron.svg)](https://github.com/voxpupuli/puppet-cron/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/voxpupuli/puppet-cron.png?branch=master)](https://travis-ci.org/voxpupuli/puppet-cron)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/cron.svg)](https://forge.puppetlabs.com/puppet/cron)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/cron.svg)](https://forge.puppetlabs.com/puppet/cron)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/cron.svg)](https://forge.puppetlabs.com/puppet/cron)

## Notes

This module manages cronjobs by placing files in `/etc/cron.d`.
rmueller-cron was a detached fork of [torrancew/puppet-cron](https://github.com/torrancew/puppet-cron)
After v1.0.0, the module was migrated to Vox Pupuli where it is now maintained and released under the [puppet](https://forge.puppet.com/puppet) namespace.

The current version (starting with v1.0.0) of this module requires Puppet 4.9.1 or greater.  
If you are using an older version of Puppet you can pin the version to v0.2.1 which was still compatible with much older Puppet versions.  
You can browse the documentation of that version in the v0.2.x branch [here](https://github.com/voxpupuli/puppet-cron/tree/v0.2.x).

This module supports configuration of cronjobs via Hiera as well.
For that you need to declare the `cron` class.

This module defines the following types:

  * `cron::job`           - basic job resource
  * `cron::job::multiple` - basic job resource for multiple jobs per file
  * `cron::hourly`        - wrapper for hourly jobs
  * `cron::daily`         - wrapper for daily jobs
  * `cron::weekly`        - wrapper for weekly jobs
  * `cron::monthly`       - wrapper for monthly jobs

## Installation

As usual use `puppet module install puppet-cron` to install it.

## Usage

The title of the job (e.g. `cron::job { 'title':`) is completely arbitrary. However, there can only be one cron job by that name.
The file in `/etc/cron.d/` will be created with the `$title` as the file name.
Keep that in mind when choosing the name to avoid overwriting existing system cronjobs and use characters that don't cause problems when used in filenames.

### cron

If you want the class to automatically install the correct cron package you can declare the `cron` class. By default it will then install the right package.
If you want to use Hiera to configure your cronjobs, you must declare the `cron` class.

You can disable the management of the cron package by setting the `manage_package` parameter to `false`.

You can also specify a different cron package name via `package_name`.
By default we try to select the right one for your distribution.
But in some cases (e.g. Gentoo) you might want to overwrite it here.

This class allows specifying the following parameter:

   * `manage_package` - optional - defaults to "true"
   * `package_ensure` - optional - defaults to "installed"
   * `package_name`   - optional - defaults to OS specific default package name
   * `service_name`   - optional - defaults to OS specific default service name
   * `manage_service`   - optional - defaults to "true"
   * `service_enable`   - optional - defaults to "true"
   * `service_ensure`   - optional - defaults to "running"
   * `manage_users_allow` - optional - defaults to false, whether to manage `/etc/cron.allow`
   * `manage_users_deny` - optional - defaults to false, whether to manage `/etc/cron.deny`
   * `users_allow` - optional - An array of users to add to `/etc/cron.allow`
   * `users_deny` - optional - An array of users to add to `/etc/cron.deny`


Examples:

```puppet
  include cron
```

or:

```puppet
  class { 'cron':
    manage_package => false,
  }
```


### cron::job

`cron::job` creates generic jobs in `/etc/cron.d`.
It allows specifying the following parameters:

  * `ensure`      - optional - defaults to "present"
  * `command`     - required - the command to execute
  * `minute`      - optional - defaults to "\*"
  * `hour`        - optional - defaults to "\*"
  * `date`        - optional - defaults to "\*"
  * `month`       - optional - defaults to "\*"
  * `weekday`     - optional - defaults to "\*"
  * `special`     - optional - defaults to undef
  * `user`        - optional - defaults to "root"
  * `environment` - optional - defaults to ""
  * `mode`        - optional - defaults to "0644"
  * `description` - optional - defaults to undef

Example:
This would create the file `/etc/cron.d/mysqlbackup` and run the command `mysqldump -u root mydb` as root at 2:40 AM every day:

```puppet
  cron::job { 'mysqlbackup':
    minute      => '40',
    hour        => '2',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    command     => 'mysqldump -u root mydb',
    environment => [ 'MAILTO=root', 'PATH="/usr/bin:/bin"', ],
    description => 'Mysql backup',
  }
```

Hiera example:

```yaml
---
cron::job:
  'mysqlbackup':
    command: 'mysqldump -u root mydb'
    minute: 0
    hour: 0
    date: '*'
    month: '*'
    weekday: '*'
    user: root
    environment:
      - 'MAILTO=root'
      - 'PATH="/usr/bin:/bin"'
    description: 'Mysql backup'
```

### cron::job::multiple

`cron:job::multiple` creates a file in `/etc/cron.d` with multiple cron jobs configured in it.
It allows specifying the following parameters:

  * `ensure`      - optional - defaults to "present"
  * `jobs`        - required - an array of hashes of multiple cron jobs using a similar structure as `cron::job`-parameters
  * `environment` - optional - defaults to ""
  * `mode`        - optional - defaults to "0644"

And the keys of the jobs hash are:

  * `command`     - required - the command to execute
  * `minute`      - optional - defaults to "\*"
  * `hour`        - optional - defaults to "\*"
  * `date`        - optional - defaults to "\*"
  * `month`       - optional - defaults to "\*"
  * `weekday`     - optional - defaults to "\*"
  * `special`     - optional - defaults to undef
  * `user`        - optional - defaults to "root"
  * `description` - optional - defaults to undef

Example:

```puppet
cron::job::multiple { 'test_cron_job_multiple':
  jobs => [
    {
      minute      => '55',
      hour        => '5',
      date        => '*',
      month       => '*',
      weekday     => '*',
      user        => 'rmueller',
      command     => '/usr/bin/uname',
      description => 'print system information',
    },
    {
      command     => '/usr/bin/sleep 1',
      description => 'Sleeping',
    },
    {
      command     => '/usr/bin/sleep 10',
      special     => 'reboot',
    },
  ],
  environment => [ 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"' ],
}

```

Hiera example:

```yaml
---
cron::job::multiple:
  'test_cron_job_multiple':
    jobs:
      - {
          minute: 55,
          hour: 5,
          date: '*',
          month: '*',
          weekday: '*',
          user: rmueller,
          command: '/usr/bin/uname',
          description: 'print system information',
        }
      - {
          command: '/usr/bin/sleep 1',
          description: 'Sleeping',
        }
      - {
          command: '/usr/bin/sleep 10',
          special: 'reboot',
        }

    environment:
      - 'PATH="/usr/sbin:/usr/bin:/sbin:/bin"'
```

That will generate the file `/etc/cron.d/test_cron_job_multiple` with essentially this content:

```
PATH="/usr/sbin:/usr/bin:/sbin:/bin"

55 5 * * *  rmueller  /usr/bin/uname
* * * * *  root  /usr/bin/sleep 1
@reboot  root  /usr/bin/sleep 10
```

### cron::hourly

`cron::hourly` creates jobs in `/etc/cron.d` that run once per hour.
It allows specifying the following parameters:

  * `ensure`      - optional - defaults to "present"
  * `command`     - required - the command to execute
  * `minute`      - optional - defaults to "0"
  * `user`        - optional - defaults to "root"
  * `environment` - optional - defaults to ""
  * `mode`        - optional - defaults to "0644"
  * `description` - optional - defaults to undef

Example:
This would create the file `/etc/cron.d/mysqlbackup_hourly` and run the command `mysqldump -u root mydb` as root on the 20th minute of every hour:

```puppet
  cron::hourly { 'mysqlbackup_hourly':
    minute      => '20',
    user        => 'root',
    command     => 'mysqldump -u root mydb',
    environment => [ 'MAILTO=root', 'PATH="/usr/bin:/bin"', ],
  }
```

Hiera example:

```yaml
---
cron::hourly:
  'mysqlbackup_hourly':
    minute: 20
    user: root
    command: 'mysqldump -u root mydb'
    environment:
      - 'MAILTO=root'
      - 'PATH="/usr/bin:/bin"'
```

### cron::daily

`cron::daily` creates jobs in `/etc/cron.d` that run once per day.
It allows specifying the following parameters:

  * `ensure`      - optional - defaults to "present"
  * `command`     - required - the command to execute
  * `minute`      - optional - defaults to "0"
  * `hour`        - optional - defaults to "0"
  * `user`        - optional - defaults to "root"
  * `environment` - optional - defaults to ""
  * `mode`        - optional - defaults to "0644"
  * `description` - optional - defaults to undef

Example:
This would create the file `/etc/cron.d/mysqlbackup_daily` and run the command `mysqldump -u root mydb` as root at 2:40 AM every day, like the above generic example:

```puppet
  cron::daily { 'mysqlbackup_daily':
    minute  => '40',
    hour    => '2',
    user    => 'root',
    command => 'mysqldump -u root mydb',
  }
```

Hiera example:

```yaml
---
cron::daily:
  'mysqlbackup_daily':
    minute: 40
    hour: 2
    user: root
    command: 'mysqldump -u root mydb'
```


### cron::weekly

`cron::weekly` creates jobs in `/etc/cron.d` that run once per week.
It allows specifying the following parameters:

  * `ensure`      - optional - defaults to "present"
  * `command`     - required - the command to execute
  * `minute`      - optional - defaults to "0"
  * `hour`        - optional - defaults to "0"
  * `weekday`     - optional - defaults to "0"
  * `user`        - optional - defaults to "root"
  * `environment` - optional - defaults to ""
  * `mode`        - optional - defaults to "0644"
  * `description` - optional - defaults to undef

Example:
This would create the file `/etc/cron.d/mysqlbackup_weekly` and run the command `mysqldump -u root mydb` as root at 4:40 AM every Sunday, like the above generic example:

```puppet
  cron::weekly { 'mysqlbackup_weekly':
    minute  => '40',
    hour    => '4',
    weekday => '0',
    user    => 'root',
    command => 'mysqldump -u root mydb',
  }
```

Hiera example:

```yaml
---
cron::weekly:
  'mysqlbackup_weekly':
    minute: 40
    hour: 4
    weekday: 0
    user: root
    command: 'mysqldump -u root mydb'
```


### cron::monthly

`cron::monthly` creates jobs in `/etc/cron.d` that run once per month.
It allows specifying the following parameters:

  * `ensure`      - optional - defaults to "present"
  * `command`     - required - the command to execute
  * `minute`      - optional - defaults to "0"
  * `hour`        - optional - defaults to "0"
  * `date`        - optional - defaults to "1"
  * `user`        - optional - defaults to "root"
  * `environment` - optional - defaults to ""
  * `mode`        - optional - defaults to "0644"
  * `description` - optional - defaults to undef

Example:
This would create the file `/etc/cron.d/mysqlbackup_monthly` and run the command `mysqldump -u root mydb` as root at 3:40 AM the 1st of every month, like the above generic example:

```puppet
  cron::monthly { 'mysqlbackup_monthly':
    minute  => '40',
    hour    => '3',
    date    => '1',
    user    => 'root',
    command => 'mysqldump -u root mydb',
  }
```

Hiera example:

```yaml
---
cron::monthly:
  'mysqlbackup_monthly':
    minute: 40
    hour: 3
    date: 1
    user: root
    command: 'mysqldump -u root mydb'
```


## Contributors

  * Kevin Goess (@kgoess)               - Environment variable support + fixes
  * Andy Shinn (@andyshinn)             - RedHat derivatives package name fix
  * Chris Weyl (@RsrchBoy)              - Fixed Puppet 3.2 deprecation warnings
  * Mathew Archibald (@mattyindustries) - Fixed file ownership issues
  * The Community                       - Continued improvement of this module via bugs and patches

