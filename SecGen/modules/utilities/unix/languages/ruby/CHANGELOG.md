## Release 1.0.0
### Summary
First major release. Brings it into the modern age with puppet 4, and into the future with archlinux.

### Changed
- Dropped puppet 3 compatibility
- Bumped stdlib lower bound to 4.13.1

### Added
- archlinux support

## Release 0.6.0
### Summary
This release includes support for Puppet 4 AIO, test fixes and cleanup.

#### Features
- Support Puppet v4 AIO

#### Bugfixes
- Fix bundler_package name for ubuntu
- Fix testing
- Update supported platforms
- Remove unused metadata
- Use community style

## Release 0.5.0
### Summary
This release includes several new OS support features/bugfixes and multiple updates to Gemfile, Rakefile and metadata.

#### Features
- Bundle options: Allow . char in filepath args
- Added FreeBSD 10 support
- Gemfile updated
- Rakefile updated to new syntax
- Pinned rake to v10 when using Ruby 1.8.7 as v11 drops support for it

#### Bugfixes
- Updated metadata summary
- Now requires ruby2.1-dev when installing on 2.1 Debian
- General typo fixes
- Readme updates and fixes
- Fixed issue were multiple gem sources generated an invalid yaml file
- Now uses ruby bundler on ubuntu < 14.04

##2014-11-18 - Release 0.4.0
###Summary
This release includes the ability to specify the `rake_provider`, improved default parameters for OSes, and updates to tests and docs.

####Features
- Add `rake_provider` parameter to `ruby::dev`
- Updated RHEL and Ubuntu parameters
- Test and documentation improvements

####Bugfixes
- Clean up lint errors
- Fix typo in README

##2014-09-16 - Release 0.3.0
###Summary
This release includes many new features and improvements, including better
handling for bundler and rake.

Special thanks to Aaron Hicks for his hard work improving this module!

####Features
- Added `$ruby_dev_gems` parameter to `ruby::dev`
- Added the following params to `ruby`
  - `$suppress_warnings`
  - `$set_system_default`
  - `$system_default_bin`
  - `$system_default_gem`
  - `$gem_integration`
  - `$gem_integration_package`
- Manage rake and bundler separately from core ruby packages with the addition
of ruby::bundle and ruby::rake
- Deprecated `$switch` in favor of `$set_system_default`
- Improved testing and documentation

####Bugfixes
- Fix package name to be 'bundler' instead of 'ruby-bundler' for Debian/Ubuntu
- Fix package list defaults for RHEL5 and RHEL6
- Fix package logic for trusty

##2014-07-15 - Release 0.2.1
###Summary
This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

##2014-06-03 - Version 0.2.0
###Summary
This work adds the ability to manage the gemrc globally, as well as adds in
Ubuntu 14.04 support.  There was a fair amount of under the hood changes to
improve the module and it's testing.

####Features
- `ruby::gemrc`: A class to allow you to configure the global gemrc file.
- `ruby::dev`: A class for configurating ruby development specific things. 
- Rework the readme, tests, and rake tasks.
- Remove augeas packages.
- Add Ubuntu 14.04 support.

####Bugfixes
- Fix for selecting the right package name when using versions.
- Ruby-switch is gone from Ubuntu 14.04 onwards.
- Fixes to ruby-switch in general.

##2013-10-09 - Version 0.1.1
###Summary
Tiny fix to the metadata.json.

####Bugfixes
- metadata.json.

##2013-10-08 - Version 0.1.0
###Summary
Release an updated version of this. Highlights include OpenSUSE and general
spring cleaning done by our wonderful community members!

####Features
- OpenSUSE support
- Allow `rubygems_package` override.
- Add gemhome fact.
- Add ri package.

####Bugfixes
- Lint fixes.
- Remove virtual irb package.
- Update dev packages for Ubuntu/Debian
