#
# unique.rb
#
module Puppet::Parser::Functions
  newfunction(:unique, :type => :rvalue, :doc => <<-DOC
    This function will remove duplicates from strings and arrays.

    *Examples:*

        unique("aabbcc")

    Will return:

        abc

    You can also use this with arrays:

        unique(["a","a","b","b","c","c"])

    This returns:

        ["a","b","c"]
    DOC
             ) do |arguments|

    if Puppet::Util::Package.versioncmp(Puppet.version, '5.0.0') >= 0
      function_deprecation([:unique, 'This method is deprecated, please use the core puppet unique function. There is further documentation for the function in the release notes of Puppet 5.0.'])
    end

    raise(Puppet::ParseError, "unique(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(String)
      raise(Puppet::ParseError, 'unique(): Requires either array or string to work with')
    end

    result = value.clone

    string = value.is_a?(String) ? true : false

    # We turn any string value into an array to be able to shuffle ...
    result = string ? result.split('') : result
    result = result.uniq # Remove duplicates ...
    result = string ? result.join : result

    return result
  end
end

# vim: set ts=2 sw=2 et :
