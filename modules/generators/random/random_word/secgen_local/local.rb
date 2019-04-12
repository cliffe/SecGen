#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require_relative '../../../../../lib/helpers/blacklist.rb'

class WordGenerator < StringGenerator
  attr_accessor :wordlist
  attr_accessor :min_length
  attr_accessor :max_length

  def initialize
    super
    self.wordlist = []
    self.min_length = ''
    self.max_length = ''
    self.module_name = 'Random Word Generator'
  end

  def get_options_array
    super + [['--wordlist', GetoptLong::OPTIONAL_ARGUMENT],
             ['--min_length', GetoptLong::OPTIONAL_ARGUMENT],
             ['--max_length', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--wordlist'
        self.wordlist << arg;
      when '--min_length'
        if arg == ''
          self.min_length = 0
        else
          self.min_length = arg.to_i
        end
      when '--max_length'
        if arg == ''
          self.max_length = 999
        else
          self.max_length = arg.to_i
        end
    end
  end

  def generate
    blacklist = Blacklist.new
    flag_word = ''

    until flag_word != ''
      selected_word = File.readlines("#{WORDLISTS_DIR}/#{self.wordlist.sample.chomp}").sample.chomp
      if suitable_word_length(selected_word) and !blacklist.is_blacklisted?(selected_word)
        flag_word = selected_word.gsub(/[^\w]/, '')
      end
    end

    self.outputs << flag_word
  end

  def suitable_word_length(string)
    if self.min_length.is_a? String or self.max_length.is_a? String
      true
    else
      ((string.length >= self.min_length) and (string.length <= self.max_length))
    end
  end
end

WordGenerator.new.run
