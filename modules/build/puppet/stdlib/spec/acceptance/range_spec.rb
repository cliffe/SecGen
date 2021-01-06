#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'range function' do
  describe 'success' do
    pp1 = <<-DOC
      $o = range('a','d')
      notice(inline_template('range is <%= @o.inspect %>'))
    DOC
    it 'ranges letters' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{range is \["a", "b", "c", "d"\]})
      end
    end

    pp2 = <<-DOC
      $o = range('a','d', '2')
      notice(inline_template('range is <%= @o.inspect %>'))
    DOC
    it 'ranges letters with a step' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{range is \["a", "c"\]})
      end
    end
    it 'ranges letters with a negative step'
    it 'ranges numbers'
    it 'ranges numbers with a step'
    it 'ranges numbers with a negative step'
    it 'ranges numeric strings'
    it 'ranges zero padded numbers'
  end
  describe 'failure' do
    it 'fails with no arguments'
  end
end
