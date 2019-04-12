#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class AdminUsernameGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Default Admin Password Generator'
  end

  def generate
    creds = File.readlines("#{WORDLISTS_DIR}/default_admin_passwords")

    self.outputs << creds.sample.chomp
  end
end

AdminUsernameGenerator.new.run
