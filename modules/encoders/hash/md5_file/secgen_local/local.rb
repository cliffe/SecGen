#!/usr/bin/ruby
require 'fileutils'
require 'digest'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class MD5Encoder < StringEncoder
  def initialize
    super
    self.module_name = 'MD5 hash'
  end

  def encode(file_path)
    Digest::MD5.file file_path
  end

end

MD5Encoder.new.run
