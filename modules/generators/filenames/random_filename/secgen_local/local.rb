#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'faker'

class FilenameGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Random Filename Generator'
  end

  def generate
    self.outputs << Faker::File.file_name('', nil, nil, '')
  end
end

FilenameGenerator.new.run
