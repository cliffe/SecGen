require 'spec_helper'

describe 'validate_ipv4_address' do

  describe 'signature validation' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  end

  context 'Checking for deprecation warning', if: Puppet.version.to_f < 4.0 do
    after(:all) do
      ENV.delete('STDLIB_LOG_DEPRECATIONS')
    end
    # Checking for deprecation warning, which should only be provoked when the env variable for it is set.
    it 'should display a single deprecation' do
      ENV['STDLIB_LOG_DEPRECATIONS'] = "true"
      scope.expects(:warning).with(includes('This method is deprecated'))
      is_expected.to run.with_params(SharedData::IPV4_PATTERNS.first)
    end
    it 'should display no warning for deprecation' do
      ENV['STDLIB_LOG_DEPRECATIONS'] = "false"
      scope.expects(:warning).with(includes('This method is deprecated')).never
      is_expected.to run.with_params(SharedData::IPV4_PATTERNS.first)
    end
  end

  SharedData::IPV4_PATTERNS.each do |value|
    it { is_expected.to run.with_params(value) }
  end

  SharedData::IPV4_NEGATIVE_PATTERNS.each do |value|
    it { is_expected.to run.with_params(value).and_raise_error(Puppet::ParseError, /is not a valid IPv4/) }
  end

  describe 'invalid inputs' do
    [ {}, [], 1, true ].each do |invalid|
      it { is_expected.to run.with_params(invalid).and_raise_error(Puppet::ParseError, /is not a string/) }
      it { is_expected.to run.with_params(SharedData::IPV4_PATTERNS.first, invalid).and_raise_error(Puppet::ParseError, /is not a string/) }
    end
  end
end
