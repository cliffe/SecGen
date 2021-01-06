#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'num2bool function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = 1
      $b = "1"
      $c = "50"
      $ao = num2bool($a)
      $bo = num2bool($b)
      $co = num2bool($c)
      notice(inline_template('a is <%= @ao.inspect %>'))
      notice(inline_template('b is <%= @bo.inspect %>'))
      notice(inline_template('c is <%= @co.inspect %>'))
    DOC
    regex_array_true = [%r{a is true}, %r{b is true}, %r{c is true}]
    it 'bools positive numbers and numeric strings as true' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        regex_array_true.each do |i|
          expect(r.stdout).to match(i)
        end
      end
    end

    pp2 = <<-DOC
      $a = 0
      $b = -0.1
      $c = ["-50","1"]
      $ao = num2bool($a)
      $bo = num2bool($b)
      $co = num2bool($c)
      notice(inline_template('a is <%= @ao.inspect %>'))
      notice(inline_template('b is <%= @bo.inspect %>'))
      notice(inline_template('c is <%= @co.inspect %>'))
    DOC
    regex_array_false = [%r{a is false}, %r{b is false}, %r{c is false}]
    it 'bools negative numbers as false' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        regex_array_false.each do |i|
          expect(r.stdout).to match(i)
        end
      end
    end
  end

  describe 'failure' do
    pp3 = <<-DOC
      $a = "a"
      $ao = num2bool($a)
      notice(inline_template('a is <%= @ao.inspect %>'))
    DOC
    it 'fails on words' do
      expect(apply_manifest(pp3, :expect_failures => true).stderr).to match(%r{not look like a number})
    end

    pp4 = <<-DOC
      $b = "1b"
      $bo = num2bool($b)
      notice(inline_template('b is <%= @bo.inspect %>'))
    DOC
    it 'fails on numberwords' do
      expect(apply_manifest(pp4, :expect_failures => true).stderr).to match(%r{not look like a number})
    end

    pp5 = <<-DOC # rubocop:disable Lint/UselessAssignment
      $c = {"c" => "-50"}
      $co = num2bool($c)
      notice(inline_template('c is <%= @co.inspect %>'))
    DOC
    it 'fails on non-numeric/strings' do
      pending "The function will call .to_s.to_i on anything not a Numeric or
      String, and results in 0. Is this intended?"
      expect(apply_manifest(pp5(:expect_failures => true)).stderr).to match(%r{Unable to parse})
    end
  end
end
