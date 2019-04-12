#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require_relative '../../../../../lib/helpers/blacklist.rb'
class WordFlagGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Word Based Flag Generator'
  end

  def generate
    file = File.readlines("#{WORDLISTS_DIR}/wordlist")
    flag_string = ''
    blacklist = Blacklist.new

    (0..4).each { |_|
      flag_word = ''
      until flag_word != ''
        selected_word = file.sample.chomp
        unless blacklist.is_blacklisted? selected_word
          flag_word = selected_word
          flag_string += flag_word
        end
      end
    }

    flag_string.gsub!(/[^0-9a-z ]/i, '')  # strip special characters from the word string. removes umlauts/accents etc.
    self.outputs << 'flag{' + flag_string + '}'
  end
end

WordFlagGenerator.new.run