#!/usr/bin/ruby
require_relative '../../../../lib/objects/local_string_encoder.rb'
require 'faker'

class DomainGenerator < StringEncoder
  attr_accessor :name

  def initialize
    super
    self.module_name = 'Domain Encoder'
    self.name = ''
  end

  def encode_all
    domain = craft_domain
    tld = %w(org com net co.uk).sample

    self.outputs << "#{domain}.#{tld}"
  end

  # Creates a domain from the business_name
  def craft_domain
    domain = self.name
    # replace spaces
    domain = domain.downcase.tr(' ', %w(_ -).sample)
    # strip punctuation and return
    domain.gsub(/[^0-9a-z\s_-]/i, '')
  end

  def process_options(opt, arg)
    super
    if opt == '--name'
      self.name << arg
    end
  end

  def get_options_array
    super + [['--name', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def encoding_print_string
    'name: ' + self.name.to_s
  end
end

DomainGenerator.new.run