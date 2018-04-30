class apache::vhosts (
  $vhosts = {},
) {
  include ::apache
  create_resources('apache::vhost', $vhosts)
}
