require 'spec_helper'

describe 'to_json' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params('').and_return('""') }
  it { is_expected.to run.with_params(true).and_return('true') }
  it { is_expected.to run.with_params('one').and_return('"one"') }
  it { is_expected.to run.with_params([]).and_return('[]') }
  it { is_expected.to run.with_params(['one']).and_return('["one"]') }
  it { is_expected.to run.with_params(%w[one two]).and_return('["one","two"]') }
  it { is_expected.to run.with_params({}).and_return('{}') }
  it { is_expected.to run.with_params('key' => 'value').and_return('{"key":"value"}') }
  it {
    is_expected.to run.with_params('one' => { 'oneA' => 'A', 'oneB' => { 'oneB1' => '1', 'oneB2' => '2' } }, 'two' => %w[twoA twoB])
                      .and_return('{"one":{"oneA":"A","oneB":{"oneB1":"1","oneB2":"2"}},"two":["twoA","twoB"]}')
  }

  it { is_expected.to run.with_params('‰').and_return('"‰"') }
  it { is_expected.to run.with_params('竹').and_return('"竹"') }
  it { is_expected.to run.with_params('Ü').and_return('"Ü"') }
  it { is_expected.to run.with_params('∇').and_return('"∇"') }
end
