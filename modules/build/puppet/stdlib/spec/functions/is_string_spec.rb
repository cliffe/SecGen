require 'spec_helper'

describe 'is_string' do

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(Puppet::ParseError, /wrong number of arguments/i) }
  it {
    pending("Current implementation ignores parameters after the first.")
    is_expected.to run.with_params('', '').and_raise_error(Puppet::ParseError, /wrong number of arguments/i)
  }

  it { is_expected.to run.with_params(3).and_return(false) }
  it { is_expected.to run.with_params('3').and_return(false) }
  it { is_expected.to run.with_params(-3).and_return(false) }
  it { is_expected.to run.with_params('-3').and_return(false) }

  it { is_expected.to run.with_params(3.7).and_return(false) }
  it { is_expected.to run.with_params('3.7').and_return(false) }
  it { is_expected.to run.with_params(-3.7).and_return(false) }
  it { is_expected.to run.with_params('3.7').and_return(false) }

  it { is_expected.to run.with_params([]).and_return(false) }
  it { is_expected.to run.with_params([1]).and_return(false) }
  it { is_expected.to run.with_params({}).and_return(false) }
  it { is_expected.to run.with_params(true).and_return(false) }
  it { is_expected.to run.with_params(false).and_return(false) }
  it { is_expected.to run.with_params('one').and_return(true) }
  it { is_expected.to run.with_params('0001234').and_return(true) }

  context 'Checking for deprecation warning' do
    after(:all) do
      ENV.delete('STDLIB_LOG_DEPRECATIONS')
    end
    # Checking for deprecation warning, which should only be provoked when the env variable for it is set.
    it 'should display a single deprecation' do
      ENV['STDLIB_LOG_DEPRECATIONS'] = "true"
      scope.expects(:warning).with(includes('This method is deprecated'))
      is_expected.to run.with_params('sponge').and_return(true)
    end
    it 'should display no warning for deprecation' do
      ENV['STDLIB_LOG_DEPRECATIONS'] = "false"
      scope.expects(:warning).with(includes('This method is deprecated')).never
      is_expected.to run.with_params('bob').and_return(true)
    end
  end 

end
