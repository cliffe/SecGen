#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'defined_with_params function' do
  describe 'success' do
    pp = <<-DOC
      user { 'dan':
        ensure => present,
      }

      if defined_with_params(User[dan], {'ensure' => 'present' }) {
        notify { 'User defined with ensure=>present': }
      }
    DOC
    it 'successfullies notify' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{Notice: User defined with ensure=>present})
      end
    end
  end
end
