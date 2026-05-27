#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'

class IptablesPolicy < StringGenerator
  attr_accessor :chain
  attr_accessor :policy

  def initialize
    super
    self.module_name = 'iptables Policy Rule Generator'
    self.chain = ''
    self.policy = ''
  end

  def get_options_array
    super + [['--chain', GetoptLong::REQUIRED_ARGUMENT],
             ['--policy', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--chain'
      self.chain << arg
    when '--policy'
      self.policy << arg
    end
  end

  def generate
    self.outputs << "-P #{chain} #{policy}"
  end
end

IptablesPolicy.new.run