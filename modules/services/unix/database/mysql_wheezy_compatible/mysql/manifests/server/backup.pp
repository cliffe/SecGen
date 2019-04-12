# See README.me for usage.
class mysql::server::backup (
  $backupuser         = undef,
  $backuppassword     = undef,
  $backupdir          = undef,
  $backupdirmode      = '0700',
  $backupdirowner     = 'root',
  $backupdirgroup     = 'root',
  $backupcompress     = true,
  $backuprotate       = 30,
  $ignore_events      = true,
  $delete_before_dump = false,
  $backupdatabases    = [],
  $file_per_database  = false,
  $include_routines   = false,
  $include_triggers   = false,
  $ensure             = 'present',
  $time               = ['23', '5'],
  $prescript          = false,
  $postscript         = false,
  $execpath           = '/usr/bin:/usr/sbin:/bin:/sbin',
  $provider           = 'mysqldump',
) {

  if $prescript and $provider =~ /(mysqldump|mysqlbackup)/ {
    warning("The \$prescript option is not currently implemented for the ${provider} backup provider.")
  }

  create_resources('class', {
    "mysql::backup::${provider}" => {
      'backupuser'         => $backupuser,
      'backuppassword'     => $backuppassword,
      'backupdir'          => $backupdir,
      'backupdirmode'      => $backupdirmode,
      'backupdirowner'     => $backupdirowner,
      'backupdirgroup'     => $backupdirgroup,
      'backupcompress'     => $backupcompress,
      'backuprotate'       => $backuprotate,
      'ignore_events'      => $ignore_events,
      'delete_before_dump' => $delete_before_dump,
      'backupdatabases'    => $backupdatabases,
      'file_per_database'  => $file_per_database,
      'include_routines'   => $include_routines,
      'include_triggers'   => $include_triggers,
      'ensure'             => $ensure,
      'time'               => $time,
      'prescript'          => $prescript,
      'postscript'         => $postscript,
      'execpath'           => $execpath,
    }
  })

}
