#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'parsejson function' do
  describe 'success' do
    it 'parses valid json' do
      pp = <<-EOS
      $a = '{"hunter": "washere", "tests": "passing"}'
      $ao = parsejson($a)
      $tests = $ao['tests']
      notice(inline_template('tests are <%= @tests.inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/tests are "passing"/)
      end
    end
  end

  describe 'failure' do
    it 'raises error on incorrect json' do
      pp = <<-EOS
      $a = '{"hunter": "washere", "tests": "passing",}'
      $ao = parsejson($a, 'tests are using the default value')
      notice(inline_template('a is <%= @ao.inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/tests are using the default value/)
      end
    end

    it 'raises error on incorrect json' do
      pp = <<-EOS
      $a = '{"hunter": "washere", "tests": "passing",}'
      $ao = parsejson($a)
      notice(inline_template('a is <%= @ao.inspect %>'))
      EOS

      apply_manifest(pp, :expect_failures => true) do |r|
        expect(r.stderr).to match(/expected next name/)
      end
    end

    it 'raises error on incorrect number of arguments' do
      pp = <<-EOS
      $o = parsejson()
      EOS

      apply_manifest(pp, :expect_failures => true) do |r|
        expect(r.stderr).to match(/wrong number of arguments/i)
      end
    end
  end
end
