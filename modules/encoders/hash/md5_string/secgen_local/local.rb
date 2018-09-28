#!/usr/bin/ruby
require 'fileutils'
require 'digest'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class MD5Encoder < StringEncoder
  def initialize
    super
    self.module_name = 'MD5 hash'
  end

  def encode(str)
    Digest::MD5.base64digest str
  end

end

MD5Encoder.new.run
