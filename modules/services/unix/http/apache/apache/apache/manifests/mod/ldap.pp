class apache::mod::ldap (
  $apache_version                = $::apache::apache_version,
  $ldap_trusted_global_cert_file = undef,
  $ldap_trusted_global_cert_type = 'CA_BASE64',
){
  if ($ldap_trusted_global_cert_file) {
    validate_string($ldap_trusted_global_cert_type)
  }
  ::apache::mod { 'ldap': }
  # Template uses $apache_version
  file { 'ldap.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/ldap.conf",
    content => template('apache/mod/ldap.conf.erb'),
    require => Exec["mkdir ${::apache::mod_dir}"],
    before  => File[$::apache::mod_dir],
    notify  => Class['apache::service'],
  }
}
