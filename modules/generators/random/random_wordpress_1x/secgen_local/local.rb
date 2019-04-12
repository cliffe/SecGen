#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class RandomWordpressVersion < StringGenerator
  def initialize
    super
    self.module_name = 'Random Wordpress Version Generator'
  end

  def generate
    one = ['1.5.2', '1.5.1.3', '1.5.1.2', '1.5.1.1', '1.5.1']
    versions = one

    outputs << versions.sample.chomp
  end
end

RandomWordpressVersion.new.run