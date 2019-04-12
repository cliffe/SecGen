#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class SHA1Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'SHA1 Encoder'
  end

  def hash_function(string)
    Digest::SHA1.hexdigest(string)
  end
end

SHA1Encoder.new.run
