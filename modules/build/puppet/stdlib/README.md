# stdlib

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with stdlib](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    1. [Classes](#classes)
    1. [Defined Types](#defined-types)
    1. [Data Types](#data-types)
    1. [Facts](#facts)
    1. [Functions](#functions)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)
1. [Contributors](#contributors)


## Module Description

This module provides a standard library of resources for Puppet modules. Puppet modules make heavy use of this standard library. The stdlib module adds the following resources to Puppet:

 * Stages
 * Facts
 * Functions
 * Defined types
 * Data types
 * Providers

> *Note:* As of version 3.7, Puppet Enterprise no longer includes the stdlib module. If you're running Puppet Enterprise, you should install the most recent release of stdlib for compatibility with Puppet modules.

## Setup

[Install](https://docs.puppet.com/puppet/latest/modules_installing.html) the stdlib module to add the functions, facts, and resources of this standard library to Puppet.

If you are authoring a module that depends on stdlib, be sure to [specify dependencies](https://docs.puppet.com/puppet/latest/modules_metadata.html#specifying-dependencies) in your metadata.json.

## Usage

Most of stdlib's features are automatically loaded by Puppet. To use standardized run stages in Puppet, declare this class in your manifest with `include stdlib`.

When declared, stdlib declares all other classes in the module. The only other class currently included in the module is `stdlib::stages`.

The `stdlib::stages` class declares various run stages for deploying infrastructure, language runtimes, and application layers. The high level stages are (in order):

  * setup
  * main
  * runtime
  * setup_infra
  * deploy_infra
  * setup_app
  * deploy_app
  * deploy

Sample usage:

```puppet
node default {
  include stdlib
  class { java: stage => 'runtime' }
}
```

## Reference

* [Public classes](#public-classes)
* [Private classes](#private-classes)
* [Defined types](#defined-types)
* [Data types](#data-types)
* [Facts](#facts)
* [Functions](#functions)

### Classes

#### Public classes

The `stdlib` class has no parameters.

#### Private classes

* `stdlib::stages`: Manages a standard set of run stages for Puppet.

### Defined types

#### `file_line`

Ensures that a given line is contained within a file. The implementation matches the full line, including whitespace at the beginning and end. If the line is not contained in the given file, Puppet appends the line to the end of the file to ensure the desired state. Multiple resources can be declared to manage multiple lines in the same file.

Example:

```puppet
file_line { 'sudo_rule':
  path => '/etc/sudoers',
  line => '%sudo ALL=(ALL) ALL',
}

file_line { 'sudo_rule_nopw':
  path => '/etc/sudoers',
  line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
}
```

In the example above, Puppet ensures that both of the specified lines are contained in the file `/etc/sudoers`.

Match Example:

```puppet
file_line { 'bashrc_proxy':
  ensure => present,
  path   => '/etc/bashrc',
  line   => 'export HTTP_PROXY=http://squid.puppetlabs.vm:3128',
  match  => '^export\ HTTP_PROXY\=',
}
```

In the example above, `match` looks for a line beginning with 'export' followed by 'HTTP_PROXY' and replaces it with the value in line.

Match Example with `ensure => absent`:

```puppet
file_line { 'bashrc_proxy':
  ensure            => absent,
  path              => '/etc/bashrc',
  line              => 'export HTTP_PROXY=http://squid.puppetlabs.vm:3128',
  match             => '^export\ HTTP_PROXY\=',
  match_for_absence => true,
}
```

In the example above, `match` looks for a line beginning with 'export' followed by 'HTTP_PROXY' and deletes it. If multiple lines match, an error is raised, unless the `multiple => true` parameter is set.

Encoding example:

```puppet
file_line { "XScreenSaver":
  ensure   => present,
  path     => '/root/XScreenSaver'
  line     => "*lock: 10:00:00",
  match    => '^*lock:',
  encoding => "iso-8859-1",
}
```

Files with special characters that are not valid UTF-8 give the error message "Invalid byte sequence in UTF-8". In this case, determine the correct file encoding and specify it with the `encoding` attribute.

**Autorequires:** If Puppet is managing the file that contains the line being managed, the `file_line` resource autorequires that file.

**Parameters**

All parameters are optional, unless otherwise noted.

##### `after`

Specifies the line after which Puppet adds any new lines using a regular expression. (Existing lines are added in place.)

Values: String containing a regex.

Default value: `undef`.

##### `encoding`

Specifies the correct file encoding.

Values: String specifying a valid Ruby character encoding.

Default: 'UTF-8'.

##### `ensure`: Specifies whether the resource is present.

Values: 'present', 'absent'.

Default value: 'present'.

##### `line`

**Required.**

Sets the line to be added to the file located by the `path` parameter.

Values: String.
  
##### `match`

Specifies a regular expression to compare against existing lines in the file; if a match is found, it is replaced rather than adding a new line. A regex comparison is performed against the line value, and if it does not match, an exception is raised.

Values: String containing a regex.

Default value: `undef`.


##### `match_for_absence`

Specifies whether a match should be applied when `ensure => absent`. If set to `true` and match is set, the line that matches is deleted. If set to `false` (the default), match is ignored when `ensure => absent` and the value of `line` is used instead. Ignored when `ensure => present`.

Boolean.

Default value: `false`.

##### `multiple`

Specifies whether `match` and `after` can change multiple lines. If set to `false`, an exception is raised if more than one line matches.

Values: `true`, `false`.

Default value: `false`.


##### `name`

Specifies the name to use as the identity of the resource. If you want the resource namevar to differ from the supplied `title` of the resource, specify it with `name`. 

Values: String.

Default value: The value of the title.

##### `path`

**Required.**

Specifies the file in which Puppet ensures the line specified by `line`. 

Value: String specifying an absolute path to the file.

##### `replace`

Specifies whether the resource overwrites an existing line that matches the `match` parameter. If set to `false` and a line is found matching the `match` parameter, the line is not placed in the file.

Boolean.

Default value: `true`.

### Data types

#### `Stdlib::Absolutepath`

A strict absolute path type. Uses a variant of Unixpath and Windowspath types.

Acceptable input examples:

```shell
/var/log
```

```shell
/usr2/username/bin:/usr/local/bin:/usr/bin:.
```

```shell
C:\\WINDOWS\\System32
```

Unacceptable input example:

```shell
../relative_path
```

#### `Stdlib::Httpsurl`

Matches HTTPS URLs.

Acceptable input example:

```shell
https://hello.com
```

Unacceptable input example:

```shell
httds://notquiteright.org`
```

#### `Stdlib::Httpurl`

Matches both HTTPS and HTTP URLs.

Acceptable input example:

```shell
https://hello.com

http://hello.com
```

Unacceptable input example:

```shell
httds://notquiteright.org
```

#### `Stdlib::Unixpath`

Matches paths on Unix operating systems.

Acceptable input example:

```shell
/usr2/username/bin:/usr/local/bin:/usr/bin:

/var/tmp
```

Unacceptable input example:

```shell
C:/whatever
```

#### `Stdlib::Windowspath`

Matches paths on Windows operating systems.

Acceptable input example: 

```shell
C:\\WINDOWS\\System32

C:\\

\\\\host\\windows
```

Unacceptable input example:

```shell
/usr2/username/bin:/usr/local/bin:/usr/bin:.
```

### Facts

#### `package_provider`

Returns the default provider Puppet uses to manage packages on this system.

#### `is_pe`

Returns whether Puppet Enterprise is installed. Does not report anything on platforms newer than PE 3.x.

#### `pe_version`

Returns the version of Puppet Enterprise installed. Does not report anything on platforms newer than PE 3.x.

#### `pe_major_version`

Returns the major version Puppet Enterprise that is installed. Does not report anything on platforms newer than PE 3.x.

#### `pe_minor_version`

Returns the minor version of Puppet Enterprise that is installed. Does not report anything on platforms newer than PE 3.x.

#### `pe_patch_version`

Returns the patch version of Puppet Enterprise that is installed.

#### `puppet_vardir`

Returns the value of the Puppet vardir setting for the node running Puppet or Puppet agent.

#### `puppet_environmentpath`

Returns the value of the Puppet environment path settings for the node running Puppet or Puppet agent.

#### `puppet_server`

Returns the Puppet agent's `server` value, which is the hostname of the Puppet master with which the agent should communicate.

#### `root_home`

Determines the root home directory.

Determines the root home directory, which depends on your operating system. Generally this is '/root'.

#### `service_provider`

Returns the default provider Puppet uses to manage services on this system

### Functions

#### `abs`

Returns the absolute value of a number. For example, '-34.56' becomes '34.56'.

Argument: A single argument of either an integer or float value.

*Type*: rvalue.

#### `any2array`

Converts any object to an array containing that object. Converts empty argument lists are to empty arrays. Hashes are converted to arrays of alternating keys and values. Arrays are not touched.

*Type*: rvalue.

#### `any2bool`

Converts any object to a Boolean:

* Strings such as 'Y', 'y', '1', 'T', 't', 'TRUE', 'yes', 'true' return `true`.
* Strings such as '0', 'F', 'f', 'N', 'n', 'FALSE', 'no', 'false' return `false`.
* Booleans return their original value.
* A number (or a string representation of a number) greater than 0 returns `true`, otherwise `false`.
* An undef value returns `false`.
* Anything else returns `true`.

*Type*: rvalue.

#### `assert_private`

Sets the current class or definition as private. Calling the class or defined type from outside the current module fails.

For example, `assert_private()` called in class `foo::bar` outputs the following message if class is called from outside module `foo`: `Class foo::bar is private.`

To specify the error message you want to use:

```puppet
assert_private("You're not supposed to do that!")
```

*Type*: statement.

#### `base64`

Converts a string to and from base64 encoding. Requires an `action` ('encode', 'decode') and either a plain or base64-encoded `string`, and an optional `method` ('default', 'strict', 'urlsafe').

For backward compatibility, `method` is set as `default` if not specified.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

**Examples:**

```puppet
base64('encode', 'hello')
base64('encode', 'hello', 'default')
# return: "aGVsbG8=\n"

base64('encode', 'hello', 'strict')
# return: "aGVsbG8="

base64('decode', 'aGVsbG8=')
base64('decode', 'aGVsbG8=\n')
base64('decode', 'aGVsbG8=', 'default')
base64('decode', 'aGVsbG8=\n', 'default')
base64('decode', 'aGVsbG8=', 'strict')
# return: "hello"

base64('encode', 'https://puppetlabs.com', 'urlsafe')
# return: "aHR0cHM6Ly9wdXBwZXRsYWJzLmNvbQ=="

base64('decode', 'aHR0cHM6Ly9wdXBwZXRsYWJzLmNvbQ==', 'urlsafe')
# return: "https://puppetlabs.com"
```

*Type*: rvalue.

#### `basename`

Returns the `basename` of a path. An optional argument strips the extension. For example:

  * ('/path/to/a/file.ext') returns 'file.ext'
  * ('relative/path/file.ext') returns 'file.ext'
  * ('/path/to/a/file.ext', '.ext') returns 'file'

*Type*: rvalue.

#### `bool2num`

Converts a Boolean to a number. Converts values:

* `false`, 'f', '0', 'n', and 'no' to 0.
* `true`, 't', '1', 'y', and 'yes' to 1.
  
  Argument: a single Boolean or string as an input.
  
  *Type*: rvalue.

#### `bool2str`

Converts a Boolean to a string using optionally supplied arguments. The optional second and third arguments represent what true and false are converted to respectively. If only one argument is given, it is converted from a Boolean to a string containing `true` or `false`.

*Examples:*

```puppet
bool2str(true)                    => `true`
bool2str(true, 'yes', 'no')       => 'yes'
bool2str(false, 't', 'f')         => 'f'
```

Arguments: Boolean.

*Type*: rvalue.

#### `camelcase`

Converts the case of a string or all strings in an array to CamelCase (mixed case).

Arguments: Either an array or string. Returns the same type of argument as it received, but in CamelCase form.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

 *Type*: rvalue.

#### `capitalize`

Capitalizes the first character of a string or array of strings and lowercases the remaining characters of each string.

Arguments: either a single string or an array as an input. *Type*: rvalue.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

#### `ceiling`

Returns the smallest integer greater than or equal to the argument.

Arguments: A single numeric value.

*Type*: rvalue.

#### `chomp`

Removes the record separator from the end of a string or an array of strings; for example, 'hello\n' becomes 'hello'.

Arguments: a single string or array.

*Type*: rvalue.

#### `chop`

Returns a new string with the last character removed. If the string ends with '\r\n', both characters are removed. Applying `chop` to an empty string returns an empty string. To only remove record separators, use the `chomp` function.

Arguments: A string or an array of strings as input.

*Type*: rvalue.

#### `clamp`

Keeps value within the range [Min, X, Max] by sort based on integer value (parameter order doesn't matter). Strings are converted and compared numerically. Arrays of values are flattened into a list for further handling. For example:

  * `clamp('24', [575, 187])` returns 187.
  * `clamp(16, 88, 661)` returns 88.
  * `clamp([4, 3, '99'])` returns 4.
  
Arguments: strings, arrays, or numerics. 

*Type*: rvalue.

#### `concat`

Appends the contents of multiple arrays onto the first array given. For example:

  * `concat(['1','2','3'],'4')` returns ['1','2','3','4'].
  * `concat(['1','2','3'],'4',['5','6','7'])` returns ['1','2','3','4','5','6','7'].

*Type*: rvalue.

#### `convert_base`

Converts a given integer or base 10 string representing an integer to a specified base, as a string. For example:

  * `convert_base(5, 2)` results in: '101'
  * `convert_base('254', '16')` results in: 'fe'

#### `count`

If called with only an array, counts the number of elements that are **not** nil or `undef`. If called with a second argument, counts the number of elements in an array that matches the second argument.

*Type*: rvalue.

#### `deep_merge`

Recursively merges two or more hashes together and returns the resulting hash.

```puppet
$hash1 = {'one' => 1, 'two' => 2, 'three' => { 'four' => 4 } }
$hash2 = {'two' => 'dos', 'three' => { 'five' => 5 } }
$merged_hash = deep_merge($hash1, $hash2)
```

The resulting hash is equivalent to:

```puppet
$merged_hash = { 'one' => 1, 'two' => 'dos', 'three' => { 'four' => 4, 'five' => 5 } }
```

If there is a duplicate key that is a hash, they are recursively merged. If there is a duplicate key that is not a hash, the key in the rightmost hash takes precedence.

*Type*: rvalue.

#### `defined_with_params`

Takes a resource reference and an optional hash of attributes. Returns `true` if a resource with the specified attributes has already been added to the catalog. Returns `false` otherwise.

```puppet
user { 'dan':
  ensure => present,
}

if ! defined_with_params(User[dan], {'ensure' => 'present' }) {
  user { 'dan': ensure => present, }
}
```

*Type*: rvalue.

#### `delete`

Deletes all instances of a given element from an array, substring from a string, or key from a hash.

For example:

* `delete(['a','b','c','b'], 'b')` returns ['a','c'].
* `delete('abracadabra', 'bra')` returns 'acada'.
* `delete({'a' => 1,'b' => 2,'c' => 3},['b','c'])` returns {'a'=> 1}.
* `delete(['ab', 'b'], 'b')` returns ['ab'].

*Type*: rvalue.

#### `delete_at`

Deletes a determined indexed value from an array.

For example: `delete_at(['a','b','c'], 1)` returns ['a','c'].

*Type*: rvalue.

#### `delete_regex`

Deletes all instances of a given element from an array or hash that match a provided regular expression. A string is treated as a one-item array.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.


For example

* `delete_regex(['a','b','c','b'], 'b')` returns ['a','c'].
* `delete_regex({'a' => 1,'b' => 2,'c' => 3},['b','c'])` returns {'a'=> 1}.
* `delete_regex(['abf', 'ab', 'ac'], '^ab.*')` returns ['ac'].
* `delete_regex(['ab', 'b'], 'b')` returns ['ab'].

*Type*: rvalue.

#### `delete_values`

Deletes all instances of a given value from a hash.

For example:

* `delete_values({'a'=>'A','b'=>'B','c'=>'C','B'=>'D'}, 'B')` returns {'a'=>'A','c'=>'C','B'=>'D'}

*Type*: rvalue.

#### `delete_undef_values`

Deletes all instances of the `undef` value from an array or hash.

For example:

* `$hash = delete_undef_values({a=>'A', b=>'', c=>`undef`, d => false})` returns {a => 'A', b => '', d => false}.

*Type*: rvalue.

#### `deprecation`

Prints deprecation warnings and logs a warning once for a given key:

```puppet
deprecation(key, message)
```

Arguments:

* A string specifying the key: To keep the number of messages low during the lifetime of a Puppet process, only one message per key is logged.
* A string specifying the message: the text to be logged.

*Type*: Statement.

**Settings that affect `deprecation`**

Other settings in Puppet affect the stdlib `deprecation` function:

* [`disable_warnings`](https://docs.puppet.com/puppet/latest/reference/configuration.html#disablewarnings)
* [`max_deprecations`](https://docs.puppet.com/puppet/latest/reference/configuration.html#maxdeprecations)
* [`strict`](https://docs.puppet.com/puppet/latest/reference/configuration.html#strict):

    * `error`: Fails immediately with the deprecation message
    * `off`: Output emits no messages.
    * `warning`: Logs all warnings. This is the default setting.

* The environment variable `STDLIB_LOG_DEPRECATIONS`

  Specifies whether or not to log deprecation warnings. This is especially useful for automated tests to avoid flooding your logs before you are ready to migrate.

  This variable is Boolean, with the following effects:
  
  * `true`: Functions log a warning.
  * `false`: No warnings are logged.
  * No value set: Puppet 4 emits warnings, but Puppet 3 does not.

#### `difference`

Returns the difference between two arrays. The returned array is a copy of the original array, removing any items that also appear in the second array.

For example:

* `difference(["a","b","c"],["b","c","d"])` returns ["a"].

*Type*: rvalue.

#### `dig`

> DEPRECATED: This function has been replaced with a built-in [`dig`](https://docs.puppet.com/puppet/latest/function.html#dig) function as of Puppet 4.5.0. Use [`dig44()`](#dig44) for backwards compatibility or use the new version.

Retrieves a value within multiple layers of hashes and arrays via an array of keys containing a path. The function goes through the structure by each path component and tries to return the value at the end of the path.

In addition to the required path argument, the function accepts the default argument. It is returned if the path is not correct, if no value was found, or if any other error has occurred.

```ruby
$data = {
  'a' => {
    'b' => [
      'b1',
      'b2',
      'b3',
    ]
  }
}

$value = dig($data, ['a', 'b', 2])
# $value = 'b3'

# with all possible options
$value = dig($data, ['a', 'b', 2], 'not_found')
# $value = 'b3'

# using the default value
$value = dig($data, ['a', 'b', 'c', 'd'], 'not_found')
# $value = 'not_found'
```

1. **$data** The data structure we are working with.
2. **['a', 'b', 2]** The path array.
3. **'not_found'** The default value. It is returned if nothing is found.

Default value: `undef`.

*Type*: rvalue.

#### `dig44`

Retrieves a value within multiple layers of hashes and arrays via an array of keys containing a path. The function goes through the structure by each path component and tries to return the value at the end of the path.

In addition to the required path argument, the function accepts the default argument. It is returned if the path is incorrect, if no value was found, or if any other error has occurred.

```ruby
$data = {
  'a' => {
    'b' => [
      'b1',
      'b2',
      'b3',
    ]
  }
}

$value = dig44($data, ['a', 'b', 2])
# $value = 'b3'

# with all possible options
$value = dig44($data, ['a', 'b', 2], 'not_found')
# $value = 'b3'

# using the default value
$value = dig44($data, ['a', 'b', 'c', 'd'], 'not_found')
# $value = 'not_found'
```

*Type*: rvalue.

1. **$data** The data structure we are working with.
2. **['a', 'b', 2]** The path array.
3. **'not_found'** The default value. It will be returned if nothing is found.
   (optional, defaults to `undef`)

#### `dirname`

Returns the `dirname` of a path. For example, `dirname('/path/to/a/file.ext')` returns '/path/to/a'.

*Type*: rvalue.

#### `dos2unix`

Returns the Unix version of the given string. Very useful when using a File resource with a cross-platform template.

```puppet
file { $config_file:
  ensure  => file,
  content => dos2unix(template('my_module/settings.conf.erb')),
}
```

See also [unix2dos](#unix2dos).

*Type*: rvalue.

#### `downcase`

Converts the case of a string or of all strings in an array to lowercase.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

*Type*: rvalue.

#### `empty`

Returns `true` if the argument is an array or hash that contains no elements, or an empty string. Returns `false` when the argument is a numerical value.

*Type*: rvalue.

#### `enclose_ipv6`

Takes an array of IP addresses and encloses the ipv6 addresses with square brackets.

*Type*: rvalue.

#### `ensure_packages`

Takes a list of packages in an array or hash and installs them only if they don't already exist. Optionally takes a hash as a second parameter to be passed as the third argument to the `ensure_resource()` or `ensure_resources()` function.

*Type*: statement.

For an array:

```puppet
ensure_packages(['ksh','openssl'], {'ensure' => 'present'})
```

For a hash:

```puppet
ensure_packages({'ksh' => { ensure => '20120801-1' } ,  'mypackage' => { source => '/tmp/myrpm-1.0.0.x86_64.rpm', provider => "rpm" }}, {'ensure' => 'present'})
```

#### `ensure_resource`

Takes a resource type, title, and a hash of attributes that describe the resource(s).

```
user { 'dan':
  ensure => present,
}
```

This example only creates the resource if it does not already exist:

  `ensure_resource('user', 'dan', {'ensure' => 'present' })`

If the resource already exists, but does not match the specified parameters, this function attempts to recreate the resource, leading to a duplicate resource definition error.

An array of resources can also be passed in, and each will be created with the type and parameters specified if it doesn't already exist.

`ensure_resource('user', ['dan','alex'], {'ensure' => 'present'})`

*Type*: statement.

#### `ensure_resources`

Creates resource declarations from a hash, but doesn't conflict with resources that are already declared.

Specify a resource type and title and a hash of attributes that describe the resource(s).

```puppet
user { 'dan':
  gid => 'mygroup',
  ensure => present,
}

ensure_resources($user)
```

Pass in a hash of resources. Any listed resources that don't already exist will be created with the type and parameters specified:

    ensure_resources('user', {'dan' => { gid => 'mygroup', uid => '600' } ,  'alex' => { gid => 'mygroup' }}, {'ensure' => 'present'})

From Hiera backend:

```yaml
userlist:
  dan:
    gid: 'mygroup'
    uid: '600'
  alex:
    gid: 'mygroup'
```

```puppet
ensure_resources('user', hiera_hash('userlist'), {'ensure' => 'present'})
```

#### `flatten`

Flattens deeply nested arrays and returns a single flat array as a result.

For example, `flatten(['a', ['b', ['c']]])` returns ['a','b','c'].

*Type*: rvalue.

#### `floor`

Returns the largest integer less than or equal to the argument.

Arguments: A single numeric value.

*Type*: rvalue.

#### `fqdn_rand_string`

Generates a random alphanumeric string, combining the `$fqdn` fact and an optional seed for repeatable randomness. Optionally, you can specify a character set for the function (defaults to alphanumeric).

*Usage:*

```puppet
fqdn_rand_string(LENGTH, [CHARSET], [SEED])
```

*Examples:*

```puppet
fqdn_rand_string(10)
fqdn_rand_string(10, 'ABCDEF!@#$%^')
fqdn_rand_string(10, '', 'custom seed')
```

Arguments:

* An integer, specifying the length of the resulting string.
* Optionally, a string specifying the character set.
* Optionally, a string specifying the seed for repeatable randomness.

*Type*: rvalue.

#### `fqdn_rotate`

Rotates an array or string a random number of times, combining the `$fqdn` fact and an optional seed for repeatable randomness.

*Usage:*

```puppet
fqdn_rotate(VALUE, [SEED])
```

*Examples:*

```puppet
fqdn_rotate(['a', 'b', 'c', 'd'])
fqdn_rotate('abcd')
fqdn_rotate([1, 2, 3], 'custom seed')
```

*Type*: rvalue.

#### `fqdn_uuid`

Returns a [RFC 4122](https://tools.ietf.org/html/rfc4122) valid version 5 UUID based on an FQDN string under the DNS namespace:

  * fqdn_uuid('puppetlabs.com') returns '9c70320f-6815-5fc5-ab0f-debe68bf764c'
  * fqdn_uuid('google.com') returns '64ee70a4-8cc1-5d25-abf2-dea6c79a09c8'

*Type*: rvalue.

#### `get_module_path`

Returns the absolute path of the specified module for the current environment.

```puppet
$module_path = get_module_path('stdlib')
```

*Type*: rvalue.

#### `getparam`

Returns the value of a resource's parameter.

Arguments: A resource reference and the name of the parameter.

For example, the following returns 'param_value':

```puppet
define example_resource($param) {
}

example_resource { "example_resource_instance":
  param => "param_value"
}

getparam(Example_resource["example_resource_instance"], "param")
```

*Type*: rvalue.

#### `getvar`

Looks up a variable in a remote namespace.

For example:

```puppet
$foo = getvar('site::data::foo')
# Equivalent to $foo = $site::data::foo
```

This is useful if the namespace itself is stored in a string:

```puppet
$datalocation = 'site::data'
$bar = getvar("${datalocation}::bar")
# Equivalent to $bar = $site::data::bar
```

*Type*: rvalue.

#### `glob`

Returns an array of strings of paths matching path patterns.

Arguments: A string or an array of strings specifying path patterns.

```puppet
$confs = glob(['/etc/**/*.conf', '/opt/**/*.conf'])
```

*Type*: rvalue.

#### `grep`

Searches through an array and returns any elements that match the provided regular expression.

For example, `grep(['aaa','bbb','ccc','aaaddd'], 'aaa')` returns ['aaa','aaaddd'].

*Type*: rvalue.

#### `has_interface_with`

Returns a Boolean based on kind and value:

  * macaddress
  * netmask
  * ipaddress
  * network

*Examples:*

```puppet
has_interface_with("macaddress", "x:x:x:x:x:x")
has_interface_with("ipaddress", "127.0.0.1")    => true
```

If no kind is given, then the presence of the interface is checked:

```puppet
has_interface_with("lo")                        => true
```

*Type*: rvalue.

#### `has_ip_address`

Returns `true` if the client has the requested IP address on some interface. This function iterates through the `interfaces` fact and checks the `ipaddress_IFACE` facts, performing a simple string comparison.

Arguments: A string specifying an IP address.

*Type*: rvalue.

#### `has_ip_network`

Returns `true` if the client has an IP address within the requested network. This function iterates through the `interfaces` fact and checks the `network_IFACE` facts, performing a simple string comparision.

Arguments: A string specifying an IP address.

*Type*: rvalue.

#### `has_key`

Determines if a hash has a certain key value.

*Example*:

```
$my_hash = {'key_one' => 'value_one'}
if has_key($my_hash, 'key_two') {
  notice('we will not reach here')
}
if has_key($my_hash, 'key_one') {
  notice('this will be printed')
}
```

*Type*: rvalue.

#### `hash`

Converts an array into a hash.

For example, `hash(['a',1,'b',2,'c',3])` returns {'a'=>1,'b'=>2,'c'=>3}.

*Type*: rvalue.

#### `intersection`

Returns an array an intersection of two.

For example, `intersection(["a","b","c"],["b","c","d"])` returns ["b","c"].

*Type*: rvalue.

#### `is_a`

Boolean check to determine whether a variable is of a given data type. This is equivalent to the `=~` type checks. This function is available only in Puppet 4, or in Puppet 3 with the "future" parser.

```
foo = 3
$bar = [1,2,3]
$baz = 'A string!'

if $foo.is_a(Integer) {
  notify  { 'foo!': }
}
if $bar.is_a(Array) {
  notify { 'bar!': }
}
if $baz.is_a(String) {
  notify { 'baz!': }
}
```

* See the [the Puppet type system](https://docs.puppetlabs.com/latest/type.html#about-resource-types) for more information about types.
* See the [`assert_type()`](https://docs.puppetlabs.com/latest/function.html#asserttype) function for flexible ways to assert the type of a value.

#### `is_absolute_path`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the given path is absolute.

*Type*: rvalue.

#### `is_array`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the variable passed to this function is an array.

*Type*: rvalue.

#### `is_bool`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the variable passed to this function is a Boolean.

*Type*: rvalue.

#### `is_domain_name`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the string passed to this function is a syntactically correct domain name.

*Type*: rvalue.

#### `is_float`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the variable passed to this function is a float.

*Type*: rvalue.

#### `is_function_available`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Accepts a string as an argument and determines whether the Puppet runtime has access to a function by that name. It returns `true` if the function exists, `false` if not.

*Type*: rvalue.

#### `is_hash`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the variable passed to this function is a hash.

*Type*: rvalue.

#### `is_integer`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the variable returned to this string is an integer.

*Type*: rvalue.

#### `is_ip_address`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the string passed to this function is a valid IP address.

*Type*: rvalue.

#### `is_ipv6_address`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the string passed to this function is a valid IPv6 address.

*Type*: rvalue.

#### `is_ipv4_address`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the string passed to this function is a valid IPv4 address.

*Type*: rvalue.

#### `is_mac_address`

Returns `true` if the string passed to this function is a valid MAC address.

*Type*: rvalue.

#### `is_numeric`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the variable passed to this function is a number.

*Type*: rvalue.

#### `is_string`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Returns `true` if the variable passed to this function is a string.

*Type*: rvalue.

#### `join`

Joins an array into a string using a separator. For example, `join(['a','b','c'], ",")` results in: "a,b,c".

*Type*: rvalue.

#### `join_keys_to_values`

Joins each key of a hash to that key's corresponding value with a separator, returning the result as strings. 

If a value is an array, the key is prefixed to each element. The return value is a flattened array.

For example, `join_keys_to_values({'a'=>1,'b'=>[2,3]}, " is ")` results in ["a is 1","b is 2","b is 3"].

*Type*: rvalue.

#### `keys`

Returns the keys of a hash as an array.

*Type*: rvalue.

#### `length`

Returns the length of a given string, array or hash. Replaces the deprecated `size()` function.

*Type*: rvalue.

#### `loadyaml`

Loads a YAML file containing an array, string, or hash, and returns the data in the corresponding native data type.

For example:

```puppet
$myhash = loadyaml('/etc/puppet/data/myhash.yaml')
```

The second parameter is returned if the file was not found or could not be parsed.

For example:

```puppet
$myhash = loadyaml('no-file.yaml', {'default'=>'value'})
```

*Type*: rvalue.

#### `loadjson`

Loads a JSON file containing an array, string, or hash, and returns the data in the corresponding native data type.

For example:

```puppet
$myhash = loadjson('/etc/puppet/data/myhash.json')
```

The second parameter is returned if the file was not found or could not be parsed.

For example:

```puppet
  $myhash = loadjson('no-file.json', {'default'=>'value'})
  ```

*Type*: rvalue.

#### `load_module_metadata`

Loads the metadata.json of a target module. Can be used to determine module version and authorship for dynamic support of modules.

```puppet
$metadata = load_module_metadata('archive')
notify { $metadata['author']: }
```

When a module's metadata file is absent, the catalog compilation fails. To avoid this failure:

```
$metadata = load_module_metadata('mysql', true)
if empty($metadata) {
  notify { "This module does not have a metadata.json file.": }
}
```

*Type*: rvalue.

#### `lstrip`

Strips spaces to the left of a string.

*Type*: rvalue.

#### `max`

Returns the highest value of all arguments. Requires at least one argument.

Arguments: A numeric or a string representing a number.

*Type*: rvalue.

#### `member`

This function determines if a variable is a member of an array. The variable can be a string, an array, or a fixnum.

For example, `member(['a','b'], 'b')` and `member(['a','b','c'], ['b','c'])` return `true`, while `member(['a','b'], 'c')` and `member(['a','b','c'], ['c','d'])` return `false`.

*Note*: This function does not support nested arrays. If the first argument contains nested arrays, it will not recurse through them.

*Type*: rvalue.

#### `merge`

Merges two or more hashes together and returns the resulting hash.

*Example*:

```puppet
$hash1 = {'one' => 1, 'two' => 2}
$hash2 = {'two' => 'dos', 'three' => 'tres'}
$merged_hash = merge($hash1, $hash2)
# The resulting hash is equivalent to:
# $merged_hash =  {'one' => 1, 'two' => 'dos', 'three' => 'tres'}
```

When there is a duplicate key, the key in the rightmost hash takes precedence.

*Type*: rvalue.

#### `min`

Returns the lowest value of all arguments. Requires at least one argument.

Arguments: A numeric or a string representing a number.

*Type*: rvalue.

#### `num2bool`

Converts a number or a string representation of a number into a true Boolean. Zero or anything non-numeric becomes `false`. Numbers greater than 0 become `true`.

*Type*: rvalue.

#### `parsejson`

Converts a string of JSON into the correct Puppet structure (as a hash, array, string, integer, or a combination of such).

Arguments:
* The JSON string to convert, as a first argument.
* Optionally, the result to return if conversion fails, as a second error.

*Type*: rvalue.

#### `parseyaml`

Converts a string of YAML into the correct Puppet structure.

Arguments:
* The YAML string to convert, as a first argument.
* Optionally, the result to return if conversion fails, as a second error.

*Type*: rvalue. 

#### `pick`

From a list of values, returns the first value that is not undefined or an empty string. Takes any number of arguments, and raises an error if all values are undefined or empty.

```puppet
$real_jenkins_version = pick($::jenkins_version, '1.449')
```

*Type*: rvalue.

#### `pick_default`

Returns the first value in a list of values. Unlike the `pick()` function, `pick_default()` does not fail if all arguments are empty. This allows it to use an empty value as default.

*Type*: rvalue.

#### `prefix`

Applies a prefix to all elements in an array, or to the keys in a hash.

For example:

* `prefix(['a','b','c'], 'p')` returns ['pa','pb','pc'].
* `prefix({'a'=>'b','b'=>'c','c'=>'d'}, 'p')` returns {'pa'=>'b','pb'=>'c','pc'=>'d'}.

*Type*: rvalue.

#### `pry`

Invokes a pry debugging session in the current scope object. Useful for debugging manifest code at specific points during a compilation. Should be used only when running `puppet apply` or running a Puppet master in the foreground. Requires the `pry` gem to be installed in Puppet's rubygems.

*Examples:*

```puppet
pry()
```

In a pry session, useful commands include:

* Run `catalog` to see the contents currently compiling catalog.
* Run `cd catalog` and `ls` to see catalog methods and instance variables.
* Run `@resource_table` to see the current catalog resource table.

#### `pw_hash`

Hashes a password using the crypt function. Provides a hash usable on most POSIX systems.

The first argument to this function is the password to hash. If it is `undef` or an empty string, this function returns `undef`.

The second argument to this function is which type of hash to use. It will be converted into the appropriate crypt(3) hash specifier. Valid hash types are:

|Hash type            |Specifier|
|---------------------|---------|
|MD5                  |1        |
|SHA-256              |5        |
|SHA-512 (recommended)|6        |

The third argument to this function is the salt to use.

This function uses the Puppet master's implementation of crypt(3). If your environment contains several different operating systems, ensure that they are compatible before using this function.

*Type*: rvalue.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

#### `range`

Extrapolates a range as an array when given in the form of '(start, stop)'. For example, `range("0", "9")` returns [0,1,2,3,4,5,6,7,8,9]. Zero-padded strings are converted to integers automatically, so `range("00", "09")` returns [0,1,2,3,4,5,6,7,8,9].

Non-integer strings are accepted:

* `range("a", "c")` returns ["a","b","c"].
* `range("host01", "host10")` returns ["host01", "host02", ..., "host09", "host10"].

You must explicitly include trailing zeros, or the underlying Ruby function fails.

Passing a third argument causes the generated range to step by that interval. For example:

* `range("0", "9", "2")` returns ["0","2","4","6","8"].

*Type*: rvalue.

#### `regexpescape`

Regexp escape a string or array of strings. Requires either a single string or an array as an input.

*Type*: rvalue.

#### `reject`

Searches through an array and rejects all elements that match the provided regular expression.

For example, `reject(['aaa','bbb','ccc','aaaddd'], 'aaa')` returns ['bbb','ccc'].

*Type*: rvalue.

#### `reverse`

Reverses the order of a string or array.

*Type*: rvalue.

#### `rstrip`

Strips spaces to the right of the string.

*Type*: rvalue.

#### `seeded_rand`

Takes an integer max value and a string seed value and returns a repeatable random integer smaller than max. Similar to `fqdn_rand`, but does not add node specific data to the seed.

*Type*: rvalue.

#### `shell_escape`

Escapes a string so that it can be safely used in a Bourne shell command line. Note that the resulting string should be used unquoted and is not intended for use in either double or single quotes. This function behaves the same as Ruby's `Shellwords.shellescape()` function; see the [Ruby documentation](http://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html#method-c-shellescape).

For example:

```puppet
shell_escape('foo b"ar') => 'foo\ b\"ar'
```

*Type*: rvalue.

#### `shell_join`

Builds a command line string from a given array of strings. Each array item is escaped for Bourne shell. All items are then joined together, with a single space in between. This function behaves the same as Ruby's `Shellwords.shelljoin()` function; see the [Ruby documentation](http://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html#method-c-shelljoin).

For example:

```puppet
shell_join(['foo bar', 'ba"z']) => 'foo\ bar ba\"z'
```

*Type*: rvalue.

#### `shell_split`

Splits a string into an array of tokens. This function behaves the same as Ruby's `Shellwords.shellsplit()` function; see the [ruby documentation](http://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html#method-c-shellsplit).

*Example:*

```puppet
shell_split('foo\ bar ba\"z') => ['foo bar', 'ba"z']
```

*Type*: rvalue.

#### `shuffle`

Randomizes the order of a string or array elements.

*Type*: rvalue.

#### `size`

Returns the number of elements in a string, an array or a hash. This function will be deprecated in a future release. For Puppet 4, use the `length` function.

*Type*: rvalue.

#### `sort`

Sorts strings and arrays lexically.

*Type*: rvalue.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

#### `squeeze`

Replaces consecutive repeats (such as 'aaaa') in a string with a single character. Returns a new string.

*Type*: rvalue.

#### `str2bool`

Converts certain strings to a Boolean. This attempts to convert strings that contain the values '1', 'true', 't', 'y', or 'yes' to `true`. Strings that contain values '0', 'false', 'f', 'n', or 'no', or that are an empty string or undefined are converted to `false`. Any other value causes an error. These checks are case insensitive.

*Type*: rvalue.

#### `str2saltedsha512`

Converts a string to a salted-SHA512 password hash, used for OS X versions 10.7 or greater. Returns a hex version of a salted-SHA512 password hash, which can be inserted into Puppet manifests as a valid password attribute.

*Type*: rvalue.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

#### `strftime`

Returns formatted time.

For example, `strftime("%s")` returns the time since Unix epoch, and `strftime("%Y-%m-%d")` returns the date.

Arguments: A string specifying the time in `strftime` format. See the Ruby [strftime](https://ruby-doc.org/core-2.1.9/Time.html#method-i-strftime) documentation for details.

*Type*: rvalue.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

*Format:*

* `%a`: The abbreviated weekday name ('Sun')
* `%A`: The full weekday name ('Sunday')
* `%b`: The abbreviated month name ('Jan')
* `%B`: The full month name ('January')
* `%c`: The preferred local date and time representation
* `%C`: Century (20 in 2009)
* `%d`: Day of the month (01..31)
* `%D`: Date (%m/%d/%y)
* `%e`: Day of the month, blank-padded ( 1..31)
* `%F`: Equivalent to %Y-%m-%d (the ISO 8601 date format)
* `%h`: Equivalent to %b
* `%H`: Hour of the day, 24-hour clock (00..23)
* `%I`: Hour of the day, 12-hour clock (01..12)
* `%j`: Day of the year (001..366)
* `%k`: Hour, 24-hour clock, blank-padded ( 0..23)
* `%l`: Hour, 12-hour clock, blank-padded ( 0..12)
* `%L`: Millisecond of the second (000..999)
* `%m`: Month of the year (01..12)
* `%M`: Minute of the hour (00..59)
* `%n`: Newline (\n)
* `%N`: Fractional seconds digits, default is 9 digits (nanosecond)
  * `%3N`: Millisecond (3 digits)
  * `%6N`: Microsecond (6 digits)
  * `%9N`: Nanosecond (9 digits)
* `%p`: Meridian indicator ('AM' or 'PM')
* `%P`: Meridian indicator ('am' or 'pm')
* `%r`: Time, 12-hour (same as %I:%M:%S %p)
* `%R`: Time, 24-hour (%H:%M)
* `%s`: Number of seconds since the Unix epoch, 1970-01-01 00:00:00 UTC.
* `%S`: Second of the minute (00..60)
* `%t`: Tab character (	)
* `%T`: Time, 24-hour (%H:%M:%S)
* `%u`: Day of the week as a decimal, Monday being 1. (1..7)
* `%U`: Week number of the current year, starting with the first Sunday as the first day of the first week (00..53)
* `%v`: VMS date (%e-%b-%Y)
* `%V`: Week number of year according to ISO 8601 (01..53)
* `%W`: Week number of the current year, starting with the first Monday as the first day of the first week (00..53)
* `%w`: Day of the week (Sunday is 0, 0..6)
* `%x`: Preferred representation for the date alone, no time
* `%X`: Preferred representation for the time alone, no date
* `%y`: Year without a century (00..99)
* `%Y`: Year with century
* `%z`: Time zone as hour offset from UTC (e.g. +0900)
* `%Z`: Time zone name
* `%%`: Literal '%' character

#### `strip`

Removes leading and trailing whitespace from a string or from every string inside an array. For example, `strip("    aaa   ")` results in "aaa".

*Type*: rvalue.

#### `suffix`

Applies a suffix to all elements in an array or to all keys in a hash.

For example:

* `suffix(['a','b','c'], 'p')` returns ['ap','bp','cp'].
* `suffix({'a'=>'b','b'=>'c','c'=>'d'}, 'p')` returns {'ap'=>'b','bp'=>'c','cp'=>'d'}.

*Type*: rvalue.

#### `swapcase`

Swaps the existing case of a string. For example, `swapcase("aBcD")` results in "AbCd".

*Type*: rvalue.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

#### `time`

Returns the current Unix epoch time as an integer.

For example, `time()` returns something like '1311972653'.

*Type*: rvalue.

#### `to_bytes`

Converts the argument into bytes.

For example, "4 kB" becomes "4096". 

Arguments: A single string.

*Type*: rvalue.

#### `try_get_value`

**DEPRECATED:** replaced by `dig()`.

Retrieves a value within multiple layers of hashes and arrays.

Arguments: 

* A string containing a path, as the first argument. Provide this argument as a string of hash keys or array indexes starting with zero and separated by the path separator character (default "/"). This function goes through the structure by each path component and tries to return the value at the end of the path.

* A default argument as a second argument. This argument is returned if the path is not correct, if no value was found, or if any other error has occurred.
* The path separator character as a last argument.

```ruby
$data = {
  'a' => {
    'b' => [
      'b1',
      'b2',
      'b3',
    ]
  }
}

$value = try_get_value($data, 'a/b/2')
# $value = 'b3'

# with all possible options
$value = try_get_value($data, 'a/b/2', 'not_found', '/')
# $value = 'b3'

# using the default value
$value = try_get_value($data, 'a/b/c/d', 'not_found')
# $value = 'not_found'

# using custom separator
$value = try_get_value($data, 'a|b', [], '|')
# $value = ['b1','b2','b3']
```

1. **$data** The data structure we are working with.
2. **'a/b/2'** The path string.
3. **'not_found'** The default value. It will be returned if nothing is found.
   (optional, defaults to *`undef`*)
4. **'/'** The path separator character.
   (optional, defaults to *'/'*)

*Type*: rvalue.

#### `type3x`

**Deprecated**. This function will be removed in a future release.

Returns a string description of the type of a given value. The type can be a string, array, hash, float, integer, or Boolean. For Puppet 4, use the new type system instead.

Arguments:

* string
* array
* hash
* float
* integer
* Boolean

*Type*: rvalue.

#### `type_of`

This function is provided for backwards compatibility, but the built-in [type() function](https://docs.puppet.com/puppet/latest/reference/function.html#type) provided by Puppet is preferred.

Returns the literal type of a given value. Requires Puppet 4. Useful for comparison of types with `<=` such as in `if type_of($some_value) <= Array[String] { ... }` (which is equivalent to `if $some_value =~ Array[String] { ... }`).

*Type*: rvalue.

#### `union`

Returns a union of two or more arrays, without duplicates.

For example, `union(["a","b","c"],["b","c","d"])` returns ["a","b","c","d"].

*Type*: rvalue.

#### `unique`

Removes duplicates from strings and arrays.

For example, `unique("aabbcc")` returns 'abc', and `unique(["a","a","b","b","c","c"])` returns ["a","b","c"].

*Type*: rvalue.

#### `unix2dos`

Returns the DOS version of a given string. Useful when using a File resource with a cross-platform template.

*Type*: rvalue.

```puppet
file { $config_file:
  ensure  => file,
  content => unix2dos(template('my_module/settings.conf.erb')),
}
```

See also [dos2unix](#dos2unix).

#### `upcase`

Converts an object, array, or hash of objects to uppercase. Objects to be converted must respond to upcase.

For example, `upcase('abcd')` returns 'ABCD'.

*Type*: rvalue.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

#### `uriescape`

URLEncodes a string or array of strings. 

Arguments: Either a single string or an array of strings.

*Type*: rvalue.

*Note:* This function is an implementation of a Ruby class and might not be UTF8 compatible. To ensure compatibility, use this function with Ruby 2.4.0 or greater.

#### `validate_absolute_path`

Validates that a given string represents an absolute path in the filesystem. Works for Windows and Unix style paths.

The following values pass:

```puppet
$my_path = 'C:/Program Files (x86)/Puppet Labs/Puppet'
validate_absolute_path($my_path)
$my_path2 = '/var/lib/puppet'
validate_absolute_path($my_path2)
$my_path3 = ['C:/Program Files (x86)/Puppet Labs/Puppet','C:/Program Files/Puppet Labs/Puppet']
validate_absolute_path($my_path3)
$my_path4 = ['/var/lib/puppet','/usr/share/puppet']
validate_absolute_path($my_path4)
```

The following values fail, causing compilation to terminate:

```puppet
validate_absolute_path(true)
validate_absolute_path('../var/lib/puppet')
validate_absolute_path('var/lib/puppet')
validate_absolute_path([ 'var/lib/puppet', '/var/foo' ])
validate_absolute_path([ '/var/lib/puppet', 'var/foo' ])
$undefined = `undef`
validate_absolute_path($undefined)
```

*Type*: statement.

#### `validate_array`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Validates that all passed values are array data structures. Terminates catalog compilation if any value fails this check.

The following values pass:

```puppet
$my_array = [ 'one', 'two' ]
validate_array($my_array)
```

The following values fail, causing compilation to terminate:

```puppet
validate_array(true)
validate_array('some_string')
$undefined = `undef`
validate_array($undefined)
```

*Type*: statement.

#### `validate_augeas`

Validates a string using an Augeas lens.

Arguments:

* The string to test, as the first argument.
* The name of the Augeas lens to use, as the second argument.
* Optionally, a list of paths which should **not** be found in the file, as a third argument.
* Optionally, an error message to raise and show to the user, as a fourth argument.

If Augeas fails to parse the string with the lens, the compilation terminates with a parse error.

The `$file` variable points to the location of the temporary file being tested in the Augeas tree.

For example, to make sure your $passwdcontent never contains user `foo`, include the third argument:

```puppet
validate_augeas($passwdcontent, 'Passwd.lns', ['$file/foo'])
```

To raise and display an error message, include the fourth argument:

```puppet
validate_augeas($sudoerscontent, 'Sudoers.lns', [], 'Failed to validate sudoers content with Augeas')
```

*Type*: statement.

#### `validate_bool`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Validates that all passed values are either `true` or `false`. 
Terminates catalog compilation if any value fails this check.

The following values pass:

```puppet
$iamtrue = true
validate_bool(true)
validate_bool(true, true, false, $iamtrue)
```

The following values fail, causing compilation to terminate:

```puppet
$some_array = [ true ]
validate_bool("false")
validate_bool("true")
validate_bool($some_array)
```

*Type*: statement.

#### `validate_cmd`

Validates a string with an external command.

Arguments:
* The string to test, as the first argument.
* The path to a test command, as the second argument. This argument takes a % as a placeholder for the file path (if no % placeholder is given, defaults to the end of the command). If the command is launched against a tempfile containing the passed string, or returns a non-null value, compilation will terminate with a parse error.
* Optionally, an error message to raise and show to the user, as a third argument.

```puppet
# Defaults to end of path
validate_cmd($sudoerscontent, '/usr/sbin/visudo -c -f', 'Visudo failed to validate sudoers content')
```

```puppet
# % as file location
validate_cmd($haproxycontent, '/usr/sbin/haproxy -f % -c', 'Haproxy failed to validate config content')
```

*Type*: statement.

#### `validate_hash`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Validates that all passed values are hash data structures. Terminates catalog compilation if any value fails this check.

The following values will pass:

```puppet
$my_hash = { 'one' => 'two' }
validate_hash($my_hash)
```

The following values will fail, causing compilation to terminate:

```puppet
validate_hash(true)
validate_hash('some_string')
$undefined = `undef`
validate_hash($undefined)
```

*Type*: statement.

#### `validate_integer`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Validates an integer or an array of integers. Terminates catalog compilation if any of the checks fail.

Arguments:

* An integer or an array of integers, as the first argument.
* Optionally, a maximum, as the second argument. (All elements of) the first argument must be equal to or less than this maximum.
* Optionally, a minimum, as the third argument. (All elements of) the first argument must be equal to or greater than than this maximum. 

This function fails if the first argument is not an integer or array of integers, or if the second or third arguments are not convertable to an integer. However, if (and only if) a minimum is given, the second argument may be an empty string or `undef`, which serves as a placeholder to ensure the minimum check.

The following values pass:

```puppet
validate_integer(1)
validate_integer(1, 2)
validate_integer(1, 1)
validate_integer(1, 2, 0)
validate_integer(2, 2, 2)
validate_integer(2, '', 0)
validate_integer(2, `undef`, 0)
$foo = `undef`
validate_integer(2, $foo, 0)
validate_integer([1,2,3,4,5], 6)
validate_integer([1,2,3,4,5], 6, 0)
```

* Plus all of the above, but any combination of values passed as strings ('1' or "1").
* Plus all of the above, but with (correct) combinations of negative integer values.

The following values fail, causing compilation to terminate:

```puppet
validate_integer(true)
validate_integer(false)
validate_integer(7.0)
validate_integer({ 1 => 2 })
$foo = `undef`
validate_integer($foo)
validate_integer($foobaridontexist)

validate_integer(1, 0)
validate_integer(1, true)
validate_integer(1, '')
validate_integer(1, `undef`)
validate_integer(1, , 0)
validate_integer(1, 2, 3)
validate_integer(1, 3, 2)
validate_integer(1, 3, true)
```

* Plus all of the above, but any combination of values passed as strings (`false` or "false").
* Plus all of the above, but with incorrect combinations of negative integer values.
* Plus all of the above, but with non-integer items in arrays or maximum / minimum argument.

*Type*: statement.

#### `validate_ip_address`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Validates that the argument is an IP address, regardless of whether it is an IPv4 or an IPv6 address. It also validates IP address with netmask. 

Arguments: A string specifying an IP address.

The following values will pass:

```puppet
validate_ip_address('0.0.0.0')
validate_ip_address('8.8.8.8')
validate_ip_address('127.0.0.1')
validate_ip_address('194.232.104.150')
validate_ip_address('3ffe:0505:0002::')
validate_ip_address('::1/64')
validate_ip_address('fe80::a00:27ff:fe94:44d6/64')
validate_ip_address('8.8.8.8/32')
```

The following values will fail, causing compilation to terminate:

```puppet
validate_ip_address(1)
validate_ip_address(true)
validate_ip_address(0.0.0.256)
validate_ip_address('::1', {})
validate_ip_address('0.0.0.0.0')
validate_ip_address('3.3.3')
validate_ip_address('23.43.9.22/64')
validate_ip_address('260.2.32.43')
```


#### `validate_legacy`

Validates a value against both a specified type and a deprecated validation function. Silently passes if both pass, errors if only one validation passes, and fails if both validations return false.

Arguments:

* The type to check the value against,
* The full name of the previous validation function,
* The value to be checked,
* An unspecified number of arguments needed for the previous validation function.

Example:

```puppet
validate_legacy("Optional[String]", "validate_re", "Value to be validated", ["."])
```

This function supports updating modules from Puppet 3-style argument validation (using the stdlib `validate_*` functions) to Puppet 4 data types, without breaking functionality for those depending on Puppet 3-style validation.

> Note: This function is compatible only with Puppet 4.4.0 (PE 2016.1) and later.

##### For module users

If you are running Puppet 4, the `validate_legacy` function can help you find and resolve deprecated Puppet 3 `validate_*` functions. These functions are deprecated as of stdlib version 4.13 and will be removed in a future version of stdlib.

Puppet 4 allows improved defined type checking using [data types](https://docs.puppet.com/puppet/latest/reference/lang_data.html). Data types avoid some of the problems with Puppet 3's `validate_*` functions, which were sometimes inconsistent. For example, [validate_numeric](#validate_numeric) unintentionally allowed not only numbers, but also arrays of numbers or strings that looked like numbers.

If you run Puppet 4 and use modules with deprecated `validate_*` functions, you might encounter deprecation messages. The `validate_legacy` function makes these differences visible and makes it easier to move to the clearer Puppet 4 syntax.

The deprecation messages you get can vary, depending on the modules and data that you use. These deprecation messages appear by default only in Puppet 4:

* `Notice: Accepting previously invalid value for target type '<type>'`: This message is informational only. You're using values that are allowed by the new type, but would have been invalid by the old validation function.
* `Warning: This method is deprecated, please use the stdlib validate_legacy function`: The module has not yet upgraded to `validate_legacy`. Use the [deprecation](#deprecation) options to silence warnings for now, or submit a fix with the module's developer. See the information [for module developers](#for-module-developers) below for how to fix the issue.
* `Warning: validate_legacy(<function>) expected <type> value, got <actual type>_`: Your code passes a value that was accepted by the Puppet 3-style validation, but will not be accepted by the next version of the module. Most often, you can fix this by removing quotes from numbers or booleans.
* `Error: Evaluation Error: Error while evaluating a Resource Statement, Evaluation Error: Error while evaluating a Function Call, validate_legacy(<function>) expected <type> value, got <actual type>`: Your code passes a value that is not acceptable to either the new or the old style validation.

##### For module developers

The `validate_legacy` function helps you move from Puppet 3 style validation to Puppet 4 validation without breaking functionality your module's users depend on.

Moving to Puppet 4 type validation allows much better defined type checking using [data types](https://docs.puppet.com/puppet/latest/reference/lang_data.html). Many of Puppet 3's `validate_*` functions have surprising holes in their validation. For example, [validate_numeric](#validate_numeric) allows not only numbers, but also arrays of numbers or strings that look like numbers, without giving you any control over the specifics. 

For each parameter of your classes and defined types, choose a new Puppet 4 data type to use. In most cases, the new data type allows a different set of values than the original `validate_*` function. The situation then looks like this:

|              | `validate_` pass | `validate_` fail |
| ------------ | ---------------- | ---------------- |
| matches type | pass             | pass, notice     |
| fails type   | pass, deprecated | fail             |

The code after the validation still has to handle all possible values for now, but users of your code can change their manifests to pass only values that match the new type.

For each `validate_*` function in stdlib, there is a matching `Stdlib::Compat::*` type that allows the appropriate set of values. See the documentation in the `types/` directory in the stdlib source code for caveats.

For example, given a class that should accept only numbers, like this:

```puppet
class example($value) {
  validate_numeric($value)
```

the resulting validation code looks like this:

```puppet
class example(
  Variant[Stdlib::Compat::Numeric, Numeric] $value
) {
  validate_legacy(Numeric, 'validate_numeric', $value)
```

Here, the type of `$value` is defined as `Variant[Stdlib::Compat::Numeric, Numeric]`, which allows any `Numeric` (the new type), as well as all values previously accepted by `validate_numeric` (through `Stdlib::Compat::Numeric`).

The call to `validate_legacy` takes care of triggering the correct log or fail message for you. It requires the new type, the previous validation function name, and all arguments to that function.

If your module still supported Puppet 3, this is a breaking change. Update your `metadata.json` requirements section to indicate that your module no longer supports Puppet 3, and bump the major version of your module. With this change, all existing tests for your module should still pass. Create additional tests for the new possible values.

As a breaking change, this is also a good time to call [`deprecation`](#deprecation) for any parameters you want to get rid of, or to add additional constraints on your parameters.

After releasing this version, you can release another breaking change release where you remove all compat types and all calls to `validate_legacy`. At that time, you can also go through your code and remove any leftovers dealing with the previously possible values.

Always note such changes in your CHANGELOG and README.

#### `validate_numeric`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Validates a numeric value, or an array or string of numeric values. Terminates catalog compilation if any of the checks fail.

Arguments:

* A numeric value, or an array or string of numeric values.
* Optionally, a maximum value. (All elements of) the first argument has to be less or equal to this max.
* Optionally, a minimum value. (All elements of) the first argument has to be greater or equal to this min.

This function fails if the first argument is not a numeric (Integer or Float) or an array or string of numerics, or if the second and third arguments are not convertable to a numeric. If, and only if, a minimum is given, the second argument can be an empty string or `undef`, which serves as a placeholder to ensure the minimum check.

For passing and failing usage, see [`validate_integer`](#validate-integer). The same values pass and fail, except that `validate_numeric` also allows floating point values.

*Type*: statement.

#### `validate_re`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Performs simple validation of a string against one or more regular expressions.

Arguments:

* The string to test, as the first argument. If this argument is not a string, compilation terminates. Use quotes to force stringification.
* A stringified regular expression (without the // delimiters) or an array of regular expressions, as the second argument.
* Optionally, the error message raised and shown to the user, as a third argument.

If none of the regular expressions in the second argument match the string passed in the first argument, compilation terminates with a parse error.

The following strings validate against the regular expressions:

```puppet
validate_re('one', '^one$')
validate_re('one', [ '^one', '^two' ])
```

The following string fails to validate, causing compilation to terminate:

```puppet
validate_re('one', [ '^two', '^three' ])
```

To set the error message:

```puppet
validate_re($::puppetversion, '^2.7', 'The $puppetversion fact value does not match 2.7')
```

To force stringification, use quotes:

  ```
  validate_re("${::operatingsystemmajrelease}", '^[57]$')
  ```

*Type*: statement.

#### `validate_slength`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Validates that a string (or an array of strings) is less than or equal to a specified length

Arguments:

* A string or an array of strings, as a first argument.
* A numeric value for maximum length, as a second argument.
* Optionally, a numeric value for minimum length, as a third argument.

  The following values pass:

```puppet
validate_slength("discombobulate",17)
validate_slength(["discombobulate","moo"],17)
validate_slength(["discombobulate","moo"],17,3)
```

The following values fail:

```puppet
validate_slength("discombobulate",1)
validate_slength(["discombobulate","thermometer"],5)
validate_slength(["discombobulate","moo"],17,10)
```

*Type*: statement.

#### `validate_string`

**Deprecated. Will be removed in a future version of stdlib. See [`validate_legacy`](#validate_legacy).**

Validates that all passed values are string data structures. Aborts catalog compilation if any value fails this check.

The following values pass:

```puppet
$my_string = "one two"
validate_string($my_string, 'three')
```

The following values fail, causing compilation to terminate:

```puppet
validate_string(true)
validate_string([ 'some', 'array' ])
```

*Note:* validate_string(`undef`) will not fail in this version of the functions API.

Instead, use:

  ```
  if $var == `undef` {
    fail('...')
  }
  ```

*Type*: statement.

#### `validate_x509_rsa_key_pair`

Validates a PEM-formatted X.509 certificate and private key using OpenSSL.
Verifies that the certificate's signature was created from the supplied key.

Fails catalog compilation if any value fails this check.

Arguments:

* An X.509 certificate as the first argument.
* An RSA private key, as the second argument.

```puppet
validate_x509_rsa_key_pair($cert, $key)
```

*Type*: statement.

#### `values`

Returns the values of a given hash.

For example, given `$hash = {'a'=1, 'b'=2, 'c'=3} values($hash)` returns [1,2,3].

*Type*: rvalue.

#### `values_at`

Finds values inside an array based on location.

Arguments:

* The array you want to analyze, as the first argument.
* Any combination of the following values, as the second argument:
  * A single numeric index
  * A range in the form of 'start-stop' (eg. 4-9)
  * An array combining the above

For example:

* `values_at(['a','b','c'], 2)` returns ['c'].
* `values_at(['a','b','c'], ["0-1"])` returns ['a','b'].
* `values_at(['a','b','c','d','e'], [0, "2-3"])` returns ['a','c','d'].

*Type*: rvalue.

#### `zip`

Takes one element from first array given and merges corresponding elements from second array given. This generates a sequence of n-element arrays, where *n* is one more than the count of arguments. For example, `zip(['1','2','3'],['4','5','6'])` results in ["1", "4"], ["2", "5"], ["3", "6"]. *Type*: rvalue.

## Limitations

As of Puppet Enterprise 3.7, the stdlib module is no longer included in PE. PE users should install the most recent release of stdlib for compatibility with Puppet modules.

### Version Compatibility

Versions | Puppet 2.6 | Puppet 2.7 | Puppet 3.x | Puppet 4.x |
:---------------|:-----:|:---:|:---:|:----:
**stdlib 2.x**  | **yes** | **yes** | no | no
**stdlib 3.x**  | no    | **yes**  | **yes** | no
**stdlib 4.x**  | no    | **yes**  | **yes** | no
**stdlib 4.6+**  | no    | **yes**  | **yes** | **yes**
**stdlib 5.x**  | no    | no  | **yes**  | **yes**

**stdlib 5.x**: When released, stdlib 5.x will drop support for Puppet 2.7.x. Please see [this discussion](https://github.com/puppetlabs/puppetlabs-stdlib/pull/176#issuecomment-30251414).

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad hardware, software, and deployment configurations that Puppet is intended to serve. We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see our [module contribution guide](https://docs.puppetlabs.com/forge/contributing.html).

To report or research a bug with any part of this module, please go to
[http://tickets.puppetlabs.com/browse/MODULES](http://tickets.puppetlabs.com/browse/MODULES).

## Contributors

The list of contributors can be found at: [https://github.com/puppetlabs/puppetlabs-stdlib/graphs/contributors](https://github.com/puppetlabs/puppetlabs-stdlib/graphs/contributors).
