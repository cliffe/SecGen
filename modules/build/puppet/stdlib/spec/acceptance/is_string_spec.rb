#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'is_string function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ['aaa.com','bbb','ccc']
      $b = false
      $o = is_string($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_strings arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = true
      $b = false
      $o = is_string($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_strings true' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp3 = <<-DOC
      $a = "aoeu"
      $o = is_string($a)
      notice(inline_template('is_string is <%= @o.inspect %>'))
    DOC
    it 'is_strings strings' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{is_string is true})
      end
    end

    pp4 = <<-DOC
      $a = "3"
      $o = is_string($a)
      notice(inline_template('is_string is <%= @o.inspect %>'))
    DOC
    it 'is_strings number strings' do
      apply_manifest(pp4, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{is_string is false})
      end
    end

    pp5 = <<-DOC
      $a = 3.5
      $b = false
      $o = is_string($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_strings floats' do
      apply_manifest(pp5, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp6 = <<-DOC
      $a = 3
      $b = false
      $o = is_string($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_strings integers' do
      apply_manifest(pp6, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp7 = <<-DOC
      $a = {'aaa'=>'www.com'}
      $b = false
      $o = is_string($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_strings hashes' do
      apply_manifest(pp7, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp8 = <<-DOC
      $a = undef
      $o = is_string($a)
      notice(inline_template('is_string is <%= @o.inspect %>'))
    DOC
    it 'is_strings undef' do
      apply_manifest(pp8, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{is_string is true})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
  end
end
