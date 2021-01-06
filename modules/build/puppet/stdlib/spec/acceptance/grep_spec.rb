#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'grep function' do
  describe 'success' do
    pp = <<-DOC
      $a = ['aaabbb','bbbccc','dddeee']
      $b = 'bbb'
      $c = ['aaabbb','bbbccc']
      $o = grep($a,$b)
      if $o == $c {
        notify { 'output correct': }
      }
    DOC
    it 'greps arrays' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-arrays'
  end
end
