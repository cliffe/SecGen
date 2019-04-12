#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class SipHashEncoder < HashEncoder
  def initialize
    super
    self.module_name = 'SipHash Encoder'
  end

  def hash_function(string)
    Digest::SipHash.hexdigest(string)
  end
end

SipHashEncoder.new.run