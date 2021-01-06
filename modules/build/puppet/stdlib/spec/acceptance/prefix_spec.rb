#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'prefix function' do
  describe 'success' do
    pp1 = <<-DOC
      $o = prefix(['a','b','c'],'p')
      notice(inline_template('prefix is <%= @o.inspect %>'))
    DOC
    it 'prefixes array of values' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{prefix is \["pa", "pb", "pc"\]})
      end
    end

    pp2 = <<-DOC
      $o = prefix([],'p')
      notice(inline_template('prefix is <%= @o.inspect %>'))
    DOC
    it 'prefixs with empty array' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{prefix is \[\]})
      end
    end

    pp3 = <<-DOC
      $o = prefix(['a','b','c'], undef)
      notice(inline_template('prefix is <%= @o.inspect %>'))
    DOC
    it 'prefixs array of values with undef' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{prefix is \["a", "b", "c"\]})
      end
    end
  end
  describe 'failure' do
    it 'fails with no arguments'
    it 'fails when first argument is not array'
    it 'fails when second argument is not string'
  end
end
