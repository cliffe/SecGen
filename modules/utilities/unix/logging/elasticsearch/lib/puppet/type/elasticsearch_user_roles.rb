Puppet::Type.newtype(:elasticsearch_user_roles) do
  desc 'Type to model Elasticsearch user roles.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'User name.'
  end

  newproperty(:roles, :array_matching => :all) do
    desc 'Array of roles that the user should belong to.'
    def insync?(is)
      is.sort == should.sort
    end
  end

  autorequire(:elasticsearch_user) do
    self[:name]
  end
end
