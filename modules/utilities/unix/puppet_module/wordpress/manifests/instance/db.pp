define wordpress::instance::db (
  $create_db,
  $create_db_user,
  $db_name,
  $db_host,
  $db_user,
  $db_password,
) {
  validate_bool($create_db,$create_db_user)
  validate_string($db_name,$db_host,$db_user,$db_password)

  ## Set up DB using puppetlabs-mysql defined type
  if $create_db {
    mysql_database { "${db_host}/${db_name}":
      name => $db_name,
      charset => 'utf8',
    }
  }
  if $create_db_user {
    mysql_user { "${db_user}@${db_host}":
      password_hash => mysql_password($db_password),
    }
    mysql_grant { "${db_user}@${db_host}/${db_name}.*":
      table      => "${db_name}.*",
      user       => "${db_user}@${db_host}",
      privileges => ['ALL'],
    }
  }

}
