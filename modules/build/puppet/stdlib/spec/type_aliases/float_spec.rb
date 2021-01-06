require 'spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  describe 'Stdlib::Compat::Float' do
    describe 'accepts floats' do
      [
        3.7,
        '3.7',
        -3.7,
        '-342.2315e-12',
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end

    describe 'rejects other values' do
      [true, 'true', false, 'false', 'iAmAString', '1test', '1 test', 'test 1', 'test 1 test', {}, { 'key' => 'value' }, { 1 => 2 }, '', :undef, 'x', 3, '3', -3, '-3'].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
