#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'size function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = 'discombobulate'
      $o = size($a)
      notice(inline_template('size is <%= @o.inspect %>'))
    DOC
    it 'single string size' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{size is 14})
      end
    end

    pp2 = <<-DOC
      $a = ''
      $o = size($a)
      notice(inline_template('size is <%= @o.inspect %>'))
    DOC
    it 'with empty string' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{size is 0})
      end
    end

    pp3 = <<-DOC
      $a = undef
      $o = size($a)
      notice(inline_template('size is <%= @o.inspect %>'))
    DOC
    it 'with undef' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{size is 0})
      end
    end

    pp4 = <<-DOC
      $a = ['discombobulate', 'moo']
      $o = size($a)
      notice(inline_template('size is <%= @o.inspect %>'))
    DOC
    it 'strings in array' do
      apply_manifest(pp4, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{size is 2})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings or arrays'
  end
end
