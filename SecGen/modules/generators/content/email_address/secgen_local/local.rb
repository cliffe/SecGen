#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'faker'

class EmailAddressGenerator < StringEncoder
  attr_accessor :name

  def initialize
    super
    self.module_name = 'Email Address Generator'
    self.name = ''
  end

  def encode_all
    if self.name.empty?
      self.name = nil
    end
    self.outputs << Faker::Internet.email(self.name)
  end

  def get_options_array
    super + [['--name ', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    if opt == '--name'
      self.name << arg
    end
  end

  def encoding_print_string
    'name: ' + self.name.to_s
  end
end

EmailAddressGenerator.new.run