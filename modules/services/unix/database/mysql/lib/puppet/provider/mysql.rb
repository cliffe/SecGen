# Puppet provider for mysql
class Puppet::Provider::Mysql < Puppet::Provider
  # Without initvars commands won't work.
  initvars

  # Make sure we find mysql commands on CentOS and FreeBSD
  ENV['PATH'] = ENV['PATH'] + ':/usr/libexec:/usr/local/libexec:/usr/local/bin'

  # rubocop:disable Style/HashSyntax
  commands :mysql_raw  => 'mysql'
  commands :mysqld     => 'mysqld'
  commands :mysqladmin => 'mysqladmin'
  # rubocop:enable Style/HashSyntax

  # Optional defaults file
  def self.defaults_file
    "--defaults-extra-file=#{Facter.value(:root_home)}/.my.cnf" if File.file?("#{Facter.value(:root_home)}/.my.cnf")
  end

  def self.mysqld_type
    # find the mysql "dialect" like mariadb / mysql etc.
    mysqld_version_string.scan(%r{mariadb}i) { return 'mariadb' }
    mysqld_version_string.scan(%r{\s\(percona}i) { return 'percona' }
    'mysql'
  end

  def mysqld_type
    self.class.mysqld_type
  end

  def self.mysqld_version_string
    # As the possibility of the mysqld being remote we need to allow the version string to be overridden,
    # this can be done by facter.value as seen below. In the case that it has not been set and the facter
    # value is nil we use the mysql -v command to ensure we report the correct version of mysql for later use cases.
    @mysqld_version_string ||= Facter.value(:mysqld_version) || mysqld('-V')
  end

  def mysqld_version_string
    self.class.mysqld_version_string
  end

  def self.mysqld_version
    # note: be prepared for '5.7.6-rc-log' etc results
    #       versioncmp detects 5.7.6-log to be newer then 5.7.6
    #       this is why we need the trimming.
    mysqld_version_string.scan(%r{\d+\.\d+\.\d+}).first unless mysqld_version_string.nil?
  end

  def mysqld_version
    self.class.mysqld_version
  end

  def self.newer_than(forks_versions)
    forks_versions.keys.include?(mysqld_type) && Puppet::Util::Package.versioncmp(mysqld_version, forks_versions[mysqld_type]) >= 0
  end

  def newer_than(forks_versions)
    self.class.newer_than(forks_versions)
  end

  def defaults_file
    self.class.defaults_file
  end

  def self.mysql_caller(text_of_sql, type)
    if type.eql? 'system'
      mysql_raw([defaults_file, system_database, '-e', text_of_sql].flatten.compact)
    elsif type.eql? 'regular'
      mysql_raw([defaults_file, '-NBe', text_of_sql].flatten.compact)
    else
      raise Puppet::Error, _("#mysql_caller: Unrecognised type '%{type}'" % { type: type })
    end
  end

  def self.users
    mysql_caller("SELECT CONCAT(User, '@',Host) AS User FROM mysql.user", 'regular').split("\n")
  end

  # Optional parameter to run a statement on the MySQL system database.
  def self.system_database
    '--database=mysql'
  end

  def system_database
    self.class.system_database
  end

  # Take root@localhost and munge it to 'root'@'localhost'
  def self.cmd_user(user)
    "'#{user.sub('@', "'@'")}'"
  end

  # Take root.* and return ON `root`.*
  def self.cmd_table(table)
    table_string = ''

    # We can't escape *.* so special case this.
    table_string << if table == '*.*'
                      '*.*'
                    # Special case also for FUNCTIONs and PROCEDUREs
                    elsif table.start_with?('FUNCTION ', 'PROCEDURE ')
                      table.sub(%r{^(FUNCTION|PROCEDURE) (.*)(\..*)}, '\1 `\2`\3')
                    else
                      table.sub(%r{^(.*)(\..*)}, '`\1`\2')
                    end
    table_string
  end

  def self.cmd_privs(privileges)
    return 'ALL PRIVILEGES' if privileges.include?('ALL')
    priv_string = ''
    privileges.each do |priv|
      priv_string << "#{priv}, "
    end
    # Remove trailing , from the last element.
    priv_string.sub(%r{, $}, '')
  end

  # Take in potential options and build up a query string with them.
  def self.cmd_options(options)
    option_string = ''
    options.each do |opt|
      option_string << ' WITH GRANT OPTION' if opt == 'GRANT'
    end
    option_string
  end
end
