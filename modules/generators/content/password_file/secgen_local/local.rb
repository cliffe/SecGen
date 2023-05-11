#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'erb'
require 'fileutils'
class PasswordFileGenerator < StringGenerator
  attr_accessor :website_sample
  attr_accessor :username_sample
  attr_accessor :pass_list
  LOCAL_DIR = File.expand_path('../../',__FILE__)
  TEMPLATE_PATH = "#{LOCAL_DIR}/templates/password_file.md.erb"

  def initialize
    super
    self.pass_list = Array.new
  end
  
  def get_options_array
    super + [['--password1', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--password1'
      arr = arg.split(',', -1)
      arr.each{ |pass|
        self.pass_list << pass.strip!
      }
    end
  end

def generate

  arrayLength = self.pass_list.length()
  pass_array = File.readlines('../../../../../lib/resources/wordlists/10_million_password_list_top_100')
  website_array = File.readlines('../../../../../lib/resources/linelists/top_100_websites')
  self.website_sample = website_array.sample(10)
  username_array = File.readlines('../../../../../lib/resources/wordlists/mythical_creatures')
  self.username_sample = username_array.sample(5)

  if arrayLength == 0
    self.pass_list = pass_array.sample(10)
  elsif arrayLength < 10
    while self.pass_list.length() < 10
       self.pass_list << pass_array.sample(1)
     end
  end

  template_out = ERB.new(File.read(TEMPLATE_PATH), 0, '<>-')
  self.outputs << template_out.result(self.get_binding)
end


  # Returns binding for erb files (access to variables in this classes scope)
  # @return binding
  def get_binding
    binding
  end
end

PasswordFileGenerator.new.run

