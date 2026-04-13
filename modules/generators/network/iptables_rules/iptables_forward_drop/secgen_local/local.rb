#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'

class IptablesForwardDrop < StringGenerator
  attr_accessor :source
  attr_accessor :destination

  def initialize
    super
    self.module_name = 'iptables FORWARD DROP Rule Generator'
    self.source = ''
    self.destination = ''
  end

  def get_options_array
    super + [['--source', GetoptLong::REQUIRED_ARGUMENT],
             ['--destination', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--source'
      self.source << arg
    when '--destination'
      self.destination << arg
    end
  end

  def generate
    self.outputs << "-A FORWARD -s #{source} -d #{destination} -j DROP"
  end
end

IptablesForwardDrop.new.run