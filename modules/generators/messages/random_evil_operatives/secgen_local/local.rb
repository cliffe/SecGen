#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class EvilOperativesGenerator < StringGenerator

  def initialize
    super
    self.module_name = 'Random Evil Life Goals Generator'
  end

  def generate
    # read all the lines, and select 5 at random
    self.outputs << File.readlines("#{LINELISTS_DIR}/operatives_evil").sample(5).join
  end
end

EvilOperativesGenerator.new.run
