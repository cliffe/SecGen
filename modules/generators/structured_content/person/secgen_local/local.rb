#!/usr/bin/ruby
require 'json'
require_relative '../../../../../lib/objects/local_string_encoder.rb'

class PersonHashBuilder < StringEncoder
  attr_accessor :name
  attr_accessor :address
  attr_accessor :phone_number
  attr_accessor :email_address
  attr_accessor :username
  attr_accessor :password
  attr_accessor :account
  attr_accessor :credit_card
  attr_accessor :national_insurance_number

  def initialize
    super
    self.module_name = 'Person Hash Builder'
    self.name = ''
    self.address = ''
    self.phone_number = ''
    self.email_address = ''
    self.username = ''
    self.password = ''
    self.credit_card = ''
    self.national_insurance_number = ''
    self.account = []
  end

  def encode_all
    person_hash = {}
    person_hash['name'] = self.name
    person_hash['address'] = self.address
    person_hash['phone_number'] = self.phone_number
    person_hash['email_address'] = self.email_address
    person_hash['credit_card'] = self.credit_card
    person_hash['national_insurance_number'] = self.national_insurance_number

    if self.account != []
      account = JSON.parse(self.account[0])
      person_hash['username'] = account['username']
      person_hash['password'] = account['password']
    else
      person_hash['username'] = self.username
      person_hash['password'] = self.password
    end

    self.outputs << person_hash.to_json
  end

  def get_options_array
    super + [['--name', GetoptLong::REQUIRED_ARGUMENT],
             ['--address', GetoptLong::REQUIRED_ARGUMENT],
             ['--phone_number', GetoptLong::REQUIRED_ARGUMENT],
             ['--email_address', GetoptLong::REQUIRED_ARGUMENT],
             ['--username', GetoptLong::REQUIRED_ARGUMENT],
             ['--password', GetoptLong::REQUIRED_ARGUMENT],
             ['--credit_card', GetoptLong::REQUIRED_ARGUMENT],
             ['--national_insurance_number', GetoptLong::REQUIRED_ARGUMENT],
             ['--account', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--name'
        self.name << arg;
      when '--address'
        self.address << arg;
      when '--phone_number'
        self.phone_number << arg;
      when '--email_address'
        self.email_address << arg;
      when '--username'
        self.username << arg;
      when '--password'
        self.password << arg;
      when '--credit_card'
        self.credit_card << arg;
      when '--national_insurance_number'
        self.national_insurance_number << arg;
      when '--account'
        self.account << arg;
    end
  end

  def encoding_print_string
    'name: ' + self.name.to_s + print_string_padding +
    'address: ' + self.address.to_s  + print_string_padding +
    'phone_number: ' + self.phone_number.to_s + print_string_padding +
    'email_address: ' + self.email_address.to_s + print_string_padding +
    'username: ' + self.username.to_s + print_string_padding +
    'password: ' + self.password.to_s + print_string_padding +
    'credit_card: ' + self.credit_card.to_s + print_string_padding +
    'national_insurance_number: ' + self.national_insurance_number.to_s + print_string_padding +
    'account: ' + self.account.to_s
  end
end

PersonHashBuilder.new.run
