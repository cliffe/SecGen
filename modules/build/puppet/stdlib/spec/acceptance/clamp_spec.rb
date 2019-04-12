#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'clamp function' do
  describe 'success' do
    it 'clamps list of values' do
      pp = <<-EOS
      $x = 17
      $y = 225
      $z = 155
      $o = clamp($x, $y, $z)
      if $o == $z {
        notify { 'output correct': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end
    it 'clamps array of values' do
      pp = <<-EOS
      $a = [7, 19, 66]
      $b = 19
      $o = clamp($a)
      if $o == $b {
        notify { 'output correct': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
    it 'handles no arguments'
  end
end
