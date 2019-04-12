#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_paragraph_generator.rb'
require 'faker'

class LipsumParagraphGenerator < ParagraphGenerator

  def initialize
    super
    self.module_name = 'Lipsum Paragraph Generator'
  end

  def encode_all
    self.outputs << Faker::Lorem.paragraphs(self.paragraph_count[0].to_i).join
  end

end

LipsumParagraphGenerator.new.run