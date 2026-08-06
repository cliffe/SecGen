class roxy_wi::install {
  Exec {path => ['/bin', '/usr/bin', '/usr/local/bin', '/sbin', '/usr/sbin'],
    environment => ['http_proxy=http://172.22.0.51:3128',
      'https_proxy=http://172.22.0.51:3128',
      'ftp_proxy=http://172.22.0.51:3128'] }


  ensure_packages('apache2')
  ensure_packages('rsync')
  ensure_packages('ansible')
  ensure_packages('netcat')
  ensure_packages('nmap')
  ensure_packages('net-tools')
  ensure_packages('lshw')
  ensure_packages('dos2unix')
  ensure_packages('libapache2-mod-wsgi-py3')
  ensure_packages('openssl')
  ensure_packages('sshpass')

  ensure_packages('python3')
  ensure_packages('python3-ldap')
  ensure_packages('python3-pip')
  ensure_packages('python3-requests')
  ensure_packages('python3-networkx')
  ensure_packages('python3-matplotlib')
  ensure_packages('python3-bottle')
  ensure_packages('python3-future')
  ensure_packages('python3-jinja2')
  ensure_packages('python3-peewee')
  ensure_packages('python3-distro')
  ensure_packages('python3-pymysql')
  ensure_packages('python3-psutil')
  ensure_packages('python3-paramiko')

  file { '/var/www/roxy-wi-master.zip':
    source => 'puppet:///modules/roxy_wi/roxy-wi-master.zip',
    owner => www-data,
    mode => '0755',
  } ->

  exec { 'unzip-roxy-wi-master':
    command => 'unzip roxy-wi-master.zip',
    cwd => '/var/www',
    creates => '/var/www/roxy-wi-master',
  } ->

  exec { 'rename-to-haproxy-wi':
    command => 'mv /var/www/roxy-wi-master /var/www/haproxy-wi',
    creates => '/var/www/haproxy-wi',
    cwd => '/',
  } ->

  exec { 'configure-apache-2-sites':
    command => 'cp /var/www/haproxy-wi/config_other/httpd/roxy-wi_deb.conf /etc/apache2/sites-available/roxy-wi.conf',
  } ->

  exec { 'thing':
    command => 'a2ensite roxy-wi.conf',
    cwd => '/var/www',
  } ->

  exec { 'thing2':
    command => 'a2enmod cgid ssl proxy_http rewrite',
    cwd => '/var/www',
  } ->

  exec { 'install-requirements-using-pip':
    command => 'pip3 install -r haproxy-wi/config_other/requirements_deb.txt',
    cwd => '/var/www',
  } ->

  exec { 'restart-apache2':
    command => 'systemctl restart apache2',
    cwd => '/var/www',
  } ->

  exec { 'configure-logging':
    command => 'cp haproxy-wi/config_other/logrotate/* /etc/logrotate.d/',
    cwd => '/var/www',
  } ->

  file { '/var/lib/roxy-wi/keys/':
    ensure => directory,
  } ->
  file { '/var/lib/roxy-wi/configs/':
    ensure => directory,
  } ->
  file { '/var/lib/roxy-wi/configs/hap_config/':
    ensure => directory,
  } ->
  file { '/var/lib/roxy-wi/configs/kp_config/':
    ensure => directory,
  } ->
  file { '/var/lib/roxy-wi/configs/nginx_config/':
    ensure => directory,
  } ->
  file { '/var/lib/roxy-wi/configs/apache_config/':
    ensure => directory,
  } ->
  file { '/var/www/haproxy-wi/log/':
    ensure => directory,
  } ->
  file { '/var/www/haproxy-wi/app/certs/':
    ensure => directory,
  } ->
  file { '/etc/roxy-wi/':
    ensure => directory,
  } ->
  file { '/etc/roxy-wi/roxy-wi.cfg':
    source => '/var/www/haproxy-wi/roxy-wi.cfg',
  } ->

  exec { 'setup-openssl-keys':
    command => 'openssl req -newkey rsa:4096 -nodes -keyout /var/www/haproxy-wi/app/certs/haproxy-wi.key -x509 -days 10365 -out /var/www/haproxy-wi/app/certs/haproxy-wi.crt -subj "/C=US/ST=Almaty/L=Springfield/O=Roxy-WI/OU=IT/CN=*.roxy-wi.org/emailAddress=aidaho@roxy-wi.org"',
    cwd => '/',
  } ->

  exec { 'change-www-owner':
    command => 'chown -R www-data:www-data /var/www/haproxy-wi/',
  } ->
  exec { 'change-lib-owner':
    command => 'chown -R www-data:www-data /var/lib/roxy-wi/',
  } ->
  exec { 'change-www-owner2':
    command => 'chown -R www-data:www-data /var/www/haproxy-wi/',
  } ->
  exec { 'daemon-reload':
    command => 'systemctl daemon-reload',
  } ->
  exec { 'restart-httpd':
    command => 'systemctl restart httpd',
  } ->
  exec { 'restart-rsyslog':
    command => 'systemctl restart rsyslog',
  } ->
  exec { 'create-database':
    command => './create_db.py',
    cwd => '/var/www/haproxy-wi/app',
  }
}
