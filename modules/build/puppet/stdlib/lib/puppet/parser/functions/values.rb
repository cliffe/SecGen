#
# values.rb
#
module Puppet::Parser::Functions
  newfunction(:values, :type => :rvalue, :doc => <<-DOC
    When given a hash this function will return the values of that hash.

    *Examples:*

        $hash = {
          'a' => 1,
          'b' => 2,
          'c' => 3,
        }
        values($hash)

    This example would return:

        [1,2,3]
    DOC
             ) do |arguments|

    raise(Puppet::ParseError, "values(): Wrong number of arguments given (#{arguments.size} for 1)") if arguments.empty?

    hash = arguments[0]

    unless hash.is_a?(Hash)
      raise(Puppet::ParseError, 'values(): Requires hash to work with')
    end

    result = hash.values

    return result
  end
end

# vim: set ts=2 sw=2 et :
