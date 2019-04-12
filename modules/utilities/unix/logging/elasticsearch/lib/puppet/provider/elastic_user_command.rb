# Parent provider for Elasticsearch Shield/X-Pack file-based user management
# tools.
class Puppet::Provider::ElasticUserCommand < Puppet::Provider
  attr_accessor :homedir

  # Elasticsearch's home directory.
  #
  # @return String
  def self.homedir
    @homedir ||= case Facter.value('osfamily')
                 when 'OpenBSD'
                   '/usr/local/elasticsearch'
                 else
                   '/usr/share/elasticsearch'
                 end
  end

  # Run the user management command with specified tool arguments.
  def self.command_with_path(args, configdir = nil)
    options = {
      :custom_environment => {
        'ES_PATH_CONF' => configdir || '/etc/elasticsearch'
      }
    }

    execute(
      [command(:users_cli)] + (args.is_a?(Array) ? args : [args]),
      options
    )
  end

  # Gather local file-based users into an array of Hash objects.
  def self.fetch_users
    begin
      output = command_with_path('list')
    rescue Puppet::ExecutionFailure => e
      debug("#fetch_users had an error: #{e.inspect}")
      return nil
    end

    debug("Raw command output: #{output}")
    output.split("\n").select { |u|
      # Keep only expected "user : role1,role2" formatted lines
      u[/^[^:]+:\s+\S+$/]
    }.map { |u|
      # Break into ["user ", " role1,role2"]
      u.split(':').first.strip
    }.map do |user|
      {
        :name => user,
        :ensure => :present,
        :provider => name
      }
    end
  end

  # Fetch an array of provider objects from the the list of local users.
  def self.instances
    fetch_users.map do |user|
      new user
    end
  end

  # Generic prefetch boilerplate.
  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  # Enforce the desired state for this user on-disk.
  def flush
    arguments = []

    case @property_flush[:ensure]
    when :absent
      arguments << 'userdel'
      arguments << resource[:name]
    else
      arguments << 'useradd'
      arguments << resource[:name]
      arguments << '-p' << resource[:password]
    end

    self.class.command_with_path(arguments, resource[:configdir])
    @property_hash = self.class.fetch_users.detect do |u|
      u[:name] == resource[:name]
    end
  end

  # Set this provider's `:ensure` property to `:present`.
  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # Set this provider's `:ensure` property to `:absent`.
  def destroy
    @property_flush[:ensure] = :absent
  end

  # Manually set this user's password.
  def passwd
    self.class.command_with_path(
      [
        'passwd',
        resource[:name],
        '-p', resource[:password]
      ],
      resource[:configdir]
    )
  end
end
