# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v9.2.2](https://github.com/puppetlabs/puppetlabs-ntp/tree/v9.2.2) (2023-04-06)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v9.2.1...v9.2.2)

### Fixed

- \(CONT-404\) Address set-output deprecation [\#670](https://github.com/puppetlabs/puppetlabs-ntp/pull/670) ([LukasAud](https://github.com/LukasAud))

## [v9.2.1](https://github.com/puppetlabs/puppetlabs-ntp/tree/v9.2.1) (2023-02-03)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v9.2.0...v9.2.1)

### Fixed

- minimum value for poll interval should be 3, not 4 [\#665](https://github.com/puppetlabs/puppetlabs-ntp/pull/665) ([johnwarburton](https://github.com/johnwarburton))
- \(CONT-360\) Syntax update [\#663](https://github.com/puppetlabs/puppetlabs-ntp/pull/663) ([LukasAud](https://github.com/LukasAud))
- pdksync - \(CONT-189\) Remove support for RedHat6 / OracleLinux6 / Scientific6 [\#655](https://github.com/puppetlabs/puppetlabs-ntp/pull/655) ([david22swan](https://github.com/david22swan))
- pdksync - \(CONT-130\) - Dropping Support for Debian 9 [\#652](https://github.com/puppetlabs/puppetlabs-ntp/pull/652) ([jordanbreen28](https://github.com/jordanbreen28))

## [v9.2.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v9.2.0) (2022-08-30)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v9.1.1...v9.2.0)

### Added

- pdksync - \(GH-cat-11\) Certify Support for Ubuntu 22.04 [\#648](https://github.com/puppetlabs/puppetlabs-ntp/pull/648) ([david22swan](https://github.com/david22swan))

### Fixed

- SMF service instance change in Oracle Solaris 11.4 SRU 45.119.2 [\#647](https://github.com/puppetlabs/puppetlabs-ntp/pull/647) ([Kristijan](https://github.com/Kristijan))

## [v9.1.1](https://github.com/puppetlabs/puppetlabs-ntp/tree/v9.1.1) (2022-06-06)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v9.1.0...v9.1.1)

### Fixed

- pdksync - \(GH-iac-334\) Remove Support for Ubuntu 14.04/16.04 [\#639](https://github.com/puppetlabs/puppetlabs-ntp/pull/639) ([david22swan](https://github.com/david22swan))
- pdksync - \(IAC-1787\) Remove Support for CentOS 6 [\#637](https://github.com/puppetlabs/puppetlabs-ntp/pull/637) ([david22swan](https://github.com/david22swan))
- pdksync - \(IAC-1598\) - Remove Support for Debian 8 [\#635](https://github.com/puppetlabs/puppetlabs-ntp/pull/635) ([david22swan](https://github.com/david22swan))

## [v9.1.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v9.1.0) (2021-08-26)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v9.0.1...v9.1.0)

### Added

- pdksync - \(IAC-1709\) - Add Support for Debian 11 [\#632](https://github.com/puppetlabs/puppetlabs-ntp/pull/632) ([david22swan](https://github.com/david22swan))

### Fixed

- \(maint\) Allow stdlib 8.0.0 [\#633](https://github.com/puppetlabs/puppetlabs-ntp/pull/633) ([smortex](https://github.com/smortex))

## [v9.0.1](https://github.com/puppetlabs/puppetlabs-ntp/tree/v9.0.1) (2021-03-29)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v9.0.0...v9.0.1)

### Fixed

- Allow setting user and group permissions of the NTP logfile [\#615](https://github.com/puppetlabs/puppetlabs-ntp/pull/615) ([Kristijan](https://github.com/Kristijan))

## [v9.0.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v9.0.0) (2021-03-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v8.5.0...v9.0.0)

### Changed

- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [\#605](https://github.com/puppetlabs/puppetlabs-ntp/pull/605) ([carabasdaniel](https://github.com/carabasdaniel))

## [v8.5.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v8.5.0) (2020-12-16)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v8.4.0...v8.5.0)

### Added

- pdksync - \(feat\) - Add support for Puppet 7 [\#594](https://github.com/puppetlabs/puppetlabs-ntp/pull/594) ([daianamezdrea](https://github.com/daianamezdrea))
- \(MAINT\) Make mode for logfile configurable [\#590](https://github.com/puppetlabs/puppetlabs-ntp/pull/590) ([tmanninger](https://github.com/tmanninger))
- \(IAC-997\) Removal of inappropriate terminology [\#587](https://github.com/puppetlabs/puppetlabs-ntp/pull/587) ([pmcmaw](https://github.com/pmcmaw))

## [v8.4.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v8.4.0) (2020-09-11)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v8.3.0...v8.4.0)

### Added

- pdksync - \(IAC-973\) - Update travis/appveyor to run on new default branch `main` [\#579](https://github.com/puppetlabs/puppetlabs-ntp/pull/579) ([david22swan](https://github.com/david22swan))
- \(IAC-746\) - Add ubuntu 20.04 support [\#575](https://github.com/puppetlabs/puppetlabs-ntp/pull/575) ([david22swan](https://github.com/david22swan))

## [v8.3.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v8.3.0) (2020-04-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v8.2.0...v8.3.0)

### Added

- \(MAINT\) Add Solaris family Hiera data [\#554](https://github.com/puppetlabs/puppetlabs-ntp/pull/554) ([paescuj](https://github.com/paescuj))
- pdksync - \(FM-8581\) - Debian 10 added to travis and provision file refactored [\#552](https://github.com/puppetlabs/puppetlabs-ntp/pull/552) ([david22swan](https://github.com/david22swan))
- \(MODULES-10413\) Allow custom ntp user and daemon options  [\#551](https://github.com/puppetlabs/puppetlabs-ntp/pull/551) ([david22swan](https://github.com/david22swan))

### Fixed

- pdksync - \(FM-7655\) Fix rubygems-update for ruby \< 2.3 [\#495](https://github.com/puppetlabs/puppetlabs-ntp/pull/495) ([tphoney](https://github.com/tphoney))

## [v8.2.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v8.2.0) (2019-12-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v8.1.0...v8.2.0)

## [v8.1.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v8.1.0) (2019-09-23)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/v8.0.0...v8.1.0)

### Added

- \(FM-8188\) convert ntp to use litmus [\#517](https://github.com/puppetlabs/puppetlabs-ntp/pull/517) ([tphoney](https://github.com/tphoney))

### Fixed

- Fix disable\_dhclient [\#521](https://github.com/puppetlabs/puppetlabs-ntp/pull/521) ([raphink](https://github.com/raphink))

## [v8.0.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/v8.0.0) (2019-05-14)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/7.4.0...v8.0.0)

### Changed

- pdksync - \(MODULES-8444\) - Raise lower Puppet bound [\#510](https://github.com/puppetlabs/puppetlabs-ntp/pull/510) ([david22swan](https://github.com/david22swan))

### Fixed

- Service hasstatus and hasrestart atributes [\#499](https://github.com/puppetlabs/puppetlabs-ntp/pull/499) ([ffapitalle](https://github.com/ffapitalle))

## [7.4.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/7.4.0) (2019-02-01)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/7.3.0...7.4.0)

### Added

- FM-8407 - Add support on Debian 10 [\#528](https://github.com/puppetlabs/puppetlabs-ntp/pull/528) ([lionce](https://github.com/lionce))
- \(MODULES-8139\) - Add SLES 15 support [\#492](https://github.com/puppetlabs/puppetlabs-ntp/pull/492) ([eimlav](https://github.com/eimlav))
- \(MODULES-8098\) - Add logconfig option to config file [\#491](https://github.com/puppetlabs/puppetlabs-ntp/pull/491) ([eimlav](https://github.com/eimlav))

### Fixed

- \(FM-7719\) - Remove Amazon Linux and Arch Linux testing/support for ntp module [\#498](https://github.com/puppetlabs/puppetlabs-ntp/pull/498) ([david22swan](https://github.com/david22swan))

## [7.3.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/7.3.0) (2018-09-27)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/7.2.0...7.3.0)

### Added

- pdksync - \(MODULES-6805\) metadata.json shows support for puppet 6 [\#484](https://github.com/puppetlabs/puppetlabs-ntp/pull/484) ([tphoney](https://github.com/tphoney))
- Add burst param [\#476](https://github.com/puppetlabs/puppetlabs-ntp/pull/476) ([kobybr](https://github.com/kobybr))
- \(MODULES-7465\) Addition of support for Ubuntu 18.04 to NTP [\#475](https://github.com/puppetlabs/puppetlabs-ntp/pull/475) ([david22swan](https://github.com/david22swan))

## [7.2.0](https://github.com/puppetlabs/puppetlabs-ntp/tree/7.2.0) (2018-07-03)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-ntp/compare/7.1.1...7.2.0)

### Changed

- \(FM-6955\) Remove unsupported OS: F24, F25, Debian 7 [\#462](https://github.com/puppetlabs/puppetlabs-ntp/pull/462) ([david22swan](https://github.com/david22swan))

### Added

- Add SLES 15 hiera data [\#472](https://github.com/puppetlabs/puppetlabs-ntp/pull/472) ([mattiascockburn](https://github.com/mattiascockburn))
- \(FM-7038\) Add support for Debian 9 [\#470](https://github.com/puppetlabs/puppetlabs-ntp/pull/470) ([david22swan](https://github.com/david22swan))
- add tos\_orphan parameter [\#452](https://github.com/puppetlabs/puppetlabs-ntp/pull/452) ([disklord](https://github.com/disklord))

### Fixed

- \(MODULES-6363\) fix disabling dhclient on redhat-derivatives [\#439](https://github.com/puppetlabs/puppetlabs-ntp/pull/439) ([sudodevnull](https://github.com/sudodevnull))

## 7.1.1
### Summary
This release includes updated Japanese translations.

### Added
- Updating translations for readmes/README_ja_JP.md

## 7.1.0
### Summary
This release uses the PDK convert functionality which in return makes the module PDK compliant. It also includes one feature and a roll up of maintenance changes.

### Added
- PDK convert ntp ([MODULES-6326](https://tickets.puppet.com/browse/MODULES-6326)).
- Create parameter for slewalways to be exposed in the ntp.conf template.

### Fixed
- `is_virtual` fact is boolean and cant be given to str2bool.
- Don't use 'inherits' in config, install and service.
- Roll up of modulesync changes.
- Make documentation more readable.
- Fix up rubocop errors ([FM-6634](https://tickets.puppet.com/browse/FM-6634)).
- Strip data types out of puppet-strings comments.

## 7.0.0
### Summary
Hiera 5 only works with Puppet 4.9.4 and above, we have bumped the Puppet requirement for the module accordingly.

### Changed
- Update YAML to version 5 ([PR 428](https://github.com/puppetlabs/puppetlabs-ntp/pull/428))
- Updates the lower puppet version boundary to 4.9.4.

## 6.4.1
### Summary
This release reverts a PR that implements Hiera 5. Issues have been seen due to compatibility issues. The issues that have been seen are ([MODULES-5775](https://tickets.puppet.com/browse/MODULES-5775)) and ([MODULES-5780](https://tickets.puppet.com/browse/MODULES-5780)).

### Changed
- Reverts ([PR 394](https://github.com/puppetlabs/puppetlabs-ntp/pull/394))

## 6.4.0
### Summary
This release is to both update the modules code so that it matches the set standards and make it so that all future prs are checked by Rubocop before release.

#### Added
- Rubocop is now enabled.

#### Changed
- All ruby code within module has been altered to match standards.

## 6.3.0
### Summary
This is a feature release with some bugfixes and updated Japanese translations, too.

#### Added
- `enable_mode7` parameter (defaults to `false`)
- disable monitor availability while setting stat properties

#### Changed
- Lower bound of Puppet requirement from 4.5.0 to 4.7.0
- hiera.yaml to Hiera version 5 format

#### Removed
- Ubuntu 10.04 and 12.04, Debian 6, SLES 10 SP4, and Fedora 20-23 support from metadata.json (existing compatibility remains)

#### Fixed
- Path to driftfile on Suse ([MODULES-4941](https://tickets.puppet.com/browse/MODULES-4941))
- Whitespace issue in ntp.conf.epp with `tos`
- Permissions on keys file

## 6.2.0
### Summary
This is a small minor release that adds the `pool` parameter and revises some Japanese translations.

#### Added
- The `pool` parameter

#### Fixed
- Japanese translations for the README

## 6.1.0
### Summary

This release adds support for internationalization of the module. It also contains Japanese translations for the README, summary and description of the metadata.json and major cleanups in the README. Additional folders have been introduced called locales and readmes where translation files can be found. A number of features and bug fixes are also included in this release.

#### Features
- Addition of POT file for metadata translation for i18n.
- Multiple Gemfile updates for Ruby and Gems support.
- (MODULES-4225) Addition of Puppet strings to the ntp module.
- Implements beaker module install helper and cleanup spec helper acceptance.rb.
- (MODULES-4414) Allow NTP statistics if requested.
- (MODULES-4278) Addition of noselect feature.
- Addition of 'pool' parameter.
- Addition of Ubuntu Xenial Support.

#### Bugfixes
- Huge readme updates for adding tags to private classes, edits for localization and general cleanups.
- (MODULES-3397) Fix of the default Solaris settings.
- Changed 'service_ensure' data type to Enum.
- (MODULES-3396) remove superfluous empty lines in ntp.conf.
- (MODULES-4528) Replace Puppet.version.to_f version comparison from spec helper.
- Solaris data that was the wrong way round now fixed.

##s 5.0.0 and 6.0.0
### Summary

This double release adds new Puppet 4 features: data in modules, EPP templates, the $facts hash, and data types. The 5.0.0 release is fully backwards compatible to existing Puppet 4 configurations and provides you with [deprecation warnings](https://github.com/puppetlabs/puppetlabs-stdlib#deprecation) for every argument that will not work as expected with the final 6.0.0 release. See the [stdlib docs](https://github.com/puppetlabs/puppetlabs-stdlib#validate_legacy) for an in-depth discussion of this.

If you want to learn more about the new features used, have a look at the [NTP: A Puppet 4 language update](https://puppet.com/blog/ntp-puppet-4-language-update) blog post.

If you're still running Puppet 3, remain on the latest puppetlabs-ntp 4.x release for now, and see the documentation to [upgrade to Puppet 4](https://docs.puppet.com/puppet/4.6/reference/upgrade_major_pre.html).

### Changes

* [Data in modules](https://docs.puppet.com/puppet/latest/reference/lookup_quick_module.html#example-with-hiera): Moves all distribution and OS-dependent defaults into YAML files in `data/`, alleviating the need for a `params` class. Note that while this feature is currently still classed as experimental, the final implementation will support the changes here.
* [EPP templating](https://docs.puppet.com/puppet/latest/reference/lang_template_epp.html): Uses the Puppet language as a base for templates to create simpler and safer templates. No need for Ruby anymore! You can pass in EPP templates for the `ntp.conf` and `step-tickers` files using the new `config_epp` and `step_tickers_epp` parameters.
* [The $facts hash](https://docs.puppet.com/puppet/latest/reference/lang_facts_and_builtin_vars.html#the-factsfactname-hash): Makes facts visibly distinct from other variables for more readable and maintainable code. This helps eliminate confusion if you use a local variable whose name happens to match that of a common fact.
* [Data types for validation](https://docs.puppet.com/puppet/4.6/reference/lang_data.html): Helps you find and replace deprecated code in existing `validate_*` functions with stricter, more readable data type notation. First upgrade to the 5.0.0 release of this module, and address all deprecation warnings before upgrading to the final 6.0.0 release. Please see the [stdlib docs](https://github.com/puppetlabs/puppetlabs-stdlib#validate_legacy) for an in-depth discussion of this process.

## 4.2.0
### Summary

A large release with many new features. Multiple additions to parameters and work contributed to OS compatibility. Also includes several bug fixes, including clean ups of code.

#### Features
- Updated spec helper for more consistency
- Addition of config_dir variable
- Addition of puppet TOS options
- Added support for disabling kernel time discipline in ntp.conf
- Update Solaris support for newer Facter, and Amazon for < 1.7.0 facter
- Added disable_dhclient parameter
- Added OpenSUSE 13.2 compatibility
- Parameterize file mode of config file
- Enhanced the default configuration
- Debian 8 compatibility
- Enabled usage of the $ntpsigndsocket parameter
- Added parameter for interfaces to ignore
- Added support for the authprov parameter
- Additional work done for SLES 12 compatibility
- Addition of key template options/ key distribution

#### Bugfixes
- Fix for strict variables and tests
- Fixed test with preferred server and iburst enabled
- Added logfile parameter test
- Cleaned out unused cleanup code and utilities from spec_helper
- Deprecated ntp_dirname function
- No longer manages the keys_file parent when it would be inappropriate to do so
- Converted license string to SPDX format
- Removed ruby 1.8.7 and puppet 2.7 from travis-ci jobs

## 4.1.2
###Summary

Small release for support of newer PE versions. This increments the version of PE in the metadata.json file.

## 4.1.1
### Summary
This is a bugfix release to address security vulnerability CVE-2013-5211.

#### Bugfixes
- Changes the default behavior to disable monitoring as part of the solution for CVE-2013-5211.

## 2015-07-21 - Supported Release 4.1.0
### Summary
This release updates metadata to support new version of puppet enterprise, as well as new features, bugfixes, and test improvements.

#### Features
- Adds Solaris 10 support
- Adds Fedora 20, 21, 22 compatibility

#### Bugfixes
- Fix default configuration for Debian (MODULES-2087)
- Fix to ensure log file is created before service starts
- Fixes SLES params for SLES 10, 11, 12

## 2015-05-26 - Supported Release 4.0.0
### Summary
This release drops puppet 2.7 support and older stdlib support. It also includes the addition of 12 new properties, as well as numerous bug fixes and other improvements.

#### Backwards-incompatible changes
- UDLC (Undisciplined local clock) is now no longer enabled by default on anything (previous was enabled on non-virtual).
- Puppet 2.7 no longer supported
- puppetlabs-stdlib less than 4.5.0 no longer supported

#### Features
- Readme, Metadata, and Contribution documentation improvements
- Acceptance test improvements
- Added the `broadcastclient` property
- Added the `disable_auth` property
- Added `broadcastclient` property
- Added `disable_auth` property
- Added `fudge` property
- Added `peers` property
- Added `udlc_stratum` property
- Added `tinker` property
- Added `minpoll` property
- Added `maxpoll` property
- Added `stepout` property
- Added `leapfile` property

#### Bugfixes
- Removing equal sign as delimiter in ntp.conf for the logfile parameter.
- Add package_manage parameter, which is set to false by default on FreeBSD
- Fixed an issue with the `is_virtual` property
- Fixed debian wheezy issue
- Fix for Redhat to disable ntp restart due to dhcp ntp server updates

##2014-11-04 - Supported Release 3.3.0
###Summary

This release adds support for SLES 12.

####Features
- Added support for SLES 12

##2014-10-02 - Supported Release 3.2.1
###Summary

This is a bug-fix release addressing the security concerns of setting /etc/ntp to mode 0755 recursively.

####Bugfixes
- Do not recursively set ownership/mode of /etc/ntp

##2014-09-10 - Supported Release 3.2.0
###Summary

This is primarily a feature release. It adds a few new parameters to class `ntp`
and adds support for Solaris 11.

####Features
- Add the `$interfaces` parameter to `ntp`
- Add support for Solaris 10 and 11
- Synchronized files with modulesync
- Test updates
- Add the `$iburst_enable` parameter to `ntp`

####Bugfixes
- Fixes for strict variables
- Remove dependency on stdlib4

##2014-06-06 - Release 3.1.2
###Summary

This is a supported release.  This release fixes a manifest typo.

##2014-06-06 - Release 3.1.1
###Summary

This is a bugfix release to get around dependency issues in PMT 3.6.  This
version has a dependency on puppetlabs-stdlib >= 4 so PE3.2.x is no longer
supported.

####Bugfixes
- Remove deprecated Modulefile as it was causing duplicate dependencies with PMT.

##2014-05-14 - Release 3.1.0
###Summary

This release adds `disable_monitor` so you can disable the monitor functionality
of NTP, which was recently used in NTP amplification attacks.  It also adds
support for RHEL7 and Ubuntu 14.04.

####Features
- Add `disable_monitor`

####Bugfixes

#####Known Bugs
* No known bugs

##2014-04-09 - Supported Release 3.0.4
###Summary
This is a supported release.

The only functional change in this release is to split up the restrict
defaults to be per operating system so that we can provide safer defaults
for AIX, to resolve cases where IPv6 are disabled.

####Features
- Rework restrict defaults.

####Bugfixes
- Fix up a comment.
- Fix a test to work better on PE.

#####Known Bugs
* No known bugs

##2014-03-04 - Supported Release 3.0.3
###Summary
This is a supported release. Correct stdlib compatibility

####Bugfixes
- Remove `dirname()` call for correct stdlib compatibility.
- Improved tests

####Known Bugs
* No known bugs


## 2014-02-13 - Release 3.0.2
###Summary

No functional changes: Update the README and allow custom gem sources.

## 2013-12-17 - Release 3.0.1
### Summary

Work around a packaging bug with symlinks, no other functional changes.

## 2013-12-13 - Release 3.0.0
### Summary

Final release of 3.0, enjoy!


## 2013-10-14 - Version 3.0.0-rc1

###Summary

This release changes the behavior of restrict and adds AIX osfamily support.

####Backwards-incompatible Changes:

`restrict` no longer requires you to pass in parameters as:

restrict => [ 'restrict x', 'restrict y' ]

but just as:

restrict => [ 'x', 'y' ]

As the template now prefixes each line with restrict.

####Features
- Change the behavior of `restrict` so you no longer need the restrict
keyword.
- Add `udlc` parameter to enable undisciplined local clock regardless of the
machines status as a virtual machine.
- Add AIX support.

####Fixes
- Use class{} instead of including and then anchoring. (style)
- Extend Gentoo coverage to Facter 1.7.

---
##2013-09-05 - Version 2.0.1

###Summary

Correct the LICENSE file.

####Bugfixes
- Add in the appropriate year and name in LICENSE.


##2013-07-31 - Version 2.0.0

###Summary

The 2.0 release focuses on merging all the distro specific
templates into a single reusable template across all platforms.

To aid in that goal we now allow you to change the driftfile,
ntp keys, and perferred_servers.

####Backwards-incompatible changes

As all the distro specific templates have been removed and a
unified one created you may be missing functionality you
previously relied on.  Please test carefully before rolling
out globally.

Configuration directives that might possibly be affected:
- `filegen`
- `fudge` (for virtual machines)
- `keys`
- `logfile`
- `restrict`
- `restrictkey`
- `statistics`
- `trustedkey`

####Features:
- All templates merged into a single template.
- NTP Keys support added.
- Add preferred servers support.
- Parameters in `ntp` class:
  - `driftfile`: path for the ntp driftfile.
  - `keys_enable`: Enable NTP keys feature.
  - `keys_file`: Path for the NTP keys file.
  - `keys_trusted`: Which keys to trust.
  - `keys_controlkey`: Which key to use for the control key.
  - `keys_requestkey`: Which key to use for the request key.
  - `preferred_servers`: Array of servers to prefer.
  - `restrict`: Array of restriction options to apply.

---
###2013-07-15 - Version 1.0.1
####Bugfixes
- Fix deprecated warning in `autoupdate` parameter.
- Correctly quote is_virtual fact.


##2013-07-08 - Version 1.0.0
####Features
- Completely refactored to split across several classes.
- rspec-puppet tests rewritten to cover more options.
- rspec-system tests added.
- ArchLinux handled via osfamily instead of special casing.
- parameters in `ntp` class:
  - `autoupdate`: deprecated in favor of directly setting package_ensure.
  - `panic`: set to false if you wish to allow large clock skews.

---
##2011-11-10 Dan Bode <dan@puppetlabs.com> - 0.0.4
* Add Amazon Linux as a supported platform
* Add unit tests


##2011-06-16 Jeff McCune <jeff@puppetlabs.com> - 0.0.3
* Initial release under puppetlabs


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
