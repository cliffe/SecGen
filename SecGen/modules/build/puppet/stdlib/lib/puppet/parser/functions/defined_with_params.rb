# Test whether a given class or definition is defined
require 'puppet/parser/functions'

Puppet::Parser::Functions.newfunction(:defined_with_params,
                                      :type => :rvalue,
                                      :doc => <<-'ENDOFDOC'
Takes a resource reference and an optional hash of attributes.

Returns true if a resource with the specified attributes has already been added
to the catalog, and false otherwise.

    user { 'dan':
      ensure => present,
    }

    if ! defined_with_params(User[dan], {'ensure' => 'present' }) {
      user { 'dan': ensure => present, }
    }
ENDOFDOC
) do |vals|
  reference, params = vals
  raise(ArgumentError, 'Must specify a reference') unless reference
  if (! params) || params == ''
    params = {}
  end
  ret = false

  if Puppet::Util::Package.versioncmp(Puppet.version, '4.6.0') >= 0
    # Workaround for PE-20308
    if reference.is_a?(String)
      type_name, title = Puppet::Resource.type_and_title(reference, nil)
      type = Puppet::Pops::Evaluator::Runtime3ResourceSupport.find_resource_type_or_class(find_global_scope, type_name.downcase)
    elsif reference.is_a?(Puppet::Resource)
      type = reference.resource_type
      title = reference.title
    else
      raise(ArgumentError, "Reference is not understood: '#{reference.class}'")
    end
    #end workaround
  else
    type = reference.to_s
    title = nil
  end

  if resource = findresource(type, title)
    matches = params.collect do |key, value|
      # eql? avoids bugs caused by monkeypatching in puppet
      resource_is_undef = resource[key].eql?(:undef) || resource[key].nil?
      value_is_undef = value.eql?(:undef) || value.nil?
      (resource_is_undef && value_is_undef) || (resource[key] == value)
    end
    ret = params.empty? || !matches.include?(false)
  end
  Puppet.debug("Resource #{reference} was not determined to be defined")
  ret
end
