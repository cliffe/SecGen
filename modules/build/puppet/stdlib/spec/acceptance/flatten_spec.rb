#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'flatten function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ["a","b",["c",["d","e"],"f","g"]]
      $b = ["a","b","c","d","e","f","g"]
      $o = flatten($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'flattens arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = ["a","b","c","d","e","f","g"]
      $b = ["a","b","c","d","e","f","g"]
      $o = flatten($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'does not affect flat arrays' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-strings'
  end
end
