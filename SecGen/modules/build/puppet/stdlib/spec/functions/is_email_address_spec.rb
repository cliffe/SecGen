require 'spec_helper'

describe 'is_email_address' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params([], []).and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it { is_expected.to run.with_params('bob@gmail.com').and_return(true) }
  it { is_expected.to run.with_params('alice+puppetlabs.com@gmail.com').and_return(true) }
  it { is_expected.to run.with_params('peter.parker@gmail.com').and_return(true) }
  it { is_expected.to run.with_params('1.2.3@domain').and_return(false) }
  it { is_expected.to run.with_params('1.2.3.4.5@').and_return(false) }
  it { is_expected.to run.with_params({}).and_return(false) }
  it { is_expected.to run.with_params([]).and_return(false) }
end
