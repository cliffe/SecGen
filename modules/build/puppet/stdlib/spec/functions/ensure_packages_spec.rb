require 'spec_helper'

describe 'ensure_packages' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError) }
  it {
    pending('should not accept numbers as arguments')
    is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError)
  }
  it {
    pending('should not accept numbers as arguments')
    is_expected.to run.with_params(['packagename', 1]).and_raise_error(Puppet::ParseError)
  }
  it { is_expected.to run.with_params('packagename') }
  it { is_expected.to run.with_params(%w[packagename1 packagename2]) }

  context 'when given a catalog with "package { puppet: ensure => absent }"' do
    let(:pre_condition) { 'package { puppet: ensure => absent }' }

    describe 'after running ensure_package("facter")' do
      before(:each) { subject.call(['facter']) }

      # this lambda is required due to strangeness within rspec-puppet's expectation handling
      it { expect(-> { catalogue }).to contain_package('puppet').with_ensure('absent') }
      it { expect(-> { catalogue }).to contain_package('facter').with_ensure('present') }
    end

    describe 'after running ensure_package("facter", { "provider" => "gem" })' do
      before(:each) { subject.call(['facter', { 'provider' => 'gem' }]) }

      # this lambda is required due to strangeness within rspec-puppet's expectation handling
      it { expect(-> { catalogue }).to contain_package('puppet').with_ensure('absent').without_provider }
      it { expect(-> { catalogue }).to contain_package('facter').with_ensure('present').with_provider('gem') }
    end
  end

  context 'when given an empty packages array' do
    let(:pre_condition) { 'notify { "hi": } -> Package <| |>; $somearray = ["vim",""]; ensure_packages($somearray)' }

    describe 'after running ensure_package(["vim", ""])' do
      it { expect { catalogue }.to raise_error(Puppet::ParseError, %r{Empty String provided}) }
    end
  end

  context 'when given hash of packages' do
    before(:each) do
      subject.call([{ 'foo' => { 'provider' => 'rpm' }, 'bar' => { 'provider' => 'gem' } }, { 'ensure' => 'present' }])
      subject.call([{ 'パッケージ' => { 'ensure' => 'absent' } }])
      subject.call([{ 'ρǻ¢κầģẻ' => { 'ensure' => 'absent' } }])
    end

    # this lambda is required due to strangeness within rspec-puppet's expectation handling
    it { expect(-> { catalogue }).to contain_package('foo').with('provider' => 'rpm', 'ensure' => 'present') }
    it { expect(-> { catalogue }).to contain_package('bar').with('provider' => 'gem', 'ensure' => 'present') }

    context 'with UTF8 and double byte characters' do
      it { expect(-> { catalogue }).to contain_package('パッケージ').with('ensure' => 'absent') }
      it { expect(-> { catalogue }).to contain_package('ρǻ¢κầģẻ').with('ensure' => 'absent') }
    end
  end

  context 'when given a catalog with "package { puppet: ensure => present }"' do
    let(:pre_condition) { 'package { puppet: ensure => present }' }

    describe 'after running ensure_package("puppet", { "ensure" => "installed" })' do
      before(:each) { subject.call(['puppet', { 'ensure' => 'installed' }]) }

      # this lambda is required due to strangeness within rspec-puppet's expectation handling
      it { expect(-> { catalogue }).to contain_package('puppet').with_ensure('present') }
    end
  end
end
