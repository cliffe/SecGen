#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'

class HideStringsInImgChallenge < StringEncoder
  attr_accessor :base64_image
  attr_accessor :strings_to_leak
  attr_accessor :binary_base64_to_leak

  def initialize
    super
    self.module_name = 'Hidden Strings in Image File Challenge Generator'
    self.base64_image = ''
    self.strings_to_leak = []
    self.binary_base64_to_leak = ''
  end

  def encode_all
    # Decode the base64 image data into raw contents
    raw_image_contents = Base64.strict_decode64(self.base64_image)
    contents_with_data = ''
    # Append data to the end of the file
    unless self.strings_to_leak.empty?
      contents_with_data += raw_image_contents.force_encoding("UTF-8") + self.strings_to_leak.join.force_encoding("UTF-8")
    end
    unless binary_base64_to_leak.empty?
      contents_with_data += raw_image_contents.force_encoding("UTF-8") + self.strings_to_leak.join.force_encoding("UTF-8")
      contents_with_data += Base64.strict_decode64(self.binary_base64_to_leak).force_encoding("UTF-8")
    end

    # Re-encode in base64 and return
    self.outputs << Base64.strict_encode64(contents_with_data)
  end

  def get_options_array
    super + [['--base64_image', GetoptLong::REQUIRED_ARGUMENT],
            ['--strings_to_leak', GetoptLong::OPTIONAL_ARGUMENT],
            ['--binary_base64_to_leak', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--base64_image'
        self.base64_image << arg;
      when '--strings_to_leak'
        self.strings_to_leak << arg;
      when '--binary_base64_to_leak'
        self.binary_base64_to_leak << arg;
    end
  end

  def encoding_print_string
    'base64_image: <selected_image>' + print_string_padding +
    'strings_to_leak: ' + self.strings_to_leak.to_s
    'binary_base64_to_leak: ' + self.binary_base64_to_leak.to_s
  end
end

HideStringsInImgChallenge.new.run
