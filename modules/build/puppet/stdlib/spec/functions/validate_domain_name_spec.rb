require 'spec_helper'

describe 'validate_domain_name' do
  describe 'signature validation' do
    it { is_expected.not_to eq(nil) }
    it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  end

  describe 'valid inputs' do
    it { is_expected.to run.with_params('com', 'com.') }
    it { is_expected.to run.with_params('x.com', 'x.com.') }
    it { is_expected.to run.with_params('foo.example.com', 'foo.example.com.') }
    it { is_expected.to run.with_params('2foo.example.com', '2foo.example.com.') }
    it { is_expected.to run.with_params('www.2foo.example.com', 'www.2foo.example.com.') }
    it { is_expected.to run.with_params('domain.tld', 'puppet.com') }
  end

  describe 'invalid inputs' do
    it { is_expected.to run.with_params([]).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params({}).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params(1).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params(true).and_raise_error(Puppet::ParseError, %r{is not a string}) }

    it { is_expected.to run.with_params('foo.example.com', []).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params('foo.example.com', {}).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params('foo.example.com', 1).and_raise_error(Puppet::ParseError, %r{is not a string}) }
    it { is_expected.to run.with_params('foo.example.com', true).and_raise_error(Puppet::ParseError, %r{is not a string}) }

    it { is_expected.to run.with_params('').and_raise_error(Puppet::ParseError, %r{is not a syntactically correct domain name}) }
    it { is_expected.to run.with_params('invalid domain').and_raise_error(Puppet::ParseError, %r{is not a syntactically correct domain name}) }
    it { is_expected.to run.with_params('-foo.example.com').and_raise_error(Puppet::ParseError, %r{is not a syntactically correct domain name}) }
    it { is_expected.to run.with_params('www.example.2com').and_raise_error(Puppet::ParseError, %r{is not a syntactically correct domain name}) }
    it { is_expected.to run.with_params('192.168.1.1').and_raise_error(Puppet::ParseError, %r{is not a syntactically correct domain name}) }
  end
end
