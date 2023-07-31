#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'erb'
require 'fileutils'
class TodoListGenerator < StringGenerator
  attr_accessor :movies_sample
  attr_accessor :chores_sample
  attr_accessor :music_sample
  attr_accessor :games_sample
  LOCAL_DIR = File.expand_path('../../',__FILE__)
  TEMPLATE_PATH = "#{LOCAL_DIR}/templates/todo_list.txt.erb"

  def generate

    movies_array = File.readlines('../../../../../lib/resources/linelists/top_100_movies.txt')
    self.movies_sample = movies_array.sample(10)
    chores_array = File.readlines('../../../../../lib/resources/linelists/household_chore_list.txt')
    self.chores_sample = chores_array.sample(5)
    music_array = File.readlines('../../../../../lib/resources/linelists/top_100_songs.txt')
    self.music_sample = music_array.sample(10)
    games_array = File.readlines('../../../../../lib/resources/linelists/top_100_games.txt')
    self.games_sample = games_array.sample(5)
    template_out = ERB.new(File.read(TEMPLATE_PATH), 0, '<>-')
    self.outputs << template_out.result(self.get_binding)
  end

  # Returns binding for erb files (access to variables in this classes scope)
  # @return binding
  def get_binding
    binding
  end
end

TodoListGenerator.new.run

