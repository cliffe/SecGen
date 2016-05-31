class lamp::install{
  include lamp::update

  Package {
    # ensure => 'installed'
    ensure  => latest,
    require  => Exec["update"]
  }

  # Apache
  package { 'apache2': }
  package { 'libapache2-mod-php5': }

  # Mysql
  package { 'mysql-server': }
  package { 'mysql-client': }

  # Php
  package { 'php5': }

}