#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'min function' do
  describe 'success' do
    pp = <<-DOC
      $o = min("the","public","art","galleries")
      notice(inline_template('min is <%= @o.inspect %>'))
    DOC
    it 'mins arrays' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{min is "art"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
  end
end
