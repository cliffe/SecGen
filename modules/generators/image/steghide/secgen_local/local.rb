#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require_relative '../../../../../lib/helpers/print.rb'
require 'mini_exiftool_vendored'
require 'securerandom'

class SteghideGenerator < StringEncoder
  attr_accessor :base64_image
  attr_accessor :strings_to_leak
  attr_accessor :exif_field
  attr_accessor :password

  def initialize
    super
    self.module_name = 'Steghide Image Generator'
    self.base64_image = ''
    self.password = ''
    self.strings_to_leak = []
    self.exif_field = ''
  end

  def encode_all
    # Decode the base64 image data into raw contents
    raw_image_contents = Base64.strict_decode64(self.base64_image)

    # Store the raw_image_contents as a temporary image file called 'tmp.jpg'
    tmp_file_path_image = "/tmp/#{SecureRandom.hex(6)}.jpg"
    tmp_file_path_leak = "/tmp/#{SecureRandom.hex(6)}.txt"
    File.open(tmp_file_path_image, 'wb') { |f| f.write(raw_image_contents) }
    File.open(tmp_file_path_leak, 'w') { |f| f.write(self.strings_to_leak.join) }

    returnstr = `steghide embed -cf #{tmp_file_path_image} -ef #{tmp_file_path_leak} -p #{self.password}`

    Print.local_verbose returnstr

    unless $?.exitstatus == 0
      Print.err "Steghide failed to run. Please make sure it's installed (apt-get install steghide)"
      exit(1)
    end
    self.outputs << Base64.strict_encode64(File.binread(tmp_file_path_image))

    File.delete(tmp_file_path_image)
    File.delete(tmp_file_path_leak)

  end

  def get_options_array
    super + [['--base64_image', GetoptLong::REQUIRED_ARGUMENT],
             ['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT],
             ['--password', GetoptLong::REQUIRED_ARGUMENT],
             ['--exif_field', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--base64_image'
        self.base64_image << arg;
      when '--strings_to_leak'
        self.strings_to_leak << arg;
      when '--exif_field'
        self.exif_field << arg;
      when '--password'
        self.password << arg;
    end
  end

  def encoding_print_string
    'base64_image: <selected_image>' + print_string_padding +
    'strings_to_leak: ' + self.strings_to_leak.to_s + print_string_padding +
    'password: ' + self.password.to_s + print_string_padding +
    'exif_field: ' + self.exif_field.to_s
  end
end

SteghideGenerator.new.run
