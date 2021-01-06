#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'strftime function' do
  describe 'success' do
    pp = <<-DOC
      $o = strftime('%C')
      notice(inline_template('strftime is <%= @o.inspect %>'))
    DOC
    it 'gives the Century' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{strftime is "20"})
      end
    end
    it 'takes a timezone argument'
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles invalid format strings'
  end
end
