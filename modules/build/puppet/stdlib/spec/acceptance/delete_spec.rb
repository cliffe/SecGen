#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'delete function' do
  pp = <<-DOC
      $output = delete(['a','b','c','b'], 'b')
      if $output == ['a','c'] {
        notify { 'output correct': }
      }
  DOC
  describe 'success' do
    it 'deletes elements of the array' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
end
