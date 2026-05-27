#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'

class IptablesForwardEstablished < StringGenerator
  def initialize
    super
    self.module_name = 'iptables FORWARD ESTABLISHED Rule Generator'
  end

  def generate
    self.outputs << '-A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT'
  end
end

IptablesForwardEstablished.new.run