class apache::mod::authnz_pam {
  include ::apache
  ::apache::mod { 'authnz_pam': }
}
