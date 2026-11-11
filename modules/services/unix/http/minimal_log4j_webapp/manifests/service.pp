# Class: minimal_log4j_webapp::service
# Run the compiled app as a systemd unit under the fetched JDK 8, on the
# configured port and as the service user.
class minimal_log4j_webapp::service {
  $modulename = 'minimal_log4j_webapp'
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $port = $secgen_parameters['port'][0]
  $user = $secgen_parameters['unix_username'][0]

  $app_dir = '/opt/minimal_log4j_webapp'
  $jdk_dir = '/opt/jdk8u181'
  $java = "${jdk_dir}/bin/java"
  $classpath = "${app_dir}/classes:${app_dir}/lib/log4j-api-2.14.1.jar:${app_dir}/lib/log4j-core-2.14.1.jar:${app_dir}/lib/commons-collections-3.2.1.jar"

  file { '/etc/systemd/system/minimal_log4j_webapp.service':
    ensure  => file,
    content => template("${modulename}/minimal_log4j_webapp.service.erb"),
    mode    => '0644',
  }
  ~> exec { 'minimal_log4j_webapp-daemon-reload':
    command     => 'systemctl daemon-reload',
    path        => [ '/bin/', '/usr/bin/', '/sbin/', '/usr/sbin/' ],
    refreshonly => true,
  }
  -> service { 'minimal_log4j_webapp':
    ensure => running,
    enable => true,
  }
}
