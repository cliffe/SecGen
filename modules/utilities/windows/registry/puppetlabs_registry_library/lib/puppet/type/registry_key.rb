require 'puppet/type'
begin
  require "puppet_x/puppetlabs/registry"
rescue LoadError => detail
  require 'pathname' # JJM WORK_AROUND #14073 and #7788
  require Pathname.new(__FILE__).dirname + "../../" + "puppet_x/puppetlabs/registry"
end

Puppet::Type.newtype(:registry_key) do
  @doc = <<-EOT
    Manages registry keys on Windows systems.

    Keys within HKEY_LOCAL_MACHINE (hklm) or HKEY_CLASSES_ROOT (hkcr) are
    supported.  Other predefined root keys, e.g. HKEY_USERS, are not
    currently supported.

    If Puppet creates a registry key, Windows will automatically create any
    necessary parent registry keys that do not exist.

    Puppet will not recursively delete registry keys.

    **Autorequires:** Any parent registry key managed by Puppet will be
    autorequired.
EOT

  def self.title_patterns
    [ [ /^(.*?)\Z/m, [ [ :path, lambda{|x| x} ] ] ] ]
  end

  ensurable

  newparam(:path, :namevar => true) do
    desc "The path to the registry key to manage.  For example; 'HKLM\Software',
      'HKEY_LOCAL_MACHINE\Software\Vendor'.  If Puppet is running on a 64-bit
      system, the 32-bit registry key can be explicitly managed using a
      prefix.  For example: '32:HKLM\Software'"

    validate do |path|
      PuppetX::Puppetlabs::Registry::RegistryKeyPath.new(path).valid?
    end
    munge do |path|
      reg_path = PuppetX::Puppetlabs::Registry::RegistryKeyPath.new(path)
      # Windows is case insensitive and case preserving.  We deal with this by
      # aliasing resources to their downcase values.  This is inspired by the
      # munge block in the alias metaparameter.
      if @resource.catalog
        reg_path.aliases.each do |alt_name|
          @resource.catalog.alias(@resource, alt_name)
        end
      else
        Puppet.debug "Resource has no associated catalog.  Aliases are not being set for #{@resource.to_s}"
      end
      reg_path.canonical
    end
  end

  # REVISIT - Make a common parameter for boolean munging and validation.  This will be used
  # By both registry_key and registry_value types.
  newparam(:purge_values, :boolean => true) do
    desc "Whether to delete any registry value associated with this key that is
    not being managed by puppet."

    newvalues(:true, :false)
    defaultto false

    validate do |value|
      case value
      when true, /^true$/i, :true, false, /^false$/i, :false, :undef, nil
        true
      else
        # We raise an ArgumentError and not a Puppet::Error so we get manifest
        # and line numbers in the error message displayed to the user.
        raise ArgumentError.new("Validation Error: purge_values must be true or false, not #{value}")
      end
    end

    munge do |value|
      case value
      when true, /^true$/i, :true
        true
      else
        false
      end
    end
  end

  # Autorequire the nearest ancestor registry_key found in the catalog.
  autorequire(:registry_key) do
    req = []
    path = PuppetX::Puppetlabs::Registry::RegistryKeyPath.new(value(:path))
    # It is important to match against the downcase value of the path because
    # other resources are expected to alias themselves to the downcase value so
    # that we respect the case insensitive and preserving nature of Windows.
    if found = path.enum_for(:ascend).find { |p| catalog.resource(:registry_key, p.to_s.downcase) }
      req << found.to_s.downcase
    end
    req
  end

  def eval_generate
    # This value will be given post-munge so we can assume it will be a ruby true or false object
    return [] unless value(:purge_values)

    # get the "should" names of registry values associated with this key
    should_values = catalog.relationship_graph.direct_dependents_of(self).select {|dep| dep.type == :registry_value }.map do |reg|
      PuppetX::Puppetlabs::Registry::RegistryValuePath.new(reg.parameter(:path).value).valuename
    end

    # get the "is" names of registry values associated with this key
    is_values = provider.values

    # create absent registry_value resources for the complement
    resources = []
    (is_values - should_values).each do |name|
      resources << Puppet::Type.type(:registry_value).new(:path => "#{self[:path]}\\#{name}", :ensure => :absent, :catalog => catalog)
    end
    resources
  end
end
