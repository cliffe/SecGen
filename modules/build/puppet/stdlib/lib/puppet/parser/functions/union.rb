#
# union.rb
#

module Puppet::Parser::Functions
  newfunction(:union, :type => :rvalue, :doc => <<-EOS
This function returns a union of two or more arrays.

*Examples:*

    union(["a","b","c"],["b","c","d"])

Would return: ["a","b","c","d"]
    EOS
  ) do |arguments|

    # Check that 2 or more arguments have been given ...
    raise(Puppet::ParseError, "union(): Wrong number of arguments given (#{arguments.size} for < 2)") if arguments.size < 2

    arguments.each do |argument|
      raise(Puppet::ParseError, 'union(): Every parameter must be an array') unless argument.is_a?(Array)
    end

    arguments.reduce(:|)
  end
end

# vim: set ts=2 sw=2 et :
