#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class MediumPasswordGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Medium Password Generator'
  end

  def generate
    nouns = File.readlines("#{WORDLISTS_DIR}/nouns")
    adjectives = File.readlines("#{WORDLISTS_DIR}/adjectives")
    male_names = File.readlines("#{WORDLISTS_DIR}/top_usa_male_names")
    female_names = File.readlines("#{WORDLISTS_DIR}/top_usa_female_names")

    all_words = adjectives + nouns + male_names + female_names

    all_words.delete_if { |word| word.length != 6 }

    word = all_words.sample.chomp

    # # add random capitalisation?
    # word.split('').each {|c|
    #   if [true, false].sample
    #     c.capitalize
    #   end
    # }

    number = rand.to_s[2..3]
    self.outputs << word + number
  end
end

MediumPasswordGenerator.new.run