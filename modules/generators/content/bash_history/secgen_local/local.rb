#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
# require 'erb'
require 'fileutils'
class BashHistoryGenerator < StringGenerator
  attr_accessor :password_sample

  def initialize
    super
    self.password_sample = ''
  end

  def get_options_array
    super + [['--password', GetoptLong::OPTIONAL_ARGUMENT]]
  end

  def process_options(opt, arg)
    super
    case opt
    when '--password'
      self.password_sample << arg;
    end
  end

  def generate
    sudo_array = File.readlines("#{LINELISTS_DIR}/sudo_commands")
    command_array = File.readlines("#{LINELISTS_DIR}/linux_commands")

    # choose some random command samples
    sudo_sample = sudo_array.sample(5)
    command_sample = command_array.sample(20)
    # if we have a password to leak, we can put it after a sudo command
    unless self.password_sample.empty?
      sudo_sample[0] += "#{self.password_sample}\n"
    end
    # copy to a flat array
    commands = [*sudo_sample, *command_sample]
    # output a shuffled array joined with new lines
    self.outputs << commands.shuffle.join
  end

end

BashHistoryGenerator.new.run
