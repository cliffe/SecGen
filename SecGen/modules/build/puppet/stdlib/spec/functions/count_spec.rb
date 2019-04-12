require 'spec_helper'

describe 'count' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params("one").and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params("one", "two").and_return(1) }
  it {
    pending("should actually be like this, and not like above")
    is_expected.to run.with_params("one", "two").and_raise_error(ArgumentError)
  }
  it { is_expected.to run.with_params("one", "two", "three").and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params(["one", "two", "three"]).and_return(3) }
  it { is_expected.to run.with_params(["one", "two", "two"], "two").and_return(2) }
  it { is_expected.to run.with_params(["one", nil, "two"]).and_return(2) }
  it { is_expected.to run.with_params(["one", "", "two"]).and_return(2) }
  it { is_expected.to run.with_params(["one", :undef, "two"]).and_return(2) }

  it { is_expected.to run.with_params(["ổņ℮", "ŧщộ", "three"]).and_return(3) }
  it { is_expected.to run.with_params(["ổņ℮", "ŧщộ", "ŧщộ"], "ŧщộ").and_return(2) }
  it { is_expected.to run.with_params(["ổņ℮", nil, "ŧщộ"]).and_return(2) }
  it { is_expected.to run.with_params(["ổņ℮", :undef, "ŧщộ"]).and_return(2) }
end
