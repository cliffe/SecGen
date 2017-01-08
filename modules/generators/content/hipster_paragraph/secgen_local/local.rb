#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class HipsterParagraphGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Hipster Paragraph Generator'
  end

  def generate
    sentence_count = rand(1..5)
    random_sentences_to_add = rand(1..10)
    self.outputs << Faker::Hipster.paragraph(sentence_count, true, random_sentences_to_add)
  end
end

HipsterParagraphGenerator.new.run