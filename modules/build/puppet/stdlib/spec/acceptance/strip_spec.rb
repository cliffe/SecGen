#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'strip function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = ["  the   ","   public   ","   art","galleries   "]
      # Anagram: Large picture halls, I bet
      $o = strip($a)
      notice(inline_template('strip is <%= @o.inspect %>'))
    DOC
    it 'strips arrays' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{strip is \["the", "public", "art", "galleries"\]})
      end
    end

    pp2 = <<-DOC
      $a = "   blowzy night-frumps vex'd jack q   "
      $o = strip($a)
      notice(inline_template('strip is <%= @o.inspect %>'))
    DOC
    it 'strips strings' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{strip is "blowzy night-frumps vex'd jack q"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings or arrays'
  end
end
