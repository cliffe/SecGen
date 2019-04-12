#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_paragraph_generator.rb'
require 'faker'

class HipsterParagraphGenerator < ParagraphGenerator

  def initialize
    super
    self.module_name = 'Hipster Paragraph Generator'
  end

  def encode_all
    self.outputs << Faker::Hipster.paragraphs(self.paragraph_count[0].to_i).join
  end

end

HipsterParagraphGenerator.new.run