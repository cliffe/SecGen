#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'is_ip_address function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = '1.2.3.4'
      $b = true
      $o = is_ip_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_ip_addresss ipv4' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = "fe80:0000:cd12:d123:e2f8:47ff:fe09:dd74"
      $b = true
      $o = is_ip_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_ip_addresss ipv6' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp3 = <<-DOC
      $a = "fe00::1"
      $b = true
      $o = is_ip_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_ip_addresss ipv6 compressed' do
      apply_manifest(pp3, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp4 = <<-DOC
      $a = "aoeu"
      $b = false
      $o = is_ip_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_ip_addresss strings' do
      apply_manifest(pp4, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp5 = <<-DOC
      $a = '1.2.3.400'
      $b = false
      $o = is_ip_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_ip_addresss ipv4 out of range' do
      apply_manifest(pp5, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
  end
end
