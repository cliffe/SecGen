#!/usr/bin/ruby
require 'fileutils'
require 'digest'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class SHA512Encoder < StringEncoder
  def initialize
    super
    self.module_name = 'MD5 hash'
  end

  def encode(str)
    Digest::SHA2.new(512).base64digest str
  end

end

SHA512Encoder.new.run
