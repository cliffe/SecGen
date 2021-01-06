#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'is_array function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ['aaa','bbb','ccc']
      $b = true
      $o = is_array($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_arrays arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = []
      $b = true
      $o = is_array($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_arrays empty arrays' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp3 = <<-DOC
      $a = "aoeu"
      $b = false
      $o = is_array($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_arrays strings' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp4 = <<-DOC
      $a = {'aaa'=>'bbb'}
      $b = false
      $o = is_array($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_arrays hashes' do
      apply_manifest(pp4, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-arrays'
  end
end
