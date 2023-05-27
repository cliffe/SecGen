# Class: apache_spark_rce::service
# Service to start spark-shell
#
class apache_spark_rce::service {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $user = $secgen_parameters['unix_username'][0]

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  exec { 'set-port':
    command => "sed -i 's/8080/${port}/' /usr/local/spark/sbin/start-master.sh",
  }
  -> file { '/etc/systemd/system/spark.service':
    content => template('apache_spark_rce/spark.service.erb'),
    owner   => 'root',
    mode    => '0777',
  }
  -> service { 'spark':
    ensure => running,
    enable => true,
  }
}
