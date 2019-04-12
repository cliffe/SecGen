require 'spec_helper'

describe 'try_get_value' do

  let(:data) do
    {
        'a' => {
            'g' => '2',
            'e' => [
                'f0',
                'f1',
                {
                    'x' => {
                        'y' => 'z'
                    }
                },
                'f3',
            ]
        },
        'b' => true,
        'c' => false,
        'd' => '1',
    }
  end

  context 'single values' do
    it 'should exist' do
      is_expected.not_to eq(nil)
    end

    it 'should be able to return a single value' do
      is_expected.to run.with_params('test').and_return('test')
    end

    it 'should use the default value if data is a single value and path is present' do
      is_expected.to run.with_params('test', 'path', 'default').and_return('default')
    end

    it 'should return default if there is no data' do
      is_expected.to run.with_params(nil, nil, 'default').and_return('default')
    end

    it 'should be able to use data structures as default values' do
      is_expected.to run.with_params('test', 'path', data).and_return(data)
    end
  end

  context 'structure values' do
    it 'should be able to extracts a single hash value' do
      is_expected.to run.with_params(data, 'd', 'default').and_return('1')
    end

    it 'should be able to extract a deeply nested hash value' do
      is_expected.to run.with_params(data, 'a/g', 'default').and_return('2')
    end

    it 'should return the default value if the path is not found' do
      is_expected.to run.with_params(data, 'missing', 'default').and_return('default')
    end

    it 'should return the default value if the path is too long' do
      is_expected.to run.with_params(data, 'a/g/c/d', 'default').and_return('default')
    end

    it 'should support an array index in the path' do
      is_expected.to run.with_params(data, 'a/e/1', 'default').and_return('f1')
    end

    it 'should return the default value if an array index is not a number' do
      is_expected.to run.with_params(data, 'a/b/c', 'default').and_return('default')
    end

    it 'should return the default value if and index is out of array length' do
      is_expected.to run.with_params(data, 'a/e/5', 'default').and_return('default')
    end

    it 'should be able to path though both arrays and hashes' do
      is_expected.to run.with_params(data, 'a/e/2/x/y', 'default').and_return('z')
    end

    it 'should be able to return "true" value' do
      is_expected.to run.with_params(data, 'b', 'default').and_return(true)
      is_expected.to run.with_params(data, 'm', true).and_return(true)
    end

    it 'should be able to return "false" value' do
      is_expected.to run.with_params(data, 'c', 'default').and_return(false)
      is_expected.to run.with_params(data, 'm', false).and_return(false)
    end

    it 'should return "nil" if value is not found and no default value is provided' do
      is_expected.to run.with_params(data, 'a/1').and_return(nil)
    end

    it 'should be able to use a custom path separator' do
      is_expected.to run.with_params(data, 'a::g', 'default', '::').and_return('2')
      is_expected.to run.with_params(data, 'a::c', 'default', '::').and_return('default')
    end
  end
end
