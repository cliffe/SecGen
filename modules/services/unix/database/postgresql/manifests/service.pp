# Enables the PostgreSQL service at boot and keeps it running.
class postgresql::service {
  service { 'postgresql':
    ensure  => running,
    enable  => true,
    require => Class['postgresql::install'],
  }
}
