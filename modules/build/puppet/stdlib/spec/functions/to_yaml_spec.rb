require 'spec_helper'

describe 'to_yaml' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params('').and_return("--- ''\n") }
  it { is_expected.to run.with_params(true).and_return("--- true\n...\n") }
  it { is_expected.to run.with_params('one').and_return("--- one\n...\n") }
  it { is_expected.to run.with_params([]).and_return("--- []\n") }
  it { is_expected.to run.with_params(['one']).and_return("---\n- one\n") }
  it { is_expected.to run.with_params(%w[one two]).and_return("---\n- one\n- two\n") }
  it { is_expected.to run.with_params({}).and_return("--- {}\n") }
  it { is_expected.to run.with_params('key' => 'value').and_return("---\nkey: value\n") }
  it {
    is_expected.to run.with_params('one' => { 'oneA' => 'A', 'oneB' => { 'oneB1' => '1', 'oneB2' => '2' } }, 'two' => %w[twoA twoB])
                      .and_return("---\none:\n  oneA: A\n  oneB:\n    oneB1: '1'\n    oneB2: '2'\ntwo:\n- twoA\n- twoB\n")
  }

  it { is_expected.to run.with_params('‰').and_return("--- \"‰\"\n") }
  it { is_expected.to run.with_params('∇').and_return("--- \"∇\"\n") }
end
