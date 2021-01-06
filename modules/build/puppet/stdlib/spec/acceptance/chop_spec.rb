#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'chop function' do
  describe 'success' do
    pp1 = <<-DOC
      $input = "test"
      if size($input) != 4 {
        fail("Size of ${input} is not 4.")
      }
      $output = chop($input)
      if size($output) != 3 {
        fail("Size of ${input} is not 3.")
      }
    DOC
    it 'eats the last character' do
      apply_manifest(pp1, :catch_failures => true)
    end

    pp2 = <<-'DOC'
      $input = "test\r\n"
      if size($input) != 6 {
        fail("Size of ${input} is not 6.")
      }
      $output = chop($input)
      if size($output) != 4 {
        fail("Size of ${input} is not 4.")
      }
    DOC
    it 'eats the last two characters of \r\n' do
      apply_manifest(pp2, :catch_failures => true)
    end

    pp3 = <<-DOC
      $input = ""
      $output = chop($input)
    DOC
    it 'does not fail on empty strings' do
      apply_manifest(pp3, :catch_failures => true)
    end
  end
end
