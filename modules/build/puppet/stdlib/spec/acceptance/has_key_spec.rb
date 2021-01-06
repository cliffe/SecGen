#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'has_key function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = { 'aaa' => 'bbb','bbb' => 'ccc','ddd' => 'eee' }
      $b = 'bbb'
      $c = true
      $o = has_key($a,$b)
      if $o == $c {
        notify { 'output correct': }
      }
    DOC
    it 'has_keys in hashes' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = { 'aaa' => 'bbb','bbb' => 'ccc','ddd' => 'eee' }
      $b = 'ccc'
      $c = false
      $o = has_key($a,$b)
      if $o == $c {
        notify { 'output correct': }
      }
    DOC
    it 'has_keys not in hashes' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-hashes'
  end
end
