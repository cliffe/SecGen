#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
class UserTableNameGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'product table headings'
  end

  def generate
    table_name = ['user','User', 'users', 'Users', 'accounts', 'account', 'user_accounts', 'user_account']
    selected_table_name = table_name.sample

    output = selected_table_name

    self.outputs << output
  end
end

UserTableNameGenerator.new.run
