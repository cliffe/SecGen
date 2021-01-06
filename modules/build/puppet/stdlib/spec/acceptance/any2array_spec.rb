#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'any2array function' do
  describe 'success' do
    pp1 = <<-DOC
      $input = ''
      $output = any2array($input)
      validate_array($output)
      notify { "Output: ${output}": }
    DOC
    it 'creates an empty array' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: Output: })
      end
    end

    pp2 = <<-DOC
      $input = ['array', 'test']
      $output = any2array($input)
      validate_array($output)
      notify { "Output: ${output}": }
    DOC
    it 'leaves arrays modified' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: Output: (\[|)array(,\s|)test(\]|)})
      end
    end

    pp3 = <<-DOC
      $input = {'test' => 'array'}
      $output = any2array($input)

      validate_array($output)
      # Check each element of the array is a plain string.
      validate_string($output[0])
      validate_string($output[1])
      notify { "Output: ${output}": }
    DOC
    it 'turns a hash into an array' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: Output: (\[|)test(,\s|)array(\]|)})
      end
    end
  end
end
