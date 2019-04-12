require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mysql'))
Puppet::Type.type(:mysql_grant).provide(:mysql, :parent => Puppet::Provider::Mysql) do

  desc 'Set grants for users in MySQL.'

  def self.instances
    instances = []
    users.select{ |user| user =~ /.+@/ }.collect do |user|
      user_string = self.cmd_user(user)
      query = "SHOW GRANTS FOR #{user_string};"
      begin
        grants = mysql([defaults_file, "-NBe", query].compact)
      rescue Puppet::ExecutionFailure => e
        # Silently ignore users with no grants. Can happen e.g. if user is
        # defined with fqdn and server is run with skip-name-resolve. Example:
        # Default root user created by mysql_install_db on a host with fqdn
        # of myhost.mydomain.my: root@myhost.mydomain.my, when MySQL is started
        # with --skip-name-resolve.
        if e.inspect =~ /There is no such grant defined for user/
          next
        else
          raise Puppet::Error, "#mysql had an error ->  #{e.inspect}"
        end
      end
      # Once we have the list of grants generate entries for each.
      grants.each_line do |grant|
        # Match the munges we do in the type.
        munged_grant = grant.delete("'").delete("`").delete('"')
        # Matching: GRANT (SELECT, UPDATE) PRIVILEGES ON (*.*) TO ('root')@('127.0.0.1') (WITH GRANT OPTION)
        if match = munged_grant.match(/^GRANT\s(.+)\sON\s(.+)\sTO\s(.*)@(.*?)(\s.*)?$/)
          privileges, table, user, host, rest = match.captures
          table.gsub!('\\\\', '\\')

          # split on ',' if it is not a non-'('-containing string followed by a
          # closing parenthesis ')'-char - e.g. only split comma separated elements not in
          # parentheses
          stripped_privileges = privileges.strip.split(/\s*,\s*(?![^(]*\))/).map do |priv|
            # split and sort the column_privileges in the parentheses and rejoin
            if priv.include?('(')
              type, col=priv.strip.split(/\s+|\b/,2)
              type.upcase + " (" + col.slice(1...-1).strip.split(/\s*,\s*/).sort.join(', ') + ")"
            else
              # Once we split privileges up on the , we need to make sure we
              # shortern ALL PRIVILEGES to just all.
              priv == 'ALL PRIVILEGES' ? 'ALL' : priv.strip
            end
          end
          # Same here, but to remove OPTION leaving just GRANT.
          options = ['GRANT'] if rest.match(/WITH\sGRANT\sOPTION/)
          # fix double backslash that MySQL prints, so resources match
          table.gsub!("\\\\", "\\")
          # We need to return an array of instances so capture these
          instances << new(
              :name       => "#{user}@#{host}/#{table}",
              :ensure     => :present,
              :privileges => stripped_privileges.sort,
              :table      => table,
              :user       => "#{user}@#{host}",
              :options    => options
          )
        end
      end
    end
    return instances
  end

  def self.prefetch(resources)
    users = instances
    resources.keys.each do |name|
      if provider = users.find { |user| user.name == name }
        resources[name].provider = provider
      end
    end
  end

  def grant(user, table, privileges, options)
    user_string = self.class.cmd_user(user)
    priv_string = self.class.cmd_privs(privileges)
    table_string = self.class.cmd_table(table)
    query = "GRANT #{priv_string}"
    query << " ON #{table_string}"
    query << " TO #{user_string}"
    query << self.class.cmd_options(options) unless options.nil?
    mysql([defaults_file, '-e', query].compact)
  end

  def create
    grant(@resource[:user], @resource[:table], @resource[:privileges], @resource[:options])

    @property_hash[:ensure]     = :present
    @property_hash[:table]      = @resource[:table]
    @property_hash[:user]       = @resource[:user]
    @property_hash[:options]    = @resource[:options] if @resource[:options]
    @property_hash[:privileges] = @resource[:privileges]

    exists? ? (return true) : (return false)
  end

  def revoke(user, table, revoke_privileges = ['ALL'])
    user_string = self.class.cmd_user(user)
    table_string = self.class.cmd_table(table)
    priv_string = self.class.cmd_privs(revoke_privileges)
    # revoke grant option needs to be a extra query, because
    # "REVOKE ALL PRIVILEGES, GRANT OPTION [..]" is only valid mysql syntax
    # if no ON clause is used.
    # It hast to be executed before "REVOKE ALL [..]" since a GRANT has to
    # exist to be executed successfully
    if revoke_privileges.include? 'ALL'
      query = "REVOKE GRANT OPTION ON #{table_string} FROM #{user_string}"
      mysql([defaults_file, '-e', query].compact)
    end
    query = "REVOKE #{priv_string} ON #{table_string} FROM #{user_string}"
    mysql([defaults_file, '-e', query].compact)
  end

  def destroy
    # if the user was dropped, it'll have been removed from the user hash
    # as the grants are alraedy removed by the DROP statement
    if self.class.users.include? @property_hash[:user]
      revoke(@property_hash[:user], @property_hash[:table])
    end
    @property_hash.clear

    exists? ? (return false) : (return true)
  end

  def exists?
    @property_hash[:ensure] == :present || false
  end

  def flush
    @property_hash.clear
    mysql([defaults_file, '-NBe', 'FLUSH PRIVILEGES'].compact)
  end

  mk_resource_methods

  def diff_privileges(privileges_old, privileges_new)
    diff = {:revoke => Array.new, :grant => Array.new}
    if privileges_old.include? 'ALL'
      diff[:revoke] = privileges_old
      diff[:grant] = privileges_new
    elsif privileges_new.include? 'ALL'
      diff[:grant] = privileges_new
    else
      diff[:revoke] = privileges_old - privileges_new
      diff[:grant] = privileges_new - privileges_old
    end
    return diff
  end

  def privileges=(privileges)
    diff = diff_privileges(@property_hash[:privileges], privileges)
    if not diff[:revoke].empty?
      revoke(@property_hash[:user], @property_hash[:table], diff[:revoke])
    end
    if not diff[:grant].empty?
      grant(@property_hash[:user], @property_hash[:table], diff[:grant], @property_hash[:options])
    end
    @property_hash[:privileges] = privileges
    self.privileges
  end

  def options=(options)
    revoke(@property_hash[:user], @property_hash[:table])
    grant(@property_hash[:user], @property_hash[:table], @property_hash[:privileges], options)
    @property_hash[:options] = options

    self.options
  end

end
