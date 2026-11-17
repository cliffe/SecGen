# Adds a weak manager account and exposes the Manager app over the network.
# Runs after the required tomcat service module (separate catalog), so
# /opt/tomcat is already installed and running; we overwrite its config on
# disk and restart Tomcat ourselves.
class tomcat_manager_default_creds::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $username = $secgen_parameters['tomcat_manager_username'][0]
  $password = $secgen_parameters['tomcat_manager_password'][0]

  $catalina_home = '/opt/tomcat'

  # Weak manager account the tomcat_mgr_login scanner guesses. manager-gui is
  # what /manager/html needs; the other roles make the account usable from the
  # text and status interfaces too.
  file { "${catalina_home}/conf/tomcat-users.xml":
    ensure  => file,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0640',
    content => template('tomcat_manager_default_creds/tomcat-users.xml.erb'),
  }

  # The stock Manager app ships a RemoteAddrValve restricting it to localhost.
  # Replace its context.xml with one that has no such valve so the app is
  # reachable from the network.
  file { "${catalina_home}/webapps/manager/META-INF/context.xml":
    ensure => file,
    owner  => 'tomcat',
    group  => 'tomcat',
    mode   => '0640',
    source => 'puppet:///modules/tomcat_manager_default_creds/manager-context.xml',
  }

  # Tomcat is already running from the service module, so restart it to pick up
  # the new realm users and manager context. Drop any cached per-host context
  # descriptor first so the de-restricted context.xml is the one that loads.
  exec { 'restart tomcat for manager default creds':
    command     => 'rm -f /opt/tomcat/conf/Catalina/localhost/manager.xml; systemctl restart tomcat',
    refreshonly => true,
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    subscribe   => [
      File["${catalina_home}/conf/tomcat-users.xml"],
      File["${catalina_home}/webapps/manager/META-INF/context.xml"],
    ],
  }
}
