#
# is_mac_address.rb
#
module Puppet::Parser::Functions
  newfunction(:is_mac_address, :type => :rvalue, :doc => <<-DOC
    Returns true if the string passed to this function is a valid mac address.
    DOC
             ) do |arguments|

    if arguments.size != 1
      raise(Puppet::ParseError, "is_mac_address(): Wrong number of arguments given #{arguments.size} for 1")
    end

    mac = arguments[0]

    return true if %r{^[a-f0-9]{1,2}(:[a-f0-9]{1,2}){5}$}i =~ mac
    return false
  end
end

# vim: set ts=2 sw=2 et :
