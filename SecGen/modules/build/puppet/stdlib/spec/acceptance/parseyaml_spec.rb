#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'parseyaml function' do
  describe 'success' do
    it 'parses valid yaml' do
      pp = <<-EOS
      $a = "---\nhunter: washere\ntests: passing\n"
      $o = parseyaml($a)
      $tests = $o['tests']
      notice(inline_template('tests are <%= @tests.inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/tests are "passing"/)
      end
    end
  end

  describe 'failure' do
    it 'returns the default value on incorrect yaml' do
      pp = <<-EOS
      $a = "---\nhunter: washere\ntests: passing\n:"
      $o = parseyaml($a, {'tests' => 'using the default value'})
      $tests = $o['tests']
      notice(inline_template('tests are <%= @tests.inspect %>'))
      EOS

      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(/tests are "using the default value"/)
      end
    end

    it 'raises error on incorrect yaml' do
      pp = <<-EOS
      $a = "---\nhunter: washere\ntests: passing\n:"
      $o = parseyaml($a)
      $tests = $o['tests']
      notice(inline_template('tests are <%= @tests.inspect %>'))
      EOS

      apply_manifest(pp, :expect_failures => true) do |r|
        expect(r.stderr).to match(/(syntax error|did not find expected key)/)
      end
    end


    it 'raises error on incorrect number of arguments' do
      pp = <<-EOS
      $o = parseyaml()
      EOS

      apply_manifest(pp, :expect_failures => true) do |r|
        expect(r.stderr).to match(/wrong number of arguments/i)
      end
    end
  end
end
