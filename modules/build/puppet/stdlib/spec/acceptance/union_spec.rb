#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'union function' do
  describe 'success' do
    pp = <<-DOC
      $a = ["the","public"]
      $b = ["art"]
      $c = ["galleries"]
      # Anagram: Large picture halls, I bet
      $o = union($a,$b,$c)
      notice(inline_template('union is <%= @o.inspect %>'))
    DOC
    it 'unions arrays' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{union is \["the", "public", "art", "galleries"\]})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non arrays'
  end
end
