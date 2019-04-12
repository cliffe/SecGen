#!/usr/bin/ruby
require_relative '../../../../../lib/objects/local_string_generator.rb'
class WelcomeMessageGenerator < StringGenerator
  def initialize
    super
    self.module_name = 'Welcome Message Generator'
  end

  def generate
    messages = ['Welcome to the server!', 'Greetings! Welcome to the server.', "G'day mate!"]
    self.outputs << messages.sample
  end
end

WelcomeMessageGenerator.new.run