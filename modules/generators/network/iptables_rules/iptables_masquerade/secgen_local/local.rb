#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'

class IptablesMasquerade < StringGenerator
  attr_accessor :source
  attr_accessor :out_interface

  def initialize
    super
    self.module_name = 'iptables MASQUERADE Rule Generator'
    self.source = ''
    self.out_interface = ''
  end

  def get_options_array
    super + [['--source', GetoptLong::REQUIRED_ARGUMENT],
             ['--out_interface', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--source'
      self.source << arg
    when '--out_interface'
      self.out_interface << arg
    end
  end

  def generate
    self.outputs << "-t nat -A POSTROUTING -s #{source} -o #{out_interface} -j MASQUERADE"
  end
end

IptablesMasquerade.new.run