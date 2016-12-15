#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_encoder.rb'
class AccountHashBuilder < StringEncoder
  attr_accessor :input_username
  attr_accessor :input_password
  attr_accessor :input_super_user
  attr_accessor :input_strings_to_leak
  attr_accessor :input_leaked_filenames

  def initialize
    super
    self.module_name = 'Account Hash Builder'
    self.input_username = ''
    self.input_password = ''
    self.input_super_user = ''
    self.input_strings_to_leak = []
    self.input_leaked_filenames = []
  end

  def encode_all
    account_hash = {}
    account_hash['username'] = self.input_username
    account_hash['password'] = self.input_password
    account_hash['super_user'] = self.input_super_user
    account_hash['strings_to_leak'] = self.input_strings_to_leak
    account_hash['leaked_filenames'] = self.input_leaked_filenames

    self.outputs << account_hash
  end

  def read_arguments
    # Get command line arguments
    opts = GetoptLong.new(
        [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
        [ '--strings_to_encode', '-s', GetoptLong::OPTIONAL_ARGUMENT ],
        [ '--strings_to_leak', GetoptLong::OPTIONAL_ARGUMENT ],
        [ '--leaked_filenames', GetoptLong::OPTIONAL_ARGUMENT ],
        [ '--username', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--password', GetoptLong::REQUIRED_ARGUMENT ],
        [ '--super_user', GetoptLong::REQUIRED_ARGUMENT ],
    )

    # process option arguments
    opts.each do |opt, arg|
      case opt
        when '--help'
          usage
        when '--username'
          self.input_username << arg;
        when '--password'
          self.input_password << arg;
        when '--super_user'
          self.input_super_user << arg;
        when '--strings_to_leak'
          self.input_strings_to_leak << arg;
        when '--leaked_filenames'
          self.input_leaked_filenames << arg;
        else
          Print.err "Argument not valid: #{arg}"
          usage
          exit
      end
    end
  end

  def encoding_print_string
    'username: ' + self.input_username.to_s + ',
    password: ' + self.input_password.to_s  + ',
    super_user: ' + self.input_super_user.to_s + ',
    strings_to_leak: ' + self.input_strings_to_leak.to_s + ',
    leaked_filenames: ' + self.input_leaked_filenames.to_s
  end
end

AccountHashBuilder.new.run
