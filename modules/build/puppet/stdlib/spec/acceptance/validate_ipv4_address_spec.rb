#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'validate_ipv4_address function' do
  describe 'success' do
    pp1 = <<-DOC
      $one = '1.2.3.4'
      validate_ipv4_address($one)
    DOC
    it 'validates a single argument' do
      apply_manifest(pp1, :catch_failures => true)
    end

    pp2 = <<-DOC
      $one = '1.2.3.4'
      $two = '5.6.7.8'
      validate_ipv4_address($one,$two)
    DOC
    it 'validates an multiple arguments' do
      apply_manifest(pp2, :catch_failures => true)
    end
  end
  describe 'failure' do
    it 'handles improper number of arguments'
    it 'handles ipv6 addresses'
    it 'handles non-ipv4 strings'
    it 'handles numbers'
    it 'handles no arguments'
  end
end
