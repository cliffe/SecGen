# Configure the PostgreSQL arbitrary-file-read misconfiguration.
#
# The required postgresql service module installs, configures and starts the
# cluster. In a scenario this module shares the service's connection datastores
# (username, password, database_name, auth_method) and the service's
# listen_addresses is set to '*', so the service itself exposes the cluster on
# every interface and writes the matching pg_hba.conf rules for the role. Doing
# the exposure in the service module (rather than overriding listen_addresses
# and appending a pg_hba rule here) keeps a single source of truth: the service
# binds '*', its pg_hba role rules sit ahead of its loopback catch-all, and the
# role's password is encrypted with the server default (scram-sha-256) that the
# pg_hba method expects. The one dangerous thing this class adds is the grant.
#
# Each SecGen module is applied as its own separate puppet run, so this catalog
# cannot reference the service module's classes. The required postgresql service
# module runs first — by the time this class is applied the cluster is installed,
# configured and running — so ordering here is purely internal.
class postgres_readfile::config {
  $secgen_parameters = secgen_functions::get_parameters($::base64_inputs_file)
  $username          = $secgen_parameters['username'][0]
  $password          = $secgen_parameters['password'][0]
  $database_name     = $secgen_parameters['database_name'][0]
  $auth_method       = $secgen_parameters['auth_method'][0]
  $storage_directory = $secgen_parameters['storage_directory'][0]
  $leaked_filenames  = $secgen_parameters['leaked_filenames']
  $strings_to_leak   = $secgen_parameters['strings_to_leak']

  # Encrypt the role password with the method the shared pg_hba rule expects.
  # The PostgreSQL 15 server default is scram-sha-256, which the service module
  # relies on; match it unless the scenario asked for md5 explicitly.
  $pw_encryption = $auth_method ? {
    'md5'   => 'md5',
    default => 'scram-sha-256',
  }

  $setup_sql = '/var/lib/postgresql/secgen_readfile_setup.sql'

  # Wait for the cluster to be accepting connections. The service module leaves
  # it running; this is cheap insurance before psql runs.
  exec { 'secgen-readfile-wait':
    command   => '/usr/bin/pg_isready -q -p 5432',
    tries     => 15,
    try_sleep => 2,
  }

  # Ensure the login role exists, grant it pg_read_server_files (membership of
  # this predefined role lets COPY ... FROM read any file the database process
  # can reach) and ensure it owns its database (needed for the temp table COPY
  # stages the read in). The role/database are normally created by the service
  # module from the shared datastores; the SQL is idempotent either way. It
  # holds the password, so it is removed once psql has run it.
  file { $setup_sql:
    ensure    => file,
    owner     => 'postgres',
    group     => 'postgres',
    mode      => '0600',
    content   => template('postgres_readfile/readfile_setup.sql.erb'),
    show_diff => false,
    require   => Exec['secgen-readfile-wait'],
  }

  exec { 'secgen-readfile-setup':
    command  => "/usr/sbin/runuser -u postgres -- /usr/bin/psql -p 5432 -v ON_ERROR_STOP=1 -q -f ${setup_sql}; rc=\$?; rm -f ${setup_sql}; exit \$rc",
    provider => shell,
    require  => File[$setup_sql],
  }

  # Plant the flag at a server-readable path. mode 0644 lets the database
  # process (the postgres user) read it; leak_files creates the directory.
  ::secgen_functions::leak_files { 'postgres_readfile_flag':
    storage_directory => $storage_directory,
    leaked_filenames  => $leaked_filenames,
    strings_to_leak   => $strings_to_leak,
    leaked_from       => 'postgres_readfile',
    owner             => 'root',
    group             => 'root',
    mode              => '0644',
  }
}
