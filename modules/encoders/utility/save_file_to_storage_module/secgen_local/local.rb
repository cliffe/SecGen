#!/usr/bin/ruby
require 'fileutils'
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class SaveFileToStorageModule < StringEncoder
  attr_accessor :file_path

  def initialize
    super
    self.module_name = 'Save file to storage module'
    self.file_path = ''
  end

  def encode_all
    filename = Base64.decode64(file_path).split('/').last
    # filename = file_path.split('/').last
    FileUtils.cp Base64.decode64(file_path), "#{FILE_TRANSFER_STORAGE_MODULE_DIR}/files/#{filename}"
    self.outputs << filename
  end

  def get_options_array
    super + [['--file_path', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--file_path'
        self.file_path << arg;
    end
  end
end

SaveFileToStorageModule.new.run
