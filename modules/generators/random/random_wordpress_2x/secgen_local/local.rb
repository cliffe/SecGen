#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class RandomWordpressVersion < StringGenerator
  def initialize
    super
    self.module_name = 'Random Wordpress Version Generator'
  end

  def generate
    two = ['2.9.2', '2.9.1', '2.9', '2.8.6', '2.8.5', '2.8.4', '2.8.3', '2.8.2', '2.8.1', '2.8', '2.7.1', '2.7', '2.6.5', '2.6.3', '2.6.2', '2.6.1', '2.6', '2.5.1', '2.5', '2.3.3', '2.3.2', '2.3.1', '2.3', '2.2.3', '2.2.2', '2.2.1', '2.2', '2.1.3', '2.1.2', '2.1.1', '2.1', '2.0.11', '2.0.10', '2.0.9', '2.0.8', '2.0.7', '2.0.6', '2.0.5', '2.0.4', '2.0.1', '2.0']
    versions = two

    outputs << versions.sample.chomp
  end
end

RandomWordpressVersion.new.run