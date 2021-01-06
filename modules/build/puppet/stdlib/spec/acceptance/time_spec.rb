#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'time function' do
  describe 'success' do
    pp1 = <<-DOC
      $o = time()
      notice(inline_template('time is <%= @o.inspect %>'))
    DOC
    it 'gives the time' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        m = r.stdout.match(%r{time is (\d+)\D})
        # When I wrote this test
        expect(Integer(m[1])).to be > 1_398_894_170
      end
    end

    pp2 = <<-DOC
      $o = time('UTC')
      notice(inline_template('time is <%= @o.inspect %>'))
    DOC
    it 'takes a timezone argument' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        m = r.stdout.match(%r{time is (\d+)\D})
        expect(Integer(m[1])).to be > 1_398_894_170
      end
    end
  end
  describe 'failure' do
    it 'handles more arguments'
    it 'handles invalid timezones'
  end
end
