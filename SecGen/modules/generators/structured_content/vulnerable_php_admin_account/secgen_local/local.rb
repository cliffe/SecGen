#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class AdminAccountGenerator < StringEncoder
  attr_accessor :username
  attr_accessor :password
  attr_accessor :name
  attr_accessor :address

  def initialize
    super
    self.module_name = 'Admin Account Generator / Builder'
    self.username = ''
    self.password = ''
    self.name = ''
    self.address = []

  end

  def encode_all
    account_hash = {}
    account_hash['username'] = self.username
    account_hash['password'] = self.password
    account_hash['name'] = self.name
    account_hash['address'] = self.address

    self.outputs << account_hash.to_json
  end

  def get_options_array
    super + [['--address', GetoptLong::OPTIONAL_ARGUMENT],
             ['--name', GetoptLong::OPTIONAL_ARGUMENT],
             ['--password', GetoptLong::OPTIONAL_ARGUMENT],
             ['--username', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--username'
        self.username << arg;
      when '--password'
        self.password << arg;
      when '--name'
        self.name << arg;
      when '--address'
        self.address << arg;
    end
  end

  def encoding_print_string
    'username: ' + self.username.to_s + print_string_padding +
    'password: ' + self.password.to_s  + print_string_padding +
    'address: ' + self.address.to_s + print_string_padding +
    'name: ' + self.name.to_s
  end
end

AdminAccountGenerator.new.run
