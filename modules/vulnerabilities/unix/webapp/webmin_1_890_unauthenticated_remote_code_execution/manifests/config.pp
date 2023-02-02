#
class webmin_1_890_unauthenticated_remote_code_execution::config {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $user = 'webminusr'
  $user_home = "/home/${user}"
  $temp_dir = '/opt/Webmin_1.890'

  # Create User.
  user { $user:
    ensure     => 'present',
    uid        => '666',
    gid        => 'root',#
    home       => $user_home,
    password   => 'Password123',
    managehome => true,
    require    => Package['unzip'],
    notify     => File[$temp_dir],
  }

  cron { 'start-webmin-cron':
    command => 'sudo /etc/webmin/start',
    special => 'reboot',
    require => Exec['setup'],
  }
  # End of Puppet module.
}
