#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class EvilLifeGoalsGenerator < StringGenerator

  def initialize
    super
    self.module_name = 'Random Evil Life Goals Generator'
  end

  def generate
    self.outputs << ["My Goals:\n", *File.readlines("#{LINELISTS_DIR}/life_goals").sample(2),
                     *File.readlines("#{LINELISTS_DIR}/life_goals_evil").sample(2)].join
  end
end

EvilLifeGoalsGenerator.new.run
