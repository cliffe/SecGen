#! /usr/bin/env ruby -S rspec # rubocop:disable Lint/ScriptPermission
require 'spec_helper_acceptance'

# Windows and OS X do not have useful implementations of crypt(3)
describe 'pw_hash function', :unless => %w[windows Darwin SLES].include?(fact('operatingsystem')) do
  describe 'success' do
    pp1 = <<-DOC
      $o = pw_hash('password', 'sha-512', 'salt')
      notice(inline_template('pw_hash is <%= @o.inspect %>'))
    DOC
    it 'hashes passwords' do
      apply_manifest(pp1, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{pw_hash is "\$6\$salt\$IxDD3jeSOb5eB1CX5LBsqZFVkJdido3OUILO5Ifz5iwMuTS4XMS130MTSuDDl3aCI6WouIL9AjRbLCelDCy\.g\."})
      end
    end

    pp2 = <<-DOC
      $o = pw_hash('', 'sha-512', 'salt')
      notice(inline_template('pw_hash is <%= @o.inspect %>'))
    DOC
    it 'returns nil if no password is provided' do
      apply_manifest(pp2, :catch_failures => true) do |r|
        expect(r.stdout).to match(%r{pw_hash is nil})
      end
    end
  end
  describe 'failure' do
    it 'handles less than three arguments'
    it 'handles more than three arguments'
    it 'handles non strings'
  end
end
