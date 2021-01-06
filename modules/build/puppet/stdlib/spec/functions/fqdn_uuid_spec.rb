require 'spec_helper'

describe 'fqdn_uuid' do
  context 'with invalid parameters' do
    it { is_expected.to run.with_params.and_raise_error(ArgumentError, %r{No arguments given$}) }
  end

  context 'with given string' do
    it { is_expected.to run.with_params('puppetlabs.com').and_return('9c70320f-6815-5fc5-ab0f-debe68bf764c') }
    it { is_expected.to run.with_params('google.com').and_return('64ee70a4-8cc1-5d25-abf2-dea6c79a09c8') }
  end
end
