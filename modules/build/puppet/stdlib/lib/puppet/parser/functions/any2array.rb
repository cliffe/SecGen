#
# any2array.rb
#
module Puppet::Parser::Functions
  newfunction(:any2array, :type => :rvalue, :doc => <<-DOC
    This converts any object to an array containing that object. Empty argument
    lists are converted to an empty array. Arrays are left untouched. Hashes are
    converted to arrays of alternating keys and values.
  DOC
             ) do |arguments|

    if arguments.empty?
      return []
    end

    return arguments unless arguments.length == 1
    return arguments[0] if arguments[0].is_a?(Array)
    if arguments[0].is_a?(Hash)
      result = []
      arguments[0].each do |key, value|
        result << key << value
      end
      return result
    end
    return arguments
  end
end

# vim: set ts=2 sw=2 et :
