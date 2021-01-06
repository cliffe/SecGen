require 'spec_helper'

describe 'is_ipv6_address' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(Puppet::ParseError, %r{wrong number of arguments}i) }
  it { is_expected.to run.with_params('2001:0db8:85a3:0000:0000:8a2e:0370:7334').and_return(true) }
  it { is_expected.to run.with_params('85a3:0000:0000:8a2e:0370:7334:100.100.100.100').and_return(true) }
  it { is_expected.to run.with_params('1.2.3').and_return(false) }
  it { is_expected.to run.with_params('1.2.3.4.5').and_return(false) }
  it { is_expected.to run.with_params('').and_return(false) }
  it { is_expected.to run.with_params('one').and_return(false) }

  context 'Checking for deprecation warning', :if => Puppet.version.to_f < 4.0 do
    after(:each) do
      ENV.delete('STDLIB_LOG_DEPRECATIONS')
    end
    # Checking for deprecation warning, which should only be provoked when the env variable for it is set.
    it 'displays a single deprecation' do
      ENV['STDLIB_LOG_DEPRECATIONS'] = 'true'
      scope.expects(:warning).with(includes('This method is deprecated'))
      is_expected.to run.with_params('2001:0db8:85a3:0000:0000:8a2e:0370:7334').and_return(true)
    end
    it 'displays no warning for deprecation' do
      ENV['STDLIB_LOG_DEPRECATIONS'] = 'false'
      scope.expects(:warning).with(includes('This method is deprecated')).never
      is_expected.to run.with_params('2001:0db8:85a3:0000:0000:8a2e:0370:7334').and_return(true)
    end
  end
end
