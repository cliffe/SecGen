#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'is_numeric function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ['aaa.com','bbb','ccc']
      $b = false
      $o = is_numeric($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_numerics arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = true
      $b = false
      $o = is_numeric($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_numerics true' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp3 = <<-DOC
      $a = "3"
      $b = true
      $o = is_numeric($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_numerics strings' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp4 = <<-DOC
      $a = 3.5
      $b = true
      $o = is_numeric($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_numerics floats' do
      apply_manifest(pp4, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp5 = <<-DOC
      $a = 3
      $b = true
      $o = is_numeric($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_numerics integers' do
      apply_manifest(pp5, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp6 = <<-DOC
      $a = {'aaa'=>'www.com'}
      $b = false
      $o = is_numeric($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_numerics hashes' do
      apply_manifest(pp6, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-arrays'
  end
end
