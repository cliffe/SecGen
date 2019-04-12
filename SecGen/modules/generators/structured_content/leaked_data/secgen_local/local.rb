#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'base64'

class LeakedDataGenerator < StringEncoder
  attr_accessor :data
  attr_accessor :filename
  attr_accessor :ext
  attr_accessor :subdirectory

  def initialize
    super
    self.module_name = 'SecGen Leaked Data Wrapper'
    self.data = ''
    self.filename = ''
    self.ext = ''
    self.subdirectory = ''
  end

  def encode_all
    data_hash = {:secgen_leaked_data => {}}
    data_hash[:secgen_leaked_data]['data'] = Base64.strict_encode64(self.data)
    data_hash[:secgen_leaked_data]['filename'] = self.filename
    data_hash[:secgen_leaked_data]['ext'] = self.ext
    data_hash[:secgen_leaked_data]['subdirectory'] = self.subdirectory

    self.outputs << data_hash.to_json
  end

  def get_options_array
    super + [['--data', GetoptLong::OPTIONAL_ARGUMENT],
             ['--filename', GetoptLong::OPTIONAL_ARGUMENT],
             ['--ext', GetoptLong::REQUIRED_ARGUMENT],
             ['--subdirectory', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--data'
        self.data << arg;
      when '--filename'
        self.filename << arg;
      when '--ext'
        self.ext << arg;
      when '--subdirectory'
        self.subdirectory << arg;
    end
  end

  def encoding_print_string
    'data: ' + self.data.to_s + print_string_padding +
    'filename: ' + self.filename.to_s  + print_string_padding +
    'ext: ' + self.ext.to_s + print_string_padding +
    'subdirectory: ' + self.subdirectory.to_s
  end
end

LeakedDataGenerator.new.run
