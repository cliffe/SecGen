#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'has_ip_address function', :unless => ((fact('osfamily') == 'windows') || (fact('osfamily') == 'AIX')) do
  describe 'success' do
    pp1 = <<-DOC
      $a = '127.0.0.1'
      $o = has_ip_address($a)
      notice(inline_template('has_ip_address is <%= @o.inspect %>'))
    DOC
    it 'has_ip_address existing ipaddress' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{has_ip_address is true})
      end
    end

    pp2 = <<-DOC
      $a = '128.0.0.1'
      $o = has_ip_address($a)
      notice(inline_template('has_ip_address is <%= @o.inspect %>'))
    DOC
    it 'has_ip_address absent ipaddress' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{has_ip_address is false})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings'
  end
end
