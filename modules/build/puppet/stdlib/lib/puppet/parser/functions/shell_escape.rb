require 'shellwords'
#
# shell_escape.rb
#
module Puppet::Parser::Functions
  newfunction(:shell_escape, :type => :rvalue, :doc => <<-DOC
    Escapes a string so that it can be safely used in a Bourne shell command line.

    Note that the resulting string should be used unquoted and is not intended for use in double quotes nor in single
    quotes.

    This function behaves the same as ruby's Shellwords.shellescape() function.
  DOC
             ) do |arguments|

    raise(Puppet::ParseError, "shell_escape(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.size != 1

    # explicit conversion to string is required for ruby 1.9
    string = arguments[0].to_s

    result = Shellwords.shellescape(string)

    return result
  end
end

# vim: set ts=2 sw=2 et :
