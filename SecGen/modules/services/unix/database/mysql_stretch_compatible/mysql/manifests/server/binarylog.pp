# @summary
#   Binary log configuration requires the mysql user to be present. This must be done after package install
#
# @api private
#
class mysql::server::binarylog {

  $options = $mysql::server::options
  $includedir = $mysql::server::includedir

  $logbin = pick($options['mysqld']['log-bin'], $options['mysqld']['log_bin'], false)

  if $logbin {
    $logbindir = mysql::dirname($logbin)

    #Stop puppet from managing directory if just a filename/prefix is specified
    if $logbindir != '.' {
      file { $logbindir:
        ensure => directory,
        mode   => '0755',
        owner  => $options['mysqld']['user'],
        group  => $options['mysqld']['user'],
      }
    }
  }
}
