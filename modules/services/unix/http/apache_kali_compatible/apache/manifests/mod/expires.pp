class apache::mod::expires (
  $expires_active  = true,
  $expires_default = undef,
  $expires_by_type = undef,
) {
  include ::apache
  ::apache::mod { 'expires': }

  # Template uses
  # $expires_active
  # $expires_default
  # $expires_by_type
  file { 'expires.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/expires.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/expires.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
