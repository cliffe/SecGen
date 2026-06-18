# Class: apache_spark_rce::configure
# Configure apache spark and secgen
#
class apache_spark_rce::configure {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $sparkconf='spark-defaults.conf'
  $leaked_filenames = $secgen_parameters['leaked_filenames']
  $strings_to_leak = $secgen_parameters['strings_to_leak']
  $user = $secgen_parameters['unix_username'][0]
  $pre_leaked_filenames = $secgen_parameters['pre_leaked_filenames']
  $strings_to_pre_leak = $secgen_parameters['strings_to_pre_leak']

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  # We set the acls flag in the config - This ensures its vulnerable
  file { '/usr/local/spark/conf':
    ensure => directory,
  }
  -> file { "/usr/local/spark/conf/${sparkconf}":
    ensure => file,
    source => "puppet:///modules/apache_spark_rce/${sparkconf}",
  }

  ::secgen_functions::leak_files { 'spark-flag-leak':
    storage_directory => "/home/${user}",
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    owner             => 'spark',
    mode              => '0750',
    leaked_from       => 'apache_spark_rce',
  }

  # Not really preleaking, hard to change spark config to pre leak.
  # TODO in future: Actually preleak it through http-title to show in nmap scan
  ::secgen_functions::leak_files { 'spark-flag-pre-leak':
    storage_directory => "/home/${user}",
    leaked_filenames  => $pre_leaked_filenames,
    strings_to_leak   => $strings_to_pre_leak,
    owner             => 'spark',
    mode              => '0750',
    leaked_from       => 'apache_spark_rce',
  }
}
