#!/usr/bin/ruby
require 'json'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'faker'

class FilenameGenerator < StringEncoder
  attr_accessor :file_name
  attr_accessor :extension

  def initialize
    super
    self.module_name = 'Random Filename Generator'
    self.file_name = ''
    self.extension = ''
  end

  def encode_all
    file_name = self.file_name
    extension = self.extension
    leaked_filenames = []

    if file_name.empty?
      file_name = nil
      leaked_filenames = %w(top_secret_information secrets hush_hush private_stuff restricted classified confidential)
    end
    if extension.empty?
      extension = nil
    end

    if self.extension == 'no_extension'
      extension = ''
    end

    15.times { leaked_filenames << Faker::File.file_name('', file_name, extension, '').chomp('.') }

    output = leaked_filenames.sample

    self.outputs << output
  end

  def process_options(opt, arg)
    super
    case opt
      when '--file_name'
        self.extension << arg;
      when '--extension'
        self.extension << arg;
    end
  end

  def get_options_array
    super + [['--file_name', GetoptLong::OPTIONAL_ARGUMENT],
             ['--extension', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def encoding_print_string
    string = ''
    if self.file_name.empty? && self.extension.empty?
      string = 'No args'
    else
      if self.file_name.length > 0 && self.extension.length > 0
        string += 'file_name: ' + self.file_name.to_s + print_string_padding +
                  'extension: ' + self.extension.to_s
      elsif self.file_name.length > 0
        string += 'file_name: ' + self.file_name.to_s
      else
        string += 'extension: ' + self.extension.to_s
      end
    end
    string
  end
end

FilenameGenerator.new.run
