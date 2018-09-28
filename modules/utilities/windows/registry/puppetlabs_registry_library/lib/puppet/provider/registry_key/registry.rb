# REMIND: need to support recursive delete of subkeys & values
begin
  # We expect this to work once Puppet supports Rubygems in #7788
  require "puppet_x/puppetlabs/registry"
  require "puppet_x/puppetlabs/registry/provider_base"
rescue LoadError => detail
  # Work around #7788 (Rubygems support for modules)
  require 'pathname' # JJM WORK_AROUND #14073
  module_base = Pathname.new(__FILE__).dirname
  require module_base + "../../../" + "puppet_x/puppetlabs/registry"
  require module_base + "../../../" + "puppet_x/puppetlabs/registry/provider_base"
end

Puppet::Type.type(:registry_key).provide(:registry) do
  include PuppetX::Puppetlabs::Registry::ProviderBase

  defaultfor :operatingsystem => :windows
  confine    :operatingsystem => :windows

  def self.instances
    hkeys.keys.collect do |hkey|
      new(:provider => :registry, :name => "#{hkey.to_s}")
    end
  end

  def create
    Puppet.debug("Creating registry key #{self}")
    hive.create(subkey, Win32::Registry::KEY_ALL_ACCESS | access) {|reg| true }
  end

  def exists?
    Puppet.debug("Checking existence of registry key #{self}")
    !!hive.open(subkey, Win32::Registry::KEY_READ | access) {|reg| true } rescue false
  end

  def destroy
    Puppet.debug("Destroying registry key #{self}")

    raise ArgumentError, "Cannot delete root key: #{path}" unless subkey

    from_string_to_wide_string(subkey) do |subkey_ptr|
      # hive.hkey returns an integer value that's like a FD
      if RegDeleteKeyExW(hive.hkey, subkey_ptr, access, 0) != 0
        raise "Failed to delete registry key: #{self}"
      end
    end
  end

  def values
    names = []
    # Only try and get the values for this key if the key itself exists.
    if exists? then
      hive.open(subkey, Win32::Registry::KEY_READ | access) do |reg|
        each_value(reg) do |name, type, data| names << name end
      end
    end
    names
  end

  private

  def path
    @path ||= PuppetX::Puppetlabs::Registry::RegistryKeyPath.new(resource.parameter(:path).value)
  end
end
