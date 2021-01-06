# Test whether a given class or definition is defined
require 'puppet/parser/functions'

Puppet::Parser::Functions.newfunction(:getparam,
                                      :type => :rvalue,
                                      :doc => <<-'DOC'
    Takes a resource reference and name of the parameter and
    returns value of resource's parameter.

    *Examples:*

        define example_resource($param) {
        }

        example_resource { "example_resource_instance":
            param => "param_value"
        }

        getparam(Example_resource["example_resource_instance"], "param")

    Would return: param_value
  DOC
                                     ) do |vals|
  reference, param = vals
  raise(ArgumentError, 'Must specify a reference') unless reference
  raise(ArgumentError, 'Must specify name of a parameter') unless param && param.instance_of?(String)

  return '' if param.empty?

  resource = findresource(reference.to_s)
  if resource
    return resource[param] unless resource[param].nil?
  end

  return ''
end
