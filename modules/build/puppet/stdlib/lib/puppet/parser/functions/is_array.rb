#
# is_array.rb
#
module Puppet::Parser::Functions
  newfunction(:is_array, :type => :rvalue, :doc => <<-DOC
    Returns true if the variable passed to this function is an array.
    DOC
             ) do |arguments|

    function_deprecation([:is_array, 'This method is deprecated, please use the stdlib validate_legacy function,
                           with Stdlib::Compat::Array. There is further documentation for validate_legacy function in the README.'])

    raise(Puppet::ParseError, "is_array(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    type = arguments[0]

    result = type.is_a?(Array)

    return result
  end
end
