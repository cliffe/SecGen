## 6.3.0 (June 18, 2018)

This release deprecates Kibana 4.x, which is end-of-life.

### Migration Guide

* Support for 4.x has been deprecated, so consider upgrading to Kibana 5 or later before upgrading this module since only versions 5 and later are supported.
* The module defaults to the upstream package repositories, which now include X-Pack bundled by default. To preserve previous behavior which does _not_ include X-Pack, follow the `README` instructions to configure `oss`-only repositories/packages.
* Use of the `elastic_stack::repo` class for managing package repositories may mean that leftover yum/apt/etc. repositories named `kibana` may persist after upgrade.

#### Features
* Support for 6.3 style repositories using elastic_stack module

#### Fixes

## 6.0.1 (March 13, 2018)

#### Fixes
* Fixed language compatibility errors that could arise when using JRuby 1.7 on Puppet Servers.

## 6.0.0 (November 14, 2017)

Major version upgrade with important deprecations:

* Puppet version 3 is no longer supported.

The following migration guide is intended to help aid in upgrading this module.

### Migration Guide

#### Puppet 3.x No Longer Supported

Puppet 4.5.0 is the new minimum required version of Puppet, which offers better safety, module metadata, and Ruby features.
Migrating from Puppet 3 to Puppet 4 is beyond the scope of this guide, but the [official upgrade documentation](https://docs.puppet.com/upgrade/upgrade_steps.html) can help.
As with any version or module upgrade, remember to restart any agents and master servers as needed.

## 5.2.0 (November 13, 2017)

#### Features
* Added support for service status

## 5.1.0 (August 18, 2017)

#### Features
* Installation via package files (`.deb`/`.rpm`) now supported. See documentation for the `package_source` parameter for usage.
* Updated puppetlabs/apt dependency to reflect support for 4.x versions.

## 5.0.1 (July 19, 2017)

This is a bugfix release to properly contain classes within the `kibana` class so that relationship ordering is respected correctly.

## 5.0.0 (May 10, 2017)

### Summary
Formally release major version 5.0 of the module.

#### Fixes
* metadata.json dependencies now compatible with Puppet 3.x.

## 0.3.0 (April 26, 2017)

### Summary
This release backports support for Puppet 3.8.

## 0.2.1 (April 10, 2017)

### Summary
Bugfix release resolving several minor issues.

#### Features
* Package revisions now supported for ensure values.

#### Fixes
* The `url` parameter for 4.x plugins is now properly passed to the plugin install command.
* Nonzero plugin commmands now properly raise errors during catalog runs.
* Boolean values allowed in config hash.
* apt-transport-https package no longer managed by this module.

## 0.2.0 (March 20, 2017)

### Summary
Minor fixes and full 4.x support.

#### Features
* Feature parity when managing plugins on Kibana 4.x.

#### Fixes
* Removed potential conflict with previously-defined apt-transport-https packages.
* Permit boolean values in configuration hashes.

## 0.1.1 (March 11, 2017)

### Summary
Small bugfix release.

#### Fixes
* Actually aknowledge and use the manage_repo class flag.

## 0.1.0 (March 8, 2017)

### Summary
Initial release.

#### Features
* Support for installing, removing, and updating Kibana and the Kibana service.
* Plugin support.
* Initial support for version 4.x management.

#### Fixes
