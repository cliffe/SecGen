#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'lstrip function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ["  the   ","   public   ","   art","galleries   "]
      # Anagram: Large picture halls, I bet
      $o = lstrip($a)
      notice(inline_template('lstrip is <%= @o.inspect %>'))
    DOC
    it 'lstrips arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{lstrip is \["the   ", "public   ", "art", "galleries   "\]})
      end
    end

    pp2 = <<-DOC
      $a = "   blowzy night-frumps vex'd jack q   "
      $o = lstrip($a)
      notice(inline_template('lstrip is <%= @o.inspect %>'))
    DOC
    it 'lstrips strings' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{lstrip is "blowzy night-frumps vex'd jack q   "})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings or arrays'
  end
end
