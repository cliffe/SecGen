#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'try_get_value function' do
  describe 'success' do
    pp1 = <<-DOC
      $data = {
        'a' => { 'b' => 'passing'}
      }

      $tests = try_get_value($data, 'a/b')
      notice(inline_template('tests are <%= @tests.inspect %>'))
    DOC
    it 'gets a value' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{tests are "passing"})
      end
    end
  end

  describe 'failure' do
    pp2 = <<-DOC
      $data = {
        'a' => { 'b' => 'passing'}
      }

      $tests = try_get_value($data, 'c/d', 'using the default value')
      notice(inline_template('tests are <%= @tests.inspect %>'))
    DOC
    it 'uses a default value' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{using the default value})
      end
    end

    pp = <<-DOC
      $o = try_get_value()
    DOC
    it 'raises error on incorrect number of arguments' do
      apply_manifest(pp, :expect_failures => true) do |r|
        expect(r.stderr).to match(%r{wrong number of arguments}i)
      end
    end
  end
end
