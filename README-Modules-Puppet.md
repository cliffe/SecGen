# Puppet is used to provision the VMs
Each vulnerability, service, and utility module contains Puppet files which are used to provision the software onto the VMs. By the time Puppet is executed to provision VMs, all randomisation has previously taken place at build time.

The module directory contains
 - a Puppet module
 - Puppet entry point (same file name as the module directory, .pp)

The following example should help illustrate.

Distcc has a documented security weakness that enables remote code execution. The below example comes from modules/vulnerabilities/misc/distcc_exec.

A manifest/ directory contains the Puppet files for a distcc_exec Puppet class.

As is convention, one file for Installation:
````
class distcc_exec::install{
  package { 'distcc':
    ensure => installed
  }
}
````
One file for configuration (plus a template file):
````
class distcc_exec::config{
  file { '/etc/default/distcc':
    require => Package['distcc'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0777',
    content  => template('distcc_exec/distcc.erb')
  }
}
````
One file for ensuring the service starts:
````
class distcc_exec::service{
  service { 'distcc':
    ensure => running
  }
}
````
So far this is all typical Puppet.

Finally, we add a module entry point, with a filename matching the directory name 'distcc_exec.pp':
````
include distcc_exec::install
include distcc_exec::config
include distcc_exec::service
````

## SecGen feeds (randomised) input into parameters
By the time Puppet is executed to provision VMs, all randomisation has previously taken place at build time, and any inputs that have been passed into the module (refer to the [Creating Scenarios guide](README-Creating-Scenarios.md)) are made available to the Puppet code via a shared function.

In the Puppet code (for example, manifests/config.pp) we can read inputs from SecGen into local variables:
````
$secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
$leaked_filenames = $secgen_parameters['leaked_filenames']
$strings_to_leak = $secgen_parameters['strings_to_leak']
````

Exploitation of the vulnerability should result in the attacker gaining access to $strings_to_leak. We can achieve that with the following Puppet code:

````
# distccd home directory
file { '/home/distccd/':
  ensure => directory,
  owner => 'distccd',
  mode  =>  '0750',
}

#exec usermod home directory for distccd
exec { 'change-home-dir':
  path => ['/usr/bin/', '/usr/sbin'],
  command => 'usermod -d /home/distccd distccd'
}

::secgen_functions::leak_files { 'distcc_exec-file-leak':
  storage_directory => "/home/distccd",
  leaked_filenames  => $leaked_filenames,
  strings_to_leak   => $strings_to_leak,
  owner             => 'distccd',
  mode              => '0600',
  leaked_from       => 'distcc_exec',
}
````
Consider referring to the full [disctcc module in the source code](modules/vulnerabilities/unix/misc/distcc_exec/manifests/config.pp).

To learn more about Puppet and understand the how to write modules check out the SecGen Wiki and also http://puppetlabs.com/
