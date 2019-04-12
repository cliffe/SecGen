class proftpd {
  class { 'proftpd::install': }
  class { 'proftpd::configure': } ~>
  class { 'proftpd::service': }
}
