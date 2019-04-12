#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'is_ipv4_address function' do
  describe 'success' do
    it 'is_ipv4_addresss' do
      pp = <<-EOS
      $a = '1.2.3.4'
      $b = true
      $o = is_ipv4_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end
    it 'is_ipv4_addresss strings' do
      pp = <<-EOS
      $a = "aoeu"
      $b = false
      $o = is_ipv4_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/Notice: output correct/)
      end
    end
    it 'is_ipv4_addresss ipv4 out of range' do
      pp = <<-EOS
      $a = '1.2.3.400'
      $b = false
      $o = is_ipv4_address($a)
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
  end
end
