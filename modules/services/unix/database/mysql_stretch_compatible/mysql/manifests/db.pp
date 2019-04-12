# @summary
#   Create and configure a MySQL database.
#
# @example Create a database
#   mysql::db { 'mydb':
#     user     => 'myuser',
#     password => 'mypass',
#     host     => 'localhost',
#     grant    => ['SELECT', 'UPDATE'],
#   }
#
# @param user
#   The user for the database you're creating.
# @param password
#   The password for $user for the database you're creating.
# @param tls_options
#   The tls_options for $user for the database you're creating.
# @param dbname
#   The name of the database to create.
# @param charset
#   The character set for the database.
# @param collate
#   The collation for the database.
# @param host
#   The host to use as part of user@host for grants.
# @param grant
#   The privileges to be granted for user@host on the database.
# @param grant_options
#   The grant_options for the grant for user@host on the database.
# @param sql
#   The path to the sqlfile you want to execute. This can be single file specified as string, or it can be an array of strings.
# @param enforce_sql
#   Specifies whether executing the sqlfiles should happen on every run. If set to false, sqlfiles only run once.
# @param ensure
#   Specifies whether to create the database. Valid values are 'present', 'absent'. Defaults to 'present'.
# @param import_timeout
#   Timeout, in seconds, for loading the sqlfiles. Defaults to 300.
# @param import_cat_cmd
#   Command to read the sqlfile for importing the database. Useful for compressed sqlfiles. For example, you can use 'zcat' for .gz files.
#
define mysql::db (
  $user,
  $password,
  $tls_options                                = undef,
  $dbname                                     = $name,
  $charset                                    = 'utf8',
  $collate                                    = 'utf8_general_ci',
  $host                                       = 'localhost',
  $grant                                      = 'ALL',
  $grant_options                              = undef,
  Optional[Variant[Array, Hash, String]] $sql = undef,
  $enforce_sql                                = false,
  Enum['absent', 'present'] $ensure           = 'present',
  $import_timeout                             = 300,
  $import_cat_cmd                             = 'cat',
) {

  $table = "${dbname}.*"

  $sql_inputs = join([$sql], ' ')

  include '::mysql::client'

  $db_resource = {
    ensure   => $ensure,
    charset  => $charset,
    collate  => $collate,
    provider => 'mysql',
    require  => [ Class['mysql::client'] ],
  }
  ensure_resource('mysql_database', $dbname, $db_resource)

  $user_resource = {
    ensure        => $ensure,
    password_hash => mysql::password($password),
    tls_options   => $tls_options,
  }
  ensure_resource('mysql_user', "${user}@${host}", $user_resource)

  if $ensure == 'present' {
    mysql_grant { "${user}@${host}/${table}":
      privileges => $grant,
      provider   => 'mysql',
      user       => "${user}@${host}",
      table      => $table,
      options    => $grant_options,
      require    => [
        Mysql_database[$dbname],
        Mysql_user["${user}@${host}"],
      ],
    }

    $refresh = ! $enforce_sql

    if $sql {
      exec{ "${dbname}-import":
        command     => "${import_cat_cmd} ${sql_inputs} | mysql ${dbname}",
        logoutput   => true,
        environment => "HOME=${::root_home}",
        refreshonly => $refresh,
        path        => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin',
        require     => Mysql_grant["${user}@${host}/${table}"],
        subscribe   => Mysql_database[$dbname],
        timeout     => $import_timeout,
      }
    }
  }
}
