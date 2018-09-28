#!/usr/bin/ruby
require 'fileutils'
require 'digest'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class SHA256Encoder < StringEncoder
  def initialize
    super
    self.module_name = 'MD5 hash'
  end

  def encode(str)
    Digest::SHA384.base64digest str
  end

end

SHA256Encoder.new.run
