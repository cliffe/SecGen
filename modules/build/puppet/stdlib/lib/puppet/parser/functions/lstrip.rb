#
#  lstrip.rb
#
module Puppet::Parser::Functions
  newfunction(:lstrip, :type => :rvalue, :doc => <<-DOC
    Strips leading spaces to the left of a string.
    DOC
             ) do |arguments|

    raise(Puppet::ParseError, "lstrip(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(String)
      raise(Puppet::ParseError, 'lstrip(): Requires either array or string to work with')
    end

    result = if value.is_a?(Array)
               # Numbers in Puppet are often string-encoded which is troublesome ...
               value.map { |i| i.is_a?(String) ? i.lstrip : i }
             else
               value.lstrip
             end

    return result
  end
end

# vim: set ts=2 sw=2 et :
