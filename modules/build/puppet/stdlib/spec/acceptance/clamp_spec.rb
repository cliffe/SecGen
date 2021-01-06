#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'clamp function' do
  describe 'success' do
    pp1 = <<-DOC
      $x = 17
      $y = 225
      $z = 155
      $o = clamp($x, $y, $z)
      if $o == $z {
        notify { 'output correct': }
      }
    DOC
    it 'clamps list of values' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = [7, 19, 66]
      $b = 19
      $o = clamp($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'clamps array of values' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles no arguments'
  end
end
