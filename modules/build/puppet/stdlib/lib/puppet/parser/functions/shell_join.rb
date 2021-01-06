
require 'shellwords'
#
# shell_join.rb
#
module Puppet::Parser::Functions
  newfunction(:shell_join, :type => :rvalue, :doc => <<-DOC
    Builds a command line string from the given array of strings. Each array item is escaped for Bourne shell. All items are
    then joined together, with a single space in between.

    This function behaves the same as ruby's Shellwords.shelljoin() function
  DOC
             ) do |arguments|

    raise(Puppet::ParseError, "shell_join(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.size != 1

    array = arguments[0]

    raise Puppet::ParseError, "First argument is not an Array: #{array.inspect}" unless array.is_a?(Array)

    # explicit conversion to string is required for ruby 1.9
    array = array.map { |item| item.to_s }
    result = Shellwords.shelljoin(array)

    return result
  end
end

# vim: set ts=2 sw=2 et :
