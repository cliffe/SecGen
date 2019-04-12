#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
class Base64FlagGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Base64 Flag Generator'
  end

  def generate
    require 'securerandom'
    flag = SecureRandom.base64
    flag.tr!('/','', )
    flag.tr!('+', '' )
    flag.tr!('=', '')
    self.outputs << "flag{#{flag}}"
  end
end

Base64FlagGenerator.new.run
