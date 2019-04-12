require 'puppet/parser/functions'

Puppet::Parser::Functions.newfunction(:ensure_resources,
                                      :type => :statement,
                                      :doc => <<-'ENDOFDOC'
Takes a resource type, title (only hash), and a list of attributes that describe a
resource.

    user { 'dan':
      gid => 'mygroup',
      ensure => present,
    }

An hash of resources should be passed in and each will be created with
the type and parameters specified if it doesn't already exist.

    ensure_resources('user', {'dan' => { gid => 'mygroup', uid => '600' } ,  'alex' => { gid => 'mygroup' }}, {'ensure' => 'present'})

From Hiera Backend:

userlist:
  dan:
    gid: 'mygroup'
 uid: '600'
  alex:
 gid: 'mygroup'

Call:
ensure_resources('user', hiera_hash('userlist'), {'ensure' => 'present'})

ENDOFDOC
) do |vals|
  type, title, params = vals
  raise(ArgumentError, 'Must specify a type') unless type
  raise(ArgumentError, 'Must specify a title') unless title
  params ||= {}

  if title.is_a?(Hash)
    resource_hash = title.dup
    resources = resource_hash.keys

    Puppet::Parser::Functions.function(:ensure_resource)
    resources.each { |resource_name|
    if resource_hash[resource_name]
        params_merged = params.merge(resource_hash[resource_name])
    else
        params_merged = params
    end
    function_ensure_resource([ type, resource_name, params_merged ])
    }
  else
       raise(Puppet::ParseError, 'ensure_resources(): Requires second argument to be a Hash')
  end
end
