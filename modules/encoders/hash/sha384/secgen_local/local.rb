#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_hash_encoder.rb'

class SHA384Encoder < HashEncoder
  def initialize
    super
    self.module_name = 'SHA384 Encoder'
  end

  def hash_function(string)
    Digest::SHA384.hexdigest(string)
  end
end

SHA384Encoder.new.run
