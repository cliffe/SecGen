Puppet::Type.newtype(:elasticsearch_role) do
  desc 'Type to model Elasticsearch roles.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Role name.'

    newvalues(/^[a-zA-Z_]{1}[-\w@.$]{0,29}$/)
  end

  newproperty(:privileges) do
    desc 'Security privileges of the given role.'
  end
end
