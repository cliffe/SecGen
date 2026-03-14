# Class: maltrail_rce::configure
# Configuration for vulnerable MalTrail with randomized threat data and dual flags
class maltrail_rce::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $modulename = 'maltrail_rce'
  $user = $secgen_parameters['unix_username'][0]
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  
  # MalTrail data from generator (JSON format, base64 encoded)
  $maltrail_data_json_array = $secgen_parameters['maltrail_data']
  $maltrail_data_json = $maltrail_data_json_array[0]

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  # Leak flag files to user's home directory for exploitation verification (Flag 1)
  ::secgen_functions::leak_files { 'maltrail-flag-leak':
    storage_directory => "/home/${user}",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => $user,
    mode              => '0600',
    leaked_from       => 'maltrail_rce',
  }

  # Deploy Ruby helper scripts for generating MalTrail data
  file { '/tmp/generate_maltrail_log.rb':
    ensure => file,
    source => "puppet:///modules/${modulename}/generate_maltrail_log.rb",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/tmp/generate_custom_trails.rb':
    ensure => file,
    source => "puppet:///modules/${modulename}/generate_custom_trails.rb",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Create MalTrail log directory
  file { '/var/log/maltrail':
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
    require => User[$user],
  }

  # Create custom trails directory
  file { '/opt/maltrail/trails':
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  # Generate today's log file with synthetic events using Ruby script
  # The script reads from maltrail_data_json and generates properly formatted log entries
  exec { 'generate-maltrail-log':
    command => "ruby /tmp/generate_maltrail_log.rb '${maltrail_data_json}' > /var/log/maltrail/$(date +%Y-%m-%d).log",
    unless  => "test -f /var/log/maltrail/$(date +%Y-%m-%d).log",
    require => [File['/var/log/maltrail'], File['/tmp/generate_maltrail_log.rb']],
  }

  # Set permissions on log file
  exec { 'set-maltrail-log-permissions':
    command => "chown ${user}:${user} /var/log/maltrail/*.log && chmod 644 /var/log/maltrail/*.log",
    require => Exec['generate-maltrail-log'],
  }

  # Generate custom trails file using Ruby script
  exec { 'generate-custom-trails':
    command => "ruby /tmp/generate_custom_trails.rb '${maltrail_data_json}' > /opt/maltrail/trails/custom.txt",
    unless  => 'test -f /opt/maltrail/trails/custom.txt',
    require => [File['/opt/maltrail/trails'], File['/tmp/generate_custom_trails.rb']],
  }

  # Set permissions on custom trails file
  file { '/opt/maltrail/trails/custom.txt':
    ensure  => file,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    require => Exec['generate-custom-trails'],
  }
}
