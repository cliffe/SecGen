## 2017-03-06 - Supported Release 1.1.4
### Summary

This release allows `HKEY_USER` registry keys to be managed, removes Windows Server 2003 support and applies a few minor bugfixes.

#### Features
- Allow keys and values in `HKEY_USERS` (`hku`) to be managed ([MODULES-3865](https://tickets.puppetlabs.com/browse/MODULES-3865))
- Remove Windows Server 2003 as a supported Operating System

#### Bugfixes
- Use double quotes so $key is interpolated ([FM-5236](https://tickets.puppetlabs.com/browse/FM-5236))
- Fix WOW64 Constant Definition ([MODULES-3195](https://tickets.puppetlabs.com/browse/MODULES-3195))
- Fix UNSET no longer available as a bareword ([MODULES-4331](https://tickets.puppetlabs.com/browse/MODULES-4331))

## 2015-12-08 - Supported Release 1.1.3
### Summary

Small release for support of newer PE versions.

## 2015-08-13 - Supported Release 1.1.2
### Summary

Fix critical bug when writing dword and qword values.

#### Bugfixes
- Fix the way we write dword and qword values [MODULES-2409](https://tickets.puppet.com/browse/MODULES-2409)
- changed byte conversion to use pack instead
- Added tests to catch scenario

## ~~2015-08-12 - Supported Release 1.1.1~~ - Deleted
### Summary

This release adds Puppet Enterprise 2015.2.0 to metadata

#### Features
- Testcase fixes
- Gemfile updates
- Updated the logic used to convert to byte arrays
- [MODULES-1921](https://tickets.puppet.com/browse/MODULES-1921) Fixes for:
-- Ruby registry writes corrupt string [PR # 93](https://github.com/puppetlabs/puppetlabs-registry/commit/0b99718bc7f2d48752aa976d1ba30e49803e97f1)

## 2015-03-24 - Supported Release 1.1.0
### Summary

This release adds support for Ruby 2.1.5 and issues with how Ruby reads back the registry in certain scenarios, see MODULES-1723 for more details.

#### Bugfixes
- Additional tests for purge_values
- Use wide character registry APIs
- Test Ruby Registry methods uncalled
- Introduce Ruby 2.1.5 failing tests


## 2014-08-25 - Supported Release 1.0.3
### Summary

This release adds support for native x64 ruby and puppet 3.7, and bugfixes issues with non-leading-zero binary values in registry keys.

## 2014-07-15 - Supported Release 1.0.2
### Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

## 2014-05-20 - Supported Release 1.0.1
#### Bugfixes
- Add zero padding to binary single character inputs

## 2014-03-04 - Supported Release 1.0.0
### Summary
This is a supported release.

#### Bugfixes
- Documentation updates
- Add license file

#### Known Bugs

* This module does not work if run as non-root. Please see [PE-2772](https://tickets.puppet.com/browse/PE-2772)

---

## 2013-08-01 - Release 0.1.2
### Summary:
This is a bugfix release that allows the module to work more reliably on x64
systems and on older systems such as 2003. Also fixes compilation errors due
to windows library loading on *nix masters.

#### Bugfixes:
- Refactored code into PuppetX namespace
- Fixed unhandled exception when loading windows code on *nix
- Updated README and manifest documentation
- Only manage redirected keys on 64 bit systems
- Only use /sysnative filesystem when available
- Use class accessor method instead of class instance variable
- Add geppetto project file

---

##### 2012-05-21 - 0.1.1 - Jeff McCune <jeff@puppet.com>

 * (#14517) Improve error handling when writing values (27223db)
 * (#14572) Fix management of the default value (f29bdc5)

##### 2012-05-16 - 0.1.0 - Jeff McCune <jeff@puppet.com>

 * (#14529) Add registry::value defined type (bf44208)

##### 2012-05-16 - Josh Cooper <josh+github@puppet.com>

 * Update README.markdown (2e9e45e)

##### 2012-05-16 - Josh Cooper <josh+github@puppet.com>

 * Update README.markdown (3904838)

##### 2012-05-15 - Josh Cooper <josh@puppet.com>

 * (Maint) Add type documentation (82205ad)

##### 2012-05-15 - Josh Cooper <josh+github@puppet.com>

 * Remove note about case-sensitivity, as that is no longer an issue (5440a0e)

##### 2012-05-15 - Jeff McCune <jeff@puppet.com>

 * (#14501) Fix autorequire case sensitivity (d5c12f0)

##### 2012-05-15 - Jeff McCune <jeff@puppet.com>

 * (maint) Remove RegistryKeyPath#{valuename,default?} methods (29db478)

##### 2012-05-14 - Jeff McCune <jeff@puppet.com>

 * Add acceptance tests for registry_value provider (6285f4a)

##### 2012-05-14 - Jeff McCune <jeff@puppet.com>

 * Eliminate RegistryPathBas#(default?,valuename) from base class (2234f96)

##### 2012-05-14 - Jeff McCune <jeff@puppet.com>

  * Memoize the filter_path method for performance (6139b7d)

##### 2012-05-11 - Jeff McCune <jeff@puppet.com>

 * Add Registry_key ensure => absent and purge_values coverage (cfd3789)

##### 2012-05-11 - Jeff McCune <jeff@puppet.com>

 * Fix cannot alias error when managing 32 and 64 bit versions of a key (3a2f260)

##### 2012-05-11 - Jeff McCune <jeff@puppet.com>

 * Add registry_key creation acceptance test (0e68654)

##### 2012-05-09 - Jeff McCune <jeff@puppet.com>

 * Add acceptance tests for the registry type (0a01b11)

##### 2012-05-08 - Jeff McCune <jeff@puppet.com>

 * Update type description strings (c69bf2d)

##### 2012-05-05 - Jeff McCune <jeff@puppet.com>

 * Separate the implementation of the type and provider (4e06ae5)

##### 2012-05-04 - Jeff McCune <jeff@puppet.com>

 * Add watchr script to automatically run tests (d5bce2d)

##### 2012-05-04 - Jeff McCune <jeff@puppet.com>

 * Add registry::compliance_example class to test compliance (0aa8a68)

##### 2012-05-03 - Jeff McCune <jeff@puppet.com>

 * Allow values associated with a registry key to be purged (27eaee3)

##### 2012-05-01 - Jeff McCune <jeff@puppet.com>

 * Update README with info about the types provided (b9b2d11)

##### 2012-04-30 - Jeff McCune <jeff@puppet.com>

 * Add registry::service defined resource example (57c5b59)

##### 2012-04-25 - Jeff McCune <jeff@puppet.com>

 * Add REG_MULTI_SZ (type => array) implementation (1b17c6f)

##### 2012-04-26 - Jeff McCune <jeff@puppet.com>

 * Work around #3947, #4248, #14073; load our utility code (a8d9402)

##### 2012-04-24 - Josh Cooper <josh@puppet.com>

 * Handle binary registry values (4353642)

##### 2012-04-24 - Josh Cooper <josh@puppet.com>

 * Fix puppet resource registry_key (f736cff)

##### 2012-04-23 - Josh Cooper <josh@puppet.com>

 * Registry keys and values were autorequiring all ancestors (0de7a0a)

##### 2012-04-24 - Jeff McCune <jeff@puppet.com>

 * Add examples of current registry key and value types (bb7e4f4)

##### 2012-04-23 - Josh Cooper <josh@puppet.com>

 * Add the ability to manage 32 and 64-bit keys/values (9a16a9b)

##### 2012-04-23 - Josh Cooper <josh@puppet.com>

 * Remove rspec deprecation warning (94063d5)

##### 2012-04-23 - Josh Cooper <josh@puppet.com>

 * Rename registry-specific util code (cd2aaa1)

##### 2012-04-20 - Josh Cooper <josh@puppet.com>

 * Fix autorequiring when using different root key forms (b7a1c39)

##### 2012-04-19 - Josh Cooper <josh@puppet.com>

 * Refactor key and value paths (74ebc80)

##### 2012-04-19 - Josh Cooper <josh@puppet.com>

 * Encode default-ness in the registry path (64bba67)

##### 2012-04-19 - Josh Cooper <josh@puppet.com>

 * Better validation and testing of key paths (d05d1e6)

##### 2012-04-19 - Josh Cooper <josh@puppet.com>

 * Maint: Remove more crlf line endings (e9f00c1)

##### 2012-04-19 - Josh Cooper <josh@puppet.com>

 * Maint: remove windows cr line endings (0138a1d)

##### 2012-04-18 - Josh Cooper <josh@puppet.com>

 * Rename `default` parameter (f45af86)

##### 2012-04-18 - Josh Cooper <josh@puppet.com>

 * Fix modifying existing registry values (d06be98)

##### 2012-04-18 - Josh Cooper <josh@puppet.com>

 * Remove debugging (8601e92)

##### 2012-04-18 - Josh Cooper <josh@puppet.com>

 * Always split the path (de66832)

##### 2012-04-18 - Josh Cooper <josh@puppet.com>

 * Initial registry key and value types and providers (065d43d)
