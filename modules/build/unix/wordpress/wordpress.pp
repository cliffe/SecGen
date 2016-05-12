include lamp

$password = generate('/bin/sh', '-c', "mkpasswd -m sha-512 ")

exec { 'add_sql':
  command => 'apt-get --yes --force-yes install php5-mysql',
  provider => 'shell'
  # path    => [ '/usr/local/bin/', '/bin/' ],  # alternative syntax
}

#generate sql password


class { 'wordpress':
  install_dir => '/var/www/wordpress',
  db_user => 'root',
  db_password => '',
  notify => File['wordpress_cli']
}


file{
  'wordpress_cli':
    ensure => 'present',
    source => 'puppet:///modules/wordpress/wp-cli.phar',
    path => '/var/www/wordpress/wp-cli.phar',
    owner => 'root',
    group => 'root',
    mode => '0744',
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
    command => "/var/www/wordpress/wpcli-install.sh"

}
