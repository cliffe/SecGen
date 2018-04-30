class apache::mod::authn_dbd (
  $authn_dbd_params,
  $authn_dbd_dbdriver    = 'mysql',
  $authn_dbd_query       = undef,
  $authn_dbd_min         = '4',
  $authn_dbd_max         = '20',
  $authn_dbd_keep        = '8',
  $authn_dbd_exptime     = '300',
  $authn_dbd_alias       = undef,
) inherits ::apache::params {
  include ::apache
  include ::apache::mod::dbd
  ::apache::mod { 'authn_dbd': }

  if $authn_dbd_alias {
  include ::apache::mod::authn_core
  }

  # Template uses
  # - All variables beginning with authn_dbd
  file { 'authn_dbd.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/authn_dbd.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/authn_dbd.conf.erb'),
    require => [ Exec["mkdir ${::apache::mod_dir}"], ],
    before  => File[$::apache::mod_dir],
    notify  => Class['Apache::Service'],
  }
}
