class apache::mod::authn_core(
  $apache_version = $::apache::apache_version
) {
  if versioncmp($apache_version, '2.4') >= 0 {
    ::apache::mod { 'authn_core': }
  }
}
