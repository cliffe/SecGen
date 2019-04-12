#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
class StorageDirectoryGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Storage Directory Generator'
  end

  def generate
    # TODO: Fix the creation of subdirectories in puppet (nfs + smb) then re-introduce filler_path.
    # current_date_time = Time.now.strftime("%d-%m-%Y--%H%M")
    # random_number = rand(1..99)
    # filler_path = [ "/#{current_date_time}", "/files_#{random_number}", ''].sample

    directory_name = %w(exports repository files storage).sample

    full_path = '/' + directory_name # + filler_path
    self.outputs << full_path
  end
end

StorageDirectoryGenerator.new.run