class apache::mod::dav_svn (
  $authz_svn_enabled = false,
) {
  Class['::apache::mod::dav'] -> Class['::apache::mod::dav_svn']
  include ::apache
  include ::apache::mod::dav
  if($::operatingsystem == 'SLES' and $::operatingsystemmajrelease < '12'){
    package { 'subversion-server':
      ensure   => 'installed',
      provider => 'zypper',
    }
  }

  ::apache::mod { 'dav_svn': }

  if $::osfamily == 'Debian' and ($::operatingsystemmajrelease != '6' and $::operatingsystemmajrelease != '10.04' and $::operatingsystemrelease != '10.04' and $::operatingsystemmajrelease != '16.04') {
    $loadfile_name = undef
  } else {
    $loadfile_name = 'dav_svn_authz_svn.load'
  }

  if $authz_svn_enabled {
    ::apache::mod { 'authz_svn':
      loadfile_name => $loadfile_name,
      require       => Apache::Mod['dav_svn'],
    }
  }
}
