class apache::mod::auth_kerb {
  include ::apache
  include ::apache::mod::authn_core
  ::apache::mod { 'auth_kerb': }
}


