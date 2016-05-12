class distcc_exec::install{
  package { 'distcc':
    ensure => installed
  }
}