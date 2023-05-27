#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class EvilDiaryGenerator < StringGenerator

  def initialize
    super
    self.module_name = 'Random Evil Diary Generator'
  end

  def generate
    self.outputs << [*File.readlines("#{LINELISTS_DIR}/diary_boring").sample(4),
                     *File.readlines("#{LINELISTS_DIR}/diary_evil").sample(4)].join
  end
end

EvilDiaryGenerator.new.run
