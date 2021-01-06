#
#  regexpescape.rb
#
module Puppet::Parser::Functions
  newfunction(:regexpescape, :type => :rvalue, :doc => <<-DOC
    Regexp escape a string or array of strings.
    Requires either a single string or an array as an input.
    DOC
  ) do |arguments| # rubocop:disable Style/ClosingParenthesisIndentation
    raise(Puppet::ParseError, "regexpescape(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(String)
      raise(Puppet::ParseError, 'regexpescape(): Requires either array or string to work with')
    end

    result = if value.is_a?(Array)
               # Numbers in Puppet are often string-encoded which is troublesome ...
               value.map { |i| i.is_a?(String) ? Regexp.escape(i) : i }
             else
               Regexp.escape(value)
             end

    return result
  end
end

# vim: set ts=2 sw=2 et :
