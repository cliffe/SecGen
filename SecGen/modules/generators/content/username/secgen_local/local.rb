#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'faker'

class UsernameGenerator < StringEncoder
  attr_accessor :name

  def initialize
    super
    self.module_name = 'Username Generator'
    self.name = ''
  end

  # Generate a username based on a random adjective and a random noun
  def encode_all
    username = ''

    if self.name != ''  # Create a username based on the name provided
      username = Faker::Internet.user_name(self.name, ['_',''])
    else  # Create a random username
      # Load adjectives + nouns
      adjectives = File.readlines("#{WORDLISTS_DIR}/adjectives")
      nouns = File.readlines("#{WORDLISTS_DIR}/nouns")

      # Maximum length username: 20 characters
      max_username_length = 20

      suitable_username_generated = false
      until suitable_username_generated
        random_adjective = adjectives.sample.chomp
        filler_character = ['', '_', '-'].sample
        random_noun = nouns.sample.chomp

        proposed_username = random_adjective + filler_character + random_noun

        if proposed_username.length <= max_username_length
          suitable_username_generated = true
          username = proposed_username
        end
      end
    end
    self.outputs << username
  end

  def get_options_array
    super + [['--name', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    if opt == '--name'
      self.name << arg;
    end
  end

  def encoding_print_string
    'name: ' + self.name.to_s
  end
end

UsernameGenerator.new.run