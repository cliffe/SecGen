#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'

class MailIDGenerator < StringGenerator

  def initialize
    super
    self.module_name = 'Mail ID Generator'
  end

  def generate
    # format XXXXXXX-XXXXX-XX  7-6-2
    first = 7.times.map { [*'0'..'9', *'a'..'z'].sample }.join.upcase
    second = 6.times.map { [*'0'..'9', *'a'..'z'].sample }.join.upcase
    third = 2.times.map { [*'0'..'9', *'a'..'z'].sample }.join
    self.outputs << "#{first}-#{second}-#{third}"
  end

end

MailIDGenerator.new.run