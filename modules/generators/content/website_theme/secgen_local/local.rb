#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'faker'

class WebsiteThemeSelector < StringEncoder

  def initialize
    super
    self.module_name = 'Website Theme Selector'
  end

  # Selects one of the parameterised_website css themes and returns it
  def encode_all
    filenames = Dir.entries("#{ROOT_DIR}/modules/services/unix/http/parameterised_website/files/themes/").reject {|f| File.directory?(f) || f[0].include?('.')}
    self.outputs << filenames.sample
  end

end

WebsiteThemeSelector.new.run