#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'ensure_resource function' do
  describe 'success' do
    pp1 = <<-DOC
      notify { "test": loglevel => 'err' }
      ensure_resource('notify', 'test', { 'loglevel' => 'err' })
    DOC
    it 'ensures a resource already declared' do
      apply_manifest('')

      apply_manifest(pp1, :expect_changes => true)
    end

    pp2 = <<-DOC
      ensure_resource('notify', 'test', { 'loglevel' => 'err' })
    DOC
    it 'ensures a undeclared resource' do
      apply_manifest('')

      apply_manifest(pp2, :expect_changes => true)
    end
    it 'takes defaults arguments'
  end
  describe 'failure' do
    it 'handles no arguments'
    it 'handles non strings'
  end
end
