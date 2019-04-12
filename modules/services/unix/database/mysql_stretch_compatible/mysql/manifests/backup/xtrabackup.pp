# @summary
#   "Provider" for Percona XtraBackup
# @api private
#
class mysql::backup::xtrabackup (
  $xtrabackup_package_name = $mysql::params::xtrabackup_package_name,
  $backupuser              = undef,
  $backuppassword          = undef,
  $backupdir               = '',
  $maxallowedpacket        = '1M',
  $backupmethod            = 'mysqldump',
  $backupdirmode           = '0700',
  $backupdirowner          = 'root',
  $backupdirgroup          = $mysql::params::root_group,
  $backupcompress          = true,
  $backuprotate            = 30,
  $ignore_events           = true,
  $delete_before_dump      = false,
  $backupdatabases         = [],
  $file_per_database       = false,
  $include_triggers        = true,
  $include_routines        = false,
  $ensure                  = 'present',
  $time                    = ['23', '5'],
  $prescript               = false,
  $postscript              = false,
  $execpath                = '/usr/bin:/usr/sbin:/bin:/sbin',
  $optional_args           = [],
  $additional_cron_args    = ''
) inherits mysql::params {

  ensure_packages($xtrabackup_package_name)

  if $backupuser and $backuppassword {
    mysql_user { "${backupuser}@localhost":
      ensure        => $ensure,
      password_hash => mysql::password($backuppassword),
      require       => Class['mysql::server::root_password'],
    }

    mysql_grant { "${backupuser}@localhost/*.*":
      ensure     => $ensure,
      user       => "${backupuser}@localhost",
      table      => '*.*',
      privileges => [ 'RELOAD', 'PROCESS', 'LOCK TABLES', 'REPLICATION CLIENT' ],
      require    => Mysql_user["${backupuser}@localhost"],
    }
  }

  cron { 'xtrabackup-weekly':
    ensure  => $ensure,
    command => "/usr/local/sbin/xtrabackup.sh ${backupdir} ${additional_cron_args}",
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => '0',
    require => Package[$xtrabackup_package_name],
  }

  cron { 'xtrabackup-daily':
    ensure  => $ensure,
    command => "/usr/local/sbin/xtrabackup.sh --incremental ${backupdir} ${additional_cron_args}",
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    weekday => '1-6',
    require => Package[$xtrabackup_package_name],
  }

  file { 'mysqlbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  }

  file { 'xtrabackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/xtrabackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => $mysql::params::root_group,
    content => template('mysql/xtrabackup.sh.erb'),
  }
}
