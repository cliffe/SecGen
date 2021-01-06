#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'values_at function' do
  describe 'success' do
    pp1 = <<-DOC
      $one = ['a','b','c','d','e']
      $two = 1
      $output = values_at($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'returns a specific value' do
      expect(apply_manifest(pp1, :catch_failures => true).stdout).to match(%r{\["b"\]})
    end

    pp2 = <<-DOC
      $one = ['a','b','c','d','e']
      $two = -1
      $output = values_at($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'returns a specific negative index value' do
      pending("negative numbers don't work")
      expect(apply_manifest(pp2, :catch_failures => true).stdout).to match(%r{\["e"\]})
    end

    pp3 = <<-DOC
      $one = ['a','b','c','d','e']
      $two = "1-3"
      $output = values_at($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'returns a range of values' do
      expect(apply_manifest(pp3, :catch_failures => true).stdout).to match(%r{\["b", "c", "d"\]})
    end

    pp4 = <<-DOC
      $one = ['a','b','c','d','e']
      $two = ["1-3",0]
      $output = values_at($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'returns a negative specific value and range of values' do
      expect(apply_manifest(pp4, :catch_failures => true).stdout).to match(%r{\["b", "c", "d", "a"\]})
    end
  end

  describe 'failure' do
    pp5 = <<-DOC
      $one = ['a','b','c','d','e']
      $output = values_at($one)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'handles improper number of arguments' do
      expect(apply_manifest(pp5, :expect_failures => true).stderr).to match(%r{Wrong number of arguments})
    end

    pp6 = <<-DOC
      $one = ['a','b','c','d','e']
      $two = []
      $output = values_at($one,$two)
      notice(inline_template('<%= @output.inspect %>'))
    DOC
    it 'handles non-indicies arguments' do
      expect(apply_manifest(pp6, :expect_failures => true).stderr).to match(%r{at least one positive index})
    end

    it 'detects index ranges smaller than the start range'
    it 'handles index ranges larger than array'
    it 'handles non-integer indicies'
  end
end
