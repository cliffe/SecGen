#
# is_ip_address.rb
#
module Puppet::Parser::Functions
  newfunction(:is_ip_address, :type => :rvalue, :doc => <<-DOC
    Returns true if the string passed to this function is a valid IP address.
    DOC
             ) do |arguments|

    require 'ipaddr'

    function_deprecation([:is_ip_address, 'This method is deprecated, please use the stdlib validate_legacy function,
                           with Stdlib::Compat::Ip_address. There is further documentation for validate_legacy function in the README.'])

    if arguments.size != 1
      raise(Puppet::ParseError, "is_ip_address(): Wrong number of arguments given #{arguments.size} for 1")
    end

    begin
      ip = IPAddr.new(arguments[0])
    rescue ArgumentError
      return false
    end

    return true if ip.ipv4? || ip.ipv6?
    return false
  end
end

# vim: set ts=2 sw=2 et :
