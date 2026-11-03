require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mysql'))
Puppet::Type.type(:mysql_datadir).provide(:mysql, parent: Puppet::Provider::Mysql) do
  desc 'manage data directories for mysql instances'

  initvars

  # Make sure we find mysqld on CentOS and mysql_install_db on Gentoo and Solaris 11
  ENV['PATH'] = [
    ENV['PATH'],
    '/usr/libexec',
    '/usr/share/mysql/scripts',
    '/opt/rh/rh-mysql57/root/usr/bin',
    '/opt/rh/rh-mysql57/root/usr/libexec',
    '/opt/rh/rh-mysql56/root/usr/bin',
    '/opt/rh/rh-mysql56/root/usr/libexec',
    '/opt/rh/rh-mariadb101/root/usr/bin',
    '/opt/rh/rh-mariadb101/root/usr/libexec',
    '/opt/rh/rh-mariadb100/root/usr/bin',
    '/opt/rh/rh-mariadb100/root/usr/libexec',
    '/opt/rh/mysql55/root/usr/bin',
    '/opt/rh/mysql55/root/usr/libexec',
    '/opt/rh/mariadb55/root/usr/bin',
    '/opt/rh/mariadb55/root/usr/libexec',
    '/usr/mysql/5.5/bin',
    '/usr/mysql/5.6/bin',
    '/usr/mysql/5.7/bin',
  ].join(':')

  commands mysqld: 'mysqld'
  optional_commands mysql_install_db: 'mysql_install_db'
  # rubocop:disable Lint/UselessAssignment
  def create
    name                     = @resource[:name]
    insecure                 = @resource.value(:insecure) || true
    defaults_extra_file      = @resource.value(:defaults_extra_file)
    user                     = @resource.value(:user) || 'mysql'
    basedir                  = @resource.value(:basedir)
    datadir                  = @resource.value(:datadir) || @resource[:name]
    log_error                = @resource.value(:log_error) || '/var/tmp/mysqld_initialize.log'
    # rubocop:enable Lint/UselessAssignment
    unless defaults_extra_file.nil?
      unless File.exist?(defaults_extra_file)
        raise ArgumentError, _('Defaults-extra-file %{file} is missing.') % { file: defaults_extra_file }
      end
      defaults_extra_file = "--defaults-extra-file=#{defaults_extra_file}"
    end

    initialize = if insecure == true
                   '--initialize-insecure'
                 else
                   '--initialize'
                 end

    opts = [defaults_extra_file]
    ['basedir', 'datadir', 'user'].each do |opt|
      val = eval(opt) # rubocop:disable Security/Eval
      opts << "--#{opt}=#{val}" unless val.nil?
    end

    if mysqld_version.nil?
      debug("Installing MySQL data directory with mysql_install_db #{opts.compact.join(' ')}")
      mysql_install_db(opts.compact)
    elsif newer_than('mysql' => '5.7.6', 'percona' => '5.7.6')
      opts << "--log-error=#{log_error}"
      opts << initialize.to_s
      debug("Initializing MySQL data directory >= 5.7.6 with mysqld: #{opts.compact.join(' ')}")
      mysqld(opts.compact)
    else
      debug("Installing MySQL data directory with mysql_install_db #{opts.compact.join(' ')}")
      mysql_install_db(opts.compact)
    end

    exists?
  end

  def destroy
    name = @resource[:name] # rubocop:disable Lint/UselessAssignment
    raise ArgumentError, _('ERROR: `Resource` can not be removed.')
  end

  def exists?
    datadir = @resource[:datadir]
    File.directory?("#{datadir}/mysql") && (Dir.entries("#{datadir}/mysql") - ['.', '..']).any?
  end

  ##
  ## MySQL datadir properties
  ##

  # Generates method for all properties of the property_hash
  mk_resource_methods
end
