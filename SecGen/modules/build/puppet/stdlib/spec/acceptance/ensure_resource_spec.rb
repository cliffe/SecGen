#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'ensure_resource function' do
  describe 'success' do
    it 'ensures a resource already declared' do
      apply_manifest('')
      pp = <<-EOS
      notify { "test": loglevel => 'err' }
      ensure_resource('notify', 'test', { 'loglevel' => 'err' })
      EOS

      apply_manifest(pp, :expect_changes => true)
    end

    it 'ensures a undeclared resource' do
      apply_manifest('')
      pp = <<-EOS
      ensure_resource('notify', 'test', { 'loglevel' => 'err' })
      EOS

      apply_manifest(pp, :expect_changes => true)
    end
    it 'takes defaults arguments'
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings'
  end
end
