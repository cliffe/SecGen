#
class mysql::server::install {

  if $mysql::server::package_manage {

    package { 'mysql-server':
      ensure          => $mysql::server::package_ensure,
      install_options => $mysql::server::install_options,
      name            => $mysql::server::package_name,
    }
  }

}
