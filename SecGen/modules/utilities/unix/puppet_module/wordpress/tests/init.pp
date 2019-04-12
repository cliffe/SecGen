class { 'wordpress':
  install_dir => '/var/www/wordpress',
  db_name     => 'wordpress',
  db_host     => 'localhost',
  db_user     => 'wordpress',
  db_password => 'insecure password',
}
