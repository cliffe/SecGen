#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'

class HideZipInImgChallenge < StringEncoder
  attr_accessor :base64_image
  attr_accessor :zip_file

  def initialize
    super
    self.module_name = 'Hidden Zip in Image File Challenge Generator'
    self.base64_image = ''
    self.zip_file = ''
  end

  def encode_all
    # Decode the base64 image data into raw contents
    raw_image_contents = Base64.strict_decode64(self.base64_image)
    raw_zip_contents = Base64.strict_decode64(self.zip_file)

    # Append data to the end of the file
    contents_with_data = raw_image_contents + raw_zip_contents

    # Re-encode in base64 and return
    self.outputs << Base64.strict_encode64(contents_with_data)
  end

  def get_options_array
    super + [['--base64_image', GetoptLong::REQUIRED_ARGUMENT],
            ['--zip_file', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--base64_image'
        self.base64_image << arg;
      when '--zip_file'
        self.zip_file << arg;
    end
  end

  def encoding_print_string
    'base64_image: <selected_image>' + print_string_padding +
    'zip_file: ' + self.zip_file.to_s
  end
end

HideZipInImgChallenge.new.run