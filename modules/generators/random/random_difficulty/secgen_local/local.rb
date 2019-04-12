#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class RandomDifficulty < StringGenerator

  def initialize
    super
    self.module_name = 'Random Difficulty Generator'
  end

  def generate
    outputs << %w(easy medium high).sample.chomp
  end

end

RandomDifficulty.new.run