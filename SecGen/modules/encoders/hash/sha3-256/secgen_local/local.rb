#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'
require 'digest/sha3'

class SHA3_256_Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'SHA3-256 Encoder'
  end

  def hash_function(string)
    Digest::SHA3.hexdigest(string, 256)
  end
end

SHA3_256_Encoder.new.run