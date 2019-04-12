require 'spec_helper'

describe 'validate_ipv6_address' do
  
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
      is_expected.to run.with_params('3ffe:0505:0002::')
    end
    it 'should display no warning for deprecation' do
      ENV['STDLIB_LOG_DEPRECATIONS'] = "false"
      scope.expects(:warning).with(includes('This method is deprecated')).never
      is_expected.to run.with_params('3ffe:0505:0002::')
    end
  end 

  describe 'valid inputs' do
    it { is_expected.to run.with_params('3ffe:0505:0002::') }
    it { is_expected.to run.with_params('3ffe:0505:0002::', '3ffe:0505:0002::2') }
    it { is_expected.to run.with_params('::1/64') }
    it { is_expected.to run.with_params('fe80::a00:27ff:fe94:44d6/64') }
    it { is_expected.to run.with_params('fe80:0000:0000:0000:0204:61ff:fe9d:f156') }
    it { is_expected.to run.with_params('fe80:0:0:0:204:61ff:fe9d:f156') }
    it { is_expected.to run.with_params('fe80::204:61ff:fe9d:f156') }
    it { is_expected.to run.with_params('fe80:0:0:0:0204:61ff:254.157.241.86') }
    it { is_expected.to run.with_params('::1') }
    it { is_expected.to run.with_params('fe80::') }
    it { is_expected.to run.with_params('2001::') }
  end

  describe 'invalid inputs' do
    it { is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError, /is not a string/) }
    it { is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, /is not a string/) }
    it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    it { is_expected.to run.with_params('0.0.0').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    it { is_expected.to run.with_params('0.0.0.256').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    it { is_expected.to run.with_params('0.0.0.0.0').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    it { is_expected.to run.with_params('::ffff:2.3.4').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    it { is_expected.to run.with_params('::ffff:257.1.2.3').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    it { is_expected.to run.with_params('::ffff:12345678901234567890.1.26').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    it { is_expected.to run.with_params('affe:beef').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    it { is_expected.to run.with_params('::1', {}).and_raise_error(Puppet::ParseError, /is not a string/) }
    it { is_expected.to run.with_params('::1', true).and_raise_error(Puppet::ParseError, /is not a string/) }
    it { is_expected.to run.with_params('::1', 'one').and_raise_error(Puppet::ParseError, /is not a valid IPv6/) }
    context 'unless running on ruby 1.8.7', :if => RUBY_VERSION != '1.8.7' do
      it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, /is not a string/) }
      it { is_expected.to run.with_params('::1', 1).and_raise_error(Puppet::ParseError, /is not a string/) }
    end
  end
end
