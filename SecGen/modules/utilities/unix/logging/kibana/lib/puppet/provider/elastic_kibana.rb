require 'json'

# Parent class for Kibana plugin providers.
class Puppet::Provider::ElasticKibana < Puppet::Provider
  class << self
    attr_accessor :home_path
    attr_accessor :install_args
    attr_accessor :plugin_directory
    attr_accessor :remove_args
    attr_accessor :format_url
  end

  # Formats a url for the plugin command-line argument.
  # Necessary since different versions of the Kibana plugin CLI tool accept URL
  # arguments in differing ways.
  #
  # @return [Proc] a lambda that accepts the URL and scope binding and returns
  #   the formatted URL.
  def format_url
    self.class.format_url ||= lambda { |url, _| [url] }
  end

  # Discovers plugins present on the system.
  # This is essentially the same way that the node code does it, so we do it
  # in native ruby to speed up the process and grab arbitrary metadata from the
  # plugin json (which _should_ always be present).
  #
  # @return [Array<Hash>] array of discovered providers on the host.
  def self.present_plugins
    Dir[File.join(home_path, plugin_directory, '*')].select do |directory|
      not File.basename(directory).start_with? '.' \
        and File.exist? File.join(directory, 'package.json')
    end.map do |plugin|
      j = JSON.parse(File.read(File.join(plugin, 'package.json')))
      {
        :name => File.basename(plugin),
        :ensure => :present,
        :provider => name,
        :version => j['version']
      }
    end
  end

  # Enforce the desired state dictated by the properties to flush from the
  # provider.
  #
  # @return nil
  def flush
    if @property_flush[:ensure] == :absent
      # Simply remove the plugin if it should be gone
      run_plugin self.class.remove_args + [resource[:name]]
    else
      unless @property_flush[:version].nil?
        run_plugin self.class.remove_args + [resource[:name]]
      end
      run_plugin self.class.install_args + plugin_url
    end

    set_property_hash
  end

  # Wrap the plugin command in some helper functionality to set the right
  # uid/gid.
  #
  # @return [String] debugging command output.
  def run_plugin(args)
    stdout = execute([command(:plugin)] + args, :uid => 'kibana', :gid => 'kibana')
    stdout.exitstatus.zero? ? debug(stdout) : raise(Puppet::Error, stdout)
  end

  # Helps to format the plugin name for installation.
  # That is, if we have a URL, pass it in correctly to the CLI tool.
  #
  # @return [Array<String>] array of name elements suitable for use in a
  #   Puppet::Provider#execute call.
  def plugin_url
    if not resource[:url].nil?
      format_url.call resource[:url], binding
    elsif not resource[:organization].nil?
      [[resource[:organization], resource[:name], resource[:version]].join('/')]
    else
      [resource[:name]]
    end
  end

  # The rest is normal provider boilerplate.

  # version property setter
  #
  # @return [String] version
  def version=(new_version)
    @property_flush[:version] = new_version
  end

  # version property getter
  #
  # @return [String] version
  def version
    @property_hash[:version]
  end

  # Sets the ensure property in the @property_flush hash.
  #
  # @return [Symbol] :present
  def create
    @property_flush[:ensure] = :present
  end

  # Determine whether this resource is present on the system.
  #
  # @return [Boolean]
  def exists?
    @property_hash[:ensure] == :present
  end

  # Set flushed ensure property to absent.
  #
  # @return [Symbol] :absent
  def destroy
    @property_flush[:ensure] = :absent
  end

  # Repopulates the @property_hash to the on-system state for the provider.
  def set_property_hash
    @property_hash = self.class.present_plugins.detect do |p|
      p[:name] == resource[:name]
    end
  end

  # Finds and returns all present resources on the host.
  #
  # @return [Array] array of providers
  def self.instances
    present_plugins.map do |plugin|
      new plugin
    end
  end

  # Puppet prefetch boilerplate.
  #
  # @param resources [Hash] collection of resources extant on the system
  def self.prefetch(resources)
    instances.each do |prov|
      if (resource = resources[prov.name])
        resource.provider = prov
      end
    end
  end

  # Provider constructor
  def initialize(value = {})
    super(value)
    @property_flush = {}
  end
end
