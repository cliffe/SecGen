require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'test::float', type: :class do
    describe 'accepts floats' do
      [
        3.7,
        '3.7',
        -3.7,
        '-342.2315e-12',
      ].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile }
        end
      end
    end

    describe 'rejects other values' do
      [ true, 'true', false, 'false', 'iAmAString', '1test', '1 test', 'test 1', 'test 1 test', {}, { 'key' => 'value' }, { 1=> 2 }, '', :undef , 'x', 3, '3', -3, '-3'].each do |value|
        describe value.inspect do
          let(:params) {{ value: value }}
          it { is_expected.to compile.and_raise_error(/parameter 'value' expects a value of type Float or Pattern(\[.*\]+)?/) }
        end
      end
    end
  end
end
