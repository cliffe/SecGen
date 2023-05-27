#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'erb'
require 'fileutils'
class FilezillaConfigFileGenerator < StringGenerator
  attr_accessor :name
  attr_accessor :host
  attr_accessor :port
  attr_accessor :password
  LOCAL_DIR = File.expand_path('../../',__FILE__)
  TEMPLATE_PATH = "#{LOCAL_DIR}/templates/filezilla_config.xml.erb"

  def initialize
    super
    self.name = ''
    self.host = ''
    self.port = ''
    self.password = ''
  end

  def get_options_array
    super + [['--host', GetoptLong::REQUIRED_ARGUMENT],
             ['--port', GetoptLong::OPTIONAL_ARGUMENT],
             ['--password', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--host'
        self.host << arg;
      when '--port'
        self.port << arg;
      when '--password'
        self.password << arg;
      end
  end
  def generate

    self.name = "#{self.host}:#{self.port}"
    template_out = ERB.new(File.read(TEMPLATE_PATH), 0, '<>-')
    self.outputs << template_out.result(self.get_binding)
  end

  # Returns binding for erb files (access to variables in this classes scope)
  # @return binding
  def get_binding
    binding
  end
end


FilezillaConfigFileGenerator.new.run

