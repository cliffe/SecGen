class apache::mod::ext_filter(
  Optional[Hash] $ext_filter_define = undef
) {
  include ::apache

  ::apache::mod { 'ext_filter': }

  # Template uses
  # -$ext_filter_define

  if $ext_filter_define {
    file { 'ext_filter.conf':
      ensure  => file,
      path    => "${::apache::mod_dir}/ext_filter.conf",
      mode    => $::apache::file_mode,
      content => template('apache/mod/ext_filter.conf.erb'),
      require => [ Exec["mkdir ${::apache::mod_dir}"], ],
      before  => File[$::apache::mod_dir],
      notify  => Class['Apache::Service'],
    }
  }
}
