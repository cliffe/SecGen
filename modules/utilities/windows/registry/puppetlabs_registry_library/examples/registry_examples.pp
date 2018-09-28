# = Class: registry_example
#
#   This is an example of how to manage registry keys and values.
#
# = Parameters
#
# = Actions
#
# = Requires
#
# = Sample Usage
#
#     include registry_example
#
# (MARKUP: http://links.puppetlabs.com/puppet_manifest_documentation)
class registry_example {
  registry_key { 'HKLM\Software\Vendor':
    ensure => present,
  }

  # This should trigger a duplicate resource with HKLM
  # registry_key { 'HKEY_LOCAL_MACHINE\Software\Vendor':
  #   ensure => present,
  # }

  registry_key { 'HKLM\Software\Vendor\Bar':
    ensure => present,
  }

  registry_value { 'HKLM\Software\Vendor\Bar\valuedword2':
    ensure => present,
    type   => dword,
    data   => 0xFFFFFFFF,
  }

  registry_value { 'HKLM\Software\Vendor\Bar\valueqword1':
    ensure => present,
    type   => qword,
    data   => 100,
  }

  registry_value { 'HKLM\Software\Vendor\Bar\valuedstring1':
    ensure => present,
    type   => string,
    data   => 'this is a string',
  }

  registry_value { 'HKLM\Software\Vendor\Bar\valuedexpand1':
    ensure => present,
    type   => expand,
    data   => '%windir%\system32',
  }

  registry_value { 'HKLM\Software\Vendor\Bar\valuedbinary1':
    ensure => present,
    type   => binary,
    data   => 'DE AD BE EF',
  }

  registry_value { 'HKLM\Software\Vendor\Bar\valuedbinary2':
    ensure => present,
    type   => binary,
    data   => 'CAFEBEEF',
  }

  registry_value { 'HKLM\Software\Vendor\Bar\valuearray1':
    ensure => present,
    type   => array,
    data   => [ 'one', 'two', 'three' ],
  }

  $some_string = "somestring"
  registry_value { 'HKLM\Software\Vendor\Bar\valuearray2':
    ensure => present,
    type   => array,
    data   => [ 0, 'zero', '0', 123456, 'two', $some_string ],
  }

  $some_array = [ "array1", "array2", "array3" ]
  registry_value { 'HKLM\Software\Vendor\Bar\valuearray3':
    ensure => present,
    type   => array,
    data   => $some_array,
  }
}

include registry_example
