# @summary
#   Private class for installing python language bindings
#
# @api private
#
class mysql::bindings::python {

  package { 'python-mysqldb':
    ensure          => $mysql::bindings::python_package_ensure,
    install_options => $mysql::bindings::install_options,
    name            => $mysql::bindings::python_package_name,
    provider        => $mysql::bindings::python_package_provider,
  }

}
