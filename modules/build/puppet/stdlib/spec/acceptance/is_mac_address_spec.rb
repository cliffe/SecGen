#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'is_mac_address function' do
  describe 'success' do
    pp1 = <<-DOC
      $a = '00:a0:1f:12:7f:a0'
      $b = true
      $o = is_mac_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_mac_addresss a mac' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end

    pp2 = <<-DOC
      $a = '00:a0:1f:12:7f:g0'
      $b = false
      $o = is_mac_address($a)
      if $o == $b {
        notify { 'output correct': }
      }
    DOC
    it 'is_mac_addresss a mac out of range' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: output correct})
      end
    end
  end
  describe 'failure' do
    it 'handles improper argument counts'
  end
end
