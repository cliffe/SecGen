#
# shell_split.rb
#

require 'shellwords'

module Puppet::Parser::Functions
  newfunction(:shell_split, :type => :rvalue, :doc => <<-EOS
Splits a string into an array of tokens in the same way the Bourne shell does.

This function behaves the same as ruby's Shellwords.shellsplit() function
  EOS
  ) do |arguments|

    raise(Puppet::ParseError, "shell_split(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.size != 1

    string = arguments[0].to_s

    result = Shellwords.shellsplit(string)

    return result
  end
end

# vim: set ts=2 sw=2 et :
