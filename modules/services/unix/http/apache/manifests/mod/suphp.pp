class apache::mod::suphp (
){
  include ::apache
  ::apache::mod { 'suphp': }

  file {'suphp.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/suphp.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/suphp.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}

