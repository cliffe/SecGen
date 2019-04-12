#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class MD4Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'MD4 Encoder'
  end

  def hash_function(string)
    require 'openssl'
    OpenSSL::Digest::MD4.hexdigest(string)
  end
end

MD4Encoder.new.run
