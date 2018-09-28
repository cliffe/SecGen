#!/usr/bin/ruby
require 'fileutils'
require 'digest'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class SHA1Encoder < StringEncoder
  def initialize
    super
    self.module_name = 'MD5 hash'
  end

  def encode(str)
    Digest::SHA1.base64digest str
  end

end

SHA1Encoder.new.run
