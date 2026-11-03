## 2.4.0
### Summary
This release uses the PDK convert functionality which in return makes the module PDK compliant. Also includes a clean up from Rubocop.

#### Changed
- 1.3.2 PDK convert has been applied [MODULES-6456](https://tickets.puppetlabs.com/browse/MODULES-6456)
- The modules has undergone a Rubocop cleanup.

#### Fixed
- $java_home for SLES 11.4 has been updated to the correct location.

## Supported Release [2.3.0]
### Summary
This release is in order to implement Rubocop changes into the module.

#### Added
- Several Modulesync changes have been made.
- Rubocop has been implemented in the module.
- CentOS 7 is now supported.
- Red Hat Enterprise Linux (RHEL) 7 is now supported.
- Ubuntu artful 1710 now supported.
- Bionic 1804 now supported.

## Supported Release [2.2.0]
### Summary
This release is a maintenance release that includes a roll up of minor changes.

#### Added
- Addition of Ubuntu for Oracle Java.
- Addition of Debian 9 in supported versions.
- Addition of OpenBSD case and use `realpath` rather than `readlink` in Java Default Home Facter fact.

#### Removed
- Removal of OpenBSD as a special case and deprecated `with_env` in Java Version Facter Facter fact.

## Supported Release 2.1.1
### Summary
This release is a maintenance release that includes a roll up of minor changes.

#### Added
- Basic Arch Linux, Cloud Linux and Ubuntu 17.04 compatibility.
- Metadata bump for Puppet 5.
- Search for matching line with java version.
- ([MODULES-4069](https://tickets.puppet.com/browse/MODULES-4069)) Fail when required params are not available in params.
- A test for java version when java not installed.
- Allow latest archive version as dependency.

#### Changed
- CONTRIBUTING.md document includes updates.
- Removal of Ubuntu 10.04 ad 12.04, Debian 6 in supported versions.

## Supported Release 2.1.0
### Summary
This release adds fixes to restore the ability to install Oracle Java. It also fixes the paths for the latest RHEL 7 1.7.0 and 1.8.0 OpenJDKs.

### Added
- java::oracle parameter `url`
- java::oracle parameter `url_hash`

### Fixed
- Let `java_default_home` fact work when /usr/bin/java does not exist
- Add puppet 4 parameter types
- Use `/usr/lib/jvm/java-1.x.0` symlinks for `java_home` defaults.

## Supported Release 2.0.0
### Summary

This is a major release including some bug fixes, new parameters, and general module updates.

**This release drops Puppet 3 support**

#### Added
- Debian Stretch, Yakkety Yak, Amazon Linux, Oracle Linux, Scientific Linux CERN compatibility
- `version_major` and `version_minor` parameters for specifying Java SE version to install
- `$JAVA_HOME` now set by the module on compatible systems. The `java_home` parameter is also provided for manual setting. [MODULES-2971](https://tickets.puppetlabs.com/browse/MODULES-2971)
- `proxy_server` and `proxy_type` for choosing a proxy server to get Java from

#### Changed
- Moved lower Puppet version requirement to 4.7.0

#### Fixed
- Module no longer downloads the Java archive on Puppet runs if Java is already installed.
- java_default_home fact is not always correct on oracle packages [MODULES-4050](https://tickets.puppetlabs.com/browse/MODULES-4050)
- Order of operations for archives [MODULES-4751](https://tickets.puppetlabs.com/browse/https://tickets.puppetlabs.com/browse/MODULES-4751)
- Increase Xmx setting for `java_version` fact [MODULES-4736](https://tickets.puppetlabs.com/browse/MODULES-4736)

## Supported Release 1.6.0
### Summary

Addition of a new supported OS, along with several other features and bugfixes.

#### Features
- Ubuntu 16.04 support.
- Addition example for installing Java 8.
- Update to newest modulesync_configs.
- Addition of RedHat for Oracle Java.

#### Bugfixes
- Custom archive type now given extract_path.
- Fix for rspec deprectation warnings.
- Typo fixes for readme.
- Fixed tests to run under strict variables.
- Updated Java package for SLES 11.4.

## Supported Release 1.5.0
### Summary

A release which has several support additions for different OSes. Also a couple of additional features and a few bug fixes.

#### Features
- Added Ubuntu 15.10 compatibility.
- Addition of two facts: java_libjvm_path and java_default_home.
- Added support for oracle-j2re1.8 and oracle-j2sdk1.8.
- Adds FreeBSD Support.
- Exposed the Puppet package resources install_options parameter via a new class parameter named package_options.
- Debian 8 support.
- Add support for official Oracle Java SE jdk and jre packages for CentOS.
- Use java 8 as the default on RHEL > 7.0.

#### Bugfixes
- Updated fixtures.yml to use git instead of http for stdlib.
- Updates to current msync configs.
- Small README updates and syntax error fixes.

## Supported Release 1.4.3
### Summary

Small release for support of newer PE versions. This increments the version of PE in the metadata.json file.

## 2015-10-07 - Supported Release 1.4.2
### Summary
This release fixes the fact to not trigger java every time on OS X when it is not available.

#### Bugfixes
- Causes java\_version fact to not run `java` when java is not installed on OS X

## 2015-07-16 - Supported Release 1.4.1
### Summary
This release updates the metadata for the upcoming release of PE and update params for OEL to match metadata

#### Bugfixes:
- Add missing OEL to params

## 2015-07-07 - Supported Release 1.4.0
### Summary
This release adds several new features, bugfixes, documentation updates, and test improvements.

#### Features:
- Puppet 4 support and testing
- Adds support for several Operating Systems
  - Ubuntu 15.04
  - OpenBSD 5.6, 5.7
  - Fedora 20, 21, 22

#### Bugfixes:
- Fixes java_version fact to work on large systems. (MODULES-1749)
- Improves maintainability of java_version fact.
- Fixes java package names on Fedora 21+.
- Fixes java install problems on Puppet 3.7.5 - 3.8.1 (PUP-4520)
- Fixes create-java-alternatives commands on RedHat distros.
- Fixes bug with Debian systems missing java-common package.

## 2015-01-20 - Supported Release 1.3.0
### Summary
This release adds 3 new facts for determining Java version, adds RHEL alternatives support, adds utopic support, and fixes the flag for `update-java-alternatives` when installed from a headless pacakge.

#### Features
- Added RHEL support for alternatives
- New facts
  - java_major_version
  - java_patch_level
  - java_version
- Add support for utopic

#### Bugfixes
- Use `--jre-headless` in the `update-java-alternatives` command when installed from a `headless` package

## 2014-11-11 - Supported Version 1.2.0

### Summary:
This release adds SLES 12 support and is tested for Future Parser Support

#### Bugfixes:
- Several readme updates
- Testcase flexability increased

#### Features:
- Add SLES 12 support
- Future Parser tested
- Validated against PE 3.7  

## 2014-08-25 - Supported Version 1.1.2

### Summary:
This release begins the support coverage of the puppetlabs-java module.

### Bugfixes:
- Update java alternative values from deprecated names
- Readme updated
- Testing updated

## 2014-05-02 - Version 1.1.1

### Summary:

Add support for new versions of Debian and Ubuntu!

#### Features:
- Add support for Ubuntu Trusty (14.04)
- Add support for Debian Jessie (8.x)

## 2014-01-06 - Version 1.1.0

### Summary:

Primarily a release for Ubuntu users!

#### Features:
- Add support for Ubuntu Saucy (13.10)
- Add `java_home` parameter for centralized setting of JAVA_HOME.
- Add Scientific Linux

#### Bugfixes:
- Plus signs are valid in debian/ubuntu package names.

## 2013-08-01 - Version 1.0.1

Matthaus Owens <matthaus@puppetlabs.com>
* Update java packages for Fedora systems

## 2013-07-29 - Version 1.0.0

#### Detailed Changes

Krzysztof Suszyński <krzysztof.suszynski@coi.gov.pl>
* Adding support for Oracle Enterprise Linux

Peter Drake <pdrake@allplayers.com>
* Add support for natty

Robert Munteanu <rmuntean@adobe.com>
* Add support for OpenSUSE

Martin Jackson <martin@uncommonsense-uk.com>
* Added support Amazon Linux using facter >= 1.7.x

Gareth Rushgrove <gareth@morethanseven.net>
Brett Porter <brett@apache.org>
* Fixes for older versions of CentOS
* Improvements to module build and tests

Nathan R Valentine <nrvale0@gmail.com>
* Add support for Ubuntu quantal and raring

Sharif Nassar <sharif@mediatemple.net>
* Add support for Debian alternatives, and more than one JDK/JRE per platform.

## 2013-04-04 - Version 0.3.0
Reid Vandewiele <reid@puppetlabs.com> -
* Refactor, introduce params pattern

## 2012-11-15 - Version 0.2.0
Scott Schneider <sschneider@puppetlabs.com>
* Add Solaris support

## 2011-06-16 - Version 0.1.5
Jeff McCune <jeff@puppetlabs.com>
* Add Debian based distro (Lucid) support

## 2011-06-02 - Version 0.1.4
Jeff McCune <jeff@puppetlabs.com>
* Fix class composition ordering problems

## 2011-05-28 - Version 0.1.3
Jeff McCune <jeff@puppetlabs.com>
* Remove stages

## 2011-05-26 - Version 0.1.2
Jeff McCune <jeff@puppetlabs.com>
* Changes JRE/JDK selection class parameter to $distribution

## 2011-05-25 - Version 0.1.1
Jeff McCune <jeff@puppetlabs.com>
* Re-did versioning to follow semantic versioning
* Add validation of class parameters

## 2011-05-24 - Version 0.1.0
Jeff McCune <jeff@puppetlabs.com>
* Default to JDK version 6u25

## 2011-05-24 - Version 0.0.1
Jeff McCune <jeff@puppetlabs.com>
* Initial release

[2.3.0]:https://github.com/puppetlabs/puppetlabs-java/compare/2.2.0...2.3.0
[2.2.0]:https://github.com/puppetlabs/puppetlabs-java/compare/2.1.1...2.2.0
