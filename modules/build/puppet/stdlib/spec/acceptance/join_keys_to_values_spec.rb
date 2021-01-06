#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'join_keys_to_values function' do
  describe 'success' do
    pp = <<-DOC
      $a = {'aaa'=>'bbb','ccc'=>'ddd'}
      $b = ':'
      $o = join_keys_to_values($a,$b)
      notice(inline_template('join_keys_to_values is <%= @o.sort.inspect %>'))
    DOC
    it 'join_keys_to_valuess hashes' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{join_keys_to_values is \["aaa:bbb", "ccc:ddd"\]})
      end
    end
    it 'handles non hashes'
    it 'handles empty hashes'
  end
  describe 'failure' do
    it 'handles improper argument counts'
  end
end
