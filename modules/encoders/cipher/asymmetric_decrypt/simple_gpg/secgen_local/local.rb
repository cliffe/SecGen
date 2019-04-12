#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_encoder.rb'
require 'json'
require 'open3'
require 'fileutils'

class SimpleGPGDecrypt < StringEncoder
  attr_accessor :gpg_key_pair
  attr_accessor :tmp_path
  attr_accessor :subdirectory

  def initialize
    super
    self.module_name = 'Simple SSH Decryption Challenge'
    self.subdirectory = ''
    self.gpg_key_pair = {}
    self.tmp_path = File.expand_path(File.dirname(__FILE__)).split("/")[0...-1].join('/') + '/tmp/'
    Dir.mkdir self.tmp_path unless Dir.exists? self.tmp_path
    self.tmp_path += Time.new.strftime("%Y%m%d_%H%M%S")
    Dir.mkdir self.tmp_path unless Dir.exists? self.tmp_path
  end

  def encode_all
    begin
      public_ascii = self.gpg_key_pair['public']
      private_ascii = self.gpg_key_pair['private']

      # save strings_to_encode to a file
      File.open("#{self.tmp_path}/ciphertext", "w+") do |file|
        self.strings_to_encode.each do |line|
          file.write(line + "\n")
        end
        file.close
      end

      # Save ascii pubkey to file
      File.open("#{self.tmp_path}/pub_key", "w+") do |file|
        file.write(public_ascii)
      end

      # generate a binary key file from our ascii input and save it in ../tmp/binary_pub.key.
      _, _, _ = Open3.capture3("gpg --dearmor #{self.tmp_path}/pub_key")

      # Use the binary key to encode some cipher text
      _, _, _ = Open3.capture3("gpg --no-default-keyring --keyring #{self.tmp_path}/pub_key.gpg --trust-model always -ear secgen@localhost  #{self.tmp_path}/ciphertext")

      # Read the ciphertext.asc file in and feed it into the outputs
      ciphertext = File.read("#{self.tmp_path}/ciphertext.asc")

      self.outputs << {:secgen_leaked_data => {:data => Base64.strict_encode64(ciphertext), :filename => 'cipher', :ext => 'txt', :subdirectory => self.subdirectory}}.to_json
      self.outputs << {:secgen_leaked_data => {:data => Base64.strict_encode64(private_ascii), :filename => 'private', :ext => 'key', :subdirectory => self.subdirectory}}.to_json
    ensure
      # Delete the local key files to avoid batch clashes
      FileUtils.rm_r self.tmp_path
    end
  end

  def process_options(opt, arg)
    super
    case opt
    when '--subdirectory'
      self.subdirectory << arg;
    when '--gpg_key_pair'
      self.gpg_key_pair = JSON.parse(arg);
    end
  end

  def get_options_array
    super + [['--subdirectory', GetoptLong::REQUIRED_ARGUMENT],
             ['--gpg_key_pair', GetoptLong::REQUIRED_ARGUMENT]]
  end


  def encoding_print_string
    'strings_to_encode: ' + self.strings_to_encode.to_s + print_string_padding +
    'subdirectory: ' + self.subdirectory.to_s + print_string_padding +
    'gpg_key_pair: ' + self.gpg_key_pair.to_json
  end
end

SimpleGPGDecrypt.new.run