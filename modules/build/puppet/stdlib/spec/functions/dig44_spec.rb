require 'spec_helper'

describe 'dig44' do
  let(:data) do
    {
      'a' => {
        'g' => '2',
        'e' => [
          'f0',
          'f1',
          {
            'x' => {
              'y' => 'z',
            },
          },
          'f3',
        ],
      },
      'b' => true,
      'c' => false,
      'd' => '1',
      'e' => :undef,
      'f' => nil,
    }
  end

  let(:utf8_data) do
    {
      'ẵ' => {
        'в' => [
          '©',
          'ĝ',
          'に',
        ],
      },
    }
  end

  context 'with single values' do
    it 'exists' do
      is_expected.not_to be_nil
    end

    it 'requires two arguments' do
      is_expected.to run.with_params.and_raise_error(ArgumentError)
    end

    it 'fails if the data is not a structure' do
      is_expected.to run.with_params('test', []).and_raise_error(Puppet::Error)
    end

    it 'fails if the path is not an array' do
      is_expected.to run.with_params({}, '').and_raise_error(Puppet::Error)
    end

    it 'returns the value if the value is string' do
      is_expected.to run.with_params(data, ['d'], 'default').and_return('1')
    end

    it 'returns true if the value is true' do
      is_expected.to run.with_params(data, ['b'], 'default').and_return(true)
    end

    it 'returns false if the value is false' do
      is_expected.to run.with_params(data, ['c'], 'default').and_return(false)
    end

    it 'returns the default if the value is nil' do
      is_expected.to run.with_params(data, ['f'], 'default').and_return('default')
    end

    it 'returns the default if the value is :undef (same as nil)' do
      is_expected.to run.with_params(data, ['e'], 'default').and_return('default')
    end

    it 'returns the default if the path is not found' do
      is_expected.to run.with_params(data, ['missing'], 'default').and_return('default')
    end
  end

  context 'with structured values' do
    it 'is able to extract a deeply nested hash value' do
      is_expected.to run.with_params(data, %w[a g], 'default').and_return('2')
    end

    it 'returns the default value if the path is too long' do
      is_expected.to run.with_params(data, %w[a g c d], 'default').and_return('default')
    end

    it 'supports an array index (number) in the path' do
      is_expected.to run.with_params(data, ['a', 'e', 1], 'default').and_return('f1')
    end

    it 'supports an array index (string) in the path' do
      is_expected.to run.with_params(data, %w[a e 1], 'default').and_return('f1')
    end

    it 'returns the default value if an array index is not a number' do
      is_expected.to run.with_params(data, %w[a b c], 'default').and_return('default')
    end

    it 'returns the default value if and index is out of array length' do
      is_expected.to run.with_params(data, %w[a e 5], 'default').and_return('default')
    end

    it 'is able to path though both arrays and hashes' do
      is_expected.to run.with_params(data, %w[a e 2 x y], 'default').and_return('z')
    end

    it 'returns "nil" if value is not found and no default value is provided' do
      is_expected.to run.with_params(data, %w[a 1]).and_return(nil)
    end
  end

  context 'with internationalization (i18N) values' do
    it 'is able to return a unicode character' do
      is_expected.to run.with_params(utf8_data, ['ẵ', 'в', 0]).and_return('©')
    end

    it 'is able to return a utf8 character' do
      is_expected.to run.with_params(utf8_data, ['ẵ', 'в', 1]).and_return('ĝ')
    end

    it 'is able to return a double byte character' do
      is_expected.to run.with_params(utf8_data, ['ẵ', 'в', 2]).and_return('に')
    end
  end
end
