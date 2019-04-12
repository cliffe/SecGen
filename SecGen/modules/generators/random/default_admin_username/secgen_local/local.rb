#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class AdminUsernameGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Default Admin Username Generator'
  end

  def generate
    creds = File.readlines("#{WORDLISTS_DIR}/admin_name")

    self.outputs << creds.sample.chomp
  end
end

AdminUsernameGenerator.new.run
