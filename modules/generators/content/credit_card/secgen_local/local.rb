#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
require 'credy'

class CreditCardGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Credit Card Number Generator'
  end

  def generate
    selected_type = [['americanexpress', 'American Express'],
             ['diners-club-international', 'Diners Club International'],
             ['china-unionpay', 'China UnionPay'],
             ['laser', 'Laser'],
             ['maestro', 'Maestro'],
             ['mastercard', 'Mastercard'],
             ['solo', 'Solo'],
             ['switch', 'Switch'],
             ['visa', 'Visa'],
             ['visa-electron', 'Visa Electron']].sample

    card_data = Credy::CreditCard.generate(:type => selected_type[0])
    card_data_formatted = card_data[:number].scan(/.{1,4}/).join(' ') # add a space every 4 characters
    card_string = "#{selected_type[1]}\t#{card_data_formatted}"

    self.outputs << card_string
  end
end

CreditCardGenerator.new.run