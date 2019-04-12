class apache::mod::lookup_identity {
  include ::apache
  ::apache::mod { 'lookup_identity': }
}
