# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org).

## Supported Release 4.24.0
### Summary

This release includes a roll up of minor changes and a new feature which provides the ability to skip undef values `to_json_pretty()`.
We have also reverted a change that was previously made and resulted in breaking compatibility with Ruby 1.8.7.

#### Added
- Ability to skip undef values in `to_json_pretty()`.
- Fix type3x function in stdlib ([MODULES-6216](https://tickets.puppet.com/browse/MODULES-6216))

#### Changed
- Indentation for `sync.yml` was fixed.
- Updated type alias tests and dropped superfluous wrapper classes
- Revert to old ruby 1.X style of hash ([MODULES-6139](https://tickets.puppet.com/browse/MODULES-6139))
- `rubocop.yml` not managed by msync ([MODULES-6201](https://tickets.puppet.com/browse/MODULES-6201))

## Supported Release 4.23.0
### Summary

This release is in order to implement Rubocop changes throughout the module.

#### Added
- Standard and translated readme's have been updated.
- Rubocop has been implemented in the module and a wide variety of changes have been made to the code.
- Modulesync changes have been merged into the code.

#### Fixed
- Minor fix to the readme.

## Supported Release 4.22.0
### Summary

This is a clean release in preparation of putting the module through the rubocop process.

#### Added
- Support has been added for Debian 9
- 'Stdlib::Mode type' has been added to the module.
- A type for 'ensure' has been added to the service resources.
- A new function 'sprintf_hash' has been added to allow the use of named references.

#### Removed
- Support has been removed for: RedHat 4, CentOS 4, OracleLinux 4, Scientific 4, SLES 10 SP4, Windows Server 2003, Windows Server 2003 R2 and Windows 8.

#### Fixed
- The 'ruby_spec.rb' test file has been altered s that it properly checks results.
- Example syntax in 'file_line.rb' has been fixed.

## Supported Release 4.21.0
### Summary

This is a small feature release that includes a revamped, albeit backwards-compatible file_line type.

#### Added
- `replace_all_matches_not_matching_line` parameter in file_line
- additional tests and documentation for file_line

#### Removed
- duplicate spec test for absolute_path

#### Fixed
- Unixpath type to allow "/" as valid path
- file_line behavior that caused infinite appending of `line` to a file ([MODULES-5651](https://tickets.puppet.com/browse/MODULES-5651))

## Supported Release 4.20.0
### Summary

This release adds new functions and updated README translations.

#### Added
- `to_json`, `to_json_pretty`, and `to_yaml` functions
- new Japanese README translations

#### Fixed
- compatibility issue with older versions of Puppet and the `pw_hash` function ([MODULES-5546](https://tickets.puppet.com/browse/MODULES-5546))

#### Removed
- support for EOL platform Debian 6 (Squeeze)

## Supported Release 4.19.0
### Summary

This release adds new functions and better documentation/fixes for existing functions with a noteworthy fix for file_line.

#### Added
- Add validate_domain_name function
- Add the round function
- Add type for MAC address
- Add support for sensitive data type to pw_hash ([MODULES-4908](https://tickets.puppet.com/browse/MODULES-4908))
- Add new function, fact() (FACT-932)

#### Fixed
- Fixes for the file_line provider ([MODULES-5003](https://tickets.puppet.com/browse/MODULES-5003)) 
- Add documentation for email functions ([MODULES-5382](https://tickets.puppet.com/browse/MODULES-5382)) 
- unique function is deprecated for puppet version > 5. (FM-6239) 
- Fix headers in CHANGELOG.md so that headers render correctly
- ensure_packages, converge ensure values 'present' and 'installed'

#### Changed
- Removes listed support for EOL Ubuntu versions

## Supported Release 4.18.0
### Summary

Small release that reverts the Puppet version requirement lower bound to again include Puppet 2.7+ and bumps the upper bound to now include Puppet 5.

#### Fixed
- Reverts lower bound of Puppet requirement to 2.7.20

## Supported Release 4.17.1
### Summary

Small release to address a bug (PUP-7650). Also pushes the Puppet version compatibility to 4.7.0.

#### Bugfixes
- (MODULES-5095) Workaround for PUP-7650
- (FM-6197) Formatting fixes for file_line resource


## Supported Release 4.17.0
### Summary
This release adds support for internationalization. It also contains Japanese translations for the README, summary and description of the metadata.json and major cleanups in the README. Additional folders have been introduced called locales and readmes where translation files can be found. A number of features and bug fixes are also included in this release. It also adds a new function `glob()` for expanding file lists. Also works around an issue that appeared in puppet 4.6.0 involving types being declared multiple times.

#### Features
- Addition of POT file / folder structure for i18n.
- Addition of Internationalized READMEs.
- `glob()` function

### Fixed
- Occasional duplicate type definitions when using `defined_with_params()`
- `file_line` encoding issue on ruby 1.8 (unsupported)
- Huge readme refresh

## Supported Release 4.16.0
### Summary

This release sees a massive update to all unit tests to test UTF8 characters. There are also multiple cleanups in preparation for internationalization. Alongside this, improvements to ipv6 support, a new length function compatible with Puppet 4, and an update to path types. Also contains multiple bug fixes around functionality and tests.

#### Features
- Addition of coverage in all unit tests for functions, data and resource types for UTF8 for i18n.
- All strings within the readme and functions that are split over two lines have been combined in preparation for i18n parser/decorator.
- Improvement on the ipv6 support for type - Improves regex to catch some valid (but lesser known) ipv6 strings, mostly those which are a mix of ipv6 strings and embedded ipv6 numbers.
- Adds a new parameter `encoding` to allow non UTF-8 files to specify a file encoding. This prevents receiving the error message "invalid byte sequence in UTF-8" when special characters that are not UTF-8 encoded appear in the input stream, such as the copyright symbol.
- Addition of the new length function. Returns the length of a given string, array or hash. To eventually replace the deprecated size() function as can handle the new type functionality introduced in Puppet 4.
- Permit double slash in absolute/Unix path types.

#### Bugfixes
- Fix unsupported data type error with rspec-puppet master.
- Now allows test module metadata.json to be read by Puppet.
- Fix acceptance test failure "Hiera is not a class".
- Removal of unsupported platforms and future parser setting in acceptance tests.
- Regex for tuple checking has been loosened.
- Ensure_packages function - Now only tries to apply the resource if not defined.
- (MODULES-4528) Use versioncmp to check Puppet version for 4.10.x compat.
- Adds comments to warn for UTF8 incompatibility of the functions that may not be compatible with UTF8 with Ruby < 2.4.0.

## Supported Release 4.15.0
### Summary

This release introduces multiple new functions, a new fact and the addition of Ubuntu Xenial support. Also includes a bugfix and documentation update.

#### Features
- Addition of puppet_server fact to return agents server.
- Addition of a pry function.
- Addition of tests for ensure_resources.
- Addition of FQDN UUID generation function.
- Addition of Ubuntu Xenial to OS Support.

#### Bugfixes
- Ensure_packages now works with Ruby < 2.0.
- Updated the documentation of str2bool function.

## Supported Release 4.14.0
### Summary

Adds several new features and updates, especially around refining the deprecation and validate_legacy functions. Also includes a Gemfile update around an issue with parallel_tests dependancy for different versions of Ruby.

#### Features
- Deprecation function now uses puppet stacktrace if available.
- join_key_to_values function now handles array values. If values are arrays, multiple keys are added for each element.
- Updated Gemfile to deal with parallel_tests Ruby dependancy (MODULES-3983).
- Updated/Fixed ipv4 regex validator (MODULES-3980).
- Deprecation clarification added to README.

#### Bugfixes
- README typo fixes.
- Use .dup to duplicate classes for modification (MODULES-3829).
- Fixes spec failures that were caused by a change in the tested error message in validate_legacy_spec.
- Broken link to validate_legacy docs fixed.
- Updates deprecation tests to include future parser.

## Supported Release 4.13.1
### Summary

This bugfix release addresses the `undefined method 'optional_repeated_param'` error messages seen by users of puppet 3.7.

It also improves the user experience around function deprecations by emitting one warning per function(-name) instead of only one deprecation overall. This allows users to identify all deprecated functions used in one agent run, with less back-and-forth.

#### Bugfixes

* Emit deprecations warnings for each function, instead of once per process. (MODULES-3961)
* Use a universally available API for the v4 deprecation stubs of `is_*` and `validate_*`. (MODULES-3962)
* Make `getvar()` compatible to ruby 1.8.7. (MODULES-3969)
* Add v4 deprecation stubs for the `is_` counterparts of the deprecated functions to emit the deprecations warnings in all cases.


## Supported Release 4.13.0
### Summary

This version of stdlib deprecates a whole host of functions, and provides stepping stones to move to Puppet 4 type validations. Be sure to check out the new `deprecation()` and `validate_legacy()` functions to migrate off the deprecated v3-style data validations.

Many thanks to all community contributors: bob, Dmitry Ilyin, Dominic Cleal, Joris, Joseph Yaworski, Loic Antoine-Gombeaud, Maksym Melnychok, Michiel Brandenburg, Nate Potter, Romain Tartière, Stephen Benjamin, and Steve Moore, as well as anyone contributing in the code review process and by submitting issues.

Special thanks to [Voxpupuli's](https://voxpupuli.org/) Igor Galić for donating the puppet-tea types to kickstart this part of stdlib.


#### Deprecations
* `validate_absolute_path`, `validate_array`, `validate_bool`, `validate_hash`, `validate_integer`, `validate_ip_address`, `validate_ipv4_address`, `validate_ipv6_address`, `validate_numeric`, `validate_re`, `validate_slength`, `validate_string`, and their `is_` counter parts are now deprecated on Puppet 4. See the `validate_legacy()` description in the README for help on migrating away from those functions.
* The `dig` function is provided by core puppet since 4.5.0 with slightly different calling convention. The stdlib version can still be accessed as `dig44` for now.


#### Features
* Add Puppet 4 data types for Unix, and Windows paths, and URLs.
* Add `deprecation` function to warn users of functionality that will be removed soon.
* Add `validate_legacy` function to help with migrating to Puppet 4 data types.

* Add `any2bool` function, a combination of of `string2bool` and `num2bool`.
* Add `delete_regex` function to delete array elements matching a regular expression.
* Add `puppet_environmentpath` fact to expose the `environmentpath` setting.
* Add `regexpescape` function to safely insert arbitrary strings into regular expressions.
* Add `shell_escape`, `shell_join`, and `shell_split` functions for safer working with shell scripts..

* The `delete` function now also accepts regular expressions as search term.
* The `loadyaml` function now accepts a default value, which is returned when there is an error loading the file.

#### Bugfixes
* Fix `file_line.match_for_absence` implementation and description to actually work. (MODULES-3590)
* Fix `getparam` so that it can now also return `false`. (MODULES-3933)
* Fix the fixture setup for testing and adjust `load_module_metadata` and `loadjson` tests.
* Fix `defined_with_params` to handle `undef` correctly on all puppet versions. (PUP-6422, MODULES-3543)
* Fix `file_line.path` validation to use puppet's built in `absolute_path?` matcher.

#### Minor Improvements
* README changes: improved descriptions of `deep_merge`, `delete`, `ensure_packages`, `file_line.after`, `range`, and `validate_numeric`.
* The `getvar` function now returns nil in all situations where the variable is not found.
* Update the `dig44` function with better `undef`, `nil`, and `false` handling.
* Better wording on `str2bool` argument validation error message.


### Known issues
* The `validate_legacy` function relies on internal APIs from Puppet 4.4.0 (PE 2016.1) onwards, and doesn't work on earlier versions.
* Puppet 4.5.0 (PE 2016.2) has a number of improvements around data types - especially error handling - that make working with them much nicer.

## Supported Release 4.12.0
### Summary

This release provides several new functions, bugfixes, modulesync changes, and some documentation updates.

#### Features
- Adds `clamp`. This function keeps values within a specified range.
- Adds `validate_x509_rsa_key_pair`. This function validates an x509 RSA certificate and key pair.
- Adds `dig`. This function performs a deep lookup in nested hashes or arrays.
- Extends the `base64` support to fit `rfc2045` and `rfc4648`.
- Adds `is_ipv6_address` and `is_ipv4_address`. These functions validate the specified ipv4 or ipv6 addresses.
- Adds `enclose_ipv6`. This function encloses IPv6 addresses in square brackets.
- Adds `ensure_resources`. This function takes a list of resources and creates them if they do not exist.
- Extends `suffix` to support applying a suffix to keys in a hash.
- Apply modulesync changes.
- Add validate_email_address function.

#### Bugfixes
- Fixes `fqdn_rand_string` tests, since Puppet 4.4.0 and later have a higher `fqdn_rand` ceiling.
- (MODULES-3152) Adds a check to `package_provider` to prevent failures if Gem is not installed.
- Fixes to README.md.
- Fixes catch StandardError rather than the gratuitous Exception
- Fixes file_line attribute validation.
- Fixes concat with Hash arguments.

## Supported Release 4.11.0
### Summary

Provides a validate_absolute_paths and Debian 8 support. There is a fix to the is_package_provider fact and a test improvement.

#### Features
-  Adds new parser called is_absolute_path
-  Supports Debian 8

#### Bugfixes
-  Allow package_provider fact to resolve on PE 3.x

#### Improvements
- ensures that the test passes independently of changes to rubygems for ensure_resource

## 2015-12-15 - Supported Release 4.10.0
### Summary

Includes the addition of several new functions and considerable improvements to the existing functions, tests and documentation. Includes some bug fixes which includes compatibility, test and fact issues.

#### Features
- Adds service_provider fact
- Adds is_a() function
- Adds package_provider fact
- Adds validate_ip_address function
- Adds seeded_rand function

#### Bugfixes
- Fix backwards compatibility from an improvement to the parseyaml function
- Renaming of load_module_metadata test to include _spec.rb
- Fix root_home fact on AIX 5.x, now '-c' rather than '-C'
- Fixed Gemfile to work with ruby 1.8.7

#### Improvements
- (MODULES-2462) Improvement of parseyaml function
- Improvement of str2bool function
- Improvement to readme
- Improvement of intersection function
- Improvement of validate_re function
- Improved speed on Facter resolution of service_provider
- empty function now handles numeric values
- Package_provider now prevents deprecation warning about the allow_virtual parameter
- load_module_metadata now succeeds on empty file
- Check added to ensure puppetversion value is not nil
- Improvement to bool2str to return a string of choice using boolean
- Improvement to naming convention in validate_ipv4_address function

## Supported Release 4.9.1
### Summary

Small release for support of newer PE versions. This increments the version of PE in the metadata.json file.

## 2015-09-08 - Supported Release 4.9.0
### Summary

This release adds new features including the new functions dos2unix, unix2dos, try_get_value, convert_base as well as other features and improvements.

#### Features
- (MODULES-2370) allow `match` parameter to influence `ensure => absent` behavior
- (MODULES-2410) Add new functions dos2unix and unix2dos
- (MODULE-2456) Modify union to accept more than two arrays
- Adds a convert_base function, which can convert numbers between bases
- Add a new function "try_get_value"

#### Bugfixes
- n/a

#### Improvements
- (MODULES-2478) Support root_home fact on AIX through "lsuser" command
- Acceptance test improvements
- Unit test improvements
- Readme improvements

## 2015-08-10 - Supported Release 4.8.0
### Summary
This release adds a function for reading metadata.json from any module, and expands file\_line's abilities.

#### Features
- New parameter `replace` on `file_line`
- New function `load_module_metadata()` to load metadata.json and return the content as a hash.
- Added hash support to `size()`

#### Bugfixes
- Fix various docs typos
- Fix `file_line` resource on puppet < 3.3

## 2015-06-22 - Supported Release 4.7.0
### Summary

Adds Solaris 12 support along with improved Puppet 4 support. There are significant test improvements, and some minor fixes.

#### Features
- Add support for Solaris 12

#### Bugfixes
- Fix for AIO Puppet 4
- Fix time for ruby 1.8.7
- Specify rspec-puppet version
- range() fix for typeerror and missing functionality
- Fix pw_hash() on JRuby < 1.7.17
- fqdn_rand_string: fix argument error message
- catch and rescue from looking up non-existent facts
- Use puppet_install_helper, for Puppet 4

#### Improvements
- Enforce support for Puppet 4 testing
- fqdn_rotate/fqdn_rand_string acceptance tests and implementation
- Simplify mac address regex
- validate_integer, validate_numeric: explicitely reject hashes in arrays
- Readme edits
- Remove all the pops stuff for rspec-puppet
- Sync via modulesync
- Add validate_slength optional 3rd arg
- Move tests directory to examples directory

## 2015-04-14 - Supported Release 4.6.0
### Summary

Adds functions and function argument abilities, and improves compatibility with the new puppet parser

#### Features
- MODULES-444: `concat()` can now take more than two arrays
- `basename()` added to have Ruby File.basename functionality
- `delete()` can now take an array of items to remove
- `prefix()` can now take a hash
- `upcase()` can now take a hash or array of upcaseable things
- `validate_absolute_path()` can now take an array
- `validate_cmd()` can now use % in the command to embed the validation file argument in the string
- MODULES-1473: deprecate `type()` function in favor of `type3x()`
- MODULES-1473: Add `type_of()` to give better type information on future parser
- Deprecate `private()` for `assert_private()` due to future parser
- Adds `ceiling()` to take the ceiling of a number
- Adds `fqdn_rand_string()` to generate random string based on fqdn
- Adds `pw_hash()` to generate password hashes
- Adds `validate_integer()`
- Adds `validate_numeric()` (like `validate_integer()` but also accepts floats)

#### Bugfixes
- Fix seeding of `fqdn_rotate()`
- `ensure_resource()` is more verbose on debug mode
- Stricter argument checking for `dirname()`
- Fix `is_domain_name()` to better match RFC
- Fix `uriescape()` when called with array
- Fix `file_line` resource when using the `after` attribute with `match`

## 2015-01-14 - Supported Release 4.5.1
### Summary

This release changes the temporary facter_dot_d cache locations outside of the /tmp directory due to a possible security vunerability. CVE-2015-1029

#### Bugfixes
- Facter_dot_d cache will now be stored in puppet libdir instead of tmp

## 2014-12-15 - Supported Release 4.5.0
### Summary

This release improves functionality of the member function and adds improved future parser support.

#### Features
- MODULES-1329: Update member() to allow the variable to be an array.
- Sync .travis.yml, Gemfile, Rakefile, and CONTRIBUTING.md via modulesync

#### Bugfixes
- Fix range() to work with numeric ranges with the future parser
- Accurately express SLES support in metadata.json (was missing 10SP4 and 12)
- Don't require `line` to match the `match` parameter

## 2014-11-10 - Supported Release 4.4.0
### Summary
This release has an overhauled readme, new private manifest function, and fixes many future parser bugs.

#### Features
- All new shiny README
- New `private()` function for making private manifests (yay!)

#### Bugfixes
- Code reuse in `bool2num()` and `zip()`
- Fix many functions to handle `generate()` no longer returning a string on new puppets
- `concat()` no longer modifies the first argument (whoops)
- strict variable support for `getvar()`, `member()`, `values_at`, and `has_interface_with()`
- `to_bytes()` handles PB and EB now
- Fix `tempfile` ruby requirement for `validate_augeas()` and `validate_cmd()`
- Fix `validate_cmd()` for windows
- Correct `validate_string()` docs to reflect non-handling of `undef`
- Fix `file_line` matching on older rubies


## 2014-07-15 - Supported Release 4.3.2
### Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

## 2014-07-14 - Supported Release 4.3.1
### Summary
This supported release updates the metadata.json to work around upgrade behavior of the PMT.

#### Bugfixes
- Synchronize metadata.json with PMT-generated metadata to pass checksums

## 2014-06-27 - Supported Release 4.3.0
### Summary
This release is the first supported release of the stdlib 4 series. It remains
backwards-compatible with the stdlib 3 series. It adds two new functions, one bugfix, and many testing updates.

#### Features
- New `bool2str()` function
- New `camelcase()` function

#### Bugfixes
- Fix `has_interface_with()` when interfaces fact is nil

## 2014-06-04 - Release 4.2.2
### Summary

This release adds PE3.3 support in the metadata and fixes a few tests.

## 2014-05-08 - Release - 4.2.1
### Summary
This release moves a stray symlink that can cause problems.

## 2014-05-08 - Release - 4.2.0
### Summary
This release adds many new functions and fixes, and continues to be backwards compatible with stdlib 3.x

#### Features
- New `base64()` function
- New `deep_merge()` function
- New `delete_undef_values()` function
- New `delete_values()` function
- New `difference()` function
- New `intersection()` function
- New `is_bool()` function
- New `pick_default()` function
- New `union()` function
- New `validate_ipv4_address` function
- New `validate_ipv6_address` function
- Update `ensure_packages()` to take an option hash as a second parameter.
- Update `range()` to take an optional third argument for range step
- Update `validate_slength()` to take an optional third argument for minimum length
- Update `file_line` resource to take `after` and `multiple` attributes

#### Bugfixes
- Correct `is_string`, `is_domain_name`, `is_array`, `is_float`, and `is_function_available` for parsing odd types such as bools and hashes.
- Allow facts.d facts to contain `=` in the value
- Fix `root_home` fact on darwin systems
- Fix `concat()` to work with a second non-array argument
- Fix `floor()` to work with integer strings
- Fix `is_integer()` to return true if passed integer strings
- Fix `is_numeric()` to return true if passed integer strings
- Fix `merge()` to work with empty strings
- Fix `pick()` to raise the correct error type
- Fix `uriescape()` to use the default URI.escape list
- Add/update unit & acceptance tests.


## 2014-03-04 - Supported Release - 3.2.1
### Summary
This is a supported release

#### Bugfixes
- Fixed `is_integer`/`is_float`/`is_numeric` for checking the value of arithmatic expressions.

#### Known bugs
* No known bugs

---

##### 2013-05-06 - Jeff McCune <jeff@puppetlabs.com> - 4.1.0

 * (#20582) Restore facter\_dot\_d to stdlib for PE users (3b887c8)
 * (maint) Update Gemfile with GEM\_FACTER\_VERSION (f44d535)

##### 2013-05-06 - Alex Cline <acline@us.ibm.com> - 4.1.0

 * Terser method of string to array conversion courtesy of ethooz. (d38bce0)

##### 2013-05-06 - Alex Cline <acline@us.ibm.com> 4.1.0

 * Refactor ensure\_resource expectations (b33cc24)

##### 2013-05-06 - Alex Cline <acline@us.ibm.com> 4.1.0

 * Changed str-to-array conversion and removed abbreviation. (de253db)

##### 2013-05-03 - Alex Cline <acline@us.ibm.com> 4.1.0

 * (#20548) Allow an array of resource titles to be passed into the ensure\_resource function (e08734a)

##### 2013-05-02 - Raphaël Pinson <raphael.pinson@camptocamp.com> - 4.1.0

 * Add a dirname function (2ba9e47)

##### 2013-04-29 - Mark Smith-Guerrero <msmithgu@gmail.com> - 4.1.0

 * (maint) Fix a small typo in hash() description (928036a)

##### 2013-04-12 - Jeff McCune <jeff@puppetlabs.com> - 4.0.2

 * Update user information in gemspec to make the intent of the Gem clear.

##### 2013-04-11 - Jeff McCune <jeff@puppetlabs.com> - 4.0.1

 * Fix README function documentation (ab3e30c)

##### 2013-04-11 - Jeff McCune <jeff@puppetlabs.com> - 4.0.0

 * stdlib 4.0 drops support with Puppet 2.7
 * stdlib 4.0 preserves support with Puppet 3

##### 2013-04-11 - Jeff McCune <jeff@puppetlabs.com> - 4.0.0

 * Add ability to use puppet from git via bundler (9c5805f)

##### 2013-04-10 - Jeff McCune <jeff@puppetlabs.com> - 4.0.0

 * (maint) Make stdlib usable as a Ruby GEM (e81a45e)

##### 2013-04-10 - Erik Dalén <dalen@spotify.com> - 4.0.0

 * Add a count function (f28550e)

##### 2013-03-31 - Amos Shapira <ashapira@atlassian.com> - 4.0.0

 * (#19998) Implement any2array (7a2fb80)

##### 2013-03-29 - Steve Huff <shuff@vecna.org> - 4.0.0

 * (19864) num2bool match fix (8d217f0)

##### 2013-03-20 - Erik Dalén <dalen@spotify.com> - 4.0.0

 * Allow comparisons of Numeric and number as String (ff5dd5d)

##### 2013-03-26 - Richard Soderberg <rsoderberg@mozilla.com> - 4.0.0

 * add suffix function to accompany the prefix function (88a93ac)

##### 2013-03-19 - Kristof Willaert <kristof.willaert@gmail.com> - 4.0.0

 * Add floor function implementation and unit tests (0527341)

##### 2012-04-03 - Eric Shamow <eric@puppetlabs.com> - 4.0.0

 * (#13610) Add is\_function\_available to stdlib (961dcab)

##### 2012-12-17 - Justin Lambert <jlambert@eml.cc> - 4.0.0

 * str2bool should return a boolean if called with a boolean (5d5a4d4)

##### 2012-10-23 - Uwe Stuehler <ustuehler@team.mobile.de> - 4.0.0

 * Fix number of arguments check in flatten() (e80207b)

##### 2013-03-11 - Jeff McCune <jeff@puppetlabs.com> - 4.0.0

 * Add contributing document (96e19d0)

##### 2013-03-04 - Raphaël Pinson <raphael.pinson@camptocamp.com> - 4.0.0

 * Add missing documentation for validate\_augeas and validate\_cmd to README.markdown (a1510a1)

##### 2013-02-14 - Joshua Hoblitt <jhoblitt@cpan.org> - 4.0.0

 * (#19272) Add has\_element() function (95cf3fe)

##### 2013-02-07 - Raphaël Pinson <raphael.pinson@camptocamp.com> - 4.0.0

 * validate\_cmd(): Use Puppet::Util::Execution.execute when available (69248df)

##### 2012-12-06 - Raphaël Pinson <raphink@gmail.com> - 4.0.0

 * Add validate\_augeas function (3a97c23)

##### 2012-12-06 - Raphaël Pinson <raphink@gmail.com> - 4.0.0

 * Add validate\_cmd function (6902cc5)

##### 2013-01-14 - David Schmitt <david@dasz.at> - 4.0.0

 * Add geppetto project definition (b3fc0a3)

##### 2013-01-02 - Jaka Hudoklin <jakahudoklin@gmail.com> - 4.0.0

 * Add getparam function to get defined resource parameters (20e0e07)

##### 2013-01-05 - Jeff McCune <jeff@puppetlabs.com> - 4.0.0

 * (maint) Add Travis CI Support (d082046)

##### 2012-12-04 - Jeff McCune <jeff@puppetlabs.com> - 4.0.0

 * Clarify that stdlib 3 supports Puppet 3 (3a6085f)

##### 2012-11-30 - Erik Dalén <dalen@spotify.com> - 4.0.0

 * maint: style guideline fixes (7742e5f)

##### 2012-11-09 - James Fryman <james@frymanet.com> - 4.0.0

 * puppet-lint cleanup (88acc52)

##### 2012-11-06 - Joe Julian <me@joejulian.name> - 4.0.0

 * Add function, uriescape, to URI.escape strings. Redmine #17459 (fd52b8d)

##### 2012-09-18 - Chad Metcalf <chad@wibidata.com> - 3.2.0

 * Add an ensure\_packages function. (8a8c09e)

##### 2012-11-23 - Erik Dalén <dalen@spotify.com> - 3.2.0

 * (#17797) min() and max() functions (9954133)

##### 2012-05-23 - Peter Meier <peter.meier@immerda.ch> - 3.2.0

 * (#14670) autorequire a file\_line resource's path (dfcee63)

##### 2012-11-19 - Joshua Harlan Lifton <lifton@puppetlabs.com> - 3.2.0

 * Add join\_keys\_to\_values function (ee0f2b3)

##### 2012-11-17 - Joshua Harlan Lifton <lifton@puppetlabs.com> - 3.2.0

 * Extend delete function for strings and hashes (7322e4d)

##### 2012-08-03 - Gary Larizza <gary@puppetlabs.com> - 3.2.0

 * Add the pick() function (ba6dd13)

##### 2012-03-20 - Wil Cooley <wcooley@pdx.edu> - 3.2.0

 * (#13974) Add predicate functions for interface facts (f819417)

##### 2012-11-06 - Joe Julian <me@joejulian.name> - 3.2.0

 * Add function, uriescape, to URI.escape strings. Redmine #17459 (70f4a0e)

##### 2012-10-25 - Jeff McCune <jeff@puppetlabs.com> - 3.1.1

 * (maint) Fix spec failures resulting from Facter API changes (97f836f)

##### 2012-10-23 - Matthaus Owens <matthaus@puppetlabs.com> - 3.1.0

 * Add PE facts to stdlib (cdf3b05)

##### 2012-08-16 - Jeff McCune <jeff@puppetlabs.com> - 3.0.1

 * Fix accidental removal of facts\_dot\_d.rb in 3.0.0 release

##### 2012-08-16 - Jeff McCune <jeff@puppetlabs.com> - 3.0.0

 * stdlib 3.0 drops support with Puppet 2.6
 * stdlib 3.0 preserves support with Puppet 2.7

##### 2012-08-07 - Dan Bode <dan@puppetlabs.com> - 3.0.0

 * Add function ensure\_resource and defined\_with\_params (ba789de)

##### 2012-07-10 - Hailee Kenney <hailee@puppetlabs.com> - 3.0.0

 * (#2157) Remove facter\_dot\_d for compatibility with external facts (f92574f)

##### 2012-04-10 - Chris Price <chris@puppetlabs.com> - 3.0.0

 * (#13693) moving logic from local spec\_helper to puppetlabs\_spec\_helper (85f96df)

##### 2012-10-25 - Jeff McCune <jeff@puppetlabs.com> - 2.5.1

 * (maint) Fix spec failures resulting from Facter API changes (97f836f)

##### 2012-10-23 - Matthaus Owens <matthaus@puppetlabs.com> - 2.5.0

 * Add PE facts to stdlib (cdf3b05)

##### 2012-08-15 - Dan Bode <dan@puppetlabs.com> - 2.5.0

 * Explicitly load functions used by ensure\_resource (9fc3063)

##### 2012-08-13 - Dan Bode <dan@puppetlabs.com> - 2.5.0

 * Add better docs about duplicate resource failures (97d327a)

##### 2012-08-13 - Dan Bode <dan@puppetlabs.com> - 2.5.0

 * Handle undef for parameter argument (4f8b133)

##### 2012-08-07 - Dan Bode <dan@puppetlabs.com> - 2.5.0

 * Add function ensure\_resource and defined\_with\_params (a0cb8cd)

##### 2012-08-20 - Jeff McCune <jeff@puppetlabs.com> - 2.5.0

 * Disable tests that fail on 2.6.x due to #15912 (c81496e)

##### 2012-08-20 - Jeff McCune <jeff@puppetlabs.com> - 2.5.0

 * (Maint) Fix mis-use of rvalue functions as statements (4492913)

##### 2012-08-20 - Jeff McCune <jeff@puppetlabs.com> - 2.5.0

 * Add .rspec file to repo root (88789e8)

##### 2012-06-07 - Chris Price <chris@puppetlabs.com> - 2.4.0

 * Add support for a 'match' parameter to file\_line (a06c0d8)

##### 2012-08-07 - Erik Dalén <dalen@spotify.com> - 2.4.0

 * (#15872) Add to\_bytes function (247b69c)

##### 2012-07-19 - Jeff McCune <jeff@puppetlabs.com> - 2.4.0

 * (Maint) use PuppetlabsSpec::PuppetInternals.scope (master) (deafe88)

##### 2012-07-10 - Hailee Kenney <hailee@puppetlabs.com> - 2.4.0

 * (#2157) Make facts\_dot\_d compatible with external facts (5fb0ddc)

##### 2012-03-16 - Steve Traylen <steve.traylen@cern.ch> - 2.4.0

 * (#13205) Rotate array/string randomley based on fqdn, fqdn\_rotate() (fef247b)

##### 2012-05-22 - Peter Meier <peter.meier@immerda.ch> - 2.3.3

 * fix regression in #11017 properly (f0a62c7)

##### 2012-05-10 - Jeff McCune <jeff@puppetlabs.com> - 2.3.3

 * Fix spec tests using the new spec\_helper (7d34333)

##### 2012-05-10 - Puppet Labs <support@puppetlabs.com> - 2.3.2

 * Make file\_line default to ensure => present (1373e70)
 * Memoize file\_line spec instance variables (20aacc5)
 * Fix spec tests using the new spec\_helper (1ebfa5d)
 * (#13595) initialize\_everything\_for\_tests couples modules Puppet ver (3222f35)
 * (#13439) Fix MRI 1.9 issue with spec\_helper (15c5fd1)
 * (#13439) Fix test failures with Puppet 2.6.x (665610b)
 * (#13439) refactor spec helper for compatibility with both puppet 2.7 and master (82194ca)
 * (#13494) Specify the behavior of zero padded strings (61891bb)

##### 2012-03-29 Puppet Labs <support@puppetlabs.com> - 2.1.3

* (#11607) Add Rakefile to enable spec testing
* (#12377) Avoid infinite loop when retrying require json

##### 2012-03-13 Puppet Labs <support@puppetlabs.com> - 2.3.1

* (#13091) Fix LoadError bug with puppet apply and puppet\_vardir fact

##### 2012-03-12 Puppet Labs <support@puppetlabs.com> - 2.3.0

* Add a large number of new Puppet functions
* Backwards compatibility preserved with 2.2.x

##### 2011-12-30 Puppet Labs <support@puppetlabs.com> - 2.2.1

* Documentation only release for the Forge

##### 2011-12-30 Puppet Labs <support@puppetlabs.com> - 2.1.2

* Documentation only release for PE 2.0.x

##### 2011-11-08 Puppet Labs <support@puppetlabs.com> - 2.2.0

* #10285 - Refactor json to use pson instead.
* Maint  - Add watchr autotest script
* Maint  - Make rspec tests work with Puppet 2.6.4
* #9859  - Add root\_home fact and tests

##### 2011-08-18 Puppet Labs <support@puppetlabs.com> - 2.1.1

* Change facts.d paths to match Facter 2.0 paths.
* /etc/facter/facts.d
* /etc/puppetlabs/facter/facts.d

##### 2011-08-17 Puppet Labs <support@puppetlabs.com> - 2.1.0

* Add R.I. Pienaar's facts.d custom facter fact
* facts defined in /etc/facts.d and /etc/puppetlabs/facts.d are
  automatically loaded now.

##### 2011-08-04 Puppet Labs <support@puppetlabs.com> - 2.0.0

* Rename whole\_line to file\_line
* This is an API change and as such motivating a 2.0.0 release according to semver.org.

##### 2011-08-04 Puppet Labs <support@puppetlabs.com> - 1.1.0

* Rename append\_line to whole\_line
* This is an API change and as such motivating a 1.1.0 release.

##### 2011-08-04 Puppet Labs <support@puppetlabs.com> - 1.0.0

* Initial stable release
* Add validate\_array and validate\_string functions
* Make merge() function work with Ruby 1.8.5
* Add hash merging function
* Add has\_key function
* Add loadyaml() function
* Add append\_line native

##### 2011-06-21 Jeff McCune <jeff@puppetlabs.com> - 0.1.7

* Add validate\_hash() and getvar() functions

##### 2011-06-15 Jeff McCune <jeff@puppetlabs.com> - 0.1.6

* Add anchor resource type to provide containment for composite classes

##### 2011-06-03 Jeff McCune <jeff@puppetlabs.com> - 0.1.5

* Add validate\_bool() function to stdlib

##### 0.1.4 2011-05-26 Jeff McCune <jeff@puppetlabs.com>

* Move most stages after main

##### 0.1.3 2011-05-25 Jeff McCune <jeff@puppetlabs.com>

* Add validate\_re() function

##### 0.1.2 2011-05-24 Jeff McCune <jeff@puppetlabs.com>

* Update to add annotated tag

##### 0.1.1 2011-05-24 Jeff McCune <jeff@puppetlabs.com>

* Add stdlib::stages class with a standard set of stages
