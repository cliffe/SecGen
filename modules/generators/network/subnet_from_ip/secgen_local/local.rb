#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class SubnetFromIp < StringGenerator
  attr_accessor :ip_address

  def initialize
    super
    self.module_name = 'Subnet From IP Generator'
    self.ip_address = ''
  end

  def get_options_array
    super + [['--ip_address', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--ip_address' then self.ip_address = arg
    end
  end

  def generate
    if ip_address.empty?
      Print.err 'subnet_from_ip: ip_address is required'
      exit 1
    end

    parts = ip_address.split('.')
    unless parts.length == 4 && parts.all? { |p| p.match?(/^\d+$/) && p.to_i.between?(0, 255) }
      Print.err "subnet_from_ip: '#{ip_address}' is not a valid IPv4 address"
      exit 1
    end

    self.outputs << "#{parts[0..2].join('.')}.0/24"
  end
end

SubnetFromIp.new.run
