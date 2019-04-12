#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class SCryptEncoder < HashEncoder
  def initialize
    super
    self.module_name = 'SCrypt Encoder'
  end

  def hash_function(string)
    require 'scrypt'
    SCrypt::Password.create(string)
  end
end

SCryptEncoder.new.run