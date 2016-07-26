require 'puppet/provider/package'

Puppet::Type.type(:package).newparam(:pipe)
Puppet::Type.type(:package).provide :pecl, :parent => Puppet::Provider::Package do
  desc "PHP pecl support. By default uses the installed channels, but you can specify the path to a pecl package via ``source``."

  has_feature :versionable
  has_feature :upgradeable

  case Facter.value(:operatingsystem)
    when "Solaris"
      commands :peclcmd => "/opt/coolstack/php5/bin/pecl"
    else
      commands :peclcmd => "pecl"
  end

  def self.pecllist(hash)
    command = [command(:peclcmd), "list"]

    begin
      list = execute(command).split("\n").collect do |set|
        if hash[:justme]
          if /^#{hash[:justme]}$/i.match(set)
            if peclhash = peclsplit(set)
              peclhash[:provider] = :peclcmd
              peclhash
            else
              nil
            end
          else
            nil
          end
        else
          if peclhash = peclsplit(set)
            peclhash[:provider] = :peclcmd
            peclhash
          else
            nil
          end
        end
      end.reject { |p| p.nil? }
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list pecls: %s" % detail
    end

    if hash[:justme]
      return list.shift
    else
      return list
    end
  end

  def self.peclsplit(desc)
    desc.strip!

    case desc
    when /^INSTALLED/ then return nil
    when /No packages installed from channel/i then return nil
    when /^=/ then return nil
    when /^PACKAGE/ then return nil
    when /\[1m/ then return nil       # Newer versions of PEAR use colorized output
    when /^(\S+)\s+(\S+)\s+\S+/ then
      name = $1
      version = $2

      return {
        :name => "pecl-#{name.downcase}",
        :ensure => version
      }
    else
      Puppet.warning "Could not match %s" % desc
      nil
    end
  end

  def self.instances
    pecllist(:local => true).collect do |hash|
      new(hash)
    end
  end

  def peclname
    self.name.sub('pecl-', '').downcase
  end

  def install(useversion = true)
    command = ["upgrade"]

    if source = @resource[:source]
      command << source
    else
      if (! @resource.should(:ensure).is_a? Symbol) and useversion
        command << '-f'
        command << "#{self.peclname}-#{@resource.should(:ensure)}"
      else
        command << self.peclname
      end
    end

    if pipe = @resource[:pipe]
        command << "<<<"
        command << @resource[:pipe]
    end

    peclcmd(*command)
  end

  def latest
    version = ''
    command = [command(:peclcmd), "remote-info", self.peclname]
    list = execute(command).each_line do |set|
      if set =~ /^Latest/
        version = set.split[1]
      end
    end

    return version
  end

  def query
    self.class.pecllist(:justme => self.peclname)
  end

  def uninstall
    output = peclcmd "uninstall", self.peclname
    if output =~ /^uninstall ok/
    else
      raise Puppet::Error, output
    end
  end

  def update
    self.install(false)
  end
end
