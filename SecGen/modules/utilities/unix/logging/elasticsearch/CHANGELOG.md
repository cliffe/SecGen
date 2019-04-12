## 6.3.3 (September 7, 2018)

Note that this release includes changes to a default value that may affect users that rely on `curl` or `wget` to retrieve Elasticsearch package files, as now all certificates are validated by default.
To preserve existing behavior, set `$elasticsearch::download_tool_verify_certificates` to `false`.

#### Fixes
* Update puppetlabs-stdlib dependency to < 6.0.0
* By default, package files downloaded with tools like wget or curl (i.e., the `$elasticsearch::download_tool` parameter) now verify certificates by default and a new boolean parameter has been added to indicate whether to ignore certificates (`$elasticsearch::download_tool_verify_certificates`).

## 6.3.2 (August 28, 2018)

#### Fixes
* Fix an issue with string coercion for certain fields in pipelines.

## 6.3.1 (August 6, 2018)

Primarily a bugfix release.

#### Fixes
* REST-based resources are now coerced to string values to uniformly compare user defined values and Elasticsearch API responses.
* Resolve deprecation warnings related to use of the deprecated is_array() function.
* Fixed an erroneous inclusion of '<' in logging.yml
* Resolve deprecation warnings related to use of the deprecated is_string() function.

## 6.3.0 (June 18, 2018)

### Migration Guide

Elasticsearch 6.3 includes several big changes that are reflected in this module.
When upgrading from module versions prior to 6.3, there are a number of upgrade considerations to take into account:

* This module defaults to the upstream package repositories, which now include X-Pack bundled by default. To preserve previous behavior which does _not_ include X-Pack, follow the `README` instructions to configure `oss`-only repositories/packages.
  * Note that if your system was previously using the `elasticsearch` package and you instead choose to move to the `oss` distribution, the `elasticsearch` and `elasticsearch-oss` packages may conflict. If that occurs, consider ensuring that the `elasticsearch` package is absent before the `::elasticsearch` class runs. This module does not explicitly remove the conflicting package to avoid unexpected package removal.
* Use of the `elastic_stack::repo` class for managing package repositories brings a couple changes:
  * All repository-level parameters and settings have been removed from the `::elasticsearch` class. These parameters can now be set on the `elastic_stack::repo` class.
  * This may mean that leftover yum/apt/etc. repositories named `elasticsearch` may persist after upgrade.
* Some changes have been made to align this module's file-level permissions with upstream defaults on some configuration, data, and logging directories. Though these have been tested, operators should be aware that some permissions may change on-disk after upgrading to version >= 6.3.x of this module.

#### Features
* Added support for managing Elasticsearch licenses.
* This module now uses the elastic-stack module to manage package repositories.
* Supports OSS packaging distribution.
* X-Pack bundled with 6.3 support.

#### Fixes
* Ensure that the stock Elasticsearch service is not running.
* Service files for removed instances were previously set to ensure => absent on removal. Because this limits Puppet's ability to verify that the named service is running or not, these service files are always present now whether an instance is set to present or absent.
* The service defaults file now enforces user/group ownership inline with the service user runtime.
* The `scripts` configuration directory is now recursively copied instead of symlinked to avoid Elasticsearch security manager permission errors.
* X-Pack and other meta-plugins are now properly detected as installed by the native plugin provider.

## 6.2.2 (March 13, 2018)

#### Fixes
* Fixed language compatibility errors that could arise when using JRuby 1.7 on Puppet Servers.

## 6.2.1 (February 14, 2018)

This is primarily a bugfix release to address an issue when installing Elasticsearch 6.2.x plugins such as X-Pack that use the new meta-plugin architecture.
While the change has been tested with several plugins and versions of Elasticsearch, if any unexpected behavior arises, help is available on the [Elastic forums](https://discuss.elastic.co/) or via [an issue in the puppet-elasticsearch Github repository](https://github.com/elastic/puppet-elasticsearch/issues).

#### Fixes
* Rewrote the `exists?` logic for the `elasticsearch_plugin` provider. This fundamentally changes how the module detects the presence of plugins but should be backwards compatible.

## 6.2.0 (February 9, 2018)

#### Features
* Add support for Amazon Linux 2
* Add support for managing Elasticsearch Snapshot Repository resources

#### Fixes
* Fixed an issue when setting `file_rolling_type => file` in Elasticsearch 6.
* Removed ExecStartPre=- from systemd template

## 6.1.0 (December 18, 2017)

#### Features
* Removed `tea` module dependency for pre-existing types in `stdlib` module.
* Support `file` as a `file_rolling_type`.
* Added `java_opts` parameter to `elasticsearch::plugin` resource.
* Brought some options in `jvm.options` up-to-date with upstream.
* Plugins can now have their `JAVA_HOME` set through the `java_home` parameter.

#### Fixes
* Fixed issue with `ES_PATH_CONF` being unset in SysV init files.

## 6.0.0 (November 14, 2017)

Major version upgrade with several important deprecations:

* Puppet version 3 is no longer supported.
* Package pinning is no longer supported.
* Java installation is no longer supported.
* The python and ruby defined types have been removed.
* Repo management through `manage_repo` is now set to `true` by default.
* All `*_hiera_merge` parameters have been removed.

Minor:

* elasticsearch::plugin only accepts `present` or `absent`
* Some REST-resource based providers (such as templates and pipelines) now validate parameters (such as numeric port numbers) more rigorously.

The following migration guide is intended to help aid in upgrading this module.

### Migration Guide

#### Puppet 3.x No Longer Supported

Puppet 4.5.0 is the new minimum required version of Puppet, which offers better safety, module metadata, and Ruby features.
Migrating from Puppet 3 to Puppet 4 is beyond the scope of this guide, but the [official upgrade documentation](https://docs.puppet.com/upgrade/upgrade_steps.html) can help.
As with any version or module upgrade, remember to restart any agents and master servers as needed.

#### Package Pinning No Longer Supported

Package pinning caused lots of unexpected behavior and usually caused more problems than solutions.
If you still require package pinning, consider using the [`apt::pin` resource](https://forge.puppet.com/puppetlabs/apt#pin-a-specific-release) on Debian-based systems or a [`yum::versionlock` resource from the yum module](https://forge.puppet.com/puppet/yum#lock-a-package-with-the-versionlock-plugin) for Red Hat-based systems.

#### Java Installation No Longer Supported

Java installation was a very simple operation in this module which simply declared an instance of the `java` class but created conflicts for users who managed Java separately.
If you still wish to configure Java alongside this module, consider using the [puppetlabs/java](https://forge.puppet.com/puppetlabs/java) module and installing Java with the following configuration:

```puppet
class { "java" : distribution => "jre" }
```

This will install a version of Java suitable for Elasticsearch in most situations.
Note that in some older distributions, you may need to take extra steps to install a more recent version of Java that supports Elasticsearch.

#### Removal of Python and Ruby Resources

These resource types were simple wrappers around `package` resources with their providers set to `pip` and `gem`, respectively.
Simply defining your own resources similarly to:

```puppet
package { 'elasticsearch' : provider => 'pip' }
```

Is sufficient.

#### Automatic Package Repository Management

This parameter is now set to `true` by default to automatically manage the Elastic repository.
If you do not wish to configure the repository to automatically retrieve package updates, set this parameter to `false`:

```puppet
class { 'elasticsearch': manage_repo => false }
```

#### Removal of `hiera_merge` Parameters

Updates to Hiera in later versions of Puppet mean that you can set merging behavior in end-user configuration.
Read [the upstream Hiera documentation regarding `lookup_options`](https://puppet.com/docs/puppet/4.10/hiera_merging.html#configuring-merge-behavior-in-hiera-data) to learn how to configure Hiera appropriately for your needs.

## 5.5.0 (November 13, 2017)

#### Features
* Updated puppetlabs/java dependency to `< 5.0.0`

#### Fixes
* Properly support plugin installation on 6.x series with explicit `ES_PATH_CONF`
* set file ownership of systemd service file to root user/group
* Fix propagating the pid_dir into OpenBSD rcscript

## 5.4.3 (September 1, 2017)

#### Features
* Bumped puppet/java dependency to < 3.0.0

#### Fixes
* Append `--quiet` flag to >= 5.x versions of Elasticsearch systemd service units
* Disable es_facts collection on SearchGuard nodes with TLS enabled

## 5.4.2 (August 18, 2017)

#### Features
* Bumped puppet/yum dependency to < 3.0.0

#### Fixes
* Custom facts no longer attempt to connect to SSL/TLS secured ports.

## 5.4.1 (August 7, 2017)

Fixed an issue where `logging_yml_ensure` and `log4j2_ensure` would not propagate to `elasticsearch::instance` resources.

## 5.4.0 (August 3, 2017)

#### Features
* The `api_timeout` parameter is now passed to the `es_instance_conn_validator` resource for index, pipeline, and template defined types.
* Updated puppetlabs/apt dependency to < 5.0.0.
* Both the `logging.yml` and `log4j2.properties` files can be selectively enabled/disabled with the `logging_yml_ensure` and `log4j2_ensure` parameters on the `elasticsearch` class and `elasticsearch::instance` defined type.
* `jvm_options` are now controllable on a per-instance basis.

#### Fixes
* Fixed an edge case with `es_instance_validator` in which ruby connection errors were not caught.
* Plugins with colon-delimited names (such as maven plugins) are properly handled now.
* Fixed a bug that would cause dependency cycles when using parameters to create defined types.

## 5.3.1 (June 14, 2017)

### Summary
Minor release to fix bugs related to the `elasticsearch_keystore` type and generated docs.

#### Features
* Moved documentation to Yard for doc auto-generation for all classes/types/etc.

#### Fixes
* Fixed dependency order bug with the `elasticsearch_keystore` type and augeas defaults resource.

## 5.3.0 (June 5, 2017)

### Summary
Minor bugfix release with added support for managing Elasticsearch keystores, custom repository URLs, and more.

#### Features
* Failures are no longer raised when no instances are defined for a plugin and service restarts are not requested.
* The `datadir` for instances can now be shared among multiple instances by using the `datadir_instance_directories` parameter.
* `repo_baseurl` is now exposed as a top-level parameter for users who wish to control custom repositories.
* `elasticsearch-keystore` values can now be managed via native Puppet resources.

#### Fixes
* log4j template now properly respects deprecation logging settings.

## 5.2.0 (May 5, 2017)

### Summary
Release supporting several new features and bugfixes for 5.4.0 users and users who need the ability to update plugins.

#### Features
* Support for Shield/X-Pack logging configuration file added.
* The `elasticsearch::script` type now supports recursively managing directories of scripts.
* All module defined types can now be managed as top-level hash parameters to the `elasticsearch` class (primarily for hiera and PE)

#### Fixes
* Fixed a bug that prevented plugins from being updated properly.
* Fixed deprecated `default.path` options introduced in Elasticsearch 5.4.0.

## 5.1.1 (April 13, 2017)

### Summary

#### Features
* Instance configs now have highest precedence when constructing the final yaml
    config file.

#### Fixes
This is a hotfix release to support users affected by [an upstream Elasticsearch issue](https://github.com/elastic/elasticsearch/issues/6887).
See the [associated issue](https://github.com/elastic/puppet-elasticsearch/issues/802#issuecomment-293295930) for details regarding the workaround.
The change implemented in this release is to place the `elasticsearch::instance` `config` parameter at the highest precedence when merging the final config yaml which permits users manually override `path.data` values.

## 5.1.0 (February 28, 2017)

### Summary
Ingest pipeline and index settings support.
Minor bugfixes.

#### Features
* Ingestion pipelines supported via custom resources.
* Index settings support.

#### Fixes
* Custom facts no longer fail when trying to read unreadable elasticsearch config files.
* `Accept` and `Content-Type` headers properly set for providers (to support ES 6.x)

## 5.0.0 (February 9, 2017)

Going forward, This module will follow Elasticsearch's upstream major version to indicate compatability.
That is, version 5.x of this module supports version 5 of Elasticsearch, and version 6.x of this module will be released once Elasticsearch 6 support is added.

### Summary
Note that this is a **major version release**!
Please read the release notes carefully before upgrading to avoid downtime/unexpected behavior.
Remember to restart any puppetmaster servers to clear provider caches and pull in updated code.

### Backwards-Incompatible Changes
* The `elasticsearch::shield::user` and `elasticsearch::shield::role` resources have been renamed to `elasticsearch::user` and `elasticsearch::role` since the resource now handles both Shield and X-Pack.
* Both Shield and X-Pack configuration files are kept in `/etc/elasticsearch/shield` and `/etc/elasticsearch/x-pack`, respectively. If you previously managed Shield resources with version 0.x of this module, you may need to migrate files from `/usr/share/elasticsearch/shield`.
* The default data directory has been changed to `/var/lib/elasticsearch`. If you used the previous default (the Elasticsearch home directory, `/usr/share/elasticsearch/data`), you may need to migrate your data.
* The first changes that may be Elasticsearch 1.x-incompatible have been introduced (see the [elasticsearch support lifecycle](https://www.elastic.co/support/eol)). This only impacts version 1.x running on systemd-based distributions.
* sysctl management has been removed (and the module removed as a dependency for this module), and puppet/yum is used in lieu of ceritsc/yum.

#### Features
* Support management of the global jvm.options configuration file.
* X-Pack support added.
* Restricted permissions to the elasticsearch.yml file.
* Deprecation log configuration support added.
* Synced systemd service file with upstream.

#### Bugfixes
* Fixed case in which index template could prepend an additional 'index.' to index settings.
* Fixed a case in which dependency cycles could arise when pinning packages on CentOS.
* No longer recursively change the Elasticsearch home directory's lib/ to the elasticsearch user.
* Unused defaults values now purged from instance init defaults files.

#### Changes
* Changed default data directory to /var/lib
* sysctl settings are no longer managed by the thias/sysctl module.
* Calls to `elasticsearch -version` in elasticsearch::plugin code replaced with native Puppet code to resolve Elasticsearch package version. Should improve resiliency when managing plugins.
* Shield and X-Pack configuration files are stored in /etc/elasticsearch instead of /usr/share/elasticsearch.
* Removed deprecated ceritsc/yum module in favor of puppet/yum.

#### Testing changes

## 0.15.1 (December 1, 2016)

### Summary
Primarily a bugfix release for Elasticsearch 5.x support-related issues.
Note updated minimum required puppet versions as well.

#### Features

#### Bugfixes
* Removed ES_HEAP_SIZE check in init scripts for Elasticsearch 5.x
* Changed sysctl value to a string to avoid type errors for some versions
* Fixed a $LOAD_PATH error that appeared in some cases for puppet_x/elastic/es_versioning

#### Changes
* Updated minimium required version for Puppet and PE to reflect tested versions and versions supported by Puppet Labs

#### Testing changes

## 0.15.0 (November 17, 2016)

### Summary
* Support for Ubuntu Xenial (16.04) formally declared.
* Initial support for running Elasticsearch 5.x series.

#### Features
* Support management of 5.x-style Elastic yum/apt package repositories.
* Support service scripts for 5.x series of Elasticsearch

#### Bugfixes
* Update the apt::source call to not cause deprecation warnings
* Updated module metadata to correctly require puppet-stdlib with validate_integer()

#### Changes

#### Testing changes
* Ubuntu Xenial (16.04) added to the test matrix.

## 0.14.0 (October 12, 2016)

### Summary
Primarily a bugfix release for issues related to plugin proxy functionality, various system service fixes, and directory permissions.
This release also adds the ability to define logging rolling file settings and a CA file/path for template API access.

#### Features
* Added 'file_rolling_type' parameter to allow selecting file logging rotation type between "dailyRollingFile" or "rollingFile". Also added 'daily_rolling_date_pattern', 'rolling_file_max_backup_index' and 'rolling_file_max_file_size' for file rolling customization.

#### Bugfixes
* Permissions on the Elasticsearch plugin directory have been fixed to permit world read rights.
* The service systemd unit now `Wants=` a network target to fix bootup parallelization problems.
* Recursively create the logdir for elasticsearch when creating multiple instances
* Files and directories with root ownership now specify UID/GID 0 instead to improve compatability with *BSDs.
* Elasticsearch Debian init file changed to avoid throwing errors when DATA_DIR, WORK_DIR and/or LOG_DIR were an empty variable.
* Fixed a broken File dependency when a plugin was set to absent and ::elasticsearch set to present.
* Fixed issue when using the `proxy` parameter on plugins in Elasticsearch 2.x.

#### Changes
* The `api_ca_file` and `api_ca_path` parameters have been added to support custom CA bundles for API access.
* Numerics in elasticsearch.yml will always be properly unquoted.
* puppetlabs/java is now listed as a dependency in metadata.json to avoid unexpected installation problems.

#### Testing changes

## 0.13.2 (August 29, 2016)

### Summary
Primarily a bugfix release to resolve HTTPS use in elasticsearch::template resources, 5.x plugin operations, and plugin file permission enforcement.

#### Features
* Plugin installation for the 5.x series of Elasticsearch is now properly supported.

#### Bugfixes
* Recursively enforce correct plugin directory mode to avoid Elasticsearch startup permissions errors.
* Fixed an edge case where dependency cycles could arise when managing absent resources.
* Elasticsearch templates now properly use HTTPS when instructed to do so.

#### Changes
* Updated the elasticsearch_template type to return more helpful error output.
* Updated the es_instance_conn_validator type to silence deprecation warnings in Puppet >= 4.

#### Testing changes

## 0.13.1 (August 8, 2016)

### Summary
Lingering bugfixes from elasticsearch::template changes.
More robust systemd mask handling.
Updated some upstream module parameters for deprecation warnings.
Support for the Shield `system_key` file.

#### Features
* Added `system_key` parameter to the `elasticsearch` class and `elasticsearch::instance` type for placing Shield system keys.

#### Bugfixes
* Fixed systemd elasticsearch.service unit masking to use systemctl rather than raw symlinking to avoid puppet file backup errors.
* Fixed a couple of cases that broke compatability with older versions of puppet (elasticsearch_template types on puppet versions prior to 3.6 and yumrepo parameters on puppet versions prior to 3.5.1)
* Fixed issues that caused templates to be incorrectly detected as out-of-sync and thus always changed on each puppet run.
* Resources are now explicitly ordered to ensure behavior such as plugins being installed before instance start, users managed before templates changed, etc.

#### Changes
* Updated repository gpg fingerprint key to long form to silence module warnings.

#### Testing changes

## 0.13.0 (August 1, 2016)

### Summary
Rewritten elasticsearch::template using native type and provider.
Fixed and added additional proxy parameters to elasticsearch::plugin instances.
Exposed repo priority parameters for apt and yum repos.

#### Features
* In addition to better consistency, the `elasticsearch::template` type now also accepts various `api_*` parameters to control how access to the Elasticsearch API is configured (there are top-level parameters that are inherited and can be overwritten in `elasticsearch::api_*`).
* The `elasticsearch::config` parameter now supports deep hiera merging.
* Added the `elasticsearch::repo_priority` parameter to support apt and yum repository priority configuration.
* Added `proxy_username` and `proxy_password` parameters to `elasticsearch::plugin`.

#### Bugfixes
* Content of templates should now properly trigger new API PUT requests when the index template stored in Elasticsearch differs from the template defined in puppet.
* Installing plugins with proxy parameters now works correctly due to changed Java property flags.
* The `elasticsearch::plugin::module_dir` parameter has been re-implemented to aid in working around plugins with non-standard plugin directories.

#### Changes
* The `file` parameter on the `elasticsearch::template` defined type has been deprecated to be consistent with usage of the `source` parameter for other types.

#### Testing changes

## 0.12.0 (July 20, 2016)

IMPORTANT! A bug was fixed that mistakenly added /var/lib to the list of DATA_DIR paths on Debian-based systems.  This release removes that environment variable, which could potentially change path.data directories for instances of Elasticsearch.  Take proper precautions when upgrading to avoid unexpected downtime or data loss (test module upgrades, et cetera).

### Summary
Rewritten yaml generator, code cleanup, and various bugfixes. Configuration file yaml no longer nested. Service no longer restarts by default, and exposes more granular restart options.

#### Features
* The additional parameters restart_config_change, restart_package_change, and restart_plugin_change have been added for more granular control over service restarts.

#### Bugfixes
* Special yaml cases such as arrays of hashes and strings like "::" are properly supported.
* Previous Debian SysV init scripts mistakenly set the `DATA_DIR` environment variable to a non-default value.
* Some plugins failed installation due to capitalization munging, the elasticsearch_plugin provider no longer forces downcasing.

#### Changes
* The `install_options` parameter on the `elasticsearch::plugin` type has been removed. This was an undocumented parameter that often caused problems for users.
* The `elasticsearch.service` systemd unit is no longer removed but masked by default, effectively hiding it from systemd but retaining the upstream vendor unit on disk for package management consistency.
* `restart_on_change` now defaults to false to reduce unexpected cluster downtime (can be set to true if desired).
* Package pinning is now contained within a separate class, so users can opt to manage package repositories manually and still use this module's pinning feature.
* All configuration hashes are now flattened into dot-notated yaml in the elasticsearch configuration file. This should be fairly transparent in terms of behavior, though the config file formatting will change.

#### Testing changes
* The acceptance test suite has been dramatically slimmed to cut down on testing time and reduce false positives.

## 0.11.0 ( May 23, 2016 )

### Summary
Shield support, SLES support, and overhauled testing setup.

#### Features
* Support for shield
  * TLS Certificate management
  * Users (role and password management for file-based realms)
  * Roles (file-based with mapping support)
* Support (repository proxies)[https://github.com/elastic/puppet-elasticsearch/pull/615]
* Support for (SSL auth on API calls)[https://github.com/elastic/puppet-elasticsearch/pull/577]

#### Bugfixes
* (Fix Facter calls)[https://github.com/elastic/puppet-elasticsearch/pull/590] in custom providers

#### Changes

#### Testing changes
* Overhaul testing methodology, see CONTRIBUTING for updates
* Add SLES 12, Oracle 6, and PE 2016.1.1 to testing matrix
* Enforce strict variable checking

#### Known bugs
* This is the first release with Shield support, some untested edge cases may exist


##0.10.3 ( Feb 08, 2016 )

###Summary
Adding support for OpenBSD and minor fixes

####Features
* Add required changes to work with ES 2.2.x plugins
* Support for custom log directory
* Support for OpenBSD

####Bugfixes
* Add correct relation to file resource and plugin installation
* Notify service when upgrading the package

####Changes
* Remove plugin dir when upgrading Elasticsearch

####Testing changes

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.10.2 ( Jan 19, 2016 )

###Summary
Bugfix release and adding Gentoo support

####Features
* Added Gentoo support

####Bugfixes
* Create init script when set to unmanaged
* init_template variable was not passed on correctly to other classes / defines
* Fix issue with plugin type that caused run to stall
* Export ES_GC_LOG_FILE in init scripts

####Changes
* Improve documentation about init_defaults
* Update common files
* Removed recurse option on data directory management
* Add retry functionality to plugin type

####Testing changes

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.10.1 ( Dec 17, 2015 )

###Summary
Bugfix release for proxy functionality in plugin installation

####Features

####Bugfixes
* Proxy settings were not passed on correctly

####Changes
* Cleanup .pmtignore to exclude more files

####Testing changes

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.10.0 ( Dec 14, 2015 )

###Summary
Module now works with ES 2.x completely

####Features
* Work with ES 2.x new plugin system and remain to work with 1.x
* Implemented datacat module from Richard Clamp so other modules can hook into it for adding configuration options
* Fixed init and systemd files to work with 1.x and 2.x
* Made the module work with newer pl-apt module versions
* Export es_include so it is passed on to ES
* Ability to supply long gpg key for apt repo

####Bugfixes
* Documentation and typographical fixes
* Do not force puppet:/// schema resource
* Use package resource defaults rather than setting provider and source

####Changes

####Testing changes
* Improve unit testing and shorten the runtime

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.9.9 ( Sep 01, 2015 )

###Summary
Bugfix release and extra features

####Features
* Work with ES 2.x
* Add Java 8 detection in debian init script
* Improve offline plugin installation

####Bugfixes
* Fix a bug with new ruby versions but older puppet versions causing type error
* Fix config tempate to use correct ruby scoping
* Fix regex retrieving proxy port while downloading plugin
* Fix systemd template for better variable handling
* Template define was using wrong pathing for removal


####Changes

####Testing changes

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.9.8 ( Jul 07, 2015 )

###Summary


####Features
* Work with ES 2.x

####Bugfixes
* Fix plugin to maintain backwards compatibility

####Changes

####Testing changes
* ensure testing works with Puppet 4.x ( Rspec and Acceptance )

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.9.7 ( Jun 24, 2015 )

###Summary
This releases adds several important features and fixes an important plugin installation issue with ES 1.6 and higher.

####Features
* Automate plugin dir extraction
* use init service provider for Amazon Linux
* Add Puppetlabs/apt and ceritsc/yum as required modules
* Added Timeout to fetching facts in case ES does not respond
* Add proxy settings for package download

####Bugfixes
* Fixed systemd template to fix issue with LimitMEMLOCK setting
* Improve package version handling when specifying a version
* Add tmpfiles.d file to manage sub dir in /var/run path
* Fix plugin installations for ES 1.6 and higher

####Changes
* Removed Modulefile, only maintaining metadata.json file

####Testing changes
* Added unit testing for package pinning feature
* Added integration testing with Elasticsearch to find issues earlier
* Fix OpenSuse 13 testing

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.9.6 ( May 28, 2015 )

###Summary
Bugfix release 0.9.6

####Features
* Implemented package version pinning to avoid accidental upgrading
* Added support for Debian 8
* Added support for upgrading plugins
* Managing LimitNOFILE and LimitMEMLOCK settings in systemd

####Bugfixes

####Changes
* Dropped official support for PE 3.1.x and 3.2.x

####Testing changes
* Several testing changes implemented to increase coverage

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.9.5( Apr 16, 2015 )

###Summary
Bugfix release 0.9.5

We reverted the change that implemented the full 40 character for the apt repo key.
This caused issues with some older versions of the puppetlabs-apt module

####Features

####Bugfixes
* Revert using the full 40 character for the apt repo key.

####Changes

####Testing changes

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.9.4( Apr 14, 2015 )

###Summary
Bugfix release 0.9.4

####Features
* Add the ability to create and populate scripts

####Bugfixes
* add support for init_defaults_file to elasticsearch::instance
* Update apt key to full 40characters

####Changes
* Fix readme regarding module_dir with plugins

####Testing changes
* Adding staged removal test
* Convert git urls to https
* Add centos7 node config

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name


##0.9.3( Mar 24, 2015 )

###Summary
Bugfix release 0.9.3

####Features

####Bugfixes
* Not setting repo_version did not give the correct error
* Systemd file did not contain User/Group values

####Changes
* Brand rename from Elasticsearch to Elastic

####Testing changes
* Moved from multiple Gemfiles to single Gemfile

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name

##0.9.2( Mar 06, 2015 )

###Summary
Bugfix release 0.9.2

####Features
* Introducing es_instance_conn_validator resource to verify instance availability

####Bugfixes
* Fix missing data path when using the path config setting but not setting the data path

####Changes
None

####Testing changes
None

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name

##0.9.1 ( Feb 23, 2015 )

###Summary
This is the first bug fix release for 0.9 version.
A bug was reported with the recursive file management.

####Features
None

####Bugfixes
* Fix recursive file management
* Set undefined variables to work with strict_variables

####Changes
None

####Testing changes
None

####Known bugs
* Possible package conflicts when using ruby/python defines with main package name

##0.9.0 ( Feb 02, 2015 )

###Summary
This release is the first one towards 1.0 release.
Our planning is to provide LTS releases with the puppet module

####Features
* Support for using hiera to define instances and plugins.
* Support for OpenSuSE 13.x
* Custom facts about the installed Elasticsearch instance(s)
* Proxy host/port support for the plugin installation
* Ability to supply a custom logging.yml template

####Bugfixes
* Ensure file owners are correct accross all related files
* Fix of possible service name conflict
* Empty main config would fail with instances
* Removal of standard files from packages we dont use
* Ensuring correct sequence of plugin and template defines
* Added ES_CLASSPATH export to init scripts

####Changes
* Java installation to use puppetlabs-java module
* Added Support and testing for Puppet 3.7 and PE 3.7
* Improve metadata.json based on scoring from Forge


####Testing changes
* Added testing against Puppet 3.7 and PE 3.7
* Using rspec3
* Using rspec-puppet-facts gem simplifies rspec testing

####Known Bugs
* Possible package conflicts when using ruby/python defines with main package name

##0.4.0 ( Jun 18, 2014 ) - Backwards compatible breaking release

###Summary
This release introduces instances to facilitate the option to have more then a single instance running on the host system.

####Features
* Rewrite module to incorperate multi instance support
* New readme layout

####Bugfixes
* None

####Changes
* Adding ec2-linux osfamily for repo management
* Retry behaviour for plugin installation

####Testing changes
* Adding Puppet 3.6.x testing
* Ubuntu 14.04 testing
* Using new docker images
* Pin rspec to 2.14.x

####Known Bugs
* No known bugs

##0.3.2 ( May 15, 2014 )
*  Add support for SLC/Scientific Linux CERN ( PR #121 )
*  Add support for custom package names ( PR #122 )
*  Fix python and ruby client defines to avoid name clashes.
*  Add ability to use stage instead of anchor for repo class
*  Minor fixes to system tests

##0.3.1 ( April 22, 2014 )
*  Ensure we create the plugin directory before installing plugins
*  Added Puppet 3.5.x to rspec and system tests

##0.3.0 ( April 2, 2014 )
*  Fix minor issue with yumrepo in repo class ( PR #92 )
*  Implement OpenSuse support
*  Implement Junit reporting for tests
*  Adding more system tests and convert to Docker images
*  Use Augeas for managing the defaults file
*  Add retry to package download exec
*  Add management to manage the logging.yml file
*  Improve inline documentation
*  Improve support for Debian 6
*  Improve augeas for values with spaces
*  Run plugin install as ES user ( PR #108 )
*  Fix rights for the plugin directory
*  Pin Rake for Ruby 1.8.7
*  Adding new metadata for Forge.
*  Increase time for retry to insert the template

##0.2.4 ( Feb 21, 2014 )
*  Set puppetlabs-stdlib dependency version from 3.0.0 to 3.2.0 to be inline with other modules
*  Let puppet run fail when template insert fails
*  Documentation improvements ( PR #77, #78, #83 )
*  Added beaker system tests
*  Fixed template define after failing system tests
*  Some fixes so variables are more inline with intended structure

##0.2.3 ( Feb 06, 2014 )
*  Add repository management feature
*  Improve testing coverage and implement basic resource coverage reporting
*  Add puppet 3.4.x testing
*  Fix dependency in template define ( PR #72 )
*  For apt repo change from key server to key file

##0.2.2 ( Jan 23, 2014 )
*  Ensure exec names are unique. This caused issues when using our logstash module
*  Add spec tests for plugin define

##0.2.1 ( Jan 22, 2014 )
*  Simplify the management of the defaults file ( PR #64 )
*  Doc improvements for the plugin define ( PR #66 )
*  Allow creation of data directory ( PR #68 )
*  Fail early when package version and package_url are defined

##0.2.0 ( Nov 19, 2013 )
*  Large rewrite of the entire module described below
*  Make the core more dynamic for different service providers and multi instance capable
*  Add better testing and devided into different files
*  Fix template function. Replace of template is now only done when the file is changed
*  Add different ways to install the package except from the repository ( puppet/http/https/ftp/file )
*  Update java class to install openjdk 1.7
*  Add tests for python function
*  Update config file template to fix scoping issue ( from PR #57 )
*  Add validation of templates
*  Small changes for preperation for system tests
*  Update readme for new functionality
*  Added more test scenario's
*  Added puppet parser validate task for added checking
*  Ensure we don't add stuff when removing the module
*  Update python client define
*  Add ruby client define
*  Add tests for ruby clients and update python client tests

##0.1.3 ( Sep 06, 2013 )
*  Exec path settings has been updated to fix warnings ( PR #37, #47 )
*  Adding define to install python bindings ( PR #43 )
*  Scope deprecation fixes ( PR #41 )
*  feature to install plugins ( PR #40 )

##0.1.2 ( Jun 21, 2013 )
*  Update rake file to ignore the param inherit
*  Added missing documentation to the template define
*  Fix for template define to allow multiple templates ( PR #36 by Bruce Morrison )

##0.1.1 ( Jun 14, 2013 )
*  Add Oracle Linux to the OS list ( PR #25 by Stas Alekseev )
*  Respect the restart_on_change on the defaults ( PR #29 by Simon Effenberg )
*  Make sure the config can be empty as advertised in the readme
*  Remove dependency cycle when the defaults file is updated ( PR #31 by Bruce Morrison )
*  Enable retry on the template insert in case ES isn't started yet ( PR #32 by Bruce Morrison )
*  Update templates to avoid deprecation notice with Puppet 3.2.x
*  Update template define to avoid auto insert issue with ES
*  Update spec tests to reflect changes to template define

##0.1.0 ( May 09, 2013 )
*  Populate .gitignore ( PR #19 by Igor Galić )
*  Add ability to install initfile ( PR #20 by Justin Lambert )
*  Add ability to manage default file service parameters ( PR #21 by Mathieu Bornoz )
*  Providing complete containment of the module ( PR #24 by Brian Lalor )
*  Add ability to specify package version ( PR #25 by Justin Lambert )
*  Adding license file

##0.0.7 ( Mar 23, 2013 )
*  Ensure config directory is created and managed ( PR #13 by Martin Seener )
*  Dont backup package if it changes
*  Create explicit dependency on template directory ( PR #16 by Igor Galić )
*  Make the config directory variable ( PR #17 by Igor Galić and PR #18 by Vincent Janelle )
*  Fixing template define

##0.0.6 ( Mar 05, 2013 )
*  Fixing issue with configuration not printing out arrays
*  New feature to write the config hash shorter
*  Updated readme to reflect the new feature
*  Adding spec tests for config file generation

##0.0.5 ( Mar 03, 2013 )
*  Option to disable restart on config file change ( PR #10 by Chris Boulton )

##0.0.4 ( Mar 02, 2013 )
*  Fixed a major issue with the config template ( Issue #9 )

##0.0.3 ( Mar 02, 2013 )
*  Adding spec tests
*  Fixed init issue on Ubuntu ( Issue #6 by Marcus Furlong )
*  Fixed config template problem ( Issue #8 by surfchris )
*  New feature to manage templates

##0.0.2 ( Feb 16, 2013 )
*  Feature to supply a package instead of being dependent on the repository
*  Feature to install java in case one doesn't manage it externally
*  Adding RedHat and Amazon as Operating systems
*  fixed a typo - its a shard not a shared :) ( PR #5 by Martin Seener )

##0.0.1 ( Jan 13, 2013 )
*  Initial release of the module
