require 'spec_helper'

describe 'length' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError, %r{'length' expects 1 argument, got none}) }
  it { is_expected.to run.with_params([], 'extra').and_raise_error(ArgumentError, %r{'length' expects 1 argument, got 2}) }
  it { is_expected.to run.with_params(1).and_raise_error(ArgumentError, %r{expects a value of type String, Array, or Hash, got Integer}) }
  it { is_expected.to run.with_params(true).and_raise_error(ArgumentError, %r{expects a value of type String, Array, or Hash, got Boolean}) }
  it { is_expected.to run.with_params('1').and_return(1) }
  it { is_expected.to run.with_params('1.0').and_return(3) }
  it { is_expected.to run.with_params([]).and_return(0) }
  it { is_expected.to run.with_params(['a']).and_return(1) }
  it { is_expected.to run.with_params(%w[one two three]).and_return(3) }
  it { is_expected.to run.with_params(%w[one two three four]).and_return(4) }

  it { is_expected.to run.with_params({}).and_return(0) }
  it { is_expected.to run.with_params('1' => '2').and_return(1) }
  it { is_expected.to run.with_params('1' => '2', '4' => '4').and_return(2) }
  it { is_expected.to run.with_params('€' => '@', '竹' => 'ǿňè').and_return(2) }

  it { is_expected.to run.with_params('').and_return(0) }
  it { is_expected.to run.with_params('a').and_return(1) }
  it { is_expected.to run.with_params('abc').and_return(3) }
  it { is_expected.to run.with_params('abcd').and_return(4) }
  it { is_expected.to run.with_params('万').and_return(1) }
  it { is_expected.to run.with_params('āβćđ').and_return(4) }

  context 'when using a class extending String' do
    it { is_expected.to run.with_params(AlsoString.new('asdfghjkl')).and_return(9) }
  end
end
