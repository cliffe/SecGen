#!/usr/bin/ruby
require 'rqrcode'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class QRCodeGenerator < StringEncoder
  attr_accessor :strings_to_leak

  def initialize
    super
    self.module_name = 'QR Code Generator'
    self.strings_to_leak = []
  end

  def encode_all
    qr_code = RQRCode::QRCode.new(self.strings_to_leak[0])
    image = qr_code.as_png
    self.outputs <<  Base64.strict_encode64(image.to_blob)
  end

  def get_options_array
    super + [['--strings_to_leak', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--strings_to_leak'
        self.strings_to_leak << arg;
    end
  end


  def encoding_print_string
    'Strings_to_leak: ' + self.strings_to_leak.first
  end
end

QRCodeGenerator.new.run