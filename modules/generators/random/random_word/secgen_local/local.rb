#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class WordGenerator < StringGenerator
  attr_accessor :wordlist

  def initialize
    super
    self.wordlist = []
    self.module_name = 'Random Word Generator'
  end

  def get_options_array
    super + [['--wordlist', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--wordlist'
        self.wordlist << arg;
    end
  end

  def generate
    word = File.readlines("#{WORDLISTS_DIR}/#{self.wordlist.sample.chomp}").sample.chomp
    self.outputs << word.gsub(/[^\w]/, '')
  end
end

WordGenerator.new.run