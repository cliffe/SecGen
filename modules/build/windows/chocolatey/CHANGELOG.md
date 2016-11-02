## 2016-07-11 Release 1.2.6

- Fix - AutoUninstaller runs every time in 0.9.9.x [#134](https://github.com/chocolatey/puppet-chocolatey/issues/134)

## 2016-06-20 Release 1.2.5

- Support feature list changes in v0.9.10+ [#133](https://github.com/chocolatey/puppet-chocolatey/issues/133)
- Fix - Chocolatey fails to install in PowerShell v2 with PowerShell Module 1.x [#128](https://github.com/chocolatey/puppet-chocolatey/issues/128)

## 2016-06-04 Release 1.2.4

- Compatibility with puppetlabs-powershell 2.x [#125](https://github.com/chocolatey/puppet-chocolatey/issues/125).

## 2016-05-06 Release 1.2.3

- Do not call choco with --debug --verbose by default [#100](https://github.com/chocolatey/puppet-chocolatey/issues/100).
- Announce [Chocolatey for Business](https://chocolatey.org/compare) in ReadMe.

## 2016-05-06 Release 1.2.3

- Do not call choco with --debug --verbose by default [#100](https://github.com/chocolatey/puppet-chocolatey/issues/100).
- Announce Chocolatey for Business in ReadMe.

## 2016-04-06 Release 1.2.2

- Fix: puppet apply works again [#105](https://github.com/chocolatey/puppet-chocolatey/issues/105).
- `$::chocolateyversion` fact is optional - see [#110](https://github.com/chocolatey/puppet-chocolatey/issues/110)
- Fix: Implement PowerShell Redirection Fix for Windows 2008 / PowerShell v2 - see [#119](https://github.com/chocolatey/puppet-chocolatey/issues/119)


## 2015-12-08 Release 1.2.1
- Small release for support of newer PE versions.

##2015-11-03 Release 1.2.0
- Implement holdable ([#95](https://github.com/chocolatey/puppet-chocolatey/issues/95))
- Fix - Use install unless version specified in install ([#71](https://github.com/chocolatey/puppet-chocolatey/issues/71))

## 2015-10-02 Release 1.1.2
- Ensure 0.9.9.9 compatibility ([#94](https://github.com/chocolatey/puppet-chocolatey/issues/94))
- Fix - Mixed stale environment variables of existing choco install causing issues ([#86](https://github.com/chocolatey/puppet-chocolatey/issues/86))
- Upgrade From POSH Version of Chocolatey Fails from Puppet ([#60](https://github.com/chocolatey/puppet-chocolatey/issues/60))

## 2015-09-25 Release 1.1.1
- Add log_output for chocolatey bootstrap installer script
- Ensure bootstrap enforces chocolatey.nupkg in libs folder
- Allow file location for installing nupkg file.

## 2015-09-09 Release 1.1.0
- Install Chocolatey itself / ensure Chocolatey is installed (PUP-1691)
- Adds custom facts for chocolateyversion and choco_install_path

## 2015-07-23 Release 1.0.2
- Fixes [#71](https://github.com/chocolatey/puppet-chocolatey/issues/71) - Allow `ensure => $version` to work with already installed packages

## 2015-07-01 Release 1.0.1
- Fixes [#66](https://github.com/chocolatey/puppet-chocolatey/issues/66) - Check for choco existence more comprehensively

## 2015-06-08 Release 1.0.0
- No change, bumping to 1.0.0

## 2015-05-22 Release 0.5.3
- Fix manifest issue
- Fix choco path issue
- Update ReadMe - fix/clarify how options with quotes need to be passed.

## 2015-04-23 Release 0.5.2
- Update ReadMe
- Add support for Windows 10.
- Fixes [#56](https://github.com/chocolatey/puppet-chocolatey/pull/56) - Avoiding puppet returning 2 instead of 0 when there are no changes to be done.

## 2015-03-31 Release 0.5.1
- Fixes [#54](https://github.com/chocolatey/puppet-chocolatey/issues/54) - Blocking: Linux masters throw error if module is present

## 2015-03-30 Release 0.5.0
- Provider enhancements
- Better docs
- Works with both compiled and powershell Chocolatey clients
- Fixes #50 - work with newer compiled Chocolatey client (0.9.9+)
- Fixes #43 - check for installed packages is case sensitive
- Fixes #18 - The OS handle's position is not what FileStream expected.
- Fixes #52 - Document best way to pass options with spaces (#15 also related)
- Fixes #26 - Document Chocolatey needs to be installed by other means
