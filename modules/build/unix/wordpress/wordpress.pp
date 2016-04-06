class { 'wordpress':
  install_dir => '/var/www/wordpress',
  db_user => 'root',
  db_password => '',
  notify => File['wp_cli_script']
}

file{
  'wp_cli_script':
    ensure => 'file',
    source => 'puppet:///modules/wordpress/wpcli-install.sh',
    path => '/var/www/wordpress/wpcli-install.sh',
    owner => 'root',
    group => 'root',
    mode => '0744',
    notify => Exec['run_wp_cli']
}

exec {
  'run_wp_cli':
    command => '/var/www/wordpress/wpcli-install.sh',

}
