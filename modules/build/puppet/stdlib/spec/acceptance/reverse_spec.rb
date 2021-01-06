#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'reverse function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = "the public art galleries"
      # Anagram: Large picture halls, I bet
      $o = reverse($a)
      notice(inline_template('reverse is <%= @o.inspect %>'))
    DOC
    it 'reverses strings' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{reverse is "seirellag tra cilbup eht"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings or arrays'
  end
end
