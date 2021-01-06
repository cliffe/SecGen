#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'count function' do
  describe 'success' do
    pp1 = <<-DOC
      $input = [1,2,3,4]
      $output = count($input)
      notify { "$output": }
    DOC
    it 'counts elements in an array' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: 4})
      end
    end

    pp2 = <<-DOC
      $input = [1,1,1,2]
      $output = count($input, 1)
      notify { "$output": }
    DOC
    it 'counts elements in an array that match a second argument' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: 3})
      end
    end
  end
end
