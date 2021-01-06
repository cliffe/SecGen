#
# validate_ip_address.rb
#
module Puppet::Parser::Functions
  newfunction(:validate_ip_address, :doc => <<-DOC
    Validate that all values passed are valid IP addresses,
    regardless they are IPv4 or IPv6
    Fail compilation if any value fails this check.
    The following values will pass:
    $my_ip = "1.2.3.4"
    validate_ip_address($my_ip)
    validate_ip_address("8.8.8.8", "172.16.0.1", $my_ip)

    $my_ip = "3ffe:505:2"
    validate_ip_address(1)
    validate_ip_address($my_ip)
    validate_ip_address("fe80::baf6:b1ff:fe19:7507", $my_ip)

    The following values will fail, causing compilation to abort:
    $some_array = [ 1, true, false, "garbage string", "3ffe:505:2" ]
    validate_ip_address($some_array)
    DOC
             ) do |args|

    require 'ipaddr'
    rescuable_exceptions = [ArgumentError]

    function_deprecation([:validate_ip_address, 'This method is deprecated, please use the stdlib validate_legacy function,
                            with Stdlib::Compat::Ip_address. There is further documentation for validate_legacy function in the README.'])

    if defined?(IPAddr::InvalidAddressError)
      rescuable_exceptions << IPAddr::InvalidAddressError
    end

    if args.empty?
      raise Puppet::ParseError, "validate_ip_address(): wrong number of arguments (#{args.length}; must be > 0)"
    end

    args.each do |arg|
      unless arg.is_a?(String)
        raise Puppet::ParseError, "#{arg.inspect} is not a string."
      end

      begin
        unless IPAddr.new(arg).ipv4? || IPAddr.new(arg).ipv6?
          raise Puppet::ParseError, "#{arg.inspect} is not a valid IP address."
        end
      rescue *rescuable_exceptions
        raise Puppet::ParseError, "#{arg.inspect} is not a valid IP address."
      end
    end
  end
end
