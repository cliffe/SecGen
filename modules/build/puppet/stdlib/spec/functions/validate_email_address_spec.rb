require 'spec_helper'

describe 'validate_email_address' do
  describe 'signature validation' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  end

  describe 'valid inputs' do
    it { is_expected.to run.with_params('bob@gmail.com') }
    it { is_expected.to run.with_params('alice+puppetlabs.com@gmail.com') }
  end

  describe 'invalid inputs' do
    it { is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params('one').and_raise_error(Puppet::ParseError, %r{is not a valid email}) }
    it { is_expected.to run.with_params('bob@gmail.com', {}).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params('bob@gmail.com', true).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params('bob@gmail.com', 'one').and_raise_error(Puppet::ParseError, %r{is not a valid email}) }
  end
end
