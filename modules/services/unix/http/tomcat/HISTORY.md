## [v5.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v5.0.0) (2021-02-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v4.3.0...v5.0.0)

### Changed

- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [\#431](https://github.com/puppetlabs/puppetlabs-tomcat/pull/431) ([carabasdaniel](https://github.com/carabasdaniel))

## [v4.3.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v4.3.0) (2020-12-14)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v4.2.0...v4.3.0)

### Added

- pdksync - \(feat\) - Add support for Puppet 7 [\#422](https://github.com/puppetlabs/puppetlabs-tomcat/pull/422) ([daianamezdrea](https://github.com/daianamezdrea))
- Refactor valve types [\#415](https://github.com/puppetlabs/puppetlabs-tomcat/pull/415) ([h-haaks](https://github.com/h-haaks))

### Fixed

- \(IAC-1236\) Adding SLES OSs for release\_checks [\#417](https://github.com/puppetlabs/puppetlabs-tomcat/pull/417) ([pmcmaw](https://github.com/pmcmaw))
- \(IAC-1214\) - Move SKIP\_GCC to test file [\#416](https://github.com/puppetlabs/puppetlabs-tomcat/pull/416) ([pmcmaw](https://github.com/pmcmaw))

## [v4.2.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v4.2.0) (2020-08-24)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v4.1.0...v4.2.0)

### Added

- pdksync - \(IAC-973\) - Update travis/appveyor to run on new default branch `main` [\#405](https://github.com/puppetlabs/puppetlabs-tomcat/pull/405) ([david22swan](https://github.com/david22swan))

### Fixed

- Increase puppetlabs/concat lower bound [\#404](https://github.com/puppetlabs/puppetlabs-tomcat/pull/404) ([bFekete](https://github.com/bFekete))

## [v4.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v4.1.0) (2020-07-07)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v4.0.0...v4.1.0)

### Added

- \(IAC-746\) - Add ubuntu 20.04 support [\#399](https://github.com/puppetlabs/puppetlabs-tomcat/pull/399) ([david22swan](https://github.com/david22swan))

### Fixed

- Allow override status\_command in case of use\_init [\#400](https://github.com/puppetlabs/puppetlabs-tomcat/pull/400) ([leroyguillaume](https://github.com/leroyguillaume))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v4.0.0) (2019-12-11)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v3.1.0...v4.0.0)

### Changed

- \(MAINT\) Make ensurable enums consistent [\#367](https://github.com/puppetlabs/puppetlabs-tomcat/pull/367) ([smortex](https://github.com/smortex))

### Added

- \(FM-8699\) - Addition of Support for CentOS 8 [\#374](https://github.com/puppetlabs/puppetlabs-tomcat/pull/374) ([david22swan](https://github.com/david22swan))
- Add Resources support [\#368](https://github.com/puppetlabs/puppetlabs-tomcat/pull/368) ([smortex](https://github.com/smortex))

### Fixed

- Completely remove tomcat::install\_from\_source [\#366](https://github.com/puppetlabs/puppetlabs-tomcat/pull/366) ([smortex](https://github.com/smortex))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v3.1.0) (2019-09-13)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/v3.0.0...v3.1.0)

### Added

- FM-8413 add support on Debian10 [\#361](https://github.com/puppetlabs/puppetlabs-tomcat/pull/361) ([lionce](https://github.com/lionce))
- \(FM-8232\) Convert to litmus [\#360](https://github.com/puppetlabs/puppetlabs-tomcat/pull/360) ([tphoney](https://github.com/tphoney))
- FM-8050 - add redhat8 support [\#354](https://github.com/puppetlabs/puppetlabs-tomcat/pull/354) ([lionce](https://github.com/lionce))

### Fixed

- add show diff to all augeas calls [\#322](https://github.com/puppetlabs/puppetlabs-tomcat/pull/322) ([johmicd](https://github.com/johmicd))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/v3.0.0) (2019-05-17)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.5.0...v3.0.0)

### Changed

- pdksync - \(MODULES-8444\) - Raise lower Puppet bound [\#347](https://github.com/puppetlabs/puppetlabs-tomcat/pull/347) ([david22swan](https://github.com/david22swan))

### Fixed

- \(MODULES-8817\) - Update to account for loss of SVN Tomcat archive [\#344](https://github.com/puppetlabs/puppetlabs-tomcat/pull/344) ([david22swan](https://github.com/david22swan))

## [2.5.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/2.5.0) (2019-01-29)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.4.0...2.5.0)

### Added

- \(MODULES-8147\) - Add SLES 15 support [\#328](https://github.com/puppetlabs/puppetlabs-tomcat/pull/328) ([eimlav](https://github.com/eimlav))
- Add context parameter type \(re-submit \#205\) [\#317](https://github.com/puppetlabs/puppetlabs-tomcat/pull/317) ([joshbeard](https://github.com/joshbeard))

### Fixed

- \(maint\) - Ubuntu 18.04 issues fix [\#333](https://github.com/puppetlabs/puppetlabs-tomcat/pull/333) ([david22swan](https://github.com/david22swan))
- pdksync - \(FM-7655\) Fix rubygems-update for ruby \< 2.3 [\#330](https://github.com/puppetlabs/puppetlabs-tomcat/pull/330) ([tphoney](https://github.com/tphoney))
- \[MODULES-7547\] Update globalnamingresource class, and add tests [\#305](https://github.com/puppetlabs/puppetlabs-tomcat/pull/305) ([jplindquist](https://github.com/jplindquist))

## [2.4.0](https://github.com/puppetlabs/puppetlabs-tomcat/tree/2.4.0) (2018-10-03)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.3.0...2.4.0)

### Added

- pdksync - \(FM-7392\) - Puppet 6 Testing Changes [\#321](https://github.com/puppetlabs/puppetlabs-tomcat/pull/321) ([pmcmaw](https://github.com/pmcmaw))
- pdksync - \(MODULES-7658\) use beaker4 in puppet-module-gems [\#315](https://github.com/puppetlabs/puppetlabs-tomcat/pull/315) ([tphoney](https://github.com/tphoney))
- \(FM-7239\) - Addition of support for Ubuntu 18.04 [\#306](https://github.com/puppetlabs/puppetlabs-tomcat/pull/306) ([david22swan](https://github.com/david22swan))
- adding wait\_timeout var for init [\#303](https://github.com/puppetlabs/puppetlabs-tomcat/pull/303) ([ackiejoe](https://github.com/ackiejoe))
- \[FM-7050\] Addition of support for Debian 9 on Tomcat [\#300](https://github.com/puppetlabs/puppetlabs-tomcat/pull/300) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - \(MODULES-6805\) metadata.json shows support for puppet 6 [\#319](https://github.com/puppetlabs/puppetlabs-tomcat/pull/319) ([tphoney](https://github.com/tphoney))
- pdksync - \(MODULES-7705\) - Bumping stdlib dependency from \< 5.0.0 to \< 6.0.0 [\#314](https://github.com/puppetlabs/puppetlabs-tomcat/pull/314) ([pmcmaw](https://github.com/pmcmaw))
- \(MODULES-7633\) - Update README Limitations section [\#307](https://github.com/puppetlabs/puppetlabs-tomcat/pull/307) ([eimlav](https://github.com/eimlav))
- \(maint\) Double retry count to workaround slow startups [\#301](https://github.com/puppetlabs/puppetlabs-tomcat/pull/301) ([hunner](https://github.com/hunner))
- \[FM-6967\] Removal of unsupported OS from tomcat [\#299](https://github.com/puppetlabs/puppetlabs-tomcat/pull/299) ([david22swan](https://github.com/david22swan))
- Add rspec retry gem to sync file [\#295](https://github.com/puppetlabs/puppetlabs-tomcat/pull/295) ([HelenCampbell](https://github.com/HelenCampbell))
- \#puppethack work if resource title contains spaces [\#287](https://github.com/puppetlabs/puppetlabs-tomcat/pull/287) ([rheijkoop](https://github.com/rheijkoop))

## 2.3.0
### Summary
A release that introduced the module to the PDK through conversion. Also a dependancy bump on the archive module along with a small fix.

### Changed
- puppet/archive compatibility version bumped from 2.0.0 to 3.0.0.
- Module is now converted with PDK 1.3.2.

### Fixed
- (MODULES-6626) Fixed the generated shell when using addto.

## Supported Release [2.2.0]
### Summary
A clean release made in order to Rubocop the module.

### Changed
- Gemfile updates.
- Module sync updates.
- All ruby files altered to match the current rubocop standards.

### Added
- Flexibility added to directory management in tomcat::instance.
- flexibility added to copy_from_home.
- Can now set status_command.

### Fixed
- Spaces now accounted for in context elements.
- tomcat::war now copies the war as root user and not as tomcat.
- Syntax error in $addto parameter in tomcat::setenv::entry fixed.
- Test fix for Tomcat 8.
- Fix added to the travis/sync file via modulesync.

### Removed
- Unsupported Debian 6.

## Supported Release [2.1.0]
### Summary
Addition of user and group to tomcat war file, along with a couple of docs updates and some old Ubuntu support dropped.

### Added
- User/group to tomcat war file.

### Fixed
- Update to README around SSL configuration.
- A couple of other simple readme fixes.
- Lint warnings.

### Removed
- Unsupported versions of Ubuntu 10.04, 12.04.

## Supported Release [2.0.0]
### Summary
This major release drops puppet 3, changes dependencies from staging to archive, and adds various "real world" configuration abilities.

### Changed
- Dependency puppet-staging (which is deprecated) removed in favor of puppet-archive
- Dropped compatibility with puppet 3.x series
- Remove `true`/`false` as valid values for all ensure attributes as they are ambiguous.

### Removed
- Deprecated `tomcat::setenv::entry` attribute `base_path`. Use `config_file` instead.
- Base `tomcat` class `install_from_source` parameter now does nothing. Use `tomcat::install` attribute `install_from_source` directly instead.
- No longer testing tomcat 6 as it is EOL and removed from the mirrors.
- `tomcat::install` attribute `environment` previously used for proxy settings. Use `proxy_server` and `proxy_type` instead.

### Deprecated
- `tomcat::instance` define parameters `install_from_source`, `source_url`, `source_strip_first_dir`, `package_ensure`, `package_name`, and `package_options` have been unofficially deprecated since 1.5.0 and are now formally deprecated. Please use `tomcat::install` instead and point any `tomcat::instance::catalina_home` there. See the readme for further examples.

### Added
- Compatibility with puppet 5.x series
- Puppet 4.x data type parameter validation.
- `tomcat::config::server::realm` Can manage multiple realms of identical class names.
- `tomcat::config::server::tomcat_users` Can be declared multiple times for the same element name.
- `tomcat::config::context::value` defined type.
- `tomcat::install` attributes `proxy_server` and `proxy_type` for installing behind a proxy.
- `tomcat::install` attribute `allow_insecure` for disabling https verification.
- `tomcat::war` ability to use context paths and versions with `war_name` attribute.
- `tomcat::war` ability to ignore HTTPS errors with `allow_insecure` attribute.

### Fixed
- Corrected documentation for all `attributes_to_remove` attributes.

## Supported Release [1.7.0]
### Summary
This release adds support for internationalization of the module. It also contains Japanese translations for the README, summary and description of the metadata.json and major cleanups in the README. Additional folders have been introduced called locales and readmes where translation files can be found. A number of features and bug fixes are also included in this release.

### Added
- Addition of POT file for metadata translation for i18n.
- Readme update and edit in preparation for localization.
- Environment can now be passed through to staging, so we can set a proxy to download tomcat.
- Add optional `$type` parameter to globalnamingresources that allows the definition of the element to be used. Use "Environment" to set an environment.
- Allow the resource name to be overridden with a new `$resource_name` parameter.
- Added Ubuntu Xenial support to metadata.
- Bump in puppet-staging module dependancy for allowing newer versions.
- Ability to not manage catalina.properties.

### Fixed
- (MODULES-4003) Adds a 'require => Tomcat::Install[$name]' to the ensure_resource function.
- (MODULES-4003) Removes logic that checks to see if catalina_base and catalina_home are the same.
- (MODULES-1986) Added newline to the inline template assigned to $\_content.
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

### Fixed
- Fix duplicate resource declarations when using local source paths

## Supported Release 1.6.0
### Summary
This release adds two new defines for managing environment variables and manager elements, enhances multi-instance multi-user support, allows valves to be nested in contexts, fixes an issue with installing directly to NFS mounted directories, fixes installation on systems with a strict root umask,

### Added
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

### Fixed
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

### Added
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

### Fixed
- Fixed conflating `CATALINA_BASE` with `CATALINA_HOME`
- Made `tomcat::config::server::connector` protocol default to `$name`
- Lots of additional validation
- Added resource dependency declaration (so no more `<-` `->` needed)
- Undeprecated `tomcat::setenv::entry::order` parameter

## Supported Release 1.4.1
### Summary

Small release for bug with multiple Realms in the same parent path.

### Added
- Improved documentation for purging connectors.
- Improved documentation for purging realms.
- Added package_options to tomcat::instance

### Fixed
- Fixed bug where multiple Realms in the same parent would corrupt data.
- Added work-around for Augeas bug when purging Realms.

## Supported Release 1.3.3
###Summary

Small release for support of newer PE versions. This increments the version of PE in the metadata.json file.

## 2015-08-11 - Supported Release 1.3.2
### Summary
This release fixes username quoting and metadata.

### Fixed
- Allow username values that contain non-string characters like whitespace
- Validate $catalina\_base
- Correct pe/puppet compatibility metadata

## 2015-07-16 - Supported Release 1.3.1
### Summary
This release fixes metadata because it supports puppet 4.

## 2015-06-09 - Supported Release 1.3.0
### Summary

This is a feature release, with a couple of bugfixes and readme changes.

### Added
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

### Fixed
- Make sure setenv entries have export
- Test improvements
- version pinning for acceptance tests

## 2014-11-11 - Supported Release 1.2.0
### Summary

This is primarily a feature release, with a couple of bugfixes for tests and metadata.

### Added
- Add `install_from_source` parameter to class `tomcat`
- Add `purge_connectors` parameter to class `tomcat` and define `tomcat::server::connector`

### Fixed
- Fix dependencies to remove missing dependency warnings with the PMT
- Use `curl -k` in the tests

## 2014-10-28 - Supported Release 1.1.0
### Summary

This release includes documentation and test updates, strict variable support, metadata bugs, and added support for multiple connectors with the same protocol.

### Added
- Strict variable support
- Support multiple connectors with the same protocol
- Update tests to not break when tomcat releases happen
- Update README based on QA feedback

### Fixed
- Update stdlib requirement to 4.2.0
- Fix illegal version range in metadata.json
- Fix typo in README

## 2014-09-04 - Supported Release 1.0.1
### Summary

This is a bugfix release.

### Fixed
- Fix typo in tomcat::instance
- Update acceptance tests for new tomcat releases

## 2014-08-27 - Supported Release 1.0.0
### Summary

This release has added support for installation from packages, improved WAR management, and updates to testing and documentation.

### Added
- Updated tomcat::setenv::entry to better support installations from package
- Added the ability to purge auto-exploded WAR directories when removing WARs. Defaults to purging these directories
- Added warnings for unused variables when installing from package
- Updated acceptance tests and nodesets
- Updated README

### Deprecated
- $tomcat::setenv::entry::base_path is being deprecated in favor of $tomcat::setenv::entry::config_file

## 2014-08-20 - Release 0.1.2
### Summary

This release adds compatibility information and updates the README with information on the requirement of augeas >= 1.0.0.

## 2014-08-14 - Release 0.1.1
### Summary

This is a bugfix release.

### Fixed
- Update 'warn' to correct 'warning' function.
- Update README for use_init.
- Test updates and fixes.

## 2014-08-06 - Release 0.1.0
### Summary

Initial release of the tomcat module.

[2.2.0]: https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/puppetlabs/puppetlabs-tomcat/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.7.0...2.0.0
[1.7.0]: https://github.com/puppetlabs/puppetlabs-tomcat/compare/1.6.1...1.7.0