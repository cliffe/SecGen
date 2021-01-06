#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'capitalize function' do
  describe 'success' do
    pp1 = <<-DOC
        $input = 'this is a string'
        $output = capitalize($input)
        notify { $output: }
    DOC
    it 'capitalizes the first letter of a string' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: This is a string})
      end
    end

    pp2 = <<-DOC
      $input = ['this', 'is', 'a', 'string']
      $output = capitalize($input)
      notify { $output: }
    DOC
    regex_array = [%r{Notice: This}, %r{Notice: Is}, %r{Notice: A}, %r{Notice: String}]
    it 'capitalizes the first letter of an array of strings' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        regex_array.each do |i|
          expect(r.stdout).to match(i)
        end
      end
    end
  end
end
