#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'delete_undef_values function' do
  describe 'success' do
    pp = <<-DOC
      $output = delete_undef_values({a=>'A', b=>'', c=>undef, d => false})
      if $output == { a => 'A', b => '', d => false } {
        notify { 'output correct': }
      }
    DOC
    it 'deletes elements of the array' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
end
