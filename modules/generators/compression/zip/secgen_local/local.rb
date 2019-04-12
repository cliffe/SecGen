#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'rubygems'
require 'zip'

class ZipGenerator < StringEncoder
  attr_accessor :file_name
  attr_accessor :strings_to_leak
  attr_accessor :password

  def initialize
    super
    self.module_name = 'Zip File Generator'
    self.file_name = ''
    self.strings_to_leak = []
    self.password = ''
    Dir.mkdir '../tmp/' unless Dir.exists? '../tmp/'
  end

  def encode_all
    zip_file_path = GENERATORS_DIR + 'compression/zip/tmp/archive.zip'
    file_contents = ''
    data = self.strings_to_leak.join("\n")

    # Create a zip archive compressing a file containing strings_to_leak
    if self.password != ''
      file_contents = Zip::OutputStream.write_buffer(::StringIO.new(''), Zip::TraditionalEncrypter.new(self.password)) do |out|
        out.put_next_entry self.file_name
        out.write data
      end.string
    else
      Zip::File.open(zip_file_path, Zip::File::CREATE) do |zip_file|
        zip_file.get_output_stream(self.file_name) { |os|
          os.write data
        }
        file_contents = File.binread(zip_file_path)
        FileUtils.rm(zip_file_path)
      end
    end
    self.outputs << Base64.strict_encode64(file_contents)
  end

  def get_options_array
    super + [['--file_name', GetoptLong::REQUIRED_ARGUMENT],
             ['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT],
             ['--password', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--file_name'
        self.file_name << arg;
      when '--strings_to_leak'
        self.strings_to_leak << arg;
      when '--password'
        self.password << arg;
    end
  end

  def encoding_print_string
    'file_name: ' + self.file_name.to_s + print_string_padding +
    'file_contents: ' + self.strings_to_leak.to_s + print_string_padding +
    'password: ' + self.password.to_s
  end
end

ZipGenerator.new.run