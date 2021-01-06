#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'str2saltedsha512 function' do
  describe 'success' do
    pp = <<-DOC
      $o = str2saltedsha512('password')
      notice(inline_template('str2saltedsha512 is <%= @o.inspect %>'))
    DOC
    it 'works with "y"' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{str2saltedsha512 is "[a-f0-9]{136}"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles more than one argument'
    it 'handles non strings'
  end
end
