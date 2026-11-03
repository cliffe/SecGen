class labtainers_marker::install{
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $labs = $secgen_parameters['lab']
  $flags = $secgen_parameters['flags']


  # labflags (setuid wrapper) execs /usr/bin/ruby to run labflags.rb
  ensure_packages(['ruby'])

  # flag-based marking
  file { "/opt/labflags/":
    ensure => directory,
    mode   => '755',
    require => Package['ruby'],
  } ->
  file { "/opt/labflags/labflags":
    ensure => present,
    source => 'puppet:///modules/labtainers_marker/labflags/labflags',
    mode   => '4755',
    owner => 'root',
    group => 'root',
  } ->
  file { "/opt/labflags/labflags.rb":
    ensure => present,
    source => 'puppet:///modules/labtainers_marker/labflags/labflags.rb',
    mode   => '755',
    owner => 'root',
    group => 'root',
  }

  $labs.each |String $lab| {
    file {"/opt/labflags/${lab}.flags.json":
      ensure => present,
      content => template("labtainers_marker/${lab}.flags.json.erb"),
    }
  }
  # file { "/opt/labflags/acl.flags.json":
  #   ensure => present,
  #   source => template("labtainers_marker/acl.flags.json"),
  #   owner => 'root',
  #   group => 'root',
  # }
}
