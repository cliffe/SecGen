#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'validate_augeas function', :unless => (fact('osfamily') == 'windows') do
  describe 'prep' do
    it 'installs augeas for tests'
  end
  describe 'success' do
    context 'with valid inputs with no 3rd argument' do
      {
        'root:x:0:0:root:/root:/bin/bash\n'                        => 'Passwd.lns',
        'proc /proc   proc    nodev,noexec,nosuid     0       0\n' => 'Fstab.lns',
      }.each do |line, lens|
        pp1 = <<-DOC
          $line = "#{line}"
          $lens = "#{lens}"
          validate_augeas($line, $lens)
        DOC
        it "validates a single argument for #{lens}" do
          apply_manifest(pp1, :catch_failures => true)
        end
      end
    end

    context 'with valid inputs with 3rd and 4th arguments' do
      line        = 'root:x:0:0:root:/root:/bin/barsh\n'
      lens        = 'Passwd.lns'
      restriction = '$file/*[shell="/bin/barsh"]'
      pp2 = <<-DOC
        $line        = "#{line}"
        $lens        = "#{lens}"
        $restriction = ['#{restriction}']
        validate_augeas($line, $lens, $restriction, "my custom failure message")
      DOC
      it 'validates a restricted value' do
        expect(apply_manifest(pp2, :expect_failures => true).stderr).to match(%r{my custom failure message})
      end
    end

    context 'with invalid inputs' do
      {
        'root:x:0:0:root' => 'Passwd.lns',
        '127.0.1.1'       => 'Hosts.lns',
      }.each do |line, lens|
        pp3 = <<-DOC
          $line = "#{line}"
          $lens = "#{lens}"
          validate_augeas($line, $lens)
        DOC
        it "validates a single argument for #{lens}" do
          apply_manifest(pp3, :expect_failures => true)
        end
      end
    end
    context 'with garbage inputs' do
      it 'raises an error on invalid inputs'
    end
  end
  describe 'failure' do
    it 'handles improper number of arguments'
  end
end
