class Blacklist
  attr_accessor :blacklisted_words
  def initialize
    self.blacklisted_words = File.readlines(BLACKLISTED_WORDS_FILE)
    self.blacklisted_words.map! { |w| w.strip }
  end

  def is_blacklisted?(word)
    blacklisted_words.include? word
  end
end