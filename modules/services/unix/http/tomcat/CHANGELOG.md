## Supported Release 1.7.0
### Summary
This release adds support for internationalization of the module. It also contains Japanese translations for the README, summary and description of the metadata.json and major cleanups in the README. Additional folders have been introduced called locales and readmes where translation files can be found. A number of features and bug fixes are also included in this release.

#### Features
- Addition of POT file for metadata translation for i18n.
- Readme update and edit in preparation for localization.
- Environment can now be passed through to staging, so we can set a proxy to download tomcat.
- Add optional `$type` parameter to globalnamingresources that allows the definition of the element to be used. Use "Environment" to set an environment.
- Allow the resource name to be overridden with a new `$resource_name` parameter.
- Added Ubuntu Xenial support to metadata.
- Bump in puppet-staging module dependancy for allowing newer versions.
- Ability to not manage catalina.properties.

#### Bugfixes
- (MODULES-4003) Adds a 'require => Tomcat::Install[$name]' to the ensure_resource function.
- (MODULES-4003) Removes logic that checks to see if catalina_base and catalina_home are the same.
- (MODULES-1986) Added newline to the inline template assigned to $_content.
- (MODULES-3224) Added mode attribute to concat resource that sets the executable bit for all permission levels.
- Fix for fixtures.yml, was pointing to nanliu-staging instead of puppet-staging.
- Fix duplicate resources in host/realm/valve.
- Fix faulty header and link in ToC.
- (MODULES-4528) Replace Puppet.version.to_f version comparison from spec_helper.rb.
- Puppet lint warning fix.
- (FM-6166) Updating tomcat tar mirror and test failure message.
- (FM-6166) Removing concat-fragment 'ensure'


## Supported Release 1.6.1
### Summary
This release removes an attempted bugfix made in 1.6.0 for working around strict
umasks. The previous change caused duplicate resource declarations when
downloading a tomcat tarball from `puppet://` or local paths. The umask bug
remains (it is actually present in staging, not tomcat).

#### Bugfixes
- Fix duplicate resource declarations when using local source paths

## Supported Release 1.6.0
### Summary
This release adds two new defines for managing environment variables and manager elements, enhances multi-instance multi-user support, allows valves to be nested in contexts, fixes an issue with installing directly to NFS mounted directories, fixes installation on systems with a strict root umask,

#### Features
- Add `tomcat::config::context::environment` define
- Add `tomcat::config::context::manager` define
- Add `owner` and `group` to `tomcat::config::server::tomcat_users`
- Add `parent_context` to `tomcat::config::server::valve`
- Add `manage_home` and `manage_base` to `tomcat` class
- Add `manage_home` to `tomcat::install`
- Add `manage_base` to `tomcat::instance`
- Add `doexport` (MODULES-3436), `user`, and `group` to `tomcat::setenv::entry`
- Change from `nanliu/staging` to `puppet/staging`
- Allow `role` to be set for user elements in `tomcat::config::server::tomcat_users`

#### Bugfixes
- Fix globalresource missing (MODULES-3353)
- Fix strict vars for `tomcat::config::server::service` (MODULES-3742)
- Work around duplicate user resources (PUP-5971)

## Supported Release 1.5.0
### Summary
General rewrite of the installation and instance management code, and better
service management. Plus a handful of new configuration defined types and actual
resource dependency ordering.

The primary improvement is that you may now use `tomcat::install` for installing
various versions of tomcat into various directories (`CATALINA_HOME`), then use
`tomcat::instance` to create instances from those installs (`CATALINA_BASE`).
Previously `tomcat::instance` treated both `CATALINA_HOME` and `CATALINA_BASE` as identical and thus only allowed a single tomcat instance per tomcat installation.

Additionally, `tomcat::service` allows `use_init => true, use_jsvc => true` to
create an init script for service management of source-based installs. And
`tomcat::instance` can declare a `tomcat::service` resource for your instance to
make life easier.

#### Features
- Added `tomcat::config::properties::property` define
- Added `tomcat::config::server::globalnamingresource` define
- Added `tomcat::config::context` define
- Added `tomcat::config::context::resource` define
- Added `tomcat::config::context::resourcelink` define
- Added `tomcat::install` define
- Added `tomcat::config::server::host::aliases` parameter
- Added `tomcat::service::user` parameter
- Added `tomcat::setenv::entry` parameters:
  - `catalina_home`
  - `addto`
- Added `tomcat::instance` parameters for multi-instance management:
  - `user`
  - `group`
  - `manage_user`
  - `manage_group`
  - `manage_service`
  - `java_home`
  - `use_jsvc`
  - `use_init`
- Added Debian 8 compatibility

#### Bugfixes
- Fixed conflating `CATALINA_BASE` with `CATALINA_HOME`
- Made `tomcat::config::server::connector` protocol default to `$name`
- Lots of additional validation
- Added resource dependency declaration (so no more `<-` `->` needed)
- Undeprecated `tomcat::setenv::entry::order` parameter

## Supported Release 1.4.1
### Summary

Small release for bug with multiple Realms in the same parent path.

#### Features
- Improved documentation for purging connectors.
- Improved documentation for purging realms.
- Added package_options to tomcat::instance

#### Bugfixes
- Fixed bug where multiple Realms in the same parent would corrupt data.
- Added work-around for Augeas bug when purging Realms.

## Supported Release 1.3.3
###Summary

Small release for support of newer PE versions. This increments the version of PE in the metadata.json file.

## 2015-08-11 - Supported Release 1.3.2
### Summary
This release fixes username quoting and metadata.

#### Bugfixes
- Allow username values that contain non-string characters like whitespace
- Validate $catalina\_base
- Correct pe/puppet compatibility metadata

## 2015-07-16 - Supported Release 1.3.1
### Summary
This release fixes metadata because it supports puppet 4.

## 2015-06-09 - Supported Release 1.3.0
### Summary

This is a feature release, with a couple of bugfixes and readme changes.

#### Features
- Update additional_attributes to support values with spaces
- Documentation changes
- Add a manifest for Context Containers in Tomcat configuration
- Manage User and Roles in Realms
- New manifests for context.xml configuration
- Added manifest for managing Realm elements in server.xml
- Ordering of setenv entries
- Adds parameter for enabling Tomcat service on boot
- Add ability to specify server_config location
- Allow configuration of location of server.xml

#### Bugfixes
- Make sure setenv entries have export
- Test improvements
- version pinning for acceptance tests

## 2014-11-11 - Supported Release 1.2.0
### Summary

This is primarily a feature release, with a couple of bugfixes for tests and metadata.

#### Features
- Add `install_from_source` parameter to class `tomcat`
- Add `purge_connectors` parameter to class `tomcat` and define `tomcat::server::connector`

#### Bugfixes
- Fix dependencies to remove missing dependency warnings with the PMT
- Use `curl -k` in the tests

## 2014-10-28 - Supported Release 1.1.0
### Summary

This release includes documentation and test updates, strict variable support, metadata bugs, and added support for multiple connectors with the same protocol.

### Features
- Strict variable support
- Support multiple connectors with the same protocol
- Update tests to not break when tomcat releases happen
- Update README based on QA feedback

### Bugfixes
- Update stdlib requirement to 4.2.0
- Fix illegal version range in metadata.json
- Fix typo in README

## 2014-09-04 - Supported Release 1.0.1
### Summary

This is a bugfix release.

### Bugfixes
- Fix typo in tomcat::instance
- Update acceptance tests for new tomcat releases

## 2014-08-27 - Supported Release 1.0.0
### Summary

This release has added support for installation from packages, improved WAR management, and updates to testing and documentation.

### Features
- Updated tomcat::setenv::entry to better support installations from package
- Added the ability to purge auto-exploded WAR directories when removing WARs. Defaults to purging these directories
- Added warnings for unused variables when installing from package
- Updated acceptance tests and nodesets
- Updated README

### Deprecations
- $tomcat::setenv::entry::base_path is being deprecated in favor of $tomcat::setenv::entry::config_file

## 2014-08-20 - Release 0.1.2
### Summary

This release adds compatibility information and updates the README with information on the requirement of augeas >= 1.0.0.

## 2014-08-14 - Release 0.1.1
### Summary

This is a bugfix release.

### Bugfixes
- Update 'warn' to correct 'warning' function.
- Update README for use_init.
- Test updates and fixes.

## 2014-08-06 - Release 0.1.0
### Summary

Initial release of the tomcat module.
