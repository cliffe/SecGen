##2016-11-17 - Supported Release 2.1.0
###Summary

Small release with bugs fixes and another speed improvement.

###Bug Fixes
- Support Windows 2016/WMF 5.1 using named pipes ([MODULES-3690](https://tickets.puppetlabs.com/browse/MODULES-3690))

###Documentation updates
- Document herestring ([DOC-2960](https://tickets.puppetlabs.com/browse/DOC-2960))

##2016-10-05 - Supported Release 2.0.3
###Summary

Small release with bugs fixes and another speed improvement.

###Bug Fixes
- Miscellaneous fixes which improve reliability
- Capture exit codes when executing external scripts ([MODULES-3399](https://tickets.puppetlabs.com/browse/MODULES-3399))
- Add ability to set current working directory ([MODULES-3565](https://tickets.puppetlabs.com/browse/MODULES-3565))
- Respect user specified timeout ([MODULES-3709](https://tickets.puppetlabs.com/browse/MODULES-3709))
- Improve handling of user code exceptions ([MODULES-3443](https://tickets.puppetlabs.com/browse/MODULES-3443))
- Output line and stacktrace of user code exception ([MODULES-3839](https://tickets.puppetlabs.com/browse/MODULES-3839))
- Improve resilience to failure of PowerShell host ([MODULES-3875](https://tickets.puppetlabs.com/browse/MODULES-3875))
- Fix race condition in threading with PowerShell host ([MODULES-3144](https://tickets.puppetlabs.com/browse/MODULES-3144))
- Modify tests to detect differences in PowerShell error text ([MODULES-3442](https://tickets.puppetlabs.com/browse/MODULES-3442))

###Documentation updates
- Document how to handle exit codes ([MODULES-3588](https://tickets.puppetlabs.com/browse/MODULES-3588))

##2016-07-12 - Supported Release 2.0.2
###Summary

Small release with bugs fixes and another speed improvement.

###Features
- Noticable speed increase by reducing the time start a PowerShell command ([MODULES-3406](https://tickets.puppetlabs.com/browse/MODULES-3406))

###Bug Fixes
- Fixed minor bugs in tests ([MODULES-3347](https://tickets.puppetlabs.com/browse/MODULES-3347))
- Added tests for try/catch ([MODULES-2634](https://tickets.puppetlabs.com/browse/MODULES-2634))
- Fixed bug with older ruby (1.8)

##2016-05-24 - Supported Release 2.0.1
###Bug Fixes

- Updated the powershell manager in this module in order to not conflict with the Powershell Manager in the Puppet DSC module

##2016-05-17 - Supported Release 2.0.0
###Summary

Major release with performance improvements

Removed support for Windows Server 2003

###Features
- Major performance improvement by sharing a single powershell session instead of creating a new powershell session per command
- Security improvement as scripts are not stored on the filesystem temporarily

###Bug Fixes
- Updated test suites with later versions
- Documentation cleanup

##2015-12-08 - Supported Release 1.0.6
###Summary

Small release for support of newer PE versions.

##2015-07-28 - Supported Release 1.0.5
###Summary

Add metadata for Puppet 4 and PE 2015.2.0

###Bug Fixes
- Minor testing bug fixes
- Readme cleanup

##2014-11-04 - Supported Release 1.0.4
###Summary

Fix Issues URL
Add Future Parser testing support

##2014-08-25 - Supported Release 1.0.3
###Summary

This release updates the tests to verify that powershell continues to function on x64-native ruby.

##2014-07-15 - Supported Release 1.0.2
###Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

##2014-07-09 - Release 1.0.1
###Summary

Fix issue with metadata and PE version requirement
