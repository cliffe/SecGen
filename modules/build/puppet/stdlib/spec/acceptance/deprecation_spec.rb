#! /usr/bin/env ruby -S rspec
require 'spec_helper_acceptance'

describe 'deprecation function' do

  if fact('operatingsystem') == 'windows'
    test_file = 'C:/deprecation'
    else
    test_file = "/tmp/deprecation"
  end

  # It seems that Windows needs everything to be on one line when using puppet apply -e, otherwise the manifests would be in an easier format
  add_file_manifest = "\"deprecation('key', 'message') file { '#{test_file}': ensure => present, content => 'test', }\""
  remove_file_manifest = "file { '#{test_file}': ensure => absent }"

  before :all do
    apply_manifest(remove_file_manifest)
  end

  context 'with --strict=error', if: get_puppet_version =~ /^4/ do
    before :all do
      @result = on(default, puppet('apply', '--strict=error', '-e', add_file_manifest), acceptable_exit_codes: (0...256))
    end

    after :all do
      apply_manifest(remove_file_manifest)
    end

    it "should return an error" do
      expect(@result.exit_code).to eq(1)
    end

    it "should show the error message" do
      expect(@result.stderr).to match(/deprecation. key. message/)
    end

    describe file("#{test_file}") do
      it { is_expected.not_to be_file }
    end
  end

  context 'with --strict=warning', if: get_puppet_version =~ /^4/ do
    before :all do
      @result = on(default, puppet('apply', '--strict=warning', '-e', add_file_manifest), acceptable_exit_codes: (0...256))
    end

    after :all do
      apply_manifest(remove_file_manifest)
    end

    it "should not return an error" do
      expect(@result.exit_code).to eq(0)
    end

    it "should show the error message" do
      expect(@result.stderr).to match(/Warning: message/)
    end

    describe file("#{test_file}") do
      it { is_expected.to be_file }
    end
  end

  context 'with --strict=off', if: get_puppet_version =~ /^4/ do
    before :all do
      @result = on(default, puppet('apply', '--strict=off', '-e', add_file_manifest), acceptable_exit_codes: (0...256))
    end

    after :all do
      apply_manifest(remove_file_manifest)
    end

    it "should not return an error" do
      expect(@result.exit_code).to eq(0)
    end

    it "should not show the error message" do
      expect(@result.stderr).not_to match(/Warning: message/)
    end

    describe file("#{test_file}") do
      it { is_expected.to be_file }
    end
  end

  context 'puppet 3 test', if: get_puppet_version =~ /^3/ do
    before :all do
      @result = on(default, puppet('apply', '--parser=future', '-e', add_file_manifest), acceptable_exit_codes: (0...256))
    end
    after :all do
      apply_manifest(remove_file_manifest)
    end

    it "should return a deprecation error" do
      expect(@result.stderr).to match(/Warning: message/)
    end
    it "should pass without error" do
      expect(@result.exit_code).to eq(0)
    end
  end

end
