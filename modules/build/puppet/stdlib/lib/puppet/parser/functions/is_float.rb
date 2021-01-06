#
# is_float.rb
#
module Puppet::Parser::Functions
  newfunction(:is_float, :type => :rvalue, :doc => <<-DOC
    Returns true if the variable passed to this function is a float.
    DOC
             ) do |arguments|

    function_deprecation([:is_float, 'This method is deprecated, please use the stdlib validate_legacy function,
                          with Stdlib::Compat::Float. There is further documentation for validate_legacy function in the README.'])

    if arguments.size != 1
      raise(Puppet::ParseError, "is_float(): Wrong number of arguments given #{arguments.size} for 1")
    end

    value = arguments[0]

    # Only allow Numeric or String types
    return false unless value.is_a?(Numeric) || value.is_a?(String)

    return false if value != value.to_f.to_s && !value.is_a?(Float)
    return true
  end
end

# vim: set ts=2 sw=2 et :
