class apache::mod::itk (
  $startservers        = '8',
  $minspareservers     = '5',
  $maxspareservers     = '20',
  $serverlimit         = '256',
  $maxclients          = '256',
  $maxrequestsperchild = '4000',
  $apache_version      = undef,
) {
  include ::apache

  $_apache_version = pick($apache_version, $apache::apache_version)

  if defined(Class['apache::mod::event']) {
    fail('May not include both apache::mod::itk and apache::mod::event on the same node')
  }
  if defined(Class['apache::mod::peruser']) {
    fail('May not include both apache::mod::itk and apache::mod::peruser on the same node')
  }
  if versioncmp($_apache_version, '2.4') < 0 {
    if defined(Class['apache::mod::prefork']) {
      fail('May not include both apache::mod::itk and apache::mod::prefork on the same node')
    }
  } else {
    # prefork is a requirement for itk in 2.4; except on FreeBSD and Gentoo, which are special
    if $::osfamily =~ /^(FreeBSD|Gentoo)/ {
      if defined(Class['apache::mod::prefork']) {
        fail('May not include both apache::mod::itk and apache::mod::prefork on the same node')
      }
    } else {
      if ! defined(Class['apache::mod::prefork']) {
        include ::apache::mod::prefork
      }
    }
  }
  if defined(Class['apache::mod::worker']) {
    fail('May not include both apache::mod::itk and apache::mod::worker on the same node')
  }
  File {
    owner => 'root',
    group => $::apache::params::root_group,
    mode  => $::apache::file_mode,
  }

  # Template uses:
  # - $startservers
  # - $minspareservers
  # - $maxspareservers
  # - $serverlimit
  # - $maxclients
  # - $maxrequestsperchild
  file { "${::apache::mod_dir}/itk.conf":
    ensure  => file,
    mode    => $::apache::file_mode,
    content => template('apache/mod/itk.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }

  case $::osfamily {
    'redhat': {
      package { 'httpd-itk':
        ensure => present,
      }
      if versioncmp($_apache_version, '2.4') >= 0 {
        ::apache::mpm{ 'itk':
          apache_version => $_apache_version,
        }
      }
      else {
        file_line { '/etc/sysconfig/httpd itk enable':
          ensure  => present,
          path    => '/etc/sysconfig/httpd',
          line    => 'HTTPD=/usr/sbin/httpd.itk',
          match   => '#?HTTPD=/usr/sbin/httpd.itk',
          require => Package['httpd'],
          notify  => Class['apache::service'],
        }
      }
    }
    'debian', 'freebsd': {
      apache::mpm{ 'itk':
        apache_version => $_apache_version,
      }
    }
    'gentoo': {
      ::portage::makeconf { 'apache2_mpms':
        content => 'itk',
      }
    }
    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }
}
