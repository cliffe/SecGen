class apache::mod::rpaf (
  $sethostname = true,
  $proxy_ips   = [ '127.0.0.1' ],
  $header      = 'X-Forwarded-For',
  $template    = 'apache/mod/rpaf.conf.erb'
) {
  include ::apache
  ::apache::mod { 'rpaf': }

  # Template uses:
  # - $sethostname
  # - $proxy_ips
  # - $header
  file { 'rpaf.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/rpaf.conf",
    mode    => $::apache::file_mode,
    content => template($template),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
