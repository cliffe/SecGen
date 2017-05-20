require 'puppet/provider/package'

# PHP PEAR support.
Puppet::Type.type(:package).provide :pear, :parent => Puppet::Provider::Package do
  desc "PHP PEAR support. By default uses the installed channels, but you can specify the path to a pear package via ``source``."

  has_feature :versionable
  has_feature :upgradeable
  has_feature :install_options

  case Facter.value(:operatingsystem)
  when "Solaris"
    commands :pearcmd => "/opt/coolstack/php5/bin/pear"
  else
    commands :pearcmd => "pear"
  end

  def self.pearlist(hash)
    command = [command(:pearcmd), "list", "-a"]
    channel = "pear"

    begin
      list = execute(command).split("\n")
      list = list.collect do |set|
        if match = /INSTALLED PACKAGES, CHANNEL (.*):/i.match(set)
          channel = match[1].downcase
        end

        if hash[:justme]
          if set =~ /^#{hash[:justme]}/
            pearhash = pearsplit(set, channel)
            pearhash[:provider] = :pear
            pearhash
          else
            nil
          end
        else
          if pearhash = pearsplit(set, channel)
            pearhash[:provider] = :pear
            pearhash
          else
            nil
          end
        end
      end.reject { |p| p.nil? }

    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list pears: %s" % detail
    end

    if hash[:justme]
      return list.shift
    else
      return list
    end
  end

  def self.pearsplit(desc, channel)
    desc.strip!

    case desc
      when /^$/ then return nil
      when /^INSTALLED/i then return nil
      when /no packages installed/i then return nil
      when /^=/ then return nil
      when /^PACKAGE/i then return nil
      when /^(\S+)\s+(\S+)\s+(\S+)\s*$/ then
        name = $1
        version = $2
        state = $3
        return {
          :name => "#{channel}/#{name}",
          :ensure => state == 'stable' ? version : state
        }
    else
      Puppet.debug "Could not match '%s'" % desc
      nil
    end
  end

  def self.instances
    pearlist(:local => true).collect do |hash|
      new(hash)
    end
  end

  def install(useversion = true)
    command = ["-D", "auto_discover=1", "upgrade"]
    if @resource[:install_options]
      command << @resource[:install_options]
    else
      command << "--alldeps"
    end

    if source = @resource[:source]
      command << source
    else
      if (! @resource.should(:ensure).is_a? Symbol) and useversion
        command << "#{@resource[:name]}-#{@resource.should(:ensure)}"
      else
        command << @resource[:name]
      end
    end

    pearcmd(*command)
  end

  def latest
    # This always gets the latest version available.
    version = ''
    command = [command(:pearcmd), "remote-info", @resource[:name]]
      list = execute(command).split("\n")
      list = list.collect do |set|
      if set =~ /^Latest/
        version = set.split[1]
      end
    end
    return version
  end

  def query
    self.class.pearlist(:justme => @resource[:name])
  end

  def uninstall
    output = pearcmd "uninstall", @resource[:name]
    if output =~ /^uninstall ok/
    else
      raise Puppet::Error, output
    end
  end

  def update
    self.install(false)
  end

end
