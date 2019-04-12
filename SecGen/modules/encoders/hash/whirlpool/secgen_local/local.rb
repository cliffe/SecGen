#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class WhirlpoolEncoder < HashEncoder
  def initialize
    super
    self.module_name = 'Whirlpool Hash Encoder'
  end

  def hash_function(string)
    Digest::Whirlpool.hexdigest(string)
  end
end

WhirlpoolEncoder.new.run
