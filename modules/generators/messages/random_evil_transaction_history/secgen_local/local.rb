#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class EvilTransactionHistoryGenerator < StringGenerator

  def initialize
    super
    self.module_name = 'Random Evil Transaction History Generator'
  end

  def generate
    # read all the lines, and select one at random
    self.outputs.push *File.readlines("#{LINELISTS_DIR}/transaction_history_evil").sample(5)
  end
end

EvilTransactionHistoryGenerator.new.run
