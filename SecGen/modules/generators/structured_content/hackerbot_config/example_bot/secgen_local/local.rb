#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
require 'erb'
require 'fileutils'
class HackerbotConfigGenerator < StringGenerator
  attr_accessor :accounts
  attr_accessor :flags
  attr_accessor :root_password
  LOCAL_DIR = File.expand_path('../../',__FILE__)
  FILE_PATH = "#{LOCAL_DIR}/files/example_bot.xml"

  def initialize
    super
    self.module_name = 'Hackerbot Config Generator'
    self.accounts = []
    self.flags = []
    self.root_password = ''
  end

  def get_options_array
    super + [['--root_password', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--root_password'
        self.root_password << arg;
    end
  end

  def generate
    self.outputs << File.read(FILE_PATH)
  end

end


HackerbotConfigGenerator.new.run