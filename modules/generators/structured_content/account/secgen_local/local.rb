#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class AccountGenerator < StringEncoder
  attr_accessor :username
  attr_accessor :password
  attr_accessor :super_user
  attr_accessor :strings_to_leak
  attr_accessor :leaked_filenames
  attr_accessor :data_to_leak

  def initialize
    super
    self.module_name = 'Account Generator / Builder'
    self.username = ''
    self.password = ''
    self.super_user = ''
    self.strings_to_leak = []
    self.data_to_leak = []
    self.leaked_filenames = []
  end

  def encode_all
    account_hash = {}
    account_hash['username'] = self.username
    account_hash['password'] = self.password
    account_hash['super_user'] = self.super_user
    account_hash['strings_to_leak'] = self.strings_to_leak
    account_hash['leaked_filenames'] = self.leaked_filenames
    account_hash['data_to_leak'] = self.data_to_leak

    self.outputs << account_hash.to_json
  end

  def get_options_array
    super + [['--strings_to_leak', GetoptLong::OPTIONAL_ARGUMENT],
             ['--leaked_filenames', GetoptLong::OPTIONAL_ARGUMENT],
             ['--data_to_leak', GetoptLong::OPTIONAL_ARGUMENT],
             ['--username', GetoptLong::REQUIRED_ARGUMENT],
             ['--password', GetoptLong::REQUIRED_ARGUMENT],
             ['--super_user', GetoptLong::REQUIRED_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
      when '--username'
        self.username << arg;
      when '--password'
        self.password << arg;
      when '--super_user'
        self.super_user << arg;
      when '--strings_to_leak'
        self.strings_to_leak << arg;
      when '--leaked_filenames'
        self.leaked_filenames << arg;
      when '--data_to_leak'
        self.data_to_leak << arg;
    end
  end

  def encoding_print_string
    'username: ' + self.username.to_s + print_string_padding +
    'password: ' + self.password.to_s  + print_string_padding +
    'super_user: ' + self.super_user.to_s + print_string_padding +
    'strings_to_leak: ' + self.strings_to_leak.to_s + print_string_padding +
    'leaked_filenames: ' + self.leaked_filenames.to_s + print_string_padding +
    'data_to_leak: ' + self.data_to_leak.to_s
  end
end

AccountGenerator.new.run
