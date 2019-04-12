# accounts

#### Table of Contents
1. [Description](#description)
2. [Setup - The basics of getting started with accounts](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
	* [Declare user accounts](#declare-user-accounts)
	* [Customize the home directory](#customize-the-home-directory)
	* [Lock accounts](#lock-accounts)
	* [Manage SSH keys](#manage-ssh-keys)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


## Description

The accounts module manages resources related to login and service accounts. This module replaces Puppet Enterprise's built-in pe\_accounts module, which is no longer included in PE 2015.3 and later versions.

This module works on many UNIX/Linux operating systems. It does not support configuring accounts on Microsoft Windows platforms.

## Setup

### Beginning with accounts

Declare the `accounts` class in a Puppet-managed node's manifest:

~~~puppet
node default {
  accounts::user { 'dan': }
  accounts::user { 'morgan': }
}
~~~

The above example creates accounts, home directories, and groups for Dan and Morgan.

## Usage

### Declare user accounts

~~~puppet
accounts::user { 'bob':
  uid      => 4001,
  gid      => 4001,
  shell    => '/bin/bash',
  password => '!!',
  sshkeys  => "ssh-rsa AAAA...",
  locked   => false,
}
~~~

### Customize the home directory

A simple bashrc and bash\_profile rc file is managed by Puppet for each account. These rc files add some simple aliases, update the prompt, add ~/bin to the path, and source the following files (which are not managed by this module) in the following order:

 1. `/etc/bashrc`
 2. `/etc/bashrc.puppet`
 3. `~/.bashrc.custom`

Account holders can customize their shells by managing their bashrc.custom files. In addition, the system administrator can make profile changes that affect all accounts with a bash shell by managing the '/etc/bashrc.puppet' file.

### Lock accounts

Lock accounts by setting the `locked` parameter of an account to true.

For example:

~~~puppet
accounts::user { 'villain':
  comment => 'Bad Person',
  locked  => true
}
~~~

The accounts module sets the account to an invalid shell appropriate for the system Puppet is managing and displays the following message if a user tries to access the account:

~~~
$ ssh villain@centos56
This account is currently not available.
Connection to 172.16.214.129 closed.
~~~

### Manage SSH keys

Manage SSH keys with the `sshkeys` attribute of the `accounts::user` defined type. This parameter accepts an array of public key contents as strings.

Example:

~~~puppet
accounts::user { 'jeff':
  comment => 'Jeff McCune',
  groups  => [
    'admin',
    'sudonopw',
  ],
  uid     => '1112',
  gid     => '1112',
  sshkeys => [
    'ssh-rsa AAAAB3Nza...== jeff@puppetlabs.com',
    'ssh-dss AAAAB3Nza...== jeff@metamachine.net',
  ],
}
~~~

## Reference

### Defined type: `accounts::user`

This resource manages the user, group, .vim/, .ssh/, .bash\_profile, .bashrc, homedir, .ssh/authorized\_keys files, and directories.

#### `bashrc_content`

The content to place in the user's ~/.bashrc file. Default: undef.

#### `bash_profile_content`

The content to place in the user's ~/.bash\_profile file. Default: undef.

#### `comment`

A comment describing or regarding the user. Accepts a string. Default: '$name'.

#### `ensure`

Specifies whether the user, its primary group, homedir, and ssh keys should exist. Valid values are 'present' and 'absent'. Note that when a user is created, a group with the same name as the user is also created. Default: 'present'.

#### `gid`

Specifies the gid of the user's primary group. Must be specified numerically. Default: undef.

#### `groups`

Specifies the user's group memberships. Valid values: an array. Default: an empty array.

#### `home`

Specifies the path to the user's home directory. 
Default: 
* Linux, non-root user: '/home/$name' 
* Linux, root user: '/root'
* Solaris, non-root user: '/export/home/$name' 
* Solaris, root user: '/'

#### `home_mode`

Manages the user's home directory permission mode. Valid values are in [octal notation](https://docs.puppetlabs.com/references/latest/type.html#file-attribute-mode), specified as a string. Defaults to `0700`, which gives the owner full read, write, and execute permissions, while group and other have no permissions. 

#### `locked`

Specifies whether the account should be locked and the user prevented from logging in. Set to true for users whose login privileges have been revoked. Valid values: true, false. Default: false.

#### `managehome`

Specifies whether the user's home directory should be managed by puppet. In addition to the usual [user resource managehome](https://docs.puppetlabs.com/references/latest/type.html#user-attribute-managehome) qualities, this attribute also purges the user's homedir if `ensure` is set to 'absent' and `managehome` is set to true. Default: true.

#### `membership`

Establishes whether specified groups should be considered the complete list (inclusive) or the minimum list (minimum) of groups to which the user belongs. Valid values: 'inclusive', 'minimum'. Default: 'minimum'.

#### `password`

The user's password, in whatever encrypted format the local machine requires. Default: '!!', which prevents the user from logging in with a password.

#### `purge_sshkeys`

Whether keys not included in `sshkeys` should be removed from the user. If `purge_sshkeys` is true and `sshkeys` is an empty array, all SSH keys will be removed from the user. Valid values: true, false. Default: false.

#### `shell`

Manages the user shell. Default: '/bin/bash'.

#### `sshkeys`

An array of SSH public keys associated with the user. These should be complete public key strings that include the type and name of the key, exactly as the key would appear in its id\_rsa.pub or id\_dsa.pub file. Must be an array. Default: an empty array.

#### `uid`

Specifies the user's uid number. Must be specified numerically. Default: undef.

## Limitations

This module works with Puppet Enterprise 2015.3 and later.

### Changes from pe\_accounts

The accounts module is designed to take the place of the pe\_accounts module that shipped with PE versions 2015.2 and earlier. Some of the changes include the removal of the base class, improving the validation, and allowing more flexibility regarding which files should or should not be managed in a user's home directory. 

For example, the .bashrc and .bash\_profile files are not managed by default but allow custom content to be passed in using the `bashrc_content` and `bash_profile_content` parameters. The content for these two files as managed by pe\_accounts can continue to be used by passing `bashrc_content => file('accounts/shell/bashrc')` and `bash_profile_content => file('accounts/shell/bash_profile')` to the `accounts::user` defined type.

## Development

If you run into an issue with this module, or if you would like to request a feature, please [file a ticket](https://tickets.puppetlabs.com/browse/MODULES/).

If you have problems getting this module up and running, please [contact Support](http://puppetlabs.com/services/customer-support).
