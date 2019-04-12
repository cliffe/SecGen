#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class MD5Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'MD5 Encoder'
  end

  def hash_function(string)
    Digest::MD5.hexdigest(string)
  end
end

MD5Encoder.new.run
