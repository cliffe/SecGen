class apache::mod::fastcgi {
  include ::apache

  # Debian specifies it's fastcgi lib path, but RedHat uses the default value
  # with no config file
  $fastcgi_lib_path = $::apache::params::fastcgi_lib_path

  ::apache::mod { 'fastcgi': }

  if $fastcgi_lib_path {
    # Template uses:
    # - $fastcgi_server
    # - $fastcgi_socket
    # - $fastcgi_dir
    file { 'fastcgi.conf':
      ensure  => file,
      path    => "${::apache::mod_dir}/fastcgi.conf",
      mode    => $::apache::file_mode,
      content => template('apache/mod/fastcgi.conf.erb'),
      require => Exec["mkdir ${::apache::mod_dir}"],
      before  => File[$::apache::mod_dir],
      notify  => Class['apache::service'],
    }
  }

}
