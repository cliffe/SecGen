class apache::mod::mime (
  $mime_support_package = $::apache::params::mime_support_package,
  $mime_types_config    = $::apache::params::mime_types_config,
  $mime_types_additional = undef,
) inherits ::apache::params {
  include ::apache
  $_mime_types_additional = pick($mime_types_additional, $apache::mime_types_additional)
  apache::mod { 'mime': }
  # Template uses $_mime_types_config
  file { 'mime.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/mime.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/mime.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
  if $mime_support_package {
    package { $mime_support_package:
      ensure => 'installed',
      before => File['mime.conf'],
    }
  }
}
