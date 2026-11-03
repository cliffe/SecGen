class apache::mod::userdir (
  $home = undef,
  $dir = undef,
  $disable_root = true,
  $apache_version = undef,
  $path = '/home/*/public_html',
  $overrides = [ 'FileInfo', 'AuthConfig', 'Limit', 'Indexes' ],
  $options = [ 'MultiViews', 'Indexes', 'SymLinksIfOwnerMatch', 'IncludesNoExec' ],
) {
  include ::apache
  $_apache_version = pick($apache_version, $apache::apache_version)

  if $home or $dir {
    $_home = $home ? {
      undef   => '/home',
      default =>  $home,
    }
    $_dir = $dir ? {
      undef   => 'public_html',
      default =>  $dir,
    }
    warning('home and dir are deprecated; use path instead')
    $_path = "${_home}/*/${_dir}"
  } else {
    $_path = $path
  }

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
