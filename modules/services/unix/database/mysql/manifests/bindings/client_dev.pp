# @summary
#   Private class for installing client development bindings
#
# @api private
#
class mysql::bindings::client_dev {

  if $mysql::bindings::client_dev_package_name {
    package { 'mysql-client_dev':
      ensure          => $mysql::bindings::client_dev_package_ensure,
      install_options => $mysql::bindings::install_options,
      name            => $mysql::bindings::client_dev_package_name,
      provider        => $mysql::bindings::client_dev_package_provider,
    }
  } else {
    warning(translate('No MySQL client development package configured for %{os}.', {'os' => $::operatingsystem }))
  }

}
