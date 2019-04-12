#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class CommonPasswordGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Common Password Generator'
  end

  def generate
    self.outputs << File.readlines("#{WORDLISTS_DIR}/10_million_password_list_top_100").sample.chomp
  end
end

CommonPasswordGenerator.new.run