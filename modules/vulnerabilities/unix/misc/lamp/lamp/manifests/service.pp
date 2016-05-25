class lamp::service{
  Service { ensure => running }

  service { 'apache2': }
  service { 'mysql': }
}