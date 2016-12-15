#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class LipsumParagraphGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Lipsum Paragraph Generator'
  end

  def generate
    self.outputs << Faker::Lorem.paragraphs(3).join
  end
end

LipsumParagraphGenerator.new.run