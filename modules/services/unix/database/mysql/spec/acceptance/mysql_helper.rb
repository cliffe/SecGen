def pre_run
  execute_manifest("class { 'mysql::server': root_password => 'password' }", catch_failures: true)
  @mysql_version = (on default, 'mysql --version').output.chomp.match(%r{\d+\.\d+\.\d+})[0]
end

def version_is_greater_than(version)
  Puppet::Util::Package.versioncmp(@mysql_version, version) > 0
end
