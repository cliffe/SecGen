#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'is_bool function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ['aaa','bbb','ccc']
      $b = false
      $o = is_bool($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_bools arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = true
      $b = true
      $o = is_bool($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_bools true' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp3 = <<-DOC
      $a = false
      $b = true
      $o = is_bool($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_bools false' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp4 = <<-DOC
      $a = "true"
      $b = false
      $o = is_bool($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_bools strings' do
      apply_manifest(pp4, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp5 = <<-DOC
      $a = {'aaa'=>'bbb'}
      $b = false
      $o = is_bool($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_bools hashes' do
      apply_manifest(pp5, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles non-arrays'
  end
end
