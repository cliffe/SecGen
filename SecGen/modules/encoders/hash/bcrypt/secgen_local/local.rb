#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class BCryptEncoder < HashEncoder
  def initialize
    super
    self.module_name = 'BCrypt Hash Encoder'
  end

  def hash_function(string)
    require 'bcrypt'
    BCrypt::Password.create(string)
  end
end

BCryptEncoder.new.run
