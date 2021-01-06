#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'chomp function' do
  describe 'success' do
    pp = <<-DOC
      $input = "test\n"
      if size($input) != 5 {
        fail("Size of ${input} is not 5.")
      }
      $output = chomp($input)
      if size($output) != 4 {
        fail("Size of ${input} is not 4.")
      }
    DOC
    it 'eats the newline' do
      apply_manifest(pp, :catch_failures => true)
    end
  end
end
