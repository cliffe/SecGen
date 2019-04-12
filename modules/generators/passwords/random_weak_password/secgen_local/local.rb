#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class WeakPasswordGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Weak Password Generator'
  end

  def generate
    nouns = File.readlines("#{WORDLISTS_DIR}/nouns")
    male_names = File.readlines("#{WORDLISTS_DIR}/top_usa_male_names")
    female_names = File.readlines("#{WORDLISTS_DIR}/top_usa_female_names")

    all_words = nouns + male_names + female_names

    # only keep words 3-5 characters
    all_words.delete_if { |word|
      word.length >=6 || word.length <= 2
    }
    self.outputs << all_words.sample.chomp
  end
end

WeakPasswordGenerator.new.run