#
class mysql::server::installdb {

  if $mysql::server::package_manage {

    # Build the initial databases.
    $mysqluser = $mysql::server::options['mysqld']['user']
    $datadir = $mysql::server::options['mysqld']['datadir']
    $basedir = $mysql::server::options['mysqld']['basedir']
    $config_file = $mysql::server::config_file

    if $mysql::server::manage_config_file {
      $_config_file=$config_file
    } else {
      $_config_file=undef
    }

    mysql_datadir { $datadir:
      ensure              => 'present',
      datadir             => $datadir,
      basedir             => $basedir,
      user                => $mysqluser,
      defaults_extra_file => $_config_file,
    }

    if $mysql::server::restart {
      Mysql_datadir[$datadir] {
        notify => Class['mysql::server::service'],
      }
    }
  }

}
