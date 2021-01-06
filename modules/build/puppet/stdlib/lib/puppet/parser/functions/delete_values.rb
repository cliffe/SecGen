#
# delete_values.rb
#
module Puppet::Parser::Functions
  newfunction(:delete_values, :type => :rvalue, :doc => <<-DOC
    Deletes all instances of a given value from a hash.

    *Examples:*

        delete_values({'a'=>'A','b'=>'B','c'=>'C','B'=>'D'}, 'B')

    Would return: {'a'=>'A','c'=>'C','B'=>'D'}

      DOC
             ) do |arguments|

    raise(Puppet::ParseError, "delete_values(): Wrong number of arguments given (#{arguments.size} of 2)") if arguments.size != 2

    hash, item = arguments

    unless hash.is_a?(Hash)
      raise(TypeError, "delete_values(): First argument must be a Hash. Given an argument of class #{hash.class}.")
    end
    hash.dup.delete_if { |_key, val| item == val }
  end
end
