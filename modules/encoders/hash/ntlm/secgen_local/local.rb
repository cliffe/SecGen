#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class NTLMEncoder < HashEncoder
  def initialize
    super
    self.module_name = 'NTLM Hash Encoder'
  end

  def hash_function(string)
    require 'smbhash'
    Smbhash.ntlm_hash(string)
  end
end

NTLMEncoder.new.run
