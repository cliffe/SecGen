#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'max function' do
  describe 'success' do
    pp = <<-DOC
      $o = max("the","public","art","galleries")
      notice(inline_template('max is <%= @o.inspect %>'))
    DOC
    it 'maxs arrays' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{max is "the"})
      end
    end
  end
  describe 'failure' do
    it 'handles no arguments'
  end
end
