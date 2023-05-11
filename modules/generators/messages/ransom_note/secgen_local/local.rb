#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'erb'
require 'fileutils'
class RansomNoteGenerator < StringGenerator
  attr_accessor :name
  LOCAL_DIR = File.expand_path('../../',__FILE__)
  TEMPLATE_PATH = "#{LOCAL_DIR}/templates/ransom_note.md.erb"

  def initialize
    super
    self.name = ''
  end
  
  def get_options_array
    super + [['--name', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--name'
      self.name << arg;
    end
  end

def generate

  #template_out = ERB.new(File.read(TEMPLATE_PATH), 0, '<>-')
  #self.outputs << template.out_result(self.get_binding)
  template_out = ERB.new(File.read(TEMPLATE_PATH), 0, '<>-')
  self.outputs << template_out.result(self.get_binding)

end


  # Returns binding for erb files (access to variables in this classes scope)
  # @return binding
  def get_binding
    binding
  end
end

RansomNoteGenerator.new.run

