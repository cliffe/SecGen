#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'hash function' do
  describe 'success' do
    pp = <<-DOC
      $a = ['aaa','bbb','bbb','ccc','ddd','eee']
      $b = { 'aaa' => 'bbb', 'bbb' => 'ccc', 'ddd' => 'eee' }
      $o = hash($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'hashs arrays' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
    it 'handles odd-length arrays'
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-arrays'
  end
end
