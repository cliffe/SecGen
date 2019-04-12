#!/usr/bin/ruby
require_relative '../../../../../../lib/objects/local_string_generator.rb'
class QuestionTableGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Question table name'
  end

  def generate

    table_name = ['question','review', 'customer_review']
    selected_table_name = table_name.sample

    name_column = ['name','firstname', 'companyname', 'names', 'fullname']
    selected_name_heading = name_column.sample

    mobile_column = ['mobile','phone', 'phonenumber', 'landline']
    selected_mobile_heading = mobile_column.sample

    email_column = ['email_address','contact_email', 'email']
    selected_email_heading = email_column.sample

    output = selected_table_name + "," + selected_name_heading + "," + selected_mobile_heading + "," + selected_email_heading

    self.outputs << output
  end
end

QuestionTableGenerator.new.run
