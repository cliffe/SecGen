require 'spec_helper'

describe 'fqdn_uuid' do

  context "Invalid parameters" do
    it { should run.with_params().and_raise_error(ArgumentError, /No arguments given$/) }
  end

  context "given string" do
    it { should run.with_params('puppetlabs.com').and_return('9c70320f-6815-5fc5-ab0f-debe68bf764c') }
    it { should run.with_params('google.com').and_return('64ee70a4-8cc1-5d25-abf2-dea6c79a09c8') }
  end
end
