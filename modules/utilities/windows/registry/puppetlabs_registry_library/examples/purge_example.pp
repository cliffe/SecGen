# = Class: registry::purge_example
#
#   This class provides an example of how to purge registry values associated
#   with a specific key.
#
#   This class has two modes of operation determined by the Facter fact
#   PURGE_EXAMPLE_MODE  The value of this fact can be either 'setup' or 'purge'
#
#   The easiest way to set this mode is to set an
#    environment variable in Power Shell:
#
#   The setup mode creates a registry key and 6 values.
#
#   `$env:FACTER_PURGE_EXAMPLE_MODE = "setup"`
#   `puppet agent --test`
#
#   The purge mode manages the key with purge_values => true and manages only 3
#   of the 6 values.  The other 3 values will be automatically purged.
#
#   `$env:FACTER_PURGE_EXAMPLE_MODE = "purge"`
#   `puppet agent --test`
#
# = Parameters
#
# = Actions
#
# = Requires
#
# = Sample Usage
#
#   include registry::purge_example
#
# (MARKUP: http://links.puppetlabs.com/puppet_manifest_documentation)
class registry::purge_example {

  $key_path = 'HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge'

  case $::purge_example_mode {
    setup: {
      registry_key { $key_path:
        ensure       => present,
        purge_values => false,
      }
      registry_key { "${key_path}\\SubKey":
        ensure       => present,
        purge_values => false,
      }
      registry_value { "${key_path}\\SubKey\\Value1":
        ensure => present,
        type   => dword,
        data   => 1,
      }
      registry_value { "${key_path}\\SubKey\\Value2":
        ensure => present,
        type   => dword,
        data   => 1,
      }
      registry_value { "${key_path}\\Value1":
        ensure => present,
        type   => dword,
        data   => 1,
      }
      registry_value { "${key_path}\\Value2":
        ensure => present,
        type   => dword,
        data   => 2,
      }
      registry_value { "${key_path}\\Value3":
        ensure => present,
        type   => string,
        data   => 'key3',
      }
      registry_value { "${key_path}\\Value4":
        ensure => present,
        type   => array,
        data   => [ 'one', 'two', 'three' ],
      }
      registry_value { "${key_path}\\Value5":
        ensure => present,
        type   => expand,
        data   => '%SystemRoot%\system32',
      }
      registry_value { "${key_path}\\Value6":
        ensure => present,
        type   => binary,
        data   => '01AB CDEF',
      }
    }
    purge: {
      registry_key { $key_path:
        ensure       => present,
        purge_values => true,
      }
      registry_value { "${key_path}\\Value1":
        ensure => present,
        type   => dword,
        data   => 0,
      }
      registry_value { "${key_path}\\Value2":
        ensure => present,
        type   => dword,
        data   => 0,
      }
      registry_value { "${key_path}\\Value3":
        ensure => present,
        type   => string,
        data   => 'should not be purged',
      }
    }
    default: {
      notify { 'purge_example_notice':
        message => 'The purge_example_mode fact is not set.  To try this
        example class first set \$env:FACTER_PURGE_EXAMPLE_MODE = \'setup\' then
        run puppet agent, then set \$env:FACTER_PURGE_EXAMPLE_MODE = \'purge\'
        and run puppet agent again to see the values purged.',
      }
    }
  }
}
