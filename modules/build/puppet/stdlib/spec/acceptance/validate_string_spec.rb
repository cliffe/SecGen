#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'validate_string function' do
  describe 'success' do
    pp1 = <<-DOC
      $one = 'string'
      validate_string($one)
    DOC
    it 'validates a single argument' do
      apply_manifest(pp1, :catch_failures => true)
    end

    pp2 = <<-DOC
      $one = 'string'
      $two = 'also string'
      validate_string($one,$two)
    DOC
    it 'validates an multiple arguments' do
      apply_manifest(pp2, :catch_failures => true)
    end

    pp3 = <<-DOC
      validate_string(undef)
    DOC
    it 'validates undef' do
      apply_manifest(pp3, :catch_failures => true)
    end

    {
      %{validate_string({ 'a' => 'hash' })} => 'Hash',
      %{validate_string(['array'])}         => 'Array',
      %{validate_string(false)}             => 'FalseClass',
    }.each do |pp4, type|
      it "validates a non-string: #{pp4.inspect}" do
        expect(apply_manifest(pp4, :expect_failures => true).stderr).to match(%r{a #{type}})
      end
    end
  end
  describe 'failure' do
    it 'handles improper number of arguments'
  end
end
