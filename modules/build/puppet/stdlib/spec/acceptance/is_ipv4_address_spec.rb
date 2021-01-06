#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'is_ipv4_address function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = '1.2.3.4'
      $b = true
      $o = is_ipv4_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_ipv4_addresss' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = "aoeu"
      $b = false
      $o = is_ipv4_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_ipv4_addresss strings' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp3 = <<-DOC
      $a = '1.2.3.400'
      $b = false
      $o = is_ipv4_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_ipv4_addresss ipv4 out of range' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
  end
end
