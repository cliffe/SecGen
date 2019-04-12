#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class SHA256Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'SHA256 Encoder'
  end

  def hash_function(string)
    Digest::SHA256.hexdigest(string)
  end
end

SHA256Encoder.new.run
