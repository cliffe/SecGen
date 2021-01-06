#
#  rstrip.rb
#
module Puppet::Parser::Functions
  newfunction(:rstrip, :type => :rvalue, :doc => <<-DOC
    Strips leading spaces to the right of the string.
    DOC
             ) do |arguments|

    raise(Puppet::ParseError, "rstrip(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(String)
      raise(Puppet::ParseError, 'rstrip(): Requires either array or string to work with')
    end

    result = if value.is_a?(Array)
               value.map { |i| i.is_a?(String) ? i.rstrip : i }
             else
               value.rstrip
             end

    return result
  end
end

# vim: set ts=2 sw=2 et :
