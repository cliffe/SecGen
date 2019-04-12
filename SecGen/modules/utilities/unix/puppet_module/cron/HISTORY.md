## v1.0.0 (2017-10-14)

  * BREAKING: Require Puppet version >=4.9.1
  * Added type-hinting to all manifest parameters
  * Added management of /etc/cron.allow and /etc/cron.deny
  * Replaced hiera\_hash() with lookup() calls
  * Replaced params.pp with in-module data (Hiera 5)
  * Replaced create\_resources with iterators
  * Replaced anchor pattern with contain
  * Made the cron::job command attribute optional

## v0.2.1 (2017-07-30)

  * Added support for special time options
  * Rspec fixes

## v0.2.0 (2016-11-22)

  * BREAKING: Added cron service managment
    The cron service is now managed by this module and by default the service will be started
  * Rspec fixes

## v0.1.8 (2016-06-26)

  * Added support for Scientific Linux

## v0.1.7 (2016-06-12)

  * Properly support Gentoo
  * Documentation fixes
  * Rspec fixes

## v0.1.6 (2016-04-10)

  * Added description parameters

## v0.1.5 (2016-03-06)

  * Fix release on forge

## v0.1.4 (2016-03-06)

  * Added possibility to add jobs from hiera
  * Added Debian as supported operating system
  * Allow declaration of cron class without managing the cron package
  * Properly detect RHEL 5 based cron packages
  * Fix puppet-lint warnings
  * Add more tests

## v0.1.3 (2015-09-20)

  * Support for multiple cron jobs in a single file added (cron::job::multiple)
  * Make manifest code more readable
  * Change header in template to fit standard 80 char wide terminals
  * Extend README.md

## v0.1.2 (2015-08-13)

  * Update to new style of Puppet modules (metadata.json)

## v0.1.1 (2015-07-12)

  * Make module Puppet 4 compatible
  * Fix Travis CI integration

## v0.1.0 (2013-08-27)

  * Add support for the `ensure` parameter

## v0.0.3 (2013-07-04)

  * Make job files owned by root
  * Fix warnings for Puppet 3.2.2

## v0.0.2 (2013-05-11)

  * Make mode of job file configurable

## v0.0.1 (2013-03-02)

  * Initial PuppetForge release
