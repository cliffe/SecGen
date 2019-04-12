#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class SHA512Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'SHA512 Encoder'
  end

  def hash_function(string)
    Digest::SHA512.hexdigest(string)
  end
end

SHA512Encoder.new.run
