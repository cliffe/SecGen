Puppet::Type.newtype(:elasticsearch_role_mapping) do
  desc 'Type to model Elasticsearch role mappings.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Role name.'

    newvalues(/^[a-zA-Z_]{1}[-\w@.$]{0,29}$/)
  end

  newproperty(:mappings, :array_matching => :all) do
    desc 'List of role mappings.'
  end
end
