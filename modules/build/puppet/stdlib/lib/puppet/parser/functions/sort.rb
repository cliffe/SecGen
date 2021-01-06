#
#  sort.rb
#  Please note: This function is an implementation of a Ruby class and as such may not be entirely UTF8 compatible. To ensure compatibility please use this function with Ruby 2.4.0 or greater - https://bugs.ruby-lang.org/issues/10085.
#
module Puppet::Parser::Functions
  newfunction(:sort, :type => :rvalue, :doc => <<-DOC
    Sorts strings and arrays lexically.
  DOC
             ) do |arguments|

    if arguments.size != 1
      raise(Puppet::ParseError, "sort(): Wrong number of arguments given #{arguments.size} for 1")
    end

    value = arguments[0]

    if value.is_a?(Array)
      value.sort
    elsif value.is_a?(String)
      value.split('').sort.join('')
    end
  end
end

# vim: set ts=2 sw=2 et :
