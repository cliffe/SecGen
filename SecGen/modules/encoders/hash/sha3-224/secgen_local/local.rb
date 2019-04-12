#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'
require 'digest/sha3'

class SHA3_224_Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'SHA3-224 Encoder'
  end

  def hash_function(string)
    Digest::SHA3.hexdigest(string, 224)
  end
end

SHA3_224_Encoder.new.run