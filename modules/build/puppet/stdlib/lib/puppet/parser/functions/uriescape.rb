require 'uri'
#
#  uriescape.rb
#  Please note: This function is an implementation of a Ruby class and as such may not be entirely UTF8 compatible. To ensure compatibility please use this function with Ruby 2.4.0 or greater - https://bugs.ruby-lang.org/issues/10085.
#
module Puppet::Parser::Functions
  newfunction(:uriescape, :type => :rvalue, :doc => <<-DOC
    Urlencodes a string or array of strings.
    Requires either a single string or an array as an input.
    DOC
             ) do |arguments|

    raise(Puppet::ParseError, "uriescape(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    value = arguments[0]

    unless value.is_a?(Array) || value.is_a?(String)
      raise(Puppet::ParseError, 'uriescape(): Requires either array or string to work with')
    end

    result = if value.is_a?(Array)
               # Numbers in Puppet are often string-encoded which is troublesome ...
               value.map { |i| i.is_a?(String) ? URI.escape(i) : i } # rubocop:disable Lint/UriEscapeUnescape
             else
               URI.escape(value) # rubocop:disable Lint/UriEscapeUnescape
             end

    return result
  end
end

# vim: set ts=2 sw=2 et :
