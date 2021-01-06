#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'base64 function' do
  describe 'success' do
    pp = <<-DOC
      $encodestring = base64('encode', 'thestring')
      $decodestring = base64('decode', $encodestring)
      notify { $decodestring: }
    DOC
    it 'encodes then decode a string' do
      apply_manifest(pp, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{thestring})
      end
    end
  end
end
