#
#  chop.rb
#
module Puppet::Parser::Functions
  newfunction(:chop, :type => :rvalue, :doc => <<-DOC
    Returns a new string with the last character removed. If the string ends
    with `\r\n`, both characters are removed. Applying chop to an empty
    string returns an empty string. If you wish to merely remove record
    separators then you should use the `chomp` function.
    Requires a string or array of strings as input.
    DOC
             ) do |arguments|

    raise(Puppet::ParseError, "chop(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(String)
      raise(Puppet::ParseError, 'chop(): Requires either an array or string to work with')
    end

    result = if value.is_a?(Array)
               # Numbers in Puppet are often string-encoded which is troublesome ...
               value.map { |i| i.is_a?(String) ? i.chop : i }
             else
               value.chop
             end

    return result
  end
end

# vim: set ts=2 sw=2 et :
