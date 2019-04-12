#
# is_ip_address.rb
#

module Puppet::Parser::Functions
  newfunction(:is_ip_address, :type => :rvalue, :doc => <<-EOS
Returns true if the string passed to this function is a valid IP address.
    EOS
  ) do |arguments|

    require 'ipaddr'

    function_deprecation([:is_ip_address, 'This method is deprecated, please use the stdlib validate_legacy function, with Stdlib::Compat::Ip_address. There is further documentation for validate_legacy function in the README.'])

    if (arguments.size != 1) then
      raise(Puppet::ParseError, "is_ip_address(): Wrong number of arguments given #{arguments.size} for 1")
    end

    begin
      ip = IPAddr.new(arguments[0])
    rescue ArgumentError
      return false
    end

    if ip.ipv4? or ip.ipv6? then
      return true
    else
      return false
    end
  end
end

# vim: set ts=2 sw=2 et :
