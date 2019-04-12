Puppet::Type.newtype(:kibana_plugin) do
  @doc = 'Manages Kibana plugins.'

  ensurable do
    desc 'Whether the plugin should be present or absent.'

    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Simple name of the Kibana plugin (not a URL or file path).'
  end

  newparam(:organization) do
    desc 'Plugin organization to use when installing 4.x-style plugins.'
  end

  newparam(:url) do
    desc 'URL to use when fetching plugin for installation.'
  end

  newproperty(:version) do
    desc 'Installed plugin version.'
  end

  autorequire(:package) do
    self[:ensure] != :absent ? 'kibana' : []
  end

  validate do
    if self[:ensure] != :absent and !self[:organization].nil? and self[:version].nil?
      raise Puppet::Error, 'version must be set if organization is set'
    end
  end
end
