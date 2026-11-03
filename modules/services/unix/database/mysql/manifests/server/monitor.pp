# @summary
#   This is a helper class to add a monitoring user to the database
#
# @param mysql_monitor_username
#   The username to create for MySQL monitoring.
# @param mysql_monitor_password
#   The password to create for MySQL monitoring.
# @param mysql_monitor_hostname
#   The hostname from which the monitoring user requests are allowed access.
#
class mysql::server::monitor (
  $mysql_monitor_username = '',
  $mysql_monitor_password = '',
  $mysql_monitor_hostname = ''
) {

  Anchor['mysql::server::end'] -> Class['mysql::server::monitor']

  mysql_user { "${mysql_monitor_username}@${mysql_monitor_hostname}":
    ensure        => present,
    password_hash => mysql::password($mysql_monitor_password),
    require       => Class['mysql::server::service'],
  }

  mysql_grant { "${mysql_monitor_username}@${mysql_monitor_hostname}/*.*":
    ensure     => present,
    user       => "${mysql_monitor_username}@${mysql_monitor_hostname}",
    table      => '*.*',
    privileges => [ 'PROCESS', 'SUPER' ],
    require    => Mysql_user["${mysql_monitor_username}@${mysql_monitor_hostname}"],
  }

}
