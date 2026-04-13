#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class NetworkRoute < StringGenerator
  attr_accessor :destination
  attr_accessor :subnet_mask
  attr_accessor :via
  attr_accessor :dev

  def initialize
    super
    self.module_name = 'Network Route Generator'
    self.destination = ''
    self.subnet_mask = ''
    self.via = ''
    self.dev = ''
  end

  def get_options_array
    super + [['--destination', GetoptLong::REQUIRED_ARGUMENT],
             ['--subnet_mask', GetoptLong::REQUIRED_ARGUMENT],
             ['--via', GetoptLong::REQUIRED_ARGUMENT],
             ['--dev', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--destination'
      self.destination << arg
    when '--subnet_mask'
      self.subnet_mask << arg
    when '--via'
      self.via << arg
    when '--dev'
      self.dev << arg
    end
  end

  def cidr_from_netmask(netmask)
    netmask.split('.').map { |o| o.to_i.to_s(2).count('1') }.sum
  end

  def generate
    cidr = cidr_from_netmask(subnet_mask)
    route = "#{destination}/#{cidr} via #{via}"
    route += " dev #{dev}" unless dev.empty?
    self.outputs << route
  end
end

NetworkRoute.new.run