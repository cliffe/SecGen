class apache::mod::ldap (
  $apache_version                                  = undef,
  $package_name                                    = undef,
  $ldap_trusted_global_cert_file                   = undef,
  Optional[String] $ldap_trusted_global_cert_type  = 'CA_BASE64',
  $ldap_shared_cache_size                          = undef,
  $ldap_cache_entries                              = undef,
  $ldap_cache_ttl                                  = undef,
  $ldap_opcache_entries                            = undef,
  $ldap_opcache_ttl                                = undef,
){

  include ::apache
  $_apache_version = pick($apache_version, $apache::apache_version)
  ::apache::mod { 'ldap':
    package => $package_name,
  }
  # Template uses $_apache_version
  file { 'ldap.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/ldap.conf",
    mode    => $::apache::file_mode,
    content => template('apache/mod/ldap.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
