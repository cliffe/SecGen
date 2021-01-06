#
#  capitalize.rb
#  Please note: This function is an implementation of a Ruby class and as such may not be entirely UTF8 compatible. To ensure compatibility please use this function with Ruby 2.4.0 or greater - https://bugs.ruby-lang.org/issues/10085.
#
module Puppet::Parser::Functions
  newfunction(:capitalize, :type => :rvalue, :doc => <<-DOC
    Capitalizes the first letter of a string or array of strings.
    Requires either a single string or an array as an input.
    DOC
             ) do |arguments|

    raise(Puppet::ParseError, "capitalize(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(String)
      raise(Puppet::ParseError, 'capitalize(): Requires either array or string to work with')
    end

    result = if value.is_a?(Array)
               # Numbers in Puppet are often string-encoded which is troublesome ...
               value.map { |i| i.is_a?(String) ? i.capitalize : i }
             else
               value.capitalize
             end

    return result
  end
end
