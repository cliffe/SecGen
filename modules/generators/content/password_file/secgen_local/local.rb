#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'erb'
require 'fileutils'
class PasswordFileGenerator < StringGenerator
  attr_accessor :website_sample
  attr_accessor :user_list
  attr_accessor :pass_list
  attr_accessor :malicious
  attr_accessor :benign
  attr_accessor :mal_website_lines
  attr_accessor :website_lines
  LOCAL_DIR = File.expand_path('../../',__FILE__)
  INTERESTS_DIR = "../../../../../lib/resources/interests"
  TEMPLATE_PATH = "#{LOCAL_DIR}/templates/password_file.md.erb"
  MALICIOUS_PATH = "#{INTERESTS_DIR}/malicious/"
  BENIGN_PATH = "#{INTERESTS_DIR}/benign/"
  def initialize
    super
    self.pass_list = Array.new
    self.user_list = Array.new
    self.malicious = ''
    self.benign = ''
    self.mal_website_lines = Array.new
    self.website_lines = Array.new
  end
  
  def get_options_array
    super + [['--passwords', GetoptLong::REQUIRED_ARGUMENT],
    ['--usernames', GetoptLong::REQUIRED_ARGUMENT],
    ['--benign', GetoptLong::REQUIRED_ARGUMENT],
    ['--malicious', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--passwords'
      arr = arg.split(',', -1)
      arr.each{ |pass|
        self.pass_list << pass.delete(' ')
      }
    when '--usernames'
      arr = arg.split(',', -1)
      arr.each{ |user|
        self.user_list << user.delete(' ')
      }
    when '--benign'
      self.benign << arg;
    when '--malicious'
      self.malicious << arg;
    end
  end

def generate


  if self.malicious != "" 
    malicious_interest = "#{MALICIOUS_PATH}#{self.malicious}"
    self.mal_website_lines = File.readlines("#{malicious_interest}/websites").map(&:strip)
  end
  random_interest = "#{BENIGN_PATH}#{self.benign}"

  self.website_lines = File.readlines("#{random_interest}/websites").map(&:strip)
  
  passLength = self.pass_list.length()
  userLength = self.user_list.length()
  self.website_sample = website_lines.sample(10)
  self.website_sample << mal_website_lines.sample(10)
  self.website_sample = self.website_sample.flatten
  self.website_sample = self.website_sample.shuffle()
  
  if passLength == 0
    warn "Empty Array"
   exit 1
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

