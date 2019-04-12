Changelog
=========

## Unreleased
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v3.2.2...HEAD)

## [v3.2.2](https://github.com/pcfens/puppet-filebeat/tree/v3.2.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v3.2.1...v3.2.2)

- Don't add xpack configuration when it's undef [\#187](https://github.com/pcfens/puppet-filebeat/pull/187)
- Don't disallow using puppetlabs/apt 6.x (check their [changelog](https://forge.puppet.com/puppetlabs/apt/changelog#600-2018-08-24) as this release drops support for Puppet pre 4.7) [\#186](https://github.com/pcfens/puppet-filebeat/pull/186)
- Use the latest PDK

## [v3.2.1](https://github.com/pcfens/puppet-filebeat/tree/v3.2.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v3.2.0...v3.2.1)

- Fetch the suse repository signing key over https [\#176](https://github.com/pcfens/puppet-filebeat/issues/176)

## [v3.2.0](https://github.com/pcfens/puppet-filebeat/tree/v3.2.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v3.1.0...v3.2.0)

- Add support for xpack monitoring [\#172](https://github.com/pcfens/puppet-filebeat/pull/172)
- Add support for OpenBSD [\#173](https://github.com/pcfens/puppet-filebeat/pull/173)
- Set filebeat_version to false when filebeat isn't installed [\#175](https://github.com/pcfens/puppet-filebeat/pull/175)

## [v3.1.0](https://github.com/pcfens/puppet-filebeat/tree/v3.1.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v3.0.1...v3.1.0)

- Manage filebeat modules as an array [\#168](https://github.com/pcfens/puppet-filebeat/pull/168)

## [v3.0.1](https://github.com/pcfens/puppet-filebeat/tree/v3.0.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v3.0.0...v3.0.1)

- Fix array validation in prospector defined resource [\#166](https://github.com/pcfens/puppet-filebeat/pull/166)

## [v3.0.0](https://github.com/pcfens/puppet-filebeat/tree/v3.0.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v2.4.0...v3.0.0)

Potentially Breaking Change:
- Make filebeat 6 the default version.

Non-breaking changes:
- Allow setup entries in configuration [\#152](https://github.com/pcfens/puppet-filebeat/pull/152), [\#146](https://github.com/pcfens/puppet-filebeat/issues/146)
- Processors should be an array of hashes [\#157](https://github.com/pcfens/puppet-filebeat/pull/157), [\#156](https://github.com/pcfens/puppet-filebeat/issues/156)
- Validate URLs using stdlib [\#158](https://github.com/pcfens/puppet-filebeat/pull/158)
- Use external configuration setup for Filebeat 6+  [\#153](https://github.com/pcfens/puppet-filebeat/issues/153)
- Use version subcommand when determining version [\#159](https://github.com/pcfens/puppet-filebeat/issues/159)
- Add processors support to prospectors [\#162](https://github.com/pcfens/puppet-filebeat/pull/162)
- Update unsupported OS Family notice [\#161](https://github.com/pcfens/puppet-filebeat/pull/161)
- Use Puppet 4+ data types for prospectors [\#165](https://github.com/pcfens/puppet-filebeat/pull/165)
- Fix windows validation command [\#164](https://github.com/pcfens/puppet-filebeat/pull/164), [\#163](https://github.com/pcfens/puppet-filebeat/issues/163)

## [v2.4.0](https://github.com/pcfens/puppet-filebeat/tree/v2.4.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v2.3.0...v2.4.0)

- Add support for FreeBSD [\#130](https://github.com/pcfens/puppet-filebeat/pull/130)
- Add support for Archlinux [\#147](https://github.com/pcfens/puppet-filebeat/pull/147)

## [v2.3.0](https://github.com/pcfens/puppet-filebeat/tree/v2.3.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v2.2.0...v2.3.0)

- Add support for Filebeat 6 [\#141](https://github.com/pcfens/puppet-filebeat/pull/141)
- Add Support for hash.random in Kafka output [\#142](https://github.com/pcfens/puppet-filebeat/pull/142)

## [v2.2.0](https://github.com/pcfens/puppet-filebeat/tree/v2.2.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v2.1.0...v2.2.0)

- Support pipeline configurations in prospectors [\#134](https://github.com/pcfens/puppet-filebeat/pull/134)
- Fix regex for validating download URL [\#135](https://github.com/pcfens/puppet-filebeat/pull/135)
- Overhaul testing

## [v2.1.0](https://github.com/pcfens/puppet-filebeat/tree/v2.1.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v2.0.0...v2.1.0)

- Change beat_name configuration parameter to name [\#126](https://github.com/pcfens/puppet-filebeat/issues/126)
- Make configuration directory/file ownership configurable [\#127](https://github.com/pcfens/puppet-filebeat/issues/127)

## [v2.0.0](https://github.com/pcfens/puppet-filebeat/tree/v2.0.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v1.0.0...v2.0.0)

- Drop support for Puppet 3
- Drop support for Filebeat versions before 5
- Add support for Puppet 5
- Use a generic template by default
- Remove processor defined type (create it in the config template)
- Add a flag to disable validating the configuration (`disable_config_test`)

## [v1.0.0](https://github.com/pcfens/puppet-filebeat/tree/v1.0.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.12.1...v1.0.0)

- This is the last release with support for Filebeat versions prior to 5
- Last release with support for Puppet 3
- Add Logstash SSL support [\#121](https://github.com/pcfens/puppet-filebeat/pull/121)
- Add ES loadbalance support [\#119](https://github.com/pcfens/puppet-filebeat/pull/119)

The next major release will be a breaking release for anyone using processors.

## [v0.12.1](https://github.com/pcfens/puppet-filebeat/tree/v0.12.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.12.0...v0.12.1)

- Add support for SSL in Logstash [\#117](https://github.com/pcfens/puppet-filebeat/pull/117)

## [v0.12.0](https://github.com/pcfens/puppet-filebeat/tree/v0.12.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.11.2...v0.12.0)

Windows users: you may see a restart and replacement of your existing filebeat directory.
There's a very brief discussion of the change in the [pull request](https://github.com/pcfens/puppet-filebeat/pull/113#issuecomment-307628477)

- Support upgrades in Windows [\#113](https://github.com/pcfens/puppet-filebeat/pull/113)
- Add optional repo_priority parameter [\#110](https://github.com/pcfens/puppet-filebeat/pull/110)
- Update external dependencies, including pinning apt version

## [v0.11.2](https://github.com/pcfens/puppet-filebeat/tree/v0.11.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.11.1...v0.11.2)

- Explicitly support newer versions of the powershell modules [\#105](https://github.com/pcfens/puppet-filebeat/issues/105)
- Support kafka codec.format module [\#106](https://github.com/pcfens/puppet-filebeat/pull/106)
- The `add_locale` processor doesnt' require parameters [\#104](https://github.com/pcfens/puppet-filebeat/pull/104)

## [v0.11.1](https://github.com/pcfens/puppet-filebeat/tree/v0.11.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.11.0...v0.11.1)

- Restore puppet 3.x compatibility regression ([PUP-2523](https://tickets.puppetlabs.com/browse/PUP-2523))

## [v0.11.0](https://github.com/pcfens/puppet-filebeat/tree/v0.11.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.10.4...v0.11.0)

**Breaking Changes**
- Processors are managed by their own defined resource (slight syntax change) [\#85](https://github.com/pcfens/puppet-filebeat/pull/85)
- The registry file has likely moved because of an upstream change. Moving this file
  can cause problems (duplicate or missed log entries), so you may want to point it
  to your existing file (check in /.filebeat on Linux systems)

**Normal Enhancements/Bugfixes**
- Support proxy for windows file downloads [\#90](https://github.com/pcfens/puppet-filebeat/pull/90)
- Setting `package_ensure` to absent removes puppet managed files and removes the package
- Add support for index conditional output to elasticsearch [\#97](https://github.com/pcfens/puppet-filebeat/pull/97)
- Add support for a conditional pipeline for elasticsearch [\#98](https://github.com/pcfens/puppet-filebeat/pull/98)
- Template should check for nil instead of undef [\#63](https://github.com/pcfens/puppet-filebeat/issues/63)
- Support for the round_robin and group_events parameters in kafka outputs [\#100](https://github.com/pcfens/puppet-filebeat/pull/100)

## [v0.10.4](https://github.com/pcfens/puppet-filebeat/tree/v0.10.4)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.10.3...v0.10.4)

- Add output.console support to the config template [\#91](https://github.com/pcfens/puppet-filebeat/issues/91)
- Support puppet with strict variables enabled [\#92](https://github.com/pcfens/puppet-filebeat/issues/92)

## [v0.10.3](https://github.com/pcfens/puppet-filebeat/tree/v0.10.3)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.10.2...v0.10.3)

- Allow non-SSL downloads of windows filebeat zipfile [\#82](https://github.com/pcfens/puppet-filebeat/pull/82)
- Basic support of processors in puppet <4.x [\#79](https://github.com/pcfens/puppet-filebeat/issues/79) (See note above)
- Confine the filebeat_version fact in a way that works in Ruby 1.8.7 [\#88](https://github.com/pcfens/puppet-filebeat/pull/88)

## [v0.10.2](https://github.com/pcfens/puppet-filebeat/tree/v0.10.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.10.1...v0.10.2)

- Add close_older and force_close_files within prospector v5 [\#77](https://github.com/pcfens/puppet-filebeat/pull/77)

## [v0.10.1](https://github.com/pcfens/puppet-filebeat/tree/v0.10.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.10.0...v0.10.1)

- Support harvesting symlinks [\#74](https://github.com/pcfens/puppet-filebeat/pull/74)
- Fix windows config file validation command [\#75](https://github.com/pcfens/puppet-filebeat/issues/75)

## [v0.10.0](https://github.com/pcfens/puppet-filebeat/tree/v0.10.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.9.2...v0.10.0)

- Add support for JSON decoding [\#72](https://github.com/pcfens/puppet-filebeat/pull/72)

## [v0.9.2](https://github.com/pcfens/puppet-filebeat/tree/v0.9.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.9.1...v0.9.2)

- Add support for close_* and clean_* parameters in prospectors [\#70](https://github.com/pcfens/puppet-filebeat/pull/70)

## [v0.9.1](https://github.com/pcfens/puppet-filebeat/tree/v0.9.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.9.0...v0.9.1)

- Fix yaml syntax around filebeat processors [\#71](https://github.com/pcfens/puppet-filebeat/pull/71)

## [v0.9.0](https://github.com/pcfens/puppet-filebeat/tree/v0.9.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.7...v0.9.0)

- Add support for tags in prospectors [\#68](https://github.com/pcfens/puppet-filebeat/pull/68)
- Add support for filebeat processors [\#69](https://github.com/pcfens/puppet-filebeat/pull/69)
- Fix the `filebeat_version` fact in Windows [\#59](https://github.com/pcfens/puppet-filebeat/issues/59)
- Validate configuration files before notifying the filebeat service
- Update the Windows install URL to the latest version

## [v0.8.7](https://github.com/pcfens/puppet-filebeat/tree/v0.8.7)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.6...v0.8.7)

- Update windows URL to the latest 5.x release
- Remove nil values before rendering the template [\#65](https://github.com/pcfens/puppet-filebeat/pull/65)

## [v0.8.6](https://github.com/pcfens/puppet-filebeat/tree/v0.8.6)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.5...v0.8.6)

- Sort field keys [\#55](https://github.com/pcfens/puppet-filebeat/pull/55),
[\#57](https://github.com/pcfens/puppet-filebeat/issues/57)
- Refresh the filebeat service when packages are updated [\#56](https://github.com/pcfens/puppet-filebeat/issues/56)


## [v0.8.5](https://github.com/pcfens/puppet-filebeat/tree/v0.8.5)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.4...v0.8.5)

- Check the kafka partition hash before checking for sub-hashes [\#54](https://github.com/pcfens/puppet-filebeat/pull/54)

## [v0.8.4](https://github.com/pcfens/puppet-filebeat/tree/v0.8.4)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.3...v0.8.4)

- Fix regression: Add the SSL label to the filebeat 5 template. [\#53](https://github.com/pcfens/puppet-filebeat/pull/53)

## [v0.8.3](https://github.com/pcfens/puppet-filebeat/tree/v0.8.3)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.2...v0.8.3)

- Don't use a possibly undefined array's length to determine if it should be
  iterated over [\#52](https://github.com/pcfens/puppet-filebeat/pull/52)

## [v0.8.2](https://github.com/pcfens/puppet-filebeat/tree/v0.8.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.1...v0.8.2)

- Correctly set document type for v5 prospectors [\#51](https://github.com/pcfens/puppet-filebeat/pull/51)

## [v0.8.1](https://github.com/pcfens/puppet-filebeat/tree/v0.8.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.8.0...v0.8.1)

- Don't manage the apt-transport-https package on Debian systems [\#49](https://github.com/pcfens/puppet-filebeat/pull/49)
- undefined values shouldn't be rendered by the filebeat5 template [\#50](https://github.com/pcfens/puppet-filebeat/pull/50)

## [v0.8.0](https://github.com/pcfens/puppet-filebeat/tree/v0.8.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.7.4...v0.8.0)

**Enhancements**
- Add support for Filebeat v5.

If you use this module on a system with filebeat 1.x installed, and you keep your current parameters
nothing will change. Setting `major_version` to '5' will modify the configuration template and update
package repositories, but won't update the package itself. To update the package set the
`package_ensure` parameter to at least 5.0.0.

- Add a parameter `use_generic_template` that uses a more generic version of the configuration
  template. The generic template is more future proof (if types are correct), but looks
  very different than the example file.


## [v0.7.4](https://github.com/pcfens/puppet-filebeat/tree/v0.7.4)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.7.2...v0.7.4)

Version 0.7.3 was never released even though it is tagged.

- Fixed some testing issues that were caused by changes to external resources

**Fixed Bugs**
- Some redis configuration options were not generated as integers [\#38](https://github.com/pcfens/puppet-filebeat/issues/38)

## [v0.7.2](https://github.com/pcfens/puppet-filebeat/tree/v0.7.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.7.1...v0.7.2)

- Wrap regular expressions in single quotes [\#31](https://github.com/pcfens/puppet-filebeat/pull/31) and [\#35](https://github.com/pcfens/puppet-filebeat/pull/35)
- Use the default Windows temporary folder (C:\Windows\Temp) by default [\#33](https://github.com/pcfens/puppet-filebeat/pull/33)

## [v0.7.1](https://github.com/pcfens/puppet-filebeat/tree/v0.7.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.7.0...v0.7.1)

- Allow the config file to be written to an alternate location. Be sure and read limitations before you use this.

**Fixed Bugs**
- Add elasticsearch and logstash port setting to Ruby 1.8 template
  [\#29](https://github.com/pcfens/puppet-filebeat/issues/29)

## [v0.7.0](https://github.com/pcfens/puppet-filebeat/tree/v0.7.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.6.3...v0.7.0)

- Setting the `prospectors_merge` parameter to true will create prospectors across multiple hiera levels
  using `hiera_hash()` [\#25](https://github.com/pcfens/puppet-filebeat/pull/25)
- No longer manage the windows temp directory where the Filebeat download is kept. The assumption is made
  that the directory exists and is writable by puppet.
- Update the default windows download to Filebeat version 1.2.3
- Add redis output to the Ruby 1.8 template
- Wrap include_lines and exclude_lines array elements in quotes [\#28](https://github.com/pcfens/puppet-filebeat/issues/28)

**Fixed Bugs**
- SLES repository and metaparameters didn't match [\#25](https://github.com/pcfens/puppet-filebeat/pull/25)

## [v0.6.3](https://github.com/pcfens/puppet-filebeat/tree/v0.6.3)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.6.2...v0.6.3)

**Fixed Bugs**
- Spool size default should match upstream [\#24](https://github.com/pcfens/puppet-filebeat/pull/24)
- Repository names now match notification parameters Part of [\#25](https://github.com/pcfens/puppet-filebeat/pull/25)

## [v0.6.2](https://github.com/pcfens/puppet-filebeat/tree/v0.6.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.6.1...v0.6.2)

**Fixed Bugs**
- Fix the other certificate_key typo in Ruby 1.8 template
[\#23](https://github.com/pcfens/puppet-filebeat/issues/23)


## [v0.6.1](https://github.com/pcfens/puppet-filebeat/tree/v0.6.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.6.0...v0.6.1)

**Fixed Bugs**
- Fix typo in Ruby 1.8 template [\#23](https://github.com/pcfens/puppet-filebeat/issues/23)


## [v0.6.0](https://github.com/pcfens/puppet-filebeat/tree/v0.6.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.8...v0.6.0)

- Add the `close_older` parameter to support the option of the same name in filebeat 1.2.0
- Add support for the `publish_async` parameter.

**Fixed Bugs**
- Added limited, but improved support for Ruby versions pre-1.9.1 by fixing the hash sort issue
[\#20](https://github.com/pcfens/puppet-filebeat/issues/20)

## [v0.5.8](https://github.com/pcfens/puppet-filebeat/tree/v0.5.8)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.7...v0.5.8)

**Fixed Bugs**
- `doc_type` is now used in the documentation instead of the deprecated `log_type`
  [\#17](https://github.com/pcfens/puppet-filebeat/pull/17)
- RedHat based systems should be using the redhat service provider.
  [\#18](https://github.com/pcfens/puppet-filebeat/pull/18)


## [v0.5.7](https://github.com/pcfens/puppet-filebeat/tree/v0.5.7)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.6...v0.5.7)

**Fixed Bugs**
- Some configuration parameters should be rendered as integers, not strings
  [\#15](https://github.com/pcfens/puppet-filebeat/pull/15)


## [v0.5.6](https://github.com/pcfens/puppet-filebeat/tree/v0.5.6)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.5...v0.5.6)

**Fixed Bugs**
- Configuration files should use the `conf_template` parameter [\#14](https://github.com/pcfens/puppet-filebeat/pull/14)

## [v0.5.5](https://github.com/pcfens/puppet-filebeat/tree/v0.5.5)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.4...v0.5.5)

**Fixed Bugs**
- `rotate_every_kb` and `number_of_files` parameters in file outputs should be
  explicitly integers to keep filebeat happy. [\#13](https://github.com/pcfens/puppet-filebeat/issues/13)

## [v0.5.4](https://github.com/pcfens/puppet-filebeat/tree/v0.5.4)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.2...v0.5.4)

**Fixed Bugs**
- Fix template regression in v0.5.3

## [v0.5.2](https://github.com/pcfens/puppet-filebeat/tree/v0.5.2)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.1...v0.5.2)

- Use the anchor pattern instead of contain so that older versions of puppet
  are supported [\#12](https://github.com/pcfens/puppet-filebeat/pull/12)

## [v0.5.1](https://github.com/pcfens/puppet-filebeat/tree/v0.5.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.5.0...v0.5.1)

- Update metadata to reflect which versions of puppet are supported.

## [v0.5.0](https://github.com/pcfens/puppet-filebeat/tree/v0.5.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.4.1...v0.5.0)

- For prospectors, deprecate `log_type` in favor of `doc_type` to better
  match the actual configuration parameter. `document_type` is not used because
  it causes errors when running with a puppet master. `log_type` will be fully
  removed before module version 1.0.
  [\#9](https://github.com/pcfens/puppet-filebeat/issues/9)

**New Features**
- Add support for `exclude_files`, `exclude_lines`, `include_lines`, and `multiline`.
  Use of the new parameters requires a filebeat version >= 1.1
  ([\#10](https://github.com/pcfens/puppet-filebeat/issues/10), [\#11](https://github.com/pcfens/puppet-filebeat/issues/11))

## [v0.4.1](https://github.com/pcfens/puppet-filebeat/tree/v0.4.1)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.4.0...v0.4.1)

**Fixed Bugs**
- Fix links in documentation to match the updated documentation

**New Features**
- Change repository resource names to beats (e.g. apt::source['beats'], etc.),
  and only declare them if they haven't already been declared. This way we only
  have one module for all beats modules managed through puppet.

## [v0.4.0](https://github.com/pcfens/puppet-filebeat/tree/v0.4.0)
[Full Changelog](https://github.com/pcfens/puppet-filebeat/compare/v0.3.1...v0.4.0)

This is the first release that includes changelog. Since v0.3.1:

**Fixed Bugs**
- 'fields' parse error in prospector.yml template [\#7](https://github.com/pcfens/puppet-filebeat/pull/7)

**New Features**
- Windows support [\#3](https://github.com/pcfens/puppet-filebeat/pull/3)
  - Requires the [`puppetlabs/powershell`](https://forge.puppetlabs.com/puppetlabs/powershell)
  and [`lwf/remote_file`](https://forge.puppetlabs.com/lwf/remote_file) modules.
- Config file and folder permissions can be managed [\#8](https://github.com/pcfens/puppet-filebeat/pull/8)
