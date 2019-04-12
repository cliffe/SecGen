#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
require 'faker'

class BusinessEmailEncoder < StringEncoder
  attr_accessor :name
  attr_accessor :business_name
  attr_accessor :domain

  def initialize
    super
    self.module_name = 'Business Email Encoder'
    self.name = ''
    self.business_name = ''
    self.domain = ''
  end

  def encode_all
    # ensure variables are populated
    self.name = Faker::Name::name if self.name.empty?
    self.business_name = Faker::Company::name if self.business_name.empty?

    # generate parts of email
    local_part = Faker::Internet.user_name(self.name, ['-'])

    if self.domain.empty?
      self.domain = craft_domain
      tld = %w(org com net co.uk).sample
      self.outputs << "#{local_part}@#{self.domain}.#{tld}"
    else
      self.outputs << "#{local_part}@#{self.domain}"
    end
  end

  # Creates a domain from the business_name
  def craft_domain
    domain = self.business_name
    # replace spaces
    domain = domain.downcase.tr(' ', %w(_ -).sample)
    # strip punctuation and return
    domain.gsub(/[^0-9a-z\s_-]/i, '')
  end

  def get_options_array
    super + [['--name', GetoptLong::REQUIRED_ARGUMENT],
             ['--business_name', GetoptLong::REQUIRED_ARGUMENT],
             ['--domain', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--name'
        self.name << arg;
      when '--business_name'
        self.business_name << arg;
      when '--domain'
        self.domain << arg;
    end
  end

  def encoding_print_string
    no_input_message = 'to generate...'

    if self.name.to_s.empty?
      name = no_input_message
    else
      name = self.name.to_s
    end

    if self.business_name.to_s.empty?
      business_name = no_input_message
    else
      business_name = self.business_name.to_s
    end

    if self.domain.to_s.empty?
      domain = no_input_message
    else
      domain = self.domain.to_s
    end

    'name: ' + name + print_string_padding +
    'business_name: ' + business_name + print_string_padding +
    'domain: ' + domain
  end
end

BusinessEmailEncoder.new.run