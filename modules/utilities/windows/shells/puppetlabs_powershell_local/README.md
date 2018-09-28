# powershell

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with powershell](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with powershell](#beginning-with-powershell)
4. [Usage - Configuration options and additional functionality](#usage)
    * [External files and exit codes](#external-files-and-exit-codes)
    * [Console Error Output](#console-error-output)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module adds a new exec provider capable of executing PowerShell commands.

## Module Description

Puppet provides a built-in `exec` type that is capable of executing commands. This module adds a `powershell` provider to the `exec` type,  which enables `exec` parameters, listed below. This module is particularly helpful if you need to run PowerShell commands but don't know the details about how PowerShell is executed, because you can run PowerShell commands in Puppet without the module.

## Setup

### Requirements

This module requires PowerShell to be installed and the `powershell.exe` to be available in the system PATH.

### Beginning with powershell

The powershell module adapts the Puppet [exec](http://docs.puppet.com/references/stable/type.html#exec) resource to run PowerShell commands. To get started, install the module and declare 'powershell' in `provider` with the applicable command.

~~~ puppet
exec { 'RESOURCENAME':
  command   => '$(SOMECOMMAND)',
  provider  => powershell,
}
~~~

## Usage

When using `exec` resources with the `powershell` provider, the `command` parameter must be single-quoted to prevent Puppet from interpolating `$(..)`.

For instance, to rename the Guest account:

~~~ puppet
exec { 'rename-guest':
  command   => '$(Get-WMIObject Win32_UserAccount -Filter "Name=\'guest\'").Rename("new-guest")',
  unless    => 'if (Get-WmiObject Win32_UserAccount -Filter "Name=\'guest\'") { exit 1 }',
  provider  => powershell,
}
~~~

Note that the example uses the `unless` parameter to make the resource idempotent. The `command` is only executed if the Guest account does not exist, as indicated by `unless` returning 0.

**Note:** PowerShell variables (such as `$_`) must be escaped in Puppet manifests either using backslashes or single quotes.

Alternately, you can put the PowerShell code for the `command`, `onlyif`, and `unless` parameters into separate files, and then invoke the file function in the resource. You could also use templates and the `template()` function if the PowerShell scripts need access to variables from Puppet.

~~~ puppet
exec { 'rename-guest':
  command   => file('guest/rename-guest.ps1'),
  onlyif    => file('guest/guest-exists.ps1'),
  provider  => powershell,
  logoutput => true,
}
~~~

Each file is a PowerShell script that should be in the module's `files/` folder.

For example, here is the script at: `guest/files/rename-guest.ps1`

~~~ powershell
$obj = $(Get-WMIObject Win32_UserAccount -Filter "Name='Guest'")
$obj.Rename("OtherGuest")
~~~

This has the added benefit of not requiring escaping '$' in the PowerShell code. Note that the files must have DOS linefeeds or they will not work as expected. One tool for converting UNIX linefeeds to DOS linefeeds is [unix2dos](http://freecode.com/projects/dos2unix).

### External files and exit codes

If you are calling external files, such as other PowerShell scripts or executables, be aware that the last executed script's exitcode is used by Puppet to determine whether the command was successful.

For example, if the file `C:\fail.ps1` contains the following PowerShell script:

~~~ powershell
& cmd /c EXIT 5
& cmd /c EXIT 1
~~~

and we use the following Puppet manifest:

~~~ puppet
exec { 'test':
  command   => '& C:\fail.ps1',
  provider  => powershell,
}
~~~

Then the `exec['test']` resource will always fail, because the last exit code from the external file `C:\fail.ps1` is `1`.  This behavior might have unintended consequences if you combine multiple external files.

To stop this behavior, ensure that you use explicit `Exit` statements in your PowerShell scripts.  For example, we changed the Puppet manifest from the above to:

~~~ puppet
exec { 'test':
  command   => '& C:\fail.ps1; Exit 0',
  provider  => powershell,
}
~~~

This will always succeed because the `Exit 0` statement overrides the exit code from the `C:\fail.ps1` script.

### Console Error Output

The PowerShell module internally captures output sent to the .NET `[System.Console]::Error` stream like:

~~~ puppet
exec { 'test':
  command   => '[System.Console]::Error.WriteLine("foo")',
  provider  => powershell,
}
~~~

However, to produce output from a script, use the `Write-` prefixed cmdlets such as `Write-Output`, `Write-Debug` and `Write-Error`.

## Reference

#### Provider

* powershell: Adapts the Puppet `exec` resource to run PowerShell commands.

#### Parameters

All parameters are optional.

##### `creates`

Specifies the file to look for before running the command. The command runs only if the file doesn't exist. **Note: This parameter does not create a file, it only looks for one.** Valid options: A string of the path to the file. Default: Undefined.

##### `cwd`

Sets the directory from which to run the command. Valid options: A string of the directory path. Default: Undefined.

##### `command`

Specifies the actual PowerShell command to execute. Must either be fully qualified or a search path for the command must be provided. Valid options: String. Default: Undefined.

##### `environment`

Sets additional environment variables to set for a command. Valid options: String, or an array of multiple options. Default: Undefined.

##### `logoutput`

Defines whether to log command output in addition to logging the exit code. If you specify 'on_failure', it only logs the output when the command has an exit code that does not match any value specified by the `returns` attribute. Valid options: true, false, and 'on_failure'. Default: 'on_failure'.

##### `onlyif`

Runs the exec only if the command returns 0. Valid options: String. Default: Undefined.

##### `path`

Specifies the search path used for command execution. Valid options: String of the path, an array, or a semicolon-separated list. Default: Undefined.

##### `refresh`

Refreshes the command. Valid options: String. Default: Undefined.

##### `refreshonly`

Refreshes the command only when a dependent object is changed. Used with `subscribe` and `notify` [metaparameters](http://docs.puppet.com/references/latest/metaparameter.html). Valid options: true, false. Default: false.

##### `returns`

Lists the expected return code(s). If the executed command returns something else, an error is returned. Valid options: An array of acceptable return codes or a single value. Default: 0.

##### `timeout`

Sets the maximum time in seconds that the command should take. Valid options: Number or string representation of a number. Default: 300.

##### `tries`

Determines the number of times execution of the command should be attempted. Valid options: Number or a string representation of a number. Default: '1'.

##### `try_sleep`

Specifies the time to sleep in seconds between `tries`. Valid options: Number or a string representation of a number. Default: Undefined.

##### `unless`

Runs the `exec`, unless the command returns 0. Valid options: String. Default: Undefined.

## Limitations

* Only supported on Windows Server 2008 and above, and Windows 7 and above.

* Only supported on Powershell 2.0 and above.

* When using here-strings in inline or templated scripts executed by this module, you must use the double-quote style syntax that begins with `@"` and ends with `"@`. The single-quote syntax that begins with `@'` and ends with `'@` is not supported.

  Note that any external .ps1 script file loaded or executed with the call operator `&` is not subject to this limitation and can contain any style here-string. For instance, the script file external-code.ps1 can contain any style of here-string:

  ```
  exec { 'external-code':
    command   => '& C:\external-code.ps1',
    provider  => powershell,
  }
  ```

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our [module contribution guide.](https://docs.puppet.com/forge/contributing.html)
