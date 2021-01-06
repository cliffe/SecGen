#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'getparam function' do
  describe 'success' do
    pp = <<-DOC
      notify { 'rspec':
        message => 'custom rspec message',
      }
      $o = getparam(Notify['rspec'], 'message')
      notice(inline_template('getparam is <%= @o.inspect %>'))
    DOC
    it 'getparam a notify' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{getparam is "custom rspec message"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings'
  end
end
