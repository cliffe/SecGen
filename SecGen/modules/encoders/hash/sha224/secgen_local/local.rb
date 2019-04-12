#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class SHA224Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'SHA224 Encoder'
  end

  def hash_function(string)
    require 'openssl'
    OpenSSL::Digest::SHA224.hexdigest(string)
  end
end

SHA224Encoder.new.run
