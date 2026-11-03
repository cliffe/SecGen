# @summary
#   Params class.
#
# @api private
#
class mysql::params {
  $client_package_ensure  = 'present'
  $client_package_manage  = true
  $exec_path              = ''
  # mysql::bindings
  $bindings_enable             = false
  $java_package_ensure         = 'present'
  $java_package_provider       = undef
  $perl_package_ensure         = 'present'
  $perl_package_provider       = undef
  $php_package_ensure          = 'present'
  $php_package_provider        = undef
  $python_package_ensure       = 'present'
  $python_package_provider     = undef
  $ruby_package_ensure         = 'present'
  $ruby_package_provider       = undef
  $client_dev_package_ensure   = 'present'
  $client_dev_package_provider = undef
  $daemon_dev_package_ensure   = 'present'
  $daemon_dev_package_provider = undef

  case $facts['os']['family'] {
    'RedHat': {
      case $facts['os']['name'] {
        'Fedora': {
          if versioncmp($facts['os']['release']['full'], '19') >= 0 or $facts['os']['release']['full'] == 'Rawhide' {
            $provider = 'mariadb'
          } else {
            $provider = 'mysql'
          }
          $python_package_name = 'MySQL-python'
        }
        'Amazon': {
          if versioncmp($facts['os']['release']['full'], '2') >= 0 {
            $provider = 'mariadb'
          } else {
            $provider = 'mysql'
          }
        }
        /^(RedHat|Rocky|CentOS|Scientific|OracleLinux|AlmaLinux)$/: {
          if versioncmp($facts['os']['release']['major'], '7') >= 0 {
            $provider = 'mariadb'
            if versioncmp($facts['os']['release']['major'], '8') >= 0 {
              $xtrabackup_package_name = 'percona-xtrabackup-24'
            }
          } else {
            $provider = 'mysql'
            $xtrabackup_package_name = 'percona-xtrabackup-20'
          }
          if versioncmp($facts['os']['release']['major'], '8') >= 0 {
            $java_package_name   = 'mariadb-java-client'
            $python_package_name = 'python3-PyMySQL'
          } else {
            $java_package_name   = 'mysql-connector-java'
            $python_package_name = 'MySQL-python'
          }
        }
        default: {
          $provider = 'mysql'
        }
      }

      if $provider == 'mariadb' {
        $client_package_name     = 'mariadb'
        $server_package_name     = 'mariadb-server'
        $server_service_name     = 'mariadb'
        $log_error               = '/var/log/mariadb/mariadb.log'
        $config_file             = '/etc/my.cnf.d/server.cnf'
        # mariadb package by default has !includedir set in my.cnf to /etc/my.cnf.d
        $includedir              = undef
        $pidfile                 = '/var/run/mariadb/mariadb.pid'
        $daemon_dev_package_name = 'mariadb-devel'
      } else {
        $client_package_name     = 'mysql'
        $server_package_name     = 'mysql-server'
        $server_service_name     = 'mysqld'
        $log_error               = '/var/log/mysqld.log'
        $config_file             = '/etc/my.cnf'
        $includedir              = '/etc/my.cnf.d'
        $pidfile                 = '/var/run/mysqld/mysqld.pid'
        $daemon_dev_package_name = 'mysql-devel'
      }

      $basedir                 = '/usr'
      $datadir                 = '/var/lib/mysql'
      $root_group              = 'root'
      $mysql_group             = 'mysql'
      $socket                  = '/var/lib/mysql/mysql.sock'
      $ssl_ca                  = '/etc/mysql/cacert.pem'
      $ssl_cert                = '/etc/mysql/server-cert.pem'
      $ssl_key                 = '/etc/mysql/server-key.pem'
      $tmpdir                  = '/tmp'
      $managed_dirs            = undef
      # mysql::bindings
      $perl_package_name       = 'perl-DBD-MySQL'
      $php_package_name        = 'php-mysql'
      $ruby_package_name       = 'ruby-mysql'
      $client_dev_package_name = undef
    }

    'Suse': {
      case $facts['os']['name'] {
        'OpenSuSE': {
          $socket = '/var/run/mysql/mysql.sock'
          $log_error = '/var/log/mysql/mysqld.log'
          $pidfile = '/var/run/mysql/mysqld.pid'
          $ruby_package_name = 'rubygem-mysql'
          $client_package_name = 'mariadb-client'
          $server_package_name = 'mariadb'
          # First service start fails if this is set. Runs fine without
          # it being set, in any case. Leaving it as-is for the mysql.
          $basedir             = undef
        }
        'SLES','SLED': {
          $socket = '/run/mysql/mysql.sock'
          $log_error = '/var/log/mysqld.log'
          $pidfile = '/var/lib/mysql/mysqld.pid'
          $ruby_package_name = 'ruby-mysql'
          $client_package_name = 'mariadb-client'
          $server_package_name = 'mariadb'
          $basedir             = undef
        }
        default: {
          fail("Unsupported platform: puppetlabs-${module_name} currently doesn\'t support ${facts['os']['name']}.")
        }
      }
      $config_file         = '/etc/my.cnf'
      $includedir          = '/etc/my.cnf.d'
      $datadir             = '/var/lib/mysql'
      $root_group          = 'root'
      $mysql_group         = 'mysql'
      $server_service_name = 'mysql'
      $xtrabackup_package_name = 'xtrabackup'

      $ssl_ca              = '/etc/mysql/cacert.pem'
      $ssl_cert            = '/etc/mysql/server-cert.pem'
      $ssl_key             = '/etc/mysql/server-key.pem'
      $tmpdir              = '/tmp'
      $managed_dirs        = undef
      # mysql::bindings
      $java_package_name   = 'mysql-connector-java'
      $perl_package_name   = 'perl-DBD-mysql'
      $php_package_name    = 'apache2-mod_php53'
      $python_package_name = 'python-mysql'
      $client_dev_package_name = 'libmysqlclient-devel'
      $daemon_dev_package_name = 'mysql-devel'
    }

    'Debian': {
      if $facts['os']['name'] == 'Debian' or $facts['os']['name'] == 'Raspbian' or
      ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['major'], '20.04') >= 0) {
        $provider = 'mariadb'
      } else {
        $provider = 'mysql'
      }
      if $provider == 'mariadb' {
        $client_package_name     = 'mariadb-client'
        $server_package_name     = 'mariadb-server'
        $server_service_name     = 'mariadb'
        $client_dev_package_name = 'libmariadbclient-dev'
        $daemon_dev_package_name = 'libmariadbd-dev'
      } else {
        $client_package_name     = 'mysql-client'
        $server_package_name     = 'mysql-server'
        $server_service_name     = 'mysql'
        $client_dev_package_name = 'libmysqlclient-dev'
        $daemon_dev_package_name = 'libmysqld-dev'
      }

      $basedir                 = '/usr'
      $config_file             = '/etc/mysql/my.cnf'
      $includedir              = '/etc/mysql/conf.d'
      # Debian's mariadb packages from 1:11.8.6-5 (what Kali rolling ships)
      # create a new install's system tables in /var/lib/mariadb; only an
      # existing install keeps /var/lib/mysql. Pointing a fresh install at
      # /var/lib/mysql leaves mariadbd with an empty datadir, and it aborts
      # with "Can't open and lock privilege tables: Table 'mysql.db' doesn't
      # exist". The catalog compiles on the guest (puppet apply), so this
      # checks the target VM before the package is installed.
      if $facts['os']['name'] == 'Kali' and !find_file('/var/lib/mysql/mysql') {
        $datadir               = '/var/lib/mariadb'
      } else {
        $datadir               = '/var/lib/mysql'
      }
      $log_error               = '/var/log/mysql/error.log'
      $pidfile                 = '/var/run/mysqld/mysqld.pid'
      $root_group              = 'root'
      $mysql_group             = 'adm'
      $socket                  = '/var/run/mysqld/mysqld.sock'
      $ssl_ca                  = '/etc/mysql/cacert.pem'
      $ssl_cert                = '/etc/mysql/server-cert.pem'
      $ssl_key                 = '/etc/mysql/server-key.pem'
      $tmpdir                  = '/tmp'
      $managed_dirs            = ['tmpdir','basedir','datadir','innodb_data_home_dir','innodb_log_group_home_dir','innodb_undo_directory','innodb_tmpdir']

      # mysql::bindings
      if ($facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['full'], '10') >= 0) or
      ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '20.04') >= 0) {
        $java_package_name   = 'libmariadb-java'
      } else {
        $java_package_name   = 'libmysql-java'
      }
      $perl_package_name   = 'libdbd-mysql-perl'
      if  ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '16.04') >= 0) or
      ($facts['os']['name'] == 'Debian') {
        $php_package_name = 'php-mysql'
      } else {
        $php_package_name = 'php5-mysql'
      }
      if  ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '16.04') < 0) or
      ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '20.04') >= 0) or
      ($facts['os']['name'] == 'Debian') {
        $xtrabackup_package_name = 'percona-xtrabackup-24'
      }
      if ($facts['os']['name'] == 'Ubuntu' and versioncmp($facts['os']['release']['full'], '20.04') >= 0) or
      ($facts['os']['name'] == 'Debian' and versioncmp($facts['os']['release']['full'], '11') >= 0) {
        $python_package_name = 'python3-mysqldb'
      } else {
        $python_package_name = 'python-mysqldb'
      }

      $ruby_package_name   =  $facts['os']['release']['major']  ? {
        '9'     => 'ruby-mysql2', # stretch
        '10'    => 'ruby-mysql2', # buster
        '11'    => 'ruby-mysql2', # bullseye
        '16.04' => 'ruby-mysql', # xenial
        '18.04' => 'ruby-mysql2', # bionic
        '20.04' => 'ruby-mysql2', # focal
        '22.04' => 'ruby-mysql2', # jammy
        default => 'libmysql-ruby',
      }
    }

    'Archlinux': {
      $daemon_dev_package_name = undef
      $client_dev_package_name = undef
      $includedir              = undef
      $client_package_name     = 'mariadb-clients'
      $server_package_name     = 'mariadb'
      $basedir                 = '/usr'
      $config_file             = '/etc/mysql/my.cnf'
      $datadir                 = '/var/lib/mysql'
      $log_error               = '/var/log/mysqld.log'
      $pidfile                 = '/var/run/mysqld/mysqld.pid'
      $root_group              = 'root'
      $mysql_group             = 'mysql'
      $server_service_name     = 'mysqld'
      $socket                  = '/var/lib/mysql/mysql.sock'
      $ssl_ca                  = '/etc/mysql/cacert.pem'
      $ssl_cert                = '/etc/mysql/server-cert.pem'
      $ssl_key                 = '/etc/mysql/server-key.pem'
      $tmpdir                  = '/tmp'
      $managed_dirs            = undef
      # mysql::bindings
      $java_package_name       = 'mysql-connector-java'
      $perl_package_name       = 'perl-dbd-mysql'
      $php_package_name        = undef
      $python_package_name     = 'mysql-python'
      $ruby_package_name       = 'mysql-ruby'
    }

    'Gentoo': {
      $client_package_name = 'virtual/mysql'
      $includedir          = undef
      $server_package_name = 'virtual/mysql'
      $basedir             = '/usr'
      $config_file         = '/etc/mysql/my.cnf'
      $datadir             = '/var/lib/mysql'
      $log_error           = '/var/log/mysql/mysqld.err'
      $pidfile             = '/run/mysqld/mysqld.pid'
      $root_group          = 'root'
      $mysql_group         = 'mysql'
      $server_service_name = 'mysql'
      $socket              = '/run/mysqld/mysqld.sock'
      $ssl_ca              = '/etc/mysql/cacert.pem'
      $ssl_cert            = '/etc/mysql/server-cert.pem'
      $ssl_key             = '/etc/mysql/server-key.pem'
      $tmpdir              = '/tmp'
      $managed_dirs        = undef
      # mysql::bindings
      $java_package_name   = 'dev-java/jdbc-mysql'
      $perl_package_name   = 'dev-perl/DBD-mysql'
      $php_package_name    = undef
      $python_package_name = 'dev-python/mysql-python'
      $ruby_package_name   = 'dev-ruby/mysql-ruby'
    }

    'FreeBSD': {
      $client_package_name = 'databases/mysql57-client'
      $server_package_name = 'databases/mysql57-server'
      $basedir             = '/usr/local'
      $config_file         = '/usr/local/etc/my.cnf'
      $includedir          = '/usr/local/etc/my.cnf.d'
      $datadir             = '/var/db/mysql'
      $log_error           = '/var/log/mysqld.log'
      $pidfile             = '/var/run/mysql.pid'
      $root_group          = 'wheel'
      $mysql_group         = 'mysql'
      $server_service_name = 'mysql-server'
      $socket              = '/var/db/mysql/mysql.sock'
      $ssl_ca              = undef
      $ssl_cert            = undef
      $ssl_key             = undef
      $tmpdir              = '/tmp'
      $managed_dirs        = undef
      # mysql::bindings
      $java_package_name   = 'databases/mysql-connector-java'
      $perl_package_name   = 'p5-DBD-mysql'
      $php_package_name    = 'php5-mysql'
      $python_package_name = 'databases/py-MySQLdb'
      $ruby_package_name   = 'databases/ruby-mysql'
      # The libraries installed by these packages are included in client and server packages, no installation required.
      $client_dev_package_name     = undef
      $daemon_dev_package_name     = undef
    }

    'OpenBSD': {
      $client_package_name = 'mariadb-client'
      $server_package_name = 'mariadb-server'
      $basedir             = '/usr/local'
      $config_file         = '/etc/my.cnf'
      $includedir          = undef
      $datadir             = '/var/mysql'
      $log_error           = "/var/mysql/${facts['networking']['hostname']}.err"
      $pidfile             = '/var/mysql/mysql.pid'
      $root_group          = 'wheel'
      $mysql_group         = '_mysql'
      $server_service_name = 'mysqld'
      $socket              = '/var/run/mysql/mysql.sock'
      $ssl_ca              = undef
      $ssl_cert            = undef
      $ssl_key             = undef
      $tmpdir              = '/tmp'
      $managed_dirs        = undef
      # mysql::bindings
      $java_package_name   = undef
      $perl_package_name   = 'p5-DBD-mysql'
      $php_package_name    = 'php-mysql'
      $python_package_name = 'py-mysql'
      $ruby_package_name   = 'ruby-mysql'
      # The libraries installed by these packages are included in client and server packages, no installation required.
      $client_dev_package_name     = undef
      $daemon_dev_package_name     = undef
    }

    default: {
      case $facts['os']['name'] {
        'Alpine': {
          $client_package_name = 'mariadb-client'
          $server_package_name = 'mariadb'
          $basedir             = '/usr'
          $config_file         = '/etc/mysql/my.cnf'
          $datadir             = '/var/lib/mysql'
          $log_error           = '/var/log/mysqld.log'
          $pidfile             = '/run/mysqld/mysqld.pid'
          $root_group          = 'root'
          $mysql_group         = 'mysql'
          $server_service_name = 'mariadb'
          $socket              = '/run/mysqld/mysqld.sock'
          $ssl_ca              = '/etc/mysql/cacert.pem'
          $ssl_cert            = '/etc/mysql/server-cert.pem'
          $ssl_key             = '/etc/mysql/server-key.pem'
          $tmpdir              = '/tmp'
          $managed_dirs        = undef
          $java_package_name   = undef
          $perl_package_name   = 'perl-dbd-mysql'
          $php_package_name    = 'php7-mysqlnd'
          $python_package_name = 'py-mysqldb'
          $ruby_package_name   = undef
          $client_dev_package_name     = undef
          $daemon_dev_package_name     = undef
        }
        'Amazon': {
          $client_package_name = 'mysql'
          $server_package_name = 'mysql-server'
          $basedir             = '/usr'
          $config_file         = '/etc/my.cnf'
          $includedir          = '/etc/my.cnf.d'
          $datadir             = '/var/lib/mysql'
          $log_error           = '/var/log/mysqld.log'
          $pidfile             = '/var/run/mysqld/mysqld.pid'
          $root_group          = 'root'
          $mysql_group         = 'mysql'
          $server_service_name = 'mysqld'
          $socket              = '/var/lib/mysql/mysql.sock'
          $ssl_ca              = '/etc/mysql/cacert.pem'
          $ssl_cert            = '/etc/mysql/server-cert.pem'
          $ssl_key             = '/etc/mysql/server-key.pem'
          $tmpdir              = '/tmp'
          $managed_dirs        = undef
          # mysql::bindings
          $java_package_name   = 'mysql-connector-java'
          $perl_package_name   = 'perl-DBD-MySQL'
          $php_package_name    = 'php-mysql'
          $python_package_name = 'MySQL-python'
          $ruby_package_name   = 'ruby-mysql'
          # The libraries installed by these packages are included in client and server packages, no installation required.
          $client_dev_package_name     = undef
          $daemon_dev_package_name     = undef
        }

        default: {
          fail("Unsupported platform: puppetlabs-${module_name} currently doesn\'t support ${facts['os']['family']} or ${facts['os']['name']}.")
        }
      }
    }
  }

  case $facts['os']['name'] {
    'Ubuntu': {
      $server_service_provider = 'systemd'
    }
    'Alpine': {
      $server_service_provider = 'rc-service'
    }
    'FreeBSD': {
      $server_service_provider = 'freebsd'
    }
    default: {
      $server_service_provider = undef
    }
  }

  $default_options = {
    'client'          => {
      'port'          => '3306',
      'socket'        => $mysql::params::socket,
    },
    'mysqld_safe'        => {
      'nice'             => '0',
      'log-error'        => $mysql::params::log_error,
      'socket'           => $mysql::params::socket,
    },
    'mysqld-5.0'       => {
      'myisam-recover' => 'BACKUP',
    },
    'mysqld-5.1'       => {
      'myisam-recover' => 'BACKUP',
    },
    'mysqld-5.5'       => {
      'myisam-recover' => 'BACKUP',
      'query_cache_limit'     => '1M',
      'query_cache_size'      => '16M',
    },
    'mysqld-5.6'              => {
      'myisam-recover-options' => 'BACKUP',
      'query_cache_limit'     => '1M',
      'query_cache_size'      => '16M',
    },
    'mysqld-5.7'              => {
      'myisam-recover-options' => 'BACKUP',
      'query_cache_limit'     => '1M',
      'query_cache_size'      => '16M',
    },
    'mysqld'                  => {
      'basedir'               => $mysql::params::basedir,
      'bind-address'          => '127.0.0.1',
      'datadir'               => $mysql::params::datadir,
      'expire_logs_days'      => '10',
      'key_buffer_size'       => '16M',
      'log-error'             => $mysql::params::log_error,
      'max_allowed_packet'    => '16M',
      'max_binlog_size'       => '100M',
      'max_connections'       => '151',
      'pid-file'              => $mysql::params::pidfile,
      'port'                  => '3306',
      'skip-external-locking' => true,
      'socket'                => $mysql::params::socket,
      'ssl'                   => false,
      'ssl-ca'                => $mysql::params::ssl_ca,
      'ssl-cert'              => $mysql::params::ssl_cert,
      'ssl-key'               => $mysql::params::ssl_key,
      'ssl-disable'           => false,
      'thread_cache_size'     => '8',
      'thread_stack'          => '256K',
      'tmpdir'                => $mysql::params::tmpdir,
      'user'                  => 'mysql',
    },
    'mysqldump'             => {
      'max_allowed_packet'  => '16M',
      'quick'               => true,
      'quote-names'         => true,
    },
    'isamchk'      => {
      'key_buffer_size' => '16M',
    },
  }

  if !defined('$xtrabackup_package_name') {
    $xtrabackup_package_name = 'percona-xtrabackup'
  }

  ## Additional graceful failures
  if $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '4' and $facts['os']['name'] != 'Amazon' {
    fail("Unsupported platform: puppetlabs-${module_name} only supports RedHat 6.0 and beyond.")
  }
}
