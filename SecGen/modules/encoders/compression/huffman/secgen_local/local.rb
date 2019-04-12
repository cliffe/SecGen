#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'huffman'
require 'fileutils'

class HuffmanEncoder < StringEncoder
  attr_accessor :tmp_path
  attr_accessor :subdirectory

  def initialize
    super
    self.module_name = 'Huffman Encoder'
    self.subdirectory = ''
    self.strings_to_encode = []
    self.tmp_path = File.expand_path(File.dirname(__FILE__)).split("/")[0...-1].join('/') + '/tmp/'
    Dir.mkdir self.tmp_path unless Dir.exists? self.tmp_path
    self.tmp_path += Time.new.strftime("%Y%m%d_%H%M%S")
    Dir.mkdir self.tmp_path unless Dir.exists? self.tmp_path
  end

  def encode_all
    begin
      tree_path = "#{self.tmp_path}/tree"
      result = Huffman.encode_text(strings_to_encode[0], tree_picture: true, tree_path: tree_path)

      self.outputs << {:secgen_leaked_data => {:data => Base64.strict_encode64(result.first), :filename => 'cipher', :ext => 'txt', :subdirectory => self.subdirectory}}.to_json
      self.outputs << {:secgen_leaked_data => {:data => Base64.strict_encode64(File.binread("#{tree_path}.png")), :filename => 'tree', :ext => 'png', :subdirectory => self.subdirectory}}.to_json
    ensure
      FileUtils.rm_r self.tmp_path
    end
  end

  def process_options(opt, arg)
    super
    case opt
    when '--subdirectory'
      self.subdirectory << arg;
    end
  end

  def get_options_array
    super + [['--subdirectory', GetoptLong::REQUIRED_ARGUMENT]]
  end


  def encoding_print_string
    'strings_to_encode: ' + self.strings_to_encode.to_s + print_string_padding +
        'subdirectory: ' + self.subdirectory.to_s
  end
end

HuffmanEncoder.new.run