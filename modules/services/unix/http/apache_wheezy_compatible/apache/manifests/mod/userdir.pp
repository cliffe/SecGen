class apache::mod::userdir (
  $home = '/home',
  $dir = 'public_html',
  $disable_root = true,
  $apache_version = undef,
  $options = [ 'MultiViews', 'Indexes', 'SymLinksIfOwnerMatch', 'IncludesNoExec' ],
) {
  include ::apache
  $_apache_version = pick($apache_version, $apache::apache_version)

  ::apache::mod { 'userdir': }

  # Template uses $home, $dir, $disable_root, $_apache_version
  file { 'userdir.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/userdir.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/userdir.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
