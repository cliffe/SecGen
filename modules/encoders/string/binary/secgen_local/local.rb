#!/usr/bin/ruby
require 'base64'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class BinaryEncoder < StringEncoder
  def initialize
    super
    self.module_name = 'Binary Encoder'
  end

  def encode(str)
    str.unpack('B*').first
  end
end

BinaryEncoder.new.run
