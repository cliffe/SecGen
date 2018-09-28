require 'puppet/type'
require 'pathname'
require 'rexml/document'

Puppet::Type.type(:chocolateyconfig).provide(:windows) do
  confine :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  require Pathname.new(__FILE__).dirname + '../../../' + 'puppet_x/chocolatey/chocolatey_common'
  include PuppetX::Chocolatey::ChocolateyCommon

  CONFIG_MINIMUM_SUPPORTED_CHOCO_VERSION = '0.9.10.0'

  commands :chocolatey => PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def properties
    if @property_hash.empty?
      @property_hash = query || { :ensure => ( :absent )}
      @property_hash[:ensure] = :absent if @property_hash.empty?
    end
    @property_hash.dup
  end

  def query
    self.class.configs.each do |config|
      return config.properties if @resource[:name][/\A\S*/].downcase == config.name.downcase
    end

    return {}
  end

  def self.get_configs
    PuppetX::Chocolatey::ChocolateyCommon.set_env_chocolateyinstall

    choco_config = PuppetX::Chocolatey::ChocolateyCommon.choco_config_file
    raise Puppet::ResourceError, "Config file not found for Chocolatey. Please make sure you have Chocolatey installed." if choco_config.nil?
    raise Puppet::ResourceError, "An install was detected, but was unable to locate config file at #{choco_config}." unless PuppetX::Chocolatey::ChocolateyCommon.file_exists?(choco_config)

    Puppet.debug("Gathering sources from '#{choco_config}'.")
    config = REXML::Document.new File.new(choco_config, 'r')

    config.elements.to_a( '//add' )
  end

  def self.get_config(element)
    config = {}
    return config if element.nil?

    config[:name] = element.attributes['key'] if element.attributes['key']
    config[:value] = element.attributes['value'] if element.attributes['value']
    config[:description] = element.attributes['description'] if element.attributes['description']

    config[:ensure] = :present

    Puppet.debug("Loaded config '#{config.inspect}'.")

    config
  end

  def self.configs
    @configs ||=  get_configs.collect do |item|
      config = get_config(item)
      new(config)
    end
  end

  def self.refresh_configs
    @configs = nil
    self.configs
  end

  def self.instances
    configs
  end

  def self.prefetch(resources)
    instances.each do |provider|
      if (resource = resources[provider.name])
        resource.provider = provider
      end
    end
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def validate
    choco_version = Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version)
    if PuppetX::Chocolatey::ChocolateyCommon.file_exists?(PuppetX::Chocolatey::ChocolateyCommon.chocolatey_command) && choco_version < Gem::Version.new(CONFIG_MINIMUM_SUPPORTED_CHOCO_VERSION)
      raise Puppet::ResourceError, "Chocolatey version must be '#{CONFIG_MINIMUM_SUPPORTED_CHOCO_VERSION}' to manage configuration values. Detected '#{choco_version}' as your version. Please upgrade Chocolatey."
    end
  end

  mk_resource_methods

  def flush
    choco_version = Gem::Version.new(PuppetX::Chocolatey::ChocolateyCommon.choco_version)

    args = []
    args << 'config'

    # look at the hash, then flush if present.
    # If all else fails, looks at resource[:ensure]
    property_ensure = @property_hash[:ensure]
    property_ensure = @property_flush[:ensure] if @property_flush[:ensure]
    property_ensure = resource[:ensure] if property_ensure.nil?

    command = 'set'
    command = 'unset' if property_ensure == :absent

    args << command
    args << '--name' << resource[:name]

    if property_ensure != :absent
      args << '--value' << resource[:value]
    end

    begin
      Puppet::Util::Execution.execute([command(:chocolatey), *args])
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "An error occurred running choco. Unable to set Chocolateyconfig[#{self.name}]: #{e}"
    end

    @property_hash.clear
    @property_flush.clear

    self.class.refresh_configs
    @property_hash = query
  end
end
