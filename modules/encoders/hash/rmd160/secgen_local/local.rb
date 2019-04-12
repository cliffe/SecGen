#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class RMD160Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'RMD160 Encoder'
  end

  def hash_function(string)
    Digest::RMD160.hexdigest(string)
  end
end

RMD160Encoder.new.run
